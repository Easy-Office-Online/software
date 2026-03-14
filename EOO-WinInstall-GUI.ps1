# ════════════════════════════════════════════════════════════════
#  EOO – Hulp bij Windows installaties  |  Portable editie
# ════════════════════════════════════════════════════════════════

# UAC elevatie – herstart als admin indien nodig
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$script_LenovoSU = @'
@echo off
:: UAC elevatie
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -EncodedCommand JABjAG8AbgBmAGkAZwBVAHIAbAAgAD0AIAAnAGgAdAB0AHAAcwA6AC8ALwByAGEAdwAuAGcAaQB0AGgAdQBiAHUAcwBlAHIAYwBvAG4AdABlAG4AdAAuAGMAbwBtAC8ARQBhAHMAeQAtAE8AZgBmAGkAYwBlAC0ATwBuAGwAaQBuAGUALwBzAG8AZgB0AHcAYQByAGUALwByAGUAZgBzAC8AaABlAGEAZABzAC8AbQBhAGkAbgAvAGwAZQBuAG8AdgBvAFMAVQAuAHQAeAB0ACcACgAKAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAnACcACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAJwAgACAAPQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9ACcAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAVwBoAGkAdABlAAoAVwByAGkAdABlAC0ASABvAHMAdAAgACcAIAAgACAATABlAG4AbwB2AG8AIABTAHkAcwB0AGUAbQAgAFUAcABkAGEAdABlACAASQBuAHMAdABhAGwAbABlAHIAJwAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABXAGgAaQB0AGUACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAJwAgACAAPQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9ACcAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAVwBoAGkAdABlAAoAVwByAGkAdABlAC0ASABvAHMAdAAgACcAJwAKAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAnACAAIABbADEALwA0AF0AIABDAG8AbgBmAGkAZwAgAG8AcABoAGEAbABlAG4AIAB2AGEAbgAgAEcAaQB0AEgAdQBiAC4ALgAuACcAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAVwBoAGkAdABlAAoACgB0AHIAeQAgAHsACgAgACAAIAAgACQAcgBhAHcAIAA9ACAAKABJAG4AdgBvAGsAZQAtAFcAZQBiAFIAZQBxAHUAZQBzAHQAIAAtAFUAcgBpACAAJABjAG8AbgBmAGkAZwBVAHIAbAAgAC0AVQBzAGUAQgBhAHMAaQBjAFAAYQByAHMAaQBuAGcAKQAuAEMAbwBuAHQAZQBuAHQACgAgACAAIAAgACQAdgBlAHIAcwBpAG8AbgAgAD0AIAAoACQAcgBhAHcAIAAtAHMAcABsAGkAdAAgACIAYABuACIAIAB8ACAAVwBoAGUAcgBlAC0ATwBiAGoAZQBjAHQAIAB7ACAAJABfACAALQBtAGEAdABjAGgAIAAnAF4AVgBlAHIAcwBpAG8AbgAnACAAfQApAC4AUwBwAGwAaQB0ACgAJwA9ACcAKQBbADEAXQAuAFQAcgBpAG0AKAApAC4AVAByAGkAbQAoACcAIgAnACkACgAgACAAIAAgACQAdQByAGwAIAAgACAAIAAgAD0AIAAoACQAcgBhAHcAIAAtAHMAcABsAGkAdAAgACIAYABuACIAIAB8ACAAVwBoAGUAcgBlAC0ATwBiAGoAZQBjAHQAIAB7ACAAJABfACAALQBtAGEAdABjAGgAIAAnAF4AVQBSAEwAJwAgAH0AKQAuAFMAcABsAGkAdAAoACcAPQAnACwAMgApAFsAMQBdAC4AVAByAGkAbQAoACkALgBUAHIAaQBtACgAJwAiACcAKQAKAAoAIAAgACAAIABpAGYAIAAoAC0AbgBvAHQAIAAkAHYAZQByAHMAaQBvAG4AIAAtAG8AcgAgAC0AbgBvAHQAIAAkAHUAcgBsACkAIAB7AAoAIAAgACAAIAAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAnACAAIABbAEYATwBVAFQAXQAgAEMAbwBuAGYAaQBnACAAbwBuAHYAbwBsAGwAZQBkAGkAZwA6ACAAdgBlAHIAcwBpAG8AbgAgAG8AZgAgAHUAcgBsACAAbwBuAHQAYgByAGUAZQBrAHQALgAnACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFIAZQBkAAoAIAAgACAAIAAgACAAIAAgAFIAZQBhAGQALQBIAG8AcwB0ACAAJwAgACAARAByAHUAawAgAG8AcAAgAEUAbgB0AGUAcgAgAG8AbQAgAHQAZQAgAHMAbAB1AGkAdABlAG4AJwAKACAAIAAgACAAIAAgACAAIABlAHgAaQB0ACAAMQAKACAAIAAgACAAfQAKAAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAIgAgACAAIAAgACAAIAAgACAAVgBlAHIAcwBpAGUAIAA6ACAAJAB2AGUAcgBzAGkAbwBuACIAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAARwByAGUAZQBuAAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAIgAgACAAIAAgACAAIAAgACAAVQBSAEwAIAAgACAAIAA6ACAAJAB1AHIAbAAiACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAEcAcgBlAGUAbgAKAH0AIABjAGEAdABjAGgAIAB7AAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAIgAgACAAWwBGAE8AVQBUAF0AIABDAG8AbgBmAGkAZwAgAG8AcABoAGEAbABlAG4AIABtAGkAcwBsAHUAawB0ADoAIAAkAF8AIgAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABSAGUAZAAKACAAIAAgACAAUgBlAGEAZAAtAEgAbwBzAHQAIAAnACAAIABEAHIAdQBrACAAbwBwACAARQBuAHQAZQByACAAbwBtACAAdABlACAAcwBsAHUAaQB0AGUAbgAnAAoAIAAgACAAIABlAHgAaQB0ACAAMQAKAH0ACgAKAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAnACcACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAJwAgACAAWwAyAC8ANABdACAAQwBvAG4AdAByAG8AbABlAHIAZQBuACAAbwBmACAATABlAG4AbwB2AG8AIABTAHkAcwB0AGUAbQAgAFUAcABkAGEAdABlACAAYQBsACAAZwBlAGkAbgBzAHQAYQBsAGwAZQBlAHIAZAAgAGkAcwAuAC4ALgAnACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFcAaABpAHQAZQAKAAoAJAByAGUAZwBQAGEAdABoAHMAIAA9ACAAQAAoAAoAIAAgACAAIAAnAEgASwBMAE0AOgBcAFMATwBGAFQAVwBBAFIARQBcAE0AaQBjAHIAbwBzAG8AZgB0AFwAVwBpAG4AZABvAHcAcwBcAEMAdQByAHIAZQBuAHQAVgBlAHIAcwBpAG8AbgBcAFUAbgBpAG4AcwB0AGEAbABsAFwAKgAnACwACgAgACAAIAAgACcASABLAEwATQA6AFwAUwBPAEYAVABXAEEAUgBFAFwAVwBPAFcANgA0ADMAMgBOAG8AZABlAFwATQBpAGMAcgBvAHMAbwBmAHQAXABXAGkAbgBkAG8AdwBzAFwAQwB1AHIAcgBlAG4AdABWAGUAcgBzAGkAbwBuAFwAVQBuAGkAbgBzAHQAYQBsAGwAXAAqACcACgApAAoAJABpAG4AcwB0AGEAbABsAGUAZAAgAD0AIABHAGUAdAAtAEkAdABlAG0AUAByAG8AcABlAHIAdAB5ACAAJAByAGUAZwBQAGEAdABoAHMAIAAtAEUAcgByAG8AcgBBAGMAdABpAG8AbgAgAFMAaQBsAGUAbgB0AGwAeQBDAG8AbgB0AGkAbgB1AGUAIAB8ACAAVwBoAGUAcgBlAC0ATwBiAGoAZQBjAHQAIAB7ACAAJABfAC4ARABpAHMAcABsAGEAeQBOAGEAbQBlACAALQBsAGkAawBlACAAJwAqAEwAZQBuAG8AdgBvACAAUwB5AHMAdABlAG0AIABVAHAAZABhAHQAZQAqACcAIAB9AAoACgBpAGYAIAAoACQAaQBuAHMAdABhAGwAbABlAGQAKQAgAHsACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiACAAIAAgACAAIAAgACAAIABHAGUAdgBvAG4AZABlAG4AOgAgACQAKAAkAGkAbgBzAHQAYQBsAGwAZQBkAC4ARABpAHMAcABsAGEAeQBOAGEAbQBlACkAIgAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABZAGUAbABsAG8AdwAKACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIAAgACAAIAAgACAAIAAgAEcAZQBpAG4AcwB0AGEAbABsAGUAZQByAGQAZQAgAHYAZQByAHMAaQBlADoAIAAkACgAJABpAG4AcwB0AGEAbABsAGUAZAAuAEQAaQBzAHAAbABhAHkAVgBlAHIAcwBpAG8AbgApACIAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAWQBlAGwAbABvAHcACgAgACAAIAAgAGkAZgAgACgAJABpAG4AcwB0AGEAbABsAGUAZAAuAEQAaQBzAHAAbABhAHkAVgBlAHIAcwBpAG8AbgAgAC0AZQBxACAAJAB2AGUAcgBzAGkAbwBuACkAIAB7AAoAIAAgACAAIAAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiACAAIAAgACAAIAAgACAAIABBAGwAIAB1AHAALQB0AG8ALQBkAGEAdABlACAAKAAkAHYAZQByAHMAaQBvAG4AKQAuACAARwBlAGUAbgAgAGkAbgBzAHQAYQBsAGwAYQB0AGkAZQAgAG4AbwBkAGkAZwAuACIAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAARwByAGUAZQBuAAoAIAAgACAAIAAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAnACcACgAgACAAIAAgACAAIAAgACAAUgBlAGEAZAAtAEgAbwBzAHQAIAAnACAAIABEAHIAdQBrACAAbwBwACAARQBuAHQAZQByACAAbwBtACAAdABlACAAcwBsAHUAaQB0AGUAbgAnAAoAIAAgACAAIAAgACAAIAAgAGUAeABpAHQAIAAwAAoAIAAgACAAIAB9ACAAZQBsAHMAZQAgAHsACgAgACAAIAAgACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIAAgACAAIAAgACAAIAAgAEEAbgBkAGUAcgBlACAAdgBlAHIAcwBpAGUAIABnAGUAdgBvAG4AZABlAG4ALAAgAGQAbwBvAHIAZwBhAGEAbgAgAG0AZQB0ACAAaQBuAHMAdABhAGwAbABhAHQAaQBlACAAdgBhAG4AIAAkAHYAZQByAHMAaQBvAG4ALgAuAC4AIgAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABDAHkAYQBuAAoAIAAgACAAIAB9AAoAfQAgAGUAbABzAGUAIAB7AAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAJwAgACAAIAAgACAAIAAgACAATgBpAGUAdAAgAGcAZQBpAG4AcwB0AGEAbABsAGUAZQByAGQALAAgAGQAbwBvAHIAZwBhAGEAbgAgAG0AZQB0ACAAaQBuAHMAdABhAGwAbABhAHQAaQBlAC4ALgAuACcAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAQwB5AGEAbgAKAH0ACgAKAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAnACcACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAIgAgACAAWwAzAC8ANABdACAASQBuAHMAdABhAGwAbABlAHIAIABkAG8AdwBuAGwAbwBhAGQAZQBuACAAKAB2ACQAdgBlAHIAcwBpAG8AbgApAC4ALgAuACIAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAVwBoAGkAdABlAAoACgAkAGkAbgBzAHQAYQBsAGwAZQByACAAPQAgACIAJABlAG4AdgA6AFQARQBNAFAAXABMAGUAbgBvAHYAbwBTAHkAcwB0AGUAbQBVAHAAZABhAHQAZQBfACQAdgBlAHIAcwBpAG8AbgAuAGUAeABlACIACgB0AHIAeQAgAHsACgAgACAAIAAgAEkAbgB2AG8AawBlAC0AVwBlAGIAUgBlAHEAdQBlAHMAdAAgAC0AVQByAGkAIAAkAHUAcgBsACAALQBPAHUAdABGAGkAbABlACAAJABpAG4AcwB0AGEAbABsAGUAcgAgAC0AVQBzAGUAQgBhAHMAaQBjAFAAYQByAHMAaQBuAGcACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAnACAAIAAgACAAIAAgACAAIABEAG8AdwBuAGwAbwBhAGQAIABnAGUAcwBsAGEAYQBnAGQALgAnACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAEcAcgBlAGUAbgAKAH0AIABjAGEAdABjAGgAIAB7AAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAIgAgACAAWwBGAE8AVQBUAF0AIABEAG8AdwBuAGwAbwBhAGQAIABtAGkAcwBsAHUAawB0ADoAIAAkAF8AIgAgAC0ARgBvAHIAZwByAG8AdQBuAGQAQwBvAGwAbwByACAAUgBlAGQACgAgACAAIAAgAFIAZQBhAGQALQBIAG8AcwB0ACAAJwAgACAARAByAHUAawAgAG8AcAAgAEUAbgB0AGUAcgAgAG8AbQAgAHQAZQAgAHMAbAB1AGkAdABlAG4AJwAKACAAIAAgACAAZQB4AGkAdAAgADEACgB9AAoACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAJwAnAAoAVwByAGkAdABlAC0ASABvAHMAdAAgACcAIAAgAFsANAAvADQAXQAgAEkAbgBzAHQAYQBsAGwAZQByAGUAbgAuAC4ALgAnACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFcAaABpAHQAZQAKAAoAdAByAHkAIAB7AAoAIAAgACAAIAAkAHAAIAA9ACAAUwB0AGEAcgB0AC0AUAByAG8AYwBlAHMAcwAgAC0ARgBpAGwAZQBQAGEAdABoACAAJABpAG4AcwB0AGEAbABsAGUAcgAgAC0AQQByAGcAdQBtAGUAbgB0AEwAaQBzAHQAIAAnAC8AVgBFAFIAWQBTAEkATABFAE4AVAAgAC8ATgBPAFIARQBTAFQAQQBSAFQAJwAgAC0AVwBhAGkAdAAgAC0AUABhAHMAcwBUAGgAcgB1AAoAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAJwAnAAoAIAAgACAAIABpAGYAIAAoACQAcAAuAEUAeABpAHQAQwBvAGQAZQAgAC0AZQBxACAAMAApACAAewAKACAAIAAgACAAIAAgACAAIABXAHIAaQB0AGUALQBIAG8AcwB0ACAAJwAgACAAWwBPAEsAXQAgACAAIABMAGUAbgBvAHYAbwAgAFMAeQBzAHQAZQBtACAAVQBwAGQAYQB0AGUAIABzAHUAYwBjAGUAcwB2AG8AbACAAZwBlAGkAbgBzAHQAYQBsAGwAZQBlAHIAZAAuACcAIAAtAEYAbwByAGUAZwByAG8AdQBuAGQAQwBvAGwAbwByACAARwByAGUAZQBuAAoAIAAgACAAIAB9ACAAZQBsAHMAZQAgAHsACgAgACAAIAAgACAAIAAgACAAVwByAGkAdABlAC0ASABvAHMAdAAgACIAIAAgAFsARgBPAFUAVABdACAASQBuAHMAdABhAGwAbABhAHQAaQBlACAAbQBpAHMAbAB1AGsAdAAuACAARQB4AGkAdAAgAGMAbwBkAGUAOgAgACQAKAAkAHAALgBFAHgAaQB0AEMAbwBkAGUAKQAiACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFIAZQBkAAoAIAAgACAAIAB9AAoAfQAgAGMAYQB0AGMAaAAgAHsACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiACAAIABbAEYATwBVAFQAXQAgAEkAbgBzAHQAYQBsAGwAYQB0AGkAZQAgAG0AaQBzAGwAdQBrAHQAOgAgACQAXwAiACAALQBGAG8AcgBlAGcAcgBvAHUAbgBkAEMAbwBsAG8AcgAgAFIAZQBkAAoAfQAgAGYAaQBuAGEAbABsAHkAIAB7AAoAIAAgACAAIABpAGYAIAAoAFQAZQBzAHQALQBQAGEAdABoACAAJABpAG4AcwB0AGEAbABsAGUAcgApACAAewAgAFIAZQBtAG8AdgBlAC0ASQB0AGUAbQAgACQAaQBuAHMAdABhAGwAbABlAHIAIAAtAEYAbwByAGMAZQAgAH0ACgB9AAoACgBXAHIAaQB0AGUALQBIAG8AcwB0ACAAJwAnAAoAUgBlAGEAZAAtAEgAbwBzAHQAIAAnACAAIABEAHIAdQBrACAAbwBwACAARQBuAHQAZQByACAAbwBtACAAdABlACAAcwBsAHUAaQB0AGUAbgAnAAoA
'@

