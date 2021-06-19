#!/bin/sh

if [ $# -lt 2 ]
then
    cat << EOF
Usage: $0 iplist.txt command 
e.g. : $0 iplist_compute.txt "sh install.sh " 
EOF
    exit 0
fi

#HOME_DIR=/data/distribute-hadoop-boss/rtrs

IP_LIST=$1
command=$2

#改成线上机器账号
user=rtrs
#改成线上机器账号对应的密码
pass=Rtrs@2018++
#pass=Rtrs@1920++


cat ${IP_LIST} | while read ip
do
	echo ./do_command.exp $user $ip \"$command\" $pass
done 
