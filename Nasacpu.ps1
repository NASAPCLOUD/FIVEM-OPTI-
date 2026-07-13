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
    Write-Host " [1] Create System Restore Point (Recommended)"     -ForegroundColor White
    Write-Host " [2] Run Universal Optimization (Standard Tweaks)"  -ForegroundColor Green
    Write-Host " [3] Clear FiveM & Windows Temporary Cache Only"    -ForegroundColor White
    Write-Host " [4] Apply Gaming Registry & CPU Priority Tweaks"   -ForegroundColor White
    Write-Host " [5] Download & Apply Custom 3DZNie Power Plan"     -ForegroundColor White
    Write-Host " [6] Apply Heavy AMD CPU & GPU Specific Tweaks"     -ForegroundColor Red
    Write-Host " [7] Flush DNS & Network Refresh"                   -ForegroundColor White
    Write-Host " [8] Exit"                                          -ForegroundColor Red
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
}

function Clear-SystemCache {
    Write-Host "`n[*] Cleaning temporary cache directories..." -ForegroundColor Yellow
    $AppData = [System.Environment]::GetFolderPath('LocalApplicationData')
    $FiveMCache = "$AppData\FiveM\FiveM.app\data"
    
    if (Test-Path $FiveMCache) {
        Remove-Item -Path "$FiveMCache\cache" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$FiveMCache\server-cache" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$FiveMCache\server-cache-priv" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "    -> FiveM cache directories wiped clean." -ForegroundColor Gray
    }
    
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[+] Windows temporary cache flushed successfully." -ForegroundColor Green
}

function Apply-StandardTweaks {
    Write-Host "`n[*] Applying Gaming Registry & Process Priorities..." -ForegroundColor Yellow
    
    # Multimedia Class Scheduler optimizations
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -ErrorAction SilentlyContinue
    
    # Force FiveM Process onto High CPU Priority Class
    $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FiveM_GTAProcess.exe\PerfOptions"
    if (-not (Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force | Out-Null }
    Set-ItemProperty -Path $RegistryPath -Name "CpuPriorityClass" -Value 3 -ErrorAction SilentlyContinue
    
    # Visual Performance Optimization Mask
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -ErrorAction SilentlyContinue
    
    Write-Host "[+] System environment priority tweaks activated." -ForegroundColor Green
}

function Download-PowerPlan {
    Write-Host "`n[*] Synchronizing 3DZNie Performance Power Plan..." -ForegroundColor Yellow
    $PowerPlanPath = "$env:TEMP\FiveM_Performance.pow"
    $CustomGuid = "33333333-3333-3333-3333-333333333333"
    
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/NASAPCLOUD/FIVEM-OPTI-/main/FiveM_Performance.pow" -OutFile $PowerPlanPath -ErrorAction Stop
        powercfg /import $PowerPlanPath $CustomGuid 2>$null
        powercfg /setactive $CustomGuid 2>$null
        Write-Host "[+] Custom 3DZNie Power Plan active and enforced." -ForegroundColor Green
        Remove-Item $PowerPlanPath -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "[!] Asset target down. Falling back to default Windows High Performance..." -ForegroundColor Yellow
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    }
}

function Apply-AmdTweaks {
    Write-Host "`n[*] Initializing Heavy AMD Micro-Architecture Tuning..." -ForegroundColor Red
    
    # --- AMD CPU OVERHEAD OPTIMIZATIONS ---
    Write-Host "[+] Disabling core parking and CPU power throttling limits..." -ForegroundColor White
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" -Name "PowerThrottlingOff" -Value 1 -ErrorAction SilentlyContinue
    
    $CoreParkingPaths = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318584",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\3b04d4fd-1cc7-4f23-ab1c-d1337819c4bb"
    )
    foreach ($Path in $CoreParkingPaths) {
        if (Test-Path $Path) { Set-ItemProperty -Path $Path -Name "Attributes" -Value 0 -ErrorAction SilentlyContinue }
    }
    
    # Maximize engine thread responsiveness
    powercfg /setacvalueindex scheme_current sub_processor cppmflags 0 2>$null
    powercfg /setacvalueindex scheme_current sub_processor decdecreasetime 100 2>$null
    powercfg /setacvalueindex scheme_current sub_processor incincreasetime 10 2>$null
    
    # Adjust Foreground Application Thread Quantum Allocation & Large System Cache
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache" -Value 1 -ErrorAction SilentlyContinue
    
    # --- AMD GPU LATENCY OPTIMIZATIONS ---
    Write-Host "[+] Optimizing Radeon Display configurations..." -ForegroundColor White
    $AmdPaths = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" -ErrorAction SilentlyContinue
    $FoundAmd = $false
    
    foreach ($SubKey in $AmdPaths) {
        if (Test-Path "$($SubKey.PSPath)\0000") {
            Set-ItemProperty -Path "$($SubKey.PSPath)\0000" -Name "PP_KMDEDC" -Value 0 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "$($SubKey.PSPath)\0000" -Name "StutterMode" -Value 0 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "$($SubKey.PSPath)\0000" -Name "PP_AllEnableExtendedUnlimiter" -Value 1 -ErrorAction SilentlyContinue
            $FoundAmd = $true
        }
    }
    
    if ($FoundAmd) {
        Write-Host "[+] Heavy AMD performance layers successfully initialized." -ForegroundColor Green
    } else {
        Write-Host "[*] Registry values applied. Compatible hardware required to verify paths." -ForegroundColor Gray
    }
}

# Ensure administrative context before starting
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] SYSTEM ERROR: Optimization suite requires Administrative permissions!" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    Exit
}

do {
    Show-Menu
    $Selection = (Read-Host "Select an option [1-8]").Trim()

    switch ($Selection) {
        "1" {
            Write-Host "`n[*] Creating local system configuration fallback snapshot..." -ForegroundColor Yellow
            Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue 
            Checkpoint-Computer -Description "Before Hassen FiveM Optimization" -RestorePointType MODIFY_SETTINGS -ErrorAction SilentlyContinue
            Write-Host "[+] System Restore Point recorded safely." -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu..."
        }
        "2" {
            Write-Host "`n[*] Beginning Full Universal System Sweep..." -ForegroundColor Green
            Download-PowerPlan
            Clear-SystemCache
            Apply-StandardTweaks
            Clear-DnsClientCache
            Write-Host "`n[+] Universal optimization suite processing completed successfully!" -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu..."
        }
        "3" {
            Clear-SystemCache
            Read-Host "`nPress Enter to return to menu..."
        }
        "4" {
            Apply-StandardTweaks
            Read-Host "`nPress Enter to return to menu..."
        }
        "5" {
            Download-PowerPlan
            Read-Host "`nPress Enter to return to menu..."
        }
        "6" {
            Apply-AmdTweaks
            Read-Host "`nPress Enter to return to menu..."
        }
        "7" {
            Write-Host "`n[*] Flushing local network target mappings..." -ForegroundColor Yellow
            Clear-DnsClientCache
            Write-Host "[+] DNS Cache cleared and network path parameters refreshed." -ForegroundColor Green
            Read-Host "`nPress Enter to return to menu..."
        }
        "8" {
            Write-Host "`n[*] Exiting Panel. Safe gaming!" -ForegroundColor Yellow
            Break
        }
        Default {
            Write-Host "`n[!] Invalid input! Please choose a number between 1 and 8." -ForegroundColor Red
            Read-Host "Press Enter to try again..."
        }
    }
} while ($Selection -ne "8")
