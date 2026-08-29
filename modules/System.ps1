function Collect-SystemInfo {

    try{
        Write-Log "Collecting System Information"

        $osInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop

        $osInfo | 
            Select-Object `
                Caption,
                Version,
                BuildNumber,
                OSArchitecture,
                LastBootUpTime | 
                Export-Csv `
                (Join-Path $root "System\Operating_System.csv")`
                -NoTypeInformation

         Write-Log "Operating system information collected."
 
    }
     catch {

        Write-Log `
            "System information collection failed: $($_.Exception.Message)" `
            "ERROR"
    }
}