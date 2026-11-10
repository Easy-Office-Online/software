# ════════════════════════════════════════════════════════════════
#  EOO – Windows Installatie Tool  |  WPF-versie (volledig)
#  Zelfde functionaliteit als EOO-WinInstall-GUIv6.ps1 (WinForms),
#  opnieuw opgebouwd in WPF/XAML met een moderne stijl (rounded
#  cards, dropshadow, vector-iconen) i.p.v. de GDI+ bitmaps.
#  NIET pixel-perfect gelijk aan v6 -- zie eerder overleg.
#  Draai met Windows PowerShell (powershell.exe), niet met pwsh.
#  Opslaan als: UTF-8 with BOM
# ════════════════════════════════════════════════════════════════

$script:currentVersion = [System.Version]'7.5'
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
        WindowStartupLocation="CenterScreen" FontFamily="Tahoma"
        UseLayoutRounding="True" TextOptions.TextFormattingMode="Display" TextOptions.TextRenderingMode="ClearType">
    <Window.Resources>
        <SolidColorBrush x:Key="BrushBg"        Color="#FAF9F6"/>
        <SolidColorBrush x:Key="BrushCard"      Color="#FFFFFF"/>
        <SolidColorBrush x:Key="BrushBorder"    Color="#E4E1DB"/>
        <SolidColorBrush x:Key="BrushAccent"    Color="#208AD0"/>
        <SolidColorBrush x:Key="BrushAccentDark" Color="#03173D"/>
        <SolidColorBrush x:Key="BrushSubText"   Color="#4B5262"/>
        <SolidColorBrush x:Key="BrushText"      Color="#000000"/>
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
                        <Grid>
                            <Border Background="{StaticResource BrushCard}" CornerRadius="8">
                                <Border.Effect>
                                    <DropShadowEffect BlurRadius="6" ShadowDepth="1" Opacity="0.08" Color="#000000"/>
                                </Border.Effect>
                            </Border>
                            <Border x:Name="Bd" Background="{StaticResource BrushCard}"
                                BorderBrush="{StaticResource BrushBorder}" BorderThickness="1" CornerRadius="8">
                            <StackPanel Orientation="Horizontal" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="14,0">
                                <Path x:Name="PART_Icon" Width="15" Height="15" Stretch="Uniform" Margin="0,0,10,0"
                                      Fill="{StaticResource BrushAccentDark}" Data="{TemplateBinding Tag}"/>
                                <TextBlock x:Name="PART_Text" Text="{TemplateBinding Content}"
                                           Foreground="{StaticResource BrushText}" VerticalAlignment="Center"/>
                            </StackPanel>
                        </Border>
                        </Grid>
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
                        <Grid>
                            <Border Background="{StaticResource BrushCard}" CornerRadius="8">
                                <Border.Effect>
                                    <DropShadowEffect BlurRadius="6" ShadowDepth="1" Opacity="0.08" Color="#000000"/>
                                </Border.Effect>
                            </Border>
                            <Border x:Name="Bd" Background="{StaticResource BrushCard}"
                                BorderBrush="{StaticResource BrushBorder}" BorderThickness="1" CornerRadius="8">
                            <StackPanel Orientation="Horizontal" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="14,0">
                                <Path x:Name="PART_Icon" Width="15" Height="15" Stretch="Uniform" Margin="0,0,10,0"
                                      Fill="{StaticResource BrushAccentDark}" Data="{TemplateBinding Tag}"/>
                                <TextBlock x:Name="PART_Text" Text="{TemplateBinding Content}"
                                           Foreground="{StaticResource BrushText}" VerticalAlignment="Center"/>
                            </StackPanel>
                        </Border>
                        </Grid>
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
            <!-- Wit logovlak met schuine rand + dunne accentstreep -->
            <Polygon Points="0,0 292,0 256,107 0,107" Fill="White">
                <Polygon.Effect>
                    <DropShadowEffect BlurRadius="12" ShadowDepth="0" Opacity="0.25" Color="#03173D"/>
                </Polygon.Effect>
            </Polygon>
            <Polygon Points="298,0 306,0 270,107 262,107" Fill="#60BEF0" Opacity="0.85"/>
            <Image x:Name="ImgLogo" Width="230" Height="98" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="14,5,0,0" Stretch="Uniform"/>
            <TextBlock x:Name="TxtLogoFallback" Text="EOO" Foreground="White" FontSize="22" FontWeight="Bold"
                       HorizontalAlignment="Left" VerticalAlignment="Top" Margin="20,24,0,0" Visibility="Collapsed"/>
            <TextBlock Text="Windows Installatie Tool" Foreground="White" FontSize="14"
                       HorizontalAlignment="Left" VerticalAlignment="Top" Margin="310,50,0,0"/>
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

                    <Grid>
                    <Border Background="{StaticResource BrushCard}" CornerRadius="10">
                        <Border.Effect>
                            <DropShadowEffect BlurRadius="10" ShadowDepth="1" Opacity="0.06" Color="#000000"/>
                        </Border.Effect>
                    </Border>
                    <Border Background="{StaticResource BrushCard}" BorderBrush="{StaticResource BrushBorder}" BorderThickness="1" CornerRadius="10" Padding="16">
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
                    </Grid>

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
                    <Button x:Name="BtnActivateOem" Content="Activeren met OEM-sleutel (firmware)" Style="{StaticResource PrimaryButton}" Margin="0,0,0,8" Visibility="Collapsed"/>
                    <Button x:Name="BtnActivateComplies" Content="Activeren met Complies-sleutel (Azure)" Style="{StaticResource PrimaryButton}" Margin="0,0,0,8" Visibility="Collapsed"/>
                    <Button x:Name="BtnBackupKey" Content="Productsleutel back-uppen naar Azure" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>

                    <!-- Drivers -->
                    <TextBlock Text="Drivers" Style="{StaticResource SectionTitle}"/>
                    <Border Height="1" Background="{StaticResource BrushBorder}" Margin="0,0,0,10"/>
                    <Button x:Name="BtnLSU" Content="Lenovo System Update installeren" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>
                    <Button x:Name="BtnHPIA" Content="HP Image Assistant installeren en draaien" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>

                    <!-- Autopilot -->
                    <TextBlock Text="Autopilot" Style="{StaticResource SectionTitle}"/>
                    <Border Height="1" Background="{StaticResource BrushBorder}" Margin="0,0,0,10"/>
                    <TextBlock Text="Group tag" FontWeight="SemiBold" Foreground="{StaticResource BrushAccent}" Margin="0,0,0,2" FontSize="12"/>
                    <TextBlock Text="Nieuwe omgevingen (na juni 2026):" Foreground="{StaticResource BrushSubText}" FontSize="11" Margin="0,0,0,6"/>
                    <Grid Margin="0,0,0,10">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="8"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="8"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Button x:Name="BtnTagFull"   Grid.Column="0" Content="1  Full"   Style="{StaticResource OutlineButton}"/>
                        <Button x:Name="BtnTagFlex"   Grid.Column="2" Content="2  Flex"   Style="{StaticResource OutlineButton}"/>
                        <Button x:Name="BtnTagShared" Grid.Column="4" Content="3  Shared" Style="{StaticResource OutlineButton}"/>
                    </Grid>
                    <TextBlock Text="Oudere omgevingen: typ hier zelf een willekeurige group tag (bijv. EOO-W11-FLEX of fitflexdd):"
                               TextWrapping="Wrap" Foreground="{StaticResource BrushSubText}" FontSize="11" Margin="0,0,0,6"/>
                    <TextBox x:Name="TxtGroupTag" Style="{StaticResource KeyInput}" Margin="0,0,0,10" HorizontalAlignment="Left" Width="300"/>

                    <TextBlock Text="Exportmethode" FontWeight="SemiBold" Foreground="{StaticResource BrushAccent}" Margin="0,0,0,6" FontSize="12"/>
                    <RadioButton x:Name="RbHWIDSingle" GroupName="HWIDMode" IsChecked="True" FontSize="12" Margin="0,0,0,4"
                                 Content="Per apparaat: eigen CSV per serienummer (overschrijven)"/>
                    <RadioButton x:Name="RbHWIDBulk" GroupName="HWIDMode" FontSize="12" Margin="0,0,0,8"
                                 Content="Bulk: toevoegen aan een batch-CSV (meerdere apparaten)"/>
                    <StackPanel x:Name="PnlHWIDBatch" Visibility="Collapsed" Margin="0,0,0,8">
                        <TextBlock Text="Batchnaam (bijv. Batch-01 of School-A):" Foreground="{StaticResource BrushSubText}" FontSize="11" Margin="0,0,0,6"/>
                        <TextBox x:Name="TxtHWIDBatch" Style="{StaticResource KeyInput}" HorizontalAlignment="Left" Width="300"/>
                    </StackPanel>
                    <Button x:Name="BtnHWID" Content="HWID exporteren en uploaden naar Azure" Style="{StaticResource PrimaryButton}" Margin="0,0,0,8"/>

                    <!-- Azure opslag -->
                    <TextBlock Text="Azure opslag" Style="{StaticResource SectionTitle}"/>
                    <Border Height="1" Background="{StaticResource BrushBorder}" Margin="0,0,0,10"/>
                    <Button x:Name="BtnAzureMount" Content="Azure opslag openen" Style="{StaticResource OutlineButton}" Margin="0,0,0,8"/>

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
$btnActivateOem  = $window.FindName('BtnActivateOem')
$btnActivateComplies = $window.FindName('BtnActivateComplies')
$btnBackupKey    = $window.FindName('BtnBackupKey')
$btnLSU          = $window.FindName('BtnLSU')
$btnHPIA         = $window.FindName('BtnHPIA')
$btnTagFull      = $window.FindName('BtnTagFull')
$btnTagFlex      = $window.FindName('BtnTagFlex')
$btnTagShared    = $window.FindName('BtnTagShared')
$txtGroupTag     = $window.FindName('TxtGroupTag')
$rbHWIDSingle    = $window.FindName('RbHWIDSingle')
$rbHWIDBulk      = $window.FindName('RbHWIDBulk')
$pnlHWIDBatch    = $window.FindName('PnlHWIDBatch')
$txtHWIDBatch    = $window.FindName('TxtHWIDBatch')
$btnHWID         = $window.FindName('BtnHWID')
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
    Upload   = 'M9,16V10H5L12,3L19,10H15V16H9M5,20V18H19V20H5Z'
    Label    = 'M5.5,7A1.5,1.5 0 0,1 4,5.5A1.5,1.5 0 0,1 5.5,4A1.5,1.5 0 0,1 7,5.5A1.5,1.5 0 0,1 5.5,7M21.41,11.58L12.41,2.58C12.05,2.22 11.55,2 11,2H4C2.89,2 2,2.89 2,4V11C2,11.55 2.22,12.05 2.59,12.42L11.58,21.41C11.95,21.77 12.45,22 13,22C13.55,22 14.05,21.77 14.41,21.41L21.41,14.41C21.78,14.05 22,13.55 22,13C22,12.44 21.77,11.94 21.41,11.58Z'
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
$btnActivateOem.Tag = Get-IconGeometry Key
$btnActivateComplies.Tag = Get-IconGeometry Key
$btnBackupKey.Tag   = Get-IconGeometry Upload
$btnLSU.Tag         = Get-IconGeometry Play
$btnHPIA.Tag        = Get-IconGeometry Play
$btnTagFull.Tag     = Get-IconGeometry Label
$btnTagFlex.Tag     = Get-IconGeometry Label
$btnTagShared.Tag   = Get-IconGeometry Label
$btnHWID.Tag        = Get-IconGeometry Upload
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

