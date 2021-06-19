#!/bin/bash

user=11123416
useradd ${user} -g rtrs -d /data/${user}
echo "${user}" | passwd --stdin ${user}
