# ============================================================
# Windows IR Toolkit
# Persistence Collection Module
# ============================================================


# ------------------------------------------------------------
# Startup Folder Collection
# ------------------------------------------------------------

function Collect-StartupItems {

    try {

        Write-Log "Collecting Startup folder items..."

        $startupPaths = @(
            [Environment]::GetFolderPath("Startup")
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
        )

        $results = foreach ($path in $startupPaths) {

            if (Test-Path $path) {

                Get-ChildItem `
                    -Path $path `
                    -Force `
                    -ErrorAction SilentlyContinue |
                    Select-Object `
                        Name,
                        FullName,
                        Extension,
                        Length,
                        CreationTime,
                        LastWriteTime,
                        LastAccessTime
            }
        }

        $results |
            Export-Csv `
                (Join-Path $root "Persistence\startup_items.csv") `
                -NoTypeInformation

        Write-CollectionStatus `
            -Module "Startup Items" `
            -Status "SUCCESS" `
            -Message "Startup folder collection completed."

        Write-Log "Startup folder collection completed."
    }

    catch {

        Write-CollectionStatus `
            -Module "Startup Items" `
            -Status "FAILED" `
            -Message $_.Exception.Message

        Write-Log `
            "Startup folder collection failed: $($_.Exception.Message)" `
            "ERROR"
    }
}


# ------------------------------------------------------------
# Startup Shortcut Collection
# ------------------------------------------------------------

function Collect-StartupShortcuts {

    try {

        Write-Log "Collecting Startup shortcut targets..."

        $startupPaths = @(
            [Environment]::GetFolderPath("Startup")
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
        )

        $shell = New-Object -ComObject WScript.Shell

        $results = foreach ($path in $startupPaths) {

            if (Test-Path $path) {

                $shortcuts = Get-ChildItem `
                    -Path $path `
                    -Filter "*.lnk" `
                    -Force `
                    -ErrorAction SilentlyContinue

                foreach ($shortcut in $shortcuts) {

                    try {

                        $link = $shell.CreateShortcut(
                            $shortcut.FullName
                        )

                        [PSCustomObject]@{

                            Name       = $shortcut.Name

                            FullName   = $shortcut.FullName

                            TargetPath = $link.TargetPath

                            Arguments  = $link.Arguments

                            WorkingDirectory = $link.WorkingDirectory

                            CreationTime = $shortcut.CreationTime

                            LastWriteTime = $shortcut.LastWriteTime
                        }
                    }

                    catch {

                        Write-Log `
                            "Failed to inspect shortcut $($shortcut.FullName): $($_.Exception.Message)" `
                            "ERROR"
                    }
                }
            }
        }

        $results |
            Export-Csv `
                (Join-Path $root "Persistence\startup_shortcuts.csv") `
                -NoTypeInformation

        Write-CollectionStatus `
            -Module "Startup Shortcuts" `
            -Status "SUCCESS" `
            -Message "Startup shortcut collection completed."

        Write-Log "Startup shortcut collection completed."
    }

    catch {

        Write-CollectionStatus `
            -Module "Startup Shortcuts" `
            -Status "FAILED" `
            -Message $_.Exception.Message

        Write-Log `
            "Startup shortcut collection failed: $($_.Exception.Message)" `
            "ERROR"
    }
}


# ------------------------------------------------------------
# Registry Run / RunOnce Collection
# ------------------------------------------------------------

