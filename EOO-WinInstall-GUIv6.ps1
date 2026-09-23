# ════════════════════════════════════════════════════════════════
#  EOO – Windows Installatie Tool  |  WPF-versie (volledig)
#  Zelfde functionaliteit als EOO-WinInstall-GUIv6.ps1 (WinForms),
#  opnieuw opgebouwd in WPF/XAML met een moderne stijl (rounded
#  cards, dropshadow, vector-iconen) i.p.v. de GDI+ bitmaps.
#  NIET pixel-perfect gelijk aan v6 -- zie eerder overleg.
#  Draai met Windows PowerShell (powershell.exe), niet met pwsh.
#  Opslaan als: UTF-8 with BOM
# ════════════════════════════════════════════════════════════════

$script:currentVersion = [System.Version]'7.2'
$script:versionName    = 'Pizza Gorgonzola'

# ── Azure Files configuratie ───────────────────────────────────────
$script:afStorageAccount = 'staceoosupportools'
$script:afShareName      = 'eoo-support-tools'
$script:afKey            = '7wa9oZJDVh+cTcYDiOPOB1WCE0TEzpYe/BaqQlLA85jKga3g7AKC0zMjgYlTTjgVRgTuvfxpdnJq+AStoXQFlA=='

# UAC elevatie – herstart als admin indien nodig
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$script_HWID_Overwrite = @'
$ErrorActionPreference = 'Stop'
$GroupTag = Read-Host 'Voer GroupTag in (bijv: EOO-W11-FLEX)'
if (-not $GroupTag) { Write-Host 'Geen GroupTag opgegeven. Stop.' -ForegroundColor Red; Read-Host; exit 1 }
$storageAccount = '##STORAGEACCOUNT##'
$shareName      = '##SHARENAME##'
$key            = '##KEY##'
try {
    Write-Host "HWID ophalen..."
    $serial = (Get-CimInstance Win32_BIOS).SerialNumber
    $dev    = Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_DevDetail_Ext01 -ErrorAction Stop
    $hash   = $dev.DeviceHardwareData
    if (-not $hash) { throw 'Hardware hash niet gevonden.' }
    $file   = "$env:TEMP\Autopilot-$serial.csv"
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
    Copy-Item -Path $file -Destination "X:\HWID\$serial.csv" -Force
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
    [System.IO.File]::WriteAllText($path, ($Content -replace "`r`n", "`n" -replace "`n", "`r`n"))
    return $path
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml, System.Drawing

# ════════════════════════════════════════════════════════════════
#  UI
# ════════════════════════════════════════════════════════════════
[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="EOO - Windows Installatie Tool"
        Width="980" Height="720" MinWidth="640" MinHeight="500"
        WindowStartupLocation="CenterScreen" FontFamily="Segoe UI">
    <Window.Resources>
        <SolidColorBrush x:Key="BrushBg"        Color="#FAF9F6"/>
        <SolidColorBrush x:Key="BrushCard"      Color="#FFFFFF"/>
        <SolidColorBrush x:Key="BrushBorder"    Color="#E4E1DB"/>
        <SolidColorBrush x:Key="BrushAccent"    Color="#208AD0"/>
        <SolidColorBrush x:Key="BrushAccentDark" Color="#03173D"/>
        <SolidColorBrush x:Key="BrushSubText"   Color="#646C7A"/>
        <SolidColorBrush x:Key="BrushDanger"    Color="#DC2626"/>
        <SolidColorBrush x:Key="BrushConsoleDefault" Color="#CBD5E1"/>
        <SolidColorBrush x:Key="BrushConsoleOk"       Color="#60BEF0"/>
        <SolidColorBrush x:Key="BrushConsoleError"    Color="#F87171"/>
        <SolidColorBrush x:Key="BrushConsoleStart"    Color="#FACC15"/>

        <Style x:Key="SectionTitle" TargetType="TextBlock">
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Foreground" Value="{StaticResource BrushAccentDark}"/>
            <Setter Property="Margin" Value="0,18,0,6"/>
        </Style>

        <Style x:Key="OutlineButton" TargetType="Button">
            <Setter Property="Height" Value="34"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Bd" Background="{StaticResource BrushCard}"
                                BorderBrush="{StaticResource BrushBorder}" BorderThickness="1" CornerRadius="8">
                            <Border.Effect>
                                <DropShadowEffect BlurRadius="6" ShadowDepth="1" Opacity="0.08" Color="#000000"/>
                            </Border.Effect>
                            <StackPanel Orientation="Horizontal" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="14,0">
                                <Path x:Name="PART_Icon" Width="15" Height="15" Stretch="Uniform" Margin="0,0,10,0"
                                      Fill="{StaticResource BrushAccentDark}" Data="{TemplateBinding Tag}"/>
                                <TextBlock x:Name="PART_Text" Text="{TemplateBinding Content}"
                                           Foreground="{StaticResource BrushAccentDark}" VerticalAlignment="Center"/>
                            </StackPanel>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="{StaticResource BrushAccent}"/>
                                <Setter TargetName="PART_Icon" Property="Fill" Value="White"/>
                                <Setter TargetName="PART_Text" Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Bd" Property="Opacity" Value="0.5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="DangerOutlineButton" TargetType="Button" BasedOn="{StaticResource OutlineButton}">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Bd" Background="{StaticResource BrushCard}"
                                BorderBrush="{StaticResource BrushBorder}" BorderThickness="1" CornerRadius="8">
                            <Border.Effect>
                                <DropShadowEffect BlurRadius="6" ShadowDepth="1" Opacity="0.08" Color="#000000"/>
                            </Border.Effect>
                            <StackPanel Orientation="Horizontal" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="14,0">
                                <Path x:Name="PART_Icon" Width="15" Height="15" Stretch="Uniform" Margin="0,0,10,0"
                                      Fill="{StaticResource BrushAccentDark}" Data="{TemplateBinding Tag}"/>
                                <TextBlock x:Name="PART_Text" Text="{TemplateBinding Content}"
                                           Foreground="{StaticResource BrushAccentDark}" VerticalAlignment="Center"/>
                            </StackPanel>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="{StaticResource BrushDanger}"/>
                                <Setter TargetName="PART_Icon" Property="Fill" Value="White"/>
                                <Setter TargetName="PART_Text" Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Bd" Property="Opacity" Value="0.5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="PrimaryButton" TargetType="Button">
            <Setter Property="Height" Value="34"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Bd" CornerRadius="8">
                            <Border.Background>
                                <LinearGradientBrush StartPoint="1,0" EndPoint="0,0">
                                    <GradientStop Color="#208AD0" Offset="0"/>
                                    <GradientStop Color="#03173D" Offset="1"/>
                                </LinearGradientBrush>
                            </Border.Background>
                            <Border.Effect>
                                <DropShadowEffect BlurRadius="8" ShadowDepth="1" Opacity="0.18" Color="#03173D"/>
                            </Border.Effect>
                            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center">
                                <Path Width="15" Height="15" Stretch="Uniform" Margin="0,0,10,0" Fill="White" Data="{TemplateBinding Tag}"/>
                                <TextBlock Text="{TemplateBinding Content}" Foreground="White" FontWeight="SemiBold" VerticalAlignment="Center"/>
                            </StackPanel>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Opacity" Value="0.9"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Bd" Property="Opacity" Value="0.5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="KeyInput" TargetType="TextBox">
            <Setter Property="FontFamily" Value="Consolas"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Padding" Value="8,6"/>
            <Setter Property="Foreground" Value="{StaticResource BrushAccentDark}"/>
            <Setter Property="Background" Value="{StaticResource BrushCard}"/>
            <Setter Property="BorderBrush" Value="{StaticResource BrushBorder}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TextBox">
                        <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6">
                            <ScrollViewer x:Name="PART_ContentHost" Margin="{TemplateBinding Padding}"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ListBoxItem">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ListBoxItem">
                        <ContentPresenter Margin="0,1"/>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Background="{StaticResource BrushBg}">
        <Grid.RowDefinitions>
            <RowDefinition Height="110"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="30"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <Grid x:Name="HeaderGrid" Grid.Row="0">
            <Grid.Background>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                    <GradientStop Color="#208AD0" Offset="0"/>
                    <GradientStop Color="#03173D" Offset="1"/>
                </LinearGradientBrush>
            </Grid.Background>
            <Image x:Name="ImgLogo" Width="230" Height="98" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="14,5,0,0" Stretch="Uniform"/>
            <TextBlock x:Name="TxtLogoFallback" Text="EOO" Foreground="White" FontSize="22" FontWeight="Bold"
                       HorizontalAlignment="Left" VerticalAlignment="Top" Margin="20,24,0,0" Visibility="Collapsed"/>
            <TextBlock Text="Windows Installatie Tool" Foreground="White" FontSize="14"
                       HorizontalAlignment="Left" VerticalAlignment="Top" Margin="252,50,0,0"/>
            <TextBlock x:Name="TxtVersion" Foreground="#CBD5E1" FontSize="11"
                       HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,88,16,0"/>
            <Border Height="3" VerticalAlignment="Bottom" Background="{StaticResource BrushAccent}"/>
        </Grid>

        <!-- Content: links infopanel + acties, rechts console -->
        <Grid Grid.Row="1">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*" MinWidth="420"/>
                <ColumnDefinition Width="3"/>
                <ColumnDefinition Width="*" MinWidth="200"/>
            </Grid.ColumnDefinitions>

            <ScrollViewer Grid.Column="0" VerticalScrollBarVisibility="Auto" Background="{StaticResource BrushBg}">
                <StackPanel Margin="22,14,22,20" MaxWidth="500" HorizontalAlignment="Left">

                    <Border Background="{StaticResource BrushCard}" BorderBrush="{StaticResource BrushBorder}" BorderThickness="1" CornerRadius="10" Padding="16">
                        <Border.Effect>
                            <DropShadowEffect BlurRadius="10" ShadowDepth="1" Opacity="0.06" Color="#000000"/>
                        </Border.Effect>
                        <DockPanel LastChildFill="True">
                            <TextBlock x:Name="TxtRefresh" DockPanel.Dock="Bottom" Text="&#8635; Vernieuwen"
                                       Foreground="{StaticResource BrushAccent}" FontSize="11" HorizontalAlignment="Right"
                                       Margin="0,8,0,0" Cursor="Hand"/>
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="70"/>
                                </Grid.ColumnDefinitions>
                                <StackPanel x:Name="InfoRows" Grid.Column="0"/>
                                <TextBlock x:Name="TxtBigStatus" Grid.Column="1" Text="" FontSize="40" FontWeight="Bold"
                                           Foreground="{StaticResource BrushAccent}" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Grid>
                        </DockPanel>
                    </Border>

                    <!-- Systeem -->
                    <TextBlock Text="Systeem" Style="{StaticResource SectionTitle}"/>
                    <Border Height="1" Background="{StaticResource BrushBorder}" Margin="0,0,0,10"/>
                    <Grid Margin="0,0,0,8">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="8"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Button x:Name="BtnRestart" Grid.Column="0" Content="Herstarten" Style="{StaticResource OutlineButton}"/>
                        <Button x:Name="BtnShutdown" Grid.Column="2" Content="Afsluiten" Style="{StaticResource DangerOutlineButton}"/>
                    </Grid>
                    <Button x:Name="BtnBios" Content="Herstart naar BIOS/UEFI" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>
                    <Button x:Name="BtnWU" Content="Windows Update openen" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>
                    <Button x:Name="BtnDM" Content="Apparaatbeheer openen" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>
                    <Button x:Name="BtnAW" Content="Windows activeren" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>
                    <Button x:Name="BtnWifi" Content="WiFi instellen: EOO_Install" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>

                    <TextBlock Text="Productsleutel" FontWeight="SemiBold" Foreground="{StaticResource BrushAccent}" Margin="0,10,0,6" FontSize="12"/>
                    <TextBox x:Name="TxtKey" Style="{StaticResource KeyInput}" MaxLength="29" Margin="0,0,0,8" HorizontalAlignment="Left" Width="300"/>
                    <Button x:Name="BtnActivateKey" Content="Activeren met sleutel" Style="{StaticResource PrimaryButton}" Margin="0,0,0,8"/>

                    <!-- Drivers -->
                    <TextBlock Text="Drivers" Style="{StaticResource SectionTitle}"/>
                    <Border Height="1" Background="{StaticResource BrushBorder}" Margin="0,0,0,10"/>
                    <Button x:Name="BtnLSU" Content="Lenovo System Update installeren" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>
                    <Button x:Name="BtnHPIA" Content="HP Image Assistant installeren en draaien" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>

                    <!-- Autopilot -->
                    <TextBlock Text="Autopilot" Style="{StaticResource SectionTitle}"/>
                    <Border Height="1" Background="{StaticResource BrushBorder}" Margin="0,0,0,10"/>
                    <Button x:Name="BtnHWIDOvr" Content="HWID Export - Overwrite (per device)" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>
                    <Button x:Name="BtnHWIDApp" Content="HWID Export - Append (bulk CSV)" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>

                    <!-- Azure opslag -->
                    <TextBlock Text="Azure opslag" Style="{StaticResource SectionTitle}"/>
                    <Border Height="1" Background="{StaticResource BrushBorder}" Margin="0,0,0,10"/>
                    <Button x:Name="BtnAzureMount" Content="Azure opslag koppelen (X:)" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>

                    <!-- Rapport -->
                    <TextBlock Text="Rapport" Style="{StaticResource SectionTitle}"/>
                    <Border Height="1" Background="{StaticResource BrushBorder}" Margin="0,0,0,10"/>
                    <Button x:Name="BtnExportPDF" Content="Rapport exporteren als PDF" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>
                </StackPanel>
            </ScrollViewer>

            <GridSplitter Grid.Column="1" Width="3" HorizontalAlignment="Stretch" Background="#808080" ResizeBehavior="PreviousAndNext"/>

            <Grid Grid.Column="2" Background="{StaticResource BrushAccentDark}">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                <TextBlock Text="Uitvoer" Foreground="White" FontWeight="Bold" Margin="12,10,0,6"/>
                <ListBox x:Name="LstConsole" Grid.Row="1" Background="Transparent" BorderThickness="0"
                         FontFamily="Consolas" FontSize="12" Margin="8,0,8,8" ScrollViewer.HorizontalScrollBarVisibility="Disabled"/>
            </Grid>
        </Grid>

        <!-- Footer -->
        <Grid Grid.Row="2" Background="{StaticResource BrushCard}">
            <Border Height="1" VerticalAlignment="Top" Background="{StaticResource BrushBorder}"/>
            <TextBlock Text="Easy Office Online  |  eoo.nl" Foreground="{StaticResource BrushSubText}" FontSize="11"
                       HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,0,0,0"/>
            <TextBlock x:Name="TxtDate" Foreground="{StaticResource BrushSubText}" FontSize="11"
                       HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,10,0"/>
        </Grid>
    </Grid>
</Window>
'@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# ── Elementen ophalen ──────────────────────────────────────────────
$headerGrid      = $window.FindName('HeaderGrid')
$imgLogo         = $window.FindName('ImgLogo')
$txtLogoFallback = $window.FindName('TxtLogoFallback')
$txtVersion      = $window.FindName('TxtVersion')
$txtDate         = $window.FindName('TxtDate')
$infoRows        = $window.FindName('InfoRows')
$txtBigStatus    = $window.FindName('TxtBigStatus')
$txtRefresh      = $window.FindName('TxtRefresh')
$lstConsole      = $window.FindName('LstConsole')

$btnRestart      = $window.FindName('BtnRestart')
$btnShutdown     = $window.FindName('BtnShutdown')
$btnBios         = $window.FindName('BtnBios')
$btnWU           = $window.FindName('BtnWU')
$btnDM           = $window.FindName('BtnDM')
$btnAW           = $window.FindName('BtnAW')
$btnWifi         = $window.FindName('BtnWifi')
$txtKey          = $window.FindName('TxtKey')
$btnActivateKey  = $window.FindName('BtnActivateKey')
$btnLSU          = $window.FindName('BtnLSU')
$btnHPIA         = $window.FindName('BtnHPIA')
$btnHWIDOvr      = $window.FindName('BtnHWIDOvr')
$btnHWIDApp      = $window.FindName('BtnHWIDApp')
$btnAzureMount   = $window.FindName('BtnAzureMount')
$btnExportPDF    = $window.FindName('BtnExportPDF')

$txtVersion.Text = "v$script:currentVersion - $script:versionName"
$txtDate.Text     = (Get-Date -Format 'dd-MM-yyyy')

# ── Vector-iconen (Material Design paden) ──────────────────────────
$iconPaths = @{
    Restart  = 'M17.65,6.35C16.2,4.9 14.21,4 12,4c-4.42,0 -7.99,3.58 -7.99,8s3.57,8 7.99,8c3.73,0 6.84,-2.55 7.73,-6h-2.08c-0.82,2.33 -3.04,4 -5.65,4 -3.31,0 -6,-2.69 -6,-6s2.69,-6 6,-6c1.66,0 3.14,0.69 4.22,1.78L13,11h7V4L17.65,6.35z'
    Power    = 'M13,3h-2v10h2V3z M17.83,5.17l-1.42,1.42C17.99,7.86,19,9.81,19,12c0,3.87-3.13,7-7,7s-7-3.13-7-7c0-2.19,1.01-4.14,2.58-5.42L6.17,5.17C4.23,6.82,3,9.26,3,12c0,4.97,4.03,9,9,9s9-4.03,9-9C21,9.26,19.77,6.82,17.83,5.17z'
    Windows  = 'M3,12V6.75L9,5.43V11.91L3,12M20,3V11.75L10,11.9V5.21L20,3M3,13L9,13.09V19.9L3,18.75V13M20,13.25V22L10,20.09V13.1L20,13.25Z'
    Gear     = 'M12,15.5A3.5,3.5 0 0,1 8.5,12A3.5,3.5 0 0,1 12,8.5A3.5,3.5 0 0,1 15.5,12A3.5,3.5 0 0,1 12,15.5M19.43,12.97C19.47,12.65 19.5,12.33 19.5,12C19.5,11.67 19.47,11.34 19.43,11L21.54,9.37C21.73,9.22 21.78,8.95 21.66,8.73L19.66,5.27C19.54,5.05 19.27,4.96 19.05,5.05L16.56,6.05C16.04,5.66 15.5,5.32 14.87,5.07L14.5,2.42C14.46,2.18 14.25,2 14,2H10C9.75,2 9.54,2.18 9.5,2.42L9.13,5.07C8.5,5.32 7.96,5.66 7.44,6.05L4.95,5.05C4.73,4.96 4.46,5.05 4.34,5.27L2.34,8.73C2.22,8.95 2.27,9.22 2.46,9.37L4.57,11C4.53,11.34 4.5,11.67 4.5,12C4.5,12.33 4.53,12.65 4.57,12.97L2.46,14.63C2.27,14.78 2.22,15.05 2.34,15.27L4.34,18.73C4.46,18.95 4.73,19.03 4.95,18.95L7.44,17.94C7.96,18.34 8.5,18.68 9.13,18.93L9.5,21.58C9.54,21.82 9.75,22 10,22H14C14.25,22 14.46,21.82 14.5,21.58L14.87,18.93C15.5,18.67 16.04,18.34 16.56,17.94L19.05,18.95C19.27,19.03 19.54,18.95 19.66,18.73L21.66,15.27C21.78,15.05 21.73,14.78 21.54,14.63L19.43,12.97Z'
    Key      = 'M7,14A2,2 0 0,1 5,12A2,2 0 0,1 7,10A2,2 0 0,1 9,12A2,2 0 0,1 7,14M12.65,10C11.83,7.67 9.61,6 7,6A6,6 0 0,0 1,12A6,6 0 0,0 7,18C9.61,18 11.83,16.33 12.65,14H17V18H21V14H23V10H12.65Z'
    Wifi     = 'M12,21L15.6,16.2C14.6,15.45 13.35,15 12,15C10.65,15 9.4,15.45 8.4,16.2L12,21M12,3C7.95,3 4.21,4.34 1.2,6.6L3,9C5.5,7.12 8.62,6 12,6C15.38,6 18.5,7.12 21,9L22.8,6.6C19.79,4.34 16.05,3 12,3M12,9C9.3,9 6.81,9.89 4.8,11.4L6.6,13.8C8.1,12.67 9.97,12 12,12C14.03,12 15.9,12.67 17.4,13.8L19.2,11.4C17.19,9.89 14.7,9 12,9Z'
    Cloud    = 'M19.35,10.04C18.67,6.59 15.64,4 12,4C9.11,4 6.6,5.64 5.35,8.04C2.34,8.36 0,10.91 0,14A6,6 0 0,0 6,20H19A5,5 0 0,0 24,15C24,12.36 21.95,10.22 19.35,10.04Z'
    Download = 'M5,20H19V18H5M19,9H15V3H9V9H5L12,16L19,9Z'
    Play     = 'M8,5V19L19,12L8,5Z'
}
function Get-IconGeometry { param([string]$Name) [System.Windows.Media.Geometry]::Parse($iconPaths[$Name]) }

$btnRestart.Tag     = Get-IconGeometry Restart
$btnShutdown.Tag    = Get-IconGeometry Power
$btnBios.Tag        = Get-IconGeometry Restart
$btnWU.Tag          = Get-IconGeometry Windows
$btnDM.Tag          = Get-IconGeometry Gear
$btnAW.Tag          = Get-IconGeometry Key
$btnWifi.Tag        = Get-IconGeometry Wifi
$btnActivateKey.Tag = Get-IconGeometry Key
$btnLSU.Tag         = Get-IconGeometry Play
$btnHPIA.Tag        = Get-IconGeometry Play
$btnHWIDOvr.Tag     = Get-IconGeometry Download
$btnHWIDApp.Tag     = Get-IconGeometry Download
$btnAzureMount.Tag  = Get-IconGeometry Cloud
$btnExportPDF.Tag   = Get-IconGeometry Download

# ── Logo laden (WPF-weergave + los GDI+-exemplaar t.b.v. PDF-export) ─
try {
    $logoBytes = (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Easy-Office-Online/software/refs/heads/main/EOO_Logo_rgb2.png' -UseBasicParsing).Content

    $msWpf = New-Object System.IO.MemoryStream(, [byte[]]$logoBytes)
    $bmpWpf = New-Object System.Windows.Media.Imaging.BitmapImage
    $bmpWpf.BeginInit(); $bmpWpf.StreamSource = $msWpf; $bmpWpf.CacheOption = 'OnLoad'; $bmpWpf.EndInit()
    $imgLogo.Source = $bmpWpf

    # Stream bewust NIET disposen: System.Drawing.Image.FromStream blijft de stream gebruiken.
    $script:logoGdiStream = New-Object System.IO.MemoryStream(, [byte[]]$logoBytes)
    $script:logoImageGdi  = [System.Drawing.Image]::FromStream($script:logoGdiStream)
} catch {
    $imgLogo.Visibility = 'Collapsed'
    $txtLogoFallback.Visibility = 'Visible'
    $script:logoImageGdi = $null
}

# ── Console-log helper ─────────────────────────────────────────────
$brushConsole = @{
    'ok'      = $window.FindResource('BrushConsoleOk')
    'error'   = $window.FindResource('BrushConsoleError')
    'start'   = $window.FindResource('BrushConsoleStart')
    'default' = $window.FindResource('BrushConsoleDefault')
}
function Write-Console {
    param([string]$Message, [string]$Type = 'default')
    $brush = if ($brushConsole.ContainsKey($Type)) { $brushConsole[$Type] } else { $brushConsole['default'] }
    $time  = Get-Date -Format 'HH:mm:ss'
    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text         = "[$time] $Message"
    $tb.Foreground   = $brush
    $tb.TextWrapping = 'Wrap'
    [void]$lstConsole.Items.Add($tb)
    $lstConsole.ScrollIntoView($tb)
}

# ── Easter egg: 5x klikken op het logo -> Raphael-kopje knipoogt en verdwijnt ─
function Show-NinjaTurtleEasterEgg {
    $art = New-Object System.Windows.Controls.Canvas
    $art.Width = 76; $art.Height = 64
    $art.HorizontalAlignment = 'Left'
    $art.VerticalAlignment = 'Top'
    $art.Margin = [System.Windows.Thickness]::new(552, 2, 0, 0)
    $art.RenderTransformOrigin = [System.Windows.Point]::new(0.5, 0.5)
    $scale = New-Object System.Windows.Media.ScaleTransform(0, 0)
    $art.RenderTransform = $scale
    [void]$headerGrid.Children.Add($art)

    $black = [System.Windows.Media.Brushes]::Black
    $white = [System.Windows.Media.Brushes]::White
    $green = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(0x6E, 0xBE, 0x4A))
    $red   = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(0xE8, 0x38, 0x2E))

    function New-EggShape {
        param([string]$Type, [double]$W, [double]$H, [double]$X, [double]$Y, $Fill,
              [double]$StrokeThickness = 2.5, [double]$Radius = 0, [double]$Rotate = 0)
        $s = New-Object $Type
        $s.Width = $W; $s.Height = $H
        if ($Fill) { $s.Fill = $Fill }
        $s.Stroke = $black
        $s.StrokeThickness = $StrokeThickness
        if ($Type -eq 'System.Windows.Shapes.Rectangle') { $s.RadiusX = $Radius; $s.RadiusY = $Radius }
        if ($Rotate -ne 0) {
            $s.RenderTransformOrigin = [System.Windows.Point]::new(0.5, 0.5)
            $s.RenderTransform = New-Object System.Windows.Media.RotateTransform($Rotate)
        }
        [System.Windows.Controls.Canvas]::SetLeft($s, $X)
        [System.Windows.Controls.Canvas]::SetTop($s, $Y)
        [void]$art.Children.Add($s)
        return $s
    }
    function New-EggPath {
        param([string]$Data, [double]$StrokeThickness = 2.5)
        $p = New-Object System.Windows.Shapes.Path
        $p.Data = [System.Windows.Media.Geometry]::Parse($Data)
        $p.Stroke = $black
        $p.StrokeThickness = $StrokeThickness
        $p.StrokeStartLineCap = 'Round'; $p.StrokeEndLineCap = 'Round'
        [void]$art.Children.Add($p)
        return $p
    }

    # Twee bandana-staartjes (achter de knoop), dan de kop, dan band + knoop erover
    New-EggShape 'System.Windows.Shapes.Rectangle' 8 26 2 28 $red -Radius 4 -Rotate -25 | Out-Null
    New-EggShape 'System.Windows.Shapes.Rectangle' 8 20 6 34 $red -Radius 4 -Rotate 12  | Out-Null
    New-EggShape 'System.Windows.Shapes.Ellipse'   52 48 20 2 $green | Out-Null
    New-EggShape 'System.Windows.Shapes.Rectangle' 54 15 19 19 $red -Radius 6 | Out-Null
    New-EggShape 'System.Windows.Shapes.Ellipse'   15 15 10 20 $red | Out-Null

    # Ogen: wit met zwarte pupil + opgetrokken wenkbrauw (het "brutale" Raphael-kijkje)
    $eyeL = New-EggShape 'System.Windows.Shapes.Ellipse' 13 11 28 21 $white -StrokeThickness 2
    New-EggShape 'System.Windows.Shapes.Ellipse' 5 5 32 25 $black -StrokeThickness 0 | Out-Null
    $eyeR = New-EggShape 'System.Windows.Shapes.Ellipse' 13 11 50 20 $white -StrokeThickness 2
    $pupilR = New-EggShape 'System.Windows.Shapes.Ellipse' 5 5 54 24 $black -StrokeThickness 0

    New-EggPath -Data 'M 26,20 Q 34,14 43,19' | Out-Null
    New-EggPath -Data 'M 48,17 Q 57,11 66,18' | Out-Null

    # Glimlach
    New-EggPath -Data 'M 34,42 Q 46,50 60,40' | Out-Null
    New-EggPath -Data 'M 56,38 Q 60,42 62,38' -StrokeThickness 1.5 | Out-Null

    # Pop-in van de hele kop
    $pop = New-Object System.Windows.Media.Animation.DoubleAnimation(0, 1, (New-Object System.Windows.Duration([TimeSpan]::FromMilliseconds(350))))
    $pop.EasingFunction = New-Object System.Windows.Media.Animation.BackEase
    $pop.EasingFunction.EasingMode = 'EaseOut'
    $scale.BeginAnimation([System.Windows.Media.ScaleTransform]::ScaleXProperty, $pop)
    $scale.BeginAnimation([System.Windows.Media.ScaleTransform]::ScaleYProperty, $pop.Clone())

    # Knipoog: rechteroog + pupil knijpen samen dicht (delen dezelfde transform) tussen 500-850ms
    $eyeRScale = New-Object System.Windows.Media.ScaleTransform(1, 1)
    $eyeR.RenderTransformOrigin = [System.Windows.Point]::new(0.5, 0.5)
    $eyeR.RenderTransform = $eyeRScale
    $pupilR.RenderTransformOrigin = [System.Windows.Point]::new(0.5, 0.5)
    $pupilR.RenderTransform = $eyeRScale

    $winkAnim = New-Object System.Windows.Media.Animation.DoubleAnimationUsingKeyFrames
    foreach ($kf in @(@{ V = 1; T = 0 }, @{ V = 0.08; T = 500 }, @{ V = 0.08; T = 700 }, @{ V = 1; T = 850 })) {
        [void]$winkAnim.KeyFrames.Add((New-Object System.Windows.Media.Animation.LinearDoubleKeyFrame($kf.V, [System.Windows.Media.Animation.KeyTime]::FromTimeSpan([TimeSpan]::FromMilliseconds($kf.T)))))
    }
    $eyeRScale.BeginAnimation([System.Windows.Media.ScaleTransform]::ScaleYProperty, $winkAnim)

    # Na 1,6s vervagen en daarna in één keer opruimen
    $exit = New-Object System.Windows.Media.Animation.DoubleAnimation(1, 0, (New-Object System.Windows.Duration([TimeSpan]::FromMilliseconds(400))))
    $exit.BeginTime = [TimeSpan]::FromMilliseconds(1600)
    $exit.Add_Completed({ $headerGrid.Children.Remove($art) }.GetNewClosure())
    $art.BeginAnimation([System.Windows.Controls.Canvas]::OpacityProperty, $exit)

    Write-Console "Easter egg gevonden: Raphael knipoogt en verdwijnt weer. $([char]::ConvertFromUtf32(0x1F422))" 'ok'
}

$script:logoClickCount = 0
$logoClickHandler = {
    $script:logoClickCount++
    if ($script:logoClickCount -ge 5) {
        $script:logoClickCount = 0
        Show-NinjaTurtleEasterEgg
    }
}
$imgLogo.Add_MouseLeftButtonUp($logoClickHandler)
$txtLogoFallback.Add_MouseLeftButtonUp($logoClickHandler)

# ── Herbruikbare achtergrondtaak-helper (Start-Job + DispatcherTimer) ─
# Jobs/timers staan in $script:eooJobs zodat de Tick-handler ze altijd
# via scriptscope opnieuw opzoekt (lokale closures over WinForms/WPF
# Timer-events zijn onbetrouwbaar gebleken bij eerdere EOO-tools).
$script:eooJobs = @{}
function Start-EOOJob {
    param(
        [string]$Key,
        [scriptblock]$ScriptBlock,
        [object[]]$ArgumentList = @(),
        [scriptblock]$OnOutput,
        [scriptblock]$OnError,
        [scriptblock]$OnComplete
    )
    $entry = @{ Job = (Start-Job -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList) }
    $script:eooJobs[$Key] = $entry

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(500)
    $timer.Add_Tick({
        $job = $entry.Job
        if (-not $job) { $timer.Stop(); return }
        foreach ($line in ($job.ChildJobs[0].Output.ReadAll())) { & $OnOutput $line }
        foreach ($e in ($job.ChildJobs[0].Error.ReadAll())) { if ($OnError) { & $OnError $e } }
        if ($job.State -in 'Completed', 'Failed') {
            $timer.Stop()
            $succeeded = $job.State -eq 'Completed'
            $reason = if (-not $succeeded) { $job.ChildJobs[0].JobStateInfo.Reason.Message } else { $null }
            Remove-Job $job -Force
            if ($script:eooJobs) { $script:eooJobs.Remove($Key) }
            if ($OnComplete) { & $OnComplete $succeeded $reason }
        }
    }.GetNewClosure())
    $entry.Timer = $timer
    $timer.Start()
}

# ── Infopanel: rij-helper ──────────────────────────────────────────
$script:infoRowMap = @{}
function New-InfoRow {
    param([string]$Key)
    $row = New-Object System.Windows.Controls.StackPanel
    $row.Orientation = 'Horizontal'
    $row.Margin = '0,0,0,7'

    $icon = New-Object System.Windows.Controls.TextBlock
    $icon.Width = 20
    $icon.FontWeight = 'Bold'
    $icon.FontSize = 13
    $icon.Foreground = $window.FindResource('BrushAccent')
    $icon.Text = '-'

    $label = New-Object System.Windows.Controls.TextBlock
    $label.Foreground = $window.FindResource('BrushSubText')
    $label.FontSize = 12
    $label.VerticalAlignment = 'Center'
    $label.TextWrapping = 'Wrap'

    [void]$row.Children.Add($icon)
    [void]$row.Children.Add($label)
    [void]$infoRows.Children.Add($row)
    $script:infoRowMap[$Key] = @{ Icon = $icon; Label = $label }
}
'Windows', 'Activatie', 'Tpm', 'SecureBoot', 'Internet', 'HP', 'Laptop', 'Wifi', 'Serienummer' |
    ForEach-Object { New-InfoRow $_ }

function Set-InfoRow {
    param([string]$Key, [string]$Text, [bool]$OK, [switch]$Neutral)
    $row = $script:infoRowMap[$Key]
    $row.Label.Text = $Text
    if ($Neutral -or $OK) {
        $row.Icon.Text = [char]0x2713
        $row.Icon.Foreground = $window.FindResource('BrushAccent')
    } else {
        $row.Icon.Text = '!'
        $row.Icon.Foreground = $window.FindResource('BrushDanger')
    }
}

# ── Systeemchecks (zelfde logica als WinForms v6) ──────────────────
$script:okActivation = $false; $script:okTpm = $false; $script:okSecureBoot = $false
$script:okInternet   = $false; $script:okWifi = $false; $script:hpBloatFound = @()

function Update-InfoPanel {
    try {
        $osInfo = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
        $pn = $osInfo.ProductName; $dv = $osInfo.DisplayVersion; $bn = [int]$osInfo.CurrentBuildNumber
        if ($bn -ge 22000) { $pn = $pn -replace '10', '11' }
        Set-InfoRow 'Windows' "$pn $dv (Build $bn)" $true -Neutral
    } catch { Set-InfoRow 'Windows' 'Windows-versie onbekend' $false }

    try {
        $lic = Get-CimInstance -Query "SELECT LicenseStatus FROM SoftwareLicensingProduct WHERE PartialProductKey IS NOT NULL AND LicenseStatus=1"
        $script:okActivation = [bool]$lic
        Set-InfoRow 'Activatie' $(if ($lic) { 'Geactiveerd' } else { 'Niet geactiveerd' }) $script:okActivation
    } catch { $script:okActivation = $false; Set-InfoRow 'Activatie' 'Activatie: controlefout' $false }

    try {
        $tpm = Get-CimInstance -Namespace 'Root\CIMv2\Security\MicrosoftTpm' -ClassName Win32_Tpm -ErrorAction Stop
        $script:okTpm = [bool]$tpm
        $tekst = if ($tpm -and $tpm.SpecVersion) { "TPM aanwezig (versie $($tpm.SpecVersion))" } elseif ($tpm) { 'TPM aanwezig (versie onbekend)' } else { 'Geen TPM gevonden' }
        Set-InfoRow 'Tpm' $tekst $script:okTpm
    } catch { $script:okTpm = $false; Set-InfoRow 'Tpm' 'Geen TPM gevonden' $false }

    try {
        if (Get-Command -Name 'Confirm-SecureBootUEFI' -ErrorAction SilentlyContinue) {
            $script:okSecureBoot = [bool](Confirm-SecureBootUEFI)
            Set-InfoRow 'SecureBoot' $(if ($script:okSecureBoot) { 'Secure Boot ingeschakeld' } else { 'Secure Boot uitgeschakeld' }) $script:okSecureBoot
        } else {
            $script:okSecureBoot = $false
            Set-InfoRow 'SecureBoot' 'Secure Boot: niet ondersteund op dit platform' $false
        }
    } catch { $script:okSecureBoot = $false; Set-InfoRow 'SecureBoot' 'Secure Boot: geen UEFI systeem' $false }

    $script:okInternet = [bool](Test-Connection -ComputerName 'google.nl' -Count 1 -Quiet -ErrorAction SilentlyContinue)
    Set-InfoRow 'Internet' $(if ($script:okInternet) { 'Internetverbinding aanwezig' } else { 'Geen internetverbinding' }) $script:okInternet

    $hpBloatNames = @(
        'HP Wolf Security', 'HP Wolf Security Application Support for Chrome', 'HP Wolf Security Application Support for Windows',
        'HP Sure Click', 'HP Sure Sense', 'HP Sure Connect', 'HP Sure Start', 'HP Sure View', 'HP Support Assistant',
        'HP Jumpstart', 'HP Instant Ink', 'HP Audio Switch', 'HP Documentation', 'HP Notifications',
        'HP PC Hardware Diagnostics', 'HP Privacy Settings', 'HP Smart', 'myHP', 'Poly Lens', 'HP LAN/WLAN Management'
    )
    $regPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $found = @()
    Get-ItemProperty $regPaths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } | ForEach-Object {
        foreach ($bloat in $hpBloatNames) { if ($_.DisplayName -like "*$bloat*") { $found += $_.DisplayName; break } }
    }
    try {
        Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue |
            Where-Object { $_.Publisher -like '*HP Inc*' -or $_.Publisher -like '*Hewlett*' } |
            ForEach-Object { $found += $_.Name }
    } catch {}
    $script:hpBloatFound = $found
    Set-InfoRow 'HP' $(if ($found.Count -eq 0) { 'Geen HP bloatware gevonden' } else { "HP bloatware: $($found.Count) app(s) gevonden" }) ($found.Count -eq 0)

    try {
        $chassis = (Get-CimInstance Win32_SystemEnclosure).ChassisTypes
        $isLaptop = $chassis | Where-Object { $_ -in 8, 9, 10, 11, 12, 14, 18, 21, 30, 31, 32 }
        Set-InfoRow 'Laptop' "Apparaattype: $(if ($isLaptop) { 'Laptop' } else { 'Desktop' })" $true -Neutral
    } catch { Set-InfoRow 'Laptop' 'Apparaattype: onbekend' $false }

    try {
        $wifi = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.MediaType -eq '802.11' -or $_.InterfaceDescription -match 'wi.?fi|wireless|802\.11' }
        $script:okWifi = [bool]$wifi
        Set-InfoRow 'Wifi' $(if ($wifi) { "WiFi adapter aanwezig: $((($wifi | Select-Object -First 1).InterfaceDescription))" } else { 'Geen WiFi adapter gevonden' }) $script:okWifi
    } catch { $script:okWifi = $false; Set-InfoRow 'Wifi' 'WiFi adapter: controlefout' $false }

    try {
        $serial = (Get-CimInstance Win32_BIOS).SerialNumber.Trim()
        if (-not $serial) { $serial = 'ONBEKEND' }
        Set-InfoRow 'Serienummer' "Serienummer: $serial" $true -Neutral
    } catch { Set-InfoRow 'Serienummer' 'Serienummer: onbekend' $false }

    if ($script:okActivation -and $script:okTpm -and $script:okSecureBoot -and $script:okInternet) {
        $txtBigStatus.Text = [char]0x2713
        $txtBigStatus.Foreground = $window.FindResource('BrushAccent')
    } else {
        $txtBigStatus.Text = '!'
        $txtBigStatus.Foreground = $window.FindResource('BrushDanger')
    }
}

