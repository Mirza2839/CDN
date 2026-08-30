#!/bin/bash

# 1. Pastikan dependencies dasar terinstall via pacman
sudo pacman -S --needed --noconfirm git base-devel

# 2. Cek apakah script dijalankan sebagai root (UID 0)
if [ "$EUID" -eq 0 ]; then
    echo "[!] Mendeteksi akses Root (Live USB). Menyiapkan user bypass..."
    
    # Buat user dummy 'builder' jika belum ada
    if ! id "builder" &>/dev/null; then
        useradd -m -G wheel builder
        echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    fi
    
    # Atur izin folder /tmp agar bisa ditulis oleh user builder
    chown -R builder:builder /tmp
    
    # Proses install YAY menggunakan user builder
    echo "[+] Menginstall yay..."
    sudo -u builder bash -c '
        cd /tmp
        rm -rf yay
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
    '
    
    # Minta input nama worker terlebih dahulu
    read -p "Mau kasih nama apa untuk worker ini?: " nama_worker
    
    # Proses install XMRig menggunakan user builder
    echo "[+] Menginstall xmrig-donateless..."
    sudo -u builder yay -Sy --noconfirm xmrig-donateless

else
    # KONDISI JIKA DIJALANKAN SEBAGAI USER BIASA (NON-ROOT)
    echo "[+] Menjalankan sebagai user biasa..."
    
    cd /tmp
    rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    
    read -p "Mau kasih nama apa untuk worker ini?: " nama_worker
    
    yay -Sy --noconfirm xmrig-donateless
fi

# 3. Jalankan XMRig dengan nama worker yang diinput
echo "[+] Menjalankan XMRig..."
xmrig -o ://supportxmr.com -u 48Cdv8BajGJJrgA4aFnQU64sugzQWzqKwLMMuKdjZdFvNAXF3P2WabWKjsfV3YMsb4BAaDDn5dYzea7HuyQ9RDvhAZQnNCx -k --tls -p "$nama_worker"
