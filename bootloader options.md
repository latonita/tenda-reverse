```
<RealTek>?
----------------- COMMAND MODE HELP ------------------
HELP (?)                 : Print this help message
DB <Address> <Len>
DW <Address> <Len>
EB <Address> <Value1> <Value2>...
EW <Address> <Value1> <Value2>...
CMP: CMP <dst><src><length>
IPCONFIG:<TargetAddress>
MEMCPY:<dst><src><length>
AUTOBURN: 0/1
LOADADDR: <Load Address>
J: Jump to <TargetAddress>
reboot
FLI: Flash init
FLR: FLR <dst><src><length>
FLW <dst_ROM_offset><src_RAM_addr><length_Byte> <SPI cnt#>: Write to SPI
MDIOR:  MDIOR phyid reg
MDIOW:  MDIOW phyid reg data
PHYR: PHYR <PHYID><reg>
PHYW: PHYW <PHYID><reg><data>
PHYPR: PHYPR <PHYID><page><reg>
PHYPW: PHYPW <PHYID><page><reg><data>
COUNTER: Dump Asic Counter
XMOD <addr>  [jump] 
TI : timer init 
T : test 
ETH : startup Ethernet
CPUClk: 
CP0
ERASECHIP
ERASESECTOR
SPICLB (<flash ID>) : SPI Flash Calibration
D8 <Address>
E8 <Address> <Value>
printenv
setenv <varname> <varvalue>
saveenv
FLERASE: erase flash from <offset> <size>
SFLTEST: spi flash test <offset> <size> <count>

<RealTek>printenv
image0_stats=0
image1_stats=0
image_boot=0
ipaddr=192.168.1.1
netmask=255.255.255.0
serverip=192.168.1.99

<RealTek>IPCONFIG
 Target Address=192.168.1.6

<RealTek>
```
