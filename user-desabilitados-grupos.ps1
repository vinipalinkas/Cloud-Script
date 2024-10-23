Connect-AzAccount -Identity

$groups = Get-AzADGroup
$disabledUsers = Get-AzADUser -Filter "accountEnabled eq false"

$excludedGroups = @("Domain Users", "Licenca_Office_365_Desabilitados", "Todos os Usuários (Desativados e Ativos)")
$excludedGroupIds = $groups | Where-Object { $excludedGroups -contains $_.DisplayName } | Select-Object -ExpandProperty Id

foreach ($user in $disabledUsers) {
    foreach ($group in $groups) {
        $isMember = Get-AzADGroupMember -GroupObjectId $group.Id | Where-Object { $_.Id -eq $user.Id }
        
        if ($isMember -and ($excludedGroupIds -notcontains $group.Id)) {
            Remove-AzADGroupMember -GroupObjectId $group.Id -MemberObjectId $user.Id
        }
    }
}
