#============================================================
# EOO-Deploy.ps1 — OSDCloud automation script
# HP: HPIA | Lenovo: DriverPack auto | Dell: DriverPack auto
# Altijd: Windows 11 Pro NL | 1 partitie | HWID + GroupTag
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
