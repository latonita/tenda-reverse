#!/bin/sh
# auth:lilin
# 定期dns去重
dns_file=/etc/resolv.conf
wan1_cfg=/etc/wan1.cfg
wan1_ini=/etc/wan1.ini
wan12_ini=/etc/wan12.ini

getvalue() {                                # 获取配置文件中的value值   key=value
  file=$1
  key=$2
  sedcmd="s/[ \t]*${key}[ \t]*=\(.*\)[ \t]*/\1/p"
  [ -e $file ] && sed -n "$sedcmd" $file
}

add_option() {
  option=$1
  [ -n "$option" ] && echo "options $option" >>  $dns_file
}

add_dns() {
  line=$1
  dns=$2
  sedcmd="${line}inameserver ${dns}"                         #第几行加入dns
  if [[ -n "$dns" ]] && [[ "$dns" != "0.0.0.0" ]]; then
    sed -i "$sedcmd" $dns_file
  fi
}

remove_repetition() {
  dns_file="/etc/resolv.conf"
  nline=1
  IFS=$'\n'
  for line in `cat $dns_file`; do
    #echo nline: $nline
    readcmd="${nline}p"
    #echo linecmd $linecmd
    type=`sed -n "$readcmd" $dns_file | awk '{print $1}'`
    value=`sed -n "$readcmd" $dns_file | awk '{print $2}'`
    if [[ -n "$value" ]]; then
      let nnline=$nline+1                               # 下一行
      delcmd="${nnline},\${/${type}[ \t]\+${value}/d}"  # 删除此行之后所有匹配项
      #echo $delcmd
      sed -i "$delcmd" $dns_file
    fi
    let nline=$nline+1
  done
}

con_type=`cfm get wan1.connecttype`
man_dns_en=`cfm get wan1.mannual.dns.en`
man_dns1=`cfm get wan1.mannual.dns1`
man_dns2=`cfm get wan1.mannual.dns2`
stage1_dns1=`getvalue $wan12_ini dns1`
stage1_dns2=`getvalue $wan12_ini dns2`
stage2_dns1=`getvalue $wan1_ini dns1`
stage2_dns2=`getvalue $wan1_ini dns2`
ppp_up=`ifconfig | grep ppp1`

[ ! -f "$dns_file" ] && exit
sed -i 's/[ \t]*#.*//g' $dns_file              #去注释
sed -i '/^[ \t]*$/d'    $dns_file              #去空行
if [[ "$con_type" -gt 2 ]] && [[ "$con_type" -le 4 ]] && [[ -z "$ppp_up" ]] ; then             #双接入dhcp过程
  add_dns 1 "$stage1_dns1"
  add_dns 2 "$stage1_dns2"
fi
remove_repetition
