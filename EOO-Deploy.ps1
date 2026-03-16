#============================================================
# EOO-OSDCloud-Deploy.ps1
# Windows 11 25H2 Enterprise NL + Office NL + HP/Lenovo/Dell
# Gebaseerd op OSDCloud (OSD PowerShell Module)
# Gebruik: Vanuit WinPE - Invoke-Expression (Invoke-RestMethod '<raw_url>')
#============================================================

#region OS VARS
$OSName       = 'Windows 11 25H2 x64'
$OSEdition    = 'Pro'
$OSActivation = 'Retail'
$OSLanguage   = 'nl-nl'
#endregion

#region OSDCLOUD GLOBAL VARS
$Global:MyOSDCloud = [ordered]@{
    Restart                = [bool]$false
    RecoveryPartition      = [bool]$true
    OEMActivation          = [bool]$true
    WindowsUpdate          = [bool]$false   # Wordt gedaan via HPIA/WU in OOBE
    WindowsUpdateDrivers   = [bool]$false   # Driver packs van fabrikant verdienen de voorkeur
    WindowsDefenderUpdate  = [bool]$true
    SetTimeZone            = [bool]$true    # Op basis van IP
    ClearDiskConfirm       = [bool]$false
    ShutdownSetupComplete  = [bool]$false

    # Office via ODT (wordt geïnjecteerd in SetupComplete)
    ODTConfigFile          = 'C:\OSDCloud\ODT\office-nl.xml'

    # HP specifiek (alleen actief op HP hardware)
    HPBIOSUpdate           = [bool]$true
    HPTPMUpdate            = [bool]$true
    HPIAALL                = [bool]$true    # Drivers + firmware + software via HPIA
}
#endregion

#region DETECT FABRIKANT & DRIVER PACK
$Manufacturer = (Get-WmiObject Win32_ComputerSystem).Manufacturer
$Product      = (Get-WmiObject Win32_ComputerSystem).Model
$OSVersion    = 'Windows 11'
$OSReleaseID  = '25H2'

Write-Host "Fabrikant : $Manufacturer" -ForegroundColor Cyan
Write-Host "Model     : $Product"      -ForegroundColor Cyan

# Driver pack ophalen op basis van fabrikant
# OSDCloud pakt HP/Dell/Lenovo automatisch op via Get-OSDCloudDriverPack
$DriverPack = Get-OSDCloudDriverPack -Product $Product -OSVersion $OSVersion -OSReleaseID $OSReleaseID

if ($DriverPack) {
    Write-Host "Driver Pack gevonden: $($DriverPack.Name)" -ForegroundColor Green
    $Global:MyOSDCloud.DriverPackName = $DriverPack.Name
} else {
    Write-Host "Geen driver pack gevonden, Windows Update Catalog wordt gebruikt." -ForegroundColor Yellow
    $Global:MyOSDCloud.DriverPackName = 'Microsoft Update Catalog'
}

# Lenovo: BIOS via Thin Installer / Lenovo Update (geen ingebouwde OSDCloud var, post-OOBE script)
if ($Manufacturer -match 'Lenovo') {
    Write-Host "Lenovo gedetecteerd - Lenovo BIOS update wordt via OOBE-script uitgevoerd." -ForegroundColor Cyan
    $Global:MyOSDCloud.HPBIOSUpdate = $false
    $Global:MyOSDCloud.HPTPMUpdate  = $false
    $Global:MyOSDCloud.HPIAALL      = $false
}

# Dell: CommandUpdate via OOBE-script
if ($Manufacturer -match 'Dell') {
    Write-Host "Dell gedetecteerd - Dell Command Update wordt via OOBE-script uitgevoerd." -ForegroundColor Cyan
    $Global:MyOSDCloud.HPBIOSUpdate = $false
    $Global:MyOSDCloud.HPTPMUpdate  = $false
    $Global:MyOSDCloud.HPIAALL      = $false
}
#endregion

#region OFFICE ODT CONFIG AANMAKEN (Enterprise NL, geen Teams classic)
$ODTDir = 'C:\OSDCloud\ODT'
if (-not (Test-Path $ODTDir)) { New-Item -Path $ODTDir -ItemType Directory -Force | Out-Null }

$ODTConfig = @"
<Configuration ID="EOO-Office365-NL">
  <Add OfficeClientEdition="64" Channel="MonthlyEnterprise">
    <Product ID="O365ProPlusRetail">
      <Language ID="nl-nl" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
    </Product>
  </Add>
  <Updates Enabled="TRUE" Channel="MonthlyEnterprise" />
  <Display Level="None" AcceptEULA="TRUE" />
  <Property Name="AUTOACTIVATE" Value="1" />
  <Logging Level="Standard" Path="C:\OSDCloud\Logs\Office" />
</Configuration>
"@

$ODTConfig | Out-File -FilePath "$ODTDir\office-nl.xml" -Encoding utf8 -Force
Write-Host "ODT config aangemaakt: $ODTDir\office-nl.xml" -ForegroundColor Green
#endregion

#region START OSDCLOUD
Write-Host "Start-OSDCloud -OSName '$OSName' -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage" -ForegroundColor Yellow

