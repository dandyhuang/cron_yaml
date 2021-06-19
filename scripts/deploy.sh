#!/bin/bash
rm -rf bin.tar.gz
tar zcvf bin.tar.gz config bin/${1}
echo "应用名：$1"
echo "服务器：$2"
sh batch_command.sh machine/iplist.txt "mkdir /data/${1}; cd /data/${1} && mv bin.tar.gz binbak.tar.gz" |sh
sh gen_scp_push_tool.sh machine/iplist.txt bin.tar.gz /data/${1} |sh
sh batch_command.sh machine/iplist.txt "cd /data/${1} && \
    tar xvf bin.tar.gz && \
    chown app:app -R /data/${1}" | sh

#ssh ${2} "cd /data/${1} && mv bin.tar.gz binbak.tar.gz"
#scp bin.tar.gz ${2}:/data/${1}/