$txtRefresh.Add_MouseLeftButtonUp({
    Update-InfoPanel
    Write-Console 'Infopaneel vernieuwd.' 'info'
})

# ── Sectie: Systeem ─────────────────────────────────────────────────
$btnRestart.Add_Click({
    if ([System.Windows.MessageBox]::Show('Systeem nu herstarten?', 'Herstarten bevestigen', 'YesNo', 'Warning') -ne 'Yes') { return }
    Write-Console 'Systeem wordt herstart...' 'start'
    Start-Process PowerShell -ArgumentList '-Command shutdown.exe /r /t 0' -NoNewWindow
})

$btnShutdown.Add_Click({
    if ([System.Windows.MessageBox]::Show('Systeem nu afsluiten?', 'Afsluiten bevestigen', 'YesNo', 'Warning') -ne 'Yes') { return }
    Write-Console 'Systeem wordt afgesloten...' 'start'
    Start-Process PowerShell -ArgumentList '-Command shutdown.exe /s /t 0' -NoNewWindow
})

$btnBios.Add_Click({
    if ([System.Windows.MessageBox]::Show('Nu herstarten naar BIOS/UEFI-instellingen?', 'BIOS-herstart bevestigen', 'YesNo', 'Warning') -ne 'Yes') { return }
    Write-Console 'Systeem wordt herstart naar BIOS/UEFI-instellingen...' 'start'
    $shutdownExe = "$env:windir\System32\shutdown.exe"
    Start-Process -FilePath $shutdownExe -ArgumentList '/a' -NoNewWindow -Wait -ErrorAction SilentlyContinue
    $errFile = "$env:TEMP\eoo_bios_reboot_err.txt"
    $p = Start-Process -FilePath $shutdownExe -ArgumentList '/r', '/fw', '/t', '0' -NoNewWindow -Wait -PassThru -RedirectStandardError $errFile
    if ($p.ExitCode -ne 0) {
        $errMsg = if (Test-Path $errFile) { (Get-Content $errFile -Raw).Trim() } else { '' }
        Write-Console "FOUT: BIOS-herstart mislukt (exit code $($p.ExitCode)). $errMsg" 'error'
    }
    Remove-Item $errFile -Force -ErrorAction SilentlyContinue
})

