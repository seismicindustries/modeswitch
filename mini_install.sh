#!/bin/bash

echo " installing apache from apt repository"
sudo apt-get install apache2

cho " installing hostapd from apt repository"
sudo apt-get install hostapd


echo ""
echo ""
echo ""
echo -e "[ \033[1m\033[96mdude\033[m ] Install wlan mode switching script into systemctl's realms -------------"
echo ""
    sudo mkdir /opt/si
    sudo mkdir /opt/si/modeswitch
    sudo cp support/modeswitch/wlan-mode.sh /opt/si/modeswitch/.
    sudo cp support/modeswitch/wlan-mode.service /etc/systemd/system/.
    sudo systemctl daemon-reload
    sudo systemctl enable wlan-mode.service
echo ""
echo ""
echo ""
echo -e "[ \033[1m\033[96mdude\033[m ] Update device configuration -------------------------------------------"
    sudo cp --backup=numbered support/hostapd.conf /etc/hostapd/.
    sudo cp -r support/html/* /var/www/html/.


echo -e "[ \033[1m\033[96mdude\033[m ] Installation completed, please reboot now."
