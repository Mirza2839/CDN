# ==============================================================================
# AUTOMATED XMRIG SETUP & LAUNCHER (CPU-ONLY FOR AMD EPYC VM)
# ==============================================================================

# 1. MINTA HAK AKSES ADMINISTRATOR
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Meminta akses Administrator..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# 2. VARIABEL KONFIGURASI (UBAH ALAMAT WALLET ANDA DI SINI)
$walletAddress = "48Cdv8BajGJJrgA4aFnQU64sugzQWzqKwLMMuKdjZdFvNAXF3P2WabWKjsfV3YMsb4BAaDDn5dYzea7HuyQ9RDvhAZQnNCx"
$workerName    = "epyc-server"
$installDir    = "C:\xmrig"

$xmrigUrl      = "https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-msvc-win64.zip"

Write-Host "=== PERSIAPAN MINING CPU AMD EPYC ===" -ForegroundColor Green

# 3. BUAT DIREKTORI DAN KECUALIKAN DARI WINDOWS DEFENDER
if (-not (Test-Path -Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

Write-Host "[+] Menambahkan pengecualian Windows Defender..." -ForegroundColor Cyan
Add-MpPreference -ExclusionPath $installDir -ErrorAction SilentlyContinue

# 4. UNDUH DAN EKSTRAK XMRIG
$xmrigZip = "$env:TEMP\xmrig.zip"
Write-Host "[+] Mendownload XMRig..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $xmrigUrl -OutFile $xmrigZip

Write-Host "[+] Mengekstrak XMRig..." -ForegroundColor Cyan
Expand-Archive -Path $xmrigZip -DestinationPath "$env:TEMP\xmrig_extracted" -Force
Get-ChildItem -Path "$env:TEMP\xmrig_extracted\*" -Recurse | Move-Item -Destination $installDir -Force
Remove-Item -Path $xmrigZip, "$env:TEMP\xmrig_extracted" -Recurse -Force

# 5. BUAT FILE CONFIG.JSON (DIOPTIMALKAN UNTUK CPU EPYC)
Write-Host "[+] Membuat file konfigurasi khusus CPU..." -ForegroundColor Cyan
$configJson = @"
{
    "api": {
        "id": null,
        "worker-id": null
    },
    "http": {
        "enabled": false
    },
    "autosave": true,
    "background": false,
    "colors": true,
    "randomx": {
        "init": -1,
        "init-avx2": -1,
        "mode": "auto",
        "1gb-pages": true,
        "rdmsr": true,
        "wrmsr": true,
        "cache_qos": false,
        "numa": true,
        "scratchpad_prefetch_mode": 1
    },
    "cpu": {
        "enabled": true,
        "huge-pages": true,
        "hw-aes": true,
        "priority": null,
        "asm": true
    },
    "cuda": {
        "enabled": false
    },
    "opencl": {
        "enabled": false
    },
    "pools": [
        {
            "algo": "rx/0",
            "coin": "monero",
            "url": "gulf.moneroocean.stream:10128",
            "user": "$walletAddress",
            "pass": "$workerName",
            "rig-id": null,
            "nicehash": false,
            "tls": false
        }
    ]
}
"@

Set-Content -Path "$installDir\config.json" -Value $configJson -Encoding UTF8

# 6. JALANKAN XMRIG
Write-Host "[+] Persiapan Selesai! Memulai XMRig CPU Miner..." -ForegroundColor Green
Set-Location -Path $installDir
Start-Process -FilePath "$installDir\xmrig.exe" -WorkingDirectory $installDir
