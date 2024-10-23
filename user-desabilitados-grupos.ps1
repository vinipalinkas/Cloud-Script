Connect-AzAccount -UseDeviceAuthentication

$groups = Get-AzADGroup
$users = Get-AzADUser -Filter "accountEnabled eq false"

foreach ($user in $users) {
    $userId = $user.Id
    foreach ($group in $groups) {
        $isMember = Get-AzADGroupMember -GroupObjectId $group.Id | Where-Object { $_.Id -eq $userId }
        
        if ($isMember -and $group.DisplayName -ne "Domain Users" -and $group.DisplayName -ne "Licenca_Office_365_Desabilitados") {
            Remove-AzADGroupMember -GroupObjectId $group.Id -MemberObjectId $userId
        }
    }
}
