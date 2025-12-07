:: ====================================================
:: STEALTH AUTO-ELEVATION
:: ====================================================
@echo off

:: ============================================================
:: Apostrophe-Safe Path Patch (V15)
:: Prevents crashes when the filename contains an apostrophe.
:: %~s0 = short 8.3 path, always safe.
:: ============================================================
set "SELF=%~s0"
set "SELFDIR=%~dps0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -WindowStyle Hidden -Command "Start-Process -FilePath '%SELF%' -Verb RunAs"
    exit /b
)

setlocal EnableDelayedExpansion
set "GPU_VENDOR=NVIDIA"
goto start


:: ====================================================
:: EXIT & BOOM SEQUENCE — 3-second countdown
:: ====================================================
:end
cls
echo.
echo All Done Checking Shi** =D
goto endend

:endend
cls
echo This Window will Now Explode!!!
echo.

for %%A in (3 2 1) do (
    cls
    echo BOOM in %%A...
    timeout /t 1 >nul
)

cls
echo ****************************************************
echo *                                                  *
echo *               BOOOOOOOOM!!!!                     *
echo *                                                  *
echo *                                                  *
echo ****************************************************
timeout /t 1 >nul
GOTO :EOF


:: ====================================================
:: MAIN START / MENU HEADER
:: ====================================================
:start
title Shawna's Cmd Tools
cls
echo.
echo ********************
echo *   Cmd Tools by   *
echo *    Shawna =D     *
echo ********************
echo.

:Menu
echo.
echo     1  = Check C
echo     2  = Check D
echo     3  = Fix C
echo     4  = Fix D
echo     5  = System File Checker
echo     6  = Multi Desktop
echo     7  = Event Dump
echo     8  = Select GPU Vendor   ^(%GPU_VENDOR%^)
echo     9  = GPU Check
echo    10 = Service Check
echo    11 = DISM System Repair
echo    12 = PCIe Link Check
echo    13 = Restart GPU Driver
echo    14 = CPU Snapshot
echo    15 = RAM Quick Test
echo    16 = System Cleanup Tool
echo    17 = Reset Windows Search Index
echo    18 = Reset Windows Store / AppX subsystem
echo    19 = Rebuild Icon Cache
echo    20 = Restart Explorer Shell Properly
echo    21 = Get me the fu** out!
echo.
set /p ANSWER=Choose a tool BITC**: 


:: ====================================================
:: SIMPLE DIRECT MAPPINGS
:: ====================================================
if "%ANSWER%"=="1"  (chkdsk C: & goto Post)
if "%ANSWER%"=="2"  (chkdsk D: & goto Post)
if "%ANSWER%"=="3"  (chkdsk C: /f & goto Post)
if "%ANSWER%"=="4"  (chkdsk D: /f & goto Post)
if "%ANSWER%"=="5"  (sfc /scannow & goto Post)
if "%ANSWER%"=="6"  (control /name Microsoft.Personalization /page pageWallpaper & goto end)

:: ====================================================
:: ADVANCED TOOLS
:: ====================================================
if "%ANSWER%"=="7"  goto EventDump
if "%ANSWER%"=="8"  goto SelectGPU
if "%ANSWER%"=="9"  goto GPUCheck
if "%ANSWER%"=="10" goto ServiceCheck
if "%ANSWER%"=="11" goto DISMFix
if "%ANSWER%"=="12" goto PciCheck
if "%ANSWER%"=="13" goto DriverRestart
if "%ANSWER%"=="14" goto CPUSnap
if "%ANSWER%"=="15" goto RAMQuick
if "%ANSWER%"=="16" goto CleanSys
if "%ANSWER%"=="17" goto ResetSearch
if "%ANSWER%"=="18" goto ResetStore
if "%ANSWER%"=="19" goto IconCache
if "%ANSWER%"=="20" goto RestartExplorer
if "%ANSWER%"=="21" goto end

echo Invalid selection BITC**, try again.
goto Menu


:: ====================================================
:: COMMON POST-ACTION SCREEN
:: ====================================================
:Post
echo.
echo Press Q to be a Quitter 
set /p KEY=
if /i "%KEY%"=="q" (goto end)
echo.
echo Fu** Off.. Haha that's not Q
goto end



