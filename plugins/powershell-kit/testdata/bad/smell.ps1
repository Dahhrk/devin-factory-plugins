# Intentional smells for ps-rg-gate discrimination (not product code).
$Deps = "curl"
Invoke-Expression "apt-get install -y $Deps"
$PublishPath = Join-Path $PSScriptRoot "out"
if (Test-Path $PublishPath) {
    Get-Content $PublishPath
    Set-Location $PublishPath
}
