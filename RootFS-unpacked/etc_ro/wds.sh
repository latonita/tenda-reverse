#!/bin/sh
echo "post WDS msg!"
cfm post netctrl wifi?op=8,wds_action=$1,wds_ifname=$2
