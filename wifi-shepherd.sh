#!/bin/sh
# Title: Wifi-Shepherd based on Raspberry Pi Zero W
# Author: Pentestit.de, Frank Neugebauer
# Version: 0.1 - 2020/04/20
#
# Wifi Shepherd scans your Wifi network and sneds an email with new devices found
# For more information see https://pentestit.de
#
# To run this scpript permanently create a conjob using "crontab -e"
# Runs Wifi Shepherd every 10 minutes -  */10 * * * * sudo /home/pi/wifi-shepherd.sh
# Runs Wifi Shepherd every day at 8:00  and at 17:00 -  0 8,17 * * * sudo /home/pi/wifi-shepherd.sh
#------------------------------------------------------------------------------------------------------
# Make your settings here!
Wifi_Shepherd_Hostname="raspberrypi.lan"
Wifi_Network="192.168.171.0/24"

#MessageText="Alert! Wifi Shepherd found the following new devices in your network!"
MessageText="Achtung! Wifi Shepherd hat folgende neuen Geräte in Ihrem Netzwerk gefunden!"
EmailReceiver="frank@fnol.de"


# Don't change unless you know what you are doing.
Wifi_Shepherd_DIR="/home/pi/wifi-sheperd"
Nmaptocsv_DIR="$Wifi-Shepherd_DIR"/nmaptocsv"
Webserver_DIR="/var/www/html"

Nmapoutput_FILE="nmap.raw"
Nmapcsv_FILE="nmap.csv"

MacDetected_FILE="mac_detect.txt"
MacKnown_FILE="mac_known.txt"
MacDiff_FILE="mac_diff.txt"

#----------------------------------------------------------------------------------------------------

#Optional - Disable next line to change sender name in email
#usermod -c "Wifi Shepherd" root

#Start nmap scan and save the output to nmap.raw
#Exclude Wifi-Shepherd Hostname from scan
cd  "$Wifi_Shepherd_DIR"
nmap -sP  --exclude "$Wifi_Shepherd_Hostname" -oN  "$Wifi_Shepherd_DIR$Nmapoutput_FILE"  "$Wifi_Network" >/dev/null 2>&1

#Convert  nmap.raw output to csv file
#See https://github.com/maaaaz/nmaptocsv for more information
python "$Nmaptocsv_DIR"/nmaptocsv.py -i "$Nmapoutput_FILE"  -d ";" -n -f ip-fqdn-mac_address-mac_vendor > "$Nmapcsv_FILE"

# remove "" from  csv file
cat  nmap.csv | sed 's/"//g' > nmap.tmp

# copy html header to Webserver index.html
cat html_head.txt > "$Webserver_DIR/index.html"

#convert csv file to html and copy it to Webserver index.html
./csvtohtml.sh nmap.tmp >>  "$Webserver_DIR/index.html"

#Take csv file and cut Mac-Addresses, store it to MacDetected
cat "$Nmapcsv_FILE"  | sed '1,1d' | cut -d ";" -f 3 > "$MacDetected_FILE"

#Check if we alrady have MacAddresses collected
testfile="$Wifi_Shepherd_DIR$MacKnown_FILE"
if ! [ -f "$testfile" ];then
      touch "$Wifi_Shepherd_DIR$MacKnown_FILE"
fi

#Compare detected MAC with known MAC and store differences in separate file (mac_diff.txt)
grep -Fxvf "$MacKnown_FILE" "$MacDetected_FILE" > "$Wifi_Shepherd_DIR$MacDiff_FILE"

#Find new devices in csv file and prepare E-Mail attachment message.txt
while read line; do grep $line "$Nmapcsv_FILE" ;done < "$MacDiff_FILE" > message.txt

#Add MAC-Addresses found to known MAC-Addresses
cat  "$MacDiff_FILE" >> "$MacKnown_FILE"

#Send email with alert if message.txt not empty

if [ -s message.txt ];
	then mail -s "$MessageText" "$EmailReceiver" < message.txt;
fi

