<#
.SYNOPSIS
    Observes PowerShell command history from:
    - In-memory session
    - PSReadLine history file
    - Event Logs (4104 - Script Block Logging)
#>

function Observe-PSHistory {
    Write-Host "`n===== In-Memory History (Get-History) =====" -ForegroundColor Cyan
    try {
        Get-History | Format-Table Id, CommandLine -AutoSize
    } catch {
        Write-Warning "Unable to access in-memory history."
    }

    Write-Host "`n===== PSReadLine Persistent History File =====" -ForegroundColor Cyan
    $histPath = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    if (Test-Path $histPath) {
        Get-Content $histPath -ErrorAction SilentlyContinue | Select-Object -Last 50
    } else {
        Write-Warning "History file not found at: $histPath"
    }

    
}

# Run the function
Observe-PSHistory
