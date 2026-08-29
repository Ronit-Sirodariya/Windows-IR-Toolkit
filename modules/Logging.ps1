# ============================================================
# Logging Module
# ============================================================

function Write-Log {

    param(
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $logMessage = "[$timestamp] [$Level] $Message"

    $logFile = Join-Path $root "collection.log"

    Add-Content -Path $logFile -Value $logMessage

    Write-Output $logMessage
}
function Write-CollectionStatus {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Module,

        [Parameter(Mandatory = $true)]
        [ValidateSet("SUCCESS", "FAILED", "SKIPPED")]
        [string]$Status,

        [string]$Message = ""
    )

    $statusFile = Join-Path `
        $root `
        "Metadata\collection_status.csv"

    [PSCustomObject]@{
        Module    = $Module
        Status    = $Status
        Timestamp = Get-Date
        Message   = $Message
    } |
        Export-Csv `
            -Path $statusFile `
            -NoTypeInformation `
            -Append
}