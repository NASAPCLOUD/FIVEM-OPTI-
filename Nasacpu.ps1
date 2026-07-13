# ====================================================================
#                        ADVANCED OPTIMIZATION
#                            created by nasa
# ====================================================================

# Hide background console
$User32 = Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);' -Name "Win32ShowWindow" -Namespace Win32Functions -PassThru
$PowerShellHandle = (Get-Process -Id $PID).MainWindowHandle
if ($PowerShellHandle -ne [IntPtr]::Zero) {
    [Win32Functions.Win32ShowWindow]::ShowWindow($PowerShellHandle, 0)
}

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

# --- UNIFIED INTERFACE INITIALIZATION (PREMIUM EDGELESS) ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "EXM Premium Utility Concept - Engineered by Nasa"
$Form.Size = New-Object System.Drawing.Size(840, 540)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [System.Drawing.Color]::FromArgb(6, 7, 9) # True Deep Obsidian Black
$Form.FormBorderStyle = "FixedSingle"
$Form.MaximizeBox = $false

# Custom EXM Typography Kit
$TitleFont   = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$HeaderFont  = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$LabelFont   = New-Object System.Drawing.Font("Segoe UI Semibold", 9, [System.Drawing.FontStyle]::Regular)
$ValueFont   = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Regular)
$ButtonFont  = New-Object System.Drawing.Font("Segoe UI Semibold", 9, [System.Drawing.FontStyle]::Bold)

# Color Scheme
$ExmGreen    = [System.Drawing.Color]::FromArgb(46, 204, 113) # Electric Cyber Green
$ExmWhite    = [System.Drawing.Color]::FromArgb(255, 255, 255)
$ExmDimText  = [System.Drawing.Color]::FromArgb(110, 118, 130)
$ExmLine     = [System.Drawing.Color]::FromArgb(25, 28, 36)    # Dark Divider Frame Color

# Top Visual Edge Border Glow
$AccentBar = New-Object System.Windows.Forms.Panel
$AccentBar.Size = New-Object System.Drawing.Size(840, 4)
$AccentBar.Location = New-Object System.Drawing.Point(0, 0)
$AccentBar.BackColor = $ExmGreen
$Form.Controls.Add($AccentBar)

# --- VISUAL ELEMENT: HYPER-THIN VERTICAL DIVIDER LINE ---
$CenterDivider = New-Object System.Windows.Forms.Panel
$CenterDivider.Size = New-Object System.Drawing.Size(1, 460)
$CenterDivider.Location = New-Object System.Drawing.Point(280, 25)
$CenterDivider.BackColor = $ExmLine
$Form.Controls.Add($CenterDivider)

# --- SIDE SECTION: ARCHITECTURE INFO PANEL (UNBOXED) ---
$SideHeader = New-Object System.Windows.Forms.Label
$SideHeader.Text = "SYSTEM ARCHITECTURE"
$SideHeader.Size = New-Object System.Drawing.Size(240, 25)
$SideHeader.Location = New-Object System.Drawing.Point(25, 30)
$SideHeader.ForeColor = $ExmGreen
$SideHeader.Font = $HeaderFont
$Form.Controls.Add($SideHeader)

function Add-UnboxedRow ($Title, $Value, $TopPosition) {
    $TitleLbl = New-Object System.Windows.Forms.Label
    $TitleLbl.Text = $Title
    $TitleLbl.Size = New-Object System.Drawing.Size(240, 18)
    $TitleLbl.Location = New-Object System.Drawing.Point(25, $TopPosition)
    $TitleLbl.ForeColor = $ExmDimText
    $TitleLbl.Font = $LabelFont

    $ValueLbl = New-Object System.Windows.Forms.Label
    $ValueLbl.Text = $Value
    $ValueLbl.Size = New-Object System.Drawing.Size(240, 35)
    $ValueLbl.Location = New-Object System.Drawing.Point(25, ($TopPosition + 18))
    $ValueLbl.ForeColor = $ExmWhite
    $ValueLbl.Font = $ValueFont

    $Form.Controls.AddRange(@($TitleLbl, $ValueLbl))
}

Add-UnboxedRow "HOST PROCESSOR" $Cpu 70
Add-UnboxedRow "DISPLAY RASTERIZER" $Gpu 135
Add-UnboxedRow "PRIMARY DRIVE (C:)" "$DriveTypeStr Subsystem`n$DriveFreeGB GB Free / $DriveSizeGB GB Total" 200

