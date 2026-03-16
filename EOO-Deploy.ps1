#============================================================
# EOO-Deploy.ps1 — OSDCloud automation script
# HP: HPIA | Lenovo: DriverPack auto | Dell: DriverPack auto
# Altijd: Windows 11 Pro NL | 1 partitie
# Office: M365 Apps for Enterprise via ODT (in WinPE)
# Company Portal: via WinGet (SetupComplete)
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
 
# ── STAP 2: Microsoft 365 Apps for Enterprise via ODT ────
Write-Host "Office 365 installatie starten via ODT..." -ForegroundColor Cyan
 
$ODTPath = "C:\OSDCloud\ODT"
New-Item -Path $ODTPath -ItemType Directory -Force | Out-Null
 
$ODTSetupExe = "$ODTPath\ODTSetup.exe"
 
try {
    Write-Host "ODT downloaden..." -ForegroundColor Gray
    Invoke-WebRequest -Uri 'https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_18129-20158.exe' `
        -OutFile $ODTSetupExe -UseBasicParsing
    Start-Process -FilePath $ODTSetupExe -ArgumentList "/quiet /extract:$ODTPath" -Wait
    Write-Host "ODT uitgepakt naar $ODTPath" -ForegroundColor Green
} catch {
    Write-Host "ODT download mislukt: $_ — Office installatie overgeslagen" -ForegroundColor Yellow
}
 
$OfficeXML = @'
<Configuration ID="EOO-M365-Enterprise">
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise">
    <Product ID="O365ProPlusRetail">
      <Language ID="nl-nl" />
      <ExcludeApp ID="Teams" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="Groove" />
    </Product>
  </Add>
  <Updates Enabled="TRUE" Channel="MonthlyEnterprise" />
  <Display Level="None" AcceptEULA="TRUE" />
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Property Name="SharedComputerLicensing" Value="0" />
</Configuration>
'@
 
$OfficeXMLPath = "$ODTPath\M365Enterprise.xml"
$SetupExe      = "$ODTPath\setup.exe"
 
if (Test-Path $SetupExe) {
    $OfficeXML | Out-File -FilePath $OfficeXMLPath -Encoding utf8 -Force
 
    try {
        Write-Host "Office installatie starten (dit duurt even)..." -ForegroundColor Cyan
        $OfficeProcess = Start-Process -FilePath $SetupExe `
            -ArgumentList "/configure `"$OfficeXMLPath`"" `
            -Wait -PassThru
 
        if ($OfficeProcess.ExitCode -eq 0) {
            Write-Host "Office succesvol geinstalleerd" -ForegroundColor Green
        } else {
            Write-Host "Office installatie afgesloten met exitcode: $($OfficeProcess.ExitCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Office installatie mislukt: $_" -ForegroundColor Red
    }
} else {
    Write-Host "setup.exe niet gevonden — Office installatie overgeslagen" -ForegroundColor Yellow
}
 
# ── STAP 3: HP HPIA via SetupComplete ────────────────────
$Manufacturer = (Get-WmiObject Win32_ComputerSystem).Manufacturer
 
if ($Manufacturer -match 'HP|Hewlett') {
    Set-SetupCompleteHPAppend -HPIAAll $true
    Write-Host "HP gedetecteerd — HPIA ingepland voor SetupComplete" -ForegroundColor Cyan
}
 
# Lenovo + Dell: OSDCloud handelt DriverPacks automatisch af
# via Specialize phase (geen extra actie nodig)
 
# ── STAP 4: EOO WinInstall GUI + Company Portal via SetupComplete ──
$setupScriptsDir = "C:\Windows\Setup\Scripts"
$setupComplete   = "$setupScriptsDir\SetupComplete.cmd"
 
if (-not (Test-Path $setupScriptsDir)) {
    New-Item -Path $setupScriptsDir -ItemType Directory -Force | Out-Null
}
 
# EOO WinInstall GUI downloaden
$guiPs1 = "$setupScriptsDir\EOO-WinInstall-GUI.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Easy-Office-Online/software/refs/heads/main/EOO-WinInstall-GUI.ps1' `
    -OutFile $guiPs1 -UseBasicParsing
 
# Company Portal installatiescript aanmaken
$companyPortalPs1 = "$setupScriptsDir\Install-CompanyPortal.ps1"
 
@'
# Install-CompanyPortal.ps1 — uitgevoerd via SetupComplete
$logFile = "C:\OSDCloud\Logs\CompanyPortal-Install.log"
New-Item -Path (Split-Path $logFile) -ItemType Directory -Force | Out-Null
 
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp [$Level] $Message" | Tee-Object -FilePath $logFile -Append | Write-Host
}
 
Write-Log "Company Portal installatie gestart"
 
$winget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $winget) {
    Write-Log "WinGet niet beschikbaar — Company Portal installatie overgeslagen" "WARN"
    Exit 0
}
 
Write-Log "WinGet gevonden op: $($winget.Source)"
 
try {
    $result = Start-Process -FilePath "winget" `
        -ArgumentList "install --id Microsoft.CompanyPortal --silent --accept-source-agreements --accept-package-agreements" `
        -Wait -PassThru -NoNewWindow
 
    if ($result.ExitCode -eq 0) {
        Write-Log "Company Portal succesvol geinstalleerd"
    } else {
        Write-Log "Company Portal exitcode: $($result.ExitCode)" "WARN"
    }
} catch {
    Write-Log "Company Portal installatie mislukt: $_" "ERROR"
}
'@ | Out-File -FilePath $companyPortalPs1 -Encoding utf8 -Force
 
# SetupComplete.cmd opbouwen — volgorde: Company Portal → GUI
# (HPIA schrijft mogelijk al naar SetupComplete.cmd via Set-SetupCompleteHPAppend,
#  dus we voegen onze regels toe i.p.v. overschrijven)
$cpLine  = "PowerShell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$companyPortalPs1`""
$guiLine = "PowerShell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$guiPs1`""
 
if (Test-Path $setupComplete) {
    Add-Content -Path $setupComplete -Value "`r`n$cpLine`r`n$guiLine"
} else {
    "@echo off`r`n$cpLine`r`n$guiLine" | Out-File -FilePath $setupComplete -Encoding ascii
}
 
Write-Host "Company Portal installatie ingepland voor SetupComplete" -ForegroundColor Cyan
Write-Host "EOO WinInstall GUI ingepland voor SetupComplete" -ForegroundColor Cyan
