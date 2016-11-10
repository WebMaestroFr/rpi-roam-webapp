This is a web application that wirelessly connects your Raspberry Pi to available WiFi networks, through a slick UI that bridges it all to an access point.

![Screenshot](screenshot.jpg)

# Installation

You will need a Raspberry Pi 3 and an extra WiFi adapter. For initial setup, you will need to wire your Pi to your router, so get a cable also.

I consider that your Pi is up and running a fresh image of Raspbian. If not, please follow [this installation guide](https://www.raspberrypi.org/documentation/installation/installing-images/README.md).

Plug it in and turn it on, let's go !

Once you downloaded this repository, use "secure copy" to push the application directory onto the Pi.
```
$ scp -r path/to/rpi-roam-webapp/roam pi@raspberrypi.local:.
```

Now take control of your Pi with SSH.
```
$ ssh pi@raspberrypi.local
```

I'm going to ask you to `sudo bash`. And because you're smart enough, you're going to go on and read [that script](https://github.com/WebMaestroFr/rpi-roam-webapp/tree/master/roam/setup.sh) first. Once you understand more or less each step of the setup process, you should decide to trust me and continue. The point here is : don't just `sudo bash` the first script you come across the internet kid, some can be stupid or dangerous.

The script will ask you for some information.
- **Access Point Name** : The SSID, basically the name of our Pi's WiFi. (default: *Raspberry Pi*)
- **Access Point Password** : The passkey of our Pi's WiFi. [Pick it well](https://strongpasswordgenerator.com/) ! (default: *raspberry*)
- **Access Point Interface** : You should probably keep "wlan0". I didn't experiment much with this, but I invite you to. (default: *wlan0*)
- **Adapter Interface** : Your WiFi receiver. (default: *wlan1*)
- **Host Name** : The *.local* address of the Pi. (default: *raspberrypi*)
- **Local Network Address** : "192.168.0" or whatever, just make sure you follow this IP format: three levels only ! (default: *10.0.0*)
- **Application Port** : The port to run the application on. (default: *80*)
- **Application Name** : The title to give to the application page... (default: *Raspberry Pi*)
- **Connection Process Interval** : Interval inbetween each "auto" connection attempt, in minutes. (default: *2*)

```
pi@raspberrypi:~ $ sudo bash roam/setup.sh
```
It may take some time since it runs `apt-get install` & `apt-get update`.

Once done, your Pi will reboot.

Unplug the ethernet wire.

From your computer now, select and connect to your *Access Point* in the list of available WiFi networks. In your browser, go to your *.local* host (`http://raspberrypi.local:80` by defaults)... and here you go ! Ready to set up your WiFi !

Once connected to any network, your Pi will bridge it to you.
