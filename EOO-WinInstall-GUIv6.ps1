# ════════════════════════════════════════════════════════════════
#  EOO – Hulp bij Windows installaties  |  Portable editie
#  Opslaan als: UTF-8 with BOM  (VS Code: "Save with Encoding" > UTF-8 BOM)
# ════════════════════════════════════════════════════════════════
# ── Versie (hier aanpassen bij nieuwe release) ───────────────────
$script:currentVersion = [System.Version]'6.1'
$script:versionName    = 'Pizza Funghi'

# ── Azure Files configuratie (hier aanpassen) ─────────────────────
$script:afStorageAccount = 'staceoosupportools'
$script:afShareName      = 'eoo-support-tools'
$script:afKey            = '7wa9oZJDVh+cTcYDiOPOB1WCE0TEzpYe/BaqQlLA85jKga3g7AKC0zMjgYlTTjgVRgTuvfxpdnJq+AStoXQFlA=='

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
$ErrorActionPreference = 'Stop'
$GroupTag = Read-Host 'Voer GroupTag in (bijv: EOO-W11-FLEX)'
if (-not $GroupTag) { Write-Host 'Geen GroupTag opgegeven. Stop.' -ForegroundColor Red; Read-Host; exit 1 }
$storageAccount = '##STORAGEACCOUNT##'
$shareName      = '##SHARENAME##'
$key            = '##KEY##'
$file   = "$env:TEMP\Autopilot-$env:COMPUTERNAME.csv"
try {
    Write-Host "HWID ophalen..."
    $serial = (Get-CimInstance Win32_BIOS).SerialNumber
    $dev    = Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_DevDetail_Ext01 -ErrorAction Stop
    $hash   = $dev.DeviceHardwareData
    if (-not $hash) { throw 'Hardware hash niet gevonden.' }
    $header = 'Device Serial Number,Windows Product ID,Hardware Hash,Group Tag,Assigned User'
    $line   = $serial + ',,' + $hash + ',' + $GroupTag + ','
    Set-Content -Path $file -Value $header -Encoding UTF8
    Add-Content -Path $file -Value $line   -Encoding UTF8
    Write-Host "CSV aangemaakt: $file"
    Write-Host "Uploaden naar Azure Files..."
    if (-not (Test-Path 'X:\')) {
        Get-SmbMapping -ErrorAction SilentlyContinue | Where-Object { $_.RemotePath -like "\\$storageAccount.file.core.windows.net\*" } | ForEach-Object {
            Remove-SmbMapping -LocalPath $_.LocalPath -Force -UpdateProfile -ErrorAction SilentlyContinue
        }
        try {
            New-SmbMapping -LocalPath 'X:' -RemotePath "\\$storageAccount.file.core.windows.net\$shareName" -UserName "Azure\$storageAccount" -Password $key -Persistent $false -ErrorAction Stop | Out-Null
        } catch {
            throw "Kan Azure Files share niet bereiken. Controleer poort 445. ($_)"
        }
    }
    if (-not (Test-Path 'X:\HWID')) { New-Item -ItemType Directory -Path 'X:\HWID' | Out-Null }
    Copy-Item -Path $file -Destination "X:\HWID\$env:COMPUTERNAME.csv" -Force
    Write-Host "OK: HWID gekopieerd naar Azure Files map HWID." -ForegroundColor Green
} catch {
    Write-Host "FOUT: $_" -ForegroundColor Red
}
Read-Host "Druk op Enter om te sluiten"
'@

$script_HWID_Append = @'
$ErrorActionPreference = 'Stop'
$GroupTag = Read-Host 'Voer GroupTag in (bijv: EOO-W11-FLEX)'
if (-not $GroupTag) { Write-Host 'Geen GroupTag opgegeven. Stop.' -ForegroundColor Red; Read-Host; exit 1 }
$BatchName = Read-Host 'Voer batch naam in (bijv: Batch-01 of School-A)'
if (-not $BatchName) { Write-Host 'Geen batch naam opgegeven. Stop.' -ForegroundColor Red; Read-Host; exit 1 }
$storageAccount = '##STORAGEACCOUNT##'
$shareName      = '##SHARENAME##'
$key            = '##KEY##'
$file = "$env:TEMP\Autopilot-$BatchName.csv"
try {
    Write-Host "HWID ophalen..."
    $serial = (Get-CimInstance Win32_BIOS).SerialNumber
    $dev    = Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_DevDetail_Ext01 -ErrorAction Stop
    $hash   = $dev.DeviceHardwareData
    if (-not $hash) { throw 'Hardware hash niet gevonden.' }
    $header = 'Device Serial Number,Windows Product ID,Hardware Hash,Group Tag,Assigned User'
    $line   = $serial + ',,' + $hash + ',' + $GroupTag + ','
    if (-not (Test-Path $file)) { Set-Content -Path $file -Value $header -Encoding UTF8 }
    Add-Content -Path $file -Value $line -Encoding UTF8
    Write-Host "Regel toegevoegd aan: $file"
    Write-Host "Uploaden naar Azure Files..."
    if (-not (Test-Path 'X:\')) {
        Get-SmbMapping -ErrorAction SilentlyContinue | Where-Object { $_.RemotePath -like "\\$storageAccount.file.core.windows.net\*" } | ForEach-Object {
            Remove-SmbMapping -LocalPath $_.LocalPath -Force -UpdateProfile -ErrorAction SilentlyContinue
        }
        try {
            New-SmbMapping -LocalPath 'X:' -RemotePath "\\$storageAccount.file.core.windows.net\$shareName" -UserName "Azure\$storageAccount" -Password $key -Persistent $false -ErrorAction Stop | Out-Null
        } catch {
            throw "Kan Azure Files share niet bereiken. Controleer poort 445. ($_)"
        }
    }
    if (-not (Test-Path 'X:\HWID')) { New-Item -ItemType Directory -Path 'X:\HWID' | Out-Null }
    Copy-Item -Path $file -Destination "X:\HWID\$BatchName.csv" -Force
    Write-Host "OK: Bulk CSV gekopieerd naar Azure Files map HWID als $BatchName.csv." -ForegroundColor Green
} catch {
    Write-Host "FOUT: $_" -ForegroundColor Red
}
Read-Host "Druk op Enter om te sluiten"
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


# Cloud/opslag (16x16) voor Azure schijfkoppeling
function New-CloudBitmap {
    param([System.Drawing.Color]$Color)
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $g.FillEllipse($brush, 1,  7, 6, 6)
    $g.FillEllipse($brush, 8,  8, 6, 5)
    $g.FillEllipse($brush, 4,  4, 8, 8)
    $rect = New-Object System.Drawing.Rectangle(2, 10, 12, 3)
    $g.FillRectangle($brush, $rect)
    $brush.Dispose(); $g.Dispose()
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
$pnlHeader.add_Paint(({
    param($s, $e)
    $g    = $e.Graphics
    $w    = [int]$pnlHeader.Width
    $h    = ([int]$pnlHeader.Height) - 4
    $rect  = [System.Drawing.Rectangle]::new(0, 0, $w, $h)
    $clrL  = [System.Drawing.Color]::FromArgb(0, 128, 128)
    $clrR  = [System.Drawing.Color]::FromArgb(0, 160, 160)
    $mode  = [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal
    $brush = [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, $clrL, $clrR, $mode)
    $g.FillRectangle($brush, $rect)
    $brush.Dispose()
}).GetNewClosure())
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
$pnlInfo.add_Paint(({
    param($s, $e)
    $g = $e.Graphics
    $w = [int]$pnlInfo.Width - 1
    $h = [int]$pnlInfo.Height - 1
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
}).GetNewClosure())
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
    $ssid = 'EOO_Install'
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
    Write-Console 'HWID Export + Azure Files Upload (Overwrite) wordt gestart...' 'start'
    $content = $script_HWID_Overwrite.Replace('##STORAGEACCOUNT##', $script:afStorageAccount).Replace('##SHARENAME##', $script:afShareName).Replace('##KEY##', $script:afKey)
    $p = Write-TempScript -Content $content -Filename 'EOO_Get-HWID.ps1'
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$p`"" -Verb RunAs
    Write-Console "HWID Azure Files Upload (Overwrite) gestart." 'info'
})

$btnHWIDApp = New-EOOButton 'HWID Export - Append (bulk CSV)' 22 ($SECT_Y + 554)
Add-BtnIcon $btnHWIDApp (New-DownArrowBitmap $clrAccent)
$script:fullWidthCtrls.Add($btnHWIDApp)
$btnHWIDApp.Add_Click({
    Write-Console 'HWID Export + Azure Files Upload (Append) wordt gestart...' 'start'
    $content = $script_HWID_Append.Replace('##STORAGEACCOUNT##', $script:afStorageAccount).Replace('##SHARENAME##', $script:afShareName).Replace('##KEY##', $script:afKey)
    $p = Write-TempScript -Content $content -Filename 'EOO_Get-HWID_Aanvullen.ps1'
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$p`"" -Verb RunAs
    Write-Console "HWID Azure Files Upload (Append) gestart." 'info'
})

# ── Sectie: Azure opslag ─────────────────────────────────────────
New-SectionLabel 'Azure opslag' ($SECT_Y + 596)

$script:btnAzureMount = New-EOOButton 'Azure opslag koppelen (X:)' 22 ($SECT_Y + 620)
Add-BtnIcon $script:btnAzureMount (New-CloudBitmap $clrAccent)
$script:fullWidthCtrls.Add($script:btnAzureMount)
$script:btnAzureMount.Add_Click({
    $script:btnAzureMount.Enabled = $false
    Write-Console '─── Azure opslag koppelen ───' 'start'
    Write-Console "  Storage account : $($script:afStorageAccount)" 'info'
    Write-Console "  Share           : $($script:afShareName)" 'info'
    Write-Console "  UNC pad         : \\$($script:afStorageAccount).file.core.windows.net\$($script:afShareName)" 'info'

    $sa = $script:afStorageAccount
    $sn = $script:afShareName
    $k  = $script:afKey

    # Draait op de achtergrond (zoals de andere knoppen) zodat de GUI niet bevriest.
    $script:jobMapDrive = Start-Job -ScriptBlock {
        param($sa, $sn, $k)

        $mapScriptText = @"
try {
    Get-SmbMapping -ErrorAction SilentlyContinue | Where-Object { `$_.RemotePath -like '\\$sa.file.core.windows.net\*' } | ForEach-Object {
        Remove-SmbMapping -LocalPath `$_.LocalPath -Force -UpdateProfile -ErrorAction SilentlyContinue
    }
    New-SmbMapping -LocalPath 'X:' -RemotePath '\\$sa.file.core.windows.net\$sn' -UserName 'Azure\$sa' -Password '$k' -Persistent `$false -ErrorAction Stop | Out-Null
    Set-Content -Path '##RESULTFILE##' -Value '0|OK' -Encoding UTF8
} catch {
    Set-Content -Path '##RESULTFILE##' -Value "1|`$(`$_.Exception.Message)" -Encoding UTF8
}
"@

        $explorerRunning = [bool](Get-Process -Name explorer -ErrorAction SilentlyContinue)

        if (-not $explorerRunning) {
            # Geen Verkenner-sessie (bijv. OOBE) - rechtstreeks koppelen heeft dan geen zichtbaarheidsprobleem.
            Write-Output 'Geen Verkenner-sessie gedetecteerd (waarschijnlijk OOBE) - rechtstreeks koppelen...'
            try {
                Get-SmbMapping -ErrorAction SilentlyContinue | Where-Object { $_.RemotePath -like "\\$sa.file.core.windows.net\*" } | ForEach-Object {
                    Remove-SmbMapping -LocalPath $_.LocalPath -Force -UpdateProfile -ErrorAction SilentlyContinue
                }
                New-SmbMapping -LocalPath 'X:' -RemotePath "\\$sa.file.core.windows.net\$sn" -UserName "Azure\$sa" -Password $k -Persistent $false -ErrorAction Stop | Out-Null
                Write-Output 'SIGNAL:0|OK'
            } catch {
                Write-Output "SIGNAL:1|$($_.Exception.Message)"
            }
            return
        }

        Write-Output 'Koppeling wordt uitgevoerd in de sessie van de ingelogde gebruiker (zichtbaar in Verkenner)...'
        $resultFile = Join-Path $env:TEMP "EOO_MapDrive_Result_$([guid]::NewGuid().ToString('N')).txt"
        $scriptPath = Join-Path $env:TEMP "EOO_MapDrive_$([guid]::NewGuid().ToString('N')).ps1"
        [System.IO.File]::WriteAllText($scriptPath, $mapScriptText.Replace('##RESULTFILE##', $resultFile))

        $taskName = "EOO_Task_$([guid]::NewGuid().ToString('N'))"
        try {
            $action    = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""
            $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited
            Register-ScheduledTask -TaskName $taskName -Action $action -Principal $principal -Force | Out-Null
            Start-ScheduledTask -TaskName $taskName

            $elapsed = 0
            while ($elapsed -lt 20) {
                Start-Sleep -Milliseconds 400
                $elapsed += 0.4
                $state = (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue).State
                if ($state -eq 'Ready') { break }
            }
        } finally {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
        }

        if (Test-Path $resultFile) {
            Write-Output "SIGNAL:$(Get-Content -Path $resultFile -Raw)"
            Remove-Item $resultFile -ErrorAction SilentlyContinue
        } else {
            Write-Output 'SIGNAL:1|Geen resultaat ontvangen (geplande taak reageerde niet op tijd).'
        }
        Remove-Item $scriptPath -ErrorAction SilentlyContinue
    } -ArgumentList $sa, $sn, $k

    $script:timerMapDrive = New-Object System.Windows.Forms.Timer
    $script:timerMapDrive.Interval = 500
    $script:timerMapDrive.Add_Tick({
        foreach ($line in ($script:jobMapDrive.ChildJobs[0].Output.ReadAll())) {
            if ($line -match '^SIGNAL:(\d+)\|(.*)$') {
                if ($matches[1] -eq '0') {
                    Write-Console '[OK] Azure opslag gekoppeld op X:\' 'ok'
                    Write-Console '     Koppeling is tijdelijk en verdwijnt na herstart.' 'info'
                } else {
                    Write-Console "FOUT: koppelen mislukt - $($matches[2])" 'error'
                    Write-Console '      Controleer of TCP poort 445 niet geblokkeerd is.' 'info'
                }
            } else {
                Write-Console "  $line" 'info'
            }
        }
        foreach ($err in ($script:jobMapDrive.ChildJobs[0].Error.ReadAll())) {
            Write-Console "FOUT: $($err.Exception.Message)" 'error'
        }
        if ($script:jobMapDrive.State -in 'Completed','Failed') {
            $script:timerMapDrive.Stop(); $script:timerMapDrive.Dispose()
            if ($script:jobMapDrive.State -eq 'Failed') {
                Write-Console "FOUT: $($script:jobMapDrive.ChildJobs[0].JobStateInfo.Reason.Message)" 'error'
            }
            Remove-Job $script:jobMapDrive -Force
            $script:btnAzureMount.Enabled = $true
            Write-Console '─────────────────────────────' 'info'
        }
    })
    $script:timerMapDrive.Start()
})

# ── Sectie: Rapport ──────────────────────────────────────────────
New-SectionLabel 'Rapport' ($SECT_Y + 662)

$script:btnExportPDF = New-EOOButton 'Rapport exporteren als PDF' 22 ($SECT_Y + 686)
Add-BtnIcon $script:btnExportPDF (New-DownArrowBitmap $clrAccent)
$script:fullWidthCtrls.Add($script:btnExportPDF)
$script:btnExportPDF.Add_Click({
    $script:btnExportPDF.Enabled = $false
    Write-Console 'Rapport als PDF exporteren...' 'start'
    Export-RapportPDF
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

function Get-HPIASummary {
    $rapDir = 'C:\HPIAReport'
    if (-not (Test-Path $rapDir)) { return $null }

    $latest = Get-ChildItem $rapDir -Filter '*.html' -File -ErrorAction SilentlyContinue |
              Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latest) { return $null }

    try {
        $html = [System.IO.File]::ReadAllText($latest.FullName)

        $text = $html -replace '<[^>]+>', ' ' -replace '&[^;]+;', ' ' -replace '\s+', ' '

        $counts = [ordered]@{}
        $failCount   = 0
        $passRestart = 0

        # Type 1: Installatierapport – heeft Pass / Pass * / Fail statuswaarden
        $passClean   = ([regex]::Matches($html, '(?i)>\s*Pass\s*<')).Count
        $passRestart = ([regex]::Matches($html, '(?i)>\s*Pass\s+\*\s*<')).Count
        $failCount   = ([regex]::Matches($html, '(?i)>\s*Fail\s*<')).Count

        if (($passClean + $passRestart + $failCount) -gt 0) {
            $totalPass = $passClean + $passRestart
            if ($totalPass   -gt 0) { $counts['Geslaagd']         = $totalPass }
            if ($passRestart -gt 0) { $counts['Herstart vereist'] = $passRestart }
            if ($failCount   -gt 0) { $counts['Mislukt']          = $failCount }
        } else {
            # Type 2: Analyserapport – Missing Drivers / Out-of-Date structuur
            if ($text -match '(?i)Missing\s+Drivers\s+(\d+)') {
                $counts['Ontbrekende drivers'] = [int]$matches[1]
            }
            if ($text -match '(?i)Missing\s+Drivers\s+\d+\s+Out-of-Date\s+(\d+)') {
                $counts['Verouderde drivers'] = [int]$matches[1]
            }
            # Unieke SP-nummers tellen als aanbevelingen
            $spList = [regex]::Matches($text, '(?i)\bsp\d{5,6}\b') |
                      ForEach-Object { $_.Value.ToLower() } | Select-Object -Unique
            if ($spList.Count -gt 0) { $counts['Aanbevelingen'] = $spList.Count }
        }

        # Body-tekst: sla samenvatting bovenin (System Info / Product Details) over
        $bodyText = $text
        foreach ($kw in @('Drivers and Software', 'Installation Status', 'Recommendations')) {
            $pos = $text.IndexOf($kw, [System.StringComparison]::OrdinalIgnoreCase)
            if ($pos -ge 0) { $bodyText = $text.Substring($pos).Trim(); break }
        }

        return @{
            File     = $latest.Name
            Date     = $latest.LastWriteTime.ToString('dd-MM-yyyy HH:mm')
            BodyText = $bodyText
            Counts   = $counts
            HasFail  = $failCount -gt 0
            Restart  = $passRestart -gt 0
        }
    } catch { return $null }
}

function Export-RapportPDF {
    $serial = try { (Get-CimInstance Win32_BIOS).SerialNumber.Trim() } catch { 'ONBEKEND' }
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    $safeSerial = $serial -replace '[\\/:*?"<>|]', '_'
    $fn = "EOO_Rapport_${safeSerial}_${ts}.pdf"
    $outputPath = Join-Path $env:TEMP $fn

    $pdfPrinterAvail = [bool]([System.Drawing.Printing.PrinterSettings]::InstalledPrinters |
        Where-Object { $_ -eq 'Microsoft Print to PDF' })
    if (-not $pdfPrinterAvail) {
        Write-Console 'FOUT: "Microsoft Print to PDF" printer niet gevonden op dit systeem.' 'error'
        $script:btnExportPDF.Enabled = $true
        return
    }

    $script:_pdfData = @{
        Serial   = $serial
        Computer = $env:COMPUTERNAME
        Date     = Get-Date -Format 'dd-MM-yyyy HH:mm:ss'
        Version  = $script:currentVersion
        Logo     = $script:logoImage
        Checks   = @(
            @{ Label = $rowWin.Label.Text;    OK = $null }
            @{ Label = $rowAct.Label.Text;    OK = $script:okActivation }
            @{ Label = $rowTpm.Label.Text;    OK = $script:okTpm }
            @{ Label = $rowBoot.Label.Text;   OK = $script:okSecureBoot }
            @{ Label = $rowNet.Label.Text;    OK = $script:okInternet }
            @{ Label = $rowHP.Label.Text;     OK = ($script:hpBloatFound.Count -eq 0) }
            @{ Label = $rowLaptop.Label.Text; OK = $null }
            @{ Label = $rowWifi.Label.Text;   OK = $script:okWifi }
        )
        Bloat    = @($script:hpBloatFound)
        HPIA     = (Get-HPIASummary)
    }

    $pd = New-Object System.Drawing.Printing.PrintDocument
    $pd.PrinterSettings.PrinterName  = 'Microsoft Print to PDF'
    $pd.PrinterSettings.PrintToFile  = $true
    $pd.PrinterSettings.PrintFileName = $outputPath

    $pd.Add_PrintPage({
        param($s2, $ev)
        $d   = $script:_pdfData
        $g   = $ev.Graphics
        $lm  = [float]$ev.MarginBounds.Left
        $tm  = [float]$ev.MarginBounds.Top
        $pw  = [float]$ev.MarginBounds.Width

        $fTitle   = New-Object System.Drawing.Font('Arial', 16, [System.Drawing.FontStyle]::Bold)
        $fSub     = New-Object System.Drawing.Font('Arial', 10, [System.Drawing.FontStyle]::Italic)
        $fSection = New-Object System.Drawing.Font('Arial', 11, [System.Drawing.FontStyle]::Bold)
        $fCheck   = New-Object System.Drawing.Font('Arial', 10)
        $fSmall   = New-Object System.Drawing.Font('Arial', 9)

        $bBlack = [System.Drawing.Brushes]::Black
        $bGreen = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 128, 0))
        $bRed   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(192, 0, 0))
        $bGray  = [System.Drawing.Brushes]::DimGray
        $bTeal  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 128, 128))
        $penLine = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(0, 128, 128), 2)

        $y = $tm

        # Logo rechts bovenaan
        if ($null -ne $d.Logo) {
            $logoH = [int]48
            $logoW = [int]($d.Logo.Width * $logoH / $d.Logo.Height)
            $logoX = [int]($lm + $pw - $logoW)
            $g.DrawImage($d.Logo, (New-Object System.Drawing.Rectangle($logoX, [int]$tm, $logoW, $logoH)))
        }

        $g.DrawString('EOO Windows Installatie Rapport', $fTitle, $bTeal, $lm, $y)
        $y += 34
        $g.DrawString("Datum: $($d.Date)", $fSub, $bGray, $lm, $y)
        $y += 20
        $g.DrawString("Computer: $($d.Computer)   |   Serienummer: $($d.Serial)", $fSub, $bGray, $lm, $y)
        $y += 28
        $g.DrawLine($penLine, $lm, $y, ($lm + $pw), $y)
        $y += 16
        $g.DrawString('Systeemcontroles', $fSection, $bBlack, $lm, $y)
        $y += 28

        foreach ($chk in $d.Checks) {
            if ($null -eq $chk.OK) {
                $sym = "$([char]0x25CF)"
                $g.DrawString("$sym  $($chk.Label)", $fCheck, $bGray, $lm, $y)
            } elseif ($chk.OK) {
                $sym = "$([char]0x2713)"
                $g.DrawString("$sym  $($chk.Label)", $fCheck, $bGreen, $lm, $y)
            } else {
                $sym = "$([char]0x2717)"
                $g.DrawString("$sym  $($chk.Label)", $fCheck, $bRed, $lm, $y)
            }
            $y += 22
        }

        if ($d.Bloat.Count -gt 0) {
            $y += 8
            foreach ($item in $d.Bloat) {
                $g.DrawString("     - $item", $fSmall, $bRed, $lm, $y)
                $y += 18
            }
        }

        # HPIA sectie
        $y += 20
        $g.DrawLine($penLine, $lm, $y, ($lm + $pw), $y)
        $y += 14
        $g.DrawString('HP Image Assistant', $fSection, $bBlack, $lm, $y)
        $y += 24

        if ($null -ne $d.HPIA) {
            $g.DrawString("Rapport: $($d.HPIA.File)   |   $($d.HPIA.Date)", $fSmall, $bGray, $lm, $y)
            $y += 16
            if ($d.HPIA.BodyText) {
                $footerTopY = [float]$ev.MarginBounds.Bottom - 24
                $availH     = [Math]::Max(10, $footerTopY - $y - 4)
                $sf = New-Object System.Drawing.StringFormat
                $sf.Trimming = [System.Drawing.StringTrimming]::Word
                $g.DrawString($d.HPIA.BodyText, $fSmall, $bBlack,
                    [System.Drawing.RectangleF]::new($lm, $y, $pw, $availH), $sf)
                $sf.Dispose()
            } else {
                $g.DrawString('Geen inhoud gevonden in rapport.', $fSmall, $bGray, $lm, $y)
            }
        } else {
            $fBig = New-Object System.Drawing.Font('Arial', 11, [System.Drawing.FontStyle]::Bold)
            $g.DrawString("$([char]0x26A0)  GEEN HPIA-RAPPORT GEVONDEN — HP Image Assistant is mogelijk niet gedraaid.", $fBig, $bRed, $lm, $y)
            $fBig.Dispose()
        }

        # Footer altijd vastgezet onderaan de pagina
        $fy = [float]$ev.MarginBounds.Bottom - 22
        $g.DrawLine($penLine, $lm, $fy, ($lm + $pw), $fy)
        $fy += 10
        $g.DrawString("Gegenereerd door EOO Windows Installatie Tool v$($d.Version)", $fSmall, $bGray, $lm, $fy)

        $penLine.Dispose()
        $bGreen.Dispose(); $bRed.Dispose(); $bTeal.Dispose()
        $fTitle.Dispose(); $fSub.Dispose(); $fSection.Dispose(); $fCheck.Dispose(); $fSmall.Dispose()
        $ev.HasMorePages = $false
    })

    try {
        $pd.Print()
        Write-Console 'PDF gereed, uploaden naar Azure Files...' 'info'

        $script:_jobPdfUpload = Start-Job -ScriptBlock {
            param($localPath, $sa, $sn, $k)
            # Wacht tot PDF op schijf staat (spooler kan even nalopen)
            $waited = 0
            while (-not (Test-Path $localPath) -and $waited -lt 30) {
                Start-Sleep -Milliseconds 500
                $waited++
            }
            if (-not (Test-Path $localPath)) { throw 'PDF niet beschikbaar na 15 seconden.' }
            $fn = [System.IO.Path]::GetFileName($localPath)
            if (-not (Test-Path 'X:\')) {
                Get-SmbMapping -ErrorAction SilentlyContinue | Where-Object { $_.RemotePath -like "\\$sa.file.core.windows.net\*" } | ForEach-Object {
                    Remove-SmbMapping -LocalPath $_.LocalPath -Force -UpdateProfile -ErrorAction SilentlyContinue
                }
                try {
                    New-SmbMapping -LocalPath 'X:' -RemotePath "\\$sa.file.core.windows.net\$sn" -UserName "Azure\$sa" -Password $k -Persistent $false -ErrorAction Stop | Out-Null
                } catch {
                    throw "Azure Files koppelen mislukt: $_"
                }
            }
            $rapDir = 'X:\Rapporten'
            if (-not (Test-Path $rapDir)) { New-Item -ItemType Directory -Path $rapDir | Out-Null }
            Copy-Item -Path $localPath -Destination "$rapDir\$fn" -Force
            Remove-Item $localPath -Force -ErrorAction SilentlyContinue
            Write-Output "OK:$fn"
        } -ArgumentList $outputPath, $script:afStorageAccount, $script:afShareName, $script:afKey

        $script:_timerPdfUpload = New-Object System.Windows.Forms.Timer
        $script:_timerPdfUpload.Interval = 500
        $script:_timerPdfUpload.Add_Tick({
            foreach ($line in ($script:_jobPdfUpload.ChildJobs[0].Output.ReadAll())) {
                if ($line -match '^OK:(.+)') {
                    Write-Console "[OK] Geupload naar Azure Files: Rapporten\$($matches[1])" 'ok'
                }
            }
            foreach ($err in ($script:_jobPdfUpload.ChildJobs[0].Error.ReadAll())) {
                Write-Console "FOUT upload: $($err.Exception.Message)" 'error'
            }
            if ($script:_jobPdfUpload.State -in 'Completed','Failed') {
                $script:_timerPdfUpload.Stop()
                $script:_timerPdfUpload.Dispose()
                if ($script:_jobPdfUpload.State -eq 'Failed') {
                    Write-Console "FOUT: Upload naar Azure Files mislukt." 'error'
                }
                Remove-Job $script:_jobPdfUpload -Force
                $script:btnExportPDF.Enabled = $true
            }
        })
        $script:_timerPdfUpload.Start()

    } catch {
        Write-Console "FOUT bij exporteren PDF: $_" 'error'
        $script:btnExportPDF.Enabled = $true
    } finally {
        $pd.Dispose()
        $script:_pdfData = $null
    }
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
