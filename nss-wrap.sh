#!/bin/bash

# write mock passwd and group files
__username=$USER
__uid=${NSS_UID:-$(id -u)}

__groupname=cross-group
__gid=${NSS_GID:-$(id -g)}

echo "$__username:x:$__uid:$__uid:gecos:$HOME:/bin/bash" > $NSS_WRAPPER_PASSWD
echo "$__groupname:x:$__gid:" > $NSS_WRAPPER_GROUP

export LD_PRELOAD=/usr/lib/libnss_wrapper.so