Start-OSDCloud `
    -OSName       $OSName `
    -OSEdition    $OSEdition `
    -OSActivation $OSActivation `
    -OSLanguage   $OSLanguage
#endregion

#region POST-WINPE: OOBE SCRIPT INJECTEREN (SetupComplete uitbreiden)
# Lenovo BIOS/Driver update via Thin Installer
# Dell Command Update
# Office installatie via ODT

$OOBEScript = @'
#============================================================
# EOO-OOBEDeploy.ps1 - Wordt uitgevoerd in SetupComplete fase
#============================================================

$Manufacturer = (Get-WmiObject Win32_ComputerSystem).Manufacturer
$LogPath = "C:\OSDCloud\Logs"
if (-not (Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory -Force | Out-Null }

#--- Office installeren via ODT ---
$ODTSetup  = "C:\OSDCloud\ODT\setup.exe"
$ODTConfig = "C:\OSDCloud\ODT\office-nl.xml"

if (Test-Path $ODTSetup) {
    Write-Host "Office 365 installeren via ODT..." -ForegroundColor Cyan
    # ODT setup.exe downloaden als nog niet aanwezig
    Start-Process -FilePath $ODTSetup -ArgumentList "/configure `"$ODTConfig`"" -Wait -NoNewWindow
    Write-Host "Office installatie afgerond." -ForegroundColor Green
} else {
    Write-Host "ODT setup.exe niet gevonden, Office downloaden..." -ForegroundColor Yellow
    $ODTUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_18227-20162.exe"
    $ODTInstaller = "C:\OSDCloud\ODT\odt_installer.exe"
    Invoke-WebRequest -Uri $ODTUrl -OutFile $ODTInstaller -UseBasicParsing
    Start-Process -FilePath $ODTInstaller -ArgumentList "/quiet /extract:`"C:\OSDCloud\ODT`"" -Wait
    Start-Process -FilePath $ODTSetup -ArgumentList "/configure `"$ODTConfig`"" -Wait -NoNewWindow
}

#--- Lenovo: BIOS + drivers via Thin Installer ---
if ($Manufacturer -match 'Lenovo') {
    Write-Host "Lenovo: Thin Installer downloaden en uitvoeren..." -ForegroundColor Cyan
    $ThinInstallerUrl = "https://download.lenovo.com/pccbbs/thinkclient_downloads/thininstaller/packages/ThinInstaller.exe"
    $ThinInstallerPath = "C:\OSDCloud\Lenovo\ThinInstaller.exe"
    
    New-Item -Path "C:\OSDCloud\Lenovo" -ItemType Directory -Force | Out-Null
    Invoke-WebRequest -Uri $ThinInstallerUrl -OutFile $ThinInstallerPath -UseBasicParsing
    
    # Silent installatie: firmware + BIOS updates
    Start-Process -FilePath $ThinInstallerPath `
        -ArgumentList '/CM -search A -action INSTALL -includerebootpackages 3,4 -noicon -noreboot -exporttowmi' `
        -Wait -NoNewWindow
    Write-Host "Lenovo Thin Installer afgerond." -ForegroundColor Green
}

#--- Dell: Dell Command Update ---
if ($Manufacturer -match 'Dell') {
    Write-Host "Dell: Dell Command Update downloaden en uitvoeren..." -ForegroundColor Cyan
    # DCU-CLI gebruiken (vereist Dell Command Update geïnstalleerd)
    $DCUPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
    
    if (-not (Test-Path $DCUPath)) {
        Write-Host "Dell Command Update niet aanwezig, overslaan." -ForegroundColor Yellow
        # Optioneel: winget install Dell.CommandUpdate.Universal
    } else {
        Start-Process -FilePath $DCUPath `
            -ArgumentList '/applyUpdates -outputLog="C:\OSDCloud\Logs\DellCU.log"' `
            -Wait -NoNewWindow
        Write-Host "Dell Command Update afgerond." -ForegroundColor Green
    }
}

Write-Host "EOO OOBE Deploy voltooid." -ForegroundColor Green
'@

# Script wegschrijven voor SetupComplete
$OOBEScriptPath = 'C:\Windows\Setup\Scripts\EOO-OOBEDeploy.ps1'
if (Test-Path 'C:\Windows\Setup\Scripts') {
    $OOBEScript | Out-File -FilePath $OOBEScriptPath -Encoding utf8 -Force

    # Toevoegen aan bestaand SetupComplete.cmd
    $SetupCompletePath = 'C:\Windows\Setup\Scripts\SetupComplete.cmd'
    $OOBELine = "start /wait PowerShell -NoL -ExecutionPolicy Bypass -File C:\Windows\Setup\Scripts\EOO-OOBEDeploy.ps1"
    
    if (Test-Path $SetupCompletePath) {
        $existing = Get-Content $SetupCompletePath
        if ($existing -notcontains $OOBELine) {
            Add-Content -Path $SetupCompletePath -Value $OOBELine
        }
    } else {
        $OOBELine | Out-File -FilePath $SetupCompletePath -Encoding ascii -Force
    }
    Write-Host "OOBE-script geïnjecteerd in SetupComplete.cmd" -ForegroundColor Green
}
#endregion

Write-Host "OSDCloud deploy klaar. Apparaat herstart naar Windows 11 25H2." -ForegroundColor Green