$script_HPIA = @'
@echo off
net session >nul 2>&1
if %errorLevel% NEQ 0 ( PowerShell -Command "Start-Process -FilePath '%~f0' -Verb RunAs" & exit /b )
set "PS=%TEMP%\hpia_install.ps1"
(
echo $PackageName = "HPIA"
echo $TextFileURL = "https://raw.githubusercontent.com/Easy-Office-Online/software/refs/heads/main/hpia.txt"
echo $text = Invoke-RestMethod -Uri $TextFileURL
echo $version = $null; $url = $null
echo foreach ($line in $text -split "`r`n"^) {
echo     if ($line -match 'Version = "(.+)"'^) { $version = $matches[1] }
echo     if ($line -match 'URL = "(.*)"'^) { $url = $matches[1] }
echo }
echo $folderPath = "C:\ProgramData\eoo\$PackageName"
echo $filename = [System.IO.Path]::GetFileName($url^)
echo $filepath = "$folderPath\$filename"
echo if (-not (Test-Path $folderPath^)^) { New-Item -Path $folderPath -ItemType Directory ^| Out-Null }
echo Invoke-WebRequest -Uri $url -OutFile $filepath
echo New-Item -ItemType Directory -Path "C:\HPIA" -Force ^| Out-Null
echo New-Item -ItemType Directory -Path "C:\HPIAReport" -Force ^| Out-Null
echo Start-Process -FilePath $filepath -ArgumentList '/s /e' -Wait
echo $timeout = 120; $elapsed = 0; $found = $null
echo do { Start-Sleep -Seconds 3; $elapsed += 3; $found = Get-ChildItem -Path "C:\SWSetup" -Filter "HPImageAssistant.exe" -Recurse -ErrorAction SilentlyContinue ^| Select-Object -First 1 } while (-not $found -and $elapsed -lt $timeout^)
echo if (-not $found^) { Write-Host "FOUT: HPImageAssistant.exe niet gevonden."; exit 1 }
echo Copy-Item -Path "$($found.DirectoryName)\*" -Destination "C:\HPIA" -Recurse -Force
echo Remove-Item -Path $found.DirectoryName -Recurse -Force -ErrorAction SilentlyContinue
echo Remove-Item $filepath -ErrorAction SilentlyContinue
echo Start-Process -FilePath "C:\HPIA\HPImageAssistant.exe" -ArgumentList "/Operation:Analyze /Category:All /Selection:All /Action:Install /Silent /ReportFolder:C:\HPIAReport" -NoNewWindow -Wait
echo Write-Host "Klaar! Rapport staat in C:\HPIAReport"
) > "%PS%"
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%PS%"
del "%PS%"
pause
'@

