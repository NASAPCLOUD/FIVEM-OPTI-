# ====================================================================
#                        ADVANCED OPTIMIZATION
#                            created by nasa
# ====================================================================

# Hide the background console window immediately for a native app feel
$User32 = Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);' -Name "Win32ShowWindow" -Namespace Win32Functions -PassThru
$PowerShellHandle = (Get-Process -Id $PID).MainWindowHandle
if ($PowerShellHandle -ne [IntPtr]::Zero) {
    [Win32Functions.Win32ShowWindow]::ShowWindow($PowerShellHandle, 0)
}

# Load the core GUI engine assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- GATHER HARDWARE SPECIFICATIONS ---
$Cpu = (Get-CimInstance Win32_Processor).Name.Trim()
$Gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name.Trim()
$OsDrive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$DriveTypeStr = "Unknown"
$DiskDrive = Get-CimInstance Win32_DiskDrive | Where-Object { $_.DeviceID -match (Get-CimInstance Win32_DiskPartition | Where-Object { $_.BootPartition -eq $true } | Select-Object -First 1).DiskIndex }
if ($DiskDrive) {
    $PhysicalDrive = Get-PhysicalDisk -DeviceNumber $DiskDrive.Index -ErrorAction SilentlyContinue
    if ($PhysicalDrive) { $DriveTypeStr = $PhysicalDrive.MediaType }
}
$DriveSizeGB = [math]::Round($OsDrive.Size / 1GB)
$DriveFreeGB = [math]::Round($OsDrive.FreeSpace / 1GB)

# --- DETERMINE DYNAMIC HARDWARE RECOMMENDATIONS ---
$IsAmdCpu = $Cpu -match "AMD"
$IsAmdGpu = $Gpu -match "AMD" -or $Gpu -match "Radeon"

$RecText = "RECOMMENDED PIPELINE:`r`n`r`n[1] Create Baseline Restore Point`r`n[2] Run Core Engine Optimization`r`n"
if ($IsAmdCpu -or $IsAmdGpu) {
    $RecText += "[3] Execute AMD Engine Matrix`r`n"
    $RecText += "[4] Deploy Keyboard/Mouse Input Tweaks"
} else {
    $RecText += "[3] Deploy Keyboard/Mouse Input Tweaks`r`n"
    $RecText += "[4] SKIP AMD Module (Intel/NVIDIA profile)"
}

# --- MAIN FORM INITIALIZATION (EXM CORE THEME) ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "EXM Utility Concept - Engineered by Nasa"
$Form.Size = New-Object System.Drawing.Size(840, 540)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [System.Drawing.Color]::FromArgb(10, 12, 14) # Slate Black
$Form.FormBorderStyle = "FixedSingle"
$Form.MaximizeBox = $false

# EXM Typography Kit
$TitleFont   = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$HeaderFont  = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$LabelFont   = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$ValueFont   = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Regular)
$ButtonFont  = New-Object System.Drawing.Font("Segoe UI Semibold", 9, [System.Drawing.FontStyle]::Bold)

# EXM Color Palette Definitions
$ExmGreen  = [System.Drawing.Color]::FromArgb(46, 204, 113) # High-visibility Cyber Green
$ExmWhite  = [System.Drawing.Color]::FromArgb(255, 255, 255)
$ExmDimText = [System.Drawing.Color]::FromArgb(150, 155, 165)
$TileBg    = [System.Drawing.Color]::FromArgb(18, 22, 26)

# --- VISUAL ELEMENT: TOP DESIGN ACCENT LINE ---
$AccentBar = New-Object System.Windows.Forms.Panel
$AccentBar.Size = New-Object System.Drawing.Size(840, 4)
$AccentBar.Location = New-Object System.Drawing.Point(0, 0)
$AccentBar.BackColor = $ExmGreen

# --- SIDE PANEL: HARDWARE OVERVIEW ---
$SidePanel = New-Object System.Windows.Forms.Panel
$SidePanel.Size = New-Object System.Drawing.Size(265, 460)
$SidePanel.Location = New-Object System.Drawing.Point(15, 20)
$SidePanel.BackColor = $TileBg

$SideHeader = New-Object System.Windows.Forms.Label
$SideHeader.Text = "SYSTEM ARCHITECTURE"
$SideHeader.Size = New-Object System.Drawing.Size(245, 25)
$SideHeader.Location = New-Object System.Drawing.Point(15, 15)
$SideHeader.ForeColor = $ExmGreen
$SideHeader.Font = $HeaderFont

function Add-HardwareRow ($Title, $Value, $TopPosition) {
    $TitleLbl = New-Object System.Windows.Forms.Label
    $TitleLbl.Text = $Title
    $TitleLbl.Size = New-Object System.Drawing.Size(235, 18)
    $TitleLbl.Location = New-Object System.Drawing.Point(15, $TopPosition)
    $TitleLbl.ForeColor = $ExmDimText
    $TitleLbl.Font = $LabelFont

    $ValueLbl = New-Object System.Windows.Forms.Label
    $ValueLbl.Text = $Value
    $ValueLbl.Size = New-Object System.Drawing.Size(235, 32)
    $ValueLbl.Location = New-Object System.Drawing.Point(15, ($TopPosition + 18))
    $ValueLbl.ForeColor = $ExmWhite
    $ValueLbl.Font = $ValueFont

    $SidePanel.Controls.AddRange(@($TitleLbl, $ValueLbl))
}