:: ====================================================
:: EVENT LOG DUMP
:: ====================================================
:EventDump
cls
echo ====== Recent System/Application Errors ======
echo.
wevtutil qe System /c:20 /f:text /q:"*[System[(Level=1 or Level=2)]]"
echo.
wevtutil qe Application /c:20 /f:text /q:"*[System[(Level=1 or Level=2)]]"
echo.
pause
goto Menu



:: ====================================================
:: GPU VENDOR SELECTION
:: ====================================================
:SelectGPU
cls
echo ====== GPU Vendor Selection ======
echo.
echo Current GPU vendor: %GPU_VENDOR%
echo.
echo     1 = NVIDIA
echo     2 = AMD
echo     3 = Intel
echo     4 = Back to main menu
echo.
set /p GPUCHOICE=Choose GPU vendor: 

if "%GPUCHOICE%"=="1" (
    set "GPU_VENDOR=NVIDIA"
    goto Menu
)
if "%GPUCHOICE%"=="2" (
    set "GPU_VENDOR=AMD"
    goto Menu
)
if "%GPUCHOICE%"=="3" (
    set "GPU_VENDOR=INTEL"
    goto Menu
)
if "%GPUCHOICE%"=="4" goto Menu

echo Invalid selection.
pause
goto SelectGPU



:: ====================================================
:: GPU CHECK (per-vendor)
:: ====================================================
:GPUCheck
cls
echo ====== GPU Snapshot (%GPU_VENDOR%) ======
echo.

if /I "%GPU_VENDOR%"=="NVIDIA" goto GPUCheck_NVIDIA
if /I "%GPU_VENDOR%"=="AMD"    goto GPUCheck_AMD
if /I "%GPU_VENDOR%"=="INTEL"  goto GPUCheck_INTEL

goto GPUCheck_NVIDIA

:GPUCheck_NVIDIA
nvidia-smi
echo.
pause
goto Menu

:GPUCheck_AMD
powershell -NoLogo -NoProfile -Command ^
"Get-CimInstance Win32_VideoController ^| Where-Object { `$_.Name -match 'AMD' } ^| Select-Object Name,AdapterRAM,DriverVersion"
echo.
pause
goto Menu

:GPUCheck_INTEL
powershell -NoLogo -NoProfile -Command ^
"Get-CimInstance Win32_VideoController ^| Where-Object { `$_.Name -match 'Intel' } ^| Select-Object Name,AdapterRAM,DriverVersion"
echo.
pause
goto Menu



:: ====================================================
:: SERVICE CHECK
:: ====================================================
:ServiceCheck
cls
echo ====== Auto-Start Services Not Running ======
echo.

set FAILCOUNT=0
del failedlist.tmp >nul 2>&1

for /f "tokens=2 delims=:" %%A in ('sc query state^=inactive ^| findstr /R "SERVICE_NAME"') do (
    set SVC=%%A
    call :CheckAutoSvc !SVC!
)

if "!FAILCOUNT!"=="0" (
    echo No failing services =D
    pause
    goto Menu
)

echo.
echo Total FAILED auto-start services: !FAILCOUNT!
echo.
echo R = Restart all failed services
echo Q = Return
set /p CHX=

if /i "!CHX!"=="R" goto RestartFailed
goto Menu

:CheckAutoSvc
for /f "tokens=1,* delims=:" %%X in ('sc qc %1 ^| findstr START_TYPE') do (
    echo %%Y | find "AUTO_START" >nul && (
        set /a FAILCOUNT+=1
        echo %1>>failedlist.tmp
        echo %1
    )
)
goto :EOF

:RestartFailed
cls
echo Restarting failed services...
echo.

for /f %%S in (failedlist.tmp) do (
    net start %%S >nul 2>&1
    if !errorlevel! == 0 (echo SUCCESS: %%S) else (echo FAILED: %%S)
)

del failedlist.tmp
echo.
pause
goto Menu



:: ====================================================
:: DISM SYSTEM FIX
:: ====================================================
:DISMFix
cls
echo ====== Running DISM Health Restore ======
echo.
DISM /Online /Cleanup-Image /RestoreHealth
echo.
pause
goto Menu



