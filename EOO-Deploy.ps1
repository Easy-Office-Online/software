#============================================================
# EOO-Deploy.ps1 — OSDCloud automation script
# HP: HPIA | Lenovo: DriverPack auto | Dell: DriverPack auto
# Altijd: Windows 11 Pro NL | 1 partitie
# Made by The High Wizard of Systems & Sorcery
#============================================================
 
# ── STAP 1: Windows installeren ──────────────────────────
$Params = @{
    OSName        = 'Windows 11 24H2 x64'
    OSEdition     = 'Pro'
    OSLanguage    = 'nl-nl'
    OSLicense     = 'Retail'
    SkipAutopilot = $true
    SkipODT       = $true
    ZTI           = $true
    Restart       = $true
}
Start-OSDCloud @Params
 
# ── Controleer of OS deployment gelukt is ────────────────
if (-not (Test-Path "C:\Windows\System32\ntoskrnl.exe")) {
    Write-Host "OS deployment mislukt — script gestopt" -ForegroundColor Red
    Exit 1
}
 
# ── STAP 2: HP HPIA via SetupComplete ────────────────────
$Manufacturer = (Get-WmiObject Win32_ComputerSystem).Manufacturer
 
if ($Manufacturer -match 'HP|Hewlett') {
    Set-SetupCompleteHPAppend -HPIAAll $true
    Write-Host "HP gedetecteerd — HPIA ingepland voor SetupComplete" -ForegroundColor Cyan
}
 
# Lenovo + Dell: OSDCloud handelt DriverPacks automatisch af
# via Specialize phase (geen extra actie nodig)
 
# ── STAP 3: EOO WinInstall GUI via SetupComplete ─────────
$setupScriptsDir = "C:\Windows\Setup\Scripts"
$setupComplete   = "$setupScriptsDir\SetupComplete.cmd"
 
if (-not (Test-Path $setupScriptsDir)) {
    New-Item -Path $setupScriptsDir -ItemType Directory -Force | Out-Null
}
 
$guiPs1 = "$setupScriptsDir\EOO-WinInstall-GUI.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Easy-Office-Online/software/refs/heads/main/EOO-WinInstall-GUI.ps1' `
    -OutFile $guiPs1 -UseBasicParsing
 
$setupLine = "`r`nPowerShell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$guiPs1`""
if (Test-Path $setupComplete) {
    Add-Content -Path $setupComplete -Value $setupLine
} else {
    "@echo off$setupLine" | Out-File -FilePath $setupComplete -Encoding ascii
}
 
Write-Host "EOO WinInstall GUI ingepland voor SetupComplete" -ForegroundColor Cyan
