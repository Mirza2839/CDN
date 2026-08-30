#!/bin/bash
sudo pacman -S --needed --noconfirm git base-devel
cd /tmp
rm -rf yay 
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
read -p "Mau kasih nama apa untuk worker ini?: " nama_worker
yay -Sy --noconfirm xmrig-donateless
xmrig -o pool.supportxmr.com:443 -u 48Cdv8BajGJJrgA4aFnQU64sugzQWzqKwLMMuKdjZdFvNAXF3P2WabWKjsfV3YMsb4BAaDDn5dYzea7HuyQ9RDvhAZQnNCx -k --tls -p "$nama_worker"
