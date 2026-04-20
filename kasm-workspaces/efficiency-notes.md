## General
du -hxd 1 --threshold=10M /usr/lib/x86_64-linux-gnu/* | sort -h
apt install -s --no-install-recommends

## https://stackoverflow.com/questions/18312935/find-file-in-linux-then-report-the-size-of-file-searched
find -iname *.cache | xargs du -sh

## https://linux.die.net/man/8/ld.so


## https://github.com/upx/upx/blob/devel/doc/upx-doc.txt


## https://wiki.archlinux.org/title/System_maintenance
https://wiki.archlinux.org/title/List_of_applications/Utilities#Disk_cleaning


# Stage 1 - base
apt install --no-install-recommends wget net-tools bzip2 wmctrl software-properties-common bc vulkan-tools iputils-ping less nano [157M]
                                    +mesa-utils [357M]
                                    +kmod udev iptables iproute2 [+~20M]

insert new "fonts" layer as stage 2 (postponed)
apt install --no-install-recommends fonts-noto-core fonts-noto-color-emoji [56M]

add to run commands:
bash /root/src/kasm/common/core/install/cleanup/cleanup.sh



# Stage 2 - desktop

# Stage 3 - additional packages
#removed

# Stage 4 - kasm
Without any changes to stage 4 and up to this point, the entire image is already 1GB smaller.

Removing additional kasm packages will likely help much. The KASM stage as original uses approx 1GB.

# Stage 5 - config
Need to add some config that was skipped from previous steps

# Stage 6 - finalize





# Status
IMAGE                                            ID             DISK USAGE   CONTENT SIZE   EXTRA
=====                                            ==             ===========  ============   =====
desktop:test                                     4daaa852ee86       3.68GB             0B        
kasmweb/core-ubuntu-noble:1.18.0-rolling-daily   a10125de3ddb       3.33GB             0B        
sgroesz/kasm-core-ubuntu-noble:1.18.0-local      b3f78003b10b       3.65GB             0B        
stages:stage1                                    80fe1c4335a1        698MB             0B        
stages:stage1-test                               d7563971b829        229MB             0B        
stages:stage2                                    8ec31b39213a       1.79GB             0B        
stages:stage2-test                               e5e76f01ef6a       1.65GB             0B        
stages:stage3                                    ab01a9ca3764        2.4GB             0B        
stages:stage4                                    b1d84be95f96       3.39GB             0B        
stages:stage4-test                               f2ec21beb61b       2.64GB             0B        
stages:stage5                                    17c855cfe77b       3.65GB             0B        
stages:stage6                                    b3f78003b10b       3.65GB             0B        
ubuntu:24.04                                     bbdabce66f1b       78.1MB             0B        