function Collect-RegistryPersistence {

    try {

        Write-Log "Collecting Registry Run and RunOnce keys..."

        $registryPaths = @(
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        )

        $results = foreach ($path in $registryPaths) {

            if (Test-Path $path) {

                $properties = Get-ItemProperty `
                    -Path $path `
                    -ErrorAction SilentlyContinue

                if ($properties) {

                    foreach ($property in $properties.PSObject.Properties) {

                        if ($property.Name -notmatch "^PS") {

                            [PSCustomObject]@{

                                RegistryPath = $path

                                Name = $property.Name

                                Command = $property.Value
                            }
                        }
                    }
                }
            }
        }

        $results |
            Export-Csv `
                (Join-Path $root "Persistence\registry_run_keys.csv") `
                -NoTypeInformation

        Write-CollectionStatus `
            -Module "Registry Persistence" `
            -Status "SUCCESS" `
            -Message "Registry Run and RunOnce collection completed."

        Write-Log "Registry persistence collection completed."
    }

    catch {

        Write-CollectionStatus `
            -Module "Registry Persistence" `
            -Status "FAILED" `
            -Message $_.Exception.Message

        Write-Log `
            "Registry persistence collection failed: $($_.Exception.Message)" `
            "ERROR"
    }
}


# ------------------------------------------------------------
# Scheduled Task Collection
# ------------------------------------------------------------

function Collect-ScheduledTaskPersistence {

    try {

        Write-Log "Collecting Scheduled Tasks..."

        Get-ScheduledTask -ErrorAction Stop |
            Select-Object `
                TaskName,
                TaskPath,
                State,
                Author,
                Description,
                URI |
            Export-Csv `
                (Join-Path $root "Persistence\scheduled_tasks.csv") `
                -NoTypeInformation

        Write-CollectionStatus `
            -Module "Scheduled Tasks" `
            -Status "SUCCESS" `
            -Message "Scheduled task collection completed."

        Write-Log "Scheduled task collection completed."
    }

    catch {

        Write-CollectionStatus `
            -Module "Scheduled Tasks" `
            -Status "FAILED" `
            -Message $_.Exception.Message

        Write-Log `
            "Scheduled task collection failed: $($_.Exception.Message)" `
            "ERROR"
    }
}


# ------------------------------------------------------------
# Persistence → Process Correlation
# ------------------------------------------------------------

function Correlate-StartupProcesses {

    try {

        Write-Log "Correlating Startup shortcuts with running processes..."

        $startupFile = Join-Path `
            $root `
            "Persistence\startup_shortcuts.csv"

        $processFile = Join-Path `
            $root `
            "Processes\processes.csv"

        if (-not (Test-Path $startupFile)) {

            Write-Log `
                "Startup shortcut evidence not found." `
                "ERROR"

            return
        }

        if (-not (Test-Path $processFile)) {

            Write-Log `
                "Process evidence not found." `
                "ERROR"

            return
        }

        $shortcuts = @(Import-Csv $startupFile)

        $processes = @(Import-Csv $processFile)

        $results = foreach ($shortcut in $shortcuts) {

            $matches = $processes |
                Where-Object {
                    $_.ExecutablePath -eq $shortcut.TargetPath
                }

            if ($matches) {

                foreach ($process in $matches) {

                    [PSCustomObject]@{

                        ShortcutName = $shortcut.Name

                        TargetPath = $shortcut.TargetPath

                        Arguments = $shortcut.Arguments

                        ProcessName = $process.Name

                        ProcessId = $process.ProcessId

                        ParentProcessId = $process.ParentProcessId

                        CommandLine = $process.CommandLine

                        Status = "Running"
                    }
                }
            }

            else {

                [PSCustomObject]@{

                    ShortcutName = $shortcut.Name

                    TargetPath = $shortcut.TargetPath

                    Arguments = $shortcut.Arguments

                    ProcessName = $null

                    ProcessId = $null

                    ParentProcessId = $null

                    CommandLine = $null

                    Status = "Not currently running"
                }
            }
        }

        $results |
            Export-Csv `
                (Join-Path $root "Persistence\startup_process_correlation.csv") `
                -NoTypeInformation

        Write-CollectionStatus `
            -Module "Persistence Correlation" `
            -Status "SUCCESS" `
            -Message "Startup/process correlation completed."

        Write-Log "Startup/process correlation completed."
    }

    catch {

        Write-CollectionStatus `
            -Module "Persistence Correlation" `
            -Status "FAILED" `
            -Message $_.Exception.Message

        Write-Log `
            "Startup/process correlation failed: $($_.Exception.Message)" `
            "ERROR"
    }
}