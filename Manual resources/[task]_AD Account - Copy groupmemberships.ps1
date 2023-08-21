$groupsToAdd = $form.memberships.leftToRight
$userPrincipalName = $form.gridUsersTarget.UserPrincipalName

Write-information "Groups to add: $groupsToAdd"

try {
    $adUser = Get-ADuser -Filter { UserPrincipalName -eq $userPrincipalName }
    Write-information "Found AD user [$userPrincipalName]"

    
    $adUserSID = $([string]$adUser.SID)
        $Log = @{
            Action            = "GrantMembership" # optional. ENUM (undefined = default) 
            System            = "ActiveDirectory" # optional (free format text) 
            Message           = "Found user with username $userPrincipalName" # required (free format text) 
            IsError           = $false # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
            TargetDisplayName = $userPrincipalName # optional (free format text) 
            TargetIdentifier  = $adUserSID # optional (free format text) 
        }
        #send result back  
        Write-Information -Tags "Audit" -MessageData $log

} catch {
    Write-error "Could not find AD user [$userPrincipalName]. Error: $($_.Exception.Message)"

            $Log = @{
            Action            = "GrantMembership" # optional. ENUM (undefined = default) 
            System            = "ActiveDirectory" # optional (free format text) 
            Message           = "Could find user with username $userPrincipalName" # required (free format text) 
            IsError           = $true # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
            TargetDisplayName = $userPrincipalName # optional (free format text) 
            TargetIdentifier  = "" # optional (free format text) 
        }
        #send result back  
        Write-Information -Tags "Audit" -MessageData $log
}

if($groupsToAdd -ne "[]"){
    try {
        $groupsToAddJson =  $groupsToAdd
        
        Add-ADPrincipalGroupMembership -Identity $adUser -MemberOf $groupsToAddJson.sid -Confirm:$false
        Write-information "Finished adding AD user [$userPrincipalName] to AD groups $groupsToAdd"
                $Log = @{
            Action            = "GrantMembership" # optional. ENUM (undefined = default) 
            System            = "ActiveDirectory" # optional (free format text) 
            Message           = "Added groups $groupstoAdd to user with username $userPrincipalName" # required (free format text) 
            IsError           = $false # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
            TargetDisplayName = $userPrincipalName # optional (free format text) 
            TargetIdentifier  = $adUserSID # optional (free format text) 
        }
        #send result back  
        Write-Information -Tags "Audit" -MessageData $log
    } catch {
        Write-error "Could not add AD user [$userPrincipalName] to AD groups $groupsToAdd. Error: $($_.Exception.Message)"

        $Log = @{
            Action            = "GrantMembership" # optional. ENUM (undefined = default) 
            System            = "ActiveDirectory" # optional (free format text) 
            Message           = "Could not add groups $groupstoadd to user with username $userPrincipalName" # required (free format text) 
            IsError           = $true # optional. Elastic reporting purposes only. (default = $false. $true = Executed action returned an error) 
            TargetDisplayName = $userPrincipalName # optional (free format text) 
            TargetIdentifier  = $adUserSID # optional (free format text) 
        }
        #send result back  
        Write-Information -Tags "Audit" -MessageData $log
    }
}
