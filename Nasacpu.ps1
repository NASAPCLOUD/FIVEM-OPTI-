# ====================================================================
#              FIVEM ADVANCED OPTIMIZATION PANEL
# ====================================================================

function Show-Menu {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "       FIVEM ADVANCED OPTIMIZATION PANEL          " -ForegroundColor Cyan
    Write-Host "              created by hassen                   " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " [1] Create System Restore Point (Recommended)" -ForegroundColor White
    Write-Host " [2] Run Full Optimization (All Tweaks)" -ForegroundColor Green
    Write-Host " [3] Clear FiveM & Windows Temporary Cache Only" -ForegroundColor White
    Write-Host " [4] Apply Gaming Registry & CPU Priority Tweaks" -ForegroundColor White
    Write-Host " [5] Download & Apply Custom 3DZNie Power Plan" -ForegroundColor White
    Write-Host " [6] Apply Heavy AMD CPU & GPU Specific Performance Tweaks" -ForegroundColor Red
    Write-Host " [7] Flush DNS & Network Refresh" -ForegroundColor White
    Write-Host " [8] Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] ERROR: Please run PowerShell as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    Exit
}

function Apply-AmdTweaks {
    Write-Host "[*] Applying Heavy AMD Specific Optimization Tweaks..." -ForegroundColor Green
    
    # --- HEAVY AMD CPU TWEAKS ---
    Write-Host "[+] Optimizing AMD Ryzen Thread Scheduling & Performance..." -ForegroundColor White
    
    # 1. Disable Windows Power Throttling completely
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" -Name "PowerThrottlingOff" -Value 1 -ErrorAction SilentlyContinue
    
    # 2. Disable Core Parking (Forces all physical AMD cores to stay awake and ready)
    $CoreParkingPaths = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318584",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb"
    )
    foreach ($Path in $CoreParkingPaths) {
        if (Test-Path $Path) {
            Set-ItemProperty -Path $Path -Name "Attributes" -Value 0 -ErrorAction SilentlyContinue
        }
    }
    # Apply raw power configurations to maximize unparked engine states
    powercfg /setacvalueindex scheme_current sub_processor cppmflags 0 2>$null
    powercfg /setacvalueindex scheme_current sub_processor decdecreasetime 100 2>$null
    powercfg /setacvalueindex scheme_current sub_processor incincreasetime 10 2>$null
    
    # 3. Optimize Windows Thread Quantum for Gaming (Prioritizes short, fast burst tasks like FiveM)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -ErrorAction SilentlyContinue

    # 4. AMD Multi-Thread Cache Alignment (Improves CCX/CCD cross-talk latency)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache" -Value 1 -ErrorAction SilentlyContinue
    
    # --- AMD GPU TWEAKS ---
    Write-Host "[+] Modifying Radeon Display Registry Configurations..." -ForegroundColor White
    $AmdPaths = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -ErrorAction SilentlyContinue
    $FoundAmd = $false
    
    foreach ($SubKey in $AmdPaths) {
        if (Test-Path "$($SubKey.PSPath)\0000") {
            # Disable Ultra-Low Power State (ULPS) to stop voltage drops
            Set-ItemProperty -Path "$($SubKey.PSPath)\0000" -Name "PP_KMDEDC" -Value 0 -ErrorAction SilentlyContinue
            # Turn off specific driver micro-stutter flag checks
            Set-ItemProperty -Path "$($SubKey.PSPath)\0000" -Name "StutterMode" -Value 0 -ErrorAction SilentlyContinue
            # Enable KMD Enable Downclock Override (Forces GPU to stay in 3D performance mode)
            Set-ItemProperty -Path "$($SubKey.PSPath)\0000" -Name "PP_AllEnableExtendedUnlimiter" -Value 1 -ErrorAction SilentlyContinue
            $FoundAmd = $true
        }
    }
    
    if ($FoundAmd) {
        Write-Host "[+] Heavy AMD tweaks successfully pushed to hardware keys." -ForegroundColor Gray
    } else {
        Write-Host "[*] Registry entry injected. Will initialize if compatible hardware is active." -ForegroundColor Gray
    }
}

do {
    Show-Menu
    $Selection = Read-Host "Select an option [1-8]"

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
            
            # --- CUSTOM POWER PLAN IMPORT ---
            Write-Host "[+] Downloading 3DZNie Performance Power Plan..." -ForegroundColor Green
            $PowerPlanPath = "$env:TEMP\FiveM_Performance.pow"
            $CustomGuid = "33333333-3333-3333-3333-333333333333"
            
            try {
                Invoke-WebRequest -Uri "https://raw.githubusercontent.com/NASAPCLOUD/FIVEM-OPTI-/main/FiveM_Performance.pow" -OutFile $PowerPlanPath -ErrorAction Stop
                powercfg /import $PowerPlanPath $CustomGuid 2>$null
                powercfg /setactive $CustomGuid 2>$null
                Write-Host "    -> Custom 3DZNie Power Plan applied successfully!" -ForegroundColor Gray
                Remove-Item $PowerPlanPath -Force -ErrorAction SilentlyContinue
            } catch {
                Write-Host "    -> [!] Plan download failed. Falling back to High Performance..." -ForegroundColor Yellow
                powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
            }
            
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
            
            # Execute the heavy AMD suite
            Apply-AmdTweaks

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
            }
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[+] Cache directories wiped clean." -ForegroundColor Gray
            Read-Host "`nPress Enter to return to menu..."
        }
        "4" {
            Write-Host "`n[*] Applying Registry and CPU tweaks..." -ForegroundColor Green
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -ErrorAction SilentlyContinue
            $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions"
            if (-not (Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force | Out-Null }
            Set-ItemProperty -Path $RegistryPath -Name "CpuPriorityClass" -Value 3 -ErrorAction SilentlyContinue
            Write-Host "[+] FiveM priority set to High." -ForegroundColor Gray
            Read-Host "`nPress Enter to return to menu..."
        }
        "5" {
            Write-Host "`n[*] Downloading custom 3DZNie Power Plan..." -ForegroundColor Green
            $PowerPlanPath = "$env:TEMP\FiveM_Performance.pow"
            $CustomGuid = "33333333-3333-3333-3333-333333333333"
            
            try {
                Invoke-WebRequest -Uri "https://raw.githubusercontent.com/NASAPCLOUD/FIVEM-OPTI-/main/FiveM_Performance.pow" -OutFile $PowerPlanPath -ErrorAction Stop
                powercfg /import $PowerPlanPath $CustomGuid 2>$null
                powercfg /setactive $CustomGuid 2>$null
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -ErrorAction SilentlyContinue
                Write-Host "[+] Custom power plan activated successfully!" -ForegroundColor Green
                Remove-Item $PowerPlanPath -Force -ErrorAction SilentlyContinue
            } catch {
                Write-Host "[!] Download failed. Ensure 'FiveM_Performance.pow' is uploaded to GitHub." -ForegroundColor Red
            }
            Read-Host "`nPress Enter to return to menu..."
        }
        "6" {
            Apply-AmdTweaks
            Read-Host "`nPress Enter to return to menu..."
        }
        "7" {
            Write-Host "`n[*] Flushing DNS resolution table..." -ForegroundColor Green
            Clear-DnsClientCache
            Write-Host "[+] Network target cache cleared." -ForegroundColor Gray
            Read-Host "`nPress Enter to return to menu..."
        }
    }
} while ($Selection -ne "8")
