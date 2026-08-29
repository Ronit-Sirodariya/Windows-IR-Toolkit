function Collect-FilesystemMetadata {

    try {

        Write-Log "Collecting filesystem metadata..."

        $paths = @(
            "$env:TEMP",
            "$env:WINDIR\Temp"
        )

        $results = foreach ($path in $paths) {

            if (Test-Path $path) {

                Get-ChildItem `
                    -Path $path `
                    -File `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Select-Object `
                        Name,
                        FullName,
                        Length,
                        Extension,
                        CreationTime,
                        LastWriteTime,
                        LastAccessTime
            }
        }

        $results |
            Export-Csv `
                (Join-Path $root "Filesystem\filesystem_metadata.csv") `
                -NoTypeInformation

        Write-Log "Filesystem metadata collected."
    }

    catch {

        Write-Log `
            "Filesystem collection failed: $($_.Exception.Message)" `
            "ERROR"
    }
}