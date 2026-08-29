function Collect-Users {

    try{
        Write-Log "Collecting local user information"

        Get-LocalUser  -ErrorAction Stop |
        Select-Object `
            Name,
            Enabled,
            LastLogon,
            PasswordRequired |
            Export-Csv `
             (Join-Path $root "Users\local_users.csv") `
             -NoTypeInformation

        Write-Log "User Information Collected"
    
    }
    catch{
        Write-Log `
         "User Collection failed: $($_.Exception.Message)" `
         "Error"
    }
}