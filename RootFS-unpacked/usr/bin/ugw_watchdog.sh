#判断日志文件大小是否超过200K，是则清空
check_size()
{
	if [ -d "/tmp/log/" ]
	then
		cd /tmp/log_print/
		DATE=`date`
		for x in `ls | awk -F= '{print $1}'`; do 
#			echo $x; 
			FILE_SIZE=`du -k $x | awk '{print $1}'`;
			if [ $FILE_SIZE -ge 200 ]
			then
				echo "$x file oversize[${FILE_SIZE}], clean!!!"
				echo "<${DATE}>, file oversize, clean!!!" > $x;
#				FILE_SIZE=`du -k $x | awk '{print $1}'`;
#				echo "$x size[${FILE_SIZE}]";
			fi
		done
	else
		echo "/tmp/log_print no exist"
	fi
}

#判断系统空余内存是否过小，是则重启系统
check_memory()
{
	MEM_FREE=`free | grep Mem | awk '{print $4}'`
	
	if [ ${MEM_FREE} -le 1024 ]
	then
		echo "memory too little, reboot system";
		reboot
	fi
}

#判断系统进程的句柄是否存在异常消耗情况
check_fd()
{
	for x in `ps | awk '{print $1}' | sed '1d'`; do 
		if [ -d "/proc/$x/fd" ]
		then
			fd_num=`ls /proc/$x/fd | wc -l`;
#			echo pid $x fd num $fd_num; 
			if [ ${fd_num} -gt 100 ]
			then
				echo "pid $x(`cat /proc/$x/cmdline`) fd num($fd_num) abnormal!!!"; 
			fi
		fi
	done
}

#判断系统网桥优先级是否匹配，尽可能将有线MESH多的设备设为根桥
check_br_priority()
{
	MP_NUM=`cat /proc/link_loop | grep "Total MP:" | awk '{print $3}'`
	CUR_PRIO=$((32768-${MP_NUM}))
	OLD_PRIO=`cat /sys/class/net/br0/bridge/priority`
	
	if [ ${CUR_PRIO} -ne ${OLD_PRIO} ]; then
		echo "reset br priority, wired mp num ${MP_NUM}, set br0 priority ${CUR_PRIO}";
		echo ${CUR_PRIO}>/sys/class/net/br0/bridge/priority
	fi
	
#	echo "wired mp num ${MP_NUM}, current br0 priority ${CUR_PRIO}";
}

check_ucloud_cpu()
{
	CPU1=`top -b -n 1 | grep ucloud | grep -v grep | awk '{print $8}' | cut -f 1 -d "."`
	sleep 1
	CPU2=`top -b -n 1 | grep ucloud | grep -v grep | awk '{print $8}' | cut -f 1 -d "."`
	if [ ${CPU1} -ge 90 ]; then
		if [ ${CPU2} -ge 90 ]; then
			killall -9 ucloud
		fi
	fi
}

while true; do check_size; check_memory; check_fd; check_br_priority; check_ucloud_cpu; sleep 5; done 
