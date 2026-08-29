function Collect-EventLogs{
    try{
        Write-Log "Collecting EVent Logs"

        Get-WinEvent -FilterHashtable @{
            LogName = "Security"
            Id = 4624,4625
        } -ErrorAction Stop | 
        Select-Object `
            TimeCreated,
            Id,
            ProviderName,
            LevelDisplayName,
            Message | 
            Export-Csv `
            (Join-Path $root "EventLogs\authentication.csv") `
            -NoTypeInformation
        Write-Log "Event Logs collected"
    }
    catch {
        Write-Log `
        "Authentication Logs collection faile $($_.Exception.Message)" `
        "Error"
    }
}