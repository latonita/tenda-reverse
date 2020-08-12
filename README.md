# tenda-reverse

## Preface

Lets say... just for fun.. i got 2 x 3-packs of tenda MW6 to cover big area (indoors and outdoors).
I had 3 of my MW6 backhauled with ethernet (actually, it is PLC bridge adapters).

In "default" configuration it works okay, however i already had good openwrt router and several devices/services set up.
By defaul, MW6 works in DHCP mode, creates 192.168.5.x subnet and puts everyone in there.
But this 1) brings extra NAT layer, 2) breaks my services.

So I decided to switch it to *bridge* mode, in which, according to manual, it shall turn off all its network services and just act as a bridge.

From the first glance it worked, but then I realized some of my devices got wrong IPs and then understood that "main" cube runs its own ~~luna park with blackjack and hookers~~ DHCP server.
There are absolutely no web administratoin page, only phone app. I see no ways to disable it from there. 

Nmap says DHCP server is running, and it intercepts all wifi clients and gives IP addresses from its pool.
And needless to say these addresses are wrong, not what I need.
Googled, found their support - same issue, however person says `dhcp authoritative='1'` on main openwrt router works for him, but it never worked for me. 

So I started investigation - how can I disable DHCP server.

# Network services
Few ports opened on the cube. nothing looks like telnet or ssh from the beginning, however after I connected to UART - I noticed that telnetd is starting up when you hold Reset button for 3 seconds (6 seconds brings back default settings).

## From LAN
```
PORT     STATE SERVICE                                                          
23/tcp   open  telnet      <--- opened only after you hold Reset for 3 seconds
5500/tcp open  hotline
9000/tcp open  cslistener
```
DHCP server is up
```
sudo nmap -sU -p 67 --script=dhcp-discover 192.168.5.1

Starting Nmap 7.60 ( https://nmap.org ) at 2019-07-18 20:04 MSK
Nmap scan report for _gateway (192.168.5.1)
Host is up (0.0027s latency).

PORT   STATE SERVICE
67/udp open  dhcps
| dhcp-discover: 
|   DHCP Message Type: DHCPACK
|   Server Identifier: 192.168.5.1
|   IP Address Lease Time: 23h30m42s
|   Subnet Mask: 255.255.255.0
|   Broadcast Address: 192.168.5.255
|   Router: 192.168.5.1
|   Domain Name Server: 192.168.5.1
|_  Domain Name: tendawifi.com
MAC Address: 04:95:E6:1A:96:E0 (Tenda Technology,Ltd.Dongguan branch)

Nmap done: 1 IP address (1 host up) scanned in 0.75 seconds

```

## From WAN
```
PORT     STATE  SERVICE
1723/tcp closed pptp
```
Closer examination of firmware required to understand what is opened and when.

## Trying to get in via telnet
I tried root/admin/support/user with admin/password/user/1234/12345678 passwords and some other.. no, not working.

# Hardware
Opening the cube is very straightforward. Out of interesting - UART socket and soic-8 SPI flash. Main chip closed by radiator - RealTek RTL8197F

