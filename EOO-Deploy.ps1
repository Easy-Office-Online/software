#============================================================
# EOO-Deploy.ps1 — OSDCloud automation script
# HP: HPIA | Lenovo: DriverPack auto | Dell: DriverPack auto
# Altijd: Windows 11 Pro NL | 1 partitie | HWID + GroupTag
# Made by The High Wizard of systems & Sorcery
#============================================================

# ── STAP 1: Windows installeren ──────────────────────────
$Params = @{
    OSName      = 'Windows 11 25H2 x64'
    OSEdition   = 'Pro'
    OSLanguage  = 'nl-nl'
    OSLicense   = 'Retail'
    SkipAutopilot = $true   # doen we zelf in OOBE
    SkipODT     = $true
    ZTI         = $true     # geen interactie, 1 partitie automatisch
}
Start-OSDCloud @Params

# ── STAP 2: HP HPIA via SetupComplete ────────────────────
$Manufacturer = (Get-WmiObject Win32_ComputerSystem).Manufacturer

if ($Manufacturer -match 'HP|Hewlett') {
    # HPIA wordt uitgevoerd in SetupComplete (OOBE fase)
    Set-SetupCompleteHPAppend -HPIA -HPIAAction All
    Write-Host "HP gedetecteerd — HPIA ingepland voor SetupComplete"
}

# Lenovo + Dell: OSDCloud handelt DriverPacks automatisch af
# via Specialize phase (geen extra actie nodig)

# ── STAP 3: AutopilotOOBE staging ────────────────────────
# GroupTagOptions aanpassen naar jullie eigen tags
$AutopilotOOBEJson = @'
{
    "Assign": { "IsPresent": true },
    "GroupTag": "",
    "GroupTagOptions": [
    "AktiefysioFull",
    "BfysicFlex",
    "BfysicFull",
    "Bfysicfulll",
    "BONNIERFLEX",
    "BONNIERFULL",
    "CONNECTFLEX",
    "CONNECTFULL",
    "DIRECTFLEX",
    "DIRECTFULL",
    "FEflex",
    "FitaalFlex",
    "FitaalFull",
    "FNFlex",
    "FysioExpertFull",
    "FysioNUFlex",
    "FysioNuFull",
    "FyzFull",
    "Fyzieflex",
    "FyzieFull",
    "Hoofdkantoor",
    "htpc",
    "Kiosk",
    "Kiosk+Aktiefysio",
    "Kiosk+FysioNu",
    "Kiosk+Topfit",
    "KioskAksiefysio",
    "KioskInteractiveFN",
    "KioskInteractiveTopfit",
    "KioskplusTopfit",
    "LGNFull",
    "lslflex",
    "LSLFull",
    "PacaFlex",
    "PacaFull",
    "PMCFlex",
    "SPRAAKFABRIEKFLEX",
    "Spraakfabriekfull",
    "TFFlex",
    "Topfit",
    "Topfit Full en KioskPlus",
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

Write-Host "AutopilotOOBE JSON geplaatst — klaar voor OOBE fase"
