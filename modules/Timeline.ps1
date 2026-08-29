function Build-Timeline {

    try {

        Write-Log "Building investigation timeline..."

        $timeline = @()

        # ----------------------------------------------------
        # Authentication events
        # ----------------------------------------------------

        $authenticationFile = Join-Path `
            $root `
            "EventLogs\authentication_events.csv"

        if (Test-Path $authenticationFile) {

            $events = Import-Csv $authenticationFile

            foreach ($event in $events) {

                $timeline += [PSCustomObject]@{
                    Timestamp = [datetime]$event.TimeCreated
                    Source    = "Windows Security"
                    EventType = "Authentication"
                    Details   = "Event ID $($event.Id)"
                }
            }
        }

        # ----------------------------------------------------
        # Sysmon process creation
        # ----------------------------------------------------

        $sysmonFile = Join-Path `
            $root `
            "Sysmon\process_creation.csv"

        if (Test-Path $sysmonFile) {

            $events = Import-Csv $sysmonFile

            foreach ($event in $events) {

                $timeline += [PSCustomObject]@{
                    Timestamp = [datetime]$event.TimeCreated
                    Source    = "Sysmon"
                    EventType = "Process Creation"
                    Details   = "Event ID $($event.Id)"
                }
            }
        }

        # ----------------------------------------------------
        # Filesystem metadata
        # ----------------------------------------------------

        $filesystemFile = Join-Path `
            $root `
            "Filesystem\filesystem_metadata.csv"

        if (Test-Path $filesystemFile) {

            $files = Import-Csv $filesystemFile

            foreach ($file in $files) {

                $timeline += [PSCustomObject]@{
                    Timestamp = [datetime]$file.CreationTime
                    Source    = "Filesystem"
                    EventType = "File Creation"
                    Details   = $file.FullName
                }

                $timeline += [PSCustomObject]@{
                    Timestamp = [datetime]$file.LastWriteTime
                    Source    = "Filesystem"
                    EventType = "File Modification"
                    Details   = $file.FullName
                }
            }
        }

        # ----------------------------------------------------
        # Sort timeline
        # ----------------------------------------------------

        $timeline |
            Sort-Object Timestamp |
            Export-Csv `
                (Join-Path $root "Timeline\timeline.csv") `
                -NoTypeInformation

        Write-Log "Investigation timeline created."
    }

    catch {

        Write-Log `
            "Timeline construction failed: $($_.Exception.Message)" `
            "ERROR"
    }
}