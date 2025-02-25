# Bailey Alger 012480373

try {
    $userInput = 0
    $CounterList = "\Processor(_Total)\% Processor Time", "\Memory\Committed Bytes"

    While ($userInput -ne 5) {
        # Displays the options for the user to choose from
        Write-Host "
        1. Save Logs
        2. List Files in the Current Folder
        3. Processor and Memory Usage
        4. List Running Processes
        5. Exit
        "
         
        # Reads user input and picks a route depending on the number submitted
        $userInput = Read-Host
        switch ($userInput) {
            1 {
                # Appends the current date/time and records the names of any log files in the current director
                Get-Date | Out-File -FilePath "$PSScriptRoot\DailyLog.txt" -Append
                Get-ChildItem -Path "$PSScriptRoot" -Filter *.log | Out-File -FilePath "$PSScriptRoot\DailyLog.txt" -Append
            }
            2 {
                # Records the files in the current directory, sorts by name and tabulates it.
                Get-ChildItem "$PSScriptRoot" | Sort-Object Name | Format-Table -AutoSize -Wrap | Out-File "$PSScriptRoot\C916Contents.txt"
            }
            3 {
                # Displays the current CPU and Memory usage
                Get-Counter -Counter $CounterList -MaxSamples 4 -SampleInterval 5
            }
            4 {
                # Opens a table displaying the current running processes
                Get-Process | Select-Object ID, Name, VM | Sort-Object VM | Out-GridView
            }
            5 { Write-Host "exit" }

        }
    }
}
Catch [System.OutOfMemoryException] {
    # Catches a system out of memory error and displays the trace for the error
    Write-Host -ForegroundColor Red "Sorry! Memory Levels are at zero!"
    Write-Host -ForegroundColor Red "$($PSItem.ToString())`n$($PSItem.ScriptStackTrace)"
}
Catch {
    # Catches all unlisted errors and displays the stack trace
    Write-Host -ForegroundColor Red "error:"
    Write-Host -ForegroundColor Red "$($PSItem.ToString())`n$($PSItem.ScriptStackTrace)"
}

