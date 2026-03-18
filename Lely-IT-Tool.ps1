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

$FontMain  = New-Object System.Drawing.Font("Segoe UI", 9)
$FontSmall = New-Object System.Drawing.Font("Segoe UI", 7)
$FontTitle = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$FontSect  = New-Object System.Drawing.Font("Segoe UI", 7, [System.Drawing.FontStyle]::Bold)

function Set-Log($msg) {
    $script:lblLog.Text = $msg
    $script:form.Refresh()
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

        $fMain  = New-Object System.Drawing.Font("Segoe UI", 9)
        $fSub   = New-Object System.Drawing.Font("Segoe UI", 7)
        $bMain  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
        $bSub   = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#aaaaaa"))

        $g.DrawString($main, $fMain, $bMain, 12, 9)
        $g.DrawString($sub,  $fSub,  $bSub,  13, 28)

        $fMain.Dispose(); $fSub.Dispose()
        $bMain.Dispose(); $bSub.Dispose()
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
    $l.Size      = New-Object System.Drawing.Size(560, 16)
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
$form.Size            = New-Object System.Drawing.Size(622, 430)
$form.MinimumSize     = $form.Size
$form.MaximumSize     = $form.Size
$form.BackColor       = $BG
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox     = $false
$form.StartPosition   = [System.Windows.Forms.FormStartPosition]::CenterScreen

# Header panel
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Location  = New-Object System.Drawing.Point(0, 0)
$pnlHeader.Size      = New-Object System.Drawing.Size(622, 68)
$pnlHeader.BackColor = $PANEL
$pnlHeader.Add_Paint({
    param($s,$e)
    $pen = New-Object System.Drawing.Pen($ORANGE, 3)
    $e.Graphics.DrawLine($pen, 0, 65, $s.Width, 65)
    $pen.Dispose()
})

# Lely oval logo - nauwkeurige GDI+ nabootsing
$picCow = New-Object System.Windows.Forms.PictureBox
$picCow.Location  = New-Object System.Drawing.Point(8, 4)
$picCow.Size      = New-Object System.Drawing.Size(76, 60)
$picCow.BackColor = $PANEL
$picCow.Add_Paint({
    param($s,$e)
    $g = $e.Graphics
    $g.SmoothingMode    = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

    # Zwarte buitenste ellips (achtergrond schaduw effect)
    $brushBlack = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    $g.FillEllipse($brushBlack, 0, 0, 76, 58)

    # Dikke witte rand-ellips
    $brushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillEllipse($brushWhite, 2, 2, 72, 54)

    # Dunne rode ring (binnenrand)
    $brushRed = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#CC0000"))
    $g.FillEllipse($brushRed, 6, 5, 64, 48)

    # Tweede witte dunne ring
    $brushWhite2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillEllipse($brushWhite2, 8, 7, 60, 44)

    # Rode kern
    $brushRed2 = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#CC0000"))
    $g.FillEllipse($brushRed2, 10, 9, 56, 40)

    # LELY letters met trapezium-perspectief via GraphicsPath
    # Elke letter heeft een smalle bovenkant en brede onderkant (karakteristiek Lely font)
    $brushW = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)

    # Letter L  (x=11, breed=9)
    $pathL = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pathL.AddPolygon([System.Drawing.PointF[]](
        [System.Drawing.PointF]::new(11,  12),   # links boven
        [System.Drawing.PointF]::new(15,  12),   # rechts boven
        [System.Drawing.PointF]::new(16,  45),   # rechts onder (schacht)
        [System.Drawing.PointF]::new(22,  45),   # voet rechts
        [System.Drawing.PointF]::new(22,  49),   # voet rechts onder
        [System.Drawing.PointF]::new(10,  49),   # voet links onder
        [System.Drawing.PointF]::new(10,  12)    # links boven (sluit)
    ))
    $g.FillPath($brushW, $pathL)

    # Letter E  (x=23)
    $pathE = New-Object System.Drawing.Drawing2D.GraphicsPath
    # Schacht
    $pathE.AddPolygon([System.Drawing.PointF[]](
        [System.Drawing.PointF]::new(23, 12),
        [System.Drawing.PointF]::new(27, 12),
        [System.Drawing.PointF]::new(28, 49),
        [System.Drawing.PointF]::new(23, 49)
    ))
    $g.FillPath($brushW, $pathE)
    # Balk boven
    $pathEt = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pathEt.AddPolygon([System.Drawing.PointF[]](
        [System.Drawing.PointF]::new(23, 12),
        [System.Drawing.PointF]::new(33, 12),
        [System.Drawing.PointF]::new(33, 16),
        [System.Drawing.PointF]::new(23, 16)
    ))
    $g.FillPath($brushW, $pathEt)
    # Middenbalk
    $pathEm = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pathEm.AddPolygon([System.Drawing.PointF[]](
        [System.Drawing.PointF]::new(24, 28),
        [System.Drawing.PointF]::new(32, 28),
        [System.Drawing.PointF]::new(32, 32),
        [System.Drawing.PointF]::new(24, 32)
    ))
    $g.FillPath($brushW, $pathEm)
    # Onderbalk
    $pathEb = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pathEb.AddPolygon([System.Drawing.PointF[]](
        [System.Drawing.PointF]::new(23, 45),
        [System.Drawing.PointF]::new(34, 45),
        [System.Drawing.PointF]::new(34, 49),
        [System.Drawing.PointF]::new(23, 49)
    ))
    $g.FillPath($brushW, $pathEb)

    # Letter L2  (x=36)
    $pathL2 = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pathL2.AddPolygon([System.Drawing.PointF[]](
        [System.Drawing.PointF]::new(36, 12),
        [System.Drawing.PointF]::new(40, 12),
        [System.Drawing.PointF]::new(41, 45),
        [System.Drawing.PointF]::new(47, 45),
        [System.Drawing.PointF]::new(47, 49),
        [System.Drawing.PointF]::new(35, 49),
        [System.Drawing.PointF]::new(35, 12)
    ))
    $g.FillPath($brushW, $pathL2)

    # Letter Y  (x=49)
    $pathYl = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pathYl.AddPolygon([System.Drawing.PointF[]](
        [System.Drawing.PointF]::new(49, 12),
        [System.Drawing.PointF]::new(53, 12),
        [System.Drawing.PointF]::new(55, 30),
        [System.Drawing.PointF]::new(51, 30)
    ))
    $g.FillPath($brushW, $pathYl)
    $pathYr = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pathYr.AddPolygon([System.Drawing.PointF[]](
        [System.Drawing.PointF]::new(59, 12),
        [System.Drawing.PointF]::new(64, 12),
        [System.Drawing.PointF]::new(57, 30),
        [System.Drawing.PointF]::new(53, 30)
    ))
    $g.FillPath($brushW, $pathYr)
    $pathYs = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pathYs.AddPolygon([System.Drawing.PointF[]](
        [System.Drawing.PointF]::new(52, 30),
        [System.Drawing.PointF]::new(56, 30),
        [System.Drawing.PointF]::new(57, 49),
        [System.Drawing.PointF]::new(52, 49)
    ))
    $g.FillPath($brushW, $pathYs)

    $brushBlack.Dispose(); $brushWhite.Dispose(); $brushRed.Dispose()
    $brushWhite2.Dispose(); $brushRed2.Dispose(); $brushW.Dispose()
    $pathL.Dispose(); $pathE.Dispose(); $pathEt.Dispose(); $pathEm.Dispose()
    $pathEb.Dispose(); $pathL2.Dispose(); $pathYl.Dispose(); $pathYr.Dispose(); $pathYs.Dispose()
})

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text      = "LELY IT TOOL"
$lblTitle.Font      = $FontTitle
$lblTitle.ForeColor = $WHITE
$lblTitle.BackColor = $PANEL
$lblTitle.Location  = New-Object System.Drawing.Point(92, 10)
$lblTitle.AutoSize  = $true

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text      = "IT Toolbox  -  Field Engineer Utility"
$lblSub.Font      = $FontSmall
$lblSub.ForeColor = $GRAY
$lblSub.BackColor = $PANEL
$lblSub.Location  = New-Object System.Drawing.Point(93, 38)
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
$Y = 80

