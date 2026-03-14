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

# Lenovo + Dell: OSDCloud handelt DriverPacks automatisch af
# via Specialize phase (geen extra actie nodig)

# ── STAP 3: AutopilotOOBE staging ────────────────────────
$AutopilotOOBEJson = @'
{
    "Assign": { "IsPresent": true },
    "GroupTag": "",
    "GroupTagOptions": [
        "AktiefysioFull",
        "BfysicFlex",
        "BfysicFull",
        "BfysicFull",
        "Bonnier-Flex",
        "Bonnier-Full",
        "Connect-Flex",
        "Connect-Full",
        "Direct-Flex",
        "Direct-Full",
        "FEflex",
        "FitaalFlex",
        "FitaalFull",
        "FNFlex",
        "FysioExpertFull",
        "FysioNuFlex",
        "FysioNuFull",
        "FyzFull",
        "Fyzieflex",
        "FyzieFull",
        "Hoofdkantoor",
        "htpc",
        "Kiosk",
        "Kiosk-Aktiefysio",
        "Kiosk-FysioNu",
        "Kiosk-Topfit",
        "KioskAksiefysio",
        "KioskInteractiveFN",
        "KioskInteractiveTopfit",
        "KioskPlus-Topfit",
        "LGNFull",
        "lslflex",
        "LSLFull",
        "PacaFlex",
        "PacaFull",
        "PMCFlex",
        "Spraakfabriek-Flex",
        "Spraakfabriek-Full",
        "TFFlex",
        "Topfit",
        "TopfitFull-KioskPlus",
        "TopfitFull"
    ],
    "Hidden": [
        "AddToGroup",
        "AssignedComputerName",
        "AssignedUser",
        "PostAction"
    ],
    "PostAction": "Quit",
    "Run": "NetworkingWireless",
    "Title": "EOO — Autopilot Registratie"
}
'@

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}

$AutopilotOOBEJson | Out-File `
    -FilePath "C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json" `
    -Encoding ascii -Force

Write-Host "AutopilotOOBE JSON geplaatst — klaar voor OOBE fase" -ForegroundColor Cyan
