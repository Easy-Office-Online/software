Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$BG     = [System.Drawing.ColorTranslator]::FromHtml("#0d0d0d")
$PANEL  = [System.Drawing.ColorTranslator]::FromHtml("#111111")
$ORANGE = [System.Drawing.ColorTranslator]::FromHtml("#CC0000")   # Lely rood
$BTNBG  = [System.Drawing.ColorTranslator]::FromHtml("#1a1a1a")
$WHITE  = [System.Drawing.Color]::White
$GRAY   = [System.Drawing.ColorTranslator]::FromHtml("#aaaaaa")
$RED    = [System.Drawing.ColorTranslator]::FromHtml("#ff3333")
$GREEN  = [System.Drawing.ColorTranslator]::FromHtml("#44cc66")
$DARK   = [System.Drawing.ColorTranslator]::FromHtml("#0a0a0a")

$FontMain  = New-Object System.Drawing.Font("Segoe UI", 10)
$FontSmall = New-Object System.Drawing.Font("Segoe UI", 8)
$FontTitle = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$FontSect  = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)

function Set-Log($msg) {
    $script:lblLog.Text = $msg
    $script:form.Refresh()
}

# Start het script opnieuw als Administrator via een VBScript,
# zodat er geen zwart PS-consolevenster verschijnt.
function Start-ElevatedScript {
    param([string]$Path)
    $vbs = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetTempFileName(), '.vbs')
    $content = @"
CreateObject("Shell.Application").ShellExecute "powershell.exe", _
    "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File " & Chr(34) & "$Path" & Chr(34), _
    "", "runas", 1
