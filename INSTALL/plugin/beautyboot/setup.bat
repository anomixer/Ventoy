@echo off
setlocal enabledelayedexpansion

rem ============================================================
rem  BeautyBoot - Ventoy GRUB Boot Animation Setup (Windows)
rem ============================================================
rem  Usage: Run as Administrator
rem         setup.bat [VentoyDriveLetter]
rem  Example: setup.bat E
rem ============================================================

echo.
echo  BeautyBoot - Ventoy Boot Animation Installer
echo  ============================================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please run as Administrator.
    echo         Right-click setup.bat and select "Run as administrator"
    pause
    exit /b 1
)

set DRIVE=%~1
if "%DRIVE%"=="" (
    echo [INPUT] Enter the Ventoy USB drive letter (e.g. E, F, G):
    set /p DRIVE="Drive letter: "
)
set DRIVE=%DRIVE::=%
set VENTOY_ROOT=%DRIVE%:\ventoy

if not exist "%VENTOY_ROOT%\" (
    echo [ERROR] ventoy\ folder not found on %DRIVE%:\
    echo         Make sure Ventoy is installed and the correct drive letter is used.
    pause
    exit /b 1
)
echo [OK] Found Ventoy directory: %VENTOY_ROOT%

rem Copy plugin ventoy/ files
set SCRIPT_DIR=%~dp0
if exist "%SCRIPT_DIR%ventoy\" (
    xcopy /E /Y /Q "%SCRIPT_DIR%ventoy\" "%VENTOY_ROOT%\"
    echo [OK] Copied plugin files to %VENTOY_ROOT%
) else (
    echo [ERROR] ventoy\ folder not found next to setup.bat.
    echo         Are you running from INSTALL\plugin\beautyboot\
    pause
    exit /b 1
)

rem Create phase0 directory
set PHASE0=%VENTOY_ROOT%\phase0
if not exist "%PHASE0%\" (
    mkdir "%PHASE0%"
    echo [OK] Created: %PHASE0%
)

rem Copy animation frames
set FRAME_COUNT=0
if exist "%SCRIPT_DIR%frames\frame_*.png" (
    copy /Y "%SCRIPT_DIR%frames\frame_*.png" "%PHASE0%\" >nul
    for %%f in ("%SCRIPT_DIR%frames\frame_*.png") do set /a FRAME_COUNT+=1
    echo [OK] Copied !FRAME_COUNT! frames to %PHASE0%
) else (
    echo [WARN] frames\frame_*.png not found.
    echo        Create a "frames" folder next to setup.bat and place your
    echo        PNG animation frames there (frame_00.png, frame_01.png, ...)
)

rem Build frame list
set FRAME_LIST=
for %%f in ("%PHASE0%\frame_*.png") do (
    set FNAME=%%~nf
    set FNUM=!FNAME:frame_=!
    set FRAME_LIST=!FRAME_LIST! !FNUM!
)
if "%FRAME_LIST%"=="" set FRAME_LIST=00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17

rem Write beautyboot_premenu.cfg
set PREMENU=%VENTOY_ROOT%\beautyboot_premenu.cfg
(
echo insmod png
echo insmod gfxterm
echo insmod gfxterm_background
echo.
echo set gfxmode=1920x1080,auto
echo terminal_output gfxterm
echo.
echo # BeautyBoot animation -- 167ms per frame ~6fps ~3s total for 18 frames
echo for frame in%FRAME_LIST%; do
echo     background_image ${vtoy_iso_part}/ventoy/phase0/frame_${frame}.png
echo     clear
echo     sleep --ms 167
echo done
) > "%PREMENU%"
echo [OK] Written: %PREMENU%

echo.
echo  ============================================================
echo  [DONE] Setup complete!
echo         Safely eject the USB and reboot to see the animation.
echo  ============================================================
echo.
pause
