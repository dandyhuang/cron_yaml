#!/bin/bash
rm -rf bin.tar.gz
tar zcvf bin.tar.gz config scripts bin/${1}
echo "应用名：$1"
sh batch_command.sh machine/iplist.txt "mkdir /data/${1}; cd /data/${1} && sudo chown rtrs:rtrs -R /data/${1} &&  mv bin.tar.gz binbak.tar.gz" |sh
sh gen_scp_push_tool.sh machine/iplist.txt bin.tar.gz /data/${1} |sh
sh batch_command.sh machine/iplist.txt "cd /data/${1} && \
    tar xvf bin.tar.gz && \
    sudo chown app:app -R /data/${1}" | sh