Add-SectLabel "RECHTEN & TOEGANG" $Y
$Y += 20

$btnRunAs     = New-FlatBtn "Run as Admin"     "Herstart tool met verhoogde rechten"    20  $Y 278 46
$btnMakeAdmin = New-FlatBtn "Make Me Admin"    "Voeg toe aan lokale Administrators"     302 $Y 278 46
$form.Controls.AddRange(@($btnRunAs, $btnMakeAdmin))
$Y += 54

Add-Divider $Y; $Y += 10

Add-SectLabel "WINDOWS FIREWALL" $Y
$Y += 20

$btnFwOff = New-FlatBtn "Firewall UIT" "Max 30 minuten, daarna automatisch aan" 20  $Y 278 46
$btnFwOn  = New-FlatBtn "Firewall AAN" "Zet firewall handmatig terug aan"        302 $Y 278 46
$form.Controls.AddRange(@($btnFwOff, $btnFwOn))
$Y += 54

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

$btnNetwork  = New-FlatBtn "Netwerk overzicht"      "Open Windows netwerkinstellingen"        20  $Y 278 46
$btnEthernet = New-FlatBtn "Ethernet / IP & DNS"   "Direct naar IP-adres en DNS instellingen" 302 $Y 278 46
$form.Controls.AddRange(@($btnNetwork, $btnEthernet))