$script_HWID_Overwrite = @'
@echo off
setlocal
title Autopilot HWID Export (OVERWRITE)
net session >nul 2>&1
if not "%errorlevel%"=="0" ( echo Administrator vereist. & pause & exit /b 1 )
set "GroupTag="
set /p GroupTag=Voer GroupTag in (bijv: EOO-W11-FLEX): 
if "%GroupTag%"=="" ( echo Geen GroupTag opgegeven. Stop. & pause & exit /b 1 )
set "ExportPath=##SCRIPTDIR##Autopilot-%COMPUTERNAME%.csv"
set "PS1=%TEMP%\Get-HWID-Autopilot-Overwrite.ps1"
> "%PS1%" echo param([string]$GroupTag,[string]$OutFile)
>>"%PS1%" echo $ErrorActionPreference = 'Stop'
>>"%PS1%" echo $serial = (Get-CimInstance Win32_BIOS).SerialNumber
>>"%PS1%" echo $dev = Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_DevDetail_Ext01 -ErrorAction Stop
>>"%PS1%" echo $hash = $dev.DeviceHardwareData
>>"%PS1%" echo if (-not $hash) { throw 'Hardware hash niet gevonden.' }
>>"%PS1%" echo if (Test-Path $OutFile) { Remove-Item $OutFile -Force -ErrorAction SilentlyContinue }
>>"%PS1%" echo $header = 'Device Serial Number,Windows Product ID,Hardware Hash,Group Tag,Assigned User'
>>"%PS1%" echo $line = $serial + ',,' + $hash + ',' + $GroupTag + ','
>>"%PS1%" echo Set-Content -Path $OutFile -Value $header -Encoding UTF8
>>"%PS1%" echo Add-Content -Path $OutFile -Value $line -Encoding UTF8
>>"%PS1%" echo Write-Host "OK: CSV overschreven: $OutFile"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -GroupTag "%GroupTag%" -OutFile "%ExportPath%"
pause
endlocal
'@

$script_HWID_Append = @'
@echo off
setlocal
title Autopilot HWID Export (APPEND)
net session >nul 2>&1
if not "%errorlevel%"=="0" ( echo Administrator vereist. & pause & exit /b 1 )
set "GroupTag="
set /p GroupTag=Voer GroupTag in (bijv: EOO-W11-FLEX): 
if "%GroupTag%"=="" ( echo Geen GroupTag opgegeven. Stop. & pause & exit /b 1 )
set "ExportPath=##SCRIPTDIR##Autopilot-Bulk.csv"
set "PS1=%TEMP%\Get-HWID-Autopilot-Append.ps1"
> "%PS1%" echo param([string]$GroupTag,[string]$OutFile)
>>"%PS1%" echo $ErrorActionPreference = 'Stop'
>>"%PS1%" echo $serial = (Get-CimInstance Win32_BIOS).SerialNumber
>>"%PS1%" echo $dev = Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_DevDetail_Ext01 -ErrorAction Stop
>>"%PS1%" echo $hash = $dev.DeviceHardwareData
>>"%PS1%" echo if (-not $hash) { throw 'Hardware hash niet gevonden.' }
>>"%PS1%" echo $header = 'Device Serial Number,Windows Product ID,Hardware Hash,Group Tag,Assigned User'
>>"%PS1%" echo $line = $serial + ',,' + $hash + ',' + $GroupTag + ','
>>"%PS1%" echo if (-not (Test-Path $OutFile)) { Set-Content -Path $OutFile -Value $header -Encoding UTF8 }
>>"%PS1%" echo Add-Content -Path $OutFile -Value $line -Encoding UTF8
>>"%PS1%" echo Write-Host "OK: Regel toegevoegd aan: $OutFile"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -GroupTag "%GroupTag%" -OutFile "%ExportPath%"
pause
endlocal
'@

