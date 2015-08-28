#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
cfg="${DC_tlt}/10.cfg"
cfgp="$DM_tl/Podcasts/.conf/podcasts.cfg"
rplay="$(grep -o rplay=\"[^\"]* "${DC_tlt}/10.cfg" |grep -o '[^"]*$')"
ritem=0; stnrd=0; f=0

[ -z "${tpc}" -a ! -d "${DC_tlt}" ] && exit 1
export tpc DC_tlt cfg cfgp f ritem stnrd numer
export -f include msg

if [[ "$rplay" = TRUE ]]; then

    while [ 1 ]; do
        "$DS/chng.sh" 0
        sleep 10
    done
    
else
    "$DS/chng.sh" 0
    rm -fr "$DT/.p_" & exit 0
fi