"@
    [System.IO.File]::WriteAllText($vbs, $content, [System.Text.Encoding]::ASCII)
    # Asynchroon starten — geen -Wait zodat de UI-thread niet blokkeert.
    # VBS-bestand blijft in %TEMP% staan; Windows ruimt dit periodiek op.
    Start-Process "wscript.exe" -ArgumentList "`"$vbs`"" -WindowStyle Hidden
}

# Maak een knop die z'n eigen tekst tekent via Paint
function New-FlatBtn($mainText, $subText, $x, $y, $w, $h) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Location  = New-Object System.Drawing.Point($x, $y)
    $btn.Size      = New-Object System.Drawing.Size($w, $h)
    $btn.BackColor = $BTNBG
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml("#2a2a2a")
    $btn.FlatAppearance.BorderSize  = 1
    $btn.FlatAppearance.MouseOverBackColor = [System.Drawing.ColorTranslator]::FromHtml("#222222")
    $btn.FlatAppearance.MouseDownBackColor = $ORANGE
    $btn.Cursor    = [System.Windows.Forms.Cursors]::Hand
    $btn.Text      = ""
    $btn.UseVisualStyleBackColor = $false
    $btn.Tag = "$mainText|$subText"

    $btn.Add_Paint({
        param($sender, $e)
        $parts = $sender.Tag -split [char]124, 2
        $main  = $parts[0]
        $sub   = if ($parts.Count -gt 1) { $parts[1] } else { "" }

        $g = $e.Graphics
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

        $fMain  = New-Object System.Drawing.Font("Segoe UI", 10)
        $fSub   = New-Object System.Drawing.Font("Segoe UI", 8)
        $bMain  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
        $bSub   = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#aaaaaa"))

        $avail  = $sender.Width - 24   # beschikbare breedte minus linker- en rechtermarge

        # Hoofdtekst – één regel, ellipsis bij overflow
        $sfMain = New-Object System.Drawing.StringFormat
        $sfMain.Trimming    = [System.Drawing.StringTrimming]::EllipsisCharacter
        $sfMain.FormatFlags = [System.Drawing.StringFormatFlags]::NoWrap
        $rectMain = New-Object System.Drawing.RectangleF(12, 10, $avail, 20)
        $g.DrawString($main, $fMain, $bMain, $rectMain, $sfMain)

        # Subtekst – één regel, ellipsis bij overflow, 6px onder hoofdtekst
        $sfSub = New-Object System.Drawing.StringFormat
        $sfSub.Trimming    = [System.Drawing.StringTrimming]::EllipsisCharacter
        $sfSub.FormatFlags = [System.Drawing.StringFormatFlags]::NoWrap
        $rectSub = New-Object System.Drawing.RectangleF(13, 33, $avail, 16)
        $g.DrawString($sub, $fSub, $bSub, $rectSub, $sfSub)

        $fMain.Dispose(); $fSub.Dispose()
        $bMain.Dispose(); $bSub.Dispose()
        $sfMain.Dispose(); $sfSub.Dispose()
    })

    return $btn
}

function Add-SectLabel($text, $y) {
    $l = New-Object System.Windows.Forms.Label
    $l.Text      = $text
    $l.Font      = $FontSect
    $l.ForeColor = $ORANGE
    $l.BackColor = $BG
    $l.Location  = New-Object System.Drawing.Point(20, $y)
    $l.Size      = New-Object System.Drawing.Size(560, 18)
    $script:form.Controls.Add($l)
}

function Add-Divider($y) {
    $d = New-Object System.Windows.Forms.Panel
    $d.Location  = New-Object System.Drawing.Point(20, $y)
    $d.Size      = New-Object System.Drawing.Size(560, 1)
    $d.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1c1c1c")
    $script:form.Controls.Add($d)
}

# Hoofdvenster
$form = New-Object System.Windows.Forms.Form
$form.Text            = "Lely IT Tool"
$form.Size            = New-Object System.Drawing.Size(622, 472)
$form.MinimumSize     = $form.Size
$form.MaximumSize     = $form.Size
$form.BackColor       = $BG
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox     = $false
$form.StartPosition   = [System.Windows.Forms.FormStartPosition]::CenterScreen

# Header panel
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Location  = New-Object System.Drawing.Point(0, 0)
$pnlHeader.Size      = New-Object System.Drawing.Size(622, 80)
$pnlHeader.BackColor = $PANEL
$pnlHeader.Add_Paint({
    param($s,$e)
    $pen = New-Object System.Drawing.Pen($ORANGE, 3)
    $e.Graphics.DrawLine($pen, 0, 77, $s.Width, 77)
    $pen.Dispose()
})

# Lely oval logo
$picCow = New-Object System.Windows.Forms.PictureBox
$picCow.Location  = New-Object System.Drawing.Point(6, 3)
$picCow.Size      = New-Object System.Drawing.Size(96, 62)
$picCow.BackColor = $PANEL
$picCow.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

    # Schaduw
    $brushBlack = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    $g.FillEllipse($brushBlack, 2, 2, 92, 60)

    # Witte rand
    $brushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillEllipse($brushWhite, 0, 0, 92, 60)

    # Rode kern
    $brushRed = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#CC0000"))
    $g.FillEllipse($brushRed, 4, 4, 84, 52)

    # LELY tekst gecentreerd
    $fLely  = New-Object System.Drawing.Font("Impact", 24, [System.Drawing.FontStyle]::Regular)
    $brushW = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $sf     = New-Object System.Drawing.StringFormat
    $sf.Alignment     = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rect = New-Object System.Drawing.RectangleF(4, 4, 84, 52)
    $g.DrawString("LELY", $fLely, $brushW, $rect, $sf)

    $brushBlack.Dispose(); $brushWhite.Dispose(); $brushRed.Dispose()
    $fLely.Dispose(); $brushW.Dispose(); $sf.Dispose()
})

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text      = "LELY IT TOOL"
$lblTitle.Font      = $FontTitle
$lblTitle.ForeColor = $WHITE
$lblTitle.BackColor = $PANEL
$lblTitle.Location  = New-Object System.Drawing.Point(110, 10)
$lblTitle.AutoSize  = $true

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text      = "IT Toolbox  -  Field Engineer Utility"
$lblSub.Font      = $FontSmall
$lblSub.ForeColor = $GRAY
$lblSub.BackColor = $PANEL
$lblSub.Location  = New-Object System.Drawing.Point(110, 48)
$lblSub.AutoSize  = $true

$lblElev = New-Object System.Windows.Forms.Label
$lblElev.Font        = $FontSmall
$lblElev.BackColor   = $PANEL
$lblElev.Location    = New-Object System.Drawing.Point(488, 24)
$lblElev.Size        = New-Object System.Drawing.Size(110, 18)
$lblElev.TextAlign   = [System.Drawing.ContentAlignment]::MiddleCenter
$lblElev.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
if (Test-IsAdmin) {
    $lblElev.Text      = "ELEVATED OK"
    $lblElev.ForeColor = $GREEN
} else {
    $lblElev.Text      = "NIET ELEVATED"
    $lblElev.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#ff6633")
}

$pnlHeader.Controls.AddRange(@($picCow, $lblTitle, $lblSub, $lblElev))
$form.Controls.Add($pnlHeader)

# Content
$Y = 92

Add-SectLabel "RECHTEN & TOEGANG" $Y
$Y += 20

$btnRunAs     = New-FlatBtn "Run as Admin"     "Herstart tool met verhoogde rechten"    20  $Y 278 52
$btnMakeAdmin = New-FlatBtn "Make Me Admin"    "Voeg toe aan lokale Administrators"     302 $Y 278 52
$form.Controls.AddRange(@($btnRunAs, $btnMakeAdmin))
$Y += 60

Add-Divider $Y; $Y += 10

Add-SectLabel "WINDOWS FIREWALL" $Y
$Y += 20

$btnFwOff = New-FlatBtn "Firewall UIT" "Max 30 minuten, daarna automatisch aan" 20  $Y 278 52
$btnFwOn  = New-FlatBtn "Firewall AAN" "Zet firewall handmatig terug aan"        302 $Y 278 52
$form.Controls.AddRange(@($btnFwOff, $btnFwOn))
$Y += 60

$pnlTimer = New-Object System.Windows.Forms.Panel
$pnlTimer.Location  = New-Object System.Drawing.Point(20, $Y)
$pnlTimer.Size      = New-Object System.Drawing.Size(560, 22)
$pnlTimer.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1a0000")
$pnlTimer.Visible   = $false
$lblTimer = New-Object System.Windows.Forms.Label
$lblTimer.Font      = $FontSmall
$lblTimer.ForeColor = $RED
$lblTimer.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1a0000")
$lblTimer.Location  = New-Object System.Drawing.Point(0, 4)
$lblTimer.Size      = New-Object System.Drawing.Size(560, 14)
$lblTimer.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$lblTimer.Text      = "FIREWALL UITGESCHAKELD - HERSTART OVER: 30:00"
$pnlTimer.Controls.Add($lblTimer)
$form.Controls.Add($pnlTimer)
$Y += 30

Add-Divider $Y; $Y += 10

Add-SectLabel "NETWERK" $Y
$Y += 20

$btnNetwork  = New-FlatBtn "Netwerk overzicht"      "Open Windows netwerkinstellingen"        20  $Y 278 52
$btnEthernet = New-FlatBtn "Ethernet / IP & DNS"   "Direct naar IP-adres en DNS instellingen" 302 $Y 278 52
$form.Controls.AddRange(@($btnNetwork, $btnEthernet))

# Footer
$pnlFooter = New-Object System.Windows.Forms.Panel
$pnlFooter.Location  = New-Object System.Drawing.Point(0, 427)
$pnlFooter.Size      = New-Object System.Drawing.Size(622, 26)
$pnlFooter.BackColor = $DARK
$pnlFooter.Add_Paint({
    param($s,$e)
    $pen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml("#1a1a1a"), 1)
    $e.Graphics.DrawLine($pen, 0, 0, $s.Width, 0)
    $pen.Dispose()
})

$lblLeft = New-Object System.Windows.Forms.Label
$lblLeft.Text = "LELY IT TOOLBOX"
$lblLeft.Font = $FontSmall
$lblLeft.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#333333")
$lblLeft.BackColor = $DARK
$lblLeft.Location  = New-Object System.Drawing.Point(10, 6)
$lblLeft.AutoSize  = $true

$lblLog = New-Object System.Windows.Forms.Label
$lblLog.Text      = "Gereed."
$lblLog.Font      = $FontSmall
$lblLog.ForeColor = $GRAY
$lblLog.BackColor = $DARK
$lblLog.Location  = New-Object System.Drawing.Point(200, 6)
$lblLog.Size      = New-Object System.Drawing.Size(220, 14)
$lblLog.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

$lblKlok = New-Object System.Windows.Forms.Label
$lblKlok.Font      = $FontSmall
$lblKlok.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#333333")
$lblKlok.BackColor = $DARK
$lblKlok.Location  = New-Object System.Drawing.Point(530, 6)
$lblKlok.Size      = New-Object System.Drawing.Size(70, 14)
$lblKlok.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight

$pnlFooter.Controls.AddRange(@($lblLeft, $lblLog, $lblKlok))
$form.Controls.Add($pnlFooter)

# Timer
$script:fwSecondsLeft = 0
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    $script:lblKlok.Text = (Get-Date).ToString("HH:mm:ss")
    if ($script:fwSecondsLeft -gt 0) {
        $script:fwSecondsLeft--
        $min = [math]::Floor($script:fwSecondsLeft / 60)
        $sec = $script:fwSecondsLeft % 60
        $ms = "$min".PadLeft(2,'0')
        $ss = "$sec".PadLeft(2,'0')
        $script:lblTimer.Text = "FIREWALL UITGESCHAKELD - HERSTART OVER: $ms`:$ss"
    }
    if ($script:fwSecondsLeft -le 0 -and $script:pnlTimer.Visible) {
        Remove-NetFirewallRule -DisplayName 'LELY-ALLOW-ALL-IN'  -ErrorAction SilentlyContinue
        Remove-NetFirewallRule -DisplayName 'LELY-ALLOW-ALL-OUT' -ErrorAction SilentlyContinue
        $script:pnlTimer.Visible = $false
        $script:fwSecondsLeft = 0
        Set-Log "Allow-all regels automatisch verwijderd."
    }
})
$timer.Start()

