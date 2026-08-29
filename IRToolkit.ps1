# ------------------------------------------------------------
# Environment checks
# ------------------------------------------------------------

$windowsIdentity = [Security.Principal.WindowsIdentity]::GetCurrent() 

$windowsPrincipal = New-Object Security.Principal.WindowsPrincipal($windowsIdentity)

$isAdministrator = $windowsPrincipal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

$psVersion = $PSVersionTable.PSVersion.ToString()

$osInfo = Get-CimInstance Win32_OperatingSystem
# ============================================================
# Windows IR Toolkit
# Main Entry Point
# ============================================================

$ErrorActionPreference = "Continue" # This controls how PowerShell behaves when errors occur.

# ------------------------------------------------------------
# 1. Collection information
# ------------------------------------------------------------

$computerName = $env:COMPUTERNAME
$userName = $env:USERNAME
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# ------------------------------------------------------------
# 2. Create collection directory
# ------------------------------------------------------------

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path 
# $MyInvocation.MyCommand.Path gives us the path of the currently executing script.

# Then:

# Split-Path -Parent

# gets the directory containing that script

$outputRoot = Join-Path $scriptRoot "output"

$caseDirectory = "IR_${computerName}_${timestamp}"

$root = Join-Path $outputRoot $caseDirectory

New-Item -ItemType Directory -Path $root -Force | Out-Null

. (Join-Path $scriptRoot "modules\Logging.ps1")
. (Join-Path $scriptRoot "modules\System.ps1")
. (Join-Path $scriptRoot ".\modules\Users.ps1")
. (Join-Path $scriptRoot ".\modules\Processes.ps1")
. (Join-Path $scriptRoot ".\modules\Network.ps1")
. (Join-Path $scriptRoot ".\modules\Services.ps1")
. (Join-Path $scriptRoot ".\modules\Persistence.ps1")
. (Join-Path $scriptRoot ".\modules\EventLogs.ps1")
. (Join-Path $scriptRoot ".\modules\Sysmon.ps1")
. (Join-Path $scriptRoot ".\modules\Timeline.ps1")
. (Join-Path $scriptRoot ".\modules\Report.ps1")
. (Join-Path $scriptRoot ".\modules\Hashes.ps1")
. (Join-Path $scriptRoot ".\modules\Findings.ps1")
. (Join-Path $scriptRoot ".\modules\FileSystem.ps1")






# ------------------------------------------------------------
# 3. Create evidence directories
# ------------------------------------------------------------

$directories = @(
    "Metadata",
    "System",
    "Users",
    "Processes",
    "Services",
    "Network",
    "Persistence",
    "EventLogs",
    "Sysmon",
    "Filesystem",
    "Hashes",
    "Timeline",
    "Findings",
    "Report"
)

foreach ($directory in $directories) {

    New-Item `
        -ItemType Directory `
        -Path (Join-Path $root $directory) `
        -Force |
        Out-Null
}

# ------------------------------------------------------------
# 4. Display collection information
# ------------------------------------------------------------

Write-Output ""
Write-Output "=============================================="
Write-Output "        WINDOWS IR TOOLKIT"
Write-Output "=============================================="
Write-Output ""
Write-Output "[+] Computer : $computerName"
Write-Output "[+] User     : $userName"
Write-Output "[+] Started  : $(Get-Date)"
Write-Output "[+] Output   : $root"
Write-Output ""
Write-Output "[+] Collection environment initialized."


Write-Output ""
Write-Output "[+] Collecting system information..."

Collect-SystemInfo

Write-Output "[+] System information collection completed."

Write-Output ""
Write-Output "[+] Collecting Users information..."

Collect-Users

Write-Output "[+] User information collection completed."

Write-Output ""
Write-Output "[+] Collecting Process information..."

Collect-Processes 

Write-Output "[+] Process information collection completed."


Write-Output ""
Write-Output " [+] COLLECTING Network Information "

Collect-NetworkInfo

Write-Output "[+] Network Collection completed"

Write-Output ""
Write-Output " [+] COLLECTING Service Information "

Collect-Services

Write-Output "[+] Service Collection completed"

Write-Output ""
Write-Output "[+] Collecting Startup items..."

Collect-StartupItems

Write-Output "[+] Collecting Startup shortcuts..."

Collect-StartupShortcuts

Write-Output "[+] Collecting Registry persistence..."

Collect-RegistryPersistence

Write-Output "[+] Collecting Scheduled Tasks..."

Collect-ScheduledTaskPersistence

Write-Output "[+] Correlating Startup shortcuts with processes..."

Correlate-StartupProcesses

Write-Output ""

Write-Output "[+] Collecting authentication events..."

Collect-EventLogs

Write-Output "[+] Authentication event collection completed."


# ============================================================
# 10. Sysmon
# ============================================================

Write-Output ""

Write-Output "[+] Collecting Sysmon process creation events..."

Collect-SysmonProcessCreation

Write-Output "[+] Sysmon process creation collection completed."


# ============================================================
# 11. Filesystem
# ============================================================

Write-Output ""

Write-Output "[+] Collecting filesystem metadata..."

Collect-FilesystemMetadata

Write-Output "[+] Filesystem metadata collection completed."


# ============================================================
# 12. Hashes
# ============================================================

Write-Output ""

Write-Output "[+] Collecting file hashes..."

Collect-FileHashes

Write-Output "[+] File hash collection completed."


# ============================================================
# 13. Timeline
# ============================================================

Write-Output ""

Write-Output "[+] Building investigation timeline..."

Build-Timeline

Write-Output "[+] Investigation timeline completed."


# ============================================================
# 14. Findings
# ============================================================

Write-Output ""

Write-Output "[+] Analyzing process evidence..."

Analyze-Processes

Write-Output "[+] Process analysis completed."


# ============================================================
# 15. Report
# ============================================================

Write-Output ""

Write-Output "[+] Building investigation report..."

Build-IRReport

Write-Output "[+] Investigation report completed."


# ============================================================
# Collection Complete
# ============================================================

Write-Output ""

Write-Output "=============================================="
Write-Output "       COLLECTION COMPLETED"
Write-Output "=============================================="

Write-Output ""
Write-Output "[+] Case directory:"
Write-Output $root

Write-Output ""
Write-Output "[+] Windows IR Toolkit finished."

