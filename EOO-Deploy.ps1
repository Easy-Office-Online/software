#============================================================
# EOO-Deploy.ps1 — OSDCloud automation script
# HP: HPIA | Lenovo: DriverPack auto | Dell: DriverPack auto
# Altijd: Windows 11 Pro NL | 1 partitie
# Made by The High Wizard of Systems & Sorcery
#============================================================

# ── STAP 1: Windows installeren ──────────────────────────
$Params = @{
    OSName        = 'Windows 11 25H2 x64'
    OSEdition     = 'Pro'
    OSLanguage    = 'nl-nl'
    OSLicense     = 'Retail'
    SkipAutopilot = $true
    SkipODT       = $false
    ZTI           = $true
    Restart       = $true
}
Start-OSDCloud @Params

# ── Controleer of OS deployment gelukt is ────────────────
if (-not (Test-Path "C:\Windows\System32\ntoskrnl.exe")) {
    Write-Host "OS deployment mislukt — script gestopt" -ForegroundColor Red
    Exit 1
}

# Lenovo + Dell: OSDCloud handelt DriverPacks automatisch af
# via Specialize phase (geen extra actie nodig)
