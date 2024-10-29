# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

$groups = Get-AzADGroup
$disabledUsers = Get-AzADUser -Filter "accountEnabled eq false" | Select-Object Id

$excludedGroups = @("Domain Users", "Licenca_Office_365_Desabilitados", "Todos os Usuários (Desativados e Ativos)")
$excludedGroupIds = $groups | Where-Object { $excludedGroups -contains $_.DisplayName } | Select-Object -ExpandProperty Id

$groupMembers = @{}
foreach ($group in $groups) {
    if ($excludedGroupIds -contains $group.Id) { continue }

    $groupMembers[$group.Id] = Get-AzADGroupMember -GroupObjectId $group.Id | Select-Object Id
}

$currentBatch = $disabledUsers | Select-Object -Firts 4000 # -Skip 4001

$groupMembership = @{}

foreach ($user in $currentBatch) {
    foreach ($group in $groups) {
        if ($excludedGroupIds -contains $group.Id) { continue }

        $isMember = $groupMembers[$group.Id] | Where-Object { $_.Id -eq $user.Id }
        if ($isMember) {
            if (-not $groupMembership[$user.Id]) {
                $groupMembership[$user.Id] = @()
            }
            $groupMembership[$user.Id] += $group.Id
        }
    }
}

foreach ($user in $groupMembership.Keys) {
    foreach ($groupId in $groupMembership[$user]) {
        Remove-AzADGroupMember -GroupObjectId $groupId -MemberObjectId $user
    }
}