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

$RecText = "1. Always run 'System Restore Point' first.`r`n2. Run 'Universal Optimization'.`r`n"
if ($IsAmdCpu -or $IsAmdGpu) {
    $RecText += "3. Run 'Heavy AMD Specific Tweaks' (Detected AMD Hardware).`r`n"
    $RecText += "4. Run 'Gaming Registry Tweaks' for processing priority."
} else {
    $RecText += "3. Run 'Gaming Registry Tweaks'.`r`n"
    $RecText += "4. SKIP Heavy AMD Tweaks (Intel/NVIDIA environment detected)."
}

# --- MAIN FORM INITIALIZATION ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Advanced Optimization - Created by Nasa"
$Form.Size = New-Object System.Drawing.Size(820, 520) # Height expanded slightly to accommodate the recommendation text window cleanly
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [System.Drawing.Color]::FromArgb(10, 12, 16)
$Form.FormBorderStyle = "FixedSingle"
$Form.MaximizeBox = $false

# Font Kit
$TitleFont   = New-Object System.Drawing.Font("Segoe UI Semibold", 13, [System.Drawing.FontStyle]::Bold)
$HeaderFont  = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$LabelFont   = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$ValueFont   = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Regular)
$ButtonFont  = New-Object System.Drawing.Font("Segoe UI Semibold", 9, [System.Drawing.FontStyle]::Bold)

# --- VISUAL ELEMENT: TOP DESIGN ACCENT LINE ---
$AccentBar = New-Object System.Windows.Forms.Panel
$AccentBar.Size = New-Object System.Drawing.Size(820, 4)
$AccentBar.Location = New-Object System.Drawing.Point(0, 0)
$AccentBar.BackColor = [System.Drawing.Color]::FromArgb(0, 150, 255)

# --- SIDE PANEL: HARDWARE OVERVIEW ---
$SidePanel = New-Object System.Windows.Forms.Panel
$SidePanel.Size = New-Object System.Drawing.Size(265, 445)
$SidePanel.Location = New-Object System.Drawing.Point(15, 20)
$SidePanel.BackColor = [System.Drawing.Color]::FromArgb(18, 22, 32)

$SideHeader = New-Object System.Windows.Forms.Label
$SideHeader.Text = "SYSTEM CONFIG"
$SideHeader.Size = New-Object System.Drawing.Size(245, 25)
$SideHeader.Location = New-Object System.Drawing.Point(15, 15)
$SideHeader.ForeColor = [System.Drawing.Color]::FromArgb(0, 190, 255)
$SideHeader.Font = $HeaderFont

function Add-HardwareRow ($Title, $Value, $TopPosition) {
    $TitleLbl = New-Object System.Windows.Forms.Label
    $TitleLbl.Text = $Title
    $TitleLbl.Size = New-Object System.Drawing.Size(235, 18)
    $TitleLbl.Location = New-Object System.Drawing.Point(15, $TopPosition)
    $TitleLbl.ForeColor = [System.Drawing.Color]::FromArgb(140, 150, 170)
    $TitleLbl.Font = $LabelFont

    $ValueLbl = New-Object System.Windows.Forms.Label
    $ValueLbl.Text = $Value
    $ValueLbl.Size = New-Object System.Drawing.Size(235, 32)
    $ValueLbl.Location = New-Object System.Drawing.Point(15, ($TopPosition + 18))
    $ValueLbl.ForeColor = [System.Drawing.Color]::White
    $ValueLbl.Font = $ValueFont

    $SidePanel.Controls.AddRange(@($TitleLbl, $ValueLbl))
}

Add-HardwareRow "PROCESSOR CORE ARCHITECTURE" $Cpu 55
Add-HardwareRow "PRIMARY RASTERIZER GRAPHICS" $Gpu 115
Add-HardwareRow "SYSTEM DRIVE (C:) CAPACITY" "$DriveTypeStr Storage Subsystem`n$DriveFreeGB GB Free / $DriveSizeGB GB Total" 175

# --- AUTOMATED SPEC RECOMMENDATIONS DISPLAY PANEL ---
$RecHeader = New-Object System.Windows.Forms.Label
$RecHeader.Text = "RECOMMENDED FOR YOU"
$RecHeader.Size = New-Object System.Drawing.Size(235, 18)
$RecHeader.Location = New-Object System.Drawing.Point(15, 260)
$RecHeader.ForeColor = [System.Drawing.Color]::FromArgb(46, 204, 113) # Subtle Alert Green
$RecHeader.Font = $HeaderFont

$RecBox = New-Object System.Windows.Forms.Label
$RecBox.Text = $RecText
$RecBox.Size = New-Object System.Drawing.Size(235, 150)
$RecBox.Location = New-Object System.Drawing.Point(15, 285)
$RecBox.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 200)
$RecBox.Font = $LabelFont

$SidePanel.Controls.AddRange(@($SideHeader, $RecHeader, $RecBox))

# --- MAIN PANEL: ACTIONS & INTERFACE ---
$MainPanel = New-Object System.Windows.Forms.Panel
$MainPanel.Size = New-Object System.Drawing.Size(500, 445)
$MainPanel.Location = New-Object System.Drawing.Point(295, 20)
$MainPanel.BackColor = [System.Drawing.Color]::FromArgb(18, 22, 32)