function Write-TempScript {
    param([string]$Content, [string]$Filename)
    $path = Join-Path $env:TEMP $Filename
    [System.IO.File]::WriteAllText($path, ($Content -replace "`r`n","`n" -replace "`n","`r`n"))
    return $path
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$clrBg        = [System.Drawing.Color]::FromArgb(15, 32, 68)
$clrPanel     = [System.Drawing.Color]::FromArgb(22, 44, 88)
$clrAccent    = [System.Drawing.Color]::FromArgb(61, 184, 232)
$clrAccentDim = [System.Drawing.Color]::FromArgb(30, 100, 140)
$clrSubText   = [System.Drawing.Color]::FromArgb(160, 190, 220)
$clrDivider   = [System.Drawing.Color]::FromArgb(40, 70, 120)
$clrBtnBg     = [System.Drawing.Color]::FromArgb(25, 55, 100)
$clrBtnHover  = [System.Drawing.Color]::FromArgb(61, 184, 232)
$clrBtnHoverFg= [System.Drawing.Color]::FromArgb(15, 32, 68)
$clrDanger    = [System.Drawing.Color]::FromArgb(220, 70, 70)
$clrGreen     = [System.Drawing.Color]::FromArgb(80, 200, 120)

$fntTitle   = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$fntSub     = New-Object System.Drawing.Font("Segoe UI", 8,  [System.Drawing.FontStyle]::Regular)
$fntLabel   = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Regular)
$fntSection = New-Object System.Drawing.Font("Segoe UI", 7,  [System.Drawing.FontStyle]::Bold)
$fntBtn     = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Regular)

# ── GDI+ icon helpers ────────────────────────────────────────────
# Teken een vinkje-bitmap (16x16)
function New-CheckBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $pen = New-Object System.Drawing.Pen($Color, 2.5)
    $pts = @(
        [System.Drawing.Point]::new(2,  8),
        [System.Drawing.Point]::new(6,  12),
        [System.Drawing.Point]::new(14, 4)
    )
    $g.DrawLines($pen, $pts)
    $pen.Dispose(); $g.Dispose()
    return $bmp
}

# Teken een uitroepteken-bitmap (16x16)
function New-ExclBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $pen   = New-Object System.Drawing.Pen($Color, 2.5)
    # Streep
    $g.DrawLine($pen, 8, 2, 8, 10)
    # Punt
    $g.FillEllipse($brush, 6, 12, 4, 4)
    $pen.Dispose(); $brush.Dispose(); $g.Dispose()
    return $bmp
}

# Groot rood uitroepteken (24x24) voor info-panel
function New-BigExclBitmap {
    $bmp = New-Object System.Drawing.Bitmap(24, 24)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $brush = New-Object System.Drawing.SolidBrush($clrDanger)
    $pen   = New-Object System.Drawing.Pen($clrDanger, 3)
    $g.DrawLine($pen, 12, 2, 12, 15)
    $g.FillEllipse($brush, 9, 18, 6, 6)
    $pen.Dispose(); $brush.Dispose(); $g.Dispose()
    return $bmp
}

# Pijl-bitmap voor actie-knoppen (16x16)
function New-ArrowBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $pts = [System.Drawing.Point[]]@(
        [System.Drawing.Point]::new(3,  3),
        [System.Drawing.Point]::new(13, 8),
        [System.Drawing.Point]::new(3,  13)
    )
    $g.FillPolygon($brush, $pts)
    $brush.Dispose(); $g.Dispose()
    return $bmp
}

# Download pijl (16x16)
function New-DownArrowBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $pen   = New-Object System.Drawing.Pen($Color, 2)
    $g.DrawLine($pen, 8, 2, 8, 11)
    $pts = [System.Drawing.Point[]]@(
        [System.Drawing.Point]::new(3,  8),
        [System.Drawing.Point]::new(13, 8),
        [System.Drawing.Point]::new(8,  14)
    )
    $g.FillPolygon($brush, $pts)
    $brush.Dispose(); $pen.Dispose(); $g.Dispose()
    return $bmp
}

# Refresh cirkel (16x16)
function New-RefreshBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $pen = New-Object System.Drawing.Pen($Color, 2)
    $g.DrawArc($pen, 2, 2, 12, 12, -30, 270)
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $pts = [System.Drawing.Point[]]@(
        [System.Drawing.Point]::new(10, 1),
        [System.Drawing.Point]::new(15, 5),
        [System.Drawing.Point]::new(10, 5)
    )
    $g.FillPolygon($brush, $pts)
    $pen.Dispose(); $brush.Dispose(); $g.Dispose()
    return $bmp
}

# Power knop icoon (16x16)
function New-PowerBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $pen = New-Object System.Drawing.Pen($Color, 2)
    $g.DrawArc($pen, 3, 4, 10, 10, 135, 270)
    $g.DrawLine($pen, 8, 2, 8, 8)
    $pen.Dispose(); $g.Dispose()
    return $bmp
}

# Settings tandwiel (16x16)
function New-GearBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $pen   = New-Object System.Drawing.Pen($Color, 1.5)
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $g.DrawEllipse($pen, 5, 5, 6, 6)
    for ($i = 0; $i -lt 8; $i++) {
        $angle = $i * 45 * [Math]::PI / 180
        $x1 = 8 + 5 * [Math]::Cos($angle) - 1
        $y1 = 8 + 5 * [Math]::Sin($angle) - 1
        $g.FillRectangle($brush, $x1, $y1, 2, 2)
    }
    $pen.Dispose(); $brush.Dispose(); $g.Dispose()
    return $bmp
}

# Windows logo (16x16)
function New-WindowsBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $g.FillRectangle($brush, 2,  2,  6, 6)
    $g.FillRectangle($brush, 9,  2,  5, 6)
    $g.FillRectangle($brush, 2,  9,  6, 5)
    $g.FillRectangle($brush, 9,  9,  5, 5)
    $brush.Dispose(); $g.Dispose()
    return $bmp
}

# Sleutel (16x16) voor activatie
function New-KeyBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $pen   = New-Object System.Drawing.Pen($Color, 1.5)
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $g.DrawEllipse($pen, 2, 2, 7, 7)
    $pts = [System.Drawing.Point[]]@(
        [System.Drawing.Point]::new(8, 9),
        [System.Drawing.Point]::new(14, 14),
        [System.Drawing.Point]::new(12, 14),
        [System.Drawing.Point]::new(10, 12)
    )
    $g.DrawLines($pen, $pts)
    $pen.Dispose(); $brush.Dispose(); $g.Dispose()
    return $bmp
}

# Duimpje omhoog (24x24) voor alles-OK status
function New-ThumbBitmap {
    $bmp = New-Object System.Drawing.Bitmap(24, 24)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $brush = New-Object System.Drawing.SolidBrush($clrGreen)
    $pen   = New-Object System.Drawing.Pen($clrGreen, 1.5)
    # Duim omhoog (vereenvoudigd): handpalm + duim
    # Handpalm
    $g.FillRectangle($brush, 6, 11, 12, 10)
    # Duim
    $thumbPts = [System.Drawing.Point[]]@(
        [System.Drawing.Point]::new(6,  11),
        [System.Drawing.Point]::new(6,  7),
        [System.Drawing.Point]::new(9,  3),
        [System.Drawing.Point]::new(12, 5),
        [System.Drawing.Point]::new(11, 11)
    )
    $g.FillPolygon($brush, $thumbPts)
    # Vingers (lijntjes)
    $g.DrawLine($pen, 9,  12, 9,  20)
    $g.DrawLine($pen, 12, 12, 12, 20)
    $g.DrawLine($pen, 15, 12, 15, 20)
    $pen.Dispose(); $brush.Dispose(); $g.Dispose()
    return $bmp
}