# ── Easter egg 2: Konami-code -> pizzamodus (venster draait 360 graden) ─
$script:Konami    = @('Up','Up','Down','Down','Left','Right','Left','Right','B','A')
$script:KonamiIdx = 0

# Het easter egg zelf: content 360 graden laten draaien en titel aanpassen
function Start-PizzaMode {
    $content = $window.Content
    $rt = [System.Windows.Media.RotateTransform]::new()
    $content.RenderTransformOrigin = [System.Windows.Point]::new(0.5, 0.5)
    $content.RenderTransform = $rt

    $duur = [System.Windows.Duration]::new([TimeSpan]::FromSeconds(1.5))
    $anim = [System.Windows.Media.Animation.DoubleAnimation]::new(0, 360, $duur)
    $rt.BeginAnimation([System.Windows.Media.RotateTransform]::AngleProperty, $anim)

    $window.Title = 'Pizza Calzone, extra kaas'
    Write-Host '[EasterEgg] Pizzamodus geactiveerd' -ForegroundColor Yellow
    Write-Console "Pizzamodus geactiveerd: de pizza wordt even rondgedraaid. $([char]::ConvertFromUtf32(0x1F355))" 'ok'
}

# PreviewKeyDown op het venster, zodat focused controls de pijltjes niet opvangen
$window.Add_PreviewKeyDown({
    param($src, $e)
    $key = $e.Key.ToString()

    if ($key -eq $script:Konami[$script:KonamiIdx]) {
        $script:KonamiIdx++
        if ($script:KonamiIdx -eq $script:Konami.Count) {
            $script:KonamiIdx = 0
            Start-PizzaMode
        }
    }
    else {
        # Bij een fout opnieuw beginnen, maar 'Up' telt meteen als eerste stap
        $script:KonamiIdx = if ($key -eq $script:Konami[0]) { 1 } else { 0 }
    }
})

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
    $row = New-Object System.Windows.Controls.DockPanel
    $row.Margin = '0,0,0,7'

    $icon = New-Object System.Windows.Controls.TextBlock
    $icon.Width = 20
    $icon.FontWeight = 'Bold'
    $icon.FontSize = 13
    $icon.Foreground = $window.FindResource('BrushAccent')
    $icon.Text = '-'

    $label = New-Object System.Windows.Controls.TextBlock
    $label.Foreground = $window.FindResource('BrushText')
    $label.FontSize = 13
    $label.VerticalAlignment = 'Center'
    $label.TextWrapping = 'Wrap'

    [void]$row.Children.Add($icon)
    [void]$row.Children.Add($label)
    [void]$infoRows.Children.Add($row)
    $script:infoRowMap[$Key] = @{ Row = $row; Icon = $icon; Label = $label }
}
'ActiveKey', 'OemKey', 'CompliesKey', 'Windows', 'Activatie', 'Tpm', 'SecureBoot', 'Internet', 'HP', 'Laptop', 'Wifi', 'Serienummer' |
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
$script:oemKey       = $null

# Windows-productsleutel decoderen uit DigitalProductId (registry)
function ConvertFrom-DigitalProductId {
    param([byte[]]$Id)
    $offset = 52
    $chars  = 'BCDFGHJKMPQRTVWXY2346789'
    $isWin8 = [int][math]::Floor($Id[66] / 6) -band 1
    $Id[66] = $Id[66] -band 0xF7
    $key = ''; $last = 0
    for ($i = 24; $i -ge 0; $i--) {
        $cur = 0
        for ($j = 14; $j -ge 0; $j--) {
            $cur = $cur * 256 + $Id[$j + $offset]
            $Id[$j + $offset] = [byte][math]::Floor($cur / 24)
            $cur = $cur % 24
        }
        $key = $chars[$cur] + $key
        $last = $cur
    }
    if ($isWin8 -eq 1) { $key = $key.Substring(1).Insert($last, 'N') }
    return ($key -replace '(.{5})(?!$)', '$1-')
}

function Update-InfoPanel {
    # Sleutel waarmee Windows nu geactiveerd is. De volledige sleutel komt uit
    # DigitalProductId; alleen tonen als die overeenkomt met de PartialProductKey.
    try {
        $winLic = Get-CimInstance -Query "SELECT Description, PartialProductKey, LicenseStatus FROM SoftwareLicensingProduct WHERE ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f' AND PartialProductKey IS NOT NULL" |
                  Sort-Object { $_.LicenseStatus -ne 1 } | Select-Object -First 1
        if ($winLic) {
            $fullKey = $null
            try {
                $dpid = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name DigitalProductId -ErrorAction Stop).DigitalProductId
                if ($dpid) { $fullKey = ConvertFrom-DigitalProductId -Id $dpid }
            } catch {}
            $shown   = if ($fullKey -and $fullKey.EndsWith($winLic.PartialProductKey)) { $fullKey } else { "*****-*****-*****-*****-$($winLic.PartialProductKey)" }
            $channel = if ($winLic.Description -match ',\s*(\S+)\s+channel') { " ($($matches[1]))" } else { '' }
            $prefix  = if ($winLic.LicenseStatus -eq 1) { 'Actieve sleutel' } else { 'Sleutel (niet geactiveerd)' }
            Set-InfoRow 'ActiveKey' "${prefix}: $shown$channel" ($winLic.LicenseStatus -eq 1)
        } else {
            Set-InfoRow 'ActiveKey' 'Geen productsleutel geinstalleerd' $false
        }
    } catch { Set-InfoRow 'ActiveKey' 'Actieve sleutel: controlefout' $false }

    # OEM-sleutel uit firmware (OA3)
    try { $script:oemKey = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey } catch { $script:oemKey = $null }
    $oemRow = $script:infoRowMap['OemKey']
    if ($script:oemKey) {
        Set-InfoRow 'OemKey' "OEM-sleutel: $script:oemKey" $true -Neutral
        $oemRow.Label.Foreground = $window.FindResource('BrushText')
        $btnActivateOem.Visibility = 'Visible'
    } else {
        Set-InfoRow 'OemKey' 'Geen OEM-sleutel in firmware gevonden' $true -Neutral
        $oemRow.Icon.Text = '-'
        $oemRow.Icon.Foreground = $window.FindResource('BrushSubText')
        $oemRow.Label.Foreground = $window.FindResource('BrushText')
        $btnActivateOem.Visibility = 'Collapsed'
    }

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

