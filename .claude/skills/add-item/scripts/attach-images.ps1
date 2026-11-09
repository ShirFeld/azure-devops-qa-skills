# Uploads images and videos to an Azure DevOps work item and appends them
# under the HTML body field: ReproSteps for Bug, Description for User Story
# and Top Level Task. Images are shown inline, videos as links, each group
# under a Hebrew label (מצורפת תמונה / מצורף סרטון).
# Auth order: env PAT/token, az devops CLI credential, Azure CLI, Git credential.
# Do not print credentials.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Project,

    [Parameter(Mandatory = $true)]
    [int]$WorkItemId,

    [Parameter(Mandatory = $true)]
    [Alias("FilePaths")]
    [string[]]$ImagePaths
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Organization = $env:ADO_ORG
if (-not $Organization) {
    $Organization = [Environment]::GetEnvironmentVariable("ADO_ORG", "User")
}
if (-not $Organization) {
    throw "ADO_ORG is not set. Set it to your Azure DevOps organization name as a Windows user environment variable."
}
$ApiVersion = "7.1"

$ImageExtensions = @(".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp")
$VideoExtensions = @(".mp4", ".mov", ".webm", ".avi", ".mkv", ".m4v")

function Get-AttachmentKind {
    param([Parameter(Mandatory = $true)][string]$Path)

    $extension = [IO.Path]::GetExtension($Path).ToLowerInvariant()
    if ($ImageExtensions -contains $extension) { return "image" }
    if ($VideoExtensions -contains $extension) { return "video" }
    return $null
}

function Get-AuthorizationValueFromSecret {
    param([Parameter(Mandatory = $true)][string]$Secret)

    $value = $Secret.Trim()
    if ($value -match "^eyJ") {
        return "Bearer $value"
    }

    $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$value"))
    return "Basic $basic"
}

