#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
lgt=$(lnglss $lgtl)
lgs=$(lnglss $lgsl)

idfile() {
    
b=$(tr -dc a-z < /dev/urandom |head -c 1)
c=$((RANDOM%100))
id="$b$c"
id=${id:0:3}
echo -e "usrid=\"$id\"
iuser=\"\"
cntct=\"\"" > "$DC_s/3.cfg"
}

[ ! -f "$DC_s/3.cfg" ] && idfile


vsd() {

    cd "$DM/backup"; ls -t *.idmnd | sed 's/\.idmnd//g' | \
    yad --list --title="$(gettext "Your Shared Topics")" \
    --name=Idiomind --class=Idiomind \
    --dclick-action="$DS/ifs/upld.sh 'infsd'" \
    --window-icon="$DS/images/icon.png" --center --on-top \
    --width=520 --height=380 --borders=10 \
    --print-column=1 --no-headers \
    --column=Nombre:TEXT \
    --button=gtk-close:1
    exit
} >/dev/null 2>&1

infsd() {

    file="$DM/backup/${2}.idmnd"
    usrid="$(grep -o 'usrid="[^"]*' < "$DC_s/3.cfg" |grep -o '[^"]*$')"
    language_source=$(grep -o 'langs="[^"]*' < "$file" |grep -o '[^"]*$')
    language_target=$(grep -o 'langt="[^"]*' < "$file" |grep -o '[^"]*$')
    category=$(grep -o 'ctgry="[^"]*' < "$file" |grep -o '[^"]*$')
    link=$(grep -o 'ilink="[^"]*' < "$file" |grep -o '[^"]*$')
    name=$(grep -o 'tname="[^"]*' < "$file" |grep -o '[^"]*$')
    lng=$(lnglss "$language_source")
    lnglbl="${language_target,,}"
    
    cd "$HOME"
    sleep 0.5
    sv=$(yad --file --save --title="$(gettext "Download")" \
    --filename="${2}.idmnd" \
    --window-icon="$DS/images/icon.png" --skip-taskbar --center --on-top \
    --width=600 --height=500 --borders=10 \
    --button="$(gettext "Cancel")":1 --button="gtk-save":0)
    ret=$?
    
    if [[ $ret -eq 0 ]]; then
        
        internet; cd "$DT"
        DOWNLOADS="$(curl http://idiomind.sourceforge.net/doc/SITE_TMP | \
        grep -o 'DOWNLOADS="[^"]*' | grep -o '[^"]*$')"
        file="$DOWNLOADS/${lng}/${lnglbl}/${category}/${link}.${name}.idmnd"
        [ -z "$DOWNLOADS" ] && msg "$(gettext "The server is not available at the moment.")" dialog-warning && exit
        
        WGET() {
        rand="$RANDOM `date`"
        pipe="/tmp/pipe.$(echo '$rand' | md5sum | tr -d ' -')"
        mkfifo "$pipe"
        wget -c "$1" 2>&1 | while read data;do
        if [ "`echo $data | grep '^Length:'`" ]; then
        total_size=$(echo $data | grep "^Length:" | sed 's/.*\((.*)\).*/\1/' | tr -d '()')
        fi
        if [ "$(echo $data | grep '[0-9]*%' )" ];then
        percent=$(echo $data | grep -o "[0-9]*%" | tr -d '%')
        echo "$percent"
        echo "# $(gettext "Downloading...")  $percent%"
        fi
        done > "$pipe" &
        wget_info=$(ps ax |grep "wget.*$1" |awk '{print $1"|"$2}')
        wget_pid=$(echo $wget_info | cut -d'|' -f1)
        yad --progress --title="$(gettext "Downloading")" \
        --progress-text=" " --auto-close \
        --window-icon="$DS/images/icon.png" \
        --skip-taskbar --no-buttons --on-top --fixed \
        --width=200 --height=50 --borders=4 --geometry=240x20-4-4 < "$pipe"

        if [ "$(ps -A |grep "$wget_pid")" ];then
        kill "$wget_pid"
        fi
        rm -f "$pipe"
        }
        WGET "${file}"
        
        if [ -f "$DT/$link.${name}.idmnd" ] ; then
        [ -f "$sv" ] && rm "$sv"
        mv -f "$DT/$link.${name}.idmnd" "$sv"
        else
        msg "$(gettext "The file is not yet available for download from the server.")\n" info & exit
        fi
    fi
    exit
}