:: ====================================================
:: PCIe LINK CHECK — DO NOT MODIFY
:: ====================================================
:PciCheck
cls
echo ====== PCIe Link Width / Speed Check ======
echo.

del "%temp%\pcie.ps1" >nul 2>&1

echo $gpu = Get-PnpDevice -FriendlyName 'NVIDIA*' > "%temp%\pcie.ps1"
echo $s = ($gpu ^| Get-PnpDeviceProperty 'DEVPKEY_PciDevice_CurrentLinkSpeed').Data >> "%temp%\pcie.ps1"
echo $m = ($gpu ^| Get-PnpDeviceProperty 'DEVPKEY_PciDevice_MaxLinkSpeed').Data >> "%temp%\pcie.ps1"

echo switch ($s) { >> "%temp%\pcie.ps1"
echo     1 { $sText = "PCIe Gen 1 (2.5 GT/s)" } >> "%temp%\pcie.ps1"
echo     2 { $sText = "PCIe Gen 2 (5.0 GT/s)" } >> "%temp%\pcie.ps1"
echo     3 { $sText = "PCIe Gen 3 (8.0 GT/s)" } >> "%temp%\pcie.ps1"
echo     4 { $sText = "PCIe Gen 4 (16.0 GT/s)" } >> "%temp%\pcie.ps1"
echo     5 { $sText = "PCIe Gen 5 (32.0 GT/s)" } >> "%temp%\pcie.ps1"
echo     default { $sText = "Unknown" } >> "%temp%\pcie.ps1"
echo } >> "%temp%\pcie.ps1"

echo switch ($m) { >> "%temp%\pcie.ps1"
echo     1 { $mText = "PCIe Gen 1 (2.5 GT/s)" } >> "%temp%\pcie.ps1"
echo     2 { $mText = "PCIe Gen 2 (5.0 GT/s)" } >> "%temp%\pcie.ps1"
echo     3 { $mText = "PCIe Gen 3 (8.0 GT/s)" } >> "%temp%\pcie.ps1"
echo     4 { $mText = "PCIe Gen 4 (16.0 GT/s)" } >> "%temp%\pcie.ps1"
echo     5 { $mText = "PCIe Gen 5 (32.0 GT/s)" } >> "%temp%\pcie.ps1"
echo     default { $mText = "Unknown" } >> "%temp%\pcie.ps1"
echo } >> "%temp%\pcie.ps1"

echo Write-Host "Current Link Speed : $sText" >> "%temp%\pcie.ps1"
echo Write-Host "Max Supported      : $mText"  >> "%temp%\pcie.ps1"

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%temp%\pcie.ps1"

echo.
echo If it reads as Unknown keep pressing enter until it works
echo Have to do this because of Windows timing issues
echo.
echo.
pause
goto Menu



:: ====================================================
:: RESTART GPU DRIVER (per-vendor)
:: ====================================================
:DriverRestart
cls
echo Restarting %GPU_VENDOR% driver...
echo.

if /I "%GPU_VENDOR%"=="NVIDIA" goto DriverRestart_NVIDIA
if /I "%GPU_VENDOR%"=="AMD"    goto DriverRestart_AMD
if /I "%GPU_VENDOR%"=="INTEL"  goto DriverRestart_INTEL

goto DriverRestart_NVIDIA

:DriverRestart_NVIDIA
powershell -NoLogo -NoProfile -WindowStyle Hidden -command "Restart-Service NVDisplay.ContainerLocalSystem -ErrorAction SilentlyContinue"
powershell -NoLogo -NoProfile -WindowStyle Hidden -command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait('^{SHIFT}^{WIN}{B}')"
echo.
pause
goto Menu

:DriverRestart_AMD
echo AMD GPU driver restart is not automated yet.
echo Please use Device Manager or AMD Software: Adrenalin to restart the driver.
echo.
pause
goto Menu

:DriverRestart_INTEL
echo Intel GPU driver restart is not automated yet.
echo Please use Device Manager or Intel Graphics tools to restart the driver.
echo.
pause
goto Menu



:: ====================================================
:: CPU SNAPSHOT — stable version
:: ====================================================
:CPUSnap
cls
echo ====== CPU Snapshot ======
echo.