Add-HardwareRow "HOST PROCESSOR" $Cpu 55
Add-HardwareRow "DISPLAY RASTERIZER" $Gpu 115
Add-HardwareRow "PRIMARY DRIVE (C:)" "$DriveTypeStr Subsystem`n$DriveFreeGB GB Free / $DriveSizeGB GB Total" 175

# --- SYSTEM RECOMMENDATIONS PANEL ---
$RecHeader = New-Object System.Windows.Forms.Label
$RecHeader.Text = "INTELLIGENT DIAGNOSTIC"
$RecHeader.Size = New-Object System.Drawing.Size(235, 18)
$RecHeader.Location = New-Object System.Drawing.Point(15, 265)
$RecHeader.ForeColor = $ExmGreen
$RecHeader.Font = $HeaderFont

$RecBox = New-Object System.Windows.Forms.Label
$RecBox.Text = $RecText
$RecBox.Size = New-Object System.Drawing.Size(235, 160)
$RecBox.Location = New-Object System.Drawing.Point(15, 290)
$RecBox.ForeColor = $ExmWhite
$RecBox.Font = $LabelFont

$SidePanel.Controls.AddRange(@($SideHeader, $RecHeader, $RecBox))

# --- MAIN PANEL: EXM ACTIONS ENGINE ---
$MainPanel = New-Object System.Windows.Forms.Panel
$MainPanel.Size = New-Object System.Drawing.Size(520, 460)
$MainPanel.Location = New-Object System.Drawing.Point(295, 20)
$MainPanel.BackColor = $TileBg

$MainHeader = New-Object System.Windows.Forms.Label
$MainHeader.Text = "EXM COMPATIBLE OPTIMIZER MATRIX"
$MainHeader.Size = New-Object System.Drawing.Size(490, 25)
$MainHeader.Location = New-Object System.Drawing.Point(15, 15)
$MainHeader.ForeColor = $ExmWhite
$MainHeader.Font = $TitleFont

function Create-ExmButton ($Text, $Top, $Action) {
    $Btn = New-Object System.Windows.Forms.Button
    $Btn.Text = "      $Text"
    $Btn.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $Btn.Size = New-Object System.Drawing.Size(490, 42)
    $Btn.Location = New-Object System.Drawing.Point(15, $Top)
    $Btn.BackColor = [System.Drawing.Color]::FromArgb(26, 32, 38)
    $Btn.ForeColor = $ExmWhite
    $Btn.FlatStyle = "Flat"
    $Btn.FlatAppearance.BorderSize = 1
    $Btn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(45, 55, 65)
    $Btn.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(35, 45, 55)
    $Btn.Font = $ButtonFont
    $Btn.Add_Click($Action)
    
    # Left Border glow strip matching the iconic utility accent
    $Strip = New-Object System.Windows.Forms.Panel
    $Strip.Size = New-Object System.Drawing.Size(4, 42)
    $Strip.Location = New-Object System.Drawing.Point(0, 0)
    $Strip.BackColor = $script:ExmGreen
    $Btn.Controls.Add($Strip)
    
    return $Btn
}

# --- EXM COMPATIBLE ACTION UTILITIES ---
$ActionRestore = {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue 
    Checkpoint-Computer -Description "Before Nasa EXM Optimization" -RestorePointType MODIFY_SETTINGS -ErrorAction SilentlyContinue
}

$ActionCache = {
    $AppData = [System.Environment]::GetFolderPath('LocalApplicationData')
    $FiveMCache = "$AppData\FiveM\FiveM.app\data"
    if (Test-Path $FiveMCache) {
        Remove-Item -Path "$FiveMCache\cache" -Recurse -Force -ErrorAction SilentlyContinue
    }
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
}

$ActionStandard = {
    # System Profile Throttling overrides
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -ErrorAction SilentlyContinue
}

$ActionInput = {
    # Custom Keyboard Latency tweaks mapped closer to standard script behaviors
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value "1" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -ErrorAction SilentlyContinue
}

$ActionAmd = {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" -Name "PowerThrottlingOff" -Value 1 -ErrorAction SilentlyContinue
    powercfg /setacvalueindex scheme_current sub_processor cppmflags 0 2>$null
}

$ActionNetwork = {
    # Network Packet delivery configurations (TCP Delay overrides)
    Clear-DnsClientCache
    $InterfacesPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    Get-ChildItem -Path $InterfacesPath | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -ErrorAction SilentlyContinue
    }
}

$ActionUniversal = {
    & $ActionCache
    & $ActionStandard
    & $ActionNetwork
}

# --- BUILD BUTTON LAYOUT PANEL ---
$Btn1 = Create-ExmButton "System Backup: Create Restore Point"       60  $ActionRestore
$Btn2 = Create-ExmButton "Engine Base: Universal Performance Suit" 115 $ActionUniversal
$Btn3 = Create-ExmButton "Input Delay Matrix: Optimize Response"     170 $ActionInput
$Btn4 = Create-ExmButton "Network Node: Flush DNS & Lower Packet Lag"  225 $ActionNetwork
$Btn5 = Create-ExmButton "Hardware Filter: Heavy AMD Architecture"   280 $ActionAmd
$Btn6 = Create-ExmButton "Maintenance Mode: Flush Temporary Cache"    335 $ActionCache

$MainPanel.Controls.AddRange(@($MainHeader, $Btn1, $Btn2, $Btn3, $Btn4, $Btn5, $Btn6))

# --- ASSEMBLE WINDOW ELEMENTS ---
$Form.Controls.AddRange(@($AccentBar, $SidePanel, $MainPanel))

# Force App View Window Render Loop
[System.Windows.Forms.Application]::Run($Form)
