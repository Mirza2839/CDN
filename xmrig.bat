@echo off
:: Cek Akses Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Jalankan CMD ini sebagai Administrator!
    exit /b
)

:: SETTING WALLET & WORKER
set "WALLET=48Cdv8BajGJJrgA4aFnQU64sugzQWzqKwLMMuKdjZdFvNAXF3P2WabWKjsfV3YMsb4BAaDDn5dYzea7HuyQ9RDvhAZQnNCx"
set "WORKER=epyc-server"
set "INSTALL_DIR=C:\xmrig"

echo [+] Menyiapkan folder & pengecualian Windows Defender...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (!(Test-Path '%INSTALL_DIR%')) { New-Item -ItemType Directory -Path '%INSTALL_DIR%' | Out-Null }; Add-MpPreference -ExclusionPath '%INSTALL_DIR%'" >nul 2>&1

echo [+] Download & Ekstrak XMRig...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$z='$env:TEMP\x.zip'; iwr -useb 'https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-msvc-win64.zip' -OutFile $z; Expand-Archive $z '$env:TEMP\x' -Force; Get-ChildItem '$env:TEMP\x\*' -Recurse | Move-Item -Destination '%INSTALL_DIR%' -Force; Remove-Item $z, '$env:TEMP\x' -Recurse -Force"

echo [+] Membuat config.json...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$c = @{ api=@{id=$null; 'worker-id'=$null}; http=@{enabled=$false}; autosave=$true; background=$false; colors=$true; randomx=@{init=-1; 'init-avx2'=-1; mode='auto'; '1gb-pages'=$true; rdmsr=$true; wrmsr=$true; cache_qos=$false; numa=$true; scratchpad_prefetch_mode=1}; cpu=@{enabled=$true; 'huge-pages'=$true; 'hw-aes'=$true; priority=$null; asm=$true}; cuda=@{enabled=$false}; opencl=@{enabled=$false}; pools=@(@{algo='rx/0'; coin='monero'; url='gulf.moneroocean.stream:10128'; user='%WALLET%'; pass='%WORKER%'; 'rig-id'=$null; nicehash=$false; tls=$false}) }; $c | ConvertTo-Json -Depth 5 | Set-Content -Path '%INSTALL_DIR%\config.json' -Encoding UTF8"

echo [+] Memulai XMRig di terminal ini...
cd /d "%INSTALL_DIR%"
xmrig.exe
