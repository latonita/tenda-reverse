#!/bin/sh
#edit by zhang
unit=$1
mppe=$2

optionfile=/etc/options$unit.pptp

IPUP=/etc/ppp/ip-up$unit
IPDOWN=/etc/ppp/ip-down$unit
up="pptp_client?op=1,index=$unit"
down="pptp_client?op=2,index=$unit"
mkdir -p /etc/ppp

echo "#!/bin/sh" > $IPUP
echo "cfm Post netctrl $up &" >> $IPUP
#echo "cat /proc/uptime > /etc/at" >> $IPUP
echo "cat /proc/uptime > /etc/conntime$unit" >>$IPUP
chmod +x $IPUP

echo "#!/bin/sh" > $IPDOWN
echo "cfm Post netctrl $down &" >> $IPDOWN
#echo "echo '0 0' > /etc/at" >> $IPDOWN
echo "echo '0 0' > /etc/conntime$unit" >>$IPDOWN
chmod +x $IPDOWN

#echo noipdefault > /etc/options.pptp
echo noipdefault > $optionfile

echo nodetach >> $optionfile
echo passive >> $optionfile
echo lcp-echo-interval 30 >> $optionfile
echo lcp-echo-failure 8 >> $optionfile
echo maxfail 3 >> $optionfile
echo noauth >> $optionfile
echo refuse-eap >> $optionfile
echo usepeerdns >> $optionfile
#echo noccp >> /etc/options.pptp
echo nobsdcomp >> /etc/options.pptp
echo nodeflate >> $optionfile
#echo noaccomp >> /etc/options.pptp
#echo nopcomp >> /etc/options.pptp
#echo novj >> /etc/options.pptp
echo persist >> $optionfile
echo ip-up-script $IPUP >>$optionfile
echo ip-down-script $IPDOWN >>$optionfile

if [ $mppe -ne 0 ]
then 
#echo mppe required,no40,no56,stateless >> $optionfile
echo +mppe-128 >> $optionfile
else
echo nomppe >> $optionfile
fi
echo novjccomp >> $optionfile
echo ipcp-accept-remote >> $optionfile
echo ipcp-accept-local >> $optionfile
echo persist >> $optionfile
