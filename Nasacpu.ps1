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

# --- MAIN FORM INITIALIZATION ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Advanced Optimization - Created by Nasa"
$Form.Size = New-Object System.Drawing.Size(780, 390)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [System.Drawing.Color]::FromArgb(20, 24, 32)
$Form.FormBorderStyle = "FixedSingle"
$Form.MaximizeBox = $false

# Custom global font definitions
$HeaderFont = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$LabelFont = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$ButtonFont = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

# --- SIDE PANEL: HARDWARE OVERVIEW ---
$SidePanel = New-Object System.Windows.Forms.Panel
$SidePanel.Size = New-Object System.Drawing.Size(260, 325)
$SidePanel.Location = New-Object System.Drawing.Point(15, 15)
$SidePanel.BackColor = [System.Drawing.Color]::FromArgb(28, 34, 46)

$SideHeader = New-Object System.Windows.Forms.Label
$SideHeader.Text = "SYSTEM HARDWARE"
$SideHeader.Size = New-Object System.Drawing.Size(240, 25)
$SideHeader.Location = New-Object System.Drawing.Point(10, 15)
$SideHeader.ForeColor = [System.Drawing.Color]::Cyan
$SideHeader.Font = $HeaderFont

$CpuLabel = New-Object System.Windows.Forms.Label
$CpuLabel.Text = "CPU Core Target Architecture:`n$Cpu"
$CpuLabel.Size = New-Object System.Drawing.Size(240, 45)
$CpuLabel.Location = New-Object System.Drawing.Point(10, 55)
$CpuLabel.ForeColor = [System.Drawing.Color]::White
$CpuLabel.Font = $LabelFont

$GpuLabel = New-Object System.Windows.Forms.Label
$GpuLabel.Text = "GPU Primary Rasterizer:`n$Gpu"
$GpuLabel.Size = New-Object System.Drawing.Size(240, 45)
$GpuLabel.Location = New-Object System.Drawing.Point(10, 115)
$GpuLabel.ForeColor = [System.Drawing.Color]::White
$GpuLabel.Font = $LabelFont

$DiskLabel = New-Object System.Windows.Forms.Label
$DiskLabel.Text = "System Drive Info (C:):`nType: $DriveTypeStr`nTotal Capacity: $($DriveSizeGB) GB`nFree Space: $($DriveFreeGB) GB"
$DiskLabel.Size = New-Object System.Drawing.Size(240, 70)
$DiskLabel.Location = New-Object System.Drawing.Point(10, 175)
$DiskLabel.ForeColor = [System.Drawing.Color]::White
$DiskLabel.Font = $LabelFont

$SidePanel.Controls.AddRange(@($SideHeader, $CpuLabel, $GpuLabel, $DiskLabel))

# --- MAIN PANEL: ACTIONS & INTERFACE ---
$MainPanel = New-Object System.Windows.Forms.Panel
$MainPanel.Size = New-Object System.Drawing.Size(465, 325)
$MainPanel.Location = New-Object System.Drawing.Point(290, 15)
$MainPanel.BackColor = [System.Drawing.Color]::FromArgb(28, 34, 46)

$MainHeader = New-Object System.Windows.Forms.Label
$MainHeader.Text = "SYSTEM TWEAKS PANEL"
$MainHeader.Size = New-Object System.Drawing.Size(445, 25)
$MainHeader.Location = New-Object System.Drawing.Point(15, 15)
$MainHeader.ForeColor = [System.Drawing.Color]::Yellow
$MainHeader.Font = $HeaderFont

# Reusable button building function
function Create-AppButton ($Text, $Top, $BgColor, $Action) {
    $Btn = New-Object System.Windows.Forms.Button
    $Btn.Text = $Text
    $Btn.Size = New-Object System.Drawing.Size(435, 38)
    $Btn.Location = New-Object System.Drawing.Point(15, $Top)
    $Btn.BackColor = $BgColor
    $Btn.ForeColor = [System.Drawing.Color]::White
    $Btn.FlatStyle = "Flat"
    $Btn.FlatAppearance.BorderSize = 0
    $Btn.Font = $ButtonFont
    $Btn.Add_Click($Action)
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

# --- BUILD ACTION BUTTONS ---
$Btn1 = Create-AppButton "Create System Restore Point (Recommended)" 55  [System.Drawing.Color]::FromArgb(60, 70, 85)   $ActionRestore
$Btn2 = Create-AppButton "Run Universal Optimization (Standard Suite)" 100 [System.Drawing.Color]::FromArgb(46, 125, 50)  $ActionUniversal
$Btn3 = Create-AppButton "Clear Cache Only"                            145 [System.Drawing.Color]::FromArgb(60, 70, 85)   $ActionCache
$Btn4 = Create-AppButton "Apply Gaming Registry & CPU Priority Tweaks"  190 [System.Drawing.Color]::FromArgb(60, 70, 85)   $ActionStandard
$Btn5 = Create-AppButton "Apply Heavy AMD CPU & GPU Specific Tweaks"  235 [System.Drawing.Color]::FromArgb(183, 28, 28)  $ActionAmd
$Btn6 = Create-AppButton "Flush DNS & Network Path Refresh"           280 [System.Drawing.Color]::FromArgb(60, 70, 85)   $ActionNetwork

$MainPanel.Controls.AddRange(@($MainHeader, $Btn1, $Btn2, $Btn3, $Btn4, $Btn5, $Btn6))

# --- ASSEMBLE WINDOW ELEMENTS ---
$Form.Controls.AddRange(@($SidePanel, $MainPanel))

# Force App View Window Render Loop
[System.Windows.Forms.Application]::Run($Form)