# Complies-sleutel: serienummer opzoeken in de CSV('s) op Azure Files
# (Productsleutels\Complies keys\*.csv). Draait als job zodat het laden
# van de share/CSV de GUI niet blokkeert.
$script:compliesKey = $null
function Update-CompliesKey {
    if ($script:eooJobs.ContainsKey('CompliesLookup')) { return }
    $script:compliesKey = $null
    $btnActivateComplies.Visibility = 'Collapsed'
    $cRow = $script:infoRowMap['CompliesKey']
    Set-InfoRow 'CompliesKey' 'Complies-sleutel: zoeken in Azure...' $true -Neutral
    $cRow.Icon.Text = '-'
    $cRow.Icon.Foreground = $window.FindResource('BrushSubText')
    $cRow.Label.Foreground = $window.FindResource('BrushText')

    try { $serial = (Get-CimInstance Win32_BIOS).SerialNumber.Trim() } catch { $serial = $null }
    if (-not $serial) {
        Set-InfoRow 'CompliesKey' 'Complies-sleutel: serienummer onbekend' $false
        return
    }

    $script:compliesResult = $null
    Start-EOOJob -Key 'CompliesLookup' -ArgumentList @($script:afStorageAccount, $script:afShareName, $script:afKey, $serial) -ScriptBlock {
        param($sa, $sn, $k, $serial)
        if (-not (Test-Path 'X:\')) {
            Get-SmbMapping -ErrorAction SilentlyContinue | Where-Object { $_.RemotePath -like "\\$sa.file.core.windows.net\*" } | ForEach-Object {
                Remove-SmbMapping -LocalPath $_.LocalPath -Force -UpdateProfile -ErrorAction SilentlyContinue
            }
            try {
                New-SmbMapping -LocalPath 'X:' -RemotePath "\\$sa.file.core.windows.net\$sn" -UserName "Azure\$sa" -Password $k -Persistent $false -ErrorAction Stop | Out-Null
            } catch { throw "Azure Files koppelen mislukt. Controleer poort 445. ($_)" }
        }
        $dir = 'X:\Productsleutels\Complies keys'
        $csvs = @(Get-ChildItem -Path $dir -Filter '*.csv' -File -ErrorAction SilentlyContinue)
        if (-not $csvs) { throw "Geen CSV gevonden in Productsleutels\Complies keys." }
        foreach ($csv in $csvs) {
            $hit = Import-Csv -Path $csv.FullName -Delimiter ';' |
                Where-Object { $_.Serienummer.Trim() -eq $serial -or ($_.serialbios -and $_.serialbios.Trim() -eq $serial) } |
                Where-Object { $_.key -match '^[A-Z0-9]{5}(-[A-Z0-9]{5}){4}$' } |
                Select-Object -Last 1
            if ($hit) {
                [pscustomobject]@{ Key = $hit.key.Trim(); OS = $hit.osname; File = $csv.Name }
                return
            }
        }
    } -OnOutput {
        param($line) $script:compliesResult = $line
    } -OnComplete {
        param($succeeded, $reason)
        $cRow = $script:infoRowMap['CompliesKey']
        if (-not $succeeded) {
            Set-InfoRow 'CompliesKey' 'Complies-sleutel: Azure niet bereikbaar' $false
            Write-Console "Complies-sleutel opzoeken mislukt: $reason" 'error'
            return
        }
        if ($script:compliesResult) {
            $script:compliesKey = $script:compliesResult.Key
            Set-InfoRow 'CompliesKey' "Complies-sleutel: $script:compliesKey" $true -Neutral
            $cRow.Label.Foreground = $window.FindResource('BrushText')
            $btnActivateComplies.Visibility = 'Visible'
            Write-Console "Complies-sleutel gevonden voor dit serienummer ($($script:compliesResult.OS), $($script:compliesResult.File))." 'ok'
        } else {
            Set-InfoRow 'CompliesKey' 'Geen Complies-sleutel voor dit serienummer' $true -Neutral
            $cRow.Icon.Text = '-'
            $cRow.Icon.Foreground = $window.FindResource('BrushSubText')
        }
    }
}

$txtRefresh.Add_MouseLeftButtonUp({
    Update-InfoPanel
    Update-CompliesKey
    Write-Console 'Infopaneel vernieuwd. Verse toppings erop gelegd.' 'info'
})

# ── Sectie: Systeem ─────────────────────────────────────────────────
$btnRestart.Add_Click({
    if ([System.Windows.MessageBox]::Show('Systeem nu herstarten?', 'Herstarten bevestigen', 'YesNo', 'Warning') -ne 'Yes') { return }
    Write-Console 'Systeem wordt herstart... de oven gaat even uit en weer aan.' 'start'
    Start-Process PowerShell -ArgumentList '-Command shutdown.exe /r /t 0' -NoNewWindow
})

$btnShutdown.Add_Click({
    if ([System.Windows.MessageBox]::Show('Systeem nu afsluiten?', 'Afsluiten bevestigen', 'YesNo', 'Warning') -ne 'Yes') { return }
    Write-Console 'Systeem wordt afgesloten... de pizzeria gaat dicht.' 'start'
    Start-Process PowerShell -ArgumentList '-Command shutdown.exe /s /t 0' -NoNewWindow
})

$btnBios.Add_Click({
    if ([System.Windows.MessageBox]::Show('Nu herstarten naar BIOS/UEFI-instellingen?', 'BIOS-herstart bevestigen', 'YesNo', 'Warning') -ne 'Yes') { return }
    Write-Console 'Systeem wordt herstart naar BIOS/UEFI-instellingen... even de oventhermostaat bijstellen.' 'start'
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

$btnWU.Add_Click({ Write-Console 'Windows Update instellingen openen... verse ingredienten bestellen.' 'start'; Start-Process 'ms-settings:windowsupdate' })
$btnDM.Add_Click({ Write-Console 'Apparaatbeheer openen... even in de keuken kijken.' 'start'; Start-Process 'devmgmt.msc' })
$btnAW.Add_Click({ Write-Console 'Windows activeringsscherm openen... de oven aanzetten.' 'start'; Start-Process 'C:\Windows\System32\slui.exe' })

$btnWifi.Add_Click({
    $btnWifi.IsEnabled = $false
    Write-Console 'WiFi profiel toevoegen... de bezorger krijgt het adres.' 'start'
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
    if ($LASTEXITCODE -eq 0) { Write-Console "[OK] WiFi profiel '$ssid' toegevoegd. Bezorging kan beginnen." 'ok' } else { Write-Console "FOUT: $out (bezorger kan het adres niet vinden)" 'error' }
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
    Write-Console "Productsleutel installeren: $key (het deeg wordt gekneed)" 'start'
    Start-EOOJob -Key 'Activate' -ArgumentList @($key) -ScriptBlock {
        param($key)
        $r1 = & cscript.exe //B "$env:windir\system32\slmgr.vbs" /ipk $key 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Sleutel installeren mislukt: $r1" }
        Write-Output "[1/2] Sleutel geinstalleerd. Pizza gaat de oven in..."
        $r2 = & cscript.exe //B "$env:windir\system32\slmgr.vbs" /ato 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Activatie mislukt: $r2" }
        Write-Output "[OK] Windows succesvol geactiveerd. Pizza is gaar!"
    } -OnOutput {
        param($line)
        if ($line -match '^\[OK\]') { Write-Console $line 'ok' } else { Write-Console $line 'info' }
    } -OnError {
        param($e) Write-Console "FOUT: $($e.Exception.Message)" 'error'
    } -OnComplete {
        param($succeeded, $reason)
        if (-not $succeeded) { Write-Console "FOUT: $reason" 'error' } else { Update-InfoPanel }
        $btnActivateKey.IsEnabled = $true
        $btnActivateOem.IsEnabled = $true
        $btnActivateComplies.IsEnabled = $true
    }
})

# Activeren met OEM-sleutel: vult het sleutelveld en hergebruikt de activatie-flow
$btnActivateOem.Add_Click({
    if (-not $script:oemKey) { Write-Console 'Geen OEM-sleutel in firmware gevonden.' 'error'; return }
    $btnActivateOem.IsEnabled = $false
    $txtKey.Text = $script:oemKey
    $btnActivateKey.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent)))
    if ($btnActivateKey.IsEnabled) { $btnActivateOem.IsEnabled = $true }  # validatie mislukt -> geen job gestart
})

# Activeren met Complies-sleutel: zelfde flow als OEM, sleutel komt uit de Azure-CSV
$btnActivateComplies.Add_Click({
    if (-not $script:compliesKey) { Write-Console 'Geen Complies-sleutel gevonden voor dit serienummer.' 'error'; return }
    $btnActivateComplies.IsEnabled = $false
    $txtKey.Text = $script:compliesKey
    $btnActivateKey.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Primitives.ButtonBase]::ClickEvent)))
    if ($btnActivateKey.IsEnabled) { $btnActivateComplies.IsEnabled = $true }  # validatie mislukt -> geen job gestart
})

# Productsleutel back-up: OEM-sleutel uit firmware (OA3) + geinstalleerde
# sleutel (gedecodeerd uit DigitalProductId) naar X:\Productsleutels\<serienummer>_<tijd>.txt
$btnBackupKey.Add_Click({
    $btnBackupKey.IsEnabled = $false
    Write-Console 'Productsleutel back-uppen naar Azure Files... het recept gaat in de kluis.' 'start'
    Start-EOOJob -Key 'KeyBackup' -ArgumentList @($script:afStorageAccount, $script:afShareName, $script:afKey, ${function:ConvertFrom-DigitalProductId}.ToString()) -ScriptBlock {
        param($sa, $sn, $k, $decodeFn)
        ${function:ConvertFrom-DigitalProductId} = [scriptblock]::Create($decodeFn)

        $serial = (Get-CimInstance Win32_BIOS).SerialNumber.Trim()
        if (-not $serial) { $serial = 'ONBEKEND' }
        Write-Output "[1/3] Serienummer: $serial"

        $oemKey = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey
        $oemDesc = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKeyDescription
        $installedKey = $null
        try {
            $dpid = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name DigitalProductId -ErrorAction Stop).DigitalProductId
            if ($dpid) { $installedKey = ConvertFrom-DigitalProductId -Id $dpid }
        } catch {}
        $lic = Get-CimInstance -Query "SELECT Name, Description, PartialProductKey, LicenseStatus FROM SoftwareLicensingProduct WHERE ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f' AND PartialProductKey IS NOT NULL" |
               Select-Object -First 1
        $os = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

        if (-not $oemKey -and -not $installedKey) { throw 'Geen productsleutel gevonden (geen OEM-sleutel in firmware en geen geinstalleerde sleutel).' }
        Write-Output "[2/3] OEM-sleutel (firmware): $(if ($oemKey) { $oemKey } else { 'niet aanwezig' })"
        Write-Output "      Geinstalleerde sleutel : $(if ($installedKey) { $installedKey } else { 'niet uit te lezen' })"

        $statusNames = @{ 0 = 'Niet gelicentieerd'; 1 = 'Gelicentieerd'; 2 = 'OOB-grace'; 3 = 'OOT-grace'; 4 = 'Non-genuine grace'; 5 = 'Notificatie'; 6 = 'Extended grace' }
        $lines = @(
            'EOO - Windows productsleutel back-up'
            "Datum                 : $(Get-Date -Format 'dd-MM-yyyy HH:mm:ss')"
            "Serienummer           : $serial"
            "Computernaam          : $env:COMPUTERNAME"
            "Fabrikant / model     : $((Get-CimInstance Win32_ComputerSystem).Manufacturer) $((Get-CimInstance Win32_ComputerSystem).Model)"
            "Windows editie        : $($os.EditionID) $($os.DisplayVersion) (Build $($os.CurrentBuildNumber))"
            ''
            "OEM-sleutel (firmware): $(if ($oemKey) { $oemKey } else { '-' })"
            "OEM-sleutel type      : $(if ($oemDesc) { $oemDesc } else { '-' })"
            "Geinstalleerde sleutel: $(if ($installedKey) { $installedKey } else { '-' })"
            "Partial key (laatste 5): $(if ($lic) { $lic.PartialProductKey } else { '-' })"
            "Licentiekanaal        : $(if ($lic) { $lic.Description } else { '-' })"
            "Licentiestatus        : $(if ($lic) { $statusNames[[int]$lic.LicenseStatus] } else { '-' })"
            ''
            'Let op: bij een digitale licentie / KMS is de geinstalleerde sleutel een generieke sleutel.'
        )

        $safeSerial = $serial -replace '[\\/:*?"<>|]', '_'
        $fn = "${safeSerial}_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        $localPath = Join-Path $env:TEMP $fn
        Set-Content -Path $localPath -Value $lines -Encoding UTF8

        Write-Output '[3/3] Uploaden naar Azure Files...'
        if (-not (Test-Path 'X:\')) {
            Get-SmbMapping -ErrorAction SilentlyContinue | Where-Object { $_.RemotePath -like "\\$sa.file.core.windows.net\*" } | ForEach-Object {
                Remove-SmbMapping -LocalPath $_.LocalPath -Force -UpdateProfile -ErrorAction SilentlyContinue
            }
            try {
                New-SmbMapping -LocalPath 'X:' -RemotePath "\\$sa.file.core.windows.net\$sn" -UserName "Azure\$sa" -Password $k -Persistent $false -ErrorAction Stop | Out-Null
            } catch { throw "Azure Files koppelen mislukt. Controleer poort 445. ($_)" }
        }
        $keyDir = 'X:\Productsleutels'
        if (-not (Test-Path $keyDir)) { New-Item -ItemType Directory -Path $keyDir | Out-Null }
        Copy-Item -Path $localPath -Destination "$keyDir\$fn" -Force
        Remove-Item $localPath -Force -ErrorAction SilentlyContinue
        Write-Output "[OK] Productsleutel opgeslagen in Azure Files: Productsleutels\$fn (recept veilig bewaard)"
    } -OnOutput {
        param($line)
        if ($line -match '^\[OK\]') { Write-Console $line 'ok' } else { Write-Console $line 'info' }
    } -OnError {
        param($e) Write-Console "FOUT: $($e.Exception.Message)" 'error'
    } -OnComplete {
        param($succeeded, $reason)
        if (-not $succeeded) { Write-Console "FOUT: $reason" 'error' }
        $btnBackupKey.IsEnabled = $true
    }
})

