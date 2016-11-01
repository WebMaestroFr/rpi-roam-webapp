This is a web application that lets you wirelessly connect your Raspberry Pi to available networks through a slick UI, and that bridges it all from your adapter to the casted access point.

# Installation

You need a Raspberry Pi 3 and an WiFi adapter (or a lower version and a second adapter, but I haven’t tried). For initial setup, you will need to wire your Pi to your router. So get a cable also.

## Raspbian

You probably want to start from a fresh image. Start by downloading a last release of Raspbian : https://www.raspberrypi.org/downloads/raspbian/.

Then plug your SD card in, and (from OSX) spot it with `diskutil list`.
```shell
$ diskutil list
...
/dev/disk2 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *16.1 GB    disk2
   1:             Windows_FAT_32 boot                    66.1 MB    disk2s1
   2:                      Linux                         16.0 GB    disk2s2
```
Here my SD card is at `/dev/disk2`, so I'll remember the number **2** and call it **N** since you geeks may not have the same.

Then, using this number, we're going to unmount the disk. Use your own **N**, don't just copy `diskutil unmountDisk /dev/diskN`.
```shell
$ diskutil unmountDisk /dev/disk2
Unmount of all volumes on disk2 was successful
```

Now burn ! `sudo dd bs=1m if=path/to/raspbian-jessie.img of=/dev/rdiskN`, with your own **N** and **path to image** obviously.
```shell
$ sudo dd bs=1m if=2016-09-23-raspbian-jessie-lite.img of=/dev/rdisk2
Password:
1325+0 records in
1325+0 records out
1389363200 bytes transferred in 123.325735 secs (11265801 bytes/sec)
```

Unmount your SD card once again before taking it out, with `diskutil unmountDisk /dev/diskN`.
```shell
$ diskutil unmountDisk /dev/disk2
Unmount of all volumes on disk2 was successful
```

Okay, we're ready. Slide the SD card in, and plug your Pi's ethernet and power.


## SSH

Now SSH with `ssh pi@raspberrypi.local`.
```shell
$ ssh pi@raspberrypi.local
...
Are you sure you want to continue connecting (yes/no)? yes
...
pi@raspberrypi.local\'s password:
...
pi@raspberrypi:~ $
```

## Clone this repo
