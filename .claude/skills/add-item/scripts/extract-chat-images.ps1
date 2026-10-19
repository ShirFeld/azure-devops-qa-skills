# Extracts images the user pasted into the latest Claude Code chat message
# and saves them as files, so attach-images.ps1 can upload them.
# Reads the current session transcript (.jsonl) under ~/.claude/projects.
# Prints one IMAGE_PATH=<path> line per image, in the user's order.
# Prints NO_IMAGES when the latest user message has no images.

[CmdletBinding()]
param(
    [string]$TranscriptPath,

    [string]$ProjectDir = (Get-Location).Path,

    [string]$OutDir = (Join-Path ([IO.Path]::GetTempPath()) "add-item-images")
)

$ErrorActionPreference = "Stop"

function Get-TranscriptPath {
    param([Parameter(Mandatory = $true)][string]$Dir)

    $projectKey = $Dir -replace "[^A-Za-z0-9]", "-"
    $transcriptDir = Join-Path $HOME ".claude\projects\$projectKey"
    if (-not (Test-Path -LiteralPath $transcriptDir -PathType Container)) {
        throw "Transcript folder not found: $transcriptDir"
    }

    $latest = Get-ChildItem -LiteralPath $transcriptDir -Filter "*.jsonl" -File |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if (-not $latest) {
        throw "No transcript found in: $transcriptDir"
    }

    return $latest.FullName
}

function Test-IsUserPrompt {
    param($Entry)

    if ($Entry.type -ne "user" -or -not $Entry.message) { return $false }
    if ($Entry.isMeta) { return $false }

    $content = $Entry.message.content
    if ($content -is [string]) { return $true }

    foreach ($block in @($content)) {
        if ($block.type -eq "tool_result") { return $false }
    }
    return $true
}

try {
    if (-not $TranscriptPath) {
        $TranscriptPath = Get-TranscriptPath -Dir $ProjectDir
    }

    # Find the latest real user prompt (not a tool result).
    $lines = [IO.File]::ReadAllLines($TranscriptPath, [Text.Encoding]::UTF8)
    $prompt = $null
    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        $line = $lines[$i]
        if (-not $line.Contains('"type":"user"')) { continue }
        try { $entry = $line | ConvertFrom-Json } catch { continue }
        if (Test-IsUserPrompt -Entry $entry) {
            $prompt = $entry
            break
        }
    }

    $images = @()
    if ($prompt -and -not ($prompt.message.content -is [string])) {
        $images = @($prompt.message.content | Where-Object {
                $_.type -eq "image" -and $_.source.type -eq "base64" -and $_.source.data
            })
    }

    if ($images.Count -eq 0) {
        Write-Output "NO_IMAGES"
        exit 0
    }

    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $index = 0
    foreach ($image in $images) {
        $index++
        $extension = switch ($image.source.media_type) {
            "image/jpeg" { "jpg" }
            "image/gif" { "gif" }
            "image/webp" { "webp" }
            default { "png" }
        }
        $path = Join-Path $OutDir "screenshot-$stamp-$index.$extension"
        [IO.File]::WriteAllBytes($path, [Convert]::FromBase64String($image.source.data))
        Write-Output "IMAGE_PATH=$path"
    }
    exit 0
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
