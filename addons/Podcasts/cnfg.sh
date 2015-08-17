#!/bin/bash
# -*- ENCODING: UTF-8 -*-

a="$(gettext "Tell us if you think this is an error.")"
b="$(gettext "New episodes <i><small>Podcasts</small></i>")"
c="$(gettext "Saved episodes <i><small>Podcasts</small></i>")"
CNF="$(gettext "Configure")"
[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
DMC="$DM_tl/Podcasts/cache"
DCP="$DM_tl/Podcasts/.conf"
DMP="$DM_tl/Podcasts"
DSP="$DS_a/Podcasts"
dfimg="$DSP/images/audio.png"
date=$(date +%d)

# Downloads by each feed. Recomended=2
downloads=2
# rsync delete: disable 0/enable 1
rsync_delete=0


function dlg_config() {
    
    sets=( 'update' 'sync' 'path' 'video' 'nsepi' 'svepi' )
    if [[ -n "$(< "$DCP/podcasts.cfg")" ]]; then cfg=1
    else cfg=0; > "$DCP/podcasts.cfg"; fi

    ini() {
        
        mkdir "$DM_tl/Podcasts"
        mkdir "$DM_tl/Podcasts/.conf"
        mkdir "$DM_tl/Podcasts/cache"
        cd "$DM_tl/Podcasts/.conf/"
        touch "./podcasts.cfg" "./1.lst" "./2.lst" \
        "./feeds.lst" "./old.lst"
        echo 11 > "$DM_tl/Podcasts/.conf/8.cfg"
        echo " " > "$DM_tl/Podcasts/.conf/info"
        echo -e "\n$(gettext "Latest downloads:") 0" \
        > "$DM_tl/Podcasts/$date.updt"
        "$DS/mngr.sh" mkmn
    }

    if [ ! -d "$DM_tl/Podcasts" ]; then ini; fi
    [ -e "$DT/cp.lock" ] && exit || touch "$DT/cp.lock"
    [ ! -f "$DCP/feeds.lst" ] && touch "$DCP/feeds.lst"

    n=1
    while read -r feed; do
        declare url${n}="$feed"
        ((n=n+1))
    done < "$DCP/feeds.lst"

    n=0
    if [ ${cfg} = 1 ]; then

        while [ ${n} -lt 3 ]; do
        get="${sets[${n}]}"
        val=$(grep -o "$get"=\"[^\"]* "$DCP/podcasts.cfg" |grep -o '[^"]*$')
        declare ${sets[${n}]}="$val"
        ((n=n+1))
        done
        
    else
        while [ ${n} -lt 6 ]; do
        echo -e "${sets[${n}]}=\"FALSE\"" >> "$DCP/podcasts.cfg"
        ((n=n+1))
        done
    fi

    apply() {
        
        printf "$CNFG" |sed 's/|/\n/g' |sed -n 4,15p | \
        sed 's/^ *//; s/ *$//g' > "$DT/podcasts.tmp"
        n=1
        while read feed; do
            declare mod${n}="${feed}"
            mod="mod${n}"; url="url${n}"
            if [ "${!url}" != "${!mod}" ]; then
            "$DSP/cnfg.sh" set_channel "${!mod}" ${n} & fi
            if [ ! -s "$DCP/${n}.rss" ]; then
            "$DSP/cnfg.sh" set_channel "${!mod}" ${n} & fi
            ((n=n+1))
        done < "$DT/podcasts.tmp"

        podcaststmp="$(cat "$DT/podcasts.tmp")"
        if [ -n "$podcaststmp" ] && [[ "$podcaststmp" != "$(cat "$DCP/feeds.lst")" ]]; then
        mv -f "$DT/podcasts.tmp" "$DCP/feeds.lst"; else rm -f "$DT/podcasts.tmp"; fi

        val1=$(cut -d "|" -f1 <<<"$CNFG")
        val2=$(cut -d "|" -f2 <<<"$CNFG")
        val3=$(cut -d "|" -f19 <<<"$CNFG" | sed 's|/|\\/|g')
        if [ ! -d "$val3" -o -z "$val3" ]; then path=FALSE; fi
        sed -i "s/update=.*/update=\"$val1\"/g" "$DCP/podcasts.cfg"
        sed -i "s/sync=.*/sync=\"$val2\"/g" "$DCP/podcasts.cfg"
        sed -i "s/path=.*/path=\"${val3}\"/g" "$DCP/podcasts.cfg"
        [ -f "$DT/cp.lock" ] && rm -f "$DT/cp.lock"
    }

    if [ ! -d "$path" -o ! -n "$path" ]; then path=FALSE; fi
    if [ -f "$DM_tl/Podcasts/.conf/feed.err" ]; then
    e="$(head -n 4 < "$DM_tl/Podcasts/.conf/feed.err" |sed 's/\&/\&amp\;/g' |awk '!a[$0]++')"
    rm "$DM_tl/Podcasts/.conf/feed.err"
    (sleep 2 && msg "$e\n\t" info "$(gettext "Errors found")") &
    fi

    CNFG=$(yad --form --title="$(gettext "Podcasts settings")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all --separator="|" \
    --window-icon="$DS/images/icon.png" --center --scroll --on-top \
    --width=580 --height=380 --borders=10 \
    --text="$(gettext "Configure podcasts to language learning.")" \
    --field="$(gettext "Update at startup")":CHK "$update" \
    --field="$(gettext "Sync after update")":CHK "$sync" \
    --field="$(gettext "URL")":LBL " " \
    --field="" "${url1}" --field="" "${url2}" --field="" "${url3}" \
    --field="" "${url4}" --field="" "${url5}" --field="" "${url6}" \
    --field="" "${url7}" --field="" "${url8}" --field="" "${url9}" \
    --field="" "${url10}" --field="" "${url11}" --field="" "${url12}" \
    --field="$(gettext "Discover podcasts")":FBTN "$DSP/cnfg.sh 'dpods'" \
    --field=" ":LBL " " \
    --field="$(gettext "Path where episodes should be synced")":LBL " " \
    --field="":DIR "$path" \
    --button="$(gettext "Remove")":"$DSP/cnfg.sh 'deleteall'" \
    --button="$(gettext "Syncronize")":5 \
    --button="$(gettext "Cancel")":1 \
    --button="gtk-ok":0)
    ret=$?

    if [ $ret -eq 0 ]; then apply
        
    elif [ $ret -eq 5 ]; then apply && "$DSP/cnfg.sh" sync 1
    
    fi
    [ -f "$DT/cp.lock" ] && rm -f "$DT/cp.lock"
    exit
}


function podmode() {

    tpa="$(sed -n 1p "$DC_a/4.cfg")"
    if [[ "$tpa" != 'Podcasts' ]]; then
    [ ! -f "$DM_tl/Podcasts/.conf/8.cfg" ] \
    && echo 11 > "$DM_tl/Podcasts/.conf/8.cfg"
    echo "Podcasts" > "$DC_a/4.cfg"; fi
    
    if [[ ${2} = 2 ]]; then
    echo "Podcasts" > "$DC_s/7.cfg"
    echo 2 > "$DC_s/5.cfg"; fi

    nmfile() { echo -n "${1}" | md5sum | rev | cut -c 4- | rev; }

    function _list_1() {
        while read list1; do
            if [ -f "$DMP/cache/$(nmfile "$list1").png" ]; then
            echo "$DMP/cache/$(nmfile "$list1").png"
            else echo "$DS_a/Podcasts/images/audio.png"; fi
            echo "$list1"
        done < "$DCP/1.lst"
    }

    function _list_2() {
        while read list2; do
            if [ -f "$DMP/cache/$(nmfile "$list2").png" ]; then
            echo "$DMP/cache/$(nmfile "$list2").png"
            else echo "$DS_a/Podcasts/images/audio.png"; fi
            echo "$list2"
        done < "$DCP/2.lst"
    }

    nt="$DCP/info"
    fdit=$(mktemp "$DT/fdit.XXXX")
    c=$(echo $(($RANDOM%100000))); KEY=$c
    [ -f "$DT/.uptp" ] && info="$(gettext "Updating Podcasts")..." || info="$(gettext "Podcasts")"
    infolabel="$(< "$DMP"/*.updt)"
    
    _list_1 | yad --list --tabnum=1 \
    --plug=$KEY --print-all --dclick-action="$DSP/cnfg.sh vwr" \
    --no-headers --expand-column=2 --ellipsize=END \
    --column=Name:IMG \
    --column=Name:TXT &
    _list_2 | yad --list --tabnum=2 \
    --plug=$KEY --print-all --dclick-action="$DSP/cnfg.sh vwr" \
    --no-headers --expand-column=2 --ellipsize=END \
    --column=Name:IMG \
    --column=Name:TXT &
    yad --text-info --tabnum=3 \
    --text="<small>$infolabel</small>" \
    --plug=$KEY --filename="$nt" \
    --wrap --editable --fore='gray30' \
    --show-uri --margins=14 --fontname='vendana 11' > "$fdit" &
    yad --notebook --title="Idiomind - $info" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --window-icon="$DS/images/icon.png" --image-on-top \
    --ellipsize=END --align=right --center --fixed \
    --width=640 --height=560 --borders=2 --tab-borders=5 \
    --tab=" $(gettext "Episodes") " \
    --tab=" $(gettext "Saved episodes") " \
    --tab=" $(gettext "Notes") " \
    --button="$(gettext "Play")":"$DS/play.sh play_list" \
    --button="$(gettext "Update")":2 \
    --button="gtk-close":1
    ret=$?
        
    if [ $ret -eq 2 ]; then
    "$DSP/cnfg.sh" update 1; fi
    
    note_mod="$(< $fdit)"
    if [ "$note_mod" != "$(< $nt)" ]; then
    mv -f "$fdit" "$nt"; fi
    
    [ -f "$fdit" ] && rm -f "$fdit"
}


function update() {
    
    include "$DS/ifs/mods/add"
    tmplitem="<?xml version='1.0' encoding='UTF-8'?>
    \r<xsl:stylesheet version='1.0'
    \rxmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    \rxmlns:itunes='http://www.itunes.com/dtds/podcast-1.0.dtd'
    \rxmlns:media='http://search.yahoo.com/mrss/'
    \rxmlns:atom='http://www.w3.org/2005/Atom'>
    \r<xsl:output method='text'/>
    \r<xsl:template match='/'>
    \r<xsl:for-each select='/rss/channel/item'>
    \r<xsl:value-of select='enclosure/@url'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='media:cache[@type=\"audio/mpeg\"]/@url'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='title'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='media:cache[@type=\"audio/mpeg\"]/@duration'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='itunes:summary'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='description'/><xsl:text>EOL</xsl:text>
    \r</xsl:for-each>
    \r</xsl:template>
    \r</xsl:stylesheet>"
    sets=( 'channel' 'link' 'logo' 'ntype' 'nmedia' 'ntitle' 'nsumm' 'nimage' 'url' )

    conditions() {
        
        [ ! -f "$DCP/1.lst" ] && touch "$DCP/1.lst"
        [ ! -f "$DCP/2.lst" ] && touch "$DCP/2.lst"

        if [ -f "$DT/.uptp" ] && [[ ${1} = 1 ]]; then
            msg_2 "$(gettext "Wait until it finishes a previous process").\n" info OK gtk-stop "$(gettext "Updating...")"
            ret=$?
            [ $ret -eq 1 ] && "$DS/stop.sh" 6
            exit 1
        
        elif [ -f "$DT/.uptp" ] && [[ ${1} = 0 ]]; then
            exit 1
        fi
        
        if [ -f "$DCP/2.lst" ] && [[ `wc -l < "$DCP/2.lst"` != `wc -l < "$DCP/.2.lst"` ]]; then
        cp "$DCP/.2.lst" "$DCP/2.lst"; fi
        if [ -f "$DCP/1.lst" ] && [[ `wc -l < "$DCP/1.lst"` != `wc -l < "$DCP/.1.lst"` ]]; then
        cp "$DCP/.1.lst" "$DCP/1.lst"; fi
        if [[ "$(< "$DCP/8.cfg")" != 11 ]]; then
        echo 11 > "$DCP/8.cfg"; fi

        if [ ! -d "$DM_tl/Podcasts/cache" ]; then
        mkdir -p "DM_tl/Podcasts/.conf"
        mkdir -p "DM_tl/Podcasts/cache"; fi
        [ ! -f "$DCP/old.lst" ] && touch "$DCP/old.lst"

        if [[ `sed '/^$/d' "$DCP/feeds.lst" | wc -l` -le 0 ]]; then
        [[ ${1} = 1 ]] && msg "$(gettext "Missing URL. Please check the settings in the preferences dialog.")\n" info
        [ -f "$DT_r" ] && rm -fr "$DT_r" "$DT/.uptp"
        exit 1; fi
            
        if [[ ${1} = 1 ]]; then internet; else curl -v www.google.com 2>&1 \
        | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || exit 1; fi
    }

    mediatype() {

        if echo "$1" | grep -q ".mp3"; then ex=mp3; tp=aud
        elif echo "$1" | grep -q ".mp4"; then ex=mp4; tp=vid
        elif echo "$1" | grep -q ".ogg"; then ex=ogg; tp=aud
        elif echo "$1" | grep -q ".m4v"; then ex=m4v; tp=vid
        elif echo "$1" | grep -q ".mov"; then ex=mov; tp=vid
        elif echo "$1" | grep -o ".pdf"; then ex=pdf; tp=txt
        else
        echo -e "$(gettext "Could not add some podcasts:")\n$FEED" >> "$DM_tl/Podcasts/.conf/feed.err"
        return; fi
    }

    mkhtml() {

        itm="$DMC/$fname.html"
        video="<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
        \r<link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/vwr.css\">
        \r<video width=640 height=380 controls>
        \r<source src=\"$fname.$ex\" type=\"video/mp4\">
        \rYour browser does not support the video tag.</video><br><br>
        \r<div class=\"title\"><h3><a href=\"$link\">$title</a></h3></div><br>
        \r<div class=\"summary\">$summary<br><br></div>"
        audio="<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
        \r<link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/vwr.css\">
        \r<br><div class=\"title\"><h2><a href=\"$link\">$title</a></h2></div><br>
        \r<div class=\"summary\"><audio controls><br>
        \r<source src=\"$fname.$ex\" type=\"audio/mpeg\">
        \rYour browser does not support the audio tag.</audio><br><br>
        \r$summary<br><br></div>"
        text="<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
        \r<link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/vwr.css\">
        \r<body><br><div class=\"title\"><h2><a href=\"$link\">$title</a></h2></div><br>
        \r<div class=\"summary\"><div class=\"image\">
        \r<img src=\"$fname.jpg\" alt=\"Image\" style=\"width:650px\"></div><br>
        \r$summary<br><br></div>
        \r</body>"

        if [[ ${tp} = vid ]]; then
            if [ $ex = m4v -o $ex = mp4 ]; then t=mp4
            elif [ $ex = avi ]; then t=avi; fi
            echo -e "${video}" |sed -e 's/^[ \t]*//' |tr -d '\n' > "$itm"

        elif [[ ${tp} = aud ]]; then
            echo -e "${audio}" |sed -e 's/^[ \t]*//' |tr -d '\n' > "$itm"

        elif [[ ${tp} = txt ]]; then
            echo -e "${text}" |sed -e 's/^[ \t]*//' |tr -d '\n' > "$itm"
        fi
    }

    get_images() {

        if [ "$tp" = aud ]; then
            
            cd "$DT_r"; p=TRUE; rm -f ./*.jpeg ./*.jpg
            wget -q -O- "$FEED" | grep -o '<itunes:image href="[^"]*' \
            | grep -o '[^"]*$' | xargs wget -c
            if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg')"
            elif ls | grep '.png'; then img="$(ls | grep '.png')"
            else img="$(ls | grep '.jpg')"; fi

            if [ ! -f "$DT_r/$img" ]; then
            cp -f "$DSP/images/audio.png" "$DMC/$fname.png"
            p=FALSE; fi

        elif [ "$tp" = vid ]; then
            
            cd "$DT_r"; p=TRUE; rm -f ./*.jpeg ./*.jpg
            mplayer -ss 60 -nosound -noconsolecontrols \
            -vo jpeg -frames 3 ./"media.$ex" >/dev/null

            if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg' | head -n1)"
            else img="$(ls | grep '.jpg' | head -n1)"; fi
            
            if [ ! -f "$DT_r/$img" ]; then
            cp -f "$DSP/images/audio.png" "$DMC/$fname.png"
            p=FALSE; fi
            
        elif [ "$tp" = txt ]; then
        
            cd "$DT_r"; p=TRUE
        
            img="media.$ex"
        fi
        
        if [ $p = TRUE -a -f "$DT_r/$img" ]; then
        layer="$DSP/images/layer.png"
        convert "$DT_r/$img" -interlace Plane -thumbnail 62x54^ \
        -gravity center -extent 62x54 -quality 100% tmp.png
        convert tmp.png -bordercolor white \
        -border 2 \( +clone -background black \
        -shadow 70x3+2+2 \) +swap -background transparent \
        -layers merge +repage tmp.png
        composite -compose Dst_Over tmp.png "${layer}" "$DMC/$fname.png"
        rm -f *.jpeg *.jpg *.png
        fi
    }

    fetch_podcasts() {

        n=1
        while read FEED; do

            if [ ! -z "$FEED" ]; then

                if [ ! -f "$DCP/${n}.rss" ]; then
                echo -e "$(gettext "Please, reconfigure this feed:")\n$FEED" >> "$DCP/feed.err"
                    
                else
                    d=0
                    while [ ${d} -lt 8 ]; do
                        itn=$((d+1)); get=${sets[${d}]}
                        val=$(sed -n ${itn}p "$DCP/${n}.rss" \
                        | grep -o "$get"=\"[^\"]* | grep -o '[^"]*$')
                        declare ${sets[${d}]}="$val"
                        ((d=d+1))
                    done
                    
                    if [ -z "${nmedia}" ]; then
                    > "$DCP/${n}.rss"
                    echo -e "$(gettext "Please, reconfigure this feed:")\n$FEED" >> "$DCP/feed.err"
                    continue; fi
                
                    if [ "$ntype" = 1 ]; then
                    
                        podcast_items="$(xsltproc - "${FEED}" < <(echo -e "${tmplitem}" \
                        |sed -e 's/^[ \t]*//' |tr -d '\n') 2> /dev/null)"
                        podcast_items="$(echo "${podcast_items}" | tr '\n' ' ' \
                        | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n ${downloads})"
                        podcast_items="$(echo "${podcast_items}" | sed '/^$/d')"
                        
                        while read -r item; do

                            fields="$(sed -r 's|-\!-|\n|g' <<<"${item}")"
                            enclosure=$(sed -n ${nmedia}p <<<"${fields}")
                            title=$(echo "${fields}" | sed -n ${ntitle}p | sed 's/\://g' \
                            | sed 's/\&quot;/\"/g' \
                            | sed 's/\&/\&amp;/g' | sed 's/^\s*./\U&\E/g' \
                            | sed 's/<[^>]*>//g' | sed 's/^ *//; s/ *$//; /^$/d')
                            summary=$(echo "${fields}" | sed -n ${nsumm}p)
                            fname="$(nmfile "${title}")"
                            
                            if [[ ${#title} -ge 300 ]] \
                            || [ -z "$title" ]; then
                            continue; fi
                                 
                            if ! grep -Fxo "${title}" < <(cat "$DCP/1.lst" "$DCP/2.lst" "$DCP/old.lst"); then
                            
                                enclosure_url=$(curl -sILw %"{url_effective}" --url "$enclosure" |tail -n 1)
                                mediatype "$enclosure_url"
                                
                                if [ ! -f "$DMC/$fname.$ex" ]; then
                                cd "$DT_r"; wget -q -c -T 51 -O ./"media.$ex" "$enclosure_url"
                                else cd "$DT_r"; mv -f "$DMC/$fname.$ex" ./"media.$ex"; fi
                                
                                e=$?
                                if [ $e = 0 ]; then
                                get_images
                                mv -f ./"media.$ex" "$DMC/$fname.$ex"
                                mkhtml

                                if [[ -s "$DCP/1.lst" ]]; then
                                sed -i -e "1i${title}\\" "$DCP/1.lst"
                                else echo "${title}" > "$DCP/1.lst"; fi
                                if grep '^$' "$DCP/1.lst"; then
                                sed -i '/^$/d' "$DCP/1.lst"; fi
                                echo "${title}" >> "$DCP/.1.lst"
                                echo "${title}" >> "$DT_r/log"
                                echo -e "channel=\"${channel}\"
                                \rlink=\"${link}\"
                                \rtitle=\"${title}\"" \
                                |sed -e 's/^[ \t]*//' \
                                |tr -d '\n' >> "$DMC/$fname.item"
                                fi
                            fi
                        done <<<"${podcast_items}"
                    fi
                fi
            else
                [ -f "$DCP/${n}.rss" ] && rm "$DCP/${n}.rss"
            fi
            
            let n++
        done < "$DCP/feeds.lst"
    }

    removes() {
        
        set -e
        check_index1 "$DCP/1.lst"
        if grep '^$' "$DCP/1.lst"; then
        sed -i '/^$/d' "$DCP/1.lst"; fi
        tail -n +51 < "$DCP/1.lst" |sed '/^$/d' >> "$DCP/old.lst"
        head -n 50 < "$DCP/1.lst" |sed '/^$/d' > "$DCP/kept"

        cd "$DMC"/
        while read item; do
        
            if ! grep -Fxq "$item" < <(cat "$DCP/2.lst" "$DCP/kept"); then
            fname=$(nmfile "$item")
            if [ -n "$fname" ]; then
            find . -type f -name "$fname.*" -exec rm {} +; fi
            fi
        done < "$DCP/old.lst"
        cd /

        while read k_item; do
        
           nmfile "${k_item}" >> "$DT/nmfile"
        done < <(cat "$DCP/1.lst" "$DCP/2.lst")
        
        while read r_item; do
        
           r_file=`basename "$r_item" |sed "s/\(.*\).\{4\}/\1/" |tr -d '.'`
           if ! grep -Fxq "${r_file}" "$DT/nmfile"; then
           [ -e "$DMC/$r_item" ] && rm "$DMC/$r_item"; fi
        done < <(find "$DMC" -type f)
        
        while read item; do
        
           fname="$(nmfile "${item}")"
            [ ! -e "$DMC/$fname.png" ] && cp "$dfimg" "$DMC/$fname.png"
            if [ -e "$DMC/$fname.html" -a -e "$DMC/$fname.item" ]; then
                continue
            else
            grep -vxF "$item" "$DCP/2.lst" > "$DT/rm.temp"
            sed '/^$/d' "$DT/rm.temp" > "$DCP/2.lst"
            grep -vxF "$item" "$DCP/1.lst" > "$DT/rm.temp"
            sed '/^$/d' "$DT/rm.temp" > "$DCP/1.lst"
            rm -f "$DT/rm.temp"
            fi
        done < <(cat "$DCP/2.lst" "$DCP/kept")

        mv -f "$DCP/kept" "$DCP/1.lst"
        check_index1 "$DCP/1.lst" "$DCP/2.lst"
        if grep '^$' "$DCP/1.lst"; then
        sed -i '/^$/d' "$DCP/1.lst"; fi
        if grep '^$' "$DCP/2.lst"; then
        sed -i '/^$/d' "$DCP/2.lst"; fi
        head -n 500 < "$DCP/old.lst" > "$DCP/old_.lst"
        mv -f "$DCP/old_.lst" "$DCP/old.lst"
        cp -f "$DCP/1.lst" "$DCP/.1.lst"
        rm "$DT/nmfile"
    }

    conditions ${2}

    if [[ ${2} = 1 ]]; then
    echo "Podcasts" > "$DC_a/4.cfg"
    echo 2 > "$DC_s/5.cfg"
    echo 11 > "$DCP/8.cfg"
    notify-send -i idiomind "$(gettext "Podcasts")" \
    "$(gettext "Checking for new episodes...")" -t 6000 &
    fi

    if [ -f "$DCP/2.lst" ]; then kept_episodes=`wc -l < "$DCP/2.lst"`
    else kept_episodes=0; fi
    echo $$ > "$DT/.uptp"; rm "$DM_tl/Podcasts"/*.updt
    echo -e "<b>$(gettext "Updating")</b>
    \r$(gettext "Latest downloads:") 0" \
    |sed -e 's/^[ \t]*//' |tr -d '\n' > "$DM_tl/Podcasts/$date.updt"
    DT_r="$(mktemp -d "$DT/XXXX")"
    fetch_podcasts

    if [ -f "$DT_r/log" ]; then new_episodes=`wc -l < "$DT_r/log"`
    else new_episodes=0; fi
    rm "$DM_tl/Podcasts"/*.updt
    echo -e "$(gettext "Last update:") $(date "+%r %a %d %B")
    \r$(gettext "Latest downloads:") $new_episodes" \
    |sed -e 's/^[ \t]*//' |tr -d '\n' > "$DM_tl/Podcasts/$date.updt"
    rm -fr "$DT_r" "$DT/.uptp"

    if [[ ${new_episodes} -gt 0 ]]; then
        [[ ${new_episodes} = 1 ]] && ne=$(gettext "new episode")
        [[ ${new_episodes} -gt 1 ]] && ne=$(gettext "new episodes")

        removes
        notify-send -i idiomind \
        "$(gettext "Update finished")" \
        "$new_episodes $ne" -t 8000
        
    else
        if [[ ${2} = 1 ]]; then
        notify-send -i idiomind \
        "$(gettext "Update finished")" \
        "$(gettext "Has not changed since last update")" -t 8000
        fi
    fi

    cfg="$DM_tl/Podcasts/.conf/podcasts.cfg"; if [ -f "$cfg" ]; then
    sync="$(grep -o 'sync="[^"]*' "$cfg" | grep -o '[^"]*$')"
    if [ "$sync" = TRUE ]; then

        if [[ ${2} = 1 ]]; then "$DSP/tls.sh" sync 1
        else "$DSP/tls.sh" sync 0; fi
    fi
    fi
    exit
}


function vwr() {
    
    DSP="$DS/addons/Podcasts"
    export item="${3}"
    dir="$DM_tl/Podcasts/cache"
    fname=$(echo -n "${item}" | md5sum | rev | cut -c 4- | rev)
    channel="$(grep -o channel=\"[^\"]* "$dir/${fname}.item" |grep -o '[^"]*$')"
    if grep -Fxo "${item}" "$DM_tl/Podcasts/.conf/2.lst"; then
    btnlabel="gtk-delete"
    btncmd="'$DSP/cnfg.sh' delete_item"; else
    btnlabel="$(gettext "Save")"
    btncmd="'$DSP/cnfg.sh' new_item"; fi
    btncmd2="'$DSP/cnfg.sh' sv_as"
    if [ -f "$dir/$fname.html" ]; then
    uri="$dir/$fname.html"; else
    source "$DS/ifs/mods/cmns.sh"
    msg "$(gettext "No such file or directory")\n${topic}\n" error Error & exit 1; fi

    yad --html --title="${channel}" \
    --name=Idiomind --class=Idiomind \
    --encoding=UTF-8 --uri="${uri}" \
    --window-icon="$DS/images/icon.png" --center --on-top \
    --width=680 --height=550 --borders=0 \
    --button=gtk-save-as:"${btncmd2}" \
    --button="${btnlabel}":"${btncmd}" \
    --button="gtk-close":1
}


function set_channel() {

    tmpl1="<?xml version='1.0' encoding='UTF-8'?>
    \r<xsl:stylesheet version='1.0'
    \rxmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    \rxmlns:itunes='http://www.itunes.com/dtds/podcast-1.0.dtd'
    \rxmlns:media='http://search.yahoo.com/mrss/'
    \rxmlns:atom='http://www.w3.org/2005/Atom'>
    \r<xsl:output method='text'/>
    \r<xsl:template match='/'>
    \r<xsl:for-each select='/rss/channel'>
    \r<xsl:value-of select='title'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='link'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='image'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='image/@url'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='itunes:image[@type=\"image/jpeg\"]/@href'/><xsl:text>-!-</xsl:text>
    \r</xsl:for-each>
    \r</xsl:template>
    \r</xsl:stylesheet>"

    tmpl2="<?xml version='1.0' encoding='UTF-8'?>
    \r<xsl:stylesheet version='1.0'
    \rxmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    \rxmlns:itunes='http://www.itunes.com/dtds/podcast-1.0.dtd'
    \rxmlns:media='http://search.yahoo.com/mrss/'
    \rxmlns:atom='http://www.w3.org/2005/Atom'>
    \r<xsl:output method='text'/>
    \r<xsl:template match='/'>
    \r<xsl:for-each select='/rss/channel/item'>
    \r<xsl:value-of select='enclosure/@url'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='media:cache[@type=\"audio/mpeg\"]/@url'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='title'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='media:cache[@type=\"audio/mpeg\"]/@duration'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='itunes:summary'/><xsl:text>-!-</xsl:text>
    \r<xsl:value-of select='description'/><xsl:text>EOL</xsl:text>
    \r</xsl:for-each>
    \r</xsl:template>
    \r</xsl:stylesheet>"

    if [[ -z "${2}" ]]; then
    [ -f "$DIR2/$3.rss" ] && rm "$DIR2/$3.rss"; exit 1; fi
    feed="${2}"
    num="${3}"
    DIR2="$DM_tl/Podcasts/.conf"
    xml="$(xsltproc - "${feed}" < <(echo -e "${tmpl1}" \
    |sed -e 's/^[ \t]*//' |tr -d '\n') 2> /dev/null)"
    items1="$(echo "${xml}" | tr '\n' ' ' | tr -s '[:space:]' \
    | sed 's/EOL/\n/g' | head -n 1 | sed -r 's|-\!-|\n|g')"
    xml="$(xsltproc - "${feed}" < <(echo -e "${tmpl2}" \
    |sed -e 's/^[ \t]*//' |tr -d '\n') 2> /dev/null)"
    items2="$(echo "${xml}" | tr '\n' ' ' | tr -s "[:space:]" \
    | sed 's/EOL/\n/g' | head -n 1 | sed -r 's|-\!-|\n|g')"

    fchannel() {
        
        n=1;
        while read -r get; do
            if [[ $(wc -w <<<"${get}") -ge 1 ]] && [ -z "${name}" ]; then
            name="${get}"
            n=2; fi
            if [[ -n "$(grep 'http:/' <<<"${get}")" ]] && [ -z "${link}" ]; then
            link="${get}"
            n=3; fi
            if [[ -n "$(grep -E '.jpeg|.jpg|.png' <<<"${get}")" ]] && [ -z "${logo}" ]; then
            logo="${get}"; fi
            let n++
        done <<<"${items1}"
    }
    
    ftype1() {
        
        n=1
        while read -r get; do
            [[ ${n} = 3 || ${n} = 5 || ${n} = 6 ]] && continue
            if [ -n "$(grep -o -E '\.mp3|\.mp4|\.ogg|\.avi|\.m4v|\.mov|\.flv' <<<"${get}")" ] && [ -z "${media}" ]; then
            media="$n"; type=1; break; fi
            let n++
        done <<<"${items2}"
        f3="$(sed -n 3p <<<"${items2}")"
        f5="$(sed -n 5p <<<"${items2}")"
        f6="$(sed -n 6p <<<"${items2}")"
        if [ $(wc -w <<<"$f3") -ge 2 ] && [ "$(wc -w <<<"${f3}")" -le 200 ]; then
        title=3; fi
        if [ $(wc -w <<<"${f5}") -ge 2 ] && [ -n "$(grep -o -E '\<|\>|/>' <<<"${f5}")" ]; then
        sum1=5; fi
        if [ $(wc -w <<<"${f6}") -ge 2 ] && [ -n "$(grep -o -E '\<|\>|/>' <<<"${f6}")" ]; then
        sum1=6; fi
        if [ $(wc -w <<<"${f5}") -ge 2 ]; then
        sum2=5; fi
        if [ $(wc -w <<<"${f6}") -ge 2 ]; then
        sum2=6; fi
    }
    
    ftype2() {

        n=1
        while read -r get; do
            if [ -n "$(grep -o -E '\.jpg|\.jpeg|\.png' <<<"${get}")" ] && [ -z "${image}" ]; then
            image="$n"; type=2; break ; fi
            let n++
        done <<<"${items3}"
        n=4
        while read -r get; do
            if [ $(wc -w <<<"${get}") -ge 1 ] && [ -z "${title}" ]; then
            title="$n"; break ; fi
            let n++
        done <<<"{$items3}"
        n=6
        while read -r get; do
            if [ $(wc -w <<<"${get}") -ge 1 ] && [ -z "${summ}" ]; then
            summ="$n"; break ; fi
            let n++
        done <<<"${items3}"
    }

    get_summ() {

        n=1
        while read -r get; do
            if [ $(wc -w <<<"${get}") -ge 1 ]; then
            summ="$n"; break; fi
            let n++
        done <<<"${items3}"
    }
    
    fchannel
    ftype1

    if [ -z $sum2 ]; then
    summary="${sum1}"; else
    summary="${sum2}"; fi
    if [[ -n "${title}" && -n "${summary}" \
    && -z "${image}" && -z "${media}" ]]; then
    type=3; fi
    
    if [[ ${type} = 1 ]]; then
        
        cfg="channel=\"$name\"
        \rlink=\"$link\"
        \rlogo=\"$logo\"
        \rntype=\"$type\"
        \rnmedia=\"$media\"
        \rntitle=\"$title\"
        \rnsumm=\"$summary\"
        \rnimage=\"$image\"
        \rurl=\"$feed\""
        echo -e "${cfg}" |sed -e 's/^[ \t]*//' \
        |tr -d '\n' > "$DIR2/$num.rss"; exit
        
    else
        url="$(tr '&' ' ' <<<"${feed}")"
        msg "<b>$(gettext "Specified URL doesn't seem to contain any feeds:")</b>\n$url\n" dialog-warning Idiomind &
        > "$DIR2/$num.rss"
        rm -f "$DT/cpt.lock"; exit 1
    fi
}


function sync() {
   
    DIR2="$DM_tl/Podcasts/.conf"
    cfg="$DM_tl/Podcasts/.conf/podcasts.cfg"
    path="$(grep -o 'path="[^"]*' "$cfg" | grep -o '[^"]*$')"
    
    if  [ -f "$DT/l_sync" ] && [[ $2 = 1 ]]; then
    msg_2 "$(gettext "A process is already running!\nIf stopped, any rsync process will stop")" info "OK" "gtk-stop" "$(gettext "Syncing...")"
    e=$?
        
        if [[ $e -eq 1 ]]; then
        killall rsync
        if ps -A | pgrep -f "rsync"; then killall rsync; fi
        [ -f "$DT/cp.lock" ] && rm -f "$DT/cp.lock"
        [ -f "$DT/l_sync" ] && rm -f "$DT/l_sync"
        killall cnfg.sh
        exit 1; fi
            
    elif  [ -f "$DT/l_sync" ] && [[ $2 = 0 ]]; then exit 1

    elif [ ! -d "$path" ] && [[ $2 = 1 ]]; then
    msg " $(gettext "The directory to synchronization does not exist.")\n" \
    dialog-warning
    [ -f "$DT/l_sync" ] && rm -f "$DT/l_sync"; exit 1
    
    elif  [ ! -d "$path" ] && [[ $2 = 0 ]]; then
    echo "Synchronization error. Missing path" >> "$DM_tl/Podcasts/.conf/feed.err"
    [ -f "$DT/l_sync" ] && rm -f "$DT/l_sync"; exit 1
    
    elif [ -d "$path" ]; then
        
        touch "$DT/l_sync"; SYNCDIR="$path/"
        cd /

        if [[ $rsync_delete = 0 ]]; then
        
            rsync -amz --stats --exclude="*.item" --exclude="*.png" \
            --exclude="*.html" --omit-dir-times --ignore-errors \
            --log-file="$DT/l_sync" "$DM_tl/Podcasts/cache/" "$SYNCDIR"
            exit=$?
            
        elif [[ $rsync_delete = 1 ]]; then
        
            rsync -amz --stats --delete --exclude="*.item" --exclude="*.png" \
            --exclude="*.html" --omit-dir-times --ignore-errors \
            --log-file="$DT/l_sync" "$DM_tl/Podcasts/cache/" "$SYNCDIR"
            exit=$?
        fi
        
        if [[ $exit != 0 ]]; then
        
            if [[ $2 = 1 ]]; then
            (sleep 1 && notify-send -i idiomind \
            "$(gettext "Error")" \
            "$(gettext "Error while syncing")" -t 8000) &
            elif [[ $2 = 0 ]]; then
            echo "$(gettext "Error while syncing") - $(cat "$DT/l_sync")" >> "$DM_tl/Podcasts/.conf/feed.err"
            fi
        fi
        [ -f "$DT/l_sync" ] && rm -f "$DT/l_sync"; exit
    fi
}


function disc_podscats() {

    [ "$lgtl" = English ] && src="\"podcasts learning English\" OR \"$(gettext "podcasts learning English")\""
    [ "$lgtl" = French ] && src="\"podcasts learning French\" OR \"$(gettext "podcasts to learn French")\""
    [ "$lgtl" = German ] && src="\"podcasts learning German\" OR \"$(gettext "podcasts to learn German")\""
    [ "$lgtl" = Chinese ] && src="\"podcasts learning Chinese\" OR \"$(gettext "podcasts to learn Chinese")\""
    [ "$lgtl" = Italian ] && src="\"podcasts learning Italian\" OR \"$(gettext "podcasts to learn Italian")\""
    [ "$lgtl" = Japanese ] && src="\"podcasts learning Japanese\" OR \"$(gettext "podcasts to learn Japanese")\""
    [ "$lgtl" = Portuguese ] && src="\"podcasts learning Portuguese\" OR \"$(gettext "podcasts to learn Portuguese")\""
    [ "$lgtl" = Spanish ] && src="\"podcasts learning Spanish\" OR \"$(gettext "podcasts to learn Spanish")\""
    [ "$lgtl" = Vietnamese ] && src="\"podcasts learning Vietnamese\" OR \"$(gettext "podcasts to learn Vietnamese")\""
    [ "$lgtl" = Russian ] && src="\"podcasts learning Russian\" OR \"$(gettext "podcasts to learn Russian")\""
    xdg-open https://www.google.com/search?q="$src"

} >/dev/null 2>&1


function new_item() {

    DMC="$DM_tl/Podcasts/cache"
    DCP="$DM_tl/Podcasts/.conf"
    fname="$(nmfile "${item}")"
    if [ -s "$DCP/2.lst" ]; then
    sed -i -e "1i$item\\" "$DCP/.2.lst"
    sed -i -e "1i$item\\" "$DCP/2.lst"
    else
    echo "$item" > "$DCP/.2.lst"
    echo "$item" > "$DCP/2.lst"; fi
    check_index1 "$DCP/2.lst" "$DCP/.2.lst"
    notify-send -i info "$(gettext "Episode saved")" "$item" -t 3000
    exit
}


function save_as() {

    fname=$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)
    [ -f "$DMC/$fname.mp3" ] && file="$DMC/$fname.mp3"
    [ -f "$DMC/$fname.ogg" ] && file="$DMC/$fname.ogg"
    [ -f "$DMC/$fname.m4v" ] && file="$DMC/$fname.m4v"
    [ -f "$DMC/$fname.mp4" ] && file="$DMC/$fname.mp4"
    cd "$HOME"
    sv=$(yad --file --save --title="$(gettext "Save as")" \
    --filename="$item${file: -4}" \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --center --on-top \
    --width=600 --height=500 --borders=10 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Save")":0)
    ret=$?
    if [ $ret -eq 0 ]; then
    cp "$file" "$sv"; fi
}


function delete_item() {

    touch "$DT/ps_lk"
    fname="$(nmfile "${item}")"
    
    if ! grep -Fxo "$item" < "$DCP/1.lst"; then
    
        msg_2 "$(gettext "Are you sure you want to delete this episode here?")\n" gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"
        ret=$(echo "$?")
    
        if [ $ret -eq 0 ]; then
            
            [ -f "$DMC/$fname.mp3" ] && rm "$DMC/$fname.mp3"
            [ -f "$DMC/$fname.ogg" ] && rm "$DMC/$fname.ogg"
            [ -f "$DMC/$fname.mp4" ] && rm "$DMC/$fname.mp4"
            [ -f "$DMC/$fname.m4v" ] && rm "$DMC/$fname.m4v"
            [ -f "$DMC/$fname.flv" ] && rm "$DMC/$fname.flv"
            [ -f "$DMC/$fname.jpg" ] && rm "$DMC/$fname.jpg"
            [ -f "$DMC/$fname.png" ] && rm "$DMC/$fname.png"
            [ -f "$DMC/$fname.html" ] && rm "$DMC/$fname.html"
            [ -f "$DMC/$fname.item" ] && rm "$DMC/$fname.item"
            cd "$DCP"
            grep -vxF "$item" "$DCP/.2.lst" > "$DCP/.2.lst.tmp"
            sed '/^$/d' "$DCP/.2.lst.tmp" > "$DCP/.2.lst"
            grep -vxF "$item" "$DCP/2.lst" > "$DCP/2.lst.tmp"
            sed '/^$/d' "$DCP/2.lst.tmp" > "$DCP/2.lst"
            rm "$DCP"/*.tmp; fi

    else
        notify-send -i info "$(gettext "Episode removed")" "$item"
        cd "$DCP"
        grep -vxF "$item" "$DCP/.2.lst" > "$DCP/.2.lst.tmp"
        sed '/^$/d' "$DCP/.2.lst.tmp" > "$DCP/.2.lst"
        grep -vxF "$item" "$DCP/2.lst" > "$DCP/2.lst.tmp"
        sed '/^$/d' "$DCP/2.lst.tmp" > "$DCP/2.lst"
        rm "$DCP"/*.tmp
    fi
    rm -f "$DT/ps_lk"; exit 1
}


function deleteall() {
    
    if [[ "$(wc -l < "$DCP/2.lst")" -gt 0 ]]; then
    chk="--field="$(gettext "Also delete saved episodes")":CHK"; fi
    if [[ "$(wc -l < "$DCP/1.lst")" -lt 1 ]]; then exit 1; fi
    
    dl=$(yad --form --title="$(gettext "Confirm")" \
    --image=gtk-delete \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all --separator="|" \
    --window-icon="$DS/images/icon.png" --center --on-top \
    --width=400 --height=120 --borders=3 \
    --text="$(gettext "Are you sure you want to delete all episodes?")  " "$chk" \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Yes")":0)
    ret="$?"
            
    if [ $ret -eq 0 ]; then

        rm "$DM_tl/Podcasts/cache"/*
        rm "$DM_tl/Podcasts/.conf/1.lst"
        rm "$DM_tl/Podcasts/$date"
        touch "$DM_tl/Podcasts/.conf/1.lst"

        if [[ $(cut -d "|" -f1 <<<"$dl") = TRUE ]]; then

            rm "$DCP/2.lst" "$DCP/.2.lst"
            touch "$DCP/2.lst" "$DCP/.2.lst"
        fi
    fi
    exit
}


case "$1" in
    update)
    update "$@" ;;
    podmode)
    podmode "$@" ;;
    vwr)
    vwr "$@" ;;
    set_channel)
    set_channel "$@" ;;
    sync)
    sync "$@" ;;
    dpods)
    disc_podscats "$@" ;;
    new_item)
    new_item "$@" ;;
    save_as)
    save_as "$@" ;;
    delete_item)
    delete_item "$@" ;;
    deleteall)
    deleteall "$@" ;;
    *)
    dlg_config "$@" ;;
esac
