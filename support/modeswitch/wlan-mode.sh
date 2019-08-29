#!/bin/bash

# Switch spink WLAN configuration (AP Mode / Client Mode)
# inital script by lucky lucas :) thanks
# GPIO 23 is from button 1 - press starts AP Mode
# GPIO 24 is from button 3 - does nothing
# GPIO 25 is from button 2 - press starts Client mode

# adaptation from spink to TerminalTedium - sera 04.06.2018

# Global variables
wlan_mode="none"

ap_mode(){
  echo "Starting $wlan_mode mode"
  sudo killall wpa_supplicant
  sudo killall hostapd
  sudo dhclient -4 -r wlan0
  sleep 1
  sudo ip route flush table main
  sleep 1
  sudo ip route flush table main
  sleep 1
  sudo ifconfig wlan0 0.0.0.0
  sudo ifconfig wlan0 10.5.5.1/27
  sudo hostapd /etc/hostapd/hostapd.conf &
  sleep 2
  sudo service isc-dhcp-server start
  timeout 5s python /home/pi/Adafruit_Python_SSD1306/examples/stats.py
}

client_mode(){
  echo "Starting $wlan_mode mode"
  sudo killall wpa_supplicant
  sudo service isc-dhcp-server stop
  sudo killall hostapd
  sudo dhclient -4 -r wlan0
  sudo ifconfig wlan0 0.0.0.0
  sleep 1
  sudo ip route flush table main
  sudo ip route flush table main
  sleep 1
  sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
  sleep 4
  sudo dhclient -4 -r wlan0
  sudo dhclient -4 -r wlan0
  sudo dhclient -4 -r wlan0
  sudo dhclient -4 -v wlan0
  sleep 1
  timeout 5s python /home/pi/Adafruit_Python_SSD1306/examples/stats.py
}
kill_mode(){
  echo "Starting $wlan_mode mode"
  sudo killall pd
  sleep 1
  timeout 5s python /home/pi/Adafruit_Python_SSD1306/examples/stats.py
}

#switch_mode(){
#}

setup (){
  echo "Setup"
  counter=1
# set modes for button 1 2 3  - to input with internal pull ups enabled
  gpio mode 4 in
  gpio mode 4 up
  gpio mode 6 in
  gpio mode 6 up
  gpio mode 5 in
  gpio mode 5 up

  # also set the led above button 3 as GPIO output pin.
  gpio mode 25 out
}

setup

# gpio 23 / button 1
# gpio 25 / button 2
while :
do
        # read the run/stop button state
        ap_mode_btn=$(gpio read 4)
        client_mode_btn=$(gpio read 6)
        kill_mode_btn=$(gpio read 5)

        if [ $ap_mode_btn -eq 0 ]; then
          echo $counter
	  ((counter++))
          if [ $counter -gt 7 ]; then
	    wlan_mode="ap"
            gpio write 25 1
            ap_mode
            gpio write 25 0
	    echo "switched to ap mode" >> /var/log/messages
  	    counter=1
          fi

        elif [ $client_mode_btn -eq 0 ]; then
          echo $counter
          ((counter++))
          if [ $counter -gt 7 ]; then
	    wlan_mode="client"
            gpio write 25 1
	    client_mode
	    gpio write 25 0
	    echo "switched to client mode" >> /var/log/messages
            counter=1
          fi

        elif [ $kill_mode_btn -eq 0 ]; then
          echo $counter
          ((counter++))
          if [ $counter -gt 7 ]; then
        wlan_mode="kill"
            gpio write 25 1
        kill_mode
        gpio write 25 0
        echo "switched to kill mode" >> /var/log/messages
            counter=1
          fi

        else
            counter=1
        fi
        sleep 0.7
done