# Button events
$btnRunAs.Add_Click({
    $script = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.ScriptName }
    $script:timer.Stop()
    Start-ElevatedScript -Path $script
    $script:form.Close()
})

$btnMakeAdmin.Add_Click({
    $mmaPaths = @(
        "$env:ProgramFiles\Make Me Admin\MakeMeAdminUI.exe",
        "${env:ProgramFiles(x86)}\Make Me Admin\MakeMeAdminUI.exe"
    )
    $mmaExe = $mmaPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($mmaExe) {
        Start-Process $mmaExe
        Set-Log "MakeMeAdmin gestart."
    } else {
        $result = [System.Windows.Forms.MessageBox]::Show(
            "MakeMeAdmin is niet geinstalleerd op dit systeem.`n`nWil je naar de downloadpagina?",
            "Lely IT Tool",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            Start-Process "https://github.com/pseymour/MakeMeAdmin/releases"
        }
        Set-Log "MakeMeAdmin niet gevonden."
    }
})

$btnFwOff.Add_Click({
    # Auto-elevate als niet admin
    if (-not (Test-IsAdmin)) {
        $script = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.ScriptName }
        $script:timer.Stop()
        Start-ElevatedScript -Path $script
        $script:form.Close()
        return
    }
    try {
        New-NetFirewallRule -DisplayName 'LELY-ALLOW-ALL-IN'  -Direction Inbound  -Action Allow -Protocol Any -Profile Any -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName 'LELY-ALLOW-ALL-OUT' -Direction Outbound -Action Allow -Protocol Any -Profile Any -ErrorAction SilentlyContinue | Out-Null
        $script:fwSecondsLeft = 1800
        $script:pnlTimer.Visible = $true
        Set-Log "Allow-all regels toegevoegd. Timer: 30 min."
    } catch {
        Set-Log "Fout: $_"
    }
})