# ── Sectie: Drivers ─────────────────────────────────────────────────
$btnLSU.Add_Click({
    $btnLSU.IsEnabled = $false
    $script:lsuSignal = $null
    Write-Console 'Lenovo System Update: bestelling geplaatst...' 'start'
    Start-EOOJob -Key 'LSU' -ScriptBlock {
        $configUrl = 'https://raw.githubusercontent.com/Easy-Office-Online/software/refs/heads/main/lenovoSU.txt'
        $raw     = (Invoke-WebRequest -Uri $configUrl -UseBasicParsing).Content
        $version = ($raw -split "`n" | Where-Object { $_ -match '^Version' }).Split('=')[1].Trim().Trim('"')
        $url     = ($raw -split "`n" | Where-Object { $_ -match '^URL' }).Split('=', 2)[1].Trim().Trim('"')
        if (-not $version -or -not $url) { throw 'Config onvolledig: versie of URL ontbreekt.' }
        Write-Output "[1/4] Recept opgehaald. Versie: $version"

        Write-Output '[2/4] Kijken of deze pizza al op tafel staat...'
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

        Write-Output "[3/4] Ingredienten ophalen (installer v$version downloaden)..."
        $installer = "$env:TEMP\LenovoSystemUpdate_$version.exe"
        Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing
        Write-Output '    Download geslaagd, alles ligt klaar op het aanrecht.'

        Write-Output '[4/4] Pizza wordt gebakken (installeren)...'
        $p = Start-Process -FilePath $installer -ArgumentList '/VERYSILENT /NORESTART' -Wait -PassThru
        if (Test-Path $installer) { Remove-Item $installer -Force }
        if ($p.ExitCode -ne 0) { throw "Installatie mislukt. Exit code: $($p.ExitCode)" }
        Write-Output '[OK] Lenovo System Update succesvol geinstalleerd. Vers uit de oven!'

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
            Write-Console 'Al up-to-date, deze pizza is nog warm. Geen actie nodig.' 'ok'
        } elseif ($script:lsuSignal -match '^SIGNAL:TVSU:(.+)') {
            $tvsuPath = $matches[1].Trim()
            if ($tvsuPath -and (Test-Path $tvsuPath)) {
                Write-Console 'Lenovo System Update wordt geserveerd...' 'start'
                Start-Process -FilePath $tvsuPath
                Write-Console 'Lenovo System Update gestart. Eet smakelijk!' 'ok'
            } else {
                Write-Console 'tvsu.exe niet gevonden op verwacht pad.' 'info'
            }
        }
        $btnLSU.IsEnabled = $true
    }
})

$btnHPIA.Add_Click({
    $btnHPIA.IsEnabled = $false
    Write-Console 'HP Image Assistant: bestelling geplaatst...' 'start'
    Start-EOOJob -Key 'HPIA' -ScriptBlock {
        $TextFileURL = 'https://raw.githubusercontent.com/Easy-Office-Online/software/refs/heads/main/hpia.txt'
        $text    = Invoke-RestMethod -Uri $TextFileURL
        $version = $null; $url = $null
        foreach ($line in $text -split "`r`n") {
            if ($line -match 'Version = "(.+)"') { $version = $matches[1] }
            if ($line -match 'URL = "(.*)"')     { $url     = $matches[1] }
        }
        if (-not $version -or -not $url) { throw 'Config onvolledig: versie of URL ontbreekt.' }
        Write-Output "[1/5] Recept opgehaald. Versie: $version"

        Write-Output '[2/5] Aanrecht vrijmaken (doelmappen aanmaken)...'
        $folderPath = 'C:\ProgramData\eoo\HPIA'
        $filename   = [System.IO.Path]::GetFileName($url)
        $filepath   = "$folderPath\$filename"
        if (-not (Test-Path $folderPath)) { New-Item -Path $folderPath -ItemType Directory | Out-Null }
        New-Item -ItemType Directory -Path 'C:\HPIA'       -Force | Out-Null
        New-Item -ItemType Directory -Path 'C:\HPIAReport' -Force | Out-Null

        Write-Output '[3/5] Ingredienten ophalen (setup downloaden)...'
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $url -OutFile $filepath
        Write-Output '    Download geslaagd.'

        Write-Output '[4/5] Deeg uitrollen (setup uitpakken)...'
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

        Write-Output '[5/5] Drivers worden gebakken (HPIA analyseert en installeert)...'
        Start-Process -FilePath 'C:\HPIA\HPImageAssistant.exe' `
            -ArgumentList '/Operation:Analyze /Category:All /Selection:All /Action:Install /Silent /ReportFolder:C:\HPIAReport' `
            -NoNewWindow -Wait
        Write-Output '[OK] Pizza is klaar! Rapport staat in C:\HPIAReport'
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
        else {
            $sum = Get-HPIASummary
            if ($sum -and $sum.Counts.Total -eq 0) {
                Write-Console 'Bakresultaat: geen updates nodig, alles is up-to-date.' 'ok'
            } elseif ($sum) {
                $c = $sum.Counts
                Write-Console ("Bakresultaat: {0} aanbevolen, {1} geinstalleerd, {2} herstart nodig, {3} mislukt, {4} niet geinstalleerd." -f $c.Total, $c.Installed, $c.Reboot, $c.Failed, $c.Open) $(if ($c.Failed -gt 0) { 'error' } else { 'ok' })
                foreach ($it in @($sum.Items | Where-Object { $_.Status -eq 'Failed' })) { Write-Console "  Mislukt: $($it.Name) ($($it.SoftPaq)) - $($it.Detail)" 'error' }
                if ($c.Reboot -gt 0) { Write-Console '  Herstart het apparaat om de updates af te ronden.' 'start' }
            }
        }
        $btnHPIA.IsEnabled = $true
    }
})

# ── Sectie: Autopilot ───────────────────────────────────────────────
# Alles draait binnen de GUI (geen losse PowerShell-vensters meer).
# Group tag: snelknoppen Full/Flex/Shared (nieuwe omgevingen na juni 2026)
# of vrije tekst in het veld (oudere omgevingen).
$script:groupTagButtons = [ordered]@{ Full = $btnTagFull; Flex = $btnTagFlex; Shared = $btnTagShared }
function Update-GroupTagButtons {
    $cur = $txtGroupTag.Text.Trim()
    foreach ($name in $script:groupTagButtons.Keys) {
        $style = if ($cur -eq $name) { 'PrimaryButton' } else { 'OutlineButton' }
        $script:groupTagButtons[$name].Style = $window.FindResource($style)
    }
}
$btnTagFull.Add_Click({   $txtGroupTag.Text = 'Full' })
$btnTagFlex.Add_Click({   $txtGroupTag.Text = 'Flex' })
$btnTagShared.Add_Click({ $txtGroupTag.Text = 'Shared' })
$txtGroupTag.Add_TextChanged({ Update-GroupTagButtons })

$rbHWIDBulk.Add_Checked({   $pnlHWIDBatch.Visibility = 'Visible'; $txtHWIDBatch.Focus() | Out-Null })
$rbHWIDSingle.Add_Checked({ $pnlHWIDBatch.Visibility = 'Collapsed' })