$MainHeader = New-Object System.Windows.Forms.Label
$MainHeader.Text = "Advanced Performance Optimizer"
$MainHeader.Size = New-Object System.Drawing.Size(470, 25)
$MainHeader.Location = New-Object System.Drawing.Point(15, 15)
$MainHeader.ForeColor = [System.Drawing.Color]::White
$MainHeader.Font = $TitleFont

function Create-CustomButton ($Text, $Top, $AccentColor, $Action) {
    $Btn = New-Object System.Windows.Forms.Button
    $Btn.Text = "   $Text"
    $Btn.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $Btn.Size = New-Object System.Drawing.Size(470, 40)
    $Btn.Location = New-Object System.Drawing.Point(15, $Top)
    $Btn.BackColor = [System.Drawing.Color]::FromArgb(28, 34, 46)
    $Btn.ForeColor = [System.Drawing.Color]::FromArgb(230, 235, 245)
    $Btn.FlatStyle = "Flat"
    $Btn.FlatAppearance.BorderSize = 1
    $Btn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(45, 52, 70)
    $Btn.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(36, 44, 60)
    $Btn.Font = $ButtonFont
    $Btn.Add_Click($Action)
    
    $Strip = New-Object System.Windows.Forms.Panel
    $Strip.Size = New-Object System.Drawing.Size(4, 40)
    $Strip.Location = New-Object System.Drawing.Point(0, 0)
    $Strip.BackColor = $AccentColor
    $Btn.Controls.Add($Strip)
    
    return $Btn
}

# --- SYSTEM ACTION SCRIPTS ---
$ActionRestore = {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue 
    Checkpoint-Computer -Description "Before Nasa Optimization" -RestorePointType MODIFY_SETTINGS -ErrorAction SilentlyContinue
}

$ActionCache = {
    $AppData = [System.Environment]::GetFolderPath('LocalApplicationData')
    $FiveMCache = "$AppData\FiveM\FiveM.app\data"
    if (Test-Path $FiveMCache) {
        Remove-Item -Path "$FiveMCache\cache" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$FiveMCache\server-cache" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$FiveMCache\server-cache-priv" -Recurse -Force -ErrorAction SilentlyContinue
    }
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
}

$ActionStandard = {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -ErrorAction SilentlyContinue
    
    $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions"
    if (-not (Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force | Out-Null }
    Set-ItemProperty -Path $RegistryPath -Name "CpuPriorityClass" -Value 3 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -ErrorAction SilentlyContinue
}

$ActionAmd = {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" -Name "PowerThrottlingOff" -Value 1 -ErrorAction SilentlyContinue
    
    $CoreParkingPaths = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318584",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb"
    )
    foreach ($Path in $CoreParkingPaths) {
        if (Test-Path $Path) { Set-ItemProperty -Path $Path -Name "Attributes" -Value 0 -ErrorAction SilentlyContinue }
    }
    powercfg /setacvalueindex scheme_current sub_processor cppmflags 0 2>$null
    powercfg /setacvalueindex scheme_current sub_processor decdecreasetime 100 2>$null
    powercfg /setacvalueindex scheme_current sub_processor incincreasetime 10 2>$null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache" -Value 1 -ErrorAction SilentlyContinue
    
    $AmdPaths = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -ErrorAction SilentlyContinue
    foreach ($SubKey in $AmdPaths) {
        if (Test-Path "$($SubKey.PSPath)\0000") {
            Set-ItemProperty -Path "$($SubKey.PSPath)\0000" -Name "PP_KMDEDC" -Value 0 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "$($SubKey.PSPath)\0000" -Name "StutterMode" -Value 0 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "$($SubKey.PSPath)\0000" -Name "PP_AllEnableExtendedUnlimiter" -Value 1 -ErrorAction SilentlyContinue
        }
    }
}

$ActionNetwork = {
    Clear-DnsClientCache
}

$ActionUniversal = {
    & $ActionCache
    & $ActionStandard
    & $ActionNetwork
}

# --- BUILD CUSTOM BUTTON LAYOUT ---
$BtnColorNormal = [System.Drawing.Color]::FromArgb(0, 150, 255)  
$BtnColorAction = [System.Drawing.Color]::FromArgb(46, 204, 113) 
$BtnColorAlert  = [System.Drawing.Color]::FromArgb(231, 76, 60)   

$Btn1 = Create-CustomButton "Create System Restore Point (Recommended)" 55  $BtnColorNormal $ActionRestore
$Btn2 = Create-CustomButton "Run Universal Optimization (Standard Suite)" 110 $BtnColorAction $ActionUniversal
$Btn3 = Create-CustomButton "Clear Cache Only"                            165 $BtnColorNormal $ActionCache
$Btn4 = Create-CustomButton "Apply Gaming Registry & CPU Priority Tweaks"  220 $BtnColorNormal $ActionStandard
$Btn5 = Create-CustomButton "Apply Heavy AMD CPU & GPU Specific Tweaks"  275 $BtnColorAlert  $ActionAmd
$Btn6 = Create-CustomButton "Flush DNS & Network Path Refresh"           330 $BtnColorNormal $ActionNetwork

$MainPanel.Controls.AddRange(@($MainHeader, $Btn1, $Btn2, $Btn3, $Btn4, $Btn5, $Btn6))

# --- ASSEMBLE WINDOW ELEMENTS ---
$Form.Controls.AddRange(@($AccentBar, $SidePanel, $MainPanel))

# Force App View Window Render Loop
[System.Windows.Forms.Application]::Run($Form)
