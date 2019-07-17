#!/bin/sh
# get wireless msg

rm -rf /tmp/log/wlan0.log
rm -rf /tmp/log/wlan1.log
echo "cat /proc/link_loop:" >> /tmp/log/wlan0.log
cat /proc/link_loop >> /tmp/log/wlan0.log
echo "" >> /tmp/log/wlan0.log

echo "cat /proc/link_loop:" >> /tmp/log/wlan1.log
cat /proc/link_loop >> /tmp/log/wlan1.log
echo "" >> /tmp/log/wlan1.log

for file in /proc/wlan0/*
do
	echo "cat $file:" >> /tmp/log/wlan0.log
	cat $file >> /tmp/log/wlan0.log
	echo "" >> /tmp/log/wlan0.log
done

for file in /proc/wlan1/*
do	
	echo "cat $file:" >> /tmp/log/wlan1.log
	cat $file >> /tmp/log/wlan1.log
	echo "" >> /tmp/log/wlan1.log
done


