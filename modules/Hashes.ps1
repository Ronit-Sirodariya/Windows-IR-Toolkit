function Get-FileHashEvidence {

    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    try {

        if (-not (Test-Path $FilePath -PathType Leaf)) {

            Write-Log "File not found for hashing: $FilePath" "ERROR"
            return
        }

        Write-Log "Calculating SHA-256 hash: $FilePath"

        $hash = Get-FileHash `
            -Path $FilePath `
            -Algorithm SHA256 `
            -ErrorAction Stop

        [PSCustomObject]@{
            FilePath = $hash.Path
            Algorithm = $hash.Algorithm
            SHA256 = $hash.Hash
        }
    }

    catch {

        Write-Log `
            "Hash calculation failed for $FilePath : $($_.Exception.Message)" `
            "ERROR"
    }
}

function Collect-FileHashes {

    try {

        Write-Log "Collecting file hashes..."

        $paths = @(
            "$env:TEMP",
            "$env:WINDIR\Temp"
        )

        $results = foreach ($path in $paths) {

            if (Test-Path $path) {

                $files = Get-ChildItem `
                    -Path $path `
                    -File `
                    -Force `
                    -ErrorAction SilentlyContinue

                foreach ($file in $files) {

                    Get-FileHashEvidence `
                        -FilePath $file.FullName
                }
            }
        }

        $results |
            Export-Csv `
                (Join-Path $root "Hashes\file_hashes.csv") `
                -NoTypeInformation

        Write-Log "File hashing completed."
    }

    catch {

        Write-Log `
            "File hash collection failed: $($_.Exception.Message)" `
            "ERROR"
    }
}