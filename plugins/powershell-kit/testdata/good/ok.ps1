param(
    [string] $PublishPath = (Join-Path $PSScriptRoot "out")
)

if (Test-Path -LiteralPath "$PublishPath") {
    Get-Content -LiteralPath "$PublishPath"
}

# Documented intentional seam; keep allow on the smell line.
Invoke-Expression "echo fixture" # ps-rg-allow: fixture documents allow marker for intentional Invoke-Expression seam
