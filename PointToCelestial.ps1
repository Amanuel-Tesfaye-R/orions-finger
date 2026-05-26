# PointToCelestial.ps1
# Converts Celestial Coordinates (RA/Dec) to Servo Angles (Alt/Az)
# and sends them to the Arduino.

param (
    [string]$RA = "00:00:00",  # Right Ascension (HH:MM:SS or decimal)
    [string]$Dec = "00:00:00", # Declination (DD:MM:SS or decimal)
    [double]$Lat = 40.7128,    # Your Latitude (Default: New York)
    [double]$Long = -74.0060,  # Your Longitude (Default: New York)
    [string]$COM = "COM3"      # Your Arduino COM port
)

function To-Decimal($timeStr, $isRA) {
    if ($timeStr -match ":") {
        $parts = $timeStr.Split(":")
        $h = [double]$parts[0]
        $m = [double]$parts[1]
        $s = if ($parts.Count -gt 2) { [double]$parts[2] } else { 0 }
        if ($h -lt 0) { return $h - ($m/60) - ($s/3600) }
        return $h + ($m/60) + ($s/3600)
    }
    return [double]$timeStr
}

# 1. Parse Inputs
$raDecimal = To-Decimal $RA $true
$decDecimal = To-Decimal $Dec $false

# CONFIGURATION - CHANGE THESE FOR YOUR SETUP
$GearRatioAz = 2.0  # Set to 2.0 if you have a 2:1 gear for 360 rotation
$NorthOffset = 0.0  # Adjustment in degrees if your base isn't perfectly North
$COM = "COM3"

# 2. Get Current Time in UTC
$now = [DateTime]::UtcNow
$y = $now.Year
$m = $now.Month
$d = $now.Day
$h = $now.Hour + ($now.Minute / 60) + ($now.Second / 3600)

# 3. Calculate Julian Day
if ($m -le 2) { $y -= 1; $m += 12 }
$jd = [math]::Floor(365.25 * ($y + 4716)) + [math]::Floor(30.6001 * ($m + 1)) + $d + ($h / 24) - 1524.5

# 4. Greenwich Sidereal Time (GMST)
$d_since_j2000 = $jd - 2451545.0
$gmst = (18.697374558 + 24.06570982441908 * $d_since_j2000) % 24

# 5. Local Sidereal Time (LST) & Hour Angle (HA)
$lst = ($gmst + ($Long / 15)) % 24
$ha = ($lst - $raDecimal) * 15 
if ($ha -lt 0) { $ha += 360 }

# 6. Convert to Alt/Az
$latRad = $Lat * [Math]::PI / 180
$decRad = $decDecimal * [Math]::PI / 180
$haRad = $ha * [Math]::PI / 180

$sinAlt = [Math]::Sin($decRad) * [Math]::Sin($latRad) + [Math]::Cos($decRad) * [Math]::Cos($latRad) * [Math]::Cos($haRad)
$alt = [Math]::Asin($sinAlt) * 180 / [Math]::PI

$cosAz = ([Math]::Sin($decRad) - [Math]::Sin($alt * [Math]::PI / 180) * [Math]::Sin($latRad)) / ([Math]::Cos($alt * [Math]::PI / 180) * [Math]::Cos($latRad))
if ($cosAz -gt 1) { $cosAz = 1 } elseif ($cosAz -lt -1) { $cosAz = -1 }
$az = [Math]::Acos($cosAz) * 180 / [Math]::PI
if ([Math]::Sin($haRad) -gt 0) { $az = 360 - $az }

# 7. Parallactic Angle (Z-axis rotation)
$sinP = [Math]::Sin($haRad) * [Math]::Cos($latRad) / [Math]::Cos($alt * [Math]::PI / 180)
$pAngle = [Math]::Asin($sinP) * 180 / [Math]::PI

# Apply Offset
$finalAz = ($az + $NorthOffset) % 360

# 8. Map to Servo (0-180 range)
$servoX = $finalAz / $GearRatioAz
$servoY = $alt
$servoZ = 90 + $pAngle # Center at 90 and tilt by parallactic angle

# Horizon Check
if ($alt -lt 0) {
    Write-Host "WARNING: Star is below the horizon (Alt: $([Math]::Round($alt,1))°)" -ForegroundColor Red
    $servoY = 0
}

Write-Host "--- Precision Celestial Scan ---" -ForegroundColor Cyan
Write-Host "Target: RA $RA, Dec $Dec"
Write-Host "Current Alt: $([Math]::Round($alt,2))°"
Write-Host "Current Az:  $([Math]::Round($az,2))°"
Write-Host "Sending to Arduino: X$([Math]::Round($servoX,2)) Y$([Math]::Round($servoY,2)) Z$([Math]::Round($servoZ,2))"

# 9. Send to Arduino
& "$PSScriptRoot\SendToStarPointer.ps1" -COM $COM -X $servoX -Y $servoY -Z $servoZ
