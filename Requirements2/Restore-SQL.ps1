# Bailey Alger 012480373

try {
    Import-Module -Name SqlServer

    # The lab Virtual Machine host name is SRV19-Primary, we create a server object routed to \SQLEXPRESS
    $sqlServerInstanceName = "SRV19-PRIMARY\SQLEXPRESS"
    $sqlServerObject = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerInstanceName

    # ClientDB in the rubric
    $databaseName = 'ClientDB'

    # Checks if the database exists and deletes it if it does
    if ($sqlServerObject.Databases[$databaseName]) {
        Write-Host "Database $($databaseName) already exists. Removing..."
        Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Database $databaseName -Username "LabAdmin" -Password 'Passw0rd!' -Query "DROP DATABASE [$databaseName]"
        Write-Host "Database removed."
    }

    # Creates the database
    $databaseObject = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -ArgumentList $sqlServerObject, $databaseName
    $databaseObject.Create()

    # invokes the sql file in the currect directory 'CreateTable_Client_A_Contacts.sql'
    Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Database $databaseName -InputFile $PSScriptRoot\CreateTable_Client_A_Contacts.sql

    # sql script to be used in the loop
    $Insert = "INSERT INTO Client_A_Contacts (first_name, last_name, city, county, zip, officePhone, mobilePhone)"
    # imports the contacts from the csv
    $NewClientContacts = Import-Csv $PSScriptRoot\NewClientData.csv
    # Creates a contact profile in the database for each contact
    foreach ($NewContact in $NewClientContacts) {
        $Values = "VALUES (`
                        '$($NewContact.first_name)',`
                        '$($NewContact.last_name)',`
                        '$($NewContact.city)',`
                        '$($NewContact.county)',`
                        '$($NewContact.zip)',`
                        '$($NewContact.officePhone)',`
                        '$($NewContact.mobilePhone)')"
                                                                                                         
        $query = $Insert + $Values
        Invoke-Sqlcmd -Database $databaseName -ServerInstance $sqlServerInstanceName -Query $query
    }
    Write-Host "Table Created"
}
catch {
    # Writes the stack trace to the console when an error occurs
    Write-Host -ForegroundColor Red "$($PSItem.ToString())`n$($PSItem.ScriptStackTrace)"
}
