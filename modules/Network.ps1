function Collect-NetworkInfo{

    try{
        Write-Log "Collecting Network Information"

        Get-NetTCPConnection -ErrorAction Stop | 
        Select-Object `
            LocalAddress,
            LocalPort,
            RemoteAddress,
            RemotePort,
            State,
            OwningProcess | 
            Export-Csv `
            (Join-Path $root "Network\network_collection.csv") `
            -NoTypeInformation

        Write-Log  "Network Infromation Collected"

    }
    catch{
        Write-Log `
        "Network Collection failed: $($_.Exception.Message)" `
        "Error"
    }

}