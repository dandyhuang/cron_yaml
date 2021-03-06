#!/bin/bash
rm -rf bin.tar.gz
# 参数要大于1个
if [ $# -lt 1 ]; then
    echo "Usage: rank4_cron "
    exit
fi
tar zcvf bin.tar.gz config scripts bin/${1}
echo "应用名：$1"
sh batch_command.sh machine/iplist.txt "sudo mkdir /data/${1}; cd /data/${1} && sudo chown rtrs:rtrs -R /data/${1} &&  mv bin.tar.gz binbak.tar.gz" |sh
sh gen_scp_push_tool.sh machine/iplist.txt bin.tar.gz /data/${1} |sh
sh batch_command.sh machine/iplist.txt "cd /data/${1} && \
    tar xvf bin.tar.gz && \
    sudo chown app:app -R /data/${1}" | sh

