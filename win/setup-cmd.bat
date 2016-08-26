@echo off

set face_name="Lucida Console"

set argc=0
for %%x in (%*) do set /a argc+=1

if %argc% equ 1 set face_name=%1

REM backup hklm's ttf
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont" hklm-ttf.reg /y >nul

REM add default font
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont" /v 000 /t REG_SZ /d %face_name% /f

REM backup hkcu's console
reg export "HKCU\Console" hkcu-console.reg /y >nul

REM setup console
reg add "HKCU\Console" /v CodePage /t REG_DWORD /d 65001 /f
reg add "HKCU\Console" /v FaceName /t REG_SZ /d %face_name% /f
reg add "HKCU\Console" /v FontSize /t REG_DWORD /d 14 /f
reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 1 /f

reg add "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /v CodePage /t REG_DWORD /d 65001 /f
reg add "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /v FaceName /t REG_SZ /d %face_name% /f
reg add "HKCU\Console\%%SystemRoot%%_system32_cmd.exe" /v FontSize /t REG_DWORD /d 14 /f


