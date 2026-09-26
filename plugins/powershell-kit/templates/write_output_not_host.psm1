# Prefer Write-Output / information stream over Write-Host in modules.
function Write-BuildStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Message
    )
    Write-Output $Message
    Write-Information -MessageData $Message -Tags 'build'
}

Export-ModuleMember -Function Write-BuildStatus
