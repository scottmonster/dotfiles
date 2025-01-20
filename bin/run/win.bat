

@REM This script should install choco, use choco to install lua


echo 'This needs to be tested before it's used an because my environment is a dumpster fire the networks aren't working for my windows VMs'
echo 'This is what we WOULD do...'

echo 'install choco with:'
echo '@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"'
echo @"%%SystemRoot%%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" ^&^& SET "PATH=%%PATH%%;%%ALLUSERSPROFILE%%\chocolatey\bin"

echo 'install lua with:'
echo '%ALLUSERSPROFILE%\chocolatey\bin\choco install lua --version 5.1.5.52 -y'
echo %%ALLUSERSPROFILE%%\chocolatey\bin\choco install lua --version 5.1.5.52 -y
