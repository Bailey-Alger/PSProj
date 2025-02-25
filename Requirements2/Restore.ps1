# Bailey Alger 012480373

try {
    $ADRoot = (Get-ADDomain).DistinguishedName
    $OUCanonicalName = "Finance"
    $OUDisplayName = "Finance"
    $ADPath = "OU=$($OUCanonicalName),$($ADRoot)"
    # Checks if the Active Directory exists, creates one if it doesn't
    if (-Not([ADSI]::Exists("LDAP://$($ADPath)"))) {
        New-ADOrganizationalUnit -Path $ADRoot -Name $OUCanonicalName -DisplayName $OUDisplayName -ProtectedFromAccidentalDeletion $false
        Write-Host -ForegroundColor Cyan "[AD]: $($OUCanonicalName) OU Created"
    }
    else {
        Write-Host "$($OUCanonicalName) Already Exists."
    }
    # gets the list of contacts from a csv file
    $NewADUsers = Import-Csv -Path $PSScriptRoot\financePersonnel.csv
    $Path = "OU=Finance,DC=consultingfirm,DC=com"

    $numberNewUsers = $NewADUsers.Count
    $count = 1

    # Creates a profile for each contact
    foreach ($ADUser in $NewADUsers) {
        $First = $ADUser.First_Name
        $Last = $ADUser.Last_Name
        $name = $First + " " + $Last
        $SamAcct = $ADUser.samAccount
        $Postal = $ADUser.PostalCode
        $Office = $ADUser.OfficePhone
        $Mobile = $ADUser.MobilePhone

        # Display status of the task
        $status = "[AD] Adding AD User: $($Name) ($($count) of $($numberNewUsers))"
        Write-Progress -Activity 'c916 Task 2 - Restore' -Status $status -PercentComplete (($count / $numberNewUsers) * 100)

        # Check if user exists
        $userExists = Get-ADUser -Filter {SamAccountName -eq $SamAcct} -ErrorAction SilentlyContinue

        if (-not $userExists) {
        New-ADUser `
            -GivenName $First `
            -Surname $Last `
            -Name $Name `
            -SamAccountName $SamAcct `
            -DisplayName $Name `
            -PostalCode $Postal `
            -MobilePhone $Mobile `
            -OfficePhone $Office `
            -Path $Path
        }                                                                        
        $count++
    }
    Write-Host -ForegroundColor Green "[AD]: Active Directory Tasks Complete"
}
catch {
    # Writes the stack trace to the console when an error occurs
    Write-Host -ForegroundColor Red "$($PSItem.ToString())`n$($PSItem.ScriptStackTrace)"
}