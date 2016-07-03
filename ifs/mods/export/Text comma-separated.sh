#!/bin/bash

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
mkdir -p "$DT/export"
file="$DT/export/file.csv"

while read -r _item; do
    if [ ! -d "$DT/export" ]; then break & exit 1; fi
    unset trgt srce expl
    get_item "${_item}"
    echo -e "\"$trgt\",\"$srce\"" >> "$DT/export/txt"
done < "${DC_tlt}/0.cfg"
if [ -e "$DT/export/txt" ]; then
    cat "$DT/export/txt" > "$file"
else
    msg "$(gettext "Not enough words")\n" dialog-warning "$(gettext "Information")"
fi

mv -f "$file" "${1}.csv"
chmod 664 "${1}.csv"
cleanups "$DT/export"




