function Collect-Services{

    try {

        Write-Log "Collecting Windows services..."

        Get-CimInstance Win32_Service -ErrorAction Stop |
            Select-Object `
                Name,
                DisplayName,
                State,
                StartMode,
                StartName,
                PathName |
            Export-Csv `
                (Join-Path $root "Services\services.csv") `
                -NoTypeInformation

        Write-Log "Windows service information collected."
    }

    catch {

        Write-Log `
            "Service collection failed: $($_.Exception.Message)" `
            "ERROR"
    }
}