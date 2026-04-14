#!/bin/sh
set -e

mkdir -p /overlay
mkdir -p /overlay/upper
mkdir -p /overlay/work
mkdir -p /mnt

mount -o remount,ro /

mount -t tmpfs tmpfs /overlay -o size=2G

mkdir -p /overlay/upper
mkdir -p /overlay/work

mount -t overlay overlay \
          -o lowerdir=/,upperdir=/overlay/upper,workdir=/overlay/work,index=off \
            /mnt

exec switch_root /mnt /sbin/init
