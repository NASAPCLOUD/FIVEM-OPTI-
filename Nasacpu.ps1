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

# --- MAIN FORM INITIALIZATION (PURE BLACK STYLING) ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Advanced Optimization - Created by Nasa"
$Form.Size = New-Object System.Drawing.Size(820, 520)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [System.Drawing.Color]::FromArgb(0, 0, 0) # Pure Black
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
$AccentBar.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255) # Sleek White Accent Bar

# --- SIDE PANEL: HARDWARE OVERVIEW ---
$SidePanel = New-Object System.Windows.Forms.Panel
$SidePanel.Size = New-Object System.Drawing.Size(265, 445)
$SidePanel.Location = New-Object System.Drawing.Point(15, 20)
$SidePanel.BackColor = [System.Drawing.Color]::FromArgb(0, 0, 0) # Pure Black

$SideHeader = New-Object System.Windows.Forms.Label
$SideHeader.Text = "SYSTEM CONFIG"
$SideHeader.Size = New-Object System.Drawing.Size(245, 25)
$SideHeader.Location = New-Object System.Drawing.Point(15, 15)
$SideHeader.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255) # Pure White Header
$SideHeader.Font = $HeaderFont

function Add-HardwareRow ($Title, $Value, $TopPosition) {
    $TitleLbl = New-Object System.Windows.Forms.Label
    $TitleLbl.Text = $Title
    $TitleLbl.Size = New-Object System.Drawing.Size(235, 18)
    $TitleLbl.Location = New-Object System.Drawing.Point(15, $TopPosition)
    $TitleLbl.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180) # Dimmed White/Gray for categories
    $TitleLbl.Font = $LabelFont

    $ValueLbl = New-Object System.Windows.Forms.Label
    $ValueLbl.Text = $Value
    $ValueLbl.Size = New-Object System.Drawing.Size(235, 32)
    $ValueLbl.Location = New-Object System.Drawing.Point(15, ($TopPosition + 18))
    $ValueLbl.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255) # Pure White Values
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
$RecHeader.Location = New-Object System.Drawing.Point(15, 260)$RecHeader.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255) # Pure White
$RecHeader.Font =$HeaderFont

$RecBox = New-Object System.Windows.Forms.Label
$RecBox.Text = $RecText$RecBox.Size = New-Object System.Drawing.Size(235, 150)
$RecBox.Location = New-Object System.Drawing.Point(15, 285)$RecBox.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255) # Pure White Recommendation Checklist
$RecBox.Font =$LabelFont

$SidePanel.Controls.AddRange(@($SideHeader, $RecHeader,$RecBox))

# --- MAIN PANEL: ACTIONS & INTERFACE ---
$MainPanel = New-Object System.Windows.Forms.Panel
$MainPanel.Size = New-Object System.Drawing.Size(500, 445)
$MainPanel.Location = New-Object System.Drawing.Point(295, 20)$MainPanel.BackColor = [System.Drawing.Color]::FromArgb(0, 0, 0) # Pure Black

$MainHeader = New-Object System.Windows.Forms.Label
$MainHeader.Text = "Advanced Performance Optimizer"
$MainHeader.Size = New-Object System.Drawing.Size(470, 25)
$MainHeader.Location = New-Object System.Drawing.Point(15, 15)$MainHeader.ForeColor =
