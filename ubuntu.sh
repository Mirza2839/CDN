#!/bin/bash
sudo apt update && sudo apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev -y && \
cd ~ && git clone https://github.com && cd xmrig && \
sed -i 's/constexpr const int kDefaultDonateLevel = 1;/constexpr const int kDefaultDonateLevel = 0;/g' src/donate.h && \
sed -i 's/constexpr const int kMinimumDonateLevel = 1;/constexpr const int kMinimumDonateLevel = 0;/g' src/donate.h && \
mkdir build && cd build && cmake .. && make -j$(nproc) && \
sudo cp xmrig /usr/local/bin/ && sudo mkdir -p /etc/xmrig && \
sudo sysctl -w vm.nr_hugepages=1280 && echo "vm.nr_hugepages=1280" | sudo tee -a /etc/sysctl.conf && \
echo "
[Unit]
Description=XMRig 0% Donate Full Power
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/xmrig -o pool.supportxmr.com:443 -u 48Cdv8BajGJJrgA4aFnQU64sugzQWzqKwLMMuKdjZdFvNAXF3P2WabWKjsfV3YMsb4BAaDDn5dYzea7HuyQ9RDvhAZQnNCx -k --tls -p SuperMicro
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/xmrig.service && \
sudo systemctl daemon-reload && sudo systemctl enable xmrig && sudo systemctl start xmrig && \
sudo systemctl status xmrig --no-pager