function Get-WindowsCredentialSecret {
    param([Parameter(Mandatory = $true)][string]$Target)

    if (-not ("WinCred" -as [type])) {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinCred {
  [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
  public struct CREDENTIAL {
    public int Flags; public int Type; public string TargetName; public string Comment;
    public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
    public int CredentialBlobSize; public IntPtr CredentialBlob; public int Persist;
    public int AttributeCount; public IntPtr Attributes; public string TargetAlias; public string UserName;
  }
  [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
  public static extern bool CredRead(string target, int type, int reservedFlag, out IntPtr credentialPtr);
  [DllImport("advapi32.dll", SetLastError = true)]
  public static extern void CredFree(IntPtr credentialPtr);
  public static string ReadSecret(string target) {
    IntPtr ptr;
    if (!CredRead(target, 1, 0, out ptr)) return null;
    try {
      var cred = (CREDENTIAL)Marshal.PtrToStructure(ptr, typeof(CREDENTIAL));
      if (cred.CredentialBlob == IntPtr.Zero || cred.CredentialBlobSize <= 0) return null;
      return Marshal.PtrToStringUni(cred.CredentialBlob, cred.CredentialBlobSize / 2);
    } finally { CredFree(ptr); }
  }
}
"@
    }

    return [WinCred]::ReadSecret($Target)
}

function Get-GitAdoCredential {
    $previousPrompt = $env:GIT_TERMINAL_PROMPT
    $previousErrorAction = $ErrorActionPreference
    $previousNative = $PSNativeCommandUseErrorActionPreference
    $env:GIT_TERMINAL_PROMPT = "0"
    $ErrorActionPreference = "Continue"
    $PSNativeCommandUseErrorActionPreference = $false
    try {
        $inputLines = "protocol=https`nhost=dev.azure.com`npath=$Organization`n`n"
        $output = $inputLines | git credential fill 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $output) {
            return $null
        }

        $user = ""
        $password = ""
        foreach ($line in $output -split "`n") {
            if ($line -match "^username=(.+)$") { $user = $Matches[1].Trim() }
            if ($line -match "^password=(.+)$") { $password = $Matches[1].Trim() }
        }

        if (-not $password) {
            return $null
        }

        return [pscustomobject]@{
            User     = $user
            Password = $password
        }
    }
    finally {
        $env:GIT_TERMINAL_PROMPT = $previousPrompt
        $ErrorActionPreference = $previousErrorAction
        $PSNativeCommandUseErrorActionPreference = $previousNative
    }
}

function Get-AdoAuthorization {
    foreach ($name in @(
            "AZURE_DEVOPS_EXT_PAT",
            "ADO_MCP_AUTH_TOKEN",
            "SYSTEM_ACCESSTOKEN",
            "PERSONAL_ACCESS_TOKEN"
        )) {
        $envValue = [Environment]::GetEnvironmentVariable($name)
        if (-not $envValue) {
            # Claude may have started before the variable was set; read the saved user value.
            $envValue = [Environment]::GetEnvironmentVariable($name, "User")
        }
        if ($envValue) {
            return Get-AuthorizationValueFromSecret -Secret $envValue
        }
    }

    $azDevopsPat = Get-WindowsCredentialSecret -Target "azdevops-cli:https://dev.azure.com/$Organization"
    if ($azDevopsPat) {
        return Get-AuthorizationValueFromSecret -Secret $azDevopsPat
    }

    $previousErrorAction = $ErrorActionPreference
    $previousNative = $PSNativeCommandUseErrorActionPreference
    $ErrorActionPreference = "Continue"
    $PSNativeCommandUseErrorActionPreference = $false
    try {
        $aadToken = az account get-access-token `
            --resource 499b84ac-1321-427f-aa17-267ca6975798 `
            --query accessToken `
            -o tsv 2>$null
        if ($LASTEXITCODE -eq 0 -and $aadToken) {
            return "Bearer $($aadToken.Trim())"
        }
    }
    finally {
        $ErrorActionPreference = $previousErrorAction
        $PSNativeCommandUseErrorActionPreference = $previousNative
    }

    $gitCredential = Get-GitAdoCredential
    if ($gitCredential) {
        $pair = "$($gitCredential.User):$($gitCredential.Password)"
        $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
        return "Basic $basic"
    }

    throw "Failed to get Azure DevOps credentials. Use Azure DevOps CLI login, or sign in with az login."
}

function Invoke-AdoJson {
    param(
        [Parameter(Mandatory = $true)][string]$Method,
        [Parameter(Mandatory = $true)][string]$Uri,
        [Parameter(Mandatory = $true)][string]$Authorization,
        [string]$ContentType = "application/json",
        [string]$Body
    )

    $headers = @{
        Authorization = $Authorization
        Accept        = "application/json"
    }

    $params = @{
        Method      = $Method
        Uri         = $Uri
        Headers     = $headers
        ContentType = $ContentType
    }

    if ($PSBoundParameters.ContainsKey("Body")) {
        $params.Body = [System.Text.Encoding]::UTF8.GetBytes($Body)
    }

    return Invoke-RestMethod @params
}

function Send-Attachment {
    param(
        [Parameter(Mandatory = $true)][string]$Uri,
        [Parameter(Mandatory = $true)][string]$Authorization,
        [Parameter(Mandatory = $true)][string]$FilePath
    )

    $outFile = [IO.Path]::GetTempFileName()
    $previousNative = $PSNativeCommandUseErrorActionPreference
    $PSNativeCommandUseErrorActionPreference = $false
    try {
        $httpCode = & curl.exe -sS -X POST `
            -H "Authorization: $Authorization" `
            -H "Content-Type: application/octet-stream" `
            -H "Accept: application/json" `
            --data-binary "@$FilePath" `
            -o $outFile `
            -w "%{http_code}" `
            $Uri

        $responseBody = Get-Content -LiteralPath $outFile -Raw -ErrorAction SilentlyContinue
        if ($httpCode -notmatch "^2") {
            $sizeMb = [math]::Round((Get-Item -LiteralPath $FilePath).Length / 1MB, 1)
            throw "Attachment upload failed for '$FilePath' ($sizeMb MB, HTTP $httpCode): $responseBody"
        }

        return $responseBody | ConvertFrom-Json
    }
    finally {
        $PSNativeCommandUseErrorActionPreference = $previousNative
        Remove-Item -LiteralPath $outFile -Force -ErrorAction SilentlyContinue
    }
}

function Get-AttachmentsHtml {
    param([Parameter(Mandatory = $true)]$Uploaded)

    $images = @($Uploaded | Where-Object { $_.Kind -eq "image" })
    $videos = @($Uploaded | Where-Object { $_.Kind -eq "video" })
    $parts = @()

    if ($images.Count -gt 0) {
        $label = if ($images.Count -eq 1) { "מצורפת תמונה:" } else { "מצורפות תמונות:" }
        $tags = ($images | ForEach-Object { "<img src=`"$($_.Url)`" />" }) -join "<br />"
        $parts += "<br /><b>$label</b><br />$tags"
    }

    if ($videos.Count -gt 0) {
        $label = if ($videos.Count -eq 1) { "מצורף סרטון:" } else { "מצורפים סרטונים:" }
        $links = ($videos | ForEach-Object {
                $name = [Net.WebUtility]::HtmlEncode($_.FileName)
                "<a href=`"$($_.Url)`">$name</a>"
            }) -join "<br />"
        $parts += "<br /><b>$label</b><br />$links"
    }

    return ($parts -join "<br />")
}

function Add-AttachmentsToHtml {
    param(
        [string]$Html,
        [Parameter(Mandatory = $true)][string]$Block
    )

    $Block = "<br />$Block"

    if ([string]::IsNullOrWhiteSpace($Html)) {
        return "<div dir=`"rtl`">$Block</div>"
    }

    if ($Html -match "</div>\s*$") {
        return [regex]::Replace($Html, "</div>\s*$", { param($m) "$Block</div>" })
    }

    return "$Html$Block"
}

function Write-UploadedUrls {
    param([Parameter(Mandatory = $true)]$Uploaded)

    foreach ($item in $Uploaded) {
        Write-Output "ATTACHMENT_URL=$($item.Url)"
    }
    Write-Output "ATTACHMENT_HTML=$(Get-AttachmentsHtml -Uploaded $Uploaded)"
}

try {
    # powershell -File passes "a","b" as one string "a,b". Split it back.
    $ImagePaths = @(
        $ImagePaths |
            ForEach-Object { $_ -split "," } |
            ForEach-Object { $_.Trim().Trim('"', "'") } |
            Where-Object { $_ }
    )

    if (-not $ImagePaths -or $ImagePaths.Count -eq 0) {
        throw "No file paths were provided."
    }

    foreach ($path in $ImagePaths) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "File not found: $path"
        }
        if (-not (Get-AttachmentKind -Path $path)) {
            throw "Unsupported file type: $path. Supported: $($ImageExtensions + $VideoExtensions -join ', ')"
        }
    }

    $authorization = Get-AdoAuthorization
    $projectEncoded = [uri]::EscapeDataString($Project)
    $orgBaseUrl = "https://dev.azure.com/$Organization/_apis/wit"
    $projectBaseUrl = "https://dev.azure.com/$Organization/$projectEncoded/_apis/wit"
    $uploaded = @()

    foreach ($path in $ImagePaths) {
        $fileName = [IO.Path]::GetFileName($path)
        $uploadUri = "$orgBaseUrl/attachments?fileName=$([uri]::EscapeDataString($fileName))&api-version=$ApiVersion"
        $result = Send-Attachment -Uri $uploadUri -Authorization $authorization -FilePath $path

        if (-not $result.url) {
            throw "Attachment upload returned no URL for '$fileName'."
        }

        $uploaded += [pscustomobject]@{
            FileName = $fileName
            Url      = [string]$result.url
            Kind     = Get-AttachmentKind -Path $path
        }
    }

    $workItemUri = "$projectBaseUrl/workitems/${WorkItemId}?api-version=$ApiVersion"
    try {
        $workItem = Invoke-AdoJson -Method GET -Uri $workItemUri -Authorization $authorization
        $workItemType = [string]$workItem.fields."System.WorkItemType"
        $htmlField = if ($workItemType -eq "Bug") {
            "Microsoft.VSTS.TCM.ReproSteps"
        }
        else {
            "System.Description"
        }
        $currentHtml = [string]$workItem.fields.$htmlField
        $newHtml = Add-AttachmentsToHtml -Html $currentHtml -Block (Get-AttachmentsHtml -Uploaded $uploaded)

        $patch = @()
        foreach ($item in $uploaded) {
            $patch += @{
                op    = "add"
                path  = "/relations/-"
                value = @{
                    rel        = "AttachedFile"
                    url        = $item.Url
                    attributes = @{ comment = $item.FileName }
                }
            }
        }

        $htmlOp = if ($workItem.fields.PSObject.Properties.Name -contains $htmlField) {
            "replace"
        }
        else {
            "add"
        }

        $patch += @{
            op    = $htmlOp
            path  = "/fields/$htmlField"
            value = $newHtml
        }

        $patchJson = $patch | ConvertTo-Json -Depth 8
        Invoke-AdoJson `
            -Method PATCH `
            -Uri $workItemUri `
            -Authorization $authorization `
            -ContentType "application/json-patch+json" `
            -Body $patchJson | Out-Null

        $imageCount = @($uploaded | Where-Object { $_.Kind -eq "image" }).Count
        $videoCount = @($uploaded | Where-Object { $_.Kind -eq "video" }).Count
        Write-Output "Attached $imageCount image(s) and $videoCount video(s) to work item $WorkItemId."
        exit 0
    }
    catch {
        Write-Output "UPLOADED_NEEDS_MCP_PATCH"
        Write-UploadedUrls -Uploaded $uploaded
        [Console]::Error.WriteLine("Files uploaded, but the work item could not be updated with this login. Use MCP to append ATTACHMENT_HTML to the HTML body field.")
        exit 2
    }
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