del "%temp%\cpu_snap.ps1" >nul 2>&1

echo $cpu = Get-CimInstance Win32_Processor ^| Select-Object -First 1 Name,NumberOfCores,NumberOfLogicalProcessors> "%temp%\cpu_snap.ps1"
echo Write-Host "CPU:`t $($cpu.Name)">> "%temp%\cpu_snap.ps1"
echo Write-Host "Cores:`t $($cpu.NumberOfCores)">> "%temp%\cpu_snap.ps1"
echo Write-Host "Threads:`t $($cpu.NumberOfLogicalProcessors)">> "%temp%\cpu_snap.ps1"
echo Write-Host "" >> "%temp%\cpu_snap.ps1"
echo try {>> "%temp%\cpu_snap.ps1"
echo     $sample = (Get-Counter '\Processor(_Total)\%% Processor Time').CounterSamples.CookedValue>> "%temp%\cpu_snap.ps1"
echo     $cpuLoad = [Math]::Round($sample,1)>> "%temp%\cpu_snap.ps1"
echo     Write-Host "Load:`t $cpuLoad %%">> "%temp%\cpu_snap.ps1"
echo } catch {>> "%temp%\cpu_snap.ps1"
echo     Write-Host "Load:`t [Unavailable - Perf counters error]">> "%temp%\cpu_snap.ps1"
echo }>> "%temp%\cpu_snap.ps1"

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%temp%\cpu_snap.ps1"

echo.
pause
goto Menu



:: ====================================================
:: RAM QUICK TEST
:: ====================================================
:RAMQuick
cls
echo ====== RAM Quick Test ======
echo.

del "%temp%\ram_quick.ps1" >nul 2>&1

echo $os = Get-CimInstance Win32_OperatingSystem> "%temp%\ram_quick.ps1"
echo $total = [Math]::Round($os.TotalVisibleMemorySize / 1024, 1)>> "%temp%\ram_quick.ps1"
echo $free  = [Math]::Round($os.FreePhysicalMemory / 1024, 1)>> "%temp%\ram_quick.ps1"
echo $used  = [Math]::Round($total - $free, 1)>> "%temp%\ram_quick.ps1"
echo Write-Host "Total RAM: $total MB">> "%temp%\ram_quick.ps1"
echo Write-Host "Used RAM : $used MB">> "%temp%\ram_quick.ps1"
echo Write-Host "Free RAM : $free MB">> "%temp%\ram_quick.ps1"

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%temp%\ram_quick.ps1"

echo.
pause
goto Menu



:: ====================================================
:: SYSTEM CLEANUP TOOL
:: ====================================================
:CleanSys
cls
echo ====== System Cleanup Tool ======
echo.
del /s /q %windir%\Temp\* >nul 2>&1
del /s /q %temp%\* >nul 2>&1
cleanmgr /sagerun:1
dism /online /cleanup-image /startcomponentcleanup /resetbase
pause
goto Menu



:: ====================================================
:: RESET WINDOWS SEARCH INDEX
:: ====================================================
:ResetSearch
cls
net stop wsearch
del "%ProgramData%\Microsoft\Search\Data\Applications\Windows\*" /s /q
net start wsearch
pause
goto Menu



:: ====================================================
:: RESET WINDOWS STORE / APPX
:: ====================================================
:ResetStore
cls
wsreset -i
powershell -NoLogo -NoProfile -WindowStyle Hidden -command "Get-AppxPackage -AllUsers ^| Foreach {Add-AppxPackage -DisableDevelopmentMode -Register `$_.InstallLocation\AppxManifest.xml}"
pause
goto Menu



:: ====================================================
:: REBUILD ICON CACHE
:: ====================================================
:IconCache
cls
taskkill /IM explorer.exe /F
cd /d %LOCALAPPDATA%
del IconCache.db /a
del IconCache*.db /a
del %LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache* /f
start explorer.exe
pause
goto Menu



:: ====================================================
:: RESTART EXPLORER
:: ====================================================
:RestartExplorer
cls
taskkill /IM explorer.exe /F
timeout /t 1 >nul
start explorer.exe
pause
goto Menu
