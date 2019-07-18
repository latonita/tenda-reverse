Началось всё с того, что польстившись на распродажу и новые buzz words - я приобрел wifi mesh систему, дабы покрыть все уголки загородного дома и прилегающего участка. Все бы ничего, но одна проблема раздражала. А с учетом того, что я сел на больничный на несколько дней - довела меня до root доступа к данному роутеру.

![КДПВ](https://habrastorage.org/webt/47/b6/em/47b6emgsl6psfjyc_j-rotkpln8.png)

<cut />

# Проблема
Ради интереса, приобрел два набора по три кубика [Tenda Nova MW6](https://www.tendacn.com/ru/product/mw6.html) - система для организации wifi mesh для чайников. С возможностью ethernet backhaul, т.е. соединения некоторых блоков друг с другом по проводам, ибо данная коробочка является чуть-ли не самой дешевой wifi mesh (дешевле, по-моему, только их же MW3) и она не имеет третьего выделенного радиотракта для внутренней коммуникации между блоками (как у некоторых дорогих коллег - Netgear Orbi).
В целом, огромной нужды не было, но пара роутеров под OpenWrt не покрывали всех нужных мест.

<spoiler title="Кто такой mesh, и зачем он нужен">
Mesh - это топология построения сетей, характеризующаяся высокой отказоустойчивостью и динамичностью. 
Не буду вдаваться в подробности, так как многие в курсе, а кто нет - можно начать со [статьи про Ячеистую топологию на wikipedia](https://ru.wikipedia.org/wiki/%DF%F7%E5%E8%F1%F2%E0%FF_%F2%EE%EF%EE%EB%EE%E3%E8%FF). 

Основная задача "домашней" wifi mesh сети — это покрыть большую площадь стабильным беспроводным сигналом с бесшовным роумингом.

Бесшовный роуминг можно и на access points и на домашних роутерах включить (например с openwrt - путем замены wpad-mini на wpad и включению 802.11r). А стабильный сигнал на большой площади от пары точек не получить - то пусто, то густо  - при этом сильно засоряешь эфир, если повышаешь мощность. Нужно больше точек - несколько точек 5G будет намного эффективнее. Но на обычных access points/routers ты еще будешь думать, как провод к ним подвести, а mesh на то и mesh, чтобы сама себя поддерживать и налаживать связи как при наличии, так и без наличия провода (backhaul).

Вообщем, технология для удобства жизни. Это хорошо.
</spoiler>

Завелась система с первого раза, сама настроилась, всё окей. Поиграв с их фичами в приложении (а классической веб-мордочки не предусмотрено, теперь всё только через приложения для телефона и китайские облака...) решил перевести в сеть в режим моста, ибо есть разные устройства уже настроенные как надо и Главный роутер много чего делает.

Сутки всё работало хорошо, потом начал замечать, что то к одному хосту, то к другому нет доступа. В админке OpenWrt в списке выделенных адресов - пара хостов, остальных нет. Сканирую сеть - хосты на месте, только адреса у них не те, что были зафиксированы. Начинаю подозревать - сканирую "главный кубик" MW6 - так и есть, на нем крутится DHCP сервер.

<spoiler title="sudo nmap -sU -p 67 --script=dhcp-discover 192.168.5.111">
```

Starting Nmap 7.60 ( https://nmap.org ) at 2019-07-18 20:04 MSK
Nmap scan report for _gateway (192.168.5.111)
Host is up (0.0027s latency).

PORT   STATE SERVICE
67/udp open  dhcps
| dhcp-discover: 
|   DHCP Message Type: DHCPACK
|   Server Identifier: 192.168.5.111
|   IP Address Lease Time: 23h30m42s
|   Subnet Mask: 255.255.255.0
|   Broadcast Address: 192.168.5.255
|   Router: 192.168.5.1
|   Domain Name Server: 192.168.5.1
|_  Domain Name: tendawifi.com
MAC Address: 04:95:E6:1A:96:E0 (Tenda Technology,Ltd.Dongguan branch)

Nmap done: 1 IP address (1 host up) scanned in 0.75 seconds
```
</spoler>

Поддержка у Tenda только де-юро. Де-факто никто ни на что не отвечает. Русская поддержка в контакте хоть и отвечает, но абсолютно не адекватна и не умеет слушать клиентов.

Беглый гуглинг подсказал, что на всякий случай надо бы на Главном роутере поставить `dhcp authoritative='1'`, но это не помогло. И тут я начал думать, как отключить DHCP сервер на этих кубиках. Выделил один кубик для игр, сбросил его настройки и - понеслась.

# Сетевые сервисы
Несколько портов открыто, сильно не копал, просто `nmap <host>`. Подозреваю, что есть и бэкдоры для китайских облаков, но пока их не искал. С ходу ничего полезного не видно. А не с ходу - после подключения к консоли по UART захотел сбросить настройки кубика и выяснил, что после 3 секунд нажатия на reset - запускается telnet сервер.

<spoiler title="Вид из LAN">
```
PORT     STATE SERVICE                                                          
23/tcp   open  telnet
5500/tcp open  hotline
9000/tcp open  cslistener
```
</spoiler>

<spoiler title="Вид из WAN">
```
PORT     STATE  SERVICE
1723/tcp closed pptp
```
</spoiler>

## Зайдем-ка в telnet
Ну тут не сильно нам удача улыбалась - всякие стандартные логины/пароли по-перебирал - не подошли. Пробовал root/admin/support/user и пароли из "интернетов" - password, root, toor, admin, support, tenda, 1234, 12345678 и т.д. Пароль от wifi сети тоже пробовал.

# Железяки
Кубик открывается легко и непринужденно, шурупы, как обычно, под ножками. Скрытых шурупов нет. Внутри ~~собаки~~ кубика - пустота. Пара плат и пара микро антенн. Ничего интересного, как и везде в 99% случаев. 

Повезло с UART - единственный коннектор оказался им. Флэшка прямо по середине. На другой стороне платы ничего нет, кроме радиатора.

![Внутренний мир](https://habrastorage.org/webt/iy/a6/y3/iya6y3hmocef5mix-qq1gvsvkmy.png)

## UART
Разъем J4. Распиновка, начиная с первой ноги: VCC (3.3), TX, RX, GND. Первый нога - которая ближе всего к флешке. Настройки UART тоже угадались с первой попытки - 115200, 8n1.

<spoiler title="А вот и долгожданный bootlog. Для ценителей.">
```
Booting...
init_ram
 00000202 M init ddr ok

DRAM Type: DDR2
        DRAM frequency: 533MHz
        DRAM Size: 128MB
JEDEC id 684017, EXT id 0x6840
found BH25Q64
flash vendor: BOHONG
BH25Q64, size=8MB, erasesize=64KB, max_speed_hz=55000000Hz
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
Jump to image start=0x80a00000...
decompressing kernel:
Uncompressing Linux... done, booting the kernel.
done decompressing kernel.
start address: 0x80466860
Linux version 3.10.90 (root@linux-bkb8) (gcc version 4.4.7 (Realtek MSDK-4.4.7 Build 2001) ) #4 Mon Jul 2 10:57:35 CST 2018
CPU revision is: 00019385 (MIPS 24Kc)
Determined physical RAM map:
 memory: 08000000 @ 00000000 (usable)
Zone ranges:
  Normal   [mem 0x00000000-0x07ffffff]
Movable zone start for each node
Early memory node ranges
  node   0: [mem 0x00000000-0x07ffffff]
Primary instruction cache 64kB, VIPT, 4-way, linesize 32 bytes.
Primary data cache 32kB, 4-way, PIPT, no aliases, linesize 32 bytes
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 8176
Kernel command line:  console=ttyS0,115200
PID hash table entries: 512 (order: -3, 2048 bytes)
Dentry cache hash table entries: 16384 (order: 2, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 1, 32768 bytes)
Writing ErrCtl register=00029693
Readback ErrCtl register=00029693
Memory: 103744k/131072k available (4526k kernel code, 27328k reserved, 2031k data, 224k init, 0k highmem)
SLUB: HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
NR_IRQS:192
Realtek GPIO IRQ init
Calibrating delay loop... 666.41 BogoMIPS (lpj=3332096)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 2048
NET: Registered protocol family 16
<<<<<Register PCI Controller>>>>>
Do MDIO_RESET
40MHz
Find PCIE Port, Device:Vender ID=b82210ec
Realtek GPIO controller driver init
INFO: registering sheipa spi device
bio: create slab <bio-0> at 0
INFO: sheipa spi driver register
INFO: sheipa spi probe
***spi max freq:100000000
Switching to clocksource MIPS
NET: Registered protocol family 2
TCP established hash table entries: 2048 (order: 0, 16384 bytes)
TCP bind hash table entries: 2048 (order: -1, 8192 bytes)
TCP: Hash tables configured (established 2048 bind 2048)
TCP: reno registered
UDP hash table entries: 1024 (order: 0, 16384 bytes)
UDP-Lite hash table entries: 1024 (order: 0, 16384 bytes)
NET: Registered protocol family 1
squashfs: version 4.0 (2009/01/31) Phillip Lougher
jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
msgmni has been set to 202
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered (default)
Serial: 8250/16550 driver, 1 ports, IRQ sharing disabled
serial8250: ttyS0 at MMIO 0x18147000 (irq = 17) is a 16550A
console [ttyS0] enabled
Realtek GPIO to I2C Driver Init...
mfi_ioctl_init:565,dev=253,MINOR=0
loop: module loaded
m25p80 spi0.0: change speed to 15000000Hz, div 7
JEDEC id 684017
m25p80 spi0.0: found BH25Q64, expected m25p80
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
PPP generic driver version 2.4.2
PPP MPPE Compression module registered
NET: Registered protocol family 24
PPTP driver version 0.8.5
Realtek WLAN driver - version 1.7 (2015-10-30)(SVN:exported)
Adaptivity function - version 9.3.4
Do MDIO_RESET
40MHz
Find PCIE Port, Device:Vender ID=b82210ec

 found 8822B !!! 
halmac_check_platform_api ==========>
12089M
HALMAC_MAJOR_VER = 0
HALMAC_PROTOTYPE_VER = 0
HALMAC_MINOR_VER = 0
halmac_init_adapter_88xx ==========>
halmac_init_adapter Succss 
IS_RTL8822B_SERIES value8 = a 
MACHAL_version_init


#######################################################
SKB_BUF_SIZE=8432 MAX_SKB_NUM=1024
#######################################################

MACHAL_version_init
RFE TYPE =5


#######################################################
SKB_BUF_SIZE=3032 MAX_SKB_NUM=400
#######################################################

RFE TYPE =5
RFE TYPE =5
RFE TYPE =5
RFE TYPE =5
--- link_loop_init ---
mesh_extend_init over...
--- hybrid_steering_init ---
u32 classifier
nf_conntrack version 0.5.0 (1621 buckets, 6484 max)
[BM CORE     ][init_online_ip  ,1053]  INFO: online ip data hash table created, size = 199
[BM CORE     ][init_online_ip_procfs,647 ]  INFO: online_ip proc file created
ipip: IPv4 over IPv4 tunneling driver
gre: GRE over IPv4 demultiplexor driver
ip_gre: GRE over IPv4 tunneling driver
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP: cubic registered
NET: Registered protocol family 17
l2tp_core: L2TP core driver, V2.0
l2tp_ppp: PPPoL2TP kernel driver, V2.0
8021q: 802.1Q VLAN Support v1.8
Realtek FastPath:v1.03

Probing RTL819X NIC-kenel stack size order[0]...
link_send_msg_timer_func:lan_dev = NULL
[Rtl83xx Ethernet Driver][RTL83XX_vlan_set][901]: failed!(0x3)
eth0 added. vid=9 Member port 0x2...
eth1 added. vid=8 Member port 0x8...
[peth0] added, mapping to [eth1]...
VFS: Mounted root (squashfs filesystem) readonly on device 31:4.
Freeing unused kernel memory: 224K (80668000 - 806a0000)
mkdir: can't create directory '/var/run': File exists
[BM CORE     ][bm_init         ,857 ]  INFO: bm_init success
[BM CORE     ][bm_u2k_info_init,1149]  INFO: bm_u2k_info_init success
[MAC FILTER  ][mf_init         ,683 ]  INFO: bm_mac_filter init success 
*TBQ* tbq_token_ctrl size:   40
*TBQ* tbq_user size:         68
*TBQ* tbq_user_sched size:   2192
*TBQ* tbq_bucket size:       56
*TBQ* tbq_bucket_sched size: 1796
*TBQ* tbq_flow_track size:   228
*TBQ* tbq_user_track size:   4412
*TBQ* tbq_backlog size:      24
*TBQ* tbq_flow_backlog size: 36
*TBQ* nos_flow_track size:   12
*TBQ* nos_user_track size:   28
*TBQ* nf_conn size:          624
*TBQ* sk_buff size:          232
*TBQ* TBQ_BACKLOG_PACKETS_MAX:  1000000
*TBQ* TBQ_LATENCY_SHIFT_MAX:    10
*TBQ* TBQ_DISABLE_TIMEOUT_MAX:  60
*TBQ* HZ: 100
*TBQ* init_user_tbq_hash_table ok
*TBQ* nos_tbq_init() OK
Give root password for system maintenance
(or type Control-D for normal startup):argv[0] = cfmd
cfmd
cfms_apmib_init:line(475)
Read hw setting header failed!

 flash_mib_compress_write DEFAULT_SETTING DONE, __[flash.c-6988]
 flash_mib_compress_write CURRENT_SETTING DONE, __[flash.c-7057]
 DEFAULT_SETTING hecksum_ok

 CURRENT_SETTING hecksum_ok

  __[flash.c-7211]setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
setMIB end...
argv[0] = timer
timer
argv[0] = logserver
logserver
argv[0] = netctrl
netctrl
prod_change_root_passwd(83)
link_send_msg_timer_func:lan_dev = NULL
insmod: can't insert '/lib/modules/phy_check.ko': File exists
/bin/sh: can't create /proc/sw_nat: Permission denied
src/common_hal.c hal_init_bridge
device eth0 entered promiscuous mode
br0: port 1(eth0) entered listening state
br0: port 1(eth0) entered listening state
netctrl_main.c,netctrl_init_vlan_ports,1207,: Set br0 to 04:95:e6:1a:96:e0.
Sun May  1 00:00:00 UTC 2011
argv[0] = device_list
device_list
argv[0] = tendaupload
tendaupload
argv[0] = sh
argv[1] = /usr/bin/mesh_op.sh
sh

######## STARTING PROGRAM #########
######## RECEIVING DATA #########
RTNETLINK answers: Operation not supported
check timer start success
RTNETLINK answers: No such file or directory
[MAC FILTER  ][mf_apply        ,232 ]  INFO: g_mac_filter_enable = disable, mf_default_action = accept
[MAC FILTER  ][mf_apply        ,232 ]  INFO: g_mac_filter_enable = disable, mf_default_action = accept
Init gsbmac dev success.
The ARP attack defence is init v1 successful
Interface doesn't accept private ioctl...
td_ssid_hide (8BDC): Operation not permitted
Interface doesn't accept private ioctl...
td_ssid_hide (8BDC): Operation not permitted
open /dev/gsbmac failure.
open /dev/gsbmac failure.
br0: port 1(eth0) entered learning state
Kernel:Init attack fence dev success.
the ddos ip attack defnence init successful
SET_LAN_PARAM_DATA k_data:
        lan ip:3232236801
        lan mask:4294967040
        lan submask:3232236800
        lan interface:br0
        lan http port:0
set the proceee ture
SET_IPOP_FENCE_ATTACK_DATA k_data:
        ip options:32512
SET_BAD_PKT_FENCE_ATTACK_DATA k_data:
        bad pkt:248
SET_DDOS_FENCE_ATTACK_DATA k_data:
        status:7
        tcp threshold:1500
        udp threshold:1500
        icmp threshold:1500
ready___djc___close____guest____wifi_close_guest(4617)
djc___close____guest____wifi_close_guest(4623)
config changed,CRC:old[3cbf4591],new[3d7bd411]
mib_nvram_cfm_commit 1608: write mibvalue success
write config to flash......ok
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
/bin/sh: wlanapp.sh: not found
device wlan1 entered promiscuous mode
WlanSupportAbility = 0x3
available channels[US]: 1 2 3 4 5 6 7 8 9 10 11 
br0: topology change detected, propagating

br_topology_change_detection, clear br0 fdb ...
br_topology_change_detection, clear shortcut cache...
br0: port 1(eth0) entered forwarding state
MDID is null !!, set default MDID
[ODM_software_init] 
[97F] Bonding Type 97FS, PKG1
[97F] RFE type 5 PHY paratemters: GPA1+GLNA1
clock 40MHz
load efuse ok
rom_progress: 0x200006f
rom_progress: 0x400006f
[GetHwReg88XX][PHY_REG_PG_8197Fmp_Type5] size
[GetHwReg88XX][PHY_REG_PG_8197Fmp_Type5]
[GetHwReg88XX][rtl8197Ffw]
[GetHwReg88XX][rtl8197Ffw size]
[97F] Default BB Swing=20

mesh_passphrase_update, before encrypt
65 39 66 66 34 64 32 66 62 65 37 38 30 30 36 30 

mesh_passphrase_update, after encrypt
64 34 38 dd 13 2c 3b ad 7b d1 93 8e 8c a8 be 34 
br0: port 2(wlan1) entered listening state
br0: port 2(wlan1) entered listening state
device wlan-msh entered promiscuous mode
br0: port 3(wlan-msh) entered listening state
br0: port 3(wlan-msh) entered listening state
wifi_config_service:4505

******************
sysconf wlanapp start wlan0 wlan1 wlan0-va0 wlan1-va0 
***************
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
Init Wlan application...

FT Daemon v1.0 (Jul  2 2018 10:59:15)

Receive Pathsel daemon pid:1365
[ATM] atm_swq_en on
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
/bin/sh: wlanapp.sh: not found
!!! adjust 5G 2ndoffset for 8812 !!!
br0: port 2(wlan1) entered learning state
br0: port 3(wlan-msh) entered disabled state
device wlan0 entered promiscuous mode
WlanSupportAbility = 0x3
available channels[US]: 36 40 44 48 149 153 157 161 165 
MDID is null !!, set default MDID
[hard_code_8822_mibs] +++ 
MAX_RX_BUF_LEN = 8000 
[ODM_software_init] 
clock 40MHz
InitPON OK!!!
load efuse ok
rom_progress: 0x200006f
rom_progress: 0x400006f
InitMAC Page0 
Init Download FW OK 
halmac_init_mac_cfg OK
halmac_cfg_rx_aggregation OK
halmac_init_mac_cfg OK
[GetHwReg88XX][size PHY_REG_PG_8822Bmp_Type6]
[GetHwReg88XX][PHY_REG_PG_8822Bmp_Type6]
RL6302_MAC_PHY_Parameter_v018_20140708
[set_8822_trx_regs] +++ 
********************************
8822 efuse content 0x3D7 = 0xf4
8822 efuse content 0x3D8 = 0xf5
********************************

mesh_passphrase_update, before encrypt
65 39 66 66 34 64 32 66 62 65 37 38 30 30 36 30 

mesh_passphrase_update, after encrypt
64 34 38 dd 13 2c 3b ad 7b d1 93 8e 8c a8 be 34 
br0: port 4(wlan0) entered listening state
br0: port 4(wlan0) entered listening state
br0: port 3(wlan-msh) entered listening state
br0: port 3(wlan-msh) entered listening state
wifi_config_service:4505

******************
sysconf wlanapp start wlan0 wlan1 wlan0-va0 wlan1-va0 
***************
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied

FT Daemon v1.0 (Jul  2 2018 10:59:15)

Init Wlan application...
Receive Pathsel daemon pid:1502
==Set ssid close
==Set ssid close
br0: topology change detected, propagating

br_topology_change_detection, clear br0 fdb ...
br_topology_change_detection, clear shortcut cache...
br0: port 2(wlan1) entered forwarding state
[ATM] atm_swq_en on
wifi_config_service:4505

******************
sysconf wlanapp start wlan0 wlan1 wlan0-va0 wlan1-va0 
***************
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied

FT Daemon v1.0 (Jul  2 2018 10:59:15)

Init Wlan application...
Receive Pathsel daemon pid:1538
/bin/sh: et: not found
/bin/sh: et: not found
/bin/sh: et: not found
/bin/sh: et: not found
hw_nat_config 113: #####################flags = 1
hw_nat_config 131: ##########enable = 1
hw_nat_config 152: set /proc/hw_nat to 0
cat /proc/hw_nat
0 

steering_proc_band_steering_mode_write, local band steering mode Prefer-5GHz
check timer start success
argv[0] = pann
pann
argv[0] = gpio_ctrl
gpio_ctrl
argv[0] = mesh_status_check
mesh_status_check
argv[0] = network_check
network_check
User set flags:1
=== set mesh_local.registerd = registered(2)
br0: port 4(wlan0) entered learning state
Phy[0] down
Phy[1] down
Phy[2] down
Phy[3] down
Phy[4] down
br0: port 3(wlan-msh) entered learning state
[arainc][multiWAN is not exit]netctrl_phy_link_status_change(1381)
ifconfig: SIOCSIFFLAGS: Cannot assign requested address
[netctrl_lan_services_ctrl][354] dhcpcd_lan is already exit! 
argv[0] = redis-server
argv[1] = /etc_ro/redis.conf
redis-server
argv[0] = cmdsrv
argv[1] = -l
argv[2] = tcp://0.0.0.0:12598
argv[3] = -R
argv[4] = tcp://127.0.0.1:6379
cmdsrv
argv[0] = confsrv
confsrv
[get_ip_sg][313]ip : 192.168.11.1
[get_ip_sg][313]ip : 192.168.5.1
[1586] 01 May 00:00:11.607 * Max number of open files set to 10032
[1586] 01 May 00:00:11.608 # Warning: 32 bit instance detected but no memory limit set. Setting 3 GB maxmemory limit with 'noeviction' policy now.
iptables: Bad rule (does a matching rule exist in that chain?).
iptables: Bad rule (does a matching rule exist in that chain?).
[dhcps_handle][784]pCurrentCfg is NULL, NewCfgEnable = 1
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 2.6.17 (00000000/0) 32 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in stand alone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 1586
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

[1586] 01 May 00:00:11.803 # Server started, Redis version 2.6.17
[1586] 01 May 00:00:11.803 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
[1586] 01 May 00:00:11.803 * The server is now ready to accept connections on port 6379
[1586] 01 May 00:00:11.803 * The server is now ready to accept connections at /tmp/redis.sock
Init features[arainc][mpp]mesh_device_features_init(2704)
[dhcps_save_config][641]dhcps_save_config end
argv[0] = dhcps
argv[1] = -C
argv[2] = /etc/dhcps.conf
argv[3] = -l
argv[4] = /etc/dhcps.leases
argv[5] = -x
argv[6] = /etc/dhcps.pid
argv[7] = -k
dhcps
br0: topology change detected, propagating

br_topology_change_detection, clear br0 fdb ...
br_topology_change_detection, clear shortcut cache...
br0: port 4(wlan0) entered forwarding state
br0: port 1(eth0) entered disabled state
Send SIGUSR2 signal from kernel to pathsel, skip for test by Jack
br0: topology change detected, propagating

br_topology_change_detection, clear br0 fdb ...
br_topology_change_detection, clear shortcut cache...
br0: port 3(wlan-msh) entered forwarding state
Phy[3] up
br0: port 1(eth0) entered listening state
br0: port 1(eth0) entered listening state
2011-05-01 00:00:12 [INFO ][uc_api_lib.c,2028][uc_api_lib_init        ] Successfully initialized the api library...
sched_boot_set_cfg[62]   rand_num :584  
upgrade_shced_timeout start    upgrade_sched_reboot_init_srv(2593)
[set_mib 3371]hex format
odm[set_mib 4037]set odm,val=0x1e
[set_mib 3371]hex format
odm[set_mib 4037]set odm,val=0x1e
iptables: No chain/target/match by that name.
iptables v1.4.4: Couldn't find target `dmz_forward_pre'

Try `iptables -h' or 'iptables --help' for more information.
iptables: No chain/target/match by that name.
iptables v1.4.4: Couldn't find target `dmz_forward_post'

Try `iptables -h' or 'iptables --help' for more information.
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
iptables: Index of insertion too big.
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
iptables v1.4.4: Couldn't find target `port_forward_pre'

Try `iptables -h' or 'iptables --help' for more information.
iptables v1.4.4: Couldn't find target `port_forward_post'

Try `iptables -h' or 'iptables --help' for more information.
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
iptables v1.4.4: Couldn't find target `web_wanadmin'

Try `iptables -h' or 'iptables --help' for more information.
iptables: No chain/target/match by that name.
[device_list_cmd_sub][1385][luminais] invalid param.
iptables: No chain/target/match by that name.
iptables v1.4.4: Couldn't find target `web_wanadmin'

Try `iptables -h' or 'iptables --help' for more information.
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
iptables v1.4.4: Couldn't find target `MINIUPNPD'

Try `iptables -h' or 'iptables --help' for more information.
iptables: No chain/target/match by that name.
miniupnpd.c,871,ver=1.0,osname=Nova,osver=1.0,osurl=http://www.tendacn.com/,manuft=Tenda,descri=Nova
br0: port 1(eth0) entered learning state
change_opmode: wan_prev_link_flag=1, lan_prev_link_flag=0
br0: port 1(eth0) entered disabled state
device eth0 left promiscuous mode
br0: port 1(eth0) entered disabled state
brctl: bridge br0: Invalid argument
set_hw_nat 158: set /proc/hw_nat to 1
/proc/hw_nat now is 1

[Rtl83xx Ethernet Driver][RTL83XX_vlan_set][901]: failed!(0x3)
RTNETLINK answers: No such file or directory
argv[0] = ucloud
argv[1] = -l
argv[2] = 4
ucloud
killall: telnet_ate_monitor: no process killed
Phy[3] down
2011-05-01 00:00:16 [INFO ][uc_api_lib.c,1938][ucloud_event_accept2   ] accept ucloud session 16
2011-05-01 00:00:16 [INFO ][uc_api_lib.c,1952][ucloud_event_accept2   ] traversal notify info
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CLOUD_INFO_MESH_NODE_A[14] in module: M_CLOUD_INFO[8]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CLOUD_INFO_DEV_UPLOAD_STATU[20] in module: M_CLOUD_INFO[8]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CLOUD_INFO_DEV_UPLOAD_DEVIC[18] in module: M_CLOUD_INFO[8]...
2011-05-01 00:00:16 =Set ssid open
m[INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CL==Set ssid open
OUD_INFO_DEV_MARK_LIST_A[21] in module: M_CLOUD_INFO[8]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CLOUD_INFO_DEV_CONFIG_TIME_[23] in module: M_CLOUD_INFO[8]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CLOUD_INFO_DEV_CONFIG_A[25] in module: M_CLOUD_INFO[8]...
enable cloud info OK
init_device_attr_desc(2680)
get_mesh_info(2614)
get_mesh_info(2650)
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CLOUD_INFO_MESH_SET[11] in module: M_CLOUD_INFO[8]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CLOUD_INFO_CHECK_MEMORY[0] in module: M_CLOUD_INFO[8]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CLOUD_INFO_BEGIN_UPGRADE[4] in module: M_CLOUD_INFO[8]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c,1955][ucloud_event_accept2   ] Init Modules
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: MESH_WAN_SET[1] in module: MESH_WAN[18]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: MESH_WAN_GET[2] in module: MESH_WAN[18]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_WAN_DETECT[3] in module: M_MESH_WAN[18]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_WAN_STATUS[0] in module: M_MESH_WAN[18]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_WAN_DIAG[4] in module: M_MESH_WAN[18]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_WAN_LINEUP_GET[7] in module: M_MESH_WAN[18]...
2011-05-01 Receive Pathsel daemon pid:2004
00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_WAN_TRAFFIC[8] in module: M_MESH_WAN[18]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_WLAN_GET[1] in module: M_MESH_WLAN[19]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_WLAN_SET[0] in module: M_MESH_WLAN[19]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_WLAN_GET[3] in module: M_MESH_WLAN[19]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_WLAN_SET[2] in module: M_MESH_WLAN[19]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_WLAN_ROAMING_GET[4] in module: M_MESH_WLAN[19]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_WLAN_ROAMING_SET[5] in module: M_MESH_WLAN[19]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_BASIC_SUILT[0] in module: M_MESH_BASIC[16]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_BASIC_TZ_SET[1] in module: M_MESH_BASIC[16]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_BASIC_TIME_SET[2] in module: M_MESH_BASIC[16]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_BASIC_LANG_SET[3] in module: M_MESH_BASIC[16]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_BASIC_FAST_DONE[4] in module: M_MESH_BASIC[16]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_BASIC_GET_MESH_ID[5] in module: M_MESH_BASIC[16]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_BASIC_UPLOAD_LOG[6] in module: M_MESH_BASIC[16]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_NODE_BROWS[0] in module: M_MESH_NODE[17]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_NODE_ADD[1] in module: M_MESH_NODE[17]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_NODE_DEL[2] in module: M_MESH_NODE[17]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_NODE_SET_LOCATION[3] in module: M_MESH_NODE[17]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_NODE_SET_LED[4] in module: M_MESH_NODE[17]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_NODE_QUERY_RSLT[5] in module: M_MESH_NODE[17]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_NODE_MULTI_UPGRADE_STA[6] in module: M_MESH_NODE[17]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_NODE_MANUAL_ADD[7] in module: M_MESH_NODE[17]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_HOSTS_GET[0] in module: M_MESH_HOSTS[20]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_HOSTS_MARK[1] in module: M_MESH_HOSTS[20]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_HOSTS_GET_REMARK[2] in module: M_MESH_HOSTS[20]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_MF_GET[0] in module: M_MESH_MACFILTER[21]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_MF_SET[1] in module: M_MESH_MACFILTER[21]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_FAMILY_GET_TMGRP[0] in module: M_MESH_FAMILY[22]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_FAMILY_SET_TMGRP[1] in module: M_MESH_FAMILY[22]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_FAMILY_GET_USRGRP[2] in module: M_MESH_FAMILY[22]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_FAMILY_SET_USRGRP[3] in module: M_MESH_FAMILY[22]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_FAMILY_GET_FMLYGRP[4] in module: M_MESH_FAMILY[22]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_FAMILY_SET_FMLYGRP[5] in module: M_MESH_FAMILY[22]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_PORTFWD_GET[0] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_PORTFWD_SET[1] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_UPNP_GET[2] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_UPNP_SET[3] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_MAINT_GET[4] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_MAINT_SET[5] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_DHCPS_GET[6] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_DHCPS_SET[7] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_QOS_GET[8] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_QOS_SET[9] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_DEV_ASSISTANT_GET[10] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_DEV_ASSISTANT_SET[11] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_SHAREDACC_GET[12] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_HIGH_DEVICE_GET[15] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_ADV_HIGH_DEVICE_SET[16] in module: M_MESH_ADVANCE[23]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CLOUD_VERSION_Q[24] in module: M_CLOUD[3]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CLOUD_INFO_CLEAR_ACC_ACK[9] in module: M_CLOUD_INFO[8]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CLOUD_INFO_ACCOUNT_INFO_A[16] in module: M_CLOUD_INFO[8]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_MNGMT_GET_STA[0] in module: M_MESH_AUTH[24]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_MESH_MNGMT_LOGIN[1] in module: M_MESH_AUTH[24]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_SYS_BASIC_INFO_GET[0] in module: M_SYS[1]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_CATEGORY_MESH[1] in module: M_CATEGORY[15]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_COMMON_SUCCESS[0] in module: M_COMMON[0]...
2011-05-01 00:00:16 [INFO ][uc_api_lib.c, 344][uc_api_lib_cmd_register] Successfully registered command: CMD_COMMON_FAILURE[1] in module: M_COMMON[0]...
argv[0] = sntp
argv[1] = 1
argv[2] = 10800
argv[3] = 43200
sntp
main,297,sntp_en =1,tz_offset_sec=10800,checktime=43200
wifi_config_service:4505

******************
sysconf wlanapp start wlan0 wlan1 wlan0-va0 wlan1-va0 
***************
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
Init Wlan application...

FT Daemon v1.0 (Jul  2 2018 10:59:15)

change_opmode: sleep 1s for NIC restart.
change_opmode: sleep 2s for NIC restart.
wifi_config_service:4505

******************
sysconf wlanapp start wlan0 wlan1 wlan0-va0 wlan1-va0 
***************
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied

FT Daemon v1.0 (Jul  2 2018 10:59:15)

Init Wlan application...
Receive Pathsel daemon pid:2078
[arainc][multiWAN is not exit]netctrl_phy_link_status_change(1381)
change_opmode: sleep 3s for NIC restart.
device eth0 entered promiscuous mode
br0: port 1(eth0) entered listening state
br0: port 1(eth0) entered listening state
[arainc][multiWAN is not exit]netctrl_phy_link_status_change(1381)
change_opmode: sleep 1s for port reverted.
###fd failed to recv packet!###
##### NO SERVER FOUND! #####
br0: port 1(eth0) entered learning state
br0: port 2(wlan1) entered disabled state
change_opmode: sleep 2s for port reverted.
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
ifconfig: SIOCGIFFLAGS: No such device
/bin/sh: wlanapp.sh: not found
br0: port 3(wlan-msh) entered disabled state
WlanSupportAbility = 0x3
available channels[US]: 1 2 3 4 5 6 7 8 9 10 11 
[ODM_software_init] 
[97F] Bonding Type 97FS, PKG1
[97F] RFE type 5 PHY paratemters: GPA1+GLNA1
clock 40MHz
load efuse ok
rom_progress: 0x200006f
rom_progress: 0x400006f
[GetHwReg88XX][PHY_REG_PG_8197Fmp_Type5] size
[GetHwReg88XX][PHY_REG_PG_8197Fmp_Type5]
[GetHwReg88XX][rtl8197Ffw]
[GetHwReg88XX][rtl8197Ffw size]
[97F] Default BB Swing=20

mesh_passphrase_update, before encrypt
65 39 66 66 34 64 32 66 62 65 37 38 30 30 36 30 

mesh_passphrase_update, after encrypt
64 34 38 dd 13 2c 3b ad 7b d1 93 8e 8c a8 be 34 
br0: port 2(wlan1) entered listening state
br0: port 2(wlan1) entered listening state
br0: port 3(wlan-msh) entered listening state
br0: port 3(wlan-msh) entered listening state
wifi_config_service:4505

change_opmode: sleep 3s for port reverted.
******************
sysconf wlanapp start wlan0 wlan1 wlan0-va0 wlan1-va0 
***************
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
open /proc/gpio: Permission denied
Init Wlan application...

FT Daemon v1.0 (Jul  2 2018 10:59:15)

Receive Pathsel daemon pid:2394
[ATM] atm_swq_en on
br0: topology change detected, propagating

br_topology_change_detection, clear br0 fdb ...
br_topology_change_detection, clear shortcut cache...
br0: port 1(eth0) entered forwarding state
change_opmode: sleep 4s for port reverted.
br0: port 2(wlan1) entered learning state
br0: port 3(wlan-msh) entered learning state
change_opmode: sleep 5s for port reverted.
change_opmode: sleep 6s for port reverted.
br0: topology change detected, propagating

br_topology_change_detection, clear br0 fdb ...
br_topology_change_detection, clear shortcut cache...
br0: port 2(wlan1) entered forwarding state
Send SIGUSR2 signal from kernel to pathsel, skip for test by Jack
br0: topology change detected, propagating

br_topology_change_detection, clear br0 fdb ...
br_topology_change_detection, clear shortcut cache...
br0: port 3(wlan-msh) entered forwarding state
change_opmode: sleep 7s for port reverted.
change_opmode: sleep 8s for port reverted.
change_opmode: sleep 9s for port reverted.
change_opmode: sleep 10s for port reverted.
change_opmode: sleep 11s for port reverted.
Phy[3] up
[arainc][multiWAN is not exit]netctrl_phy_link_status_change(1381)
change_opmode: sleep 12s for port reverted.
change_opmode: NIC restart finished.(WAN:1,LAN:0)
src/prod_common_rtl_fn_delete: failed del route from rtl865x!
hal.c,add_local_route_to_switch,179: config (192.168.5.0,255.255.255.0,br0) to the Realtek ASIC L3 Routing Table
[hw_nat_msg_handle][245]var->op 3
[set_hw_nat_by_guest_network][76]guest network is close!
eth1 has been deleted from br0!
hw_nat_config 113: #####################flags = 1
hw_nat_config 131: ##########enable = 1
hw_nat_config 152: set /proc/hw_nat to 0
cat /proc/hw_nat
wandial_handle(231)
0 

[arainc][ctrl_op = 1]netctrl_moudle_multiwan_handle(22)
argv[0] = multiWAN
multiWAN
multiWAN -> multiwan_bad_sig_entry [18]...ct = 9
open:: No such file or directory
multiWAN -> multiwan_bad_sig_entry [18]...ct = 8
iptables: No chain/target/match by that name.
multiWAN -> multiwan_bad_sig_entry [18]...ct = 7
iptables: No chain/target/match by that name.
multiWAN -> multiwan_bad_sig_entry [18]...ct = 6
multiWAN -> multiwan_bad_sig_entry [18]...ct = 5
multiWAN -> multiwan_bad_sig_entry [18]...ct = 4
multiWAN -> multiwan_bad_sig_entry [18]...ct = 3
iptables: No chain/target/match by that name.
multiWAN -> multiwan_bad_sig_entry [18]...ct = 2
multiWAN -> multiwan_bad_sig_entry [18]...ct = 1
multiWAN -> multiwan_bad_sig_entry [18]...ct = 0
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
argv[0] = dhcpcd_wan1
argv[1] = -c
argv[2] = /etc/wan1.ini
argv[3] = -m
argv[4] = 1
argv[5] = eth1
argv[6] = -h
argv[7] = NOVA-0495e61a96e0
argv[8] = -x
argv[9] = /etc/dhcpc-wan-up1.sh
dhcpcd_wan1
program_name = dhcpcd_lan
killall: dhcpcd_lan: no process killed
[multiwan_msg_handle][2849]recv_info->SendPid = 7, recv_info->SendMid = 7, recv_info->RecvPid = 5, recv_info->RecvMid = 5
ganda_debug--[igmp_start]107 IGMP UP!!!
iptables: Bad rule (does a matching rule exist in that chain?).
iptables: Bad rule (does a matching rule exist in that chain?).
*TBQ* disabling tbq ...
*TBQ* tbq enqueue handlers is disabled
igmpproxy, Version 0.1 beta2, Build 170904 
Copyright 2005 by Johnny Egeland <j*TBQ* notify disable done in timer func
ohnny@rlo.org>
*TBQ* tbq backlog is cleared
Distributed unde*TBQ* tbq disabled
r the GNU GENERAL PUBLIC LICENSE, Version 2 - check GPL.txt

update_hwnat_setting 383:/proc/hw_nat now is 0 
route: SIOCDELRT: No such process
[multiwan_set_route_single_wan][1308][luminais] add_default_route_success
[getAllWanDns][125]wan1.manual.dns.en = 0
[getAllWanDns][187]dns_buf =  -s 192.168.3.1
argv[0] = dnrd
argv[1] = -t
argv[2] = 3
argv[3] = -M
argv[4] = 600
argv[5] = --cache=off
argv[6] = -b
argv[7] = -R
argv[8] = /etc/dnrd
argv[9] = -r
argv[10] = 3
argv[11] = -s
argv[12] = 192.168.3.1
dnrd
[lan_wan_ip_conflict_check][707][luminais] wan : 192.168.3.140/255.255.255.0
Notice: caching turned off
[lan_wan_ip_conflict_check][722][luminais] br0 : 192.168.5.1/255.255.255.0
[multiwan_msg_handle][2849]recv_info->SendPid = 4, recv_info->SendMid = 4, recv_info->RecvPid = 5, recv_info->RecvMid = 5
open /dev/flow failed:: No such file or directory
iptables: No chain/target/match by that name.
iptables v1.4.4: Couldn't find target `icmp_access'

Try `iptables -h' or 'iptables --help' for more information.
*TBQ* tbq is not running
*TBQ* config size: 278
*TBQ* Operation not set
*TBQ* wanid=ffffffff set
*TBQ* config.Rules[n].IpIncluded not set
*TBQ* config.Rules[n].UserIncluded not set
*TBQ* config.Rules[n].AppIncluded not set
*TBQ* MaxBacklogPackets set to: 9999
*TBQ* reloading tbq ...
*TBQ* tbq reloaded
*TBQ* ------------- TBQ CONFIG (rule count: 1) -------------
*TBQ* ~~~~~~~~~ TBQ RULE [UI-GLOBAL] ~~~~~~~~~
*TBQ* global out tokens_per_jiffy: 1280000
*TBQ* user   out tokens_per_jiffy: 1280000
*TBQ* global in tokens_per_jiffy: 1280000
*TBQ* user   in tokens_per_jiffy: 1280000
*TBQ* max_backlog_packets:  9999
*TBQ* latency_shift:        7
*TBQ* disable_timeout:      2
*TBQ* ------------------------------------------
*TBQ* tbq enabled
killall: xl2tpd-server: no process killed
iptables: No chain/target/match by that name.
iptables: Chain already exists.
iptables: Chain already exists.
iptables: No chain/target/match by that name.
iptables v1.4.4: Couldn't find target `web_wanadmin'

Try `iptables -h' or 'iptables --help' for more information.
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
iptables v1.4.4: Couldn't find target `web_wanadmin'

Try `iptables -h' or 'iptables --help' for more information.
iptables: No chain/target/match by that name.
miniupnpd.c,871,ver=1.0,osname=Nova,osver=1.0,osurl=http://www.tendacn.com/,manuft=Tenda,descri=Nova
[hw_nat_msg_handle][245]var->op 2
[set_hw_nat_by_guest_network][76]guest network is close!
hw_nat_config 113: #####################flags = 0
hw_nat_config 131: ##########enable = 0
[fill_cloud_info_device_lists_rate][2600][luminais] NULL == g_ip_info
cat /proc/hw_nat
[mib_load_manage][472][luminais] GetBasicInfo [0]
0 

[mib_save_manage][532][luminais] AccoutACK [0]
dev_mark_list_a(72)
[dev_mark_list_a][75]
[upload_local_diff_remark_to_cloud][2270][luminais] all client remark same with cloud.
[mesh_node_a][242]
[cloud_mesh_node_handle][3977]
[save_mesh_node_group_conf][387][kg] groupsn = 181285920113001948
not need to write flash,crc:[3d7bd411]
commit cfm failed or not need write flash
not need to write flash,crc:[3d7bd411]
commit cfm failed or not need write flash
  s_time :1562925999991 
config_time :1562925999991    local_time:1562925999991    
telnet_ate_monitor_recv(166)
telnet_ate_monitor_recv(166)

[hw_nat_msg_handle][245]var->op 1
[set_hw_nat_by_guest_network][76]guest network is close!
hw_nat_config 113: #####################flags = 1
hw_nat_config 131: ##########enable = 0
cat /proc/hw_nat
0 

Normal startupGive root password for system maintenance
(or type Control-D for normal startup):

```
</spoiler>
Консоль приглашает зайти, но без пароля рута не пускает.

## Flash
Китайская на 146% SPI flash BOHONG BH25Q64 на 8 Мб. [Datasheet](http://www.hhzealcore.com/upload/201807/02/201807021644551022.pdf)

# Прошивка, то бишь firmware
Прошивку скачать с просторов интернета не удалось. Приложение на телефоне само скачивает прошивки из китайского Tenda облака, причем по своему протоколу, как выяснилось позже. Мои кубики имеют последнюю прошивку, по-этому вынюхать, откуда скачивается прошивка, не удалось.

## Давайте просто снимем дамп с флешки
Сначала попробовал надеть сверху на чип клещи и считать прошивку - но, как и ожидалось, у меня этого не получилось, т.к. запитывая флешку, запустился процессор и пошло поехало. Резать дорожки не хотелось, поэтому решил выпаять. Огородив окрестности ~~Онежского озера~~ окаянного отпрыска китайской промышленности каптоновым скотчем - подогрел феном и выпаял зверушку по-македонски - двумя паяльниками. Ну и хочется динамичности в процессе смены прошивок - подпаял хвостики для кроватки. 

![Так удобнее перепрошивать флешку](https://habrastorage.org/webt/1s/lx/5y/1slx5ym__-ijau-wa67juovqtnc.jpeg)

## Чем бы снять дамп?
Флешки я читаю раз в пять лет, надобности нет, а соответственно - и программаторов для них. В закромах нашел платку FTDI FT2232H, которой я пользовался для отладки ESP32 через JTAG + OpenOCD. Оказалось, она много чего умеет. В том числе и SPI в режиме мастера. Нагуглил на нее даташит и записал распиновку при подключении к первому каналу (порту):

| FT2232H      | Function | Нога на флешке |
|--------------|----------|----------------|
| ADBUS0       | SCK      | 6 |
| ADBUS1       | MOSI     | 5 |
| ADBUS2       | MISO     | 2 |
| ADBUS3       | CS       | 1 |

Оставшиеся ножки флешки 4 - GND, 8, 3 и 7 - VCC 3.3v.

![Подключение к FT2232H](https://habrastorage.org/webt/-y/8f/if/-y8fifqkmlw-h9i4qjkxgutto1w.jpeg)

### Flashrom
Параллельно поиску железяк в закромах нагуглил [flashrom](https://flashrom.org) - популярная утилитка для работы с флешками.

Запускаем...
```
$ flashrom -p ft2232_spi:type=2232H,port=A
```
...и, вообщем, смотрим в книгу - видим фигу.
<spoiler title="$ flashrom v0.9.9-r1954 on Linux 4.18.0-25-generic (x86_64)">
```
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
</spoiler>

К сожалению, флешка черезчур китайская, софтинка её понимать отказалась, а может ли она работать в каком-то "стандартном" или "generic" режиме я не понял. 

### Ардуины спешат на помощь. Ну и esp8266 с ними.
Опять пошел гуглить. Нагуглил древнюю поделку [доброго человека с сайта Технохрень](http://skproj.ru/programmator-spi-flash-svoimi-rukami/). Комплект из скетча для ардуины и приложения на .NET.

Поразмыслив, что для ардуины придется городить согласование уровней 3.3в и 5в - взял из закромов платку NodeMCU на `esp8266`. Она на 3.3в. 
Скетч запустился без проблем, правда я никак не мог флешку прочитать - после пары научных тыков преподключил флешку ко второму SPI порту, который называется HSPI и выведен на ноги `GPIO 12..14` согласно [официальной документации](https://nodemcu.readthedocs.io/en/master/modules/spi/).

- **NB** Надо сказать, что `flashrom` еще умеет работать с программатором `serprog`, в который собственно можно превратить любую 8-битную AVRку, включая ардуины. Но, к сожалению, быстрый гуглинг порта для esp8266 не дал результатов.

![esp8266 HSPI](https://habrastorage.org/webt/om/sm/wh/omsmwhqfehfvjghfkq_5jqqupde.jpeg)

### Дайте нормальную флешку!
Вообщем, чтобы не париться с китайской флешкой, в небезызвестном своими ценовыми политиками магазине имени двух бурундуков приобрел за огромные деньги в 110 рублей (2 USD) нормальную флешку Winbond W25Q64FV. Куда тут же залил считанный дамп и воткнул в кубик.
```
$ flashrom -p ft2232_spi:type=2232H,port=A -w all.bin
```
Tenda флешку подхватила и запустилась, как ни в чем не бывало. (Хотя, по-моему, она разок перезагрузилась, переписав что-то в конфиге/облаке. Не заметил что именно).

## А ну-ка, давай-ка
В прошивке что-то есть. По крайней мере, binwalk нашел всякого. Как я понял - достаточно стандартно для таких железяк.
Попробуем раскопать, что-нибудь исправить и закопать обратно.

<spoiler title="$ binwalk all.bin">
```
DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
35096         0x8918          CRC32 polynomial table, little endian
36192         0x8D60          gzip compressed data, maximum compression, from Unix, last modified: 2018-04-20 02:17:42
206872        0x32818         LZMA compressed data, properties: 0x5D, dictionary size: 8388608 bytes, uncompressed size: 6890804 bytes
2261010       0x228012        Squashfs filesystem, little endian, version 4.0, compression:xz, size: 3071844 bytes, 378 inodes, blocksize: 131072 bytes, created: 1902-05-30 15:13:04
6160384       0x5E0000        JFFS2 filesystem, little endian
```
</spoiler>

Сразу распаковывать не стал. Еще первый раз в bootlog-е видел, что мелькала разбивка флешки на разделы - сначала разбил командой `dd` на соответствующие куски, а потом уже играл с `binwalk`.

<spoiler title="bootlog : mtd partitions">
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
</spoiler>

Пример вырезания RootFS из файла прошивки `all.bin`: 
```
$ dd if=all.bin of=RootFS.bin bs=1 skip=$((0x228012)) count=$((0x5c0000-0x228012))
```

Я не специалист, но мне кажется странным, что согласно разметке раздел RootFS находится внутри KernelFS.

Кроме того, устройство ядра для меня загадка, поэтому его трогать не стал.

Весть процесс загрузки, как я понял, почти прямолинеен:
 - сначала процессор отображает флешку к себе в память,
 - запускает bootloader,
 - bootloader проверяет, не хочет ли кто-то по TFTP загрузить новую прошивку,
 - после чего он грузит уже ядро.

## RootFS
Распаковать файловую систему элементарно - `unsquashfs RootFS.bin`. В результате работы появляется папка `squashfs-root` с деревом папок/файлов. 

- Тут уже есть, что посмотреть! - подумал я.


cat `/etc_ro/passwd`
```
root:$1$nalENqL8$jnRFwb1x5S.ygN.3nwTbG1:0:0:root:/:/bin/sh
```
cat `/etc_ro/shadow`
```
root:$1$OVhtCyFa$7tISyKW1KGssHAQj1vI3i1:14319::::::
```
cat `/etc_ro/inittab`
```
::sysinit:/etc_ro/init.d/rcS
ttyS0::respawn:/sbin/sulogin
::ctrlaltdel:/bin/umount -a -r
::shutdown:/usr/sbin/usb led_off
```

<spoiler title="В `/etc_ro/fstab` ничего интересного.">
```
proc            /proc           proc    defaults 0 0
#none            /var            ramfs   defaults 0 0
none            /tmp            ramfs   defaults 0 0
mdev            /dev            ramfs   defaults 0 0
none            /sys            sysfs   defaults 0 0
```
</spoiler>

<spoiler title="Впрочем, ничего интересного я не нашел и в `/etc_ro/init.d/rcS`.">
```
#! /bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin/
export PATH

mount -t ramfs none /var/


mkdir -p /var/etc
mkdir -p /var/media
mkdir -p /var/webroot
mkdir -p /var/etc/iproute
mkdir -p /var/run
mkdir -p /var/debug

cp -rf /etc_ro/* /etc/
cp -rf /webroot_ro/* /webroot/
mkdir -p /var/etc/upan
mount -a

mount -t ramfs /dev
mkdir /dev/pts
mount -t devpts devpts /dev/pts
mount -t tmpfs none /var/etc/upan -o size=2M
mdev -s
mkdir /var/run
echo 1 > /proc/sys/vm/panic_on_oom
echo 1 > /proc/sys/kernel/panic_on_oops


echo '/sbin/mdev' > /proc/sys/kernel/hotplug
#echo 'sd[a-z][0-9] 0:0 0660 @/usr/sbin/autoUsb.sh $MDEV' >> /etc/mdev.conf
#echo 'sd[a-z] 0:0 0660 $/usr/sbin/DelUsb.sh $MDEV' >> /etc/mdev.conf
#echo 'lp[0-9] 0:0 0660 */usr/sbin/IppPrint.sh'>> /etc/mdev.conf
#wds rule start
echo 'wds*.* 0:0 0660 */etc/wds.sh $ACTION $INTERFACE' > /etc/mdev.conf
#wsd rule end
echo 'sd[a-z][0-9] 0:0 0660 @/usr/sbin/usb_up.sh $MDEV $DEVPATH' >> /etc/mdev.conf
echo '-sd[a-z] 0:0 0660 $/usr/sbin/usb_down.sh $MDEV $DEVPATH'>> /etc/mdev.conf
echo 'sd[a-z] 0:0 0660 @/usr/sbin/usb_up.sh $MDEV $DEVPATH'>> /etc/mdev.conf
echo '.* 0:0 0660 */usr/sbin/IppPrint.sh $ACTION $INTERFACE'>> /etc/mdev.conf
mkdir -p /var/ppp

insmod /lib/modules/dhcp_options.ko
#insmod /lib/modules/gpio.ko
insmod /lib/modules/phy_check.ko
#insmod /lib/modules/fastnat.ko 
insmod /lib/modules/bm.ko
#insmod /lib/modules/ai.ko 
insmod /lib/modules/mac_filter.ko 
#insmod /lib/modules/ip_mac_bind.ko
#insmod /lib/modules/privilege_ip.ko
insmod /lib/modules/nos.ko
#insmod /lib/modules/url_filter.ko
#insmod /lib/modules/loadbalance.ko
#insmod /lib/modules/app_filter.ko
#insmod /lib/modules/port_filter.ko
#insmod /lib/modules/arp_fence.ko
#insmod /lib/modules/ddos_ip_fence.ko
#/etc/gpio_conf
echo "enable 0 interval 0" >/proc/watchdog_cmd
chmod +x /etc/mdev.conf
mkdir -p /tmp/log
mkdir -p /tmp/log/crash
mkdir -p /tmp/log_print

ln -sf /proc/port1 /var/port1
ln -sf /proc/port3 /var/port0

echo 'kern.* /tmp/log/kernel.log' >>  /etc/syslog.conf
echo '*.* /tmp/log_print/message.txt' >>  /etc/syslog.conf

klogd -n &
syslogd -f /var/etc/syslog.conf -s 50 &

monitor &
sh /usr/bin/ugw_watchdog.sh 2>/tmp/log_print/ugw_watchdog.log&
#sh /usr/bin/mesh_op.sh > /dev/null &
```
</spoiler>

Юзеров не много, ttyS0 можно было бы и не на `/sbin/sulogin` натравливать, а на `/bin/login -f root` или `/bin/sh`.

# Вторая наивная попытка войти

Попробуем поправить `/etc_ro/inittab`.  Заменил `ttyS0::respawn:/sbin/sulogin` на `ttyS0::respawn:/bin/login -f root`.

Запаковал обратно squashfs с помощью `mksquashfs` - файл стал в 1.5 раза больше и перестал влезать в раздел. Заметил, что оригинальный файл был пожат алгоритмом `xz`, а утилита по-умолчанию использует `lzma`. Переделал файл с нужным алгоритмом компресии - все стало ок. Подсмотрев в содержимое оригинального дампа раздела RootFS добил свой новый файл до размера раздела байтом `0xff`. С помощью `dd` скопировал новый раздел на место старого. Записал всё на флешку. Потираю ручки, включаю кубик...

<spoiler title="Booting...">
```
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
</spoiler>
**Какой мощный фейл!** Как я вообще мог не подумать про CRC.

Смотрю еще раз `binwalk` - bootloader не UBoot, гуглинг подсказывает, что RealTek - ребята скрытные. В общем доступе описания нет, кроме того, под каждый девайс свои сигнатуры призывают делать, чтобы неповадно реверсить было... Эх.

Для UBoot и ряда других случаев может помочь древний заброшенный проект [firmware-mod-kit](https://code.google.com/archive/p/firmware-mod-kit/), либо есть гордый потомок - наикрутейший [Firmware Analysis Toolkit](https://github.com/attify/firmware-analysis-toolkit)

Погуглил по темным закоулкам интернета - нашел относительно свежий RealTek SDK года 2015-го. Архив на 600 Мб. Одним глазом поглядел на процесс построения финального образа прошивки и расчет CRC - плюнул и закрыл. Пока что жалко мозг. И время. Может быть потом как-нибудь.

# Еще попыточка
Конечно же, я с первого раза заметил, что при загрузке кубик выдает подозрительную надпись в логе:
```
argv[0] = netctrl
netctrl
prod_change_root_passwd(83)
```

Запускается процесс `netctrl` и меняет пароль.

Ну давайте поиграем. Вспомнил, как 20 лет назад писал софт по ZX Spectrum на ассемблере и ломал игрушки, чтобы жизней было побольше и бесконечные патроны. 
Больше к ассемблеру не притрагивался, не считая того факта, что на 3-4 года позже благодаря ему я попал на первую работу. Фиксал ~~KDE под FreeBSD~~ драйвера для виндовского setup-загрузчика.

Берем IDA PRO в долг у приятеля.

## Куда же посмотреть сначала?
Наверное надо найти, где же выводится данная надпись. Ищем текст `prod_change_root_passwd` по файлам - в результатах много исполняемых файлов, включая тот самый `/bin/netctrl`, а также одна библиотека `/lib/libcommonprod.so`. Нам повезло - судя по всему и функция и текст вывода на экран совпадают, а сама реализация - в файле библиотеки.

## Вспомнила бабка первый поцелуй
Запускаем IDA PRO, который я вижу первый раз в жизни. Как и MIPS ассемблер.

Открываем `/bin/netctrl`. Система сразу любезно открыла нам функцию `main`. Ничего не понятно, но, судя по всему, вначале очищаются буферы и инициализируются локальные переменные. А потом, скорее всего, из конфига считывается параметр `sys.role` и на основе его значения программа либо засыпает, либо ... вызывает внешнюю функцию с тем самым подозрительным названием. Параметров вроде никаких нет. Как я понял, параметры передаются в регистрах $a0..$a3.

![IDA PRO - netctrl](https://habrastorage.org/webt/uz/om/r0/uzomr0xmqm6h5zxsy5uej2v-jwo.png)

Открываем `/lib/libcommonprod.so`, а в нем - искомую функцию. Она тоже начинает работу с зачистки буферов, потом считывает параметры из конфига и... ** О, БОЖЕ** берет пароль от wifi, кодирует его в base64 и меняет на это пароль рута. 

![вот где собака порылась](https://habrastorage.org/webt/ol/1p/a0/ol1pa0dybm6vteko7rjjnb7pgky.png)

## А-а-лилуйя!
Вообщем, при каждой загрузке пароль рута устанавливается в base64(пароль от wifi). После сброса настроек - это пароль со стикера на самом роутере.
```
Normal startupGive root password for system maintenance
(or type Control-D for normal startup):
System Maintenance Mode
~ #
~ # uname -a
Linux NOVA-xxxxxxxxxxxx 3.10.90 #4 Mon Jul 2 10:57:35 CST 2018 mips GNU/Linux
```

## Мы внутри
Вообщем, сильно много интересного внутри нет. Всё разделы r/o, по-этому все в RootFS и текстовых конфигах на отдельном разделе.

<spoiler title="~ # cat /proc/cpuinfo">
```
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
```
</spoiler>
<spoiler title="~ # ls -l /sys/class/gpio/">
```
total 0
--w-------    1 root     root         16384 Jan  1  1970 export
lrwxrwxrwx    1 root     root             0 Jan  1  1970 gpio18 -> ../../devices/virtual/gpio/gpio18
lrwxrwxrwx    1 root     root             0 Jan  1  1970 gpio19 -> ../../devices/virtual/gpio/gpio19
lrwxrwxrwx    1 root     root             0 Jan  1  1970 gpio58 -> ../../devices/virtual/gpio/gpio58
lrwxrwxrwx    1 root     root             0 Jan  1  1970 gpiochip0 -> ../../devices/virtual/gpio/gpiochip0
--w-------    1 root     root         16384 Jan  1  1970 unexport
```
</spoiler>
<spoiler title="~ # ls -l /sys/devices/platform/">
```
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
</spoiler>
<spoiler title="~ # ps">
```
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
</spoiler>

# Access granted, root
Собственно, рутовый доступ получен. Позитивные эмоции получены. Приятно же иметь доступ ко всему, чем владеешь. А то эта эпоха всё позакрывать и выдавать черные ящики с сюрпризами мне очень не нравится.

# А что дальше?
А дальше хочется вернуться к изначальной проблеме - прибить DHCP сервер. Это для начала.
Для этого надо будет изучить процессы загрузки, скрипты. Всё это осложняется пока что отсутствием возможности перепаковать образ прошивки - надо копать RSDK.

Кроме того, достаточно интересно пощупать на наличие китайских бэкдоров. Ну и, если прошивку не удасться перепаковать, поковырять cloud протокол, чтобы таки получить доступ снаружи.

Но, в любом случае, я получил массу удовольствия в процессе раскопок.

# Ссылки
1. Все файлы, логи и пр. доступны у меня в репозитории на https://github.com/latonita/tenda-reverse
2. [Tenda Mesh3-18 (Nova MW6 2018) on wikidevi.com](https://wikidevi.com/wiki/Tenda_Mesh3-18_(Nova_MW6_2018))
3. [SPI Flash programmer by SKProj на сайте Технохрень](http://skproj.ru/programmator-spi-flash-svoimi-rukami/)
4. [flashrom homepage](https://flashrom.org/Flashrom)
5. [firmware-mod-kit (давно заброшен)](https://code.google.com/archive/p/firmware-mod-kit/)
6. Достаточно интересный проект по эмуляции и анализу linux-based firmware - [firmadyne](https://github.com/firmadyne/firmadyne)
7. Кладезь для анализа и автоматической перепаковки - [Firmware Analysis Toolkit](https://github.com/attify/firmware-analysis-toolkit)
