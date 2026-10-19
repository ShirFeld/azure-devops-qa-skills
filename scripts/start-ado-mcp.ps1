# Starts the Azure DevOps MCP server with PAT authentication.
# Reads the organization from ADO_ORG and the PAT from AZURE_DEVOPS_EXT_PAT
# (process env, then Windows user env).
# The token is never written to disk or printed.

$ErrorActionPreference = "Stop"

$org = $env:ADO_ORG
if (-not $org) {
    $org = [Environment]::GetEnvironmentVariable("ADO_ORG", "User")
}
if (-not $org) {
    [Console]::Error.WriteLine("ADO_ORG is not set. Set it to your Azure DevOps organization name (the slug in https://dev.azure.com/<org>) as a Windows user environment variable and restart Claude / Cursor.")
    exit 1
}

$pat = $env:AZURE_DEVOPS_EXT_PAT
if (-not $pat) {
    $pat = [Environment]::GetEnvironmentVariable("AZURE_DEVOPS_EXT_PAT", "User")
}
if (-not $pat) {
    [Console]::Error.WriteLine("AZURE_DEVOPS_EXT_PAT is not set. Set it as a Windows user environment variable and restart Claude / Cursor.")
    exit 1
}

# @azure-devops/mcp --authentication pat expects base64("<any user>:<pat>").
$env:PERSONAL_ACCESS_TOKEN = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("pat:$pat"))

& npx -y @azure-devops/mcp $org --authentication pat
exit $LASTEXITCODE