![Tenda MW6 router board](https://github.com/latonita/tenda-reverse/raw/master/images/tenda-mw6-board-uart.png)


## UART - J4
115200 8n1. Starting from pin 1 (closer to SPI flash): VCC, RX, TX, GND.

## Memory chip
BOHONG BH25Q64 SPI Flash, 8MB. [Datasheet](http://www.hhzealcore.com/upload/201807/02/201807021644551022.pdf)

# Firmware
Firmware is not available on web. Phone app looks for that in tenda cloud and downloads itself. My cubes have latest firmware, so can't sniff over network where does it take new. Only i can say this app has its own protocol of communication with tenda cloud.

## Read flash chip
Unfortunately chip clamp didn't work, it powers up whole device and it starts communication with chip.
Desoldered it completely. Don't forget capton tape.
![Preparation to desolder chip](https://github.com/latonita/tenda-reverse/raw/master/images/prepare-to-desolder.jpg)

### How to read it, FTFS!
I'm not reading flash chips everyday and I don't own special programming device for this.
However I found FTDI FT2232H device, which I used as OpenOCD JTAG debugger for ESP32.
This chip has SPI mode and can work as master.
Pinout is taken from datasheet.

| FT2232H port | Function | Flash chip pin |
|--------------|----------|----------------|
| ADBUS0       | SCK      | 6 |
| ADBUS1       | MOSI     | 5 |
| ADBUS2       | MISO     | 2 |
| ADBUS3       | CS       | 1 |

Other flash chip pins 4 - GND, 8 - VCC 3.3v, 3 and 7 go to VCC.

![Wiring SPI chip to FT2232H](https://github.com/latonita/tenda-reverse/raw/master/images/ft2232h.jpg)

### Use flashrom
```
$ flashrom -p ft2232_spi:type=2232H,port=A
```
and it brings only sadness...
```
flashrom v0.9.9-r1954 on Linux 4.18.0-25-generic (x86_64)
flashrom is free software, get the source code at https://flashrom.org 
 
Calibrating delay loop... OK.
Found Generic flash chip "unknown SPI chip (RDID)" (0 kB, SPI) on ft2232_spi.
===
This flash part has status NOT WORKING for operations: PROBE READ ERASE WRITE 
The test status of this chip may have been updated in the latest development 
version of flashrom. If you are running the latest development version,
please email a report to flashrom@flashrom.org if any of the above operations
work correctly for you with this flash chip. Please include the flashrom log 
file for all operations you tested (see the man page for details), and mention 
which mainboard or programmer you tested in the subject line.
Thanks for your help!
No operations were specified.
```

## Arduinos and Espressif to the rescue
Looked around and found [site SKProj with sketch and .net app (in russian)](http://skproj.ru/programmator-spi-flash-svoimi-rukami/) which worked well for me to read chinese flash chip.

I used NodeMCU esp8266 board since it is 3.3v and I didn't want to think of 5v<>3v level conversion. 

**Important**: SPI chip shall be connected to HSPI pins `GPIO12-GPIO14` as per [official documentation](https://nodemcu.readthedocs.io/en/master/modules/spi/).

- There is `serprog` firmware for Arduinos which work with `flashrom`, but I couldn't quickly find its port for esp8266
![ESP8266 HSPI wiring](https://github.com/latonita/tenda-reverse/raw/master/images/esp8266-reader.jpg)

## Change flash chip to normal one
To make flashing easier I just bought couple Winbond W25Q64FV chips. They properly work with `flashrom` and I dont need to run Windows to flash chip. I wrote flash dump to new chip with 
```
flashrom -p ft2232_spi:type=2232H,port=A -w image.bin
```
Tenda bootloader detected new flash chip and started normally. 


# Firmware examination
Straight run of binwalk gives a lot of regular findings.
```
binwalk all.bin 

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
35096         0x8918          CRC32 polynomial table, little endian
36192         0x8D60          gzip compressed data, maximum compression, from Unix, last modified: 2018-04-20 02:17:42
206872        0x32818         LZMA compressed data, properties: 0x5D, dictionary size: 8388608 bytes, uncompressed size: 6890804 bytes
2261010       0x228012        Squashfs filesystem, little endian, version 4.0, compression:xz, size: 3071844 bytes, 378 inodes, blocksize: 131072 bytes, created: 1902-05-30 15:13:04
6160384       0x5E0000        JFFS2 filesystem, little endian
```

However with a hope to be able to glue it all back together I split flash image to 9 files according to MTD blocks in the bootlog with `dd`
```
flash vendor: BOHONG
m25p80 spi0.0: BH25Q64 (8192 Kbytes) (55000000 Hz)
m25p80 spi0.0: change speed to 55000000Hz, div 2
Kernel code size:0x1f8012
9 rtkxxpart partitions found on MTD device m25p80
Creating 9 MTD partitions on "m25p80":
0x000000000000-0x000000800000 : "ALL"
0x000000000000-0x000000020000 : "Bootloader"
0x000000020000-0x000000030000 : "CFG"
0x000000030000-0x0000005c0000 : "KernelFS"
0x000000228012-0x0000005c0000 : "RootFS"
0x0000005c0000-0x0000005d0000 : "CFM"
0x0000005d0000-0x0000005e0000 : "CFM_BACKUP"
0x0000005e0000-0x0000007f0000 : "LOG"
0x0000007f0000-0x000000800000 : "ENV"
```
Not clear for me why `KernelFS` and `RootFS` intersect according to MTD table.

## RootFS 
Just `unsquashfs` to unpack file system. Its busybox based.

cat `/etc/passwd`
```
root:$1$nalENqL8$jnRFwb1x5S.ygN.3nwTbG1:0:0:root:/:/bin/sh
```
cat `/etc/shadow`
```
root:$1$OVhtCyFa$7tISyKW1KGssHAQj1vI3i1:14319::::::
```
cat `/etc/inittab`
```
::sysinit:/etc_ro/init.d/rcS
ttyS0::respawn:/sbin/sulogin
::ctrlaltdel:/bin/umount -a -r
::shutdown:/usr/sbin/usb led_off
```

# First try to get in
First try was very naive: lets update `/etc/inittab` and put it back.

Changed `ttyS0::respawn:/sbin/sulogin` to `ttyS0::respawn:/bin/login -f root`

Updated the file, packed files to squshfs back - ooops, its larger than it was.
Examined compression - it was `XZ` originally, but `mksquashfs` used LZMA by default. 
Changed to XZ, now it is pretty same size and fits to RootFS MTD.
Padded newRootFS file with FF till it reached original MTD partition size.
Combined all the files back into on one image file, wrote to flash, booting...

```
Booting...
init_ram
 00000202 M init ddr ok

DRAM Type: DDR2
        DRAM frequency: 533MHz
        DRAM Size: 128MB
JEDEC id EF4017, EXT id 0x0000
found w25q64
flash vendor: Winbond
w25q64, size=8MB, erasesize=64KB, max_speed_hz=29000000Hz
auto_mode=0 addr_width=3 erase_opcode=0x000000d8
=>CPU Wake-up interrupt happen! GISR=89000004 
 
---Realtek RTL8197F boot code at 2018.04.20-10:17+0800 v3.4.11B.9 (999MHz)
Mac addr:04-95-e6-1a-96-e0
lan_wan_isolation Initing...
config: lan port mask is 0x000000f7
config: wan port mask is 0x000000e8
lan_wan_isolation Initing has been completed.
lan_wan_isolation Initing...
config: lan port mask is 0x000000f7
config: wan port mask is 0x000000e8
lan_wan_isolation Initing has been completed.
wait for upgrage
port[0] link:down
port[1] link:down
port[2] link:down
port[3] link:down
port[4] link:down
irq:0x00008080
rootfs checksum error at 00228012!
<RealTek>
```

## Fail!
How could I forget about CRC... I spent couple hours trying to find out proper way to calculate CRC - found RSDK, tried to understand image creation... too much for my brain for now.

Lets try something else.

# Second try
According to the boot log there is `netctrl` process which starts early and changes root password.
```
argv[0] = netctrl
netctrl
prod_change_root_passwd(83)
```
So lets do the hard way. Try to disassemble and reverse the code. Ouch. Never saw MIPS asm...

## Look for the files
Looking through the files found many of them are using `prod_change_root_passwd`, `netctrl` uses it and looks like the function itself defined in `/lib/libcommonprod.so`.

## Hard way with IDA PRO which I see first time in my life
Open `/bin/netctrl` in IDA. Open function `main`. It clears up buffers first, then reads `sys.role` parameter from configuration and depends on this either sleeps or calls external function `prod_change_root_passwd` without parameters.

![Netctrl main](https://github.com/latonita/tenda-reverse/raw/master/images/disasm-netctrl.png)

Open `/lib/libcommonprod.so`. Open function `prod_change_root_passw`. Also clears buffers first, then reads some parameters from config and calls `Encode64()` with value either `wl2g.ssid0.wpapsk_psk` or `TD_WLAN1_SSID0_PWD`.

And then just sets root password via command line `(echo %s;sleep 1;echo %s) | passwd root -a s> /dev/null`

![Set root password](https://github.com/latonita/tenda-reverse/raw/master/images/disasm-set-password.png)

**Voila!**

Calculated Base64 of my default password from the sticker, connected via serial...
```
Normal startupGive root password for system maintenance
(or type Control-D for normal startup):
System Maintenance Mode
~ #
~ # uname -a
Linux NOVA-xxxxxxxxxxxx 3.10.90 #4 Mon Jul 2 10:57:35 CST 2018 mips GNU/Linux
```
## I'm in
Basically nothing interesting to see here yet. No users except for the root is registered in the system.

```
~ # cat /proc/cpuinfo
system type             : RTL8197F
machine                 : Unknown
processor               : 0
cpu model               : MIPS 24Kc V8.5
BogoMIPS                : 666.41
wait instruction        : yes
microsecond timers      : yes
tlb_entries             : 64
extra interrupt vector  : yes
hardware watchpoint     : yes, count: 4, address/irw mask: [0x0ffc, 0x0ffc, 0x0ffb, 0x0ffb]
isa                     : mips1 mips2 mips32r2
ASEs implemented        : mips16
shadow register sets    : 4
kscratch registers      : 0
core                    : 1
VCED exceptions         : not available
VCEI exceptions         : not available

~ # ls -l /sys/class/gpio/
total 0
--w-------    1 root     root         16384 Jan  1  1970 export
lrwxrwxrwx    1 root     root             0 Jan  1  1970 gpio18 -> ../../devices/virtual/gpio/gpio18
lrwxrwxrwx    1 root     root             0 Jan  1  1970 gpio19 -> ../../devices/virtual/gpio/gpio19
lrwxrwxrwx    1 root     root             0 Jan  1  1970 gpio58 -> ../../devices/virtual/gpio/gpio58
lrwxrwxrwx    1 root     root             0 Jan  1  1970 gpiochip0 -> ../../devices/virtual/gpio/gpiochip0
--w-------    1 root     root         16384 Jan  1  1970 unexport

~ # ls -l /sys/devices/platform/
total 0
drwxr-xr-x    2 root     root             0 Jul 18 21:12 alarmtimer
drwxr-xr-x    2 root     root             0 Jul 18 21:12 rtl819x_8367r_i2c_pin.1
drwxr-xr-x    2 root     root             0 Jul 18 21:12 rtl819x_8367r_i2c_pin.2
drwxr-xr-x    2 root     root             0 Jul 18 21:12 rtl819x_8367r_reset_pin.0
drwxr-xr-x    2 root     root             0 Jul 18 21:12 rtl819x_btn.0
drwxr-xr-x    2 root     root             0 Jul 18 21:12 rtl819x_led.0
drwxr-xr-x    2 root     root             0 Jul 18 21:12 rtl819x_led.1
drwxr-xr-x    2 root     root             0 Jul 18 21:12 rtl819x_led.2
drwxr-xr-x    3 root     root             0 Jan  1  1970 serial8250
drwxr-xr-x    3 root     root             0 Jan  1  1970 spi-sheipa.0
-rw-r--r--    1 root     root         16384 Jul 18 21:12 uevent
```
And here are processes running
```
~ # ps
PID   USER     TIME   COMMAND
    1 root       0:01 init
    2 root       0:00 [kthreadd]
    3 root       0:40 [ksoftirqd/0]
    4 root       0:00 [kworker/0:0]
    5 root       0:00 [kworker/0:0H]
    6 root       0:01 [kworker/u2:0]
    7 root       0:00 [khelper]
    8 root       0:00 [kworker/u2:1]
   75 root       0:00 [writeback]
   78 root       0:00 [bioset]
   79 root       0:00 [crypto]
   81 root       0:00 [kblockd]
   84 root       0:01 [spi0]
  102 root       0:00 [kworker/0:1]
  106 root       0:00 [kswapd0]
  154 root       0:00 [fsnotify_mark]
  708 root       0:00 [mtdblock0]
  713 root       0:00 [mtdblock1]
  718 root       0:00 [mtdblock2]
  723 root       0:00 [mtdblock3]
  728 root       0:00 [mtdblock4]
  733 root       0:00 [mtdblock5]
  738 root       0:00 [mtdblock6]
  743 root       0:00 [mtdblock7]
  748 root       0:00 [mtdblock8]
  802 root       0:00 [deferwq]
  860 root       0:03 klogd -n
  862 root       0:00 monitor
  863 root       1:55 sh /usr/bin/ugw_watchdog.sh
  869 root       0:00 syslogd -f /var/etc/syslog.conf -s 50
  914 root       0:15 cfmd
 1030 root       0:00 [jffs2_gcd_mtd7]
 1032 root       0:11 timer
 1033 root       0:00 logserver
 1034 root       0:14 netctrl
 1069 root       0:01 device_list
 1071 root       3:20 sh /usr/bin/mesh_op.sh
 1530 root       0:10 pann
 1531 root       0:00 gpio_ctrl
 1532 root       0:00 mesh_status_check
 1534 root       0:19 network_check
 1570 root       0:00 redis-server /etc_ro/redis.conf
 1571 root       0:01 cmdsrv -l tcp://0.0.0.0:12598 -R tcp://127.0.0.1:6379
 1572 root       0:00 [kworker/0:1H]
 1573 root       0:05 confsrv
 1599 root       0:01 dhcps -C /etc/dhcps.conf -l /etc/dhcps.leases -x /etc/dhc
 1931 root       0:00 ucloud -l 4
 1962 root       0:00 sntp 1 28800 43200
 2370 root       0:00 ftd -br br0 -w wlan0 wlan1 -pid /var/run/ft.pid -c /tmp/f
 2375 root       0:00 pathsel -i wlan-msh -P -t 9
 2387 root       0:00 multiWAN
 2488 root       0:00 dhcpcd_wan1 -c /etc/wan1.ini -m 1 eth1 -h NOVA-0495e61a96
 2567 root       0:00 dnrd -t 3 -M 600 --cache=off -b -R /etc/dnrd -r 3 -s 192.
 2955 root       0:00 miniupnpd -f /etc/miniupnpd.config -w
 2991 root       0:00 igmpproxy
10388 root       0:00 -sh
12125 root       0:00 sleep 5
12155 root       0:00 sleep 1
12156 root       0:00 ps
```

# Access granted
I have root access to new Tenda MW6, that makes me happy since I hate having black boxes.

Root password is just your current wifi password, encoded with Base64.

# Disabling the DHCP server
(Thanks to [@Crees](https://github.com/crees) to finish DHCP research. Tested on MW5, but it has similar software)

The `cfm` utility can be discovered in the scripts in `/usr/sbin`, and is used to manipulate the parameters that persist across reboots (you can inspect the store directly with `cat /dev/mtd5`).

```
~ # cfm get ^dhcps
dhcps.Staticip1=
dhcps.Staticnum=0
dhcps.apmode.list1=1;br1;192.168.1.31;192.168.1.254;192.168.1.1;255.255.255.0;1440;192.168.1.66;192.168.1.70;host
dhcps.apmode.list2=1;br1;192.168.1.2;192.168.1.30;192.168.1.1;255.255.255.0;1440;192.168.1.66;192.168.1.70;dev
dhcps.en=1
dhcps.list1=1;br0;192.168.1.31;192.168.1.254;192.168.1.1;255.255.255.0;1440;192.168.1.1;;host
dhcps.list2=1;br0;192.168.1.2;192.168.1.30;192.168.1.1;255.255.255.0;1440;192.168.1.1;;dev
dhcps.listnum=2
dhcps.static.list1=1    14:DA:E9:38:EC:40       192.168.1.70
dhcps.static.listnum=1
```

Generally you'll need to set up port forwarding first, as otherwise the UI may not recognise your device.

For ```dhcps.listnum```, if you set it to 0, it does not write a /etc/dhcps.conf on reboot, thus disabling dhcps.

```
~ # cfm set dhcps.listnum 0
```

This will persist across reboots, and can be easily undone by changing dhcps.listnum back to its original value, and a factory reset will also reverse it.

# DMZ

You're only allowed 8 port forwarding rules in the app, which is pretty limiting.  Setting up a DMZ works (or you can also mess with the forwarding rules using cfm- the virtualser rules look pretty straightforward.

```
~ # cfm set wan1.dmzip ip.address.here
~ # cfm set wan1.dmzen 1
~ # reboot
```

# Next steps
Looks like many business logic is done in C/C++ and compiled (vs making a lot of scripts).
Another complication is no overlay fs, all mounted R/O except for `/dev/mtdblock7` on `/tmp/log/crash type jffs2 (rw,relatime)`- the settings are stored directly in `/dev/mtd5` and manipulated using `cfm`.


That was fun.


# Links
1. [Tenda Mesh3-18 (Nova MW6 2018) on wikidevi.com](https://wikidevi.com/wiki/Tenda_Mesh3-18_(Nova_MW6_2018))
2. [SPI Flash programmer by SKProj](http://skproj.ru/programmator-spi-flash-svoimi-rukami/)
3. [flashrom homepage](https://flashrom.org/Flashrom)
