#!/bin/sh
echo "================apmib_cfg================"
cfm apmib_show; 
echo "================mib_cfg================"
cfm show stdout; 
echo "================wl_cfg wlan0================"
cat /proc/wlan0/mib_all; 
echo "================wl_cfg wlan1================"
cat /proc/wlan1/mib_all; 
echo "================netstat================"
netstat -p; 
echo "================route================"
route; 
echo "================ip rule================"
ip rule; 
echo "================ip route================"
ip route; 
echo "================brctl show ================"
brctl show; 
echo "================iptables ================"
iptables -t filter -nvL; 
iptables -t nat -nvL; 
iptables -t mangle -nvL; 
echo "================nf_conntrack ================"
cat /proc/net/nf_conntrack; 
echo "================ifconfig================"
ifconfig;
echo "================arp================"
arp;
echo "================ps================"
ps;
echo "================var/mib.mem================"
cat var/mib.mem;
echo "================var/network_check_rst================"
cat var/network_check_rst;
echo "================etc/resolv.conf================"
cat /etc/resolv.conf;
echo "================/proc/meminfo================"
cat /proc/meminfo;
echo "================/proc/hw_nat================"
cat /proc/hw_nat;
echo "================/etc/dhcps.leases================"
cat /etc/dhcps.leases;
echo "================/etc/dhcps.conf================"
cat /etc/dhcps.conf;
echo "================cat /proc/rtl865x/l3================"
cat /proc/rtl865x/l3;
echo "================cat /proc/rtl865x/l2_dyn================"
cat /proc/rtl865x/l2_dyn;
echo "================cat /proc/mesh/status================"
cat /proc/mesh/status;
echo "================cat /proc/wlan0/mesh_assoc_mpinfo================"
cat /proc/wlan0/mesh_assoc_mpinfo;
echo "================cat /proc/wlan1/mesh_assoc_mpinfo================"
cat /proc/wlan1/mesh_assoc_mpinfo;
echo "================cat /proc/wlan0/mesh_pathsel_routetable================"
cat /proc/wlan0/mesh_pathsel_routetable;
echo "================cat /proc/wlan1/mesh_pathsel_routetable================"
cat /proc/wlan1/mesh_pathsel_routetable;
echo "================cat /proc/hybrid_steering/band_steering_mode================"
cat /proc/hybrid_steering/band_steering_mode;
echo "================cat /proc/hybrid_steering/enable================"
cat /proc/hybrid_steering/enable;
echo "================cat /proc/hybrid_steering/fixed_2g================"
cat /proc/hybrid_steering/fixed_2g;
echo "================cat port0================"
cat /var/port0;
echo "================cat port1================"
cat /var/port1;
echo "================cat /tmp/log/kernel.log================"
cat /tmp/log/kernel.log;
echo "================cat /tmp/log/pann.log================"
cat /tmp/log/pann.log;