$btnWU.Add_Click({ Write-Console 'Windows Update instellingen openen...' 'start'; Start-Process 'ms-settings:windowsupdate' })
$btnDM.Add_Click({ Write-Console 'Apparaatbeheer openen...' 'start'; Start-Process 'devmgmt.msc' })
$btnAW.Add_Click({ Write-Console 'Windows activeringsscherm openen...' 'start'; Start-Process 'C:\Windows\System32\slui.exe' })

$btnWifi.Add_Click({
    $btnWifi.IsEnabled = $false
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
    if ($LASTEXITCODE -eq 0) { Write-Console "[OK] WiFi profiel '$ssid' toegevoegd." 'ok' } else { Write-Console "FOUT: $out" 'error' }
    $btnWifi.IsEnabled = $true
})

$txtKey.Add_TextChanged({
    $upper = $txtKey.Text.ToUpper()
    if ($txtKey.Text -cne $upper) {
        $pos = $txtKey.CaretIndex
        $txtKey.Text = $upper
        $txtKey.CaretIndex = $pos
    }
})

$btnActivateKey.Add_Click({
    $key = $txtKey.Text.Trim()
    if ($key -notmatch '^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$') {
        Write-Console 'Voer een geldige productsleutel in (XXXXX-XXXXX-XXXXX-XXXXX-XXXXX).' 'error'
        return
    }
    $btnActivateKey.IsEnabled = $false
    Write-Console "Productsleutel installeren: $key" 'start'
    Start-EOOJob -Key 'Activate' -ArgumentList @($key) -ScriptBlock {
        param($key)
        $r1 = & cscript.exe //B "$env:windir\system32\slmgr.vbs" /ipk $key 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Sleutel installeren mislukt: $r1" }
        Write-Output "[1/2] Sleutel geinstalleerd."
        $r2 = & cscript.exe //B "$env:windir\system32\slmgr.vbs" /ato 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Activatie mislukt: $r2" }
        Write-Output "[OK] Windows succesvol geactiveerd."
    } -OnOutput {
        param($line)
        if ($line -match '^\[OK\]') { Write-Console $line 'ok' } else { Write-Console $line 'info' }
    } -OnError {
        param($e) Write-Console "FOUT: $($e.Exception.Message)" 'error'
    } -OnComplete {
        param($succeeded, $reason)
        if (-not $succeeded) { Write-Console "FOUT: $reason" 'error' } else { Update-InfoPanel }
        $btnActivateKey.IsEnabled = $true
    }
})

