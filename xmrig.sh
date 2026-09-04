#!/bin/bash

# ==========================================
# 1. Menanyakan nama worker di awal
# ==========================================
read -p "Masukkan nama worker untuk mining ini (misal: Worker-01): " WORKER_NAME

# Validasi jika nama worker kosong
if [ -z "$WORKER_NAME" ]; then
    echo "Error: Nama worker tidak boleh kosong!"
    exit 1
fi

# ==========================================
# 2. Mendeteksi OS Host
# ==========================================
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    # Coba deteksi OS turunan Arch (opsional)
    if [ "$ID_LIKE" == "arch" ]; then
        OS="arch"
    fi
else
    echo "Error: Sistem Operasi tidak dapat dideteksi."
    exit 1
fi

echo "Sistem terdeteksi: $OS"

# Variabel default untuk lokasi binary dan metode build
XMRIG_BIN="/usr/local/bin/xmrig"
BUILD_FROM_SOURCE=true

# ==========================================
# 3. Instalasi Dependensi Sesuai OS
# ==========================================
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    echo "Menyiapkan lingkungan untuk Debian/Ubuntu..."
    sudo apt update
    sudo apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev -y

elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "fedora" || "$OS" == "rocky" || "$OS" == "almalinux" ]]; then
    echo "Menyiapkan lingkungan untuk keluarga RHEL..."
    PKG_MANAGER=$(command -v dnf || command -v yum)
    sudo $PKG_MANAGER install epel-release -y
    sudo $PKG_MANAGER update -y
    sudo $PKG_MANAGER install git make cmake gcc gcc-c++ libuv-devel openssl-devel hwloc-devel -y

elif [[ "$OS" == "arch" ]]; then
    echo "Menyiapkan lingkungan untuk Arch Linux..."
    BUILD_FROM_SOURCE=false
    XMRIG_BIN="/usr/bin/xmrig" # yay menginstal binary xmrig di /usr/bin/
    
    # Update dan pastikan base-devel serta git terinstal
    sudo pacman -Sy --noconfirm --needed base-devel git

    # Membuat user sementara karena yay (AUR Helper) tidak bisa dijalankan sebagai root
    TEMP_USER="aur_builder_temp"
    echo "Membuat user sementara: $TEMP_USER"
    sudo useradd -m $TEMP_USER
    echo "$TEMP_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$TEMP_USER

    # Install yay jika belum ada
    if ! command -v yay &> /dev/null; then
        echo "Yay belum terinstal. Menginstal yay..."
        sudo -u $TEMP_USER bash -c 'cd ~ && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm'
    fi

    # Install xmrig-donateless menggunakan yay sebagai user sementara
    echo "Menginstal xmrig-donateless dari AUR..."
    sudo -u $TEMP_USER bash -c 'yay -S --noconfirm xmrig-donateless'

    # Menghapus user sementara setelah instalasi selesai
    echo "Menghapus user sementara: $TEMP_USER"
    sudo rm /etc/sudoers.d/$TEMP_USER
    sudo userdel -r $TEMP_USER

else
    echo "Error: OS '$OS' belum didukung oleh script deteksi otomatis ini."
    exit 1
fi

# ==========================================
# 4. Proses Build XMRig (Hanya untuk Debian/Ubuntu/RHEL)
# ==========================================
if [ "$BUILD_FROM_SOURCE" = true ]; then
    echo "Membangun (compile) XMRig dari source code..."
    cd ~ 
    git clone https://github.com/xmrig/xmrig.git 
    cd xmrig

    # Menghapus donasi bawaan (0%)
    sed -i 's/constexpr const int kDefaultDonateLevel = 1;/constexpr const int kDefaultDonateLevel = 0;/g' src/donate.h 
    sed -i 's/constexpr const int kMinimumDonateLevel = 1;/constexpr const int kMinimumDonateLevel = 0;/g' src/donate.h

    # Build aplikasi
    mkdir build && cd build 
    cmake .. 
    make -j$(nproc)

    # Mengcopy binary dan menyiapkan direktori
    sudo cp xmrig $XMRIG_BIN
fi

# ==========================================
# 5. Optimasi dan Konfigurasi
# ==========================================
sudo mkdir -p /etc/xmrig

# Optimasi Hugepages
sudo sysctl -w vm.nr_hugepages=1280 
echo "vm.nr_hugepages=1280" | sudo tee -a /etc/sysctl.conf

# ==========================================
# 6. Pembuatan Service Systemd
# ==========================================
# File service akan menggunakan binary path dari variabel $XMRIG_BIN dan argumen -p dari $WORKER_NAME
echo "
[Unit]
Description=XMRig 0% Donate Full Power
After=network.target

[Service]
Type=simple
User=root
ExecStart=${XMRIG_BIN} -o pool.supportxmr.com:443 -u 48Cdv8BajGJJrgA4aFnQU64sugzQWzqKwLMMuKdjZdFvNAXF3P2WabWKjsfV3YMsb4BAaDDn5dYzea7HuyQ9RDvhAZQnNCx -k --tls -p ${WORKER_NAME}
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/xmrig.service

# ==========================================
# 7. Start dan Status Service
# ==========================================
sudo systemctl daemon-reload 
sudo systemctl enable xmrig 
sudo systemctl start xmrig 
sudo systemctl status xmrig --no-pager
