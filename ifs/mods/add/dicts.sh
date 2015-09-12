#!/bin/bash
# -*- ENCODING: UTF-8 -*-
cmsg() {
    zenity --question --class=Idiomind name=Idiomind \
    --title="$(gettext "Dictionaries")" --cancel-label="$(gettext "Cancel")" \
    --text="$(gettext "You may need to configure the list of Internet resources.\nDo you want to do this now?")"
    if [ $? = 0 ]; then s=1; "$DS_a/Dics/cnfg.sh" 6; fi
}
s=0
if [ ! -d "$DC_d" -o ! -d "$DC_a/dict/disables" ]; then
    mkdir -p "$DC_d"; mkdir -p "$DC_a/dict/disables"
    echo -e "$lgtl" > "$DC_a/dict/.dict"
    for re in "$DS_a/Dics/dicts"/*; do
        > "$DC_a/dict/disables/$(basename "$re")"
    done
fi
if  [ ! -f "$DC_a/dict/.dict" ]; then s=1
    echo -e "$lgtl" > "$DC_a/dict/.dict"
fi
if ! ls "$DC_d"/* 1> /dev/null 2>&1; then
    sleep 1; cmsg
    
fi
if  [[ `sed -n 1p "$DC_a/dict/.dict"` != $lgtl ]] ; then
    sleep 1; cmsg
fi
[ $s = 1 ] && echo -e "$lgtl" > "$DC_a/dict/.dict"
