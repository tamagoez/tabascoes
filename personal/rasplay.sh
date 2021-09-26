#!/bin/bash

cd

sudo apt update
sudo apt full-upgrade -y

git clone https://github.com/FD-/RPiPlay.git
cd RPiPlay

sudo apt-get install cmake
sudo apt-get install libavahi-compat-libdnssd-dev
sudo apt-get install libplist-dev
sudo apt-get install libssl-dev
mkdir build
cd build
cmake ..
make -j

cd
touch rpiplay-config.txt
echo -n Monitor -b auto -l -a hdmi > rpiplay-config.txt

cat <<EOF | sudo tee /etc/systemd/system/rpiplay.service
[Unit]
Description=RPi Play
After=network.target
StartLimitIntervalSec=30

[Service]
Type=simple
Restart=always
RestartSec=10
User=pi
ExecStart=/home/pi/RPiPlay/build/rpiplay $(cat /home/pi/rpiplay-config.txt)
StandardOutput=inherit
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable rpiplay
sudo systemctl start rpiplay
