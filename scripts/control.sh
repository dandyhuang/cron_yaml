#! /bin/bash

# 参数要大于2个
if [ $# -lt 1 ]; then
    echo "Usage: ./bin/rank4_cron  env{pre|prd}  {start|stop} "
    exit
fi

envflag="prd"
config="../config"

echo "config:"${config}
if [ $# -ge 2 ];then
    envflag=$2
fi

if [ $# -ge 4 ];then
    config=$4
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
    echo "${start_proc} -env ${envflag} -path ${config} &>/dev/null"
    ${start_proc} -env ${envflag} -path ${config} >/dev/null 2>&1 &
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
case "$3" in
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