function New-IconBox {
    param([System.Drawing.Bitmap]$Bmp, [int]$X, [int]$Y, [int]$Size = 16)
    $pb = New-Object System.Windows.Forms.PictureBox
    $pb.Image    = $Bmp
    $pb.Size     = New-Object System.Drawing.Size($Size, $Size)
    $pb.Location = New-Object System.Drawing.Point($X, $Y)
    $pb.SizeMode = 'StretchImage'
    $pb.BackColor= [System.Drawing.Color]::Transparent
    return $pb
}

# ── Form ─────────────────────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text            = 'EOO - Windows Installatie Tool'
$form.Size            = New-Object System.Drawing.Size(980, 640)
$form.MinimumSize     = New-Object System.Drawing.Size(780, 540)
$form.StartPosition   = 'CenterScreen'
$form.BackColor       = $clrBg
$form.ForeColor       = [System.Drawing.Color]::White
$form.FormBorderStyle = 'Sizable'
$form.MaximizeBox     = $true

# ── Header ───────────────────────────────────────────────────────
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Size      = New-Object System.Drawing.Size(980, 80)
$pnlHeader.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$pnlHeader.Location  = New-Object System.Drawing.Point(0, 0)
$pnlHeader.BackColor = $clrPanel
$form.Controls.Add($pnlHeader)

$pnlAccentBar = New-Object System.Windows.Forms.Panel
$pnlAccentBar.Size      = New-Object System.Drawing.Size(980, 4)
$pnlAccentBar.Location  = New-Object System.Drawing.Point(0, 0)
$pnlAccentBar.BackColor = $clrAccent
$pnlHeader.Controls.Add($pnlAccentBar)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text      = 'EOO'
$lblTitle.Font      = $fntTitle
$lblTitle.ForeColor = $clrAccent
$lblTitle.Location  = New-Object System.Drawing.Point(20, 14)
$lblTitle.AutoSize  = $true
$pnlHeader.Controls.Add($lblTitle)

$lblSubTitle = New-Object System.Windows.Forms.Label
$lblSubTitle.Text      = 'Windows Installatie Tool'
$lblSubTitle.Font      = $fntSub
$lblSubTitle.ForeColor = $clrSubText
$lblSubTitle.Location  = New-Object System.Drawing.Point(22, 44)
$lblSubTitle.AutoSize  = $true
$pnlHeader.Controls.Add($lblSubTitle)

$lblVersion = New-Object System.Windows.Forms.Label
$lblVersion.Text      = 'v3.0'
$lblVersion.Font      = $fntSub
$lblVersion.ForeColor = $clrAccentDim
$lblVersion.Location  = New-Object System.Drawing.Point(935, 60)
$lblVersion.AutoSize  = $true
$pnlHeader.Controls.Add($lblVersion)

# ── Info panel ───────────────────────────────────────────────────
$pnlInfo = New-Object System.Windows.Forms.Panel
$pnlInfo.Size      = New-Object System.Drawing.Size(446, 134)
$pnlInfo.Location  = New-Object System.Drawing.Point(22, 92)
$pnlInfo.BackColor = $clrPanel
$pnlInfo.add_Paint({
    param($s, $e)
    $pen = New-Object System.Drawing.Pen($clrAccent, 1)
    $e.Graphics.DrawRectangle($pen, 0, 0, $s.Width - 1, $s.Height - 1)
    $pen.Dispose()
})
$form.Controls.Add($pnlInfo)

# Info rij: status-icoon (PictureBox) + tekst label
function New-InfoRow {
    param($Panel, [int]$Y)
    $pb = New-Object System.Windows.Forms.PictureBox
    $pb.Size     = New-Object System.Drawing.Size(16, 16)
    $pb.Location = New-Object System.Drawing.Point(10, ($Y + 3))
    $pb.SizeMode = 'StretchImage'
    $pb.BackColor= [System.Drawing.Color]::Transparent
    $Panel.Controls.Add($pb)

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Font      = $fntLabel
    $lbl.ForeColor = $clrSubText
    $lbl.Location  = New-Object System.Drawing.Point(32, $Y)
    $lbl.Size      = New-Object System.Drawing.Size(300, 22)
    $Panel.Controls.Add($lbl)
    return @{ Icon = $pb; Label = $lbl }
}

$rowWin  = New-InfoRow $pnlInfo 10
$rowAct  = New-InfoRow $pnlInfo 34
$rowTpm  = New-InfoRow $pnlInfo 58
$rowBoot = New-InfoRow $pnlInfo 82
$rowNet  = New-InfoRow $pnlInfo 106

# Overall status label – groot symbool rechts in het info panel
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Font      = New-Object System.Drawing.Font("Segoe UI Symbol", 42, [System.Drawing.FontStyle]::Regular)
$lblStatus.Location  = New-Object System.Drawing.Point(360, 10)
$lblStatus.Size      = New-Object System.Drawing.Size(75, 90)
$lblStatus.TextAlign = 'MiddleCenter'
$lblStatus.BackColor = [System.Drawing.Color]::Transparent
$lblStatus.Text      = ''
$pnlInfo.Controls.Add($lblStatus)

$lblWindowsVersion   = $rowWin.Label
$lblActivationState  = $rowAct.Label
$lblTpmStatus        = $rowTpm.Label
$lblSecureBootStatus = $rowBoot.Label

# ── Knop helper ──────────────────────────────────────────────────
function New-EOOButton {
    param([string]$Text, [int]$X, [int]$Y,
          [int]$W = 446, [int]$H = 34,
          $BgColor = $null, $HoverBg = $null, $HoverFg = $null)
    if ($null -eq $BgColor) { $BgColor  = $clrBtnBg }
    if ($null -eq $HoverBg) { $HoverBg  = $clrBtnHover }
    if ($null -eq $HoverFg) { $HoverFg  = $clrBtnHoverFg }

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text      = $Text
    $btn.Font      = $fntBtn
    $btn.ForeColor = $clrSubText
    $btn.BackColor = $BgColor
    $btn.FlatStyle = 'Flat'
    $btn.FlatAppearance.BorderColor        = $clrDivider
    $btn.FlatAppearance.BorderSize         = 1
    $btn.FlatAppearance.MouseOverBackColor = $HoverBg
    $btn.Location  = New-Object System.Drawing.Point($X, $Y)
    $btn.Size      = New-Object System.Drawing.Size($W, $H)
    $btn.Cursor    = [System.Windows.Forms.Cursors]::Hand
    $btn.TextAlign = 'MiddleLeft'
    $btn.Padding   = New-Object System.Windows.Forms.Padding(28, 0, 0, 0)

    $capturedFg = [System.Drawing.Color]::FromArgb($HoverFg.A, $HoverFg.R, $HoverFg.G, $HoverFg.B)
    $btn.Add_MouseEnter([scriptblock]::Create('$this.ForeColor = [System.Drawing.Color]::FromArgb(' + $capturedFg.A + ',' + $capturedFg.R + ',' + $capturedFg.G + ',' + $capturedFg.B + ')'))
    $btn.Add_MouseLeave({ $this.ForeColor = [System.Drawing.Color]::FromArgb(160, 190, 220) })
    $form.Controls.Add($btn)
    return $btn
}

# Voeg icoon toe aan knop (PictureBox zweeft over de knop)
function Add-BtnIcon {
    param($Btn, [System.Drawing.Bitmap]$Bmp)
    $pb = New-Object System.Windows.Forms.PictureBox
    $pb.Image    = $Bmp
    $pb.Size     = New-Object System.Drawing.Size(16, 16)
    $pb.Location = New-Object System.Drawing.Point(($Btn.Left + 8), ($Btn.Top + 9))
    $pb.SizeMode = 'StretchImage'
    $pb.BackColor= [System.Drawing.Color]::Transparent
    $pb.Enabled  = $false
    $form.Controls.Add($pb)
    $pb.BringToFront()
}

