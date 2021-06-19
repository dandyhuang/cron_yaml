#! /bin/bash

# 参数要大于2个
if [ $# -lt 1 ]; then
    echo "Usage: ./bin/rank4_cron {start|stop}  envflag{pre|prd}"
    exit
fi

envflag="prd"
config=envflag+".yaml"

echo "config:"${config}
if [ $# -ge 2 ];then
    envflag=$2
fi

ROOT_DIR=$(cd "$(dirname "$0")"; cd ../; pwd)
pwd
cd ${ROOT_DIR}

procname=$1
start_proc="${ROOT_DIR}/${procname}"


start()
{
    count=`ps -ef | grep ${start_proc} | grep -v grep |  grep -v $0 | awk '{print $2}' | wc -l`
    if [ ${count} -gt 0 ];then
        echo "${start_proc} alread start"
        return 1
    fi

    ${start_proc} -env ${envflag} -conf ${config} &
}

stop()
{
    PID=`ps -ef | grep ${start_proc} | grep -v grep |  grep -v $0 | awk '{print $2}'`
    if [ "${PID}x" == "x" ]; then
        echo "${start_proc} no process"
    else
        PID=`ps -ef | grep ${start_proc} | grep -v grep |  grep -v $0 | awk '{print $2}'`
        if [ "${PID}x" != "x" ]; then
            for x in $PID
            do
                echo "${APP_NAME} process is alive, PID is:${PID} send 9 to kill"
                kill -9 ${PID}
            done
        fi
    fi
}

# See how we were called.
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    status)
        status
        ;;
    monitor)
      monitor
        ;;
       *)
        echo $"Usage: $0 {start|stop|restart|status} procname [config]"
        exit 2
esac