# Footer
$pnlFooter = New-Object System.Windows.Forms.Panel
$pnlFooter.Location  = New-Object System.Drawing.Point(0, 385)
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
        $cmd = "Remove-NetFirewallRule -DisplayName 'LELY-ALLOW-ALL-IN'  -ErrorAction SilentlyContinue; Remove-NetFirewallRule -DisplayName 'LELY-ALLOW-ALL-OUT' -ErrorAction SilentlyContinue"
        Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$cmd`"" -Verb RunAs -WindowStyle Hidden -Wait
        $script:pnlTimer.Visible = $false
        $script:fwSecondsLeft = 0
        Set-Log "Allow-all regels automatisch verwijderd."
    }
})
$timer.Start()

# Button events
$btnRunAs.Add_Click({
    $script = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.ScriptName }
    Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$script`"" -Verb RunAs
    Set-Log "Elevated versie gestart."
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
        Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$script`"" -Verb RunAs
        Set-Log "Elevated versie gestart voor firewall."
        return
    }
    try {
        $cmd = @"
New-NetFirewallRule -DisplayName 'LELY-ALLOW-ALL-IN'  -Direction Inbound  -Action Allow -Protocol Any -Profile Any -ErrorAction SilentlyContinue | Out-Null
New-NetFirewallRule -DisplayName 'LELY-ALLOW-ALL-OUT' -Direction Outbound -Action Allow -Protocol Any -Profile Any -ErrorAction SilentlyContinue | Out-Null
"@
        Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$cmd`"" -Verb RunAs -WindowStyle Hidden -Wait
        $script:fwSecondsLeft = 1800
        $script:pnlTimer.Visible = $true
        Set-Log "Allow-all regels toegevoegd. Timer: 30 min."
    } catch {
        Set-Log "Fout: $_"
    }
})

