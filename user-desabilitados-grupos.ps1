Connect-AzAccount -Identity

$groups = Get-AzADGroup
$users = Get-AzADUser -Filter "accountEnabled eq false"

$excludedGroups = @("Domain Users", "Licenca_Office_365_Desabilitados", "Todos os Usuários (Desativados e Ativos)")
$excludedGroupIds = $groups | Where-Object { $excludedGroups -contains $_.DisplayName } | Select-Object -ExpandProperty Id

$groupMembers = @{}

foreach ($group in $groups) {
    if ($excludedGroupIds -notcontains $group.Id) {
        $members = Get-AzADGroupMember -GroupObjectId $group.Id
        
        $groupMembers[$group.Id] = $members
    }
}

foreach ($user in $users) {
    foreach ($groupId in $groupMembers.Keys) {
        $isMember = $groupMembers[$groupId] | Where-Object { $_.Id -eq $user.Id }
        
        if ($isMember) {
            Remove-AzADGroupMember -GroupObjectId $groupId -MemberObjectId $user.Id
        }
    }
}
