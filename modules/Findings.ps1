function Analyze-Processes {

    try {

        Write-Log "Analyzing process evidence..."

        $processFile = Join-Path `
            $root `
            "Processes\processes.csv"

        if (-not (Test-Path $processFile)) {

            Write-Log "Process evidence not found." "ERROR"

            return
        }

        $processes = Import-Csv $processFile

        $findings = foreach ($process in $processes) {

            if ($process.ExecutablePath -match "\\Temp\\") {

                [PSCustomObject]@{
                    Timestamp  = Get-Date
                    Category   = "Process"
                    Severity   = "Review"
                    Indicator  = "Executable in Temp directory"
                    Process    = $process.Name
                    ProcessId  = $process.ProcessId
                    Path       = $process.ExecutablePath
                    CommandLine = $process.CommandLine
                    Reason     = "Process executable path contains a Temp directory."
                }
            }
        }

        $findings |
            Export-Csv `
                (Join-Path $root "Findings\process_findings.csv") `
                -NoTypeInformation

        Write-Log "Process analysis completed."
    }

    catch {

        Write-Log `
            "Process analysis failed: $($_.Exception.Message)" `
            "ERROR"
    }
}