function upld() {

if [ `wc -l < "${DC_tlt}/0.cfg"` -lt 2 ]; then
msg "$(gettext "Unavailable")\n" info "$(gettext "Unavailable")" & exit 1; fi

if [ "${tpc}" != "${2}" ]; then
msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit 1; fi

if [ -d "$DT/upload" ]; then
msg_2 "$(gettext "Wait until it finishes a previous process")\n" info OK gtk-stop "$(gettext "Warning")"
ret=$(echo "$?")
if [[ $ret -eq 1 ]]; then
rm -fr "$DT/upload"
"$DS/stop.sh" 5
fi
exit 1
fi

others="$(gettext "Others")"
comics="$(gettext "Comics")"
culture="$(gettext "Culture")"
family="$(gettext "Family")"
entertainment="$(gettext "Entertainment")"
grammar="$(gettext "Grammar")"
history="$(gettext "History")"
documentary="$(gettext "Documentary")"
in_the_city="$(gettext "In the city")"
movies="$(gettext "Movies")"
internet="$(gettext "Internet")"
music="$(gettext "Music")"
nature="$(gettext "Nature")"
news="$(gettext "News")"
office="$(gettext "Office")"
relations="$(gettext "Relations")"
sport="$(gettext "Sport")"
social_networks="$(gettext "Social networks")"
shopping="$(gettext "Shopping")"
technology="$(gettext "Technology")"
travel="$(gettext "Travel")"
article="$(gettext "Article")"
science="$(gettext "Science")"
interview="$(gettext "Interview")"
funny="$(gettext "Funny")"
lnglbl="${lgtl,,}"
usrid="$(grep -o 'usrid="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
iuser="$(grep -o 'iuser="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
cntct="$(grep -o 'cntct="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
if [ -z "$usrid" ] || [ ${#id} -gt 3 ]; then
b=$(tr -dc a-z < /dev/urandom |head -c 1)
usrid="$b$((RANDOM%1000))"
usrid=${usrid:0:3}; fi
[ -z "$iuser" ] && iuser=$USER
note=$(< "${DC_tlt}/info")
imgm="${DM_tlt}/images/img.jpg"

#"$DS/ifs/tls.sh" check_index "$tpc" # TODO ------------------------------------

if [ $(cat "${DC_tlt}/0.cfg" | wc -l) -ge 20 ]; then
btn="--button="$(gettext "Upload")":0"; else
btn="--center"; fi

cd "$HOME"
upld=$(yad --form --title="$(gettext "Share")" \
--text="<span font_desc='Free Sans Bold 10' color='#5A5A5A'>${tpc}</span>" \
--name=Idiomind --class=Idiomind \
--window-icon="$DS/images/icon.png" --buttons-layout=end \
--align=right --center --on-top \
--width=480 --height=460 --borders=12 \
--field=" :lbl" "#1" \
--field="$(gettext "Author")" "$iuser" \
--field="\t$(gettext "Contact (Optional)")" "$cntct" \
--field="$(gettext "Category"):CBE" \
"!$others!$article!$comics!$culture!$documentary!$entertainment!$funny!$family!$grammar!$history!$movies!$in_the_city!$interview!$internet!$music!$nature!$news!$office!$relations!$sport!$science!$shopping!$social_networks!$technology!$travel" \
--field="$(gettext "Skill Level"):CB" "!$(gettext "Beginner")!$(gettext "Intermediate")!$(gettext "Advanced")" \
--field="\n$(gettext "Description/Notes"):TXT" "${note}" \
--field="$(gettext "Image 600x150px"):FL" "${imgm}" \
--button="$(gettext "Cancel")":4 \
--button="$(gettext "PDF")":2 "$btn")
ret=$?

img=$(echo "${upld}" | cut -d "|" -f7)
if [ -f "${img}" ] && [ "${img}" != "${imgm}" ]; then
wsize="$(identify "${img}" | cut -d ' ' -f 3 | cut -d 'x' -f 1)"
esize="$(identify "${img}" | cut -d ' ' -f 3 | cut -d 'x' -f 2)"
if [ "$wsize" -gt 1000 ] || [ "$wsize" -lt 600 ] \
|| [ "$esize" -lt 100 ] || [ "$esize" -gt 400 ]; then
msg "$(gettext "Sorry, the image size is not suitable.")\n " info "$(gettext "Error")"
"$DS/ifs/upld.sh" upld "${tpc}" & exit 1; fi
/usr/bin/convert "${img}" -interlace Plane -thumbnail 600x150^ \
-gravity center -extent 600x150 \
-quality 100% "${DM_tlt}/images/img.jpg"
fi

if [[ $ret = 2 ]]; then
    "$DS/ifs/tls.sh" pdf & exit 1
    
elif [[ $ret = 0 ]]; then

Ctgry=$(echo "${upld}" | cut -d "|" -f4)
level=$(echo "${upld}" | cut -d "|" -f5)
[ "$Ctgry" = "$others" ] && Ctgry=others
[ "$Ctgry" = "$comics" ] && Ctgry=comics
[ "$Ctgry" = "$culture" ] && Ctgry=culture
[ "$Ctgry" = "$family" ] && Ctgry=family
[ "$Ctgry" = "$entertainment" ] && Ctgry=entertainment
[ "$Ctgry" = "$grammar" ] && Ctgry=grammar
[ "$Ctgry" = "$history" ] && Ctgry=history
[ "$Ctgry" = "$documentary" ] && Ctgry=documentary
[ "$Ctgry" = "$in_the_city" ] && Ctgry=in_the_city
[ "$Ctgry" = "$movies" ] && Ctgry=movies
[ "$Ctgry" = "$internet" ] && Ctgry=internet
[ "$Ctgry" = "$music" ] && Ctgry=music
[ "$Ctgry" = "$nature" ] && Ctgry=nature
[ "$Ctgry" = "$news" ] && Ctgry=news
[ "$Ctgry" = "$office" ] && Ctgry=office
[ "$Ctgry" = "$relations" ] && Ctgry=relations
[ "$Ctgry" = "$sport" ] && Ctgry=sport
[ "$Ctgry" = "$social_networks" ] && Ctgry=social_networks
[ "$Ctgry" = "$shopping" ] && Ctgry=shopping
[ "$Ctgry" = "$technology" ] && Ctgry=technology
[ "$Ctgry" = "$article" ] && Ctgry=article
[ "$Ctgry" = "$travel" ] && Ctgry=travel
[ "$Ctgry" = "$interview" ] && Ctgry=interview
[ "$Ctgry" = "$science" ] && Ctgry=science
[ "$Ctgry" = "$funny" ] && Ctgry=funny
[ "$Ctgry" = "$others" ] && Ctgry=others
[ "$level" = $(gettext "Beginner") ] && level=0
[ "$level" = $(gettext "Intermediate") ] && level=1
[ "$level" = $(gettext "Advanced") ] && level=2

iuser_m=$(echo "${upld}" | cut -d "|" -f2)
cntct_m=$(echo "${upld}" | cut -d "|" -f3)
notes_m=$(echo "${upld}" | cut -d "|" -f6)

if [ -z "${Ctgry}" ]; then
msg "$(gettext "Please select a category.")\n " info
"$DS/ifs/upld.sh" upld "${tpc}" & exit 1; fi

if [ -d "${DM_tlt}/files" ]; then
du=$(du -sb "${DM_tlt}/files" | cut -f1)
if [ "$du" -gt 50000000 ]; then
msg "$(gettext "Sorry, the size of the attachments is too large.")\n " info & exit 1; fi
fi

internet
[ -d "$DT" ] && cd "$DT" || exit 1
[ -d "$DT/upload" ] && rm -fr "$DT/upload"

# ---------------------------------------------------
mkdir "$DT/upload"
DT_u="$DT/upload/"
mkdir -p "$DT/upload/${usrid}.${tpc}/conf"

cd "${DM_tlt}/images"
if [ $(ls -1 *.jpg 2>/dev/null | wc -l) != 0 ]; then
images=$(ls *.jpg | wc -l); else
images=0; fi
[ -f "${DC_tlt}/3.cfg" ] && words=$(wc -l < "${DC_tlt}/3.cfg")
[ -f "${DC_tlt}/4.cfg" ] && sentences=$(wc -l < "${DC_tlt}/4.cfg")
if [ -f "${DC_tlt}/id.cfg" ]; then
datec="$(grep -o 'datec="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
datei="$(grep -o 'datei="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"; fi
dateu=$(date +%F)

echo -e "v=1
tname=\"${tpc}\"
langs=\"$lgsl\"
langt=\"$lgtl\"
authr=\"$iuser_m\"
cntct=\"$cntct_m\"
ctgry=\"$Ctgry\"
ilink=\"$usrid\"
datec=\"$datec\"
dateu=\"$dateu\"
datei=\"$datei\"
nword=\"$words\"
nsent=\"$sentences\"
nimag=\"$images\"
level=\"$level\"
set_1=\"$set_1\"
set_2=\"$set_2\" 


------------------ content -----------------" > "${DC_tlt}/id.cfg"
cp -f "${DC_tlt}/id.cfg" "$DT_u/${usrid}.${tpc}.$lgt"
cat "${DC_tlt}/0.cfg" >> "$DT_u/${usrid}.${tpc}.$lgt"

if [ "${iuser}" != "${iuser_m}" ] \
|| [ "${cntct}" != "${cntct_m}" ]; then
sed -i "s/usrid=.*/usrid=\"$usrid\"/g" "$DC_s/3.cfg"
sed -i "s/iuser=.*/iuser=\"$iuser_m\"/g" "$DC_s/3.cfg"
sed -i "s/cntct=.*/cntct=\"$cntct_m\"/g" "$DC_s/3.cfg"
fi

cd "${DM_tlt}"
cp -r ./* "$DT_u/${usrid}.${tpc}/"
mkdir "$DT_u/${usrid}.${tpc}/files"

mkdir "$DT_u/${usrid}.${tpc}/share"
auds="$(uniq < "${DC_tlt}/4.cfg" \
| sed 's/\n/ /g' | sed 's/ /\n/g' \
| grep -v '^.$' | grep -v '^..$' \
| sed 's/&//; s/,//; s/\?//; s/\¿//; s/;//'g \
|  sed 's/\!//; s/\¡//; s/\]//; s/\[//; s/\.//; s/  / /'g \
| tr -d ')' | tr -d '(' | tr '[:upper:]' '[:lower:]')"
while read -r audio; do
if [ -f "$DM_tl/.share/$audio.mp3" ]; then
cp -f "$DM_tl/.share/$audio.mp3" "$DT_u/${usrid}.${tpc}/share/$audio.mp3"; fi
done <<<"$auds"

# remove from folder topic name characters weirds TODO
echo -e "${notes}" > "$DT_u/${usrid}.${tpc}/conf/info"

find "$DT_u" -type f -exec chmod 644 {} \;
cd "$DT_u"
tar -cvf ./"${usrid}.${tpc}.tar" ./"${usrid}.${tpc}"
gzip -9 ./"${usrid}.${tpc}.tar"
sum=`md5sum ./"${usrid}.${tpc}.tar.gz" | cut -d' ' -f1`

echo -e "---------------end content -----------------

md5sum=\"$sum\"
" >> "$DT_u/${usrid}.${tpc}.$lgt"

du=$(du -h "${usrid}.${tpc}.tar.gz" | cut -f1)

notify-send "$(gettext "Upload in progress")" \
"$(gettext "This can take some time, please wait")" -t 6000

url="$(curl http://idiomind.sourceforge.net/doc/SITE_TMP \
| grep -o 'UPLOADS="[^"]*' | grep -o '[^"]*$')"
_files="${DT_u}/${usrid}.${tpc}.tar.gz"
idmnd="$DT_u/${usrid}.${tpc}.$lgt"
export _files idmnd url

python << END
import requests
import os
upld = os.environ['_files']
idmnd = os.environ['idmnd']
url = os.environ['url']
files = {'file': open(upld, 'rb')}
r = requests.post(url, files=files)
files = {'file': open(idmnd, 'rb')}
r = requests.post(url, files=files)
END
u=$?

if [[ $u = 0 ]]; then
    [ ! -d "${DM}/backup" ] && mkdir "${DM}/backup"
    mv -f "$DT_u/${usrid}.${tpc}.$lgt" "${DM}/backup/${tpc}.idmnd"
    info=" <b>$(gettext "Uploaded correctly")</b>\n $tpc\n"
    image=dialog-ok
else
    sleep 10
    info="$(gettext "A problem has occurred with the file upload, try again later.")\n"
    image=dialog-warning
fi
msg "$info" $image

cleanups "${DT_u}/${tpc}" "${DT_u}/${usrid}.${tpc}.${lgt}" \
"${DT_u}/${tpc}.tar" "${DT}/${tpc}.id" "${DT_u}" "${DT_u}/${tpc}.tar.gz"

exit 0
fi
    
} >/dev/null 2>&1


case "$1" in
    vsd)
    vsd "$@" ;;
    infsd)
    infsd "$@" ;;
    upld)
    upld "$@" ;;
    share)
    download "$@" ;;
esac
