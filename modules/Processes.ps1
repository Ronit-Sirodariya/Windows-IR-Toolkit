function Collect-Processes {

    try{
        Write-Log "Collecting runnign processes"

        Get-CimInstance Win32_Process -ErrorAction Stop |
        Select-Object `
        Name,
        ProcessId,
        ParentProcessId,
        ExecutablePath,
        CommandLine | 
        Export-Csv `
        (Join-Path $root "Processes\processes.csv") `
        -NoTypeInformation

    Write-Log "Process Information Collected"
    }
    catch{
        Write-Log `
        "Processncollection failed $($_.Exception.Message)" `
        "Error"
    }
}