$btnHWID.Add_Click({
    $tag = $txtGroupTag.Text.Trim()
    if (-not $tag) {
        Write-Console 'Kies een group tag (1 Full, 2 Flex, 3 Shared) of vul zelf een group tag in.' 'error'
        $txtGroupTag.Focus() | Out-Null
        return
    }
    if ($tag -match '[,"]') { Write-Console 'De group tag mag geen komma of aanhalingsteken bevatten.' 'error'; return }

    $batch = $null
    if ($rbHWIDBulk.IsChecked) {
        $batch = ($txtHWIDBatch.Text.Trim() -replace '[\\/:*?"<>|]', '_')
        if (-not $batch) { Write-Console 'Vul een batchnaam in voor de bulk-export.' 'error'; $txtHWIDBatch.Focus() | Out-Null; return }
    }

    $btnHWID.IsEnabled = $false
    $modus = if ($batch) { "bulk, batch '$batch'" } else { 'per apparaat' }
    Write-Console "HWID export gestart ($modus, group tag '$tag')... bestelbon gaat naar de keuken." 'start'

    Start-EOOJob -Key 'HWID' -ArgumentList @($script:afStorageAccount, $script:afShareName, $script:afKey, $tag, $batch) -ScriptBlock {
        param($sa, $sn, $k, $groupTag, $batch)
        $ErrorActionPreference = 'Stop'

        Write-Output '[1/3] Hardware hash ophalen...'
        $serial = (Get-CimInstance Win32_BIOS).SerialNumber.Trim()
        $dev    = Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_DevDetail_Ext01
        $hash   = $dev.DeviceHardwareData
        if (-not $hash) { throw 'Hardware hash niet gevonden.' }
        Write-Output "    Serienummer: $serial   |   Group tag: $groupTag"
        $header = 'Device Serial Number,Windows Product ID,Hardware Hash,Group Tag,Assigned User'
        $line   = "$serial,,$hash,$groupTag,"

        Write-Output '[2/3] Verbinden met Azure Files...'
        if (-not (Test-Path 'X:\')) {
            Get-SmbMapping -ErrorAction SilentlyContinue | Where-Object { $_.RemotePath -like "\\$sa.file.core.windows.net\*" } | ForEach-Object {
                Remove-SmbMapping -LocalPath $_.LocalPath -Force -UpdateProfile -ErrorAction SilentlyContinue
            }
            try {
                New-SmbMapping -LocalPath 'X:' -RemotePath "\\$sa.file.core.windows.net\$sn" -UserName "Azure\$sa" -Password $k -Persistent $false -ErrorAction Stop | Out-Null
            } catch { throw "Kan Azure Files share niet bereiken. Controleer poort 445. ($_)" }
        }
        $dir = 'X:\HWID'
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

        Write-Output '[3/3] CSV wegschrijven...'
        if ($batch) {
            # Rechtstreeks in de batch-CSV op de share: bestaande regels blijven staan,
            # een eerdere regel van dit serienummer wordt vervangen.
            $dest = Join-Path $dir "$batch.csv"
            $rows = @()
            $replaced = $false
            if (Test-Path $dest) {
                $old  = @(Get-Content -Path $dest | Select-Object -Skip 1 | Where-Object { $_ })
                $rows = @($old | Where-Object { -not $_.StartsWith("$serial,") })
                $replaced = $rows.Count -lt $old.Count
            }
            Set-Content -Path $dest -Value (@($header) + $rows + $line) -Encoding UTF8
            $actie = if ($replaced) { 'bijgewerkt in' } else { 'toegevoegd aan' }
            Write-Output "[OK] Apparaat $actie HWID\$batch.csv ($($rows.Count + 1) apparaten in deze batch)."
        } else {
            $dest = Join-Path $dir "$serial.csv"
            Set-Content -Path $dest -Value @($header, $line) -Encoding UTF8
            Write-Output "[OK] HWID geupload naar HWID\$serial.csv. Bestelling staat klaar in de keuken."
        }
    } -OnOutput {
        param($line)
        if ($line -match '^\[OK\]') { Write-Console $line 'ok' } else { Write-Console $line 'info' }
    } -OnError {
        param($e) Write-Console "FOUT: $($e.Exception.Message)" 'error'
    } -OnComplete {
        param($succeeded, $reason)
        if (-not $succeeded) { Write-Console "FOUT: $reason (pizza aangebrand)" 'error' }
        $btnHWID.IsEnabled = $true
    }
})

# ── Sectie: Azure opslag ────────────────────────────────────────────
# Geen schijfkoppeling meer: we slaan alleen de credentials op met
# cmdkey en openen de UNC-map direct in de Verkenner. Dit loopt via
# Shell.Application zodat cmdkey en explorer in de context van de
# ingelogde gebruiker draaien i.p.v. in dit elevated proces (bv.
# defaultuser0 tijdens Autopilot ESP).
function Start-AzureMount {
    $sa = $script:afStorageAccount
    $sn = $script:afShareName
    $k  = $script:afKey

    $cmdContent = @"
@echo off
cmdkey /add:"$sa.file.core.windows.net" /user:"localhost\$sa" /pass:"$k" >nul
start "" explorer.exe "\\$sa.file.core.windows.net\$sn"
"@
    $cmdPath = Write-TempScript -Content $cmdContent -Filename 'EOO_OpenAzureShare.cmd'

    $shell = New-Object -ComObject Shell.Application
    $shell.ShellExecute('cmd.exe', "/c `"$cmdPath`"", '', 'open', 0)
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell)

    Write-Console "  Map \\$sa.file.core.windows.net\$sn geopend in de Verkenner. Voorraadkast staat open." 'ok'
    Write-Console '─────────────────────────────' 'info'
    $btnAzureMount.IsEnabled = $true
}

$btnAzureMount.Add_Click({
    $btnAzureMount.IsEnabled = $false
    Write-Console '─── Azure opslag openen (de voorraadkast) ───' 'start'
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
# HPIA-resultaat inlezen. Elke HPIA-run schrijft naast de HTML ook:
#   <model>.xml  -> analyse: categorie, huidige/nieuwe versie, systeeminfo
#   <model>.json -> uitvoering: per SoftPaq de installatiestatus
# Beide worden op SoftPaq-ID samengevoegd. Alleen als er geen JSON/XML
# is, valt de functie terug op tellen in de HTML.
function Get-XmlText {
    param($Node, [string]$XPath)
    if (-not $Node) { return '' }
    $n = $Node.SelectSingleNode($XPath)
    if ($n) { return $n.InnerText.Trim() } else { return '' }
}

function Get-HPIASummary {
    $rapDir = 'C:\HPIAReport'
    if (-not (Test-Path $rapDir)) { return $null }

    $jsonFile = Get-ChildItem $rapDir -Filter '*.json' -File -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $xmlPath = $null
    if ($jsonFile) {
        $cand = Join-Path $rapDir ($jsonFile.BaseName + '.xml')
        if (Test-Path -LiteralPath $cand) { $xmlPath = $cand }
    } else {
        $xf = Get-ChildItem $rapDir -Filter '*.xml' -File -ErrorAction SilentlyContinue |
              Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($xf) { $xmlPath = $xf.FullName }
    }

    $x = $null; $j = $null
    if ($xmlPath)  { try { $x = [xml](Get-Content -LiteralPath $xmlPath -Raw) } catch {} }
    if ($jsonFile) { try { $j = (Get-Content -LiteralPath $jsonFile.FullName -Raw | ConvertFrom-Json).HPIA } catch {} }

    # ── Terugval: alleen HTML aanwezig ──
    if (-not $x -and -not $j) {
        $html = Get-ChildItem $rapDir -Filter '*.html' -File -ErrorAction SilentlyContinue |
                Sort-Object @{ E = { $_.Name -like 'Readme*' } }, @{ E = { $_.LastWriteTime }; Descending = $true } |
                Select-Object -First 1
        if (-not $html) { return $null }
        $raw = try { [System.IO.File]::ReadAllText($html.FullName) } catch { '' }
        $passClean   = ([regex]::Matches($raw, '(?i)>\s*Pass\s*<')).Count
        $passRestart = ([regex]::Matches($raw, '(?i)>\s*Pass\s+\*\s*<')).Count
        $failCount   = ([regex]::Matches($raw, '(?i)>\s*Fail\s*<')).Count
        return @{
            Source = 'html'; File = $html.Name; Date = $html.LastWriteTime.ToString('dd-MM-yyyy HH:mm')
            Stale = $html.LastWriteTime -lt (Get-Date).AddDays(-7)
            ToolVersion = ''; Health = ''; BiosSecurity = ''; Items = @()
            Counts = [ordered]@{ Total = $passClean + $passRestart + $failCount; Installed = $passClean + $passRestart; Reboot = $passRestart; Failed = $failCount; Open = 0 }
            Message = "Alleen een HTML-rapport gevonden ($($html.Name)), details per update zijn niet beschikbaar."
        }
    }

    $catNames = @{ Drivers = 'Driver'; Software = 'Software'; Firmware = 'Firmware'; BIOS = 'BIOS'; BIOSSettings = 'BIOS' }
    $items = [ordered]@{}

    # Analyse (XML): wat is er aanbevolen, met oude en nieuwe versie
    if ($x) {
        foreach ($rec in $x.SelectNodes('/HPIA/Recommendations/*/Recommendation')) {
            $id   = Get-XmlText $rec 'Solution/Softpaq/Id'
            $key  = if ($id) { $id.ToLower() } else { "x$($items.Count)" }
            $cat  = $rec.ParentNode.Name
            $name = Get-XmlText $rec 'Solution/Softpaq/Name'
            $comp = Get-XmlText $rec 'TargetComponent'
            $items[$key] = @{
                Category   = $(if ($catNames.ContainsKey($cat)) { $catNames[$cat] } else { $cat })
                Name       = $(if ($name) { $name } else { $comp })
                Component  = $comp
                SoftPaq    = $id
                OldVersion = Get-XmlText $rec 'TargetVersion'
                NewVersion = $(if (Get-XmlText $rec 'ReferenceVersion') { Get-XmlText $rec 'ReferenceVersion' } else { Get-XmlText $rec 'Solution/Softpaq/Version' })
                Status     = 'Open'
                Detail     = ''
            }
        }
    }

    # Uitvoering (JSON): per SoftPaq het installatieresultaat
    if ($j -and $j.Recommendations) {
        foreach ($rj in @($j.Recommendations)) {
            $id  = "$($rj.SoftPaqID)"
            $key = if ($id) { $id.ToLower() } else { "j$($items.Count)" }
            if (-not $items.Contains($key)) {
                $items[$key] = @{ Category = '-'; Name = "$($rj.Name)"; Component = ''; SoftPaq = $id
                                  OldVersion = ''; NewVersion = "$($rj.RecommendationValue)"; Status = 'Open'; Detail = '' }
            }
            $it  = $items[$key]
            $rem = $rj.Remediation
            if (-not $rem) { continue }
            $stTxt = "$($rem.Status)"; $rc = "$($rem.ReturnCode)"; $desc = "$($rem.ReturnDescription)"
            $okRc  = (-not $rc) -or ($rc -in '0', '3010', '1641')
            if ($stTxt -match 'FAIL|ERROR|CANCEL' -or $desc -match '^(FAIL|ERROR)' -or -not $okRc) { $it.Status = 'Failed' }
            elseif ($desc -match 'SUCCESS:REBOOT' -or $rc -in '3010', '1641')                       { $it.Status = 'Reboot' }
            elseif ($stTxt -match 'COMPLETED|SUCCESS|INSTALLED')                                      { $it.Status = 'Installed' }
            $detail = if ($desc -match '=(.+)$') { $matches[1].Trim() } else { $desc }
            if (-not $detail) { $detail = $stTxt }
            if ($it.Status -eq 'Failed' -and $rc) { $detail = "$detail (code $rc)" }
            $it.Detail = $detail
        }
    }

    # Mislukt bovenaan, daarna herstart nodig, niet geinstalleerd, geinstalleerd
    $prio = @{ Failed = 0; Reboot = 1; Open = 2; Installed = 3 }
    $list = @($items.Values | Sort-Object @{ E = { $prio[$_.Status] } }, @{ E = { $_.Category } }, @{ E = { $_.Name } })

    $dt = $null
    if ($j -and $j.LastAnalyzedDate) {
        if ($j.LastAnalyzedDate -is [datetime]) { $dt = $j.LastAnalyzedDate } else { try { $dt = [datetime]::Parse("$($j.LastAnalyzedDate)") } catch {} }
    }
    if (-not $dt) { $dt = if ($jsonFile) { $jsonFile.LastWriteTime } else { (Get-Item -LiteralPath $xmlPath).LastWriteTime } }

    $healthMap = @{ Good = 'Goed'; Warning = 'Waarschuwing'; Critical = 'Kritiek' }
    $health = Get-XmlText $x '/HPIA/OverallHealth'
    if ($healthMap.ContainsKey($health)) { $health = $healthMap[$health] }
    $biosSec = switch ("$($j.BIOSSetupSecurity)") {
        'BIOS_NOT_PROTECTED' { 'Geen BIOS-wachtwoord ingesteld' }
        'BIOS_PROTECTED'     { 'BIOS-wachtwoord ingesteld' }
        default              { '' }
    }

    $counts = [ordered]@{
        Total     = $list.Count
        Installed = @($list | Where-Object { $_.Status -in 'Installed', 'Reboot' }).Count
        Reboot    = @($list | Where-Object { $_.Status -eq 'Reboot' }).Count
        Failed    = @($list | Where-Object { $_.Status -eq 'Failed' }).Count
        Open      = @($list | Where-Object { $_.Status -eq 'Open' }).Count
    }
    $msg = if ($list.Count -eq 0) { 'Geen updates nodig: alle drivers, software en firmware zijn up-to-date.' } else { '' }

    return @{
        Source = 'json'; File = $(if ($jsonFile) { $jsonFile.Name } else { Split-Path $xmlPath -Leaf })
        Date = $dt.ToString('dd-MM-yyyy HH:mm'); Stale = $dt -lt (Get-Date).AddDays(-7)
        ToolVersion = Get-XmlText $x '/HPIA/ToolVersion'; Health = $health; BiosSecurity = $biosSec
        Items = $list; Counts = $counts; Message = $msg
    }
}

# ── PDF-tekenhulpjes (GDI+, eenheid = 1/100 inch) ────────────────────
function ConvertTo-PdfColor { param([string]$Hex, [int]$Alpha = 255) [System.Drawing.Color]::FromArgb($Alpha, [System.Drawing.ColorTranslator]::FromHtml($Hex)) }
function New-PdfBrush       { param([string]$Hex) New-Object System.Drawing.SolidBrush (ConvertTo-PdfColor $Hex) }

function New-PdfRoundedPath {
    param([double]$X, [double]$Y, [double]$W, [double]$H, [double]$R)
    $p  = New-Object System.Drawing.Drawing2D.GraphicsPath
    $dd = [float][Math]::Min($R * 2, [Math]::Min($W, $H))
    $p.AddArc([float]$X, [float]$Y, $dd, $dd, [float]180, [float]90)
    $p.AddArc([float]($X + $W - $dd), [float]$Y, $dd, $dd, [float]270, [float]90)
    $p.AddArc([float]($X + $W - $dd), [float]($Y + $H - $dd), $dd, $dd, [float]0, [float]90)
    $p.AddArc([float]$X, [float]($Y + $H - $dd), $dd, $dd, [float]90, [float]90)
    $p.CloseFigure()
    return $p
}

function Add-PdfRoundRect {
    param($G, $Fill, $Pen, [double]$X, [double]$Y, [double]$W, [double]$H, [double]$R = 6)
    $path = New-PdfRoundedPath $X $Y $W $H $R
    if ($Fill) { $G.FillPath($Fill, $path) }
    if ($Pen)  { $G.DrawPath($Pen, $path) }
    $path.Dispose()
}

# Statusicoon als vorm (geen glyph), zodat het niet afhangt van font-fallback
function Add-PdfStatusIcon {
    param($G, $Res, [double]$X, [double]$Y, [double]$S, $State)
    $fill = if ($null -eq $State) { $Res.BIconGray } elseif ($State) { $Res.BIconGreen } else { $Res.BIconRed }
    $G.FillEllipse($fill, [float]$X, [float]$Y, [float]$S, [float]$S)
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, [float]($S * 0.15))
    $pen.StartCap = 'Round'; $pen.EndCap = 'Round'; $pen.LineJoin = 'Round'
    if ($null -eq $State) {
        $G.DrawLine($pen, [float]($X + $S * 0.3), [float]($Y + $S * 0.5), [float]($X + $S * 0.7), [float]($Y + $S * 0.5))
    } elseif ($State) {
        $G.DrawLines($pen, [System.Drawing.PointF[]]@(
            [System.Drawing.PointF]::new($X + $S * 0.27, $Y + $S * 0.52),
            [System.Drawing.PointF]::new($X + $S * 0.44, $Y + $S * 0.68),
            [System.Drawing.PointF]::new($X + $S * 0.74, $Y + $S * 0.34)))
    } else {
        $G.DrawLine($pen, [float]($X + $S * 0.33), [float]($Y + $S * 0.33), [float]($X + $S * 0.67), [float]($Y + $S * 0.67))
        $G.DrawLine($pen, [float]($X + $S * 0.67), [float]($Y + $S * 0.33), [float]($X + $S * 0.33), [float]($Y + $S * 0.67))
    }
    $pen.Dispose()
}

function Add-PdfSection {
    param($G, $Res, [string]$Title, [double]$X, [double]$Y)
    $G.FillRectangle($Res.BAccent, [float]$X, [float]($Y + 3), [float]4, [float]17)
    $G.DrawString($Title, $Res.FSection, $Res.BDark, [float]($X + 11), [float]$Y)
    return ($Y + 30)
}

function Add-PdfPill {
    param($G, $Res, [string]$Text, $Fg, $Bg, [double]$X, [double]$Y)
    $sz = $G.MeasureString($Text, $Res.FPill)
    Add-PdfRoundRect $G $Bg $null $X $Y ($sz.Width + 10) 17 8.5
    $G.DrawString($Text, $Res.FPill, $Fg, [float]($X + 5), [float]($Y + (17 - $sz.Height) / 2))
}

function Add-PdfMessageCard {
    param($G, $Res, [string]$Text, $State, [double]$X, [double]$Y, [double]$W)
    $bg = if ($null -eq $State) { $Res.BGrayBg } elseif ($State) { $Res.BGreenBg } else { $Res.BRedBg }
    $h  = [Math]::Max(40, $G.MeasureString($Text, $Res.FBody, [int]($W - 60)).Height + 22)
    Add-PdfRoundRect $G $bg $null $X $Y $W $h 8
    Add-PdfStatusIcon $G $Res ($X + 14) ($Y + ($h - 18) / 2) 18 $State
    $G.DrawString($Text, $Res.FBody, $Res.BText, [System.Drawing.RectangleF]::new($X + 42, $Y + 11, $W - 56, $h - 16))
    return ($Y + $h)
}

$script:pdfStatusInfo = @{
    Installed = @{ Label = 'Geinstalleerd';      Fg = 'BGreen'; Bg = 'BGreenBg' }
    Reboot    = @{ Label = 'Herstart nodig';     Fg = 'BAmber'; Bg = 'BAmberBg' }
    Failed    = @{ Label = 'Mislukt';            Fg = 'BRed';   Bg = 'BRedBg' }
    Open      = @{ Label = 'Niet geinstalleerd'; Fg = 'BGray';  Bg = 'BGrayBg' }
}

function New-PdfResources {
    $f = { param($size, $style = 'Regular') New-Object System.Drawing.Font('Segoe UI', [float]$size, [System.Drawing.FontStyle]$style) }
    $sfEll = New-Object System.Drawing.StringFormat
    $sfEll.Trimming = 'EllipsisCharacter'; $sfEll.FormatFlags = 'NoWrap'
    $sfRight = New-Object System.Drawing.StringFormat
    $sfRight.Alignment = 'Far'
    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = 'Center'; $sfCenter.LineAlignment = 'Center'
    return @{
        FTitle = (& $f 20 'Bold'); FHeadSub = (& $f 9.5); FBadge = (& $f 8.5 'Bold'); FSection = (& $f 12 'Bold')
        FLabel = (& $f 7); FValue = (& $f 9.5 'Bold'); FBody = (& $f 9); FBodyB = (& $f 9 'Bold')
        FSmall = (& $f 8); FSmallI = (& $f 8 'Italic'); FTileNum = (& $f 22 'Bold'); FTileLbl = (& $f 8); FPill = (& $f 7.5 'Bold')
        FHead  = (& $f 7.5 'Bold')
        BWhite = (New-PdfBrush '#FFFFFF'); BDark = (New-PdfBrush '#03173D'); BAccent = (New-PdfBrush '#208AD0'); BLight = (New-PdfBrush '#60BEF0')
        BText  = (New-PdfBrush '#111827'); BSub  = (New-PdfBrush '#6B7280'); BHeadSub = (New-PdfBrush '#CBD5E1')
        BGreen = (New-PdfBrush '#15803D'); BGreenBg = (New-PdfBrush '#DCFCE7')
        BRed   = (New-PdfBrush '#B91C1C'); BRedBg   = (New-PdfBrush '#FEE2E2')
        BAmber = (New-PdfBrush '#B45309'); BAmberBg = (New-PdfBrush '#FEF3C7')
        BGray  = (New-PdfBrush '#4B5563'); BGrayBg  = (New-PdfBrush '#F1F5F9')
        BBlueBg = (New-PdfBrush '#E0F0FA'); BCard = (New-PdfBrush '#F8FAFC'); BZebra = (New-PdfBrush '#F8FAFC')
        BIconGreen = (New-PdfBrush '#16A34A'); BIconRed = (New-PdfBrush '#DC2626'); BIconGray = (New-PdfBrush '#9CA3AF')
        PBorder = (New-Object System.Drawing.Pen((ConvertTo-PdfColor '#E2E8F0'), [float]1))
        SfEllipsis = $sfEll; SfRight = $sfRight; SfCenter = $sfCenter
    }
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

    $cs   = try { Get-CimInstance Win32_ComputerSystem } catch { $null }
    $bios = try { Get-CimInstance Win32_BIOS } catch { $null }
    $hpia = Get-HPIASummary
    $isHP = "$($cs.Manufacturer)" -match 'HP|Hewlett'
    $hpiaFailed = if ($hpia) { $hpia.Counts.Failed } else { 0 }
    $laptopTxt  = $script:infoRowMap['Laptop'].Label.Text -replace '^Apparaattype:\s*', ''

    $script:_pdfData = @{
        Serial = $serial; Computer = $env:COMPUTERNAME; Date = Get-Date -Format 'dd-MM-yyyy HH:mm'
        Version = "v$script:currentVersion - $script:versionName"; Logo = $script:logoImageGdi
        Device = @(
            @{ K = 'Computernaam'; V = $env:COMPUTERNAME }
            @{ K = 'Serienummer';  V = $serial }
            @{ K = 'Fabrikant';    V = "$($cs.Manufacturer)" }
            @{ K = 'Model';        V = "$($cs.Model)" }
            @{ K = 'Windows';      V = $script:infoRowMap['Windows'].Label.Text }
            @{ K = 'BIOS-versie';  V = "$($bios.SMBIOSBIOSVersion)" }
            @{ K = 'Geheugen';     V = $(try { '{0:N0} GB' -f ((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB) } catch { '-' }) }
            @{ K = 'Apparaattype'; V = $laptopTxt }
        )
        Keys = @(
            @{ Label = $script:infoRowMap['ActiveKey'].Label.Text;   OK = $script:okActivation }
            @{ Label = $script:infoRowMap['OemKey'].Label.Text;      OK = $null }
            @{ Label = $script:infoRowMap['CompliesKey'].Label.Text; OK = $null }
        )
        Checks = @(
            @{ Label = $script:infoRowMap['Activatie'].Label.Text;  OK = $script:okActivation }
            @{ Label = $script:infoRowMap['Tpm'].Label.Text;        OK = $script:okTpm }
            @{ Label = $script:infoRowMap['SecureBoot'].Label.Text; OK = $script:okSecureBoot }
            @{ Label = $script:infoRowMap['Internet'].Label.Text;   OK = $script:okInternet }
            @{ Label = $script:infoRowMap['Wifi'].Label.Text;       OK = $script:okWifi }
            @{ Label = $script:infoRowMap['HP'].Label.Text;         OK = ($script:hpBloatFound.Count -eq 0) }
        )
        Bloat = @($script:hpBloatFound); HPIA = $hpia; IsHP = $isHP
        AllOk = ($script:okActivation -and $script:okTpm -and $script:okSecureBoot -and $script:okInternet -and $hpiaFailed -eq 0)
    }
    $script:_pdfRes   = New-PdfResources
    $script:_pdfState = @{ Page = 0; RowIdx = 0; Done = $false }

    $pd = New-Object System.Drawing.Printing.PrintDocument
    $pd.PrinterSettings.PrinterName   = 'Microsoft Print to PDF'
    $pd.PrinterSettings.PrintToFile   = $true
    $pd.PrinterSettings.PrintFileName = $outputPath
    $a4 = $pd.PrinterSettings.PaperSizes | Where-Object { $_.Kind -eq 'A4' } | Select-Object -First 1
    if ($a4) { $pd.DefaultPageSettings.PaperSize = $a4 }

    $pd.Add_PrintPage({
        param($s2, $ev)
        $d  = $script:_pdfData
        $r  = $script:_pdfRes
        $st = $script:_pdfState
        $g  = $ev.Graphics
        $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

        $dot    = [char]0x00B7
        $arrow  = [char]0x2192
        $pageW  = [double]$ev.PageBounds.Width
        $pageH  = [double]$ev.PageBounds.Height
        $L      = 45.0
        $W      = $pageW - 90
        $Rx     = $L + $W
        $bottom = $pageH - 60
        $hasMore = $false
        $st.Page++
        $items = @(if ($d.HPIA) { $d.HPIA.Items })

        if ($st.Page -eq 1) {
            # ── Kop: verloop in huisstijl met wit logovlak (zelfde vorm als de GUI) ──
            $hH = 112.0
            $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush([System.Drawing.RectangleF]::new(0, 0, $pageW, $hH), (ConvertTo-PdfColor '#208AD0'), (ConvertTo-PdfColor '#03173D'), [single]0)
            $g.FillRectangle($grad, [float]0, [float]0, [float]$pageW, [float]$hH)
            $grad.Dispose()
            $g.FillPolygon($r.BWhite, [System.Drawing.PointF[]]@(
                [System.Drawing.PointF]::new(0, 0), [System.Drawing.PointF]::new(250, 0),
                [System.Drawing.PointF]::new(215, $hH), [System.Drawing.PointF]::new(0, $hH)))
            $g.FillPolygon($r.BLight, [System.Drawing.PointF[]]@(
                [System.Drawing.PointF]::new(256, 0), [System.Drawing.PointF]::new(264, 0),
                [System.Drawing.PointF]::new(229, $hH), [System.Drawing.PointF]::new(221, $hH)))
            if ($null -ne $d.Logo) {
                $ratio = [Math]::Min(185 / $d.Logo.Width, ($hH - 30) / $d.Logo.Height)
                $lw = $d.Logo.Width * $ratio; $lh = $d.Logo.Height * $ratio
                $g.DrawImage($d.Logo, [System.Drawing.RectangleF]::new(18, ($hH - $lh) / 2, $lw, $lh))
            } else {
                $g.DrawString('EOO', $r.FTitle, $r.BDark, [float]30, [float]38)
            }
            $tx = 282.0
            $g.DrawString('Installatierapport', $r.FTitle, $r.BWhite, [float]$tx, [float]20)
            $g.DrawString("$($d.Computer)   $dot   Serienummer $($d.Serial)", $r.FHeadSub, $r.BWhite, [float]$tx, [float]58)
            $g.DrawString("Gemaakt op $($d.Date)", $r.FHeadSub, $r.BHeadSub, [float]$tx, [float]76)

            $badge = if ($d.AllOk) { 'GEREED' } else { 'AANDACHT NODIG' }
            $bsz = $g.MeasureString($badge, $r.FBadge)
            $bw = $bsz.Width + 24; $bx = $Rx - $bw
            Add-PdfRoundRect $g $(if ($d.AllOk) { $r.BIconGreen } else { $r.BIconRed }) $null $bx 24 $bw 26 13
            $g.DrawString($badge, $r.FBadge, $r.BWhite, [System.Drawing.RectangleF]::new($bx, 24, $bw, 26), $r.SfCenter)

            $y = $hH + 24

            # ── Apparaat ──
            $y = Add-PdfSection $g $r 'Apparaat' $L $y
            $rowsN = [Math]::Ceiling($d.Device.Count / 2)
            $cardH = $rowsN * 36 + 14
            Add-PdfRoundRect $g $r.BCard $r.PBorder $L $y $W $cardH 8
            $colW = ($W - 32) / 2
            for ($i = 0; $i -lt $d.Device.Count; $i++) {
                $cx = $L + 16 + ($i % 2) * $colW
                $cy = $y + 9 + [Math]::Floor($i / 2) * 36
                $g.DrawString($d.Device[$i].K.ToUpper(), $r.FLabel, $r.BSub, [float]$cx, [float]$cy)
                $val = if ($d.Device[$i].V) { $d.Device[$i].V } else { '-' }
                $g.DrawString($val, $r.FValue, $r.BText, [System.Drawing.RectangleF]::new($cx, $cy + 12, $colW - 12, 18), $r.SfEllipsis)
            }
            $y += $cardH + 20

            # ── Licentie ──
            $y = Add-PdfSection $g $r 'Licentie' $L $y
            $cardH = $d.Keys.Count * 24 + 12
            Add-PdfRoundRect $g $r.BCard $r.PBorder $L $y $W $cardH 8
            $ky = $y + 9
            foreach ($k in $d.Keys) {
                Add-PdfStatusIcon $g $r ($L + 16) ($ky + 1) 14 $k.OK
                $g.DrawString($k.Label, $r.FBody, $r.BText, [System.Drawing.RectangleF]::new($L + 40, $ky, $W - 56, 18), $r.SfEllipsis)
                $ky += 24
            }
            $y += $cardH + 20

            # ── Systeemcontroles (2 kolommen) ──
            $y = Add-PdfSection $g $r 'Systeemcontroles' $L $y
            $rowsN = [Math]::Ceiling($d.Checks.Count / 2)
            $cardH = $rowsN * 26 + 12
            Add-PdfRoundRect $g $r.BCard $r.PBorder $L $y $W $cardH 8
            for ($i = 0; $i -lt $d.Checks.Count; $i++) {
                $cx = $L + 16 + ($i % 2) * $colW
                $cy = $y + 10 + [Math]::Floor($i / 2) * 26
                Add-PdfStatusIcon $g $r $cx ($cy + 1) 14 $d.Checks[$i].OK
                $g.DrawString($d.Checks[$i].Label, $r.FBody, $r.BText, [System.Drawing.RectangleF]::new($cx + 22, $cy, $colW - 34, 18), $r.SfEllipsis)
            }
            $y += $cardH + 12

            # ── HP bloatware (alleen als er iets gevonden is) ──
            if ($d.Bloat.Count -gt 0) {
                $rowsN = [Math]::Ceiling($d.Bloat.Count / 2)
                $cardH = 30 + $rowsN * 16 + 8
                Add-PdfRoundRect $g $r.BRedBg $null $L $y $W $cardH 8
                $g.DrawString("HP bloatware gevonden ($($d.Bloat.Count))", $r.FBodyB, $r.BRed, [float]($L + 16), [float]($y + 9))
                for ($i = 0; $i -lt $d.Bloat.Count; $i++) {
                    $cx = $L + 16 + ($i % 2) * $colW
                    $cy = $y + 30 + [Math]::Floor($i / 2) * 16
                    $g.DrawString("$dot  $($d.Bloat[$i])", $r.FSmall, $r.BText, [System.Drawing.RectangleF]::new($cx, $cy, $colW - 12, 16), $r.SfEllipsis)
                }
                $y += $cardH + 12
            }
            $y += 8

            # ── Drivers en updates (HPIA) ──
            $y = Add-PdfSection $g $r 'Drivers en updates (HP Image Assistant)' $L $y
            $h = $d.HPIA
            if (-not $h) {
                if ($d.IsHP) {
                    $y = Add-PdfMessageCard $g $r 'Geen HPIA-rapport gevonden. HP Image Assistant is op dit apparaat nog niet gedraaid.' $false $L $y $W
                } else {
                    $y = Add-PdfMessageCard $g $r 'Niet van toepassing: dit is geen HP-apparaat.' $null $L $y $W
                }
                $st.Done = $true
            } else {
                $meta = @("Laatste analyse: $($h.Date)")
                if ($h.ToolVersion)  { $meta += "HPIA $($h.ToolVersion)" }
                if ($h.Health)       { $meta += "Algemene status: $($h.Health)" }
                if ($h.BiosSecurity) { $meta += $h.BiosSecurity }
                $g.DrawString(($meta -join "   $dot   "), $r.FSmall, $r.BSub, [System.Drawing.RectangleF]::new($L, $y - 4, $W, 16), $r.SfEllipsis)
                $y += 14
                if ($h.Stale) {
                    $g.DrawString('Let op: dit HPIA-rapport is ouder dan 7 dagen.', $r.FSmall, $r.BRed, [float]$L, [float]$y)
                    $y += 14
                }
                $y += 6

                # Tegels met aantallen
                $c = $h.Counts
                $tiles = @(
                    @{ N = $c.Total;     L = 'Aanbevolen';         Fg = $r.BDark;  Bg = $r.BBlueBg }
                    @{ N = $c.Installed; L = 'Geinstalleerd';      Fg = $r.BGreen; Bg = $r.BGreenBg }
                    @{ N = $c.Reboot;    L = 'Herstart nodig';     Fg = $r.BAmber; Bg = $r.BAmberBg }
                    @{ N = $c.Failed;    L = 'Mislukt';            Fg = $r.BRed;   Bg = $r.BRedBg }
                    @{ N = $c.Open;      L = 'Niet geinstalleerd'; Fg = $r.BGray;  Bg = $r.BGrayBg }
                )
                $gap = 10.0; $tw = ($W - 4 * $gap) / 5; $th = 64.0
                for ($i = 0; $i -lt $tiles.Count; $i++) {
                    $t  = $tiles[$i]
                    $tx2 = $L + $i * ($tw + $gap)
                    Add-PdfRoundRect $g $t.Bg $null $tx2 $y $tw $th 8
                    $g.DrawString("$($t.N)", $r.FTileNum, $t.Fg, [System.Drawing.RectangleF]::new($tx2, $y + 4, $tw, 38), $r.SfCenter)
                    $g.DrawString($t.L, $r.FTileLbl, $r.BGray, [System.Drawing.RectangleF]::new($tx2, $y + 40, $tw, 18), $r.SfCenter)
                }
                $y += $th + 16

                if ($items.Count -eq 0) {
                    $state = if ($h.Source -eq 'html') { $null } else { $true }
                    $y = Add-PdfMessageCard $g $r $h.Message $state $L $y $W
                    $st.Done = $true
                } elseif ($c.Reboot -gt 0) {
                    $y = Add-PdfMessageCard $g $r 'Herstart het apparaat om de updates met status "Herstart nodig" af te ronden.' $null $L $y $W
                    $y += 12
                }
            }
        } else {
            # ── Vervolgpagina: smalle kopbalk ──
            $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush([System.Drawing.RectangleF]::new(0, 0, $pageW, 40), (ConvertTo-PdfColor '#208AD0'), (ConvertTo-PdfColor '#03173D'), [single]0)
            $g.FillRectangle($grad, [float]0, [float]0, [float]$pageW, [float]40)
            $grad.Dispose()
            $g.DrawString("Installatierapport   $dot   $($d.Computer)   $dot   Serienummer $($d.Serial)", $r.FBodyB, $r.BWhite, [float]$L, [float]12)
            $y = 64.0
            $y = Add-PdfSection $g $r 'Drivers en updates (vervolg)' $L $y
        }

        # ── Tabel met updates (loopt door over meerdere pagina's) ──
        if (-not $st.Done -and $items.Count -gt 0) {
            if ($bottom - $y -lt 80) {
                $hasMore = $true
            } else {
                $xStatus = $L + 8; $xCat = $L + 124; $xName = $L + 192; $xVer = $Rx - 150
                $nameW = $xVer - $xName - 12
                Add-PdfRoundRect $g $r.BDark $null $L $y $W 24 6
                $g.DrawString('STATUS',    $r.FHead, $r.BWhite, [float]$xStatus, [float]($y + 6))
                $g.DrawString('CATEGORIE', $r.FHead, $r.BWhite, [float]$xCat,    [float]($y + 6))
                $g.DrawString('ONDERDEEL', $r.FHead, $r.BWhite, [float]$xName,   [float]($y + 6))
                $g.DrawString('VERSIE (OUD ' + $arrow + ' NIEUW)', $r.FHead, $r.BWhite, [float]$xVer, [float]($y + 6))
                $y += 26
                $first = $true
                while ($st.RowIdx -lt $items.Count) {
                    $it  = $items[$st.RowIdx]
                    $sub = (@($it.SoftPaq, $it.Component) | Where-Object { $_ -and $_ -ne $it.Name }) -join "   $dot   "
                    $hName = $g.MeasureString($it.Name, $r.FBodyB, [int]$nameW).Height
                    $hSub  = if ($sub)       { $g.MeasureString($sub, $r.FSmall, [int]$nameW).Height } else { 0 }
                    $hDet  = if ($it.Detail) { $g.MeasureString($it.Detail, $r.FSmallI, [int]$nameW).Height } else { 0 }
                    $rowH  = [Math]::Max(38, $hName + $hSub + $hDet + 14)
                    if (($y + $rowH -gt $bottom) -and -not $first) { break }

                    if ($st.RowIdx % 2 -eq 1) { $g.FillRectangle($r.BZebra, [float]$L, [float]$y, [float]$W, [float]$rowH) }
                    $info = $script:pdfStatusInfo[$it.Status]
                    Add-PdfPill $g $r $info.Label $r[$info.Fg] $r[$info.Bg] $xStatus ($y + 9)
                    $g.DrawString($it.Category, $r.FBody, $r.BText, [float]$xCat, [float]($y + 9))

                    $ty = $y + 7
                    $g.DrawString($it.Name, $r.FBodyB, $r.BText, [System.Drawing.RectangleF]::new($xName, $ty, $nameW, $hName + 2)); $ty += $hName
                    if ($sub)       { $g.DrawString($sub, $r.FSmall, $r.BSub, [System.Drawing.RectangleF]::new($xName, $ty, $nameW, $hSub + 2)); $ty += $hSub }
                    if ($it.Detail) { $g.DrawString($it.Detail, $r.FSmallI, $(if ($it.Status -eq 'Failed') { $r.BRed } else { $r.BSub }), [System.Drawing.RectangleF]::new($xName, $ty, $nameW, $hDet + 2)) }

                    if ($it.OldVersion) {
                        $g.DrawString($it.OldVersion, $r.FSmall, $r.BSub, [float]$xVer, [float]($y + 7))
                        $g.DrawString("$arrow $($it.NewVersion)", $r.FBodyB, $r.BText, [float]$xVer, [float]($y + 20))
                    } elseif ($it.NewVersion) {
                        $g.DrawString($it.NewVersion, $r.FBodyB, $r.BText, [float]$xVer, [float]($y + 9))
                    }
                    $g.DrawLine($r.PBorder, [float]$L, [float]($y + $rowH), [float]$Rx, [float]($y + $rowH))
                    $y += $rowH
                    $st.RowIdx++
                    $first = $false
                }
                $hasMore = $st.RowIdx -lt $items.Count
            }
        }

        # ── Voettekst ──
        $fy = $pageH - 44
        $g.DrawLine($r.PBorder, [float]$L, [float]$fy, [float]$Rx, [float]$fy)
        $g.DrawString("Gegenereerd door EOO Windows Installatie Tool $($d.Version)   $dot   Easy Office Online   $dot   eoo.nl", $r.FSmall, $r.BSub, [float]$L, [float]($fy + 7))
        $g.DrawString("Pagina $($st.Page)", $r.FSmall, $r.BSub, [System.Drawing.RectangleF]::new($L, $fy + 7, $W, 16), $r.SfRight)

        $ev.HasMorePages = $hasMore
    })

    try {
        $pd.Print()
        Write-Console 'PDF gereed, de bon wordt naar Azure Files bezorgd...' 'info'
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
        if ($script:_pdfRes) { foreach ($v in $script:_pdfRes.Values) { try { $v.Dispose() } catch {} } }
        $script:_pdfData = $null; $script:_pdfRes = $null; $script:_pdfState = $null
    }
}

$btnExportPDF.Add_Click({
    $btnExportPDF.IsEnabled = $false
    Write-Console 'Rapport als PDF exporteren... de kassabon wordt geprint.' 'start'
    Export-RapportPDF
})

# ── Opstart ─────────────────────────────────────────────────────────
$window.Add_Loaded({
    Write-Console 'Oven voorverwarmd: systeemcontrole uitgevoerd.' 'info'
    Update-InfoPanel
    Update-CompliesKey
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
