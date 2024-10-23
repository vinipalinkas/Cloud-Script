foreach ($username in (Get-ADUser -SearchBase "OU=Users_Disabled,DC=seb,DC=com,DC=br" -filter *)) {

    $groups = get-adprincipalgroupmembership $username;

        foreach ($group in $groups) {
            if ($group.name -ne "Domain Users" -and $group.name -ne "Licenca_Office_365_Desabilitados") {
                remove-adgroupmember -Identity $group.name -Member $username.SamAccountName -Confirm:$false;
                write-host "removido" $username "de" $group.name;
                
                    $grouplogfile = "c:\Temp" + $username.SamAccountName + ".txt";
                    $group.name >> $grouplogfile
        }
    }
}