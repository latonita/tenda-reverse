#!/bin/sh

#脚本状态机定义
MESH_SM_NORMAL='0'
MESH_SM_DISABLE_5G='1'
MESH_SM_ENABLE_5G='2'

state=${MESH_SM_NORMAL}
en_5g='0'
dis_5g='0'
max_5g=0

mesh_hop_check()
{
	mppmac=`cfm get sys.mpp.mac`
#	echo $mppmac
	mac0=`echo $mppmac|cut -b 1-2`
	mac1=`echo $mppmac|cut -b 4-5`
	mac2=`echo $mppmac|cut -b 7-8`
	mac3=`echo $mppmac|cut -b 10-11`
	mac4=`echo $mppmac|cut -b 13-14`
	mac5=`echo $mppmac|cut -b 16-17`
	mac5_dec=$(printf "%d\n" 0x$mac5)
	mac5=`expr $mac5_dec + 4`
	mac_str=$(printf "%s%s%s%s%s%x\n" $mac0 $mac1 $mac2 $mac3 $mac4 $mac5)
#	echo wifi_5g_mac $mac_str
	hopcount=$((`cat /proc/wlan0/mesh_pathsel_routetable |grep $mac_str -A 8|grep hopcount|cut -d ' ' -f 6`))
#	echo [$hopcount]
	if [ ${hopcount} -ge 2 ]; then
		max_5g=3
		else
		max_5g=6
		fi
}

mesh_sm_normal()
{
	is_mesh_group=`cat /proc/wlan0/mesh_pathsel_routetable | grep "2: "`
	sta_num_5h_mj=$((`cat /proc/wlan0/sta_info | grep addr -c`))
	sta_num_5h_vs=$((`cat /proc/wlan0-va0/sta_info | grep addr -c`))
	let "sta_num_total = sta_num_5h_mj+sta_num_5h_vs"
	if [[ -z "${is_mesh_group}" ]]; then
#		echo "5g enable access state, 5g sta num {$sta_num_total}"
		if [ x"${en_5g}" == x"0" ]; then
			state=${MESH_SM_ENABLE_5G}
		fi
	else
		mesh_hop_check
		#echo max_num $max_5g	
		if [ $sta_num_total -ge $max_5g ]; then
			if [ x"${dis_5g}" == x"0" ]; then
				state=${MESH_SM_DISABLE_5G}
			fi	
		else
			if [ x"${en_5g}" == x"0" ]; then
				state=${MESH_SM_ENABLE_5G}
			fi
		fi
	fi
}

mesh_sm_5g_disable()
{
	iwpriv wlan0 td_ssid_hide 1
	iwpriv wlan0-va0 td_ssid_hide 1
	state=${MESH_SM_NORMAL}
	en_5g='0'
	dis_5g='1'
}

mesh_sm_5g_enable()
{
	iwpriv wlan0 td_ssid_hide 0
	iwpriv wlan0-va0 td_ssid_hide 0
	state=${MESH_SM_NORMAL}
	en_5g='1'
	dis_5g='0'
}

while :; do
	case ${state} in
		"${MESH_SM_NORMAL}")
#			echo "enter normal state"
			mesh_sm_normal
		;;
		${MESH_SM_DISABLE_5G})
#			echo "enter 5g enable state"
			mesh_sm_5g_disable
		;;
		${MESH_SM_ENABLE_5G})
#			echo "enter disable 5g state"
			mesh_sm_5g_enable
		;;
		*)
		;;
	esac
	
	sleep 1
done
