# Wifi-Shepherd

![alt text](https://github.com/eaglefn/wifi-shepherd/blob/master/images/wifi-shepherd.jpg?raw=true)


## Description

The Wifi-Shepherd is a small tool based on Raspberry Pi Zero W which scans your local wifi network on a regular basis and notifies you by email, if it discovered a new device. The scan result is published on its own website. With its optional USB addon board you can simply use it on every device that provides power via its USB interface.  You can install Wifi-Shepherd in three steps:

## STEP 1:  Download Raspbian Light and write it to SD Card

Download the official operating system “Raspbian” from the product website. You just need the light version. Write the image to your SD Card using your preferred program. The Win32DiskImager will work for Windows. 

Create the following files on the boot partition:

* ssh – with no content
* wpa_supplicant.conf  – with information about your wifi network

```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
        ssid="your-SSID"
        scan_ssid=1
        psk="your-Password"
}
```

Check if you are able to ping your  Wifi-Shepherd and connect via ssh using the default password raspberry:

```
ssh pi@IP-Address
```

## Step 2: Configure Raspbian and download required software

Use the Raspberry Pi Software Configuration Tool (raspi-config) to change settings:

```
sudo raspi-config
```

1.	Change User Password 
2.	Check localization options and change time zone if necessary 
3.	See advanced option and expand filesystem to ensure that all of the SD card storage is available	


Upgrade the installed software:

```
sudo apt update && sudo apt upgrade
```

Install the required software packages:

```
sudo apt install nmap python apache2 ssmtp mailutils git
```

Download and install dependent software and scripts

```
cd /home/pi
git clone https://github.com/eaglefn/wifi-shepherd.git
cd wifi-shepherd
git clone https://github.com/maaaaz/nmaptocsv.git
chmod +x csvtohtml.sh wifi-shepherd.sh
```


## Step 3:  Configure Wifi-Shepherd and email settings

Open wifi-shepherd.sh with your preferred editor and make your settings:

```
# Make your settings here!
Wifi_Shepherd_Hostname="raspberrypi.lan"
Wifi_Network="192.168.1.0/24"
EmailReceiver="your@email.com"
```

Get a free email account or use your own SMTP server. Change settings in the following files. This is for GMX Freemail only!

/etc/ssmtp/ssmtp.conf

```
root=email@gmx.de
mailhub=mail.gmx.net:465
AuthUser=email@gmx.de
AuthPass=Passwort
UseTLS=YES
rewriteDomain=gmx.net
hostname=gmx.net
FromLineOverride=NO
```

/etc/ssmtp/revaliases

```
root:email@gmx.de:mail.gmx.net:465
pi:email@gmx.de:mail.gmx.net:465
```

To scan your wifi network on a regular basis, create a cronjob for the pi user:

```
crontab -e
```
e.g. this will scan your network every 10 minutes:

*/10 * * * * /home/pi/wifi-shepherd/wifi-shepherd.sh

## Copyright and license
Wifi-Shepherd is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Wifi-Shepherd  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with nmaptocsv. If not, see http://www.gnu.org/licenses/.

## Credits

I'm using Thomas D. brilliant  script nmaptocsv https://github.com/maaaaz/nmaptocsv to convert nmap output to a csv file. Thanks! @maaaaz

DataTables https://www.datatables.net are used to enhance the accessibility of data in HTML tables.


## Links

You will find more information (German language only) on pentestit.de https://pentestit.de/wifi-shepherd-teil-1-installieren-und-einrichten/
