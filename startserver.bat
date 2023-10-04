@echo off
set "executable_path=C:\Users\Tom Chan\Downloads\0705\QSanguosha.exe"
set "argument=1 -server"
setlocal enabledelayedexpansion
:menu
cls
echo 1. Start server
echo 2. Stop server
echo 3. Exit

choice /c 123 /n /m "Enter your choice:"

if errorlevel 3 goto exit
if errorlevel 2 goto stop
if errorlevel 1 goto start

:start
REM Start new process
start "" "%executable_path%" %argument%
goto menu

:stop
REM Terminate process
taskkill /F /IM QSanguosha.exe >nul 2>&1
goto menu

:exit
endlocal