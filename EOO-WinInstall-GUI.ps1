# ════════════════════════════════════════════════════════════════
#  EOO – Hulp bij Windows installaties  |  Portable editie
#  Opslaan als: UTF-8 with BOM  (VS Code: "Save with Encoding" > UTF-8 BOM)
# ════════════════════════════════════════════════════════════════
# ── Versie (hier aanpassen bij nieuwe release) ───────────────────
$script:currentVersion = [System.Version]'5.2'
$script:versionName    = 'Pizza Diavola'

# UAC elevatie – herstart als admin indien nodig
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
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
# EnableVisualStyles weggelaten voor Windows 95 opmaak

$clrBg        = [System.Drawing.Color]::FromArgb(192, 192, 192)   # Win95 grijs
$clrAccent    = [System.Drawing.Color]::FromArgb(0, 0, 128)        # Win95 navy (titelbalk)
$clrAccentDim = [System.Drawing.Color]::FromArgb(0, 0, 0)          # Zwart
$clrSubText   = [System.Drawing.Color]::FromArgb(0, 0, 0)          # Zwart

$clrBtnBg     = [System.Drawing.Color]::FromArgb(192, 192, 192)    # Win95 grijs knop
$clrBtnHover  = [System.Drawing.Color]::FromArgb(0, 0, 128)        # Win95 navy hover
$clrBtnHoverFg= [System.Drawing.Color]::FromArgb(255, 255, 255)    # Wit hover tekst
$clrDanger    = [System.Drawing.Color]::FromArgb(192, 0, 0)        # Win95 rood
$clrGreen     = [System.Drawing.Color]::FromArgb(0, 128, 0)        # Win95 groen

$fntTitle   = New-Object System.Drawing.Font("Microsoft Sans Serif", 12, [System.Drawing.FontStyle]::Bold)
$fntSub     = New-Object System.Drawing.Font("Microsoft Sans Serif", 8,  [System.Drawing.FontStyle]::Regular)
$fntLabel   = New-Object System.Drawing.Font("Microsoft Sans Serif", 8,  [System.Drawing.FontStyle]::Regular)
$fntSection = New-Object System.Drawing.Font("Microsoft Sans Serif", 8,  [System.Drawing.FontStyle]::Bold)
$fntBtn     = New-Object System.Drawing.Font("Microsoft Sans Serif", 8,  [System.Drawing.FontStyle]::Regular)

# EOO logo laden vanuit GitHub
$script:logoImage = $null
try {
    $logoBytes = (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Easy-Office-Online/software/refs/heads/main/EOO_Logo_rgb2.png' -UseBasicParsing).Content
    $logoStream = New-Object System.IO.MemoryStream(, [byte[]]$logoBytes)
    $script:logoImage = [System.Drawing.Image]::FromStream($logoStream)
} catch { }

$script:remoteVersion   = $null
$script:githubScriptUrl = 'https://raw.githubusercontent.com/Easy-Office-Online/software/refs/heads/main/EOO-WinInstall-GUI.ps1'

# ── Layout constanten ─────────────────────────────────────────────
$HDR_H       = 110   # header hoogte
$INFO_ROW_H  = 26    # hoogte per info-rij
$INFO_ROWS   = 8     # aantal info-rijen (automatisch meerekenen bij toevoegen)
$INFO_PAD_T  = 12    # top-marge binnenin info panel
$INFO_PAD_B  = 48    # onderste marge (ruimte voor vernieuw-knop)
$INFO_W      = 420   # breedte infopanel en knoppen (relatief aan scrollpanel)
$INFO_Y      = 14    # Y-positie in scrollpanel (paneel-relatief)
$INFO_H      = $INFO_PAD_T + ($INFO_ROWS * $INFO_ROW_H) + $INFO_PAD_B
$INFO_BOTTOM = $INFO_Y + $INFO_H
$SECT_Y      = $INFO_BOTTOM + 18   # Y-start voor secties onder het info panel

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

# Refresh cirkel (16x16) – gebruikt voor de Vernieuwen-knop in het infopanel
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

# Restart icoon (16x16) – grote clockwise circulaire pijl ↻
function New-RestartBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $pen   = New-Object System.Drawing.Pen($Color, 2)
    $brush = New-Object System.Drawing.SolidBrush($Color)
    # Arc van 40° (rechtsonder) clockwise 285° → eindigt bij ~325° (rechtsboven)
    $g.DrawArc($pen, 2, 2, 11, 11, 40, 285)
    # Pijlpunt bij einde arc (rechtsboven), richting wijzend naar beneden (= clockwise)
    $pts = [System.Drawing.Point[]]@(
        [System.Drawing.Point]::new(14, 7),   # tip
        [System.Drawing.Point]::new(14, 3),   # basis boven
        [System.Drawing.Point]::new(10, 5)    # basis links
    )
    $g.FillPolygon($brush, $pts)
    $pen.Dispose(); $brush.Dispose(); $g.Dispose()
    return $bmp
}

# Shutdown / power knop (16x16) – klassiek ⏻ symbool met opening BOVEN
function New-PowerBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $pen = New-Object System.Drawing.Pen($Color, 2)
    # Arc met 60° opening boven (van 300° clockwise 300°, gap tussen 240° en 300° = bovenkant)
    $g.DrawArc($pen, 3, 3, 10, 10, 300, 300)
    # Verticale lijn van boven-rand cirkel omhoog, door de opening
    $g.DrawLine($pen, 8, 1, 8, 8)
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

# WiFi signaal (16x16)
function New-WifiBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $pen   = New-Object System.Drawing.Pen($Color, 1.5)
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $g.DrawArc($pen, 1,  2, 14, 14, 210, 120)
    $g.DrawArc($pen, 4,  5,  8,  8, 210, 120)
    $g.DrawArc($pen, 7,  8,  2,  2, 210, 120)
    $g.FillEllipse($brush, 7, 13, 2, 2)
    $pen.Dispose(); $brush.Dispose(); $g.Dispose()
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
$form.Size            = New-Object System.Drawing.Size(980, 720)
$form.MinimumSize     = New-Object System.Drawing.Size(640, 500)
$form.StartPosition   = 'CenterScreen'
$form.BackColor       = $clrBg
$form.ForeColor       = $clrAccentDim
$form.FormBorderStyle = 'Sizable'
$form.MaximizeBox     = $true
$form.Font            = $fntLabel

