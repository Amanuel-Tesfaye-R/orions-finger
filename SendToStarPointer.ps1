# PowerShell script to send angles to the Arduino Star Pointer
# Usage: .\SendToStarPointer.ps1 -COM "COM3" -X 90 -Y 45 -Z 0

param (
    [string]$COM = "COM3",
    [int]$X = 90,
    [int]$Y = 90,
    [int]$Z = 90
)

try {
    $port = New-Object System.IO.Ports.SerialPort $COM, 115200, None, 8, one
    $port.Open()
    Start-Sleep -Seconds 2 # Wait for Arduino to reset

    $command = "X$X Y$Y Z$Z`n"
    $port.Write($command)
    
    Write-Host "Sent to $COM: $command" -ForegroundColor Cyan
    
    $port.Close()
} catch {
    Write-Error "Failed to communicate with $COM. Check port name and connection."
}
