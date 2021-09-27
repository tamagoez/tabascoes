#!/bin/bash

cd

sudo apt update
sudo apt full-upgrade -y
sudo apt install xscreensaver -y

git clone https://github.com/FD-/RPiPlay.git
cd RPiPlay

sudo apt install -y cmake
sudo apt install -y libavahi-compat-libdnssd-dev
sudo apt install -y libplist-dev
sudo apt install -y libssl-dev
mkdir build
cd build
cmake ..
make -j

cd
touch rpiplay-config.txt
echo "-n Monitor -b auto -l -a hdmi" > rpiplay-config.txt

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

cat <<EOF | tee $HOME/wallpaper.sh
#!/bin/bash
pcmanfm --wallpaper-mode=fit
x=1
while true
do
  pcmanfm -w $HOME/wallpaper/$x.jpg
  if [ x = $(ls /home/pi/wallpaper/ -U1 | wc -l) ]; then
    x=1
  else
    x=$((x+1))
  fi
  sleep $1
done
EOF

sudo chmod 777 $HOME/wallpaper.sh
echo 1 > $HOME/wallpaper-option.txt

cat <<EOF | sudo tee /etc/systemd/system/wallpaper.service
[Unit]
Description=Wallpaper
After=network.target
StartLimitIntervalSec=30

[Service]
Type=simple
Restart=always
RestartSec=10
User=pi
ExecStart=/home/pi/wallpaper.sh $(cat /home/pi/wallpaper-option.txt)
StandardOutput=inherit
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable wallpaper
