# Prefer call operator / splatting over Invoke-Expression.
param(
    [Parameter(Mandatory)]
    [string] $ScriptPath,
    [hashtable] $Arguments = @{}
)

if (-not (Test-Path -LiteralPath $ScriptPath)) {
    throw "Missing script: $ScriptPath"
}

& $ScriptPath @Arguments
