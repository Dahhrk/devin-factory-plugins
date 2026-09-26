# Intentional Write-Host-in-module smell for ps-rg-gate (not product code).
function Show-Banner {
    Write-Host -ForegroundColor Green 'hello from module'
}
Export-ModuleMember -Function Show-Banner
