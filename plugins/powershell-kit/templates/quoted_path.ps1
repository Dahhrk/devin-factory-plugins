# Quote path cmdlet arguments so spaces and empty values stay safe.
param(
    [Parameter(Mandatory)]
    [string] $PublishPath
)

if (Test-Path -LiteralPath "$PublishPath") {
    Get-Content -LiteralPath "$PublishPath"
    Remove-Item -LiteralPath "$PublishPath" -Recurse -Force
}

Set-Location -LiteralPath "$PublishPath"
