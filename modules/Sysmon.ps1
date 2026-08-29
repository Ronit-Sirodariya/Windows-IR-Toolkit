function Collect-SysmonProcessCreation {

    try {

        Write-Log "Collecting Sysmon process creation events..."

        Get-WinEvent -FilterHashtable @{
            LogName = "Microsoft-Windows-Sysmon/Operational"
            Id      = 1
        } -ErrorAction Stop |
            Select-Object `
                TimeCreated,
                Id,
                ProviderName,
                Message |
            Export-Csv `
                (Join-Path $root "Sysmon\process_creation.csv") `
                -NoTypeInformation

        Write-Log "Sysmon process creation events collected."
    }

    catch {

        Write-Log `
            "Sysmon process collection failed: $($_.Exception.Message)" `
            "ERROR"
    }
}