function New-SectionLabel {
    param([string]$Text, [int]$Y)
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text      = $Text.ToUpper()
    $lbl.Font      = $fntSection
    $lbl.ForeColor = $clrAccentDim
    $lbl.Location  = New-Object System.Drawing.Point(22, $Y)
    $lbl.AutoSize  = $true
    $form.Controls.Add($lbl)
    $line = New-Object System.Windows.Forms.Panel
    $line.BackColor = $clrDivider
    $line.Location  = New-Object System.Drawing.Point(22, ($Y + 12))
    $line.Size      = New-Object System.Drawing.Size(446, 1)
    $form.Controls.Add($line)
}

# ── Sectie: Systeem ──────────────────────────────────────────────
New-SectionLabel 'Systeem' 218

$btnRestart = New-EOOButton 'Restart' 22 234 214 34
Add-BtnIcon $btnRestart (New-RefreshBitmap $clrAccent)
$btnRestart.Add_Click({
    Write-Console 'Systeem wordt herstart...' 'start'
    Start-Process PowerShell -ArgumentList '-Command shutdown.exe /r /t 0' -NoNewWindow
})

$btnShutdown = New-EOOButton 'Shutdown' 246 234 222 34 $clrBtnBg $clrDanger ([System.Drawing.Color]::White)
$btnShutdown.FlatAppearance.MouseOverBackColor = $clrDanger
$shutdownWhite = [System.Drawing.Color]::White
$btnShutdown.Add_MouseEnter({ $this.ForeColor = $shutdownWhite })
$btnShutdown.Add_MouseLeave({ $this.ForeColor = $clrSubText })
Add-BtnIcon $btnShutdown (New-PowerBitmap $clrSubText)
$btnShutdown.Add_Click({
    Write-Console 'Systeem wordt afgesloten...' 'start'
    Start-Process PowerShell -ArgumentList '-Command shutdown.exe /s /t 0' -NoNewWindow
})

$btnWU = New-EOOButton 'Windows Update openen' 22 276
Add-BtnIcon $btnWU (New-WindowsBitmap $clrAccent)
$btnWU.Add_Click({
    Write-Console 'Windows Update instellingen openen...' 'start'
    Start-Process 'ms-settings:windowsupdate'
})

$btnDM = New-EOOButton 'Apparaatbeheer openen' 22 318
Add-BtnIcon $btnDM (New-GearBitmap $clrAccent)
$btnDM.Add_Click({
    Write-Console 'Apparaatbeheer openen...' 'start'
    Start-Process 'devmgmt.msc'
})

$btnAW = New-EOOButton 'Windows activeren' 22 360
Add-BtnIcon $btnAW (New-KeyBitmap $clrAccent)
$btnAW.Add_Click({
    Write-Console 'Windows activeringsscherm openen...' 'start'
    Start-Process "C:\Windows\System32\slui.exe"
})

# ── Sectie: Drivers ──────────────────────────────────────────────
New-SectionLabel 'Drivers' 410

