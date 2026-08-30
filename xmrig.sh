#!/bin/bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -Sy xmrig-donateless
read -p "Name?: " nama_worker
xmrig -o pool.supportxmr.com:443 -u 48Cdv8BajGJJrgA4aFnQU64sugzQWzqKwLMMuKdjZdFvNAXF3P2WabWKjsfV3YMsb4BAaDDn5dYzea7HuyQ9RDvhAZQnNCx -k --tls -p "$nama_worker"
