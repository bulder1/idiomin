#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
dir="$DC/addons/dict"
enables="$DC/addons/dict/enables"
disables="$DC/addons/dict/disables"
lgt=$(lnglss "$lgtl")
lgs=$(lnglss "$lgsl")
new_script="#!/bin/bash
# argument 1 = \"word\"
# e.g. languages: en
Name=\"\"
Language=\"\""

dialog_edit() {
    
    yad --text-info --title="$Name" \
    --name=Idiomind --class=Idiomind \
    --filename="$script" --print-all --always-print-result \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --buttons-layout=end --center --on-top \
    --width=490 --height=360 --borders=0 \
    --editable --fontname=monospace --margins=4 --wrap \
    --button=Cancel:1 \
    --button=Save:5 > "$DT/script.sh"
}

dict_list() {

    cd "$enables/"
    find . -not -name "*.$lgt" -and -not -name "*.auto" -type f \
    -exec mv --target-directory="$disables/" {} +
    
    while read -r dict; do
        if [ -n "$dict" ]; then
        echo 'TRUE'
        echo "$dict" | sed 's/\./\n/g'; fi
    done < <(ls "$enables/")
    
    while read -r dict; do
        if [ -n "$dict" ]; then
        echo 'FALSE'
        echo "$dict" | sed 's/\./\n/g'; fi
    done < <(ls "$disables/")
}

if [ "$1" = add_dlg ]; then

        if [[ "$2" = 2 ]]; then 
        script="$DT/new.sh"; else
        printf "$new_script" > "$DT/new.sh"
        script="$DT/new.sh"; fi
        Name="New script"
        Language=""
        dialog_edit
         
    if [ $? -eq 5 ]; then
        
        if [ -z "$(< "$DT/script.sh")" ]; then
        
        rm "$DT/script.sh"
        "$DS_a/Dics/cnfg.sh" & exit
            
        else
        Name=$(grep -o -P '(?<=Name=").*(?=")' "$DT/script.sh" | sed 's/\.//g')
        Language=$(grep -o -P '(?<=Language=").*(?=")' "$DT/script.sh" | sed 's/\.//g')
            
            if [ -n "$Name" ] && [ -n "$Language" ]; then
            mv -f "$DT/script.sh" "$disables/$Name.$Language"
            fi
            
        "$DS_a/Dics/cnfg.sh"
        fi
        
    else
        "$DS_a/Dics/cnfg.sh"
    fi

elif [ "$1" = edit_dlg ]; then

    [ "$2" = TRUE ] && stts=enables
    [ "$2" = FALSE ] && stts=disables
    script="$dir/$stts/$3.$4"
    Name="$3"
    Language="$4"
    dialog_edit

    if [ $? -eq 5 ]; then
    
        Name=$(grep -F "Name=" "$script" | grep -o -P '(?<=Name=").*(?=")' | sed 's/\.//g')
        Language=$(grep -F "Language=" "$script" | grep -o -P '(?<=Language=").*(?=")' | sed 's/\.//g')
        [ -z "$Name" ] && Name="$3"
        [ -z "$Language" ] && Language="$4"
            
        if [ -z "$(< "$DT/script.sh")" ]; then
        rm "$DT/script.sh" "$dir/$stts/$Name.$Language" & exit
        else
        mv -f "$DT/script.sh" "$dir/$stts/$Name.$Language" & exit
        fi
        
    fi
    
elif [ -z "${1}" ]; then

    if [ ! -d "$DC_a/dict/" ]; then
        mkdir -p "$enables"
        mkdir -p "$disables"
        cp -f "$DS/addons/Dics/disables"/* "$disables/"
    fi
    
    [[ "${2}" = f ]] && tex="--text=$3" || tex="--center"
    sel="$(dict_list | yad --list --title="$(gettext "Dictionaries")" \
    --name=Idiomind --class=Idiomind "$tex" \
    --print-all --always-print-result --separator=" " \
    --dclick-action='/usr/share/idiomind/addons/Dics/cnfg.sh edit_dlg' \
    --window-icon="$DS/images/icon.png" \
    --expand-column=2 --skip-taskbar --center --on-top \
    --width=450 --height=300 --borders=10 \
    --column=" ":CHK \
    --column="$(gettext "Available dictionaries")":TEXT \
    --column="$(gettext "Lang")  ":TEXT \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Add")":2 \
    --button=OK:0)"
    ret=$?
    
        if [ $ret -eq 2 ]; then
        
                "$DS_a/Dics/cnfg.sh" add_dlg
        
        elif [ $ret -eq 0 ]; then
        
            n=1
            while [ ${n} -le "$(echo "$sel" | wc -l)" ]; do
            
                dict=$(echo "$sel" | sed -n ${n}p)
                d=$(echo "$dict" | awk '{print ($2)}')
                
                if echo "$dict" | grep 'FALSE'; then
                    if [ ! -f "$disables/$d.$lgt" ]; then
                        [ -f "$enables/$d.$lgt" ] \
                        && mv -f "$enables/$d.$lgt" "$disables/$d.$lgt"
                    fi
                    if [ ! -f "$disables/$d.auto" ]; then
                        [ -f "$enables/$d.auto" ] \
                        && mv -f "$enables/$d.auto" "$disables/$d.auto"
                    fi
                fi
                if echo "$dict" | grep 'TRUE'; then
                    if [ ! -f "$enables/$d.$lgt" ]; then
                        [ -f "$disables/$d.$lgt" ] \
                        && mv -f "$disables/$d.$lgt" "$enables/$d.$lgt"
                    fi
                    if [ ! -f "$enables/$d.auto" ]; then
                        [ -f "$disables/$d.auto" ] \
                        && mv -f "$disables/$d.auto" "$enables/$d.auto"
                    fi
                fi
                let n++
            done
        fi
        
    rm -f "$DT/new.sh" "$DT/script.sh"
    exit 1
fi