# ── Sectie: Drivers ─────────────────────────────────────────────────
$btnLSU.Add_Click({
    $btnLSU.IsEnabled = $false
    $script:lsuSignal = $null
    Write-Console 'Lenovo System Update: gestart...' 'start'
    Start-EOOJob -Key 'LSU' -ScriptBlock {
        $configUrl = 'https://raw.githubusercontent.com/Easy-Office-Online/software/refs/heads/main/lenovoSU.txt'
        $raw     = (Invoke-WebRequest -Uri $configUrl -UseBasicParsing).Content
        $version = ($raw -split "`n" | Where-Object { $_ -match '^Version' }).Split('=')[1].Trim().Trim('"')
        $url     = ($raw -split "`n" | Where-Object { $_ -match '^URL' }).Split('=', 2)[1].Trim().Trim('"')
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
            $tvsu = (Get-ChildItem 'C:\Program Files (x86)\Lenovo\System Update\tvsu.exe', 'C:\Program Files\Lenovo\System Update\tvsu.exe' -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
        }
        Write-Output "SIGNAL:TVSU:$tvsu"
    } -OnOutput {
        param($line)
        if     ($line -match '^SIGNAL:')     { $script:lsuSignal = $line }
        elseif ($line -match '^\[OK\]')      { Write-Console $line 'ok' }
        elseif ($line -match 'FOUT|mislukt') { Write-Console $line 'error' }
        else                                 { Write-Console $line 'info' }
    } -OnError {
        param($e) Write-Console "FOUT: $($e.Exception.Message)" 'error'
    } -OnComplete {
        param($succeeded, $reason)
        if (-not $succeeded) {
            Write-Console "FOUT: $reason" 'error'
        } elseif ($script:lsuSignal -match '^SIGNAL:UPTODATE') {
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
        $btnLSU.IsEnabled = $true
    }
})

$btnHPIA.Add_Click({
    $btnHPIA.IsEnabled = $false
    Write-Console 'HP Image Assistant: gestart...' 'start'
    Start-EOOJob -Key 'HPIA' -ScriptBlock {
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
        # Nieuwere HPIA-wrapper (hpsoftpaqwrapper) extraheert niet meer standaard naar
        # C:\SWSetup zonder expliciete /f doelmap; exitcode 1168 is normale "wrapper noise".
        Start-Process -FilePath $filepath -ArgumentList '/s /e /f "C:\SWSetup"' -Wait

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
    } -OnOutput {
        param($line)
        if     ($line -match '^\[OK\]')      { Write-Console $line 'ok' }
        elseif ($line -match 'FOUT|mislukt') { Write-Console $line 'error' }
        else                                 { Write-Console $line 'info' }
    } -OnError {
        param($e) Write-Console "FOUT: $($e.Exception.Message)" 'error'
    } -OnComplete {
        param($succeeded, $reason)
        if (-not $succeeded) { Write-Console "FOUT: $reason" 'error' }
        $btnHPIA.IsEnabled = $true
    }
})

# ── Sectie: Autopilot ───────────────────────────────────────────────
$btnHWIDOvr.Add_Click({
    Write-Console 'HWID Export + Azure Files Upload (Overwrite) wordt gestart...' 'start'
    $content = $script_HWID_Overwrite.Replace('##STORAGEACCOUNT##', $script:afStorageAccount).Replace('##SHARENAME##', $script:afShareName).Replace('##KEY##', $script:afKey)
    $p = Write-TempScript -Content $content -Filename 'EOO_Get-HWID.ps1'
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$p`"" -Verb RunAs
    Write-Console 'HWID Azure Files Upload (Overwrite) gestart.' 'info'
})

$btnHWIDApp.Add_Click({
    Write-Console 'HWID Export + Azure Files Upload (Append) wordt gestart...' 'start'
    $content = $script_HWID_Append.Replace('##STORAGEACCOUNT##', $script:afStorageAccount).Replace('##SHARENAME##', $script:afShareName).Replace('##KEY##', $script:afKey)
    $p = Write-TempScript -Content $content -Filename 'EOO_Get-HWID_Aanvullen.ps1'
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$p`"" -Verb RunAs
    Write-Console 'HWID Azure Files Upload (Append) gestart.' 'info'
})

# ── Sectie: Azure opslag ────────────────────────────────────────────
# Zie EOO-WinInstall-GUIv6.ps1 voor de uitleg waarom de koppeling via
# een apart, zichtbaar cmd-venster (Shell.Application) loopt i.p.v.
# vanuit dit elevated proces: anders landt X: in de verkeerde
# tokencontext en is 'ie niet zichtbaar in de Verkenner van de
# ingelogde gebruiker (bv. defaultuser0 tijdens Autopilot ESP).
function Start-AzureMount {
    $sa = $script:afStorageAccount
    $sn = $script:afShareName
    $k  = $script:afKey

    if (Get-PSDrive -Name X -ErrorAction SilentlyContinue) { Remove-PSDrive -Name X -Force -ErrorAction SilentlyContinue }

    $cmdContent = @"
@echo off
title Azure opslag koppelen (X:)
net use X: /delete /y >nul 2>&1
cmdkey /add:"$sa.file.core.windows.net" /user:"localhost\$sa" /pass:"$k" >nul
echo Bezig met koppelen van \\$sa.file.core.windows.net\$sn aan X: ...
net use X: "\\$sa.file.core.windows.net\$sn" /persistent:yes
if %errorlevel% neq 0 (
    echo.
    echo Koppelen mislukt met foutcode %errorlevel%.
) else (
    echo.
    echo Azure opslag gekoppeld op X:
    start explorer.exe X:\
)
echo.
pause
"@
    $cmdPath = Write-TempScript -Content $cmdContent -Filename 'EOO_MapAzureDrive.cmd'

    $shell = New-Object -ComObject Shell.Application
    $shell.ShellExecute('cmd.exe', "/c `"$cmdPath`"", '', 'open', 1)
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell)

    Write-Console '  Venster geopend om X:\ te koppelen - volg de voortgang daar.' 'info'
    Write-Console '  Koppeling is persistent (blijft ook na herstart bestaan).' 'info'
    Write-Console '─────────────────────────────' 'info'
    $btnAzureMount.IsEnabled = $true
}

$btnAzureMount.Add_Click({
    $btnAzureMount.IsEnabled = $false
    Write-Console '─── Azure opslag koppelen ───' 'start'
    Write-Console "  Storage account : $($script:afStorageAccount)" 'info'
    Write-Console "  Share           : $($script:afShareName)" 'info'
    Write-Console "  UNC pad         : \\$($script:afStorageAccount).file.core.windows.net\$($script:afShareName)" 'info'
    Write-Console '  Poort 445 testen...' 'info'

    $script:portTestResult = $false
    Start-EOOJob -Key 'PortTest' -ArgumentList @($script:afStorageAccount) -ScriptBlock {
        param($sa)
        (Test-NetConnection -ComputerName "$sa.file.core.windows.net" -Port 445 -WarningAction SilentlyContinue).TcpTestSucceeded
    } -OnOutput {
        param($line) $script:portTestResult = [bool]$line
    } -OnComplete {
        param($succeeded, $reason)
        if (-not $succeeded -or -not $script:portTestResult) {
            Write-Console "FOUT: poort 445 niet bereikbaar bij $($script:afStorageAccount).file.core.windows.net." 'error'
            Write-Console '      Controleer firewall/ISP, of gebruik Azure P2S/S2S VPN of ExpressRoute.' 'info'
            Write-Console '─────────────────────────────' 'info'
            $btnAzureMount.IsEnabled = $true
            return
        }
        Write-Console '  Poort 445 bereikbaar, koppelen...' 'ok'
        Start-AzureMount
    }
})

# ── Sectie: Rapport ─────────────────────────────────────────────────
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
        $passClean   = ([regex]::Matches($html, '(?i)>\s*Pass\s*<')).Count
        $passRestart = ([regex]::Matches($html, '(?i)>\s*Pass\s+\*\s*<')).Count
        $failCount   = ([regex]::Matches($html, '(?i)>\s*Fail\s*<')).Count

        if (($passClean + $passRestart + $failCount) -gt 0) {
            $totalPass = $passClean + $passRestart
            if ($totalPass   -gt 0) { $counts['Geslaagd']         = $totalPass }
            if ($passRestart -gt 0) { $counts['Herstart vereist'] = $passRestart }
            if ($failCount   -gt 0) { $counts['Mislukt']          = $failCount }
        } else {
            if ($text -match '(?i)Missing\s+Drivers\s+(\d+)') { $counts['Ontbrekende drivers'] = [int]$matches[1] }
            if ($text -match '(?i)Missing\s+Drivers\s+\d+\s+Out-of-Date\s+(\d+)') { $counts['Verouderde drivers'] = [int]$matches[1] }
            $spList = [regex]::Matches($text, '(?i)\bsp\d{5,6}\b') | ForEach-Object { $_.Value.ToLower() } | Select-Object -Unique
            if ($spList.Count -gt 0) { $counts['Aanbevelingen'] = $spList.Count }
        }

        $bodyText = $text
        foreach ($kw in @('Drivers and Software', 'Installation Status', 'Recommendations')) {
            $pos = $text.IndexOf($kw, [System.StringComparison]::OrdinalIgnoreCase)
            if ($pos -ge 0) { $bodyText = $text.Substring($pos).Trim(); break }
        }
        return @{
            File = $latest.Name; Date = $latest.LastWriteTime.ToString('dd-MM-yyyy HH:mm')
            BodyText = $bodyText; Counts = $counts; HasFail = $failCount -gt 0; Restart = $passRestart -gt 0
        }
    } catch { return $null }
}

function Export-RapportPDF {
    $serial = try { (Get-CimInstance Win32_BIOS).SerialNumber.Trim() } catch { 'ONBEKEND' }
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    $safeSerial = $serial -replace '[\\/:*?"<>|]', '_'
    $fn = "EOO_Rapport_${safeSerial}_${ts}.pdf"
    $outputPath = Join-Path $env:TEMP $fn

    $pdfPrinterAvail = [bool]([System.Drawing.Printing.PrinterSettings]::InstalledPrinters | Where-Object { $_ -eq 'Microsoft Print to PDF' })
    if (-not $pdfPrinterAvail) {
        Write-Console 'FOUT: "Microsoft Print to PDF" printer niet gevonden op dit systeem.' 'error'
        $btnExportPDF.IsEnabled = $true
        return
    }

    $script:_pdfData = @{
        Serial = $serial; Computer = $env:COMPUTERNAME; Date = Get-Date -Format 'dd-MM-yyyy HH:mm:ss'
        Version = $script:currentVersion; Logo = $script:logoImageGdi
        Checks = @(
            @{ Label = $script:infoRowMap['Windows'].Label.Text;     OK = $null }
            @{ Label = $script:infoRowMap['Activatie'].Label.Text;   OK = $script:okActivation }
            @{ Label = $script:infoRowMap['Tpm'].Label.Text;         OK = $script:okTpm }
            @{ Label = $script:infoRowMap['SecureBoot'].Label.Text;  OK = $script:okSecureBoot }
            @{ Label = $script:infoRowMap['Internet'].Label.Text;    OK = $script:okInternet }
            @{ Label = $script:infoRowMap['HP'].Label.Text;          OK = ($script:hpBloatFound.Count -eq 0) }
            @{ Label = $script:infoRowMap['Laptop'].Label.Text;      OK = $null }
            @{ Label = $script:infoRowMap['Wifi'].Label.Text;        OK = $script:okWifi }
            @{ Label = $script:infoRowMap['Serienummer'].Label.Text; OK = $null }
        )
        Bloat = @($script:hpBloatFound); HPIA = (Get-HPIASummary)
    }

    $pd = New-Object System.Drawing.Printing.PrintDocument
    $pd.PrinterSettings.PrinterName   = 'Microsoft Print to PDF'
    $pd.PrinterSettings.PrintToFile   = $true
    $pd.PrinterSettings.PrintFileName = $outputPath

    $pd.Add_PrintPage({
        param($s2, $ev)
        $d  = $script:_pdfData
        $g  = $ev.Graphics
        $lm = [float]$ev.MarginBounds.Left
        $tm = [float]$ev.MarginBounds.Top
        $pw = [float]$ev.MarginBounds.Width

        $fTitle = New-Object System.Drawing.Font('Arial', 16, [System.Drawing.FontStyle]::Bold)
        $fSub = New-Object System.Drawing.Font('Arial', 10, [System.Drawing.FontStyle]::Italic)
        $fSection = New-Object System.Drawing.Font('Arial', 11, [System.Drawing.FontStyle]::Bold)
        $fCheck = New-Object System.Drawing.Font('Arial', 10)
        $fSmall = New-Object System.Drawing.Font('Arial', 9)

        $bBlack = [System.Drawing.Brushes]::Black
        $bGreen = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 128, 0))
        $bRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(192, 0, 0))
        $bGray = [System.Drawing.Brushes]::DimGray
        $bTeal = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 128, 128))
        $penLine = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(0, 128, 128), 2)

        $y = $tm
        if ($null -ne $d.Logo) {
            $logoH = [int]48
            $logoW = [int]($d.Logo.Width * $logoH / $d.Logo.Height)
            $logoX = [int]($lm + $pw - $logoW)
            $g.DrawImage($d.Logo, (New-Object System.Drawing.Rectangle($logoX, [int]$tm, $logoW, $logoH)))
        }

        $g.DrawString('EOO Windows Installatie Rapport', $fTitle, $bTeal, $lm, $y); $y += 34
        $g.DrawString("Datum: $($d.Date)", $fSub, $bGray, $lm, $y); $y += 20
        $g.DrawString("Computer: $($d.Computer)   |   Serienummer: $($d.Serial)", $fSub, $bGray, $lm, $y); $y += 28
        $g.DrawLine($penLine, $lm, $y, ($lm + $pw), $y); $y += 16
        $g.DrawString('Systeemcontroles', $fSection, $bBlack, $lm, $y); $y += 28

        foreach ($chk in $d.Checks) {
            if ($null -eq $chk.OK) {
                $g.DrawString("$([char]0x25CF)  $($chk.Label)", $fCheck, $bGray, $lm, $y)
            } elseif ($chk.OK) {
                $g.DrawString("$([char]0x2713)  $($chk.Label)", $fCheck, $bGreen, $lm, $y)
            } else {
                $g.DrawString("$([char]0x2717)  $($chk.Label)", $fCheck, $bRed, $lm, $y)
            }
            $y += 22
        }

        if ($d.Bloat.Count -gt 0) {
            $y += 8
            foreach ($item in $d.Bloat) { $g.DrawString("     - $item", $fSmall, $bRed, $lm, $y); $y += 18 }
        }

        $y += 20
        $g.DrawLine($penLine, $lm, $y, ($lm + $pw), $y); $y += 14
        $g.DrawString('HP Image Assistant', $fSection, $bBlack, $lm, $y); $y += 24

        if ($null -ne $d.HPIA) {
            $g.DrawString("Rapport: $($d.HPIA.File)   |   $($d.HPIA.Date)", $fSmall, $bGray, $lm, $y); $y += 16
            if ($d.HPIA.BodyText) {
                $footerTopY = [float]$ev.MarginBounds.Bottom - 24
                $availH = [Math]::Max(10, $footerTopY - $y - 4)
                $sf = New-Object System.Drawing.StringFormat
                $sf.Trimming = [System.Drawing.StringTrimming]::Word
                $g.DrawString($d.HPIA.BodyText, $fSmall, $bBlack, [System.Drawing.RectangleF]::new($lm, $y, $pw, $availH), $sf)
                $sf.Dispose()
            } else {
                $g.DrawString('Geen inhoud gevonden in rapport.', $fSmall, $bGray, $lm, $y)
            }
        } else {
            $fBig = New-Object System.Drawing.Font('Arial', 11, [System.Drawing.FontStyle]::Bold)
            $g.DrawString("$([char]0x26A0)  GEEN HPIA-RAPPORT GEVONDEN — HP Image Assistant is mogelijk niet gedraaid.", $fBig, $bRed, $lm, $y)
            $fBig.Dispose()
        }

        $fy = [float]$ev.MarginBounds.Bottom - 22
        $g.DrawLine($penLine, $lm, $fy, ($lm + $pw), $fy); $fy += 10
        $g.DrawString("Gegenereerd door EOO Windows Installatie Tool v$($d.Version)", $fSmall, $bGray, $lm, $fy)

        $penLine.Dispose(); $bGreen.Dispose(); $bRed.Dispose(); $bTeal.Dispose()
        $fTitle.Dispose(); $fSub.Dispose(); $fSection.Dispose(); $fCheck.Dispose(); $fSmall.Dispose()
        $ev.HasMorePages = $false
    })

    try {
        $pd.Print()
        Write-Console 'PDF gereed, uploaden naar Azure Files...' 'info'
        Start-EOOJob -Key 'PdfUpload' -ArgumentList @($outputPath, $script:afStorageAccount, $script:afShareName, $script:afKey) -ScriptBlock {
            param($localPath, $sa, $sn, $k)
            $waited = 0
            while (-not (Test-Path $localPath) -and $waited -lt 30) { Start-Sleep -Milliseconds 500; $waited++ }
            if (-not (Test-Path $localPath)) { throw 'PDF niet beschikbaar na 15 seconden.' }
            $fn = [System.IO.Path]::GetFileName($localPath)
            if (-not (Test-Path 'X:\')) {
                Get-SmbMapping -ErrorAction SilentlyContinue | Where-Object { $_.RemotePath -like "\\$sa.file.core.windows.net\*" } | ForEach-Object {
                    Remove-SmbMapping -LocalPath $_.LocalPath -Force -UpdateProfile -ErrorAction SilentlyContinue
                }
                try {
                    New-SmbMapping -LocalPath 'X:' -RemotePath "\\$sa.file.core.windows.net\$sn" -UserName "Azure\$sa" -Password $k -Persistent $false -ErrorAction Stop | Out-Null
                } catch { throw "Azure Files koppelen mislukt: $_" }
            }
            $rapDir = 'X:\Rapporten'
            if (-not (Test-Path $rapDir)) { New-Item -ItemType Directory -Path $rapDir | Out-Null }
            Copy-Item -Path $localPath -Destination "$rapDir\$fn" -Force
            Remove-Item $localPath -Force -ErrorAction SilentlyContinue
            Write-Output "OK:$fn"
        } -OnOutput {
            param($line)
            if ($line -match '^OK:(.+)') { Write-Console "[OK] Geupload naar Azure Files: Rapporten\$($matches[1])" 'ok' }
        } -OnError {
            param($e) Write-Console "FOUT upload: $($e.Exception.Message)" 'error'
        } -OnComplete {
            param($succeeded, $reason)
            if (-not $succeeded) { Write-Console 'FOUT: Upload naar Azure Files mislukt.' 'error' }
            $btnExportPDF.IsEnabled = $true
        }
    } catch {
        Write-Console "FOUT bij exporteren PDF: $_" 'error'
        $btnExportPDF.IsEnabled = $true
    } finally {
        $pd.Dispose()
        $script:_pdfData = $null
    }
}

$btnExportPDF.Add_Click({
    $btnExportPDF.IsEnabled = $false
    Write-Console 'Rapport als PDF exporteren...' 'start'
    Export-RapportPDF
})

# ── Opstart ─────────────────────────────────────────────────────────
$window.Add_Loaded({
    Write-Console 'Systeemcontrole uitgevoerd.' 'info'
    Update-InfoPanel
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
})

[void]$window.ShowDialog()