$btnFwOn.Add_Click({
    try {
        Remove-NetFirewallRule -DisplayName 'LELY-ALLOW-ALL-IN'  -ErrorAction SilentlyContinue
        Remove-NetFirewallRule -DisplayName 'LELY-ALLOW-ALL-OUT' -ErrorAction SilentlyContinue
        $script:fwSecondsLeft = 0
        $script:pnlTimer.Visible = $false
        Set-Log "Allow-all regels verwijderd."
    } catch {
        Set-Log "Fout: toegang geweigerd. Start tool als admin."
    }
})

$btnNetwork.Add_Click({
    Start-Process "ms-settings:network"
    Set-Log "Netwerkinstellingen geopend."
})

$btnEthernet.Add_Click({

    # Stap 1: alle actieve adapters ophalen
    $allAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'Loopback' }
    if (-not $allAdapters) {
        [System.Windows.Forms.MessageBox]::Show("Geen actieve netwerkadapter gevonden.", "Lely IT Tool", "OK", "Warning")
        return
    }

    # Als er meer dan 1 adapter is, eerst kiezen
    if (@($allAdapters).Count -gt 1) {
        $pick = New-Object System.Windows.Forms.Form
        $pick.Text            = "Kies netwerkadapter"
        $pick.Size            = New-Object System.Drawing.Size(420, 300)
        $pick.MinimumSize     = $pick.Size
        $pick.MaximumSize     = $pick.Size
        $pick.BackColor       = [System.Drawing.ColorTranslator]::FromHtml("#0d0d0d")
        $pick.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
        $pick.MaximizeBox     = $false
        $pick.MinimizeBox     = $false
        $pick.StartPosition   = [System.Windows.Forms.FormStartPosition]::CenterParent

        $fontPick = New-Object System.Drawing.Font("Segoe UI", 9)
        $fontHdr  = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
        $lelyRed  = [System.Drawing.ColorTranslator]::FromHtml("#CC0000")
        $darkbgP  = [System.Drawing.ColorTranslator]::FromHtml("#0d0d0d")
        $white    = [System.Drawing.Color]::White
        $gray     = [System.Drawing.ColorTranslator]::FromHtml("#666666")

        $lblPickHdr = New-Object System.Windows.Forms.Label
        $lblPickHdr.Text = "SELECTEER ADAPTER"
        $lblPickHdr.Font = $fontHdr
        $lblPickHdr.ForeColor = $lelyRed
        $lblPickHdr.BackColor = $darkbgP
        $lblPickHdr.Location = New-Object System.Drawing.Point(20, 14)
        $lblPickHdr.AutoSize = $true
        $pick.Controls.Add($lblPickHdr)

        $divPick = New-Object System.Windows.Forms.Panel
        $divPick.Location = New-Object System.Drawing.Point(20, 32)
        $divPick.Size = New-Object System.Drawing.Size(370, 1)
        $divPick.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1c1c1c")
        $pick.Controls.Add($divPick)

        $script:pickResult = $null
        $btnList = @()
        $btnY = 44

        foreach ($adp in $allAdapters) {
            $ipTmp  = Get-NetIPAddress -InterfaceAlias $adp.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
            $ipStr  = if ($ipTmp) { $ipTmp.IPAddress } else { "geen IP" }
            $descStr = if ($adp.InterfaceDescription.Length -gt 38) { $adp.InterfaceDescription.Substring(0,38) + "..." } else { $adp.InterfaceDescription }

            $btn = New-Object System.Windows.Forms.Button
            $btn.Size      = New-Object System.Drawing.Size(370, 44)
            $btn.Location  = New-Object System.Drawing.Point(20, $btnY)
            $btn.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1a1a1a")
            $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
            $btn.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml("#CC0000")
            $btn.FlatAppearance.MouseOverBackColor = [System.Drawing.ColorTranslator]::FromHtml("#2a0000")
            $btn.FlatAppearance.MouseDownBackColor = [System.Drawing.ColorTranslator]::FromHtml("#CC0000")
            $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
            $btn.Text   = ""
            $btn.Tag    = "$($adp.Name)|$ipStr|$descStr"

            $btn.Add_Paint({
                param($sender, $ev)
                $parts = $sender.Tag -split [char]124, 3
                $ev.Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
                $fN = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
                $fD = New-Object System.Drawing.Font("Segoe UI", 8)
                $bN = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
                $bD = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#aaaaaa"))
                $ev.Graphics.DrawString($parts[0], $fN, $bN, 12, 7)
                $ev.Graphics.DrawString(($parts[2] + "  -  " + $parts[1]), $fD, $bD, 13, 27)
                $fN.Dispose(); $fD.Dispose(); $bN.Dispose(); $bD.Dispose()
            })

            # Sla adapternaam op via Name property zodat closure werkt
            $btn.Name = $adp.Name
            $btn.Add_Click({
                param($sender, $ev)
                $script:pickResult = $sender.Name
                $sender.FindForm().DialogResult = [System.Windows.Forms.DialogResult]::OK
                $sender.FindForm().Close()
            })

            $pick.Controls.Add($btn)
            $btnY += 52
        }

        $pick.Size = New-Object System.Drawing.Size(420, ($btnY + 50))
        $pick.MinimumSize = $pick.Size
        $pick.MaximumSize = $pick.Size

        $result = $pick.ShowDialog()
        if ($result -ne [System.Windows.Forms.DialogResult]::OK -or -not $script:pickResult) { return }
        $adapterName = $script:pickResult
    } else {
        $adapterName = $allAdapters[0].Name
    }

    # IP-info ophalen voor gekozen adapter
    $ipInfo = Get-NetIPAddress -InterfaceAlias $adapterName -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
    $gwInfo = Get-NetRoute -InterfaceAlias $adapterName -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Select-Object -First 1
    $dnsInfo = Get-DnsClientServerAddress -InterfaceAlias $adapterName -AddressFamily IPv4 -ErrorAction SilentlyContinue

    $curIP      = if ($ipInfo) { $ipInfo.IPAddress } else { "" }
    $prefix     = if ($ipInfo) { $ipInfo.PrefixLength } else { 24 }
    $bits       = ('1' * $prefix).PadRight(32, '0')
    $curMask    = "$([convert]::ToInt32($bits.Substring(0,8),2)).$([convert]::ToInt32($bits.Substring(8,8),2)).$([convert]::ToInt32($bits.Substring(16,8),2)).$([convert]::ToInt32($bits.Substring(24,8),2))"
    $curGW      = if ($gwInfo) { $gwInfo.NextHop } else { "" }
    $curDNS1    = if ($dnsInfo -and $dnsInfo.ServerAddresses.Count -gt 0) { $dnsInfo.ServerAddresses[0] } else { "" }
    $curDNS2    = if ($dnsInfo -and $dnsInfo.ServerAddresses.Count -gt 1) { $dnsInfo.ServerAddresses[1] } else { "" }
    $isDHCP     = if ($ipInfo) { $ipInfo.PrefixOrigin -eq 'Dhcp' } else { $true }

    # Dialoog venster
    $dlg = New-Object System.Windows.Forms.Form
    $dlg.Text            = "IP-instellingen - $adapterName"
    $dlg.Size            = New-Object System.Drawing.Size(460, 490)
    $dlg.MinimumSize     = $dlg.Size
    $dlg.MaximumSize     = $dlg.Size
    $dlg.BackColor       = [System.Drawing.ColorTranslator]::FromHtml("#0d0d0d")
    $dlg.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $dlg.MaximizeBox     = $false
    $dlg.MinimizeBox     = $false
    $dlg.StartPosition   = [System.Windows.Forms.FormStartPosition]::CenterParent

    $fontDlg  = New-Object System.Drawing.Font("Segoe UI", 10)
    $fontLbl  = New-Object System.Drawing.Font("Segoe UI", 8)
    $orange   = [System.Drawing.ColorTranslator]::FromHtml("#CC0000")
    $white    = [System.Drawing.Color]::White
    $darkbg   = [System.Drawing.ColorTranslator]::FromHtml("#0d0d0d")
    $inputbg  = [System.Drawing.ColorTranslator]::FromHtml("#1a1a1a")
    $dlgInputW = 410

    function New-DlgLabel($text, $x, $y) {
        $l = New-Object System.Windows.Forms.Label
        $l.Text = $text; $l.Font = $fontLbl
        $l.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#888888")
        $l.BackColor = $darkbg
        $l.Location = New-Object System.Drawing.Point($x, $y)
        $l.AutoSize = $true
        return $l
    }

    function New-DlgInput($text, $x, $y, $w) {
        $t = New-Object System.Windows.Forms.TextBox
        $t.Text = $text; $t.Font = $fontDlg
        $t.ForeColor = $white; $t.BackColor = $inputbg
        $t.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $t.Location = New-Object System.Drawing.Point($x, $y)
        $t.Size = New-Object System.Drawing.Size($w, 26)
        return $t
    }

    # DHCP / Statisch toggle
    $radioDHCP   = New-Object System.Windows.Forms.RadioButton
    $radioDHCP.Text = "DHCP (automatisch)"; $radioDHCP.Font = $fontDlg
    $radioDHCP.ForeColor = $white; $radioDHCP.BackColor = $darkbg
    $radioDHCP.Location = New-Object System.Drawing.Point(20, 16)
    $radioDHCP.AutoSize = $true
    $radioDHCP.Checked = $isDHCP

    $radioStatic = New-Object System.Windows.Forms.RadioButton
    $radioStatic.Text = "Statisch IP"; $radioStatic.Font = $fontDlg
    $radioStatic.ForeColor = $white; $radioStatic.BackColor = $darkbg
    $radioStatic.Location = New-Object System.Drawing.Point(220, 16)
    $radioStatic.AutoSize = $true
    $radioStatic.Checked = -not $isDHCP

    # Scheidingslijn onder radio buttons
    $divDlg = New-Object System.Windows.Forms.Panel
    $divDlg.Location = New-Object System.Drawing.Point(20, 46)
    $divDlg.Size = New-Object System.Drawing.Size(410, 1)
    $divDlg.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2a2a2a")

    # Invoervelden  (volledig breedte, 8px gap tussen label en veld, 14px tussen groepen)
    $lblIP   = New-DlgLabel "IP-adres"               20  56
    $txtIP   = New-DlgInput $curIP                   20  78  $dlgInputW   # 56+14(lbl)+8pad = 78; einde 104
    $lblMask = New-DlgLabel "Subnetmasker"            20 120               # 104+16gap = 120
    $txtMask = New-DlgInput "$curMask"               20 142  $dlgInputW   # einde 168
    $lblGW   = New-DlgLabel "Gateway"                20 184               # 168+16 = 184
    $txtGW   = New-DlgInput $curGW                   20 206  $dlgInputW   # einde 232
    $lblD1   = New-DlgLabel "DNS 1"                  20 248               # 232+16 = 248
    $txtDNS1 = New-DlgInput $curDNS1                 20 270  $dlgInputW   # einde 296
    $lblD2   = New-DlgLabel "DNS 2  (optioneel)"     20 312               # 296+16 = 312
    $txtDNS2 = New-DlgInput $curDNS2                 20 334  $dlgInputW   # einde 360

    $staticControls = @($lblIP,$txtIP,$lblMask,$txtMask,$lblGW,$txtGW,$lblD1,$txtDNS1,$lblD2,$txtDNS2)
    foreach ($c in $staticControls) { $c.Enabled = -not $isDHCP }

    $radioDHCP.Add_CheckedChanged({
        param($s,$ev)
        $en = -not $s.Checked
        foreach ($c in $staticControls) { $c.Enabled = $en }
    }.GetNewClosure())

    # Knoppen
    $btnApply = New-Object System.Windows.Forms.Button
    $btnApply.Text = "Toepassen"; $btnApply.Font = $fontDlg
    $btnApply.ForeColor = $white; $btnApply.BackColor = $orange
    $btnApply.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnApply.FlatAppearance.BorderSize = 0
    $btnApply.Location = New-Object System.Drawing.Point(20, 378)
    $btnApply.Size = New-Object System.Drawing.Size(130, 32)
    $btnApply.Cursor = [System.Windows.Forms.Cursors]::Hand

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Annuleren"; $btnCancel.Font = $fontDlg
    $btnCancel.ForeColor = $white; $btnCancel.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1a1a1a")
    $btnCancel.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnCancel.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml("#333333")
    $btnCancel.Location = New-Object System.Drawing.Point(165, 378)
    $btnCancel.Size = New-Object System.Drawing.Size(130, 32)
    $btnCancel.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnCancel.Add_Click({ $dlg.Close() }.GetNewClosure())

    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Font = $fontLbl; $lblStatus.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#555555")
    $lblStatus.BackColor = $darkbg; $lblStatus.Location = New-Object System.Drawing.Point(20, 422)
    $lblStatus.Size = New-Object System.Drawing.Size(410, 32); $lblStatus.Text = "Adapter: $adapterName"

    $btnApply.Add_Click({
        if ($radioDHCP.Checked) {
            Start-Process "cmd.exe" -ArgumentList "/c netsh interface ip set address name=`"$adapterName`" source=dhcp" -WindowStyle Hidden -Wait
            Start-Process "cmd.exe" -ArgumentList "/c netsh interface ip set dns name=`"$adapterName`" source=dhcp" -WindowStyle Hidden -Wait
            $lblStatus.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#44cc66")
            $lblStatus.Text = "DHCP ingesteld op $adapterName"
            Set-Log "DHCP ingesteld op $adapterName."
        } else {
            $ip   = $txtIP.Text.Trim()
            $mask = $txtMask.Text.Trim()
            $gw   = $txtGW.Text.Trim()
            $dns1 = $txtDNS1.Text.Trim()
            $dns2 = $txtDNS2.Text.Trim()

            if (-not $ip -or -not $mask -or -not $gw) {
                $lblStatus.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#ff3333")
                $lblStatus.Text = "IP, subnetmasker en gateway zijn verplicht."
                return
            }

            Start-Process "netsh" -ArgumentList "interface ip set address name=`"$adapterName`" static $ip $mask $gw" -WindowStyle Hidden -Wait
            if ($dns1) {
                Start-Process "netsh" -ArgumentList "interface ip set dns name=`"$adapterName`" static $dns1 primary" -WindowStyle Hidden -Wait
                if ($dns2) {
                    Start-Process "netsh" -ArgumentList "interface ip add dns name=`"$adapterName`" $dns2 index=2" -WindowStyle Hidden -Wait
                }
            }
            $lblStatus.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#44cc66")
            $lblStatus.Text = "Statisch IP ingesteld: $ip"
            Set-Log "IP ingesteld: $ip op $adapterName."
        }
    }.GetNewClosure())

    $dlg.Controls.AddRange(@(
        $radioDHCP, $radioStatic, $divDlg,
        $lblIP, $txtIP, $lblMask, $txtMask, $lblGW, $txtGW,
        $lblD1, $txtDNS1, $lblD2, $txtDNS2,
        $btnApply, $btnCancel, $lblStatus
    ))
    $dlg.ShowDialog() | Out-Null
})

$form.Add_FormClosing({
    $script:timer.Stop()
})

[System.Windows.Forms.Application]::Run($form)
