#!/bin/bash
# -*- ENCODING: UTF-8 -*-

u=$(echo "$(whoami)")
nmt=$(sed -n 1p /tmp/.idmtp1.$u/idmimp_X015x/ls)
dir="/tmp/.idmtp1.$u/idmimp_X015x/$nmt"
wth=$(sed -n 5p $HOME/.config/idiomind/s/cfg.18)
eht=$(sed -n 6p $HOME/.config/idiomind/s/cfg.18)
re='^[0-9]+$'
now="$1"
nuw="$2"
cd "$dir"

if ! [[ $nuw =~ $re ]]; then
nuw=$(cat "$dir/cfg.0" | grep -Fxon "$now" \
| sed -n 's/^\([0-9]*\)[:].*/\1/p')
nll='echo  " "'
fi
item="$(sed -n "$nuw"p "$dir/cfg.0")"
if [ -z "$item" ]; then
item="$(sed -n 1p "$dir/cfg.0")"
nuw=1
fi

fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"

if [ -f "$dir/words/$fname.mp3" ]; then
        file="$dir/words/$fname.mp3"
        listen="--button=Listen:play '$dir/words/$fname.mp3'"

    tgs=$(eyeD3 "$file")
    trgt=$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
    src=$(echo "$tgs" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
    exmp=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
    exm1=$(echo "$exmp" | sed -n 1p)
    dftn=$(echo "$exmp" | sed -n 2p)
    ntes=$(echo "$exmp" | sed -n 3p)
    dfnts="--field=<i><span color='#696464'>$dftn</span></i>\\n:lbl"
    ntess="--field=<span color='#868686'>$ntes</span>\\n:lbl"
    exmp1=$(echo "$exm1" | sed "s/"$trgt"/<span background='#F8F4A2'>"$trgt"<\/\span>/g")
    
    yad --columns=1 --form --width=$wth --height=$eht --center \
    --window-icon=idiomind --scroll --text-align=center \
    --skip-taskbar --center --title="$MPG " --borders=20 \
    --quoted-output --on-top --selectable-labels \
    --text="<big><big><big><b>$trgt</b></big></big></big>\n\n<i>$src</i>\n\n" \
    --field="":lbl --field="<i><span color='#808080'>$exmp1 \
</span></i>\\n:lbl" "$dfnts" "$ntess" \
    "$listen" --button=gtk-go-up:3 --button=gtk-go-down:2

elif [ -f "$dir/$fname.mp3" ]; then
        file="$dir/$fname.mp3"
        listen="--button=Listen:play '$dir/$fname.mp3'"
    
    dwck="/tmp/.idmtp1.$u/p2.X015x"
    tgs=$(eyeD3 "$file")
    trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
    src=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
    lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
    
    echo "$lwrd" | awk '{print $0""}' | yad --list \
    --window-icon=idiomind --scroll --no-headers \
    --skip-taskbar --center --title=" " --borders=15 \
    --on-top --selectable-labels --expand-column=0 \
    --text="<big><big>$trgt</big></big>\\n\\n<i>$src</i>\\n\\n" \
    --width=$wth --height=$eht --center \
    --column="":TEXT --column="":TEXT \
    "$listen" --button=gtk-go-up:3 --button=gtk-go-down:2 \
    --dclick-action="$dwck"
    
else
    ff=$(($nuw + 1))
    echo "_" >> $DT/sc
    [[ $(cat $DT/sc | wc -l) -ge 5 ]] && rm -f $DT/sc & exit 1 \
    || /tmp/.idmtp1.$u/p1.X015x "$nll" "$ff" & exit 1
fi

ret=$?
if [[ $ret -eq 2 ]]; then
ff=$(($nuw + 1))
/tmp/.idmtp1.$u/p1.X015x "$nll" "$ff" &
elif [[ $ret -eq 3 ]]; then
ff=$(($nuw - 1))
/tmp/.idmtp1.$u/p1.X015x "$nll" "$ff" &
exit 1
fi

