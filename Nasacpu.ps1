function Show-Menu {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "        ADVANCED CPU OPTIMIZATION         " -ForegroundColor Cyan
    Write-Host "              created by Nasa                   " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " [1] Create System Restore Point (Recommended)" -ForegroundColor White
    Write-Host " [2] Run Full Optimization (All Tweaks)" -ForegroundColor Green
    Write-Host " [3] Clear FiveM & Windows Temporary Cache Only" -ForegroundColor White
    Write-Host " [4] Apply Gaming Registry & CPU Priority Tweaks" -ForegroundColor White
    Write-Host " [5] Optimize Power Plan & Windows Visuals" -ForegroundColor White
    Write-Host " [6] Flush DNS & Network Refresh" -ForegroundColor White
    Write-Host " [7] Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
}

# Ensure Admin privileges for deep tweaks
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] ERROR: Please run PowerShell as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    Exit
}

do {
    Show-Menu
    $Selection = Read-Host "Select an option [1-7]"

    switch ($Selection) {
        "1" {
            Write-Host "`n[*] Creating System Restore Point..." -ForegroundColor Green
            Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue 
            Checkpoint-Computer -Description "Before Hassen FiveM Optimization" -RestorePointType MODIFY_SETTINGS -ErrorAction SilentlyContinue
            Write-Host "[+] Restore point task finished." -ForegroundColor Gray
            Read-Host "`nPress Enter to return to menu..."
        }
        "2" {
            Write-Host "`n[*] Running complete system optimization..." -ForegroundColor Green
            # Power Plan
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
            if ($LASTEXITCODE -ne 0) { powercfg /setactive 852b64dd-951e-4f8a-a921-694602f34dbd 2>$null }
            
            # Cache Clean
            $AppData = [System.Environment]::GetFolderPath('LocalApplicationData')
            $FiveMCache = "$AppData\FiveM\FiveM.app\data"
            if (Test-Path $FiveMCache) {
                Remove-Item -Path "$FiveMCache\cache" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$FiveMCache\server-cache" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$FiveMCache\server-cache-priv" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            
            # Registry & Priority
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -ErrorAction SilentlyContinue
            $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions"
            if (-not (Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force | Out-Null }
            Set-ItemProperty -Path $RegistryPath -Name "CpuPriorityClass" -Value 3 -ErrorAction SilentlyContinue
            
            # Visuals
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -ErrorAction SilentlyContinue
            
            # Network
            Clear-DnsClientCache
            
            Write-Host "[+] All optimization tweaks applied successfully!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu..."
        }
        "3" {
            Write-Host "`n[*] Cleaning cache files..." -ForegroundColor Green
            $AppData = [System.Environment]::GetFolderPath('LocalApplicationData')
            $FiveMCache = "$AppData\FiveM\FiveM.app\data"
            if (Test-Path $FiveMCache) {
                Remove-Item -Path "$FiveMCache\cache" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$FiveMCache\server-cache" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$FiveMCache\server-cache-priv" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "    -> FiveM asset cache cleared." -ForegroundColor Gray
            }
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[+] System temp directories wiped clean." -ForegroundColor Gray
            Read-Host "`nPress Enter to return to menu..."
        }
        "4" {
            Write-Host "`n[*] Applying Registry and CPU tweaks..." -ForegroundColor Green
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -ErrorAction SilentlyContinue
            $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions"
            if (-not (Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force | Out-Null }
            Set-ItemProperty -Path $RegistryPath -Name "CpuPriorityClass" -Value 3 -ErrorAction SilentlyContinue
            Write-Host "[+] FiveM priority set to High and network throttling disabled." -ForegroundColor Gray
            Read-Host "`nPress Enter to return to menu..."
        }
        "5" {
            Write-Host "`n[*] Optimizing power scheme and interface latency..." -ForegroundColor Green
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
            if ($LASTEXITCODE -ne 0) { powercfg /setactive 852b64dd-951e-4f8a-a921-694602f34dbd 2>$null }
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -ErrorAction SilentlyContinue
            Write-Host "[+] Performance power plan active. Visual overhead reduced." -ForegroundColor Gray
            Read-Host "`nPress Enter to return to menu..."
        }
        "6" {
            Write-Host "`n[*] Flushing DNS resolution table..." -ForegroundColor Green
            Clear-DnsClientCache
            Write-Host "[+] Network target cache cleared." -ForegroundColor Gray
            Read-Host "`nPress Enter to return to menu..."
        }
    }
} while ($Selection -ne "7")
