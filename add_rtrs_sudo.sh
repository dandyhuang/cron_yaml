#!/bin/bash

chmod a+w /etc/sudoers

echo "app  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

chmod a-w  /etc/sudoers