# Diagnostic Segment
$RecHeader = New-Object System.Windows.Forms.Label
$RecHeader.Text = "DIAGNOSTIC MATRIX"
$RecHeader.Size = New-Object System.Drawing.Size(240, 25)
$RecHeader.Location = New-Object System.Drawing.Point(25, 290)
$RecHeader.ForeColor = $ExmGreen
$RecHeader.Font = $HeaderFont

$RecBox = New-Object System.Windows.Forms.Label
$RecBox.Text = $RecText
$RecBox.Size = New-Object System.Drawing.Size(240, 160)
$RecBox.Location = New-Object System.Drawing.Point(25, 315)
$RecBox.ForeColor = $ExmWhite
$RecBox.Font = $LabelFont
$Form.Controls.AddRange(@($RecHeader, $RecBox))


# --- MAIN SECTION: INTERFACE ACTIONS MATRIX (UNBOXED) ---
$MainHeader = New-Object System.Windows.Forms.Label
$MainHeader.Text = "EXM PREMIUM COMPATIBLE UTILITY MATRIX"
$MainHeader.Size = New-Object System.Drawing.Size(500, 25)
$MainHeader.Location = New-Object System.Drawing.Point(305, 30)
$MainHeader.ForeColor = $ExmWhite
$MainHeader.Font = $TitleFont
$Form.Controls.Add($MainHeader)

function Create-PremiumExmButton ($Text, $Top, $Action) {
    $Btn = New-Object System.Windows.Forms.Button
    $Btn.Text = "        $Text"
    $Btn.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $Btn.Size = New-Object System.Drawing.Size(495, 44)
    $Btn.Location = New-Object System.Drawing.Point(305, $Top)
    $Btn.BackColor = [System.Drawing.Color]::FromArgb(14, 16, 20) # Sleek Dark Button Body
    $Btn.ForeColor = $ExmWhite
    $Btn.FlatStyle = "Flat"
    $Btn.FlatAppearance.BorderSize = 1
    $Btn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(32, 37, 48)
    $Btn.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(24, 28, 36)
    $Btn.Font = $ButtonFont
    $Btn.Add_Click($Action)
    
    # Left Dashboard structural color toggle
    $Strip = New-Object System.Windows.Forms.Panel
    $Strip.Size = New-Object System.Drawing.Size(5, 44)
    $Strip.Location = New-Object System.Drawing.Point(0, 0)
    $Strip.BackColor = $script:ExmGreen
    $Btn.Controls.Add($Strip)
    
    return $Btn
}

# --- PIPELINE SCRIPTS ---
$ActionRestore = {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue 
    Checkpoint-Computer -Description "Before Nasa EXM Optimization" -RestorePointType MODIFY_SETTINGS -ErrorAction SilentlyContinue
}

$ActionCache = {
    $AppData = [System.Environment]::GetFolderPath('LocalApplicationData')
    $FiveMCache = "$AppData\FiveM\FiveM.app\data"
    if (Test-Path $FiveMCache) { Remove-Item -Path "$FiveMCache\cache" -Recurse -Force -ErrorAction SilentlyContinue }
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
}

$ActionStandard = {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -ErrorAction SilentlyContinue
}

$ActionInput = {
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Value "1" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -ErrorAction SilentlyContinue
}

$ActionAmd = {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" -Name "PowerThrottlingOff" -Value 1 -ErrorAction SilentlyContinue
    powercfg /setacvalueindex scheme_current sub_processor cppmflags 0 2>$null
}

$ActionNetwork = {
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

# --- ATTACH PREMIUM ACTION BUTTON MATRIX ---
$Btn1 = Create-PremiumExmButton "System Backup: Create Restore Point"       75  $ActionRestore
$Btn2 = Create-PremiumExmButton "Engine Base: Universal Performance Suite" 135 $ActionUniversal
$Btn3 = Create-PremiumExmButton "Input Delay Matrix: Optimize Response"     195 $ActionInput
$Btn4 = Create-PremiumExmButton "Network Node: Flush DNS & Lower Packet Lag"  255 $ActionNetwork
$Btn5 = Create-PremiumExmButton "Hardware Filter: Heavy AMD Architecture"   315 $ActionAmd
$Btn6 = Create-PremiumExmButton "Maintenance Mode: Flush Temporary Cache"    375 $ActionCache

$Form.Controls.AddRange(@($Btn1, $Btn2, $Btn3, $Btn4, $Btn5, $Btn6))

# Execute Frame Render
[System.Windows.Forms.Application]::Run($Form)
