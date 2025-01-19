@echo off
setlocal

REM Remove Chocolatey from the PATH
set "new_path="
for %%i in (%PATH:;= %) do (
    if /I "%%i" neq "%ALLUSERSPROFILE%\chocolatey\bin" (
        set "new_path=!new_path!;%%i"
    )
)
set "PATH=%new_path:~1%"

REM Remove Chocolatey directory
rmdir /S /Q "%ALLUSERSPROFILE%\chocolatey"

REM Remove Chocolatey environment variables
reg delete "HKCU\Environment" /F /V ChocolateyInstall
reg delete "HKCU\Environment" /F /V ChocolateyToolsLocation
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /F /V ChocolateyInstall
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /F /V ChocolateyToolsLocation

echo Chocolatey has been uninstalled.

endlocal
pause