# ====================================================================
#              FIVEM LOW-END PC OPTIMIZER
# ====================================================================
Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "         FIVEM LOW-END PC OPTIMIZER              " -ForegroundColor Cyan
Write-Host "              created by hassen                   " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# 1. User Prompt (Yes/No)
$Confirmation = Read-Host "Are you ready to optimize? (Y/N)"
if ($Confirmation -notmatch "^[Yy]$") {
    Write-Host "[!] Optimization canceled by user." -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    Exit
}

Write-Host ""
Write-Host "[*] Starting optimization process... Please wait." -ForegroundColor White

# 2. Create System Restore Point
Write-Host "[+] Creating a System Restore Point..." -ForegroundColor Green
Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue 
Checkpoint-Computer -Description "Before Hassen FiveM Optimization" -RestorePointType MODIFY_SETTINGS -ErrorAction SilentlyContinue
Write-Host "    -> Restore point created successfully." -ForegroundColor Gray

# 3. Force Ultimate/High Performance Power Plan
Write-Host "[+] Enabling Ultimate/High Performance Power Plan..." -ForegroundColor Green
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
if ($LASTEXITCODE -ne 0) {
    powercfg /setactive 852b64dd-951e-4f8a-a921-694602f34dbd 2>$null
}

# 4. Clear FiveM and GTA V Temporary Caches (Saves RAM/Disk Lag)
Write-Host "[+] Cleaning FiveM Cache and Temp files..." -ForegroundColor Green
$AppData = [System.Environment]::GetFolderPath('LocalApplicationData')
$FiveMCache = "$AppData\FiveM\FiveM.app\data"

if (Test-Path $FiveMCache) {
    Remove-Item -Path "$FiveMCache\cache" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$FiveMCache\server-cache" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$FiveMCache\server-cache-priv" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "    -> FiveM cache cleared successfully." -ForegroundColor Gray
}

# Clear Windows Temp files to free up RAM/Pagefile space
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# 5. Optimize Windows Memory Management for Gaming
Write-Host "[+] Optimizing Registry for Gaming Performance..." -ForegroundColor Green
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions"
if (-not (Test-Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}
Set-ItemProperty -Path $RegistryPath -Name "CpuPriorityClass" -Value 3

# 6. Disable Visual Overhead (Windows Animations & Transparency)
Write-Host "[+] Disabling intensive Windows visual effects..." -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\visualStudio" -Name "Value" -Value "Deny" -ErrorAction SilentlyContinue

# 7. Flush DNS to reduce connection lag spikes to heavy servers
Write-Host "[+] Flushing DNS Cache..." -ForegroundColor Green
Clear-DnsClientCache

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "    OPTIMIZATION COMPLETE! PLEASE RESTART YOUR PC  " -ForegroundColor Green
Write-Host "              created by hassen                   " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Read-Host "Press Enter to exit..."
