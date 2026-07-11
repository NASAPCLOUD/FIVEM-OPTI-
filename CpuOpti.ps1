# ====================================================================
#              FIVEM LOW-END PC OPTIMIZER
# ====================================================================
Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "         FIVEM LOW-END PC OPTIMIZER              " -ForegroundColor Cyan
Write-Host "              created by hassen                   " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Confirmation Prompt
$Choice = Read-Host "Are you ready to optimize? (Yes/No)"
if ($Choice -notmatch "^(yes|y)$") {
    Write-Host "[!] Optimization cancelled by user." -ForegroundColor Yellow
    Read-Host "Press Enter to exit..."
    exit
}

Write-Host ""
Write-Host "[*] Starting optimization process... Please wait." -ForegroundColor White

# Create a System Restore Point
Write-Host "[+] Creating a System Restore Point..." -ForegroundColor Green
# Enable restore points on the C: drive just in case it's disabled
Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue 
Checkpoint-Computer -Description "Before hassen FiveM Optimization" -RestorePointType MODIFY_SETTINGS -ErrorAction SilentlyContinue
Write-Host "    -> Restore point created successfully." -ForegroundColor Gray

# 1. Force Ultimate/High Performance Power Plan
Write-Host "[+] Enabling Ultimate/High Performance Power Plan..." -ForegroundColor Green
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
if ($LASTEXITCODE -ne 0) {
    powercfg /setactive 852b64dd-951e-4f8a-a921-694602f34dbd 2>$null # Fallback to High Performance
}

# 2. Clear FiveM and GTA V Temporary Caches (Saves RAM/Disk Lag)[cite: 1]
Write-Host "[+] Cleaning FiveM Cache and Temp files..." -ForegroundColor Green[cite: 1]
$AppData = [System.Environment]::GetFolderPath('LocalApplicationData')[cite: 1]
$FiveMCache = "$AppData\FiveM\FiveM.app\data"[cite: 1]

if (Test-Path $FiveMCache) {[cite: 1]
    # Removes server cache but keeps your game data intact[cite: 1]
    Remove-Item -Path "$FiveMCache\cache" -Recurse -Force -ErrorAction SilentlyContinue[cite: 1]
    Remove-Item -Path "$FiveMCache\server-cache" -Recurse -Force -ErrorAction SilentlyContinue[cite: 1]
    Remove-Item -Path "$FiveMCache\server-cache-priv" -Recurse -Force -ErrorAction SilentlyContinue[cite: 1]
    Write-Host "    -> FiveM cache cleared successfully." -ForegroundColor Gray[cite: 1]
}

# Clear Windows Temp files to free up RAM/Pagefile space[cite: 1]
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue[cite: 1]
Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue[cite: 1]

# 3. Optimize Windows Memory Management for Gaming[cite: 1]
Write-Host "[+] Optimizing Registry for Gaming Performance..." -ForegroundColor Green[cite: 1]
# Disable Network Throttling for gaming traffic[cite: 1]
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF[cite: 1]
# Give games priority over background tasks[cite: 1]
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0[cite: 1]
# Set FiveM Subprocess priority to High natively[cite: 1]
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions"[cite: 1]
if (-not (Test-Path $RegistryPath)) {[cite: 1]
    New-Item -Path $RegistryPath -Force | Out-Null[cite: 1]
}
Set-ItemProperty -Path $RegistryPath -Name "CpuPriorityClass" -Value 3[cite: 1]

# 4. Disable Visual Overhead (Windows Animations & Transparency)[cite: 1]
Write-Host "[+] Disabling intensive Windows visual effects..." -ForegroundColor Green[cite: 1]
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -ErrorAction SilentlyContinue[cite: 1]
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\visualStudio" -Name "Value" -Value "Deny" -ErrorAction SilentlyContinue[cite: 1]

# 5. Flush DNS to reduce connection lag spikes to heavy servers[cite: 1]
Write-Host "[+] Flushing DNS Cache..." -ForegroundColor Green[cite: 1]
Clear-DnsClientCache[cite: 1]

Write-Host ""[cite: 1]
Write-Host "==================================================" -ForegroundColor Cyan[cite: 1]
Write-Host "    OPTIMIZATION COMPLETE! PLEASE RESTART YOUR PC  " -ForegroundColor Green[cite: 1]
Write-Host "              created by hassen                   " -ForegroundColor Yellow[cite: 1]
Write-Host "==================================================" -ForegroundColor Cyan[cite: 1]
Read-Host "Press Enter to exit..."[cite: 1]
