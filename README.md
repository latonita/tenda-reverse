# tenda-reverse

## history

Lets say... just for fun.. i got 2x3-packs of tenda MW6 to cover big area (indoors and outdoors).
I had 3 of my MW6 backhauled with ethernet (actually, it is PLC bridge adapters).

In "default" configuration it works okay, however i already had good openwrt router and several devices/services set up.
By defaul, MW6 works in DHCP mode, creates 192.168.5.x subnet and puts everyone in there.
But this 1) brings extra NAT layer, 2) breaks my services.

So I decided to switch it to "bridge" mode, in which, according to manual, it shall turn off all its network services and just act as a bridge.

From the first glance it worked, but then i realized some of my devices got wrong IPs and then understood that "main" cube runs its own lunapark with blackjack... I mean it runs DHCP server.
There are absolutely no web config, only phone app. No ways to disable it there. 

Nmap says DHCP server is running, and it intercepts all wifi clients and gives IP addresses from its pool.
And needless to say these addresses are wrong, not what I need.
Googled, found their support - same issue, however person says `dhcp authoritative='1'` on main openwrt router works for him, but it never worked for me. 

So I started investigation - how can I disable DHCP server.

# Network services
Few ports opened on the cube. nothing looks like telnet or ssh.
## Reset button - telnetd
This came after UART research.
Holding reset button for 3 seconds brings up telnetd!
However hard to get in. root/admin/support/user do not work with admin/password/user/1234/12345678 passwords and some other I tried.

# Hardware
Opening the cube is very straightforward. Of interesting - UART socket and soic-8 SPI flash.

## UART - J4
115200 8n1

## Memory chip
BOHONG BH25Q64 SPI Flash, 8MB

# Firmware
Is not available on web. Phone app looks for that in tenda cloud and downloads itself. My cubes have latest firmware, so can't sniff over network where does it take new. Only i can say this app has its own protocol of communication with tenda cloud.

## Read flash chip
Unfortunately chip clamp didn't work, it powers up whole device and it starts communication with chip.
Desoldered it completely.

## How to read it, FTFS!
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

## Use flashrom
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

