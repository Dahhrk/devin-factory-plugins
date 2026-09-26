function Write-Status {
    param([string] $Message)
    Write-Output $Message
}
Export-ModuleMember -Function Write-Status