$btnFwOn.Add_Click({
    try {
        $cmd = "Remove-NetFirewallRule -DisplayName 'LELY-ALLOW-ALL-IN'  -ErrorAction SilentlyContinue; Remove-NetFirewallRule -DisplayName 'LELY-ALLOW-ALL-OUT' -ErrorAction SilentlyContinue"
        Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$cmd`"" -Verb RunAs -WindowStyle Hidden -Wait
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
                $fN = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
                $fD = New-Object System.Drawing.Font("Segoe UI", 7)
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
    $dlg.Size            = New-Object System.Drawing.Size(400, 420)
    $dlg.MinimumSize     = $dlg.Size
    $dlg.MaximumSize     = $dlg.Size
    $dlg.BackColor       = [System.Drawing.ColorTranslator]::FromHtml("#0d0d0d")
    $dlg.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $dlg.MaximizeBox     = $false
    $dlg.MinimizeBox     = $false
    $dlg.StartPosition   = [System.Windows.Forms.FormStartPosition]::CenterParent

    $fontDlg  = New-Object System.Drawing.Font("Segoe UI", 9)
    $fontLbl  = New-Object System.Drawing.Font("Segoe UI", 8)
    $orange   = [System.Drawing.ColorTranslator]::FromHtml("#CC0000")
    $white    = [System.Drawing.Color]::White
    $darkbg   = [System.Drawing.ColorTranslator]::FromHtml("#0d0d0d")
    $inputbg  = [System.Drawing.ColorTranslator]::FromHtml("#1a1a1a")

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
        $t.Size = New-Object System.Drawing.Size($w, 22)
        return $t
    }

    # DHCP / Statisch toggle
    $radioDHCP   = New-Object System.Windows.Forms.RadioButton
    $radioDHCP.Text = "DHCP"; $radioDHCP.Font = $fontDlg
    $radioDHCP.ForeColor = $white; $radioDHCP.BackColor = $darkbg
    $radioDHCP.Location = New-Object System.Drawing.Point(20, 16)
    $radioDHCP.AutoSize = $true
    $radioDHCP.Checked = $isDHCP

    $radioStatic = New-Object System.Windows.Forms.RadioButton
    $radioStatic.Text = "Statisch"; $radioStatic.Font = $fontDlg
    $radioStatic.ForeColor = $white; $radioStatic.BackColor = $darkbg
    $radioStatic.Location = New-Object System.Drawing.Point(110, 16)
    $radioStatic.AutoSize = $true
    $radioStatic.Checked = -not $isDHCP

    # Invoervelden
    $lblIP   = New-DlgLabel "IP-adres"      20  60
    $txtIP   = New-DlgInput $curIP          20  76  200
    $lblMask = New-DlgLabel "Subnetmasker (bijv. 255.255.255.0)" 20 108
    $txtMask = New-DlgInput "$curMask"      20  124 200
    $lblGW   = New-DlgLabel "Gateway"       20  156
    $txtGW   = New-DlgInput $curGW          20  172 200
    $lblD1   = New-DlgLabel "DNS 1"         20  204
    $txtDNS1 = New-DlgInput $curDNS1        20  220 200
    $lblD2   = New-DlgLabel "DNS 2"         20  252
    $txtDNS2 = New-DlgInput $curDNS2        20  268 200

    $staticControls = @($lblIP,$txtIP,$lblMask,$txtMask,$lblGW,$txtGW,$lblD1,$txtDNS1,$lblD2,$txtDNS2)
    foreach ($c in $staticControls) { $c.Enabled = -not $isDHCP }

    $radioDHCP.Add_CheckedChanged({
        $en = -not $radioDHCP.Checked
        foreach ($c in $staticControls) { $c.Enabled = $en }
    })

    # Knoppen
    $btnApply = New-Object System.Windows.Forms.Button
    $btnApply.Text = "Toepassen"; $btnApply.Font = $fontDlg
    $btnApply.ForeColor = $white; $btnApply.BackColor = $orange
    $btnApply.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnApply.FlatAppearance.BorderSize = 0
    $btnApply.Location = New-Object System.Drawing.Point(20, 310)
    $btnApply.Size = New-Object System.Drawing.Size(110, 30)
    $btnApply.Cursor = [System.Windows.Forms.Cursors]::Hand

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Annuleren"; $btnCancel.Font = $fontDlg
    $btnCancel.ForeColor = $white; $btnCancel.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1a1a1a")
    $btnCancel.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnCancel.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml("#333333")
    $btnCancel.Location = New-Object System.Drawing.Point(145, 310)
    $btnCancel.Size = New-Object System.Drawing.Size(110, 30)
    $btnCancel.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnCancel.Add_Click({ $dlg.Close() })

    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Font = $fontLbl; $lblStatus.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#555555")
    $lblStatus.BackColor = $darkbg; $lblStatus.Location = New-Object System.Drawing.Point(20, 350)
    $lblStatus.Size = New-Object System.Drawing.Size(355, 30); $lblStatus.Text = "Adapter: $adapterName"

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
    })

    $dlg.Controls.AddRange(@(
        $radioDHCP, $radioStatic,
        $lblIP, $txtIP, $lblMask, $txtMask, $lblGW, $txtGW,
        $lblD1, $txtDNS1, $lblD2, $txtDNS2,
        $btnApply, $btnCancel, $lblStatus
    ))
    $dlg.ShowDialog() | Out-Null
})

[System.Windows.Forms.Application]::Run($form)
