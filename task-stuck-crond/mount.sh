#!/bin/bash

set -euo pipefail

insmod /lib/modules/5.10.234+/dm-mod.ko
insmod /lib/modules/5.10.234+/stuck_dm.ko



SIZE=$(blockdev --getsz /dev/vdb)
echo "0 $SIZE stuck /dev/vdb" | dmsetup create stuck0

if [[ $? -ne 0 ]]; then
	echo "Failed to create device mapper. Exiting."
	exit 1
fi

mount /dev/mapper/stuck0 /mnt -o rw

# write lock to trigger the stuck state. Must be done after mounting, otherwise the device will be stuck before the mount and the mount will fail.
echo 1 > /proc/stuck_dm