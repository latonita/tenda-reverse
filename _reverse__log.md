

# put new squshfs to image. CRC failure
got 
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
<RealTek>help
Unknown command !
```
# realtek boot commmands
http://blog.jbit.net/ 

# need to find whole image structure

MDT blocks doest have partition tables. instead partitions are defined in kernel.
https://bootlin.com/blog/managing-flash-storage-with-linux/


https://reverseengineering.stackexchange.com/questions/13948/how-to-find-bootloader-load-address


## Realtek SDK
need to find realtek sdk, here is someone 
https://jyhshin.pixnet.net/blog/category/2031772  
https://jyhshin.pixnet.net/blog/post/48854277

https://github.com/mzpqnxow/realtek-mips-sdks 