# ── Header ───────────────────────────────────────────────────────
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Location  = New-Object System.Drawing.Point(0, 0)
$pnlHeader.Size      = New-Object System.Drawing.Size($form.ClientSize.Width, $HDR_H)
$pnlHeader.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$pnlHeader.BackColor = [System.Drawing.Color]::FromArgb(0, 128, 128)
$pnlHeader.add_Paint({
    param($s, $e)
    $g = $e.Graphics
    Add-Type -AssemblyName System.Drawing
    $rect   = New-Object System.Drawing.Rectangle(0, 0, $s.Width, $s.Height - 4)
    $clrL   = [System.Drawing.Color]::FromArgb(0, 128, 128)
    $clrR   = [System.Drawing.Color]::FromArgb(0, 160, 160)
    $brush  = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $clrL, $clrR, [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
    $g.FillRectangle($brush, $rect)
    $brush.Dispose()
})
$form.Controls.Add($pnlHeader)

# Onderste rand van header: grijs scheidslijn (Win95 stijl)
$pnlAccentBar = New-Object System.Windows.Forms.Panel
$pnlAccentBar.Location  = New-Object System.Drawing.Point(0, ($HDR_H - 4))
$pnlAccentBar.Size      = New-Object System.Drawing.Size($form.ClientSize.Width, 2)
$pnlAccentBar.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$pnlAccentBar.BackColor = [System.Drawing.Color]::FromArgb(128, 128, 128)
$pnlHeader.Controls.Add($pnlAccentBar)
$pnlAccentBar2 = New-Object System.Windows.Forms.Panel
$pnlAccentBar2.Location  = New-Object System.Drawing.Point(0, ($HDR_H - 2))
$pnlAccentBar2.Size      = New-Object System.Drawing.Size($form.ClientSize.Width, 2)
$pnlAccentBar2.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$pnlAccentBar2.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$pnlHeader.Controls.Add($pnlAccentBar2)

# Logo PictureBox
$pbHeaderLogo = New-Object System.Windows.Forms.PictureBox
$pbHeaderLogo.SizeMode  = 'Zoom'
$pbHeaderLogo.BackColor = [System.Drawing.Color]::Transparent
$pbHeaderLogo.Location  = New-Object System.Drawing.Point(14, 5)
$pbHeaderLogo.Size      = New-Object System.Drawing.Size(230, 98)
if ($script:logoImage) {
    $pbHeaderLogo.Image = $script:logoImage
} else {
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text      = 'EOO'
    $lblTitle.Font      = $fntTitle
    $lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
    $lblTitle.BackColor = [System.Drawing.Color]::Transparent
    $lblTitle.Location  = New-Object System.Drawing.Point(20, 24)
    $lblTitle.AutoSize  = $true
    $pnlHeader.Controls.Add($lblTitle)
}
$pnlHeader.Controls.Add($pbHeaderLogo)

$lblSubTitle = New-Object System.Windows.Forms.Label
$lblSubTitle.Text      = 'Windows Installatie Tool'
$lblSubTitle.Font      = New-Object System.Drawing.Font("Microsoft Sans Serif", 9, [System.Drawing.FontStyle]::Regular)
$lblSubTitle.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$lblSubTitle.BackColor = [System.Drawing.Color]::Transparent
$lblSubTitle.Location  = New-Object System.Drawing.Point(252, 50)
$lblSubTitle.AutoSize  = $true
$pnlHeader.Controls.Add($lblSubTitle)

$lblVersion = New-Object System.Windows.Forms.Label
$lblVersion.Text      = "v$script:currentVersion - $script:versionName"
$lblVersion.Font      = $fntSub
$lblVersion.ForeColor = [System.Drawing.Color]::FromArgb(192, 192, 192)
$lblVersion.BackColor = [System.Drawing.Color]::Transparent
$lblVersion.Location  = New-Object System.Drawing.Point(780, 88)
$lblVersion.AutoSize  = $true
$lblVersion.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$pnlHeader.Controls.Add($lblVersion)

$script:btnUpdate = New-Object System.Windows.Forms.Button
$script:btnUpdate.Text      = 'Update beschikbaar'
$script:btnUpdate.Font      = $fntSub
$script:btnUpdate.ForeColor = [System.Drawing.Color]::White
$script:btnUpdate.BackColor = [System.Drawing.Color]::FromArgb(0, 128, 0)
$script:btnUpdate.FlatStyle = 'Flat'
$script:btnUpdate.FlatAppearance.BorderColor        = [System.Drawing.Color]::FromArgb(0, 80, 0)
$script:btnUpdate.FlatAppearance.BorderSize         = 1
$script:btnUpdate.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(0, 160, 0)
$script:btnUpdate.Location  = New-Object System.Drawing.Point(760, 58)
$script:btnUpdate.Size      = New-Object System.Drawing.Size(162, 24)
$script:btnUpdate.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$script:btnUpdate.Cursor    = [System.Windows.Forms.Cursors]::Default
$script:btnUpdate.TextAlign = 'MiddleCenter'
$script:btnUpdate.Visible   = $false
$script:btnUpdate.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 160, 0) })
$script:btnUpdate.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 128, 0) })
$script:btnUpdate.Add_Click({
    $script:btnUpdate.Enabled = $false
    $script:btnUpdate.Text    = 'Bezig...'
    try {
        $raw      = (Invoke-WebRequest -Uri $script:githubScriptUrl -UseBasicParsing).Content
        $encoding = New-Object System.Text.UTF8Encoding($true)
        [System.IO.File]::WriteAllText($PSCommandPath, $raw, $encoding)
        $keuze = [System.Windows.Forms.MessageBox]::Show(
            "Script bijgewerkt naar v$script:remoteVersion.`nNu herstarten?",
            'Update geslaagd',
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        if ($keuze -eq [System.Windows.Forms.DialogResult]::Yes) {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
            $form.Close()
        } else {
            $script:btnUpdate.Text    = 'Herstart vereist'
            $script:btnUpdate.Enabled = $true
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Update mislukt:`n$_",
            'Fout',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        $script:btnUpdate.Text    = 'Update beschikbaar'
        $script:btnUpdate.Enabled = $true
    }
})
$pnlHeader.Controls.Add($script:btnUpdate)

# ── Footer (alvast aanmaken, inhoud komt verderop) ────────────────
$FTR_H = 30
$pnlFooter = New-Object System.Windows.Forms.Panel
$pnlFooter.Size      = New-Object System.Drawing.Size($form.ClientSize.Width, $FTR_H)
$pnlFooter.Location  = New-Object System.Drawing.Point(0, ($form.ClientSize.Height - $FTR_H))
$pnlFooter.Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$pnlFooter.BackColor = [System.Drawing.Color]::FromArgb(192, 192, 192)
$form.Controls.Add($pnlFooter)

# ── SplitContainer: linker scrollpanel | rechter consolepanel ────
$splitMain = New-Object System.Windows.Forms.SplitContainer
$splitMain.Location     = New-Object System.Drawing.Point(0, $HDR_H)
$splitMain.Size         = New-Object System.Drawing.Size($form.ClientSize.Width, ($form.ClientSize.Height - $HDR_H - $FTR_H))
$splitMain.Anchor       = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$splitMain.Orientation  = 'Vertical'
$splitMain.SplitterWidth = 3
$splitMain.Panel1MinSize = 420
$splitMain.Panel2MinSize = 200
$splitMain.BackColor     = [System.Drawing.Color]::FromArgb(128, 128, 128)
$splitMain.Panel1.BackColor = $clrBg
$splitMain.Panel2.BackColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
$form.Controls.Add($splitMain)

# SplitterDistance pas instellen nadat het form getoond is (juiste breedte)
$form.Add_Shown({
    $splitMain.SplitterDistance = [int]($splitMain.Width * 0.50)
    Invoke-LayoutResize
    Start-VersionCheck
})

$pnlLeftScroll = New-Object System.Windows.Forms.Panel
$pnlLeftScroll.AutoScroll = $true
$pnlLeftScroll.BackColor  = $clrBg
$pnlLeftScroll.Dock       = 'Fill'
$splitMain.Panel1.Controls.Add($pnlLeftScroll)
$script:leftPanel = $pnlLeftScroll

# ── Responsive layout helpers ────────────────────────────────────
$script:fullWidthCtrls  = [System.Collections.Generic.List[System.Windows.Forms.Control]]::new()
$script:sectionDividers = [System.Collections.Generic.List[System.Windows.Forms.Control]]::new()

function Invoke-LayoutResize {
    $avail = $script:leftPanel.ClientSize.Width
    if ($avail -le 0) { return }
    $margin = 22
    $innerW = [Math]::Max(360, $avail - $margin * 2)
    foreach ($ctrl in $script:fullWidthCtrls)  { $ctrl.Width = $innerW }
    foreach ($ctrl in $script:sectionDividers) { $ctrl.Width = $innerW }
    $halfW = [int](($innerW - 4) / 2)
    if ($script:btnRestart)  { $script:btnRestart.Width  = $halfW }
    if ($script:btnShutdown) {
        $script:btnShutdown.Width = $halfW
        $script:btnShutdown.Left  = $margin + $halfW + 4
    }
}
$script:leftPanel.Add_Resize({ Invoke-LayoutResize })

# ── Info panel ───────────────────────────────────────────────────
$pnlInfo = New-Object System.Windows.Forms.Panel
$pnlInfo.Size      = New-Object System.Drawing.Size($INFO_W, $INFO_H)
$pnlInfo.Location  = New-Object System.Drawing.Point(22, $INFO_Y)
$pnlInfo.BackColor = [System.Drawing.Color]::FromArgb(192, 192, 192)
$pnlInfo.add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $w = $s.Width - 1
    $h = $s.Height - 1
    # Win95 sunken 3D rand (zoals een tekstvak of sunken panel)
    $penDarkOuter  = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(128, 128, 128), 1)
    $penBlackInner = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(0, 0, 0), 1)
    $penWhiteOuter = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255), 1)
    $penLightInner = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(223, 223, 223), 1)
    # Buitenste rand: grijs boven/links, wit rechts/onder
    $g.DrawLine($penDarkOuter,  0, 0, $w, 0)
    $g.DrawLine($penDarkOuter,  0, 0, 0, $h)
    $g.DrawLine($penWhiteOuter, $w, 0, $w, $h)
    $g.DrawLine($penWhiteOuter, 0, $h, $w, $h)
    # Binnenste rand: zwart boven/links, lichtgrijs rechts/onder
    $g.DrawLine($penBlackInner, 1, 1, $w-1, 1)
    $g.DrawLine($penBlackInner, 1, 1, 1, $h-1)
    $g.DrawLine($penLightInner, $w-1, 1, $w-1, $h-1)
    $g.DrawLine($penLightInner, 1, $h-1, $w-1, $h-1)
    $penDarkOuter.Dispose(); $penBlackInner.Dispose()
    $penWhiteOuter.Dispose(); $penLightInner.Dispose()
})
$script:leftPanel.Controls.Add($pnlInfo)
$script:fullWidthCtrls.Add($pnlInfo)

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
    $lbl.Size      = New-Object System.Drawing.Size(320, 22)
    $Panel.Controls.Add($lbl)
    return @{ Icon = $pb; Label = $lbl }
}

$rowY      = 0..($INFO_ROWS - 1) | ForEach-Object { $INFO_PAD_T + $_ * $INFO_ROW_H }
$rowWin    = New-InfoRow $pnlInfo $rowY[0]
$rowAct    = New-InfoRow $pnlInfo $rowY[1]
$rowTpm    = New-InfoRow $pnlInfo $rowY[2]
$rowBoot   = New-InfoRow $pnlInfo $rowY[3]
$rowNet    = New-InfoRow $pnlInfo $rowY[4]
$rowHP     = New-InfoRow $pnlInfo $rowY[5]
$rowLaptop = New-InfoRow $pnlInfo $rowY[6]
$rowWifi   = New-InfoRow $pnlInfo $rowY[7]

# Overall status label – groot symbool rechts in het info panel
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Font      = New-Object System.Drawing.Font("Segoe UI Emoji", 36, [System.Drawing.FontStyle]::Regular)
$lblStatus.Location  = New-Object System.Drawing.Point(338, 10)
$lblStatus.Size      = New-Object System.Drawing.Size(75, 150)
$lblStatus.TextAlign = 'MiddleCenter'
$lblStatus.BackColor = [System.Drawing.Color]::Transparent
$lblStatus.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$lblStatus.Text      = ''
$pnlInfo.Controls.Add($lblStatus)

# ── Easter egg: 6x klik op 👍 → 👌 ──────────────────────────────
$script:eggThumbClicks = 0
$script:eggThumbActive = $false
$lblStatus.Cursor = [System.Windows.Forms.Cursors]::Hand
$lblStatus.Add_Click({
    if ($lblStatus.Text -ne [System.Char]::ConvertFromUtf32(0x1F44D)) { return }
    $script:eggThumbClicks++
    if ($script:eggThumbClicks -ge 6) {
        $script:eggThumbClicks = 0
        $script:eggThumbActive = $true
        $lblStatus.Text      = [System.Char]::ConvertFromUtf32(0x1F44C)
        $lblStatus.ForeColor = $clrAccent
        $script:timerEgg = New-Object System.Windows.Forms.Timer
        $script:timerEgg.Interval = 3000
        $script:timerEgg.Add_Tick({
            $script:eggThumbActive = $false
            Display-AllGoodThumb
            $script:timerEgg.Stop()
            $script:timerEgg.Dispose()
        })
        $script:timerEgg.Start()
    }
})

$lblWindowsVersion   = $rowWin.Label
$lblActivationState  = $rowAct.Label
$lblTpmStatus        = $rowTpm.Label
$lblSecureBootStatus = $rowBoot.Label

# ── Knop helper ──────────────────────────────────────────────────
function New-EOOButton {
    param([string]$Text, [int]$X, [int]$Y,
          [int]$W = 420, [int]$H = 28,
          $BgColor = $null, $HoverBg = $null, $HoverFg = $null)
    if ($null -eq $BgColor) { $BgColor  = $clrBtnBg }
    if ($null -eq $HoverBg) { $HoverBg  = $clrBtnHover }
    if ($null -eq $HoverFg) { $HoverFg  = $clrBtnHoverFg }

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text      = $Text
    $btn.Font      = $fntBtn
    $btn.ForeColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
    $btn.BackColor = [System.Drawing.Color]::FromArgb(192, 192, 192)
    $btn.FlatStyle = 'Flat'
    $btn.FlatAppearance.BorderColor        = [System.Drawing.Color]::FromArgb(0, 0, 0)
    $btn.FlatAppearance.BorderSize         = 1
    $btn.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(0, 0, 128)
    $btn.Location  = New-Object System.Drawing.Point($X, $Y)
    $btn.Size      = New-Object System.Drawing.Size($W, $H)
    $btn.Cursor    = [System.Windows.Forms.Cursors]::Default
    $btn.TextAlign = 'MiddleLeft'
    $btn.Padding   = New-Object System.Windows.Forms.Padding(4, 0, 0, 0)

    $capturedFg  = [System.Drawing.Color]::FromArgb($HoverFg.A, $HoverFg.R, $HoverFg.G, $HoverFg.B)
    $capturedDim = [System.Drawing.Color]::FromArgb(0, 0, 0)
    $btn.Add_MouseEnter([scriptblock]::Create('$this.ForeColor = [System.Drawing.Color]::FromArgb(' + $capturedFg.A + ',' + $capturedFg.R + ',' + $capturedFg.G + ',' + $capturedFg.B + ')'))
    $btn.Add_MouseLeave([scriptblock]::Create('$this.ForeColor = [System.Drawing.Color]::FromArgb(' + $capturedDim.A + ',' + $capturedDim.R + ',' + $capturedDim.G + ',' + $capturedDim.B + ')'))
    $script:leftPanel.Controls.Add($btn)
    return $btn
}

# Voeg icoon toe aan knop – direct als Button.Image (geen Z-order problemen)
function Add-BtnIcon {
    param($Btn, [System.Drawing.Bitmap]$Bmp)
    $Btn.Image             = $Bmp
    $Btn.ImageAlign        = 'MiddleLeft'
    $Btn.TextImageRelation = 'ImageBeforeText'
}

function New-SectionLabel {
    param([string]$Text, [int]$Y)
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text      = $Text
    $lbl.Font      = $fntSection
    $lbl.ForeColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
    $lbl.BackColor = [System.Drawing.Color]::Transparent
    $lbl.Location  = New-Object System.Drawing.Point(22, $Y)
    $lbl.AutoSize  = $true
    $script:leftPanel.Controls.Add($lbl)
    # Win95 raised scheidslijn (grijs boven, wit onder)
    $line = New-Object System.Windows.Forms.Panel
    $line.BackColor = [System.Drawing.Color]::FromArgb(128, 128, 128)
    $line.Location  = New-Object System.Drawing.Point(22, ($Y + 16))
    $line.Size      = New-Object System.Drawing.Size(420, 1)
    $script:leftPanel.Controls.Add($line)
    $script:sectionDividers.Add($line)
    $line2 = New-Object System.Windows.Forms.Panel
    $line2.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
    $line2.Location  = New-Object System.Drawing.Point(22, ($Y + 17))
    $line2.Size      = New-Object System.Drawing.Size(420, 1)
    $script:leftPanel.Controls.Add($line2)
    $script:sectionDividers.Add($line2)
}

# ── Sectie: Systeem ──────────────────────────────────────────────
New-SectionLabel 'Systeem' $SECT_Y

$btnRestart = New-EOOButton 'Restart' 22 ($SECT_Y + 24) 196 34
Add-BtnIcon $btnRestart (New-RestartBitmap $clrAccentDim)
$btnRestart.Add_Click({
    Write-Console 'Systeem wordt herstart...' 'start'
    Start-Process PowerShell -ArgumentList '-Command shutdown.exe /r /t 0' -NoNewWindow
})

$btnShutdown = New-EOOButton 'Shutdown' 226 ($SECT_Y + 24) 196 34 $clrBtnBg $clrDanger ([System.Drawing.Color]::White)
$btnShutdown.FlatAppearance.MouseOverBackColor = $clrDanger
$shutdownWhite = [System.Drawing.Color]::White
$btnShutdown.Add_MouseEnter({ $this.ForeColor = $shutdownWhite })
$btnShutdown.Add_MouseLeave({ $this.ForeColor = $clrAccentDim })
Add-BtnIcon $btnShutdown (New-PowerBitmap $clrAccentDim)
$btnShutdown.Add_Click({
    Write-Console 'Systeem wordt afgesloten...' 'start'
    Start-Process PowerShell -ArgumentList '-Command shutdown.exe /s /t 0' -NoNewWindow
})

$btnWU = New-EOOButton 'Windows Update openen' 22 ($SECT_Y + 70)
Add-BtnIcon $btnWU (New-WindowsBitmap $clrAccent)
$script:fullWidthCtrls.Add($btnWU)
$btnWU.Add_Click({
    Write-Console 'Windows Update instellingen openen...' 'start'
    Start-Process 'ms-settings:windowsupdate'
})

$btnDM = New-EOOButton 'Apparaatbeheer openen' 22 ($SECT_Y + 112)
Add-BtnIcon $btnDM (New-GearBitmap $clrAccent)
$script:fullWidthCtrls.Add($btnDM)
$btnDM.Add_Click({
    Write-Console 'Apparaatbeheer openen...' 'start'
    Start-Process 'devmgmt.msc'
})

$btnAW = New-EOOButton 'Windows activeren' 22 ($SECT_Y + 154)
Add-BtnIcon $btnAW (New-KeyBitmap $clrAccent)
$script:fullWidthCtrls.Add($btnAW)
$btnAW.Add_Click({
    Write-Console 'Windows activeringsscherm openen...' 'start'
    Start-Process "C:\Windows\System32\slui.exe"
})

$btnWifi = New-EOOButton 'WiFi instellen: WIFI EOO_Install' 22 ($SECT_Y + 196)
Add-BtnIcon $btnWifi (New-WifiBitmap $clrAccent)
$script:fullWidthCtrls.Add($btnWifi)
$btnWifi.Add_Click({
    $script:btnWifi.Enabled = $false
    Write-Console 'WiFi profiel toevoegen...' 'start'
    $ssid = 'WIFI EOO_Install'
    $pw   = 'House-Earth-Wealth-Repair-8'
    $xml  = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
  <name>$ssid</name>
  <SSIDConfig><SSID><name>$ssid</name></SSID></SSIDConfig>
  <connectionType>ESS</connectionType>
  <connectionMode>auto</connectionMode>
  <MSM>
    <security>
      <authEncryption>
        <authentication>WPA2PSK</authentication>
        <encryption>AES</encryption>
        <useOneX>false</useOneX>
      </authEncryption>
      <sharedKey>
        <keyType>passPhrase</keyType>
        <protected>false</protected>
        <keyMaterial>$pw</keyMaterial>
      </sharedKey>
    </security>
  </MSM>
</WLANProfile>
"@
    $tmp = "$env:TEMP\EOO_WiFi.xml"
    [System.IO.File]::WriteAllText($tmp, $xml, [System.Text.Encoding]::UTF8)
    $out = & netsh wlan add profile filename="$tmp" user=all 2>&1
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    if ($LASTEXITCODE -eq 0) {
        Write-Console "[OK] WiFi profiel '$ssid' toegevoegd." 'ok'
    } else {
        Write-Console "FOUT: $out" 'error'
    }
    $script:btnWifi.Enabled = $true
})

# ── Productsleutel invoer ────────────────────────────────────────
$lblKeyInput = New-Object System.Windows.Forms.Label
$lblKeyInput.Text      = 'Productsleutel:'
$lblKeyInput.Font      = $fntSection
$lblKeyInput.ForeColor = $clrAccent
$lblKeyInput.Location  = New-Object System.Drawing.Point(22, ($SECT_Y + 248))
$lblKeyInput.AutoSize  = $true
$script:leftPanel.Controls.Add($lblKeyInput)

$txtKey = New-Object System.Windows.Forms.TextBox
$txtKey.Font        = New-Object System.Drawing.Font("Courier New", 9)
$txtKey.ForeColor   = [System.Drawing.Color]::FromArgb(0, 0, 0)
$txtKey.BackColor   = [System.Drawing.Color]::FromArgb(255, 255, 255)
$txtKey.BorderStyle = 'Fixed3D'
$txtKey.MaxLength   = 29
$txtKey.Location    = New-Object System.Drawing.Point(22, ($SECT_Y + 268))
$txtKey.Size        = New-Object System.Drawing.Size(290, 26)
$txtKey.CharacterCasing = 'Upper'
$txtKey.Text        = ''
$script:leftPanel.Controls.Add($txtKey)

$btnActivateKey = New-EOOButton 'Activeren met sleutel' 22 ($SECT_Y + 308) 420 34 $clrBtnBg $clrGreen ([System.Drawing.Color]::White)
Add-BtnIcon $btnActivateKey (New-KeyBitmap $clrAccent)
$script:fullWidthCtrls.Add($btnActivateKey)
$btnActivateKey.Add_Click({
    $key = $txtKey.Text.Trim()
    if ($key -notmatch '^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$') {
        Write-Console 'Voer een geldige productsleutel in (XXXXX-XXXXX-XXXXX-XXXXX-XXXXX).' 'error'
        return
    }
    $script:btnActivateKey.Enabled = $false
    Write-Console "Productsleutel installeren: $key" 'start'

    $script:jobActivate = Start-Job -ScriptBlock {
        param($key)
        $r1 = & cscript.exe //B "$env:windir\system32\slmgr.vbs" /ipk $key 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Sleutel installeren mislukt: $r1" }
        Write-Output "[1/2] Sleutel geinstalleerd."
        $r2 = & cscript.exe //B "$env:windir\system32\slmgr.vbs" /ato 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Activatie mislukt: $r2" }
        Write-Output "[OK] Windows succesvol geactiveerd."
    } -ArgumentList $key

    $script:timerActivate = New-Object System.Windows.Forms.Timer
    $script:timerActivate.Interval = 500
    $script:timerActivate.Add_Tick({
        foreach ($line in ($script:jobActivate.ChildJobs[0].Output.ReadAll())) {
            if ($line -match '^\[OK\]') { Write-Console $line 'ok' } else { Write-Console $line 'info' }
        }
        foreach ($err in ($script:jobActivate.ChildJobs[0].Error.ReadAll())) {
            Write-Console "FOUT: $($err.Exception.Message)" 'error'
        }
        if ($script:jobActivate.State -in 'Completed','Failed') {
            $script:timerActivate.Stop(); $script:timerActivate.Dispose()
            if ($script:jobActivate.State -eq 'Failed') {
                Write-Console "FOUT: $($script:jobActivate.ChildJobs[0].JobStateInfo.Reason.Message)" 'error'
            } else {
                Update-InfoPanel
            }
            Remove-Job $script:jobActivate -Force
            $script:btnActivateKey.Enabled = $true
        }
    })
    $script:timerActivate.Start()
})

# ── Sectie: Drivers ──────────────────────────────────────────────
New-SectionLabel 'Drivers' ($SECT_Y + 366)

$btnLSU = New-EOOButton 'Lenovo System Update installeren' 22 ($SECT_Y + 390)
Add-BtnIcon $btnLSU (New-ArrowBitmap $clrAccent)
$script:fullWidthCtrls.Add($btnLSU)
$btnLSU.Add_Click({
    $script:btnLSU.Enabled = $false
    $script:lsuSignal = $null
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
            if     ($line -match '^SIGNAL:')     { $script:lsuSignal = $line }
            elseif ($line -match '^\[OK\]')      { Write-Console $line 'ok' }
            elseif ($line -match 'FOUT|mislukt') { Write-Console $line 'error' }
            else                                 { Write-Console $line 'info' }
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
                if ($script:lsuSignal -match '^SIGNAL:UPTODATE') {
                    Write-Console 'Al up-to-date, geen actie nodig.' 'ok'
                } elseif ($script:lsuSignal -match '^SIGNAL:TVSU:(.+)') {
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

$btnHPIA = New-EOOButton 'HP Image Assistant installeren en draaien' 22 ($SECT_Y + 432)
Add-BtnIcon $btnHPIA (New-ArrowBitmap $clrAccent)
$script:fullWidthCtrls.Add($btnHPIA)
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
New-SectionLabel 'Autopilot' ($SECT_Y + 488)

$btnHWIDOvr = New-EOOButton 'HWID Export - Overwrite (per device)' 22 ($SECT_Y + 512)
Add-BtnIcon $btnHWIDOvr (New-DownArrowBitmap $clrAccent)
$script:fullWidthCtrls.Add($btnHWIDOvr)
$btnHWIDOvr.Add_Click({
    Write-Console 'HWID Export (Overwrite) wordt gestart...' 'start'
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot + '\' } else { (Split-Path -Parent $MyInvocation.ScriptName) + '\' }
    $p = Write-TempScript -Content ($script_HWID_Overwrite -replace '##SCRIPTDIR##', $scriptDir) -Filename 'EOO_Get-HWID.cmd'
    Start-Process 'cmd.exe' -ArgumentList "/k `"$p`"" -Verb RunAs
    Write-Console 'HWID Export: voer GroupTag in het geopende venster in.' 'info'
})

$btnHWIDApp = New-EOOButton 'HWID Export - Append (bulk CSV)' 22 ($SECT_Y + 554)
Add-BtnIcon $btnHWIDApp (New-DownArrowBitmap $clrAccent)
$script:fullWidthCtrls.Add($btnHWIDApp)
$btnHWIDApp.Add_Click({
    Write-Console 'HWID Export (Append) wordt gestart...' 'start'
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot + '\' } else { (Split-Path -Parent $MyInvocation.ScriptName) + '\' }
    $p = Write-TempScript -Content ($script_HWID_Append -replace '##SCRIPTDIR##', $scriptDir) -Filename 'EOO_Get-HWID_Aanvullen.cmd'
    Start-Process 'cmd.exe' -ArgumentList "/k `"$p`"" -Verb RunAs
    Write-Console 'HWID Export: voer GroupTag in het geopende venster in.' 'info'
})

# ── Console output panel (rechterkolom – in splitMain.Panel2) ────
$lblConsoleHdr = New-Object System.Windows.Forms.Label
$lblConsoleHdr.Text      = 'Log'
$lblConsoleHdr.Font      = New-Object System.Drawing.Font("Microsoft Sans Serif", 8, [System.Drawing.FontStyle]::Bold)
$lblConsoleHdr.ForeColor = [System.Drawing.Color]::FromArgb(192, 192, 192)
$lblConsoleHdr.BackColor = [System.Drawing.Color]::Transparent
$lblConsoleHdr.Location  = New-Object System.Drawing.Point(4, 4)
$lblConsoleHdr.AutoSize  = $true
$splitMain.Panel2.Controls.Add($lblConsoleHdr)

$txtConsole = New-Object System.Windows.Forms.RichTextBox
$txtConsole.Location    = New-Object System.Drawing.Point(0, 22)
$txtConsole.Size        = New-Object System.Drawing.Size($splitMain.Panel2.Width, ($splitMain.Panel2.Height - 22))
$txtConsole.BackColor   = [System.Drawing.Color]::FromArgb(0, 0, 0)
$txtConsole.ForeColor   = [System.Drawing.Color]::FromArgb(192, 192, 192)
$txtConsole.Font        = New-Object System.Drawing.Font("Courier New", 8)
$txtConsole.ReadOnly    = $true
$txtConsole.BorderStyle = 'None'
$txtConsole.ScrollBars  = 'Vertical'
$txtConsole.WordWrap    = $true
$txtConsole.Anchor      = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$splitMain.Panel2.Controls.Add($txtConsole)

function Write-Console {
    param([string]$Message, [string]$Type = 'info')
    $time = Get-Date -Format 'HH:mm:ss'
    $txtConsole.SelectionStart = $txtConsole.TextLength
    $txtConsole.SelectionLength = 0
    switch ($Type) {
        'ok'    { $txtConsole.SelectionColor = [System.Drawing.Color]::FromArgb(0, 255, 0) }
        'error' { $txtConsole.SelectionColor = [System.Drawing.Color]::FromArgb(255, 85, 85) }
        'start' { $txtConsole.SelectionColor = [System.Drawing.Color]::FromArgb(255, 255, 85) }
        default { $txtConsole.SelectionColor = [System.Drawing.Color]::FromArgb(192, 192, 192) }
    }
    $txtConsole.AppendText("[$time] $Message`n")
    $txtConsole.ScrollToCaret()
}

# ── Footer inhoud ────────────────────────────────────────────────
# Win95 footer: grijs boven (schaduw), wit daarboven (highlight) = raised rand
$pnlFooterLine = New-Object System.Windows.Forms.Panel
$pnlFooterLine.Dock      = 'Top'
$pnlFooterLine.Height    = 1
$pnlFooterLine.BackColor = [System.Drawing.Color]::FromArgb(128, 128, 128)
$pnlFooter.Controls.Add($pnlFooterLine)
$pnlFooterLine2 = New-Object System.Windows.Forms.Panel
$pnlFooterLine2.Dock      = 'Top'
$pnlFooterLine2.Height    = 1
$pnlFooterLine2.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$pnlFooter.Controls.Add($pnlFooterLine2)

$lblFooter = New-Object System.Windows.Forms.Label
$lblFooter.Text      = 'Easy Office Online  |  eoo.nl'
$lblFooter.Font      = $fntSub
$lblFooter.ForeColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
$lblFooter.BackColor = [System.Drawing.Color]::Transparent
$lblFooter.Location  = New-Object System.Drawing.Point(8, 8)
$lblFooter.AutoSize  = $true
$pnlFooter.Controls.Add($lblFooter)

$lblDate = New-Object System.Windows.Forms.Label
$lblDate.Text      = (Get-Date -Format 'dd-MM-yyyy')
$lblDate.Font      = $fntSub
$lblDate.ForeColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
$lblDate.BackColor = [System.Drawing.Color]::Transparent
$lblDate.Location  = New-Object System.Drawing.Point(($pnlFooter.Width - 100), 8)
$lblDate.AutoSize  = $true
$lblDate.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
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

function Display-HPBloatware {
    $hpBloatNames = @(
        'HP Wolf Security',
        'HP Wolf Security Application Support for Chrome',
        'HP Wolf Security Application Support for Windows',
        'HP Sure Click',
        'HP Sure Sense',
        'HP Sure Connect',
        'HP Sure Start',
        'HP Sure View',
        'HP Support Assistant',
        'HP Jumpstart',
        'HP Instant Ink',
        'HP Audio Switch',
        'HP Documentation',
        'HP Notifications',
        'HP PC Hardware Diagnostics',
        'HP Privacy Settings',
        'HP Smart',
        'myHP',
        'Poly Lens',
        'HP LAN/WLAN Management'
    )

    $regPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    $found = @()
    $regApps = Get-ItemProperty $regPaths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName }
    foreach ($app in $regApps) {
        foreach ($bloat in $hpBloatNames) {
            if ($app.DisplayName -like "*$bloat*") {
                $found += $app.DisplayName
                break
            }
        }
    }
    try {
        $uwp = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue |
            Where-Object { $_.Publisher -like '*HP Inc*' -or $_.Publisher -like '*Hewlett*' }
        foreach ($app in $uwp) { $found += $app.Name }
    } catch {}

    if ($found.Count -eq 0) {
        Set-InfoRow $rowHP -Text 'Geen HP bloatware gevonden' -OK $true
    } else {
        Set-InfoRow $rowHP -Text "HP bloatware: $($found.Count) app(s) gevonden" -OK $false
    }
    $script:hpBloatFound = $found
}

function Display-LaptopType {
    try {
        $chassisTypes = (Get-CimInstance Win32_SystemEnclosure).ChassisTypes
        $laptopTypes  = @(8, 9, 10, 11, 12, 14, 18, 21, 30, 31, 32)
        $isLaptop     = $chassisTypes | Where-Object { $_ -in $laptopTypes }
        if ($isLaptop) {
            $rowLaptop.Label.Text      = 'Apparaattype: Laptop'
            $rowLaptop.Label.ForeColor = $clrSubText
            $rowLaptop.Icon.Image      = New-CheckBitmap $clrAccent
        } else {
            $rowLaptop.Label.Text      = 'Apparaattype: Desktop'
            $rowLaptop.Label.ForeColor = $clrSubText
            $rowLaptop.Icon.Image      = New-CheckBitmap $clrAccent
        }
        $script:isLaptopDevice = [bool]$isLaptop
    } catch {
        $rowLaptop.Label.Text      = 'Apparaattype: onbekend'
        $rowLaptop.Label.ForeColor = $clrSubText
        $rowLaptop.Icon.Image      = $null
        $script:isLaptopDevice = $false
    }
}

function Display-WifiAdapter {
    try {
        $wifi = Get-NetAdapter -Physical -ErrorAction SilentlyContinue |
                Where-Object { $_.MediaType -eq '802.11' -or $_.InterfaceDescription -match 'wi.?fi|wireless|802\.11' }
        if ($wifi) {
            $name = ($wifi | Select-Object -First 1).InterfaceDescription
            Set-InfoRow $rowWifi -Text "WiFi adapter aanwezig: $name" -OK $true
            $script:okWifi = $true
        } else {
            Set-InfoRow $rowWifi -Text 'Geen WiFi adapter gevonden' -OK $false
            $script:okWifi = $false
        }
    } catch {
        Set-InfoRow $rowWifi -Text 'WiFi adapter: controlefout' -OK $false
        $script:okWifi = $false
    }
}

function Display-AllGoodThumb {
    if ($script:eggThumbActive) { return }
    if ($script:okActivation -and $script:okTpm -and $script:okSecureBoot -and $script:okInternet) {
        $lblStatus.Text      = [System.Char]::ConvertFromUtf32(0x1F44D)
        $lblStatus.ForeColor = $clrGreen
    } else {
        $lblStatus.Text      = '!'
        $lblStatus.Font      = New-Object System.Drawing.Font("Segoe UI Emoji", 52, [System.Drawing.FontStyle]::Regular)
        $lblStatus.ForeColor = $clrDanger
    }
}

function Update-InfoPanel {
    Display-WindowsVersion
    Display-ActivationStatus
    Display-TpmStatus
    Display-SecureBootStatus
    Display-InternetStatus
    Display-HPBloatware
    Display-LaptopType
    Display-WifiAdapter
    Display-AllGoodThumb
}

$btnRefreshInfo = New-Object System.Windows.Forms.Button
$btnRefreshInfo.Text      = 'Vernieuwen'
$btnRefreshInfo.Font      = $fntSub
$btnRefreshInfo.ForeColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
$btnRefreshInfo.BackColor = [System.Drawing.Color]::FromArgb(192, 192, 192)
$btnRefreshInfo.FlatStyle = 'Flat'
$btnRefreshInfo.FlatAppearance.BorderColor        = [System.Drawing.Color]::FromArgb(0, 0, 0)
$btnRefreshInfo.FlatAppearance.BorderSize         = 1
$btnRefreshInfo.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(0, 0, 128)
$btnRefreshInfo.Location  = New-Object System.Drawing.Point(278, ($INFO_PAD_T + $INFO_ROWS * $INFO_ROW_H + 8))
$btnRefreshInfo.Size      = New-Object System.Drawing.Size(134, 24)
$btnRefreshInfo.Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
$btnRefreshInfo.Cursor    = [System.Windows.Forms.Cursors]::Default
$btnRefreshInfo.TextAlign = 'MiddleCenter'
$btnRefreshInfo.Add_MouseEnter({ $this.ForeColor = [System.Drawing.Color]::White })
$btnRefreshInfo.Add_MouseLeave({ $this.ForeColor = [System.Drawing.Color]::FromArgb(0, 0, 0) })
$btnRefreshInfo.Add_Click({ Update-InfoPanel })
$pnlInfo.Controls.Add($btnRefreshInfo)

Update-InfoPanel

Write-Console 'Systeemcontrole uitgevoerd.' 'info'
Write-Console "Windows activatie: $(if ($script:okActivation) { 'OK' } else { 'NIET geactiveerd' })" $(if ($script:okActivation) { 'ok' } else { 'error' })
Write-Console "TPM: $(if ($script:okTpm) { 'OK' } else { 'NIET gevonden' })" $(if ($script:okTpm) { 'ok' } else { 'error' })
Write-Console "Secure Boot: $(if ($script:okSecureBoot) { 'OK' } else { 'NIET ingeschakeld' })" $(if ($script:okSecureBoot) { 'ok' } else { 'error' })
Write-Console "Internet: $(if ($script:okInternet) { 'OK' } else { 'GEEN verbinding' })" $(if ($script:okInternet) { 'ok' } else { 'error' })
if ($script:hpBloatFound.Count -gt 0) {
    Write-Console "HP bloatware ($($script:hpBloatFound.Count) app(s)):" 'error'
    foreach ($item in $script:hpBloatFound) { Write-Console "  - $item" 'error' }
} else {
    Write-Console 'HP bloatware: geen gevonden' 'ok'
}

# ── Versiecheck via GitHub ────────────────────────────────────────
function Start-VersionCheck {
    $script:timerVersionCheck          = New-Object System.Windows.Forms.Timer
    $script:timerVersionCheck.Interval = 2000
    $script:timerVersionCheck.Add_Tick({
        $script:timerVersionCheck.Stop()
        try {
            $raw = (Invoke-WebRequest -Uri $script:githubScriptUrl -UseBasicParsing).Content
            if ($raw -match '\$script:currentVersion\s*=\s*\[System\.Version\]''([\d\.]+)''') {
                $script:remoteVersion = [System.Version]$matches[1]
                if ($script:remoteVersion -gt $script:currentVersion) {
                    $script:btnUpdate.Text    = "Update v$script:remoteVersion"
                    $script:btnUpdate.Visible = $true
                    $lblVersion.ForeColor     = [System.Drawing.Color]::FromArgb(255, 200, 0)
                }
            }
        } catch { }
        $script:timerVersionCheck.Dispose()
        $script:timerVersionCheck = $null
    })
    $script:timerVersionCheck.Start()
}

[void]$form.ShowDialog()
