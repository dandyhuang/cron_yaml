#!/bin/sh

scrip_dir=$( cd $(dirname $0) && pwd)
iplist=$1
scp_file=$2
dest_dir=$3

#改成线上机器账号
user=rtrs
#改成线上机器账号对应的密码
pass=Rtrs@2018++




if [ $# -lt 3 ]
then
    cat << EOF
Usage: ./gen_scp_push_tool.sh iplist.txt scp_file dest_dir
e.g. : ./gen_scp_push_tool.sh iplist_kars.txt kars.tgz /data/home/kars
EOF
    exit 0
fi

cd ${scrip_dir}; 
cat ${iplist} | sed -e "s#^#./scp.exp #g" -e "s#\$# ${user} ${pass} 36000 ${scp_file} ${dest_dir} push 0 -1#g"