$btnLSU = New-EOOButton 'Lenovo System Update installeren' 22 426
Add-BtnIcon $btnLSU (New-ArrowBitmap $clrAccent)
$btnLSU.Add_Click({
    $script:btnLSU.Enabled = $false
    $script:Write_Console_Ref = Get-Item Function:\Write-Console
    Write-Console 'Lenovo System Update: gestart...' 'start'

    $script:jobLSU = Start-Job -ScriptBlock {
        $configUrl = 'https://raw.githubusercontent.com/Easy-Office-Online/software/refs/heads/main/lenovoSU.txt'
        $raw     = (Invoke-WebRequest -Uri $configUrl -UseBasicParsing).Content
        $version = ($raw -split "`n" | Where-Object { $_ -match '^Version' }).Split('=')[1].Trim().Trim('"')
        $url     = ($raw -split "`n" | Where-Object { $_ -match '^URL' }).Split('=',2)[1].Trim().Trim('"')

        if (-not $version -or -not $url) { throw 'Config onvolledig: versie of URL ontbreekt.' }
        Write-Output "[1/4] Config opgehaald. Versie: $version"

        Write-Output '[2/4] Controleren of al geinstalleerd...'
        $regPaths  = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                       'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
        $installed = Get-ItemProperty $regPaths -ErrorAction SilentlyContinue |
                     Where-Object { $_.DisplayName -like '*Lenovo System Update*' }

        if ($installed) {
            Write-Output "    Gevonden: $($installed.DisplayName) v$($installed.DisplayVersion)"
            if ($installed.DisplayVersion -eq $version) {
                Write-Output "    Al up-to-date ($version). Geen installatie nodig."
                Write-Output "SIGNAL:UPTODATE"
                return
            }
            Write-Output "    Andere versie gevonden, doorgaan met v$version..."
        } else {
            Write-Output '    Niet geinstalleerd, doorgaan...'
        }

        Write-Output "[3/4] Installer downloaden (v$version)..."
        $installer = "$env:TEMP\LenovoSystemUpdate_$version.exe"
        Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing
        Write-Output '    Download geslaagd.'

        Write-Output '[4/4] Installeren...'
        $p = Start-Process -FilePath $installer -ArgumentList '/VERYSILENT /NORESTART' -Wait -PassThru
        if (Test-Path $installer) { Remove-Item $installer -Force }
        if ($p.ExitCode -ne 0) { throw "Installatie mislukt. Exit code: $($p.ExitCode)" }
        Write-Output '[OK] Lenovo System Update succesvol geinstalleerd.'

        $tvsu = 'C:\Program Files (x86)\Lenovo\System Update\tvsu.exe'
        if (-not (Test-Path $tvsu)) {
            $tvsu = (Get-ChildItem 'C:\Program Files (x86)\Lenovo\System Update\tvsu.exe','C:\Program Files\Lenovo\System Update\tvsu.exe' -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
        }
        Write-Output "SIGNAL:TVSU:$tvsu"
    }

    $script:timerLSU = New-Object System.Windows.Forms.Timer
    $script:timerLSU.Interval = 500
    $script:timerLSU.Add_Tick({
        foreach ($line in ($script:jobLSU.ChildJobs[0].Output.ReadAll())) {
            if     ($line -match '^SIGNAL:') { }
            elseif ($line -match '^\[OK\]')  { Write-Console $line 'ok' }
            elseif ($line -match 'FOUT|mislukt') { Write-Console $line 'error' }
            else                             { Write-Console $line 'info' }
        }
        foreach ($err in ($script:jobLSU.ChildJobs[0].Error.ReadAll())) {
            Write-Console "FOUT: $($err.Exception.Message)" 'error'
        }
        if ($script:jobLSU.State -in 'Completed','Failed') {
            $script:timerLSU.Stop()
            $script:timerLSU.Dispose()

            if ($script:jobLSU.State -eq 'Failed') {
                Write-Console "FOUT: $($script:jobLSU.ChildJobs[0].JobStateInfo.Reason.Message)" 'error'
            } else {
                # Zoek SIGNAL-regels in alle output
                $allOutput = $script:jobLSU.ChildJobs[0].Output + $script:jobLSU.ChildJobs[0].Output.ReadAll()
                $signal = @($script:jobLSU | Receive-Job -ErrorAction SilentlyContinue) | Where-Object { $_ -match '^SIGNAL:' } | Select-Object -Last 1
                if ($signal -match '^SIGNAL:UPTODATE') {
                    Write-Console 'Al up-to-date, geen actie nodig.' 'ok'
                } elseif ($signal -match '^SIGNAL:TVSU:(.+)') {
                    $tvsuPath = $matches[1].Trim()
                    if ($tvsuPath -and (Test-Path $tvsuPath)) {
                        Write-Console 'Lenovo System Update wordt gestart...' 'start'
                        Start-Process -FilePath $tvsuPath
                        Write-Console 'Lenovo System Update gestart.' 'ok'
                    } else {
                        Write-Console 'tvsu.exe niet gevonden op verwacht pad.' 'info'
                    }
                }
            }
            Remove-Job $script:jobLSU -Force
            $script:btnLSU.Enabled = $true
        }
    })
    $script:timerLSU.Start()
})

$btnHPIA = New-EOOButton 'HP Image Assistant installeren en draaien' 22 468
Add-BtnIcon $btnHPIA (New-ArrowBitmap $clrAccent)
$btnHPIA.Add_Click({
    $script:btnHPIA.Enabled = $false
    Write-Console 'HP Image Assistant: gestart...' 'start'

    $script:jobHPIA = Start-Job -ScriptBlock {
        $TextFileURL = 'https://raw.githubusercontent.com/Easy-Office-Online/software/refs/heads/main/hpia.txt'
        $text    = Invoke-RestMethod -Uri $TextFileURL
        $version = $null; $url = $null
        foreach ($line in $text -split "`r`n") {
            if ($line -match 'Version = "(.+)"') { $version = $matches[1] }
            if ($line -match 'URL = "(.*)"')     { $url     = $matches[1] }
        }
        if (-not $version -or -not $url) { throw 'Config onvolledig: versie of URL ontbreekt.' }
        Write-Output "[1/5] Config opgehaald. Versie: $version"

        Write-Output '[2/5] Doelmappen aanmaken...'
        $folderPath = 'C:\ProgramData\eoo\HPIA'
        $filename   = [System.IO.Path]::GetFileName($url)
        $filepath   = "$folderPath\$filename"
        if (-not (Test-Path $folderPath)) { New-Item -Path $folderPath -ItemType Directory | Out-Null }
        New-Item -ItemType Directory -Path 'C:\HPIA'       -Force | Out-Null
        New-Item -ItemType Directory -Path 'C:\HPIAReport' -Force | Out-Null

        Write-Output '[3/5] Setup downloaden...'
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $url -OutFile $filepath
        Write-Output '    Download geslaagd.'

        Write-Output '[4/5] Setup uitpakken...'
        Start-Process -FilePath $filepath -ArgumentList '/s /e' -Wait

        $timeout = 120; $elapsed = 0; $found = $null
        do {
            Start-Sleep -Seconds 3; $elapsed += 3
            $found = Get-ChildItem -Path 'C:\SWSetup' -Filter 'HPImageAssistant.exe' -Recurse -ErrorAction SilentlyContinue |
                     Select-Object -First 1
        } while (-not $found -and $elapsed -lt $timeout)
        if (-not $found) { throw 'HPImageAssistant.exe niet gevonden na extractie.' }

        Copy-Item -Path "$($found.DirectoryName)\*" -Destination 'C:\HPIA' -Recurse -Force
        Remove-Item -Path $found.DirectoryName -Recurse -Force -ErrorAction SilentlyContinue
        Stop-Process -Name 'HPImageAssistant' -Force -ErrorAction SilentlyContinue
        Remove-Item $filepath -ErrorAction SilentlyContinue
        Write-Output '    HPIA staat in C:\HPIA'

        Write-Output '[5/5] HPIA uitvoeren (drivers analyseren en installeren)...'
        Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' `
            -ArgumentList '/Operation:Analyze /Category:All /Selection:All /Action:Install /Silent /ReportFolder:C:\HPIAReport' `
            -NoNewWindow -Wait
        Write-Output '[OK] Klaar. Rapport staat in C:\HPIAReport'
    }

    $script:timerHPIA = New-Object System.Windows.Forms.Timer
    $script:timerHPIA.Interval = 500
    $script:timerHPIA.Add_Tick({
        foreach ($line in ($script:jobHPIA.ChildJobs[0].Output.ReadAll())) {
            if     ($line -match '^\[OK\]')          { Write-Console $line 'ok' }
            elseif ($line -match 'FOUT|mislukt')     { Write-Console $line 'error' }
            else                                     { Write-Console $line 'info' }
        }
        foreach ($err in ($script:jobHPIA.ChildJobs[0].Error.ReadAll())) {
            Write-Console "FOUT: $($err.Exception.Message)" 'error'
        }
        if ($script:jobHPIA.State -in 'Completed','Failed') {
            $script:timerHPIA.Stop()
            $script:timerHPIA.Dispose()
            if ($script:jobHPIA.State -eq 'Failed') {
                Write-Console "FOUT: $($script:jobHPIA.ChildJobs[0].JobStateInfo.Reason.Message)" 'error'
            }
            Remove-Job $script:jobHPIA -Force
            $script:btnHPIA.Enabled = $true
        }
    })
    $script:timerHPIA.Start()
})

# ── Sectie: Autopilot ────────────────────────────────────────────
New-SectionLabel 'Autopilot' 518

$btnHWIDOvr = New-EOOButton 'HWID Export - Overwrite (per device)' 22 534
Add-BtnIcon $btnHWIDOvr (New-DownArrowBitmap $clrAccent)
$btnHWIDOvr.Add_Click({
    Write-Console 'HWID Export (Overwrite) wordt gestart...' 'start'
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot + '\' } else { (Split-Path -Parent $MyInvocation.ScriptName) + '\' }
    $p = Write-TempScript -Content ($script_HWID_Overwrite -replace '##SCRIPTDIR##', $scriptDir) -Filename 'EOO_Get-HWID.cmd'
    Start-Process 'cmd.exe' -ArgumentList "/k `"$p`"" -Verb RunAs
    Write-Console 'HWID Export: voer GroupTag in het geopende venster in.' 'info'
})

$btnHWIDApp = New-EOOButton 'HWID Export - Append (bulk CSV)' 22 576
Add-BtnIcon $btnHWIDApp (New-DownArrowBitmap $clrAccent)
$btnHWIDApp.Add_Click({
    Write-Console 'HWID Export (Append) wordt gestart...' 'start'
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot + '\' } else { (Split-Path -Parent $MyInvocation.ScriptName) + '\' }
    $p = Write-TempScript -Content ($script_HWID_Append -replace '##SCRIPTDIR##', $scriptDir) -Filename 'EOO_Get-HWID_Aanvullen.cmd'
    Start-Process 'cmd.exe' -ArgumentList "/k `"$p`"" -Verb RunAs
    Write-Console 'HWID Export: voer GroupTag in het geopende venster in.' 'info'
})

# ── Console output panel (rechterkolom) ─────────────────────────
# Verticale scheidingslijn
$pnlDivider = New-Object System.Windows.Forms.Panel
$pnlDivider.BackColor = $clrDivider
$pnlDivider.Location  = New-Object System.Drawing.Point(490, 80)
$pnlDivider.Size      = New-Object System.Drawing.Size(2, 530)
$pnlDivider.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
$form.Controls.Add($pnlDivider)

# Console sectielabel rechts
$lblConsoleHdr = New-Object System.Windows.Forms.Label
$lblConsoleHdr.Text      = 'CONSOLE'
$lblConsoleHdr.Font      = $fntSection
$lblConsoleHdr.ForeColor = $clrAccentDim
$lblConsoleHdr.Location  = New-Object System.Drawing.Point(502, 84)
$lblConsoleHdr.AutoSize  = $true
$form.Controls.Add($lblConsoleHdr)

$txtConsole = New-Object System.Windows.Forms.RichTextBox
$txtConsole.Location    = New-Object System.Drawing.Point(502, 100)
$txtConsole.Size        = New-Object System.Drawing.Size(462, 506)
$txtConsole.BackColor   = [System.Drawing.Color]::FromArgb(10, 20, 45)
$txtConsole.ForeColor   = $clrSubText
$txtConsole.Font        = New-Object System.Drawing.Font("Consolas", 8)
$txtConsole.ReadOnly    = $true
$txtConsole.BorderStyle = 'None'
$txtConsole.ScrollBars  = 'Vertical'
$txtConsole.WordWrap    = $false
$txtConsole.Anchor      = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($txtConsole)

function Write-Console {
    param([string]$Message, [string]$Type = 'info')
    $time = Get-Date -Format 'HH:mm:ss'
    $txtConsole.SelectionStart = $txtConsole.TextLength
    $txtConsole.SelectionLength = 0
    switch ($Type) {
        'ok'    { $txtConsole.SelectionColor = $clrGreen }
        'error' { $txtConsole.SelectionColor = $clrDanger }
        'start' { $txtConsole.SelectionColor = $clrAccent }
        default { $txtConsole.SelectionColor = $clrSubText }
    }
    $txtConsole.AppendText("[$time] $Message`n")
    $txtConsole.ScrollToCaret()
}

# ── Footer ───────────────────────────────────────────────────────
$pnlFooter = New-Object System.Windows.Forms.Panel
$pnlFooter.Size      = New-Object System.Drawing.Size(980, 30)
$pnlFooter.Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$pnlFooter.Location  = New-Object System.Drawing.Point(0, 610)
$pnlFooter.BackColor = $clrPanel
$form.Controls.Add($pnlFooter)

$pnlFooterLine = New-Object System.Windows.Forms.Panel
$pnlFooterLine.BackColor = $clrAccent
$pnlFooterLine.Location  = New-Object System.Drawing.Point(0, 0)
$pnlFooterLine.Size      = New-Object System.Drawing.Size(980, 2)
$pnlFooter.Controls.Add($pnlFooterLine)

$lblFooter = New-Object System.Windows.Forms.Label
$lblFooter.Text      = 'Easy Office Online  •  eoo.nl'
$lblFooter.Font      = $fntSub
$lblFooter.ForeColor = $clrAccentDim
$lblFooter.Location  = New-Object System.Drawing.Point(20, 10)
$lblFooter.AutoSize  = $true
$pnlFooter.Controls.Add($lblFooter)

$lblDate = New-Object System.Windows.Forms.Label
$lblDate.Text      = (Get-Date -Format 'dd-MM-yyyy')
$lblDate.Font      = $fntSub
$lblDate.ForeColor = $clrAccentDim
$lblDate.Location  = New-Object System.Drawing.Point(920, 10)
$lblDate.AutoSize  = $true
$pnlFooter.Controls.Add($lblDate)

# ── Status functies ──────────────────────────────────────────────
function Set-InfoRow {
    param($Row, [string]$Text, [bool]$OK)
    $Row.Label.Text = $Text
    if ($OK) {
        $Row.Label.ForeColor = $clrGreen
        $Row.Icon.Image      = New-CheckBitmap $clrGreen
    } else {
        $Row.Label.ForeColor = $clrDanger
        $Row.Icon.Image      = New-BigExclBitmap
    }
}

function Display-WindowsVersion {
    $osInfo = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $pn = $osInfo.ProductName
    $dv = $osInfo.DisplayVersion
    $bn = [int]$osInfo.CurrentBuildNumber
    if ($bn -ge 22000) { $pn = $pn -replace '10','11' }
    $rowWin.Label.Text      = "$pn $dv (Build $bn)"
    $rowWin.Label.ForeColor = $clrSubText
    # Windows versie altijd neutraal icoon (info)
    $bmp = New-WindowsBitmap $clrAccent
    $rowWin.Icon.Image = $bmp
}

function Display-ActivationStatus {
    $licenseStatus = Get-CimInstance -Query "SELECT LicenseStatus FROM SoftwareLicensingProduct WHERE PartialProductKey IS NOT NULL AND LicenseStatus=1"
    $tekst = if ($licenseStatus) { 'Geactiveerd' } else { 'Niet geactiveerd' }
    Set-InfoRow $rowAct -Text $tekst -OK ([bool]$licenseStatus)
    $script:okActivation = [bool]$licenseStatus
}

function Display-TpmStatus {
    try {
        $tpm = Get-WmiObject -Namespace 'Root\CIMv2\Security\MicrosoftTpm' -Class Win32_Tpm
        if ($tpm) {
            $specVersion = $tpm.SpecVersion
            if ($specVersion) {
                Set-InfoRow $rowTpm -Text "TPM aanwezig (versie $specVersion)" -OK $true
            } else {
                Set-InfoRow $rowTpm -Text 'TPM aanwezig (versie onbekend)' -OK $true
            }
            $script:okTpm = $true
        } else {
            Set-InfoRow $rowTpm -Text 'Geen TPM gevonden' -OK $false
            $script:okTpm = $false
        }
    } catch {
        Set-InfoRow $rowTpm -Text 'Geen TPM gevonden' -OK $false
        $script:okTpm = $false
    }
}

function Display-SecureBootStatus {
    try {
        if (Get-Command -Name 'Confirm-SecureBootUEFI' -ErrorAction SilentlyContinue) {
            $secureBootStatus = Confirm-SecureBootUEFI
            if ($secureBootStatus) {
                Set-InfoRow $rowBoot -Text 'Secure Boot ingeschakeld' -OK $true
                $script:okSecureBoot = $true
            } else {
                Set-InfoRow $rowBoot -Text 'Secure Boot uitgeschakeld' -OK $false
                $script:okSecureBoot = $false
            }
        } else {
            $rowBoot.Label.Text      = 'Secure Boot: niet ondersteund op dit platform'
            $rowBoot.Label.ForeColor = $clrSubText
            $rowBoot.Icon.Image      = $null
            $script:okSecureBoot = $false
        }
    } catch {
        $rowBoot.Label.Text      = 'Secure Boot: geen UEFI systeem'
        $rowBoot.Label.ForeColor = $clrSubText
        $rowBoot.Icon.Image      = $null
        $script:okSecureBoot = $false
    }
}

function Display-InternetStatus {
    $ping = Test-Connection -ComputerName 'google.nl' -Count 1 -Quiet -ErrorAction SilentlyContinue
    if ($ping) {
        Set-InfoRow $rowNet -Text 'Internetverbinding aanwezig' -OK $true
        $script:okInternet = $true
    } else {
        Set-InfoRow $rowNet -Text 'Geen internetverbinding' -OK $false
        $script:okInternet = $false
    }
}

function Display-AllGoodThumb {
    if ($script:okActivation -and $script:okTpm -and $script:okSecureBoot -and $script:okInternet) {
        $lblStatus.Text      = [System.Char]::ConvertFromUtf32(0x1F44D)
        $lblStatus.ForeColor = $clrGreen
    } else {
        $lblStatus.Text      = '!'
        $lblStatus.Font      = New-Object System.Drawing.Font("Segoe UI", 64, [System.Drawing.FontStyle]::Bold)
        $lblStatus.ForeColor = $clrDanger
    }
}

Display-WindowsVersion
Display-ActivationStatus
Display-TpmStatus
Display-SecureBootStatus
Display-InternetStatus
Display-AllGoodThumb

Write-Console 'Systeemcontrole uitgevoerd.' 'info'
Write-Console "Windows activatie: $(if ($script:okActivation) { 'OK' } else { 'NIET geactiveerd' })" $(if ($script:okActivation) { 'ok' } else { 'error' })
Write-Console "TPM: $(if ($script:okTpm) { 'OK' } else { 'NIET gevonden' })" $(if ($script:okTpm) { 'ok' } else { 'error' })
Write-Console "Secure Boot: $(if ($script:okSecureBoot) { 'OK' } else { 'NIET ingeschakeld' })" $(if ($script:okSecureBoot) { 'ok' } else { 'error' })
Write-Console "Internet: $(if ($script:okInternet) { 'OK' } else { 'GEEN verbinding' })" $(if ($script:okInternet) { 'ok' } else { 'error' })

[void]$form.ShowDialog()
