if ($env:MSI_SECRET) {
    Disable-AzContextAutosave -Scope Process | Out-Null
    Connect-AzAccount -Identity
    Import-Module Az.Accounts
    Import-Module Az.Resources
}