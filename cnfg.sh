#!/bin/bash
source /usr/share/idiomind/ifs/c.conf

wth=$(sed -n 5p $DC_s/.rd)
eht=$(sed -n 6p $DC_s/.rd)
if [ -f $DT/.lc ]; then
	echo "--loock"
	exit 1
fi
> $DT/.lc


text="
Idiomind it's specifically designed for people learning one or more foreign languages. It helps you learn foreign language vocabulary. You can create and manage word lists and share them online.
supports different types of exercises, including grammar and pronunciation tests.

Enviar sugerencias o comentarios para mejorar el programa, si crees que te resultó util, considera realizar una donación.

Limitaciones:
Hasta 30 topics de 50 oraciones y 50 palabras cada uno.

Github:
https://github.com/robinsato/idiomind

Licencia:
GPLv3

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details."





ICON=$DS/images/icon.png
cd $DS/addons

if [ ! -d "$DC" ]; then
	$DS/ifs/1u
	cp $DS/default/cnfg1 \
	"$DC_s/cnfg1"
	sleep 1
	$DS/cnfg & exit
fi

KEY=12348
cnf1=$(mktemp $DT/cnf1.XXXX)
cnf3=$(mktemp $DT/cnf3.XXXX)
sttng3=$(sed -n 3p $DC_s/cnfg1)
sttng4=$(sed -n 4p $DC_s/cnfg1)
sttng5=$(sed -n 5p $DC_s/cnfg1)
sttng6=$(sed -n 6p $DC_s/cnfg1)
sttng7=$(sed -n 7p $DC_s/cnfg1)
sttng8=$(sed -n 8p $DC_s/cnfg1)
sttng9=$(sed -n 9p $DC_s/cnfg1)
sttng10=$(sed -n 10p $DC_s/cnfg1)
img1=$DS/images/gts.png
img2=$DS/images/lwn.png
img3=applications-other
img4=applications-other
img5=applications-other
img6=applications-other

$yad --plug=$KEY --tabnum=1 --borders=15 --scroll \
	--separator="\\n" --form --no-headers \
	--field="General Options:lbl" "#1" \
	--field=":lbl" "#2"\
	--field="Use colors for grammar (experimental):CHK" $sttng3 \
	--field="Show dialog word Selector:CHK" $sttng4 \
	--field="Start with system:CHK" $sttng5 \
	--field=" :lbl" "#6"\
	--field="<small>Voice Syntetizer\n(Defaul espeak)</small>:CB5" "$sttng7" \
	--field="<small>Use this program\nto record audio</small>:CB5" "$sttng8" \
	--field="Audio Imput:BTN" "$DS/audio/auds" \
	--field=" :lbl" "#10"\
	--field="languages:CB" "$lgtl!English!Spanish!Italian!Portuguese!German!Japanese!French!Chinese!Vietnamese" \
	--field=" :lbl" "#12" > "$cnf1" &
$yad --plug=$KEY --tabnum=2 --list --expand-column=2 \
	--text="<small>  Double click for configure</small>" \
	--no-headers --dclick-action="./plgcnf" --print-all \
	--column=icon:IMG --column=Action \
	"$img1" "Google translation service" "$img2" "Learning with News" "$img4" "Dictionarys" "$img5" "Weekly Report" &
$yad --plug=$KEY --tabnum=3 --form --align=left \
	--borders=20 --text-align=left \
	--field="Topics Saved :BTN" "$DS/ifs/upld vsd" \
	--field="Search Updates :BTN" "$DS/ifs/tls updt" \
	--field="Basic Use :BTN" "$DS/ifs/tls how" \
	--field="User Data :BTN" "'$DS/ifs/t_bd'" \
	--field="Report Problem / Suggestion :BTN" "$DS/ifs/tls rpsg" \
	--field="Make Donation:BTN" "$DS/ifs/tls mkdnt" &
echo "$text" | $yad --plug=$KEY --tabnum=4 --text-info \
	--text="\\n<big><big><big><b>Idiomind 1.0 alpha</b></big></big></big>\\n<sup>Vocabulary Learning Tool\\n<a href='https://sourceforge.net/projects/idiomind/'>Homepage</a> © 2013-2014 Robin Palat</sup>" \
	--show-uri --fontname=Arial --margins=10 --wrap --text-align=center &
$yad --notebook --key=$KEY --name=idiomind --class=idiomind \
	--sticky --center --window-icon=$ICON --window-icon=idiomind \
	--tab="Preferences" --tab="  Addons  " \
	--tab="  More  " --tab="  About  " \
	--width=450 --height=340 --title="Settings" \
	--button=Close:0
	
	ret=$?
	
	if [ $ret -eq 0 ]; then
		rm -f $DT/.lc
		cp -f "$cnf1" $DC_s/cnfg1
		[ ! -d  $HOME/.config/autostart ] && mkdir $HOME/.config/autostart
		config_dir=$HOME/.config/autostart
		if [[ "$(sed -n 5p $DC_s/cnfg1)" = "TRUE" ]]; then
			if [ ! -f $config_dir/idiomind.desktop ]; then
			
				if [ ! -d "$HOME/.config/autostart" ]; then
					mkdir "$HOME/.config/autostart"
				fi
				echo '[Desktop Entry]' > $config_dir/idiomind.desktop
				echo 'Version=1.0
				Name=idiomind
				GenericName=idiomind
				Comment=Learning languages
				Exec=idiomind
				Terminal=false
				Type=Application
				Categories=languages;Education;
				Icon=idiomind
				MimeType=application/x-idmnd;
				StartupNotify=true
				Encoding=UTF-8' >> $config_dir/idiomind.desktop
				chmod +x $config_dir/idiomind.desktop
			fi
		else
			if [ -f $config_dir/idiomind.desktop ]; then
				rm $config_dir/idiomind.desktop
			fi
		fi
		
		if cat "$cnf1" | grep "English" && [ English != $lgtl ] ; then
			if [ ! -d "$DM_t"/English ]; then
				mkdir "$DM_t"/English
				mkdir "$DM_t"/English/.share
				mkdir "$DC/topics"/English
				mkdir "$DC_a/Learning with news"/English
				mkdir "$DC_a/Learning with news"/English/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/English" \
				"$DC_a/Learning with news/English/subscripts/Example"
			fi
			echo "en" > $DC_s/lang
			echo "English" >> $DC_s/lang
			$DS/stop L
			$DS/addons/Learning_with_news/stp.sh
			cp -f $DS/images/flags/en.png $DT/tryidmdicon
			chmod 777 $DT/tryidmdicon
			$ > $DC_s/topic_m
			if [ -f "$DC/topics/English/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/English/.lst")
				"$DC/topics/English/$LST/tpc.sh"
			else
				$ > $DC_s/topic_m
			fi
			$DS/mngr mkmn
		fi
		
		if cat "$cnf1" | grep "Spanish" && [ Spanish != $lgtl ] ; then
			if [ ! -d "$DM_t"/Spanish ]; then
				mkdir "$DM_t"/Spanish
				mkdir "$DM_t"/Spanish/.share
				mkdir "$DC/topics"/Spanish
				mkdir "$DC_a/Learning with news"/Spanish
				mkdir "$DC_a/Learning with news"/Spanish/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Spanish" \
				"$DC_a/Learning with news/Spanish/subscripts/Example"
			fi
			echo "es" > $DC_s/lang
			echo "Spanish" >> $DC_s/lang
			$DS/stop L
			$DS/addons/Learning_with_news/stp.sh
			cp -f $DS/images/flags/es.png $DT/tryidmdicon
			chmod 777 $DT/tryidmdicon
			$ > $DC_s/topic_m
			if [ -f "$DC/topics/Spanish/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Spanish/.lst")
				"$DC/topics/Spanish/$LST/tpc.sh"
			else
				$ > $DC_s/topic_m
			fi
			$DS/mngr mkmn
		fi
		
		if cat "$cnf1" | grep "Italian" && [ Italian != $lgtl ] ; then
			if [ ! -d "$DM_t"/Italian ]; then
				mkdir "$DM_t"/Italian
				mkdir "$DM_t"/Italian/.share
				mkdir "$DC/topics"/Italian
				mkdir "$DC_a/Learning with news"/Italian
				mkdir "$DC_a/Learning with news"/Italian/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Italian" \
				"$DC_a/Learning with news/Italian/subscripts/Example"
			fi
			echo "it" > $DC_s/lang
			echo "Italian" >> $DC_s/lang
			$DS/stop L
			$DS/addons/Learning_with_news/stp.sh
			cp -f $DS/images/flags/it.png $DT/tryidmdicon
			chmod 777 $DT/tryidmdicon
			$ > $DC_s/topic_m
			if [ -f "$DC/topics/Italian/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Italian/.lst")
				"$DC/topics/Italian/$LST/tpc.sh"
			else
				$ > $DC_s/topic_m
			fi
			$DS/mngr mkmn
		fi
		
		if cat "$cnf1" | grep "Portuguese" && [ Portuguese != $lgtl ] ; then
			if [ ! -d "$DM_t"/Portuguese ]; then
				mkdir "$DM_t"/Portuguese
				mkdir "$DM_t"/Portuguese/.share
				mkdir "$DC/topics"/Portuguese
				mkdir "$DC_a/Learning with news"/Portuguese
				mkdir "$DC_a/Learning with news"/Portuguese/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Portuguese" \
				"$DC_a/Learning with news/Portuguese/subscripts/Example"
			fi
			echo "pt" > $DC_s/lang
			echo "Portuguese" >> $DC_s/lang
			$DS/stop L
			$DS/addons/Learning_with_news/stp.sh
			cp -f $DS/images/flags/pt.png $DT/tryidmdicon
			chmod 777 $DT/tryidmdicon
			$ > $DC_s/topic_m
			if [ -f "$DC/topics/Portuguese/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Portuguese/.lst")
				"$DC/topics/Portuguese/$LST/tpc.sh"
			else
				$ > $DC_s/topic_m
			fi
			$DS/mngr mkmn
		fi
		
		if cat "$cnf1" | grep "German" && [ German != $lgtl ] ; then
			if [ ! -d "$DM_t"/German ]; then
				mkdir "$DM_t"/German
				mkdir "$DM_t"/German/.share
				mkdir "$DC/topics"/German
				mkdir "$DC_a/Learning with news"/German
				mkdir "$DC_a/Learning with news"/German/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/German" \
				"$DC_a/Learning with news/German/subscripts/Example"
			fi
			echo "de" > $DC_s/lang
			echo "German" >> $DC_s/lang
			$DS/stop L
			$DS/addons/Learning_with_news/stp.sh
			cp -f $DS/images/flags/de.png $DT/tryidmdicon
			chmod 777 $DT/tryidmdicon
			$ > $DC_s/topic_m
			if [ -f "$DC/topics/German/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/German/.lst")
				"$DC/topics/German/$LST/tpc.sh"
			else
				$ > $DC_s/topic_m
			fi
			$DS/mngr mkmn
		fi
		
		if cat "$cnf1" | grep "Japanese" && [ Japanese != $lgtl ] ; then
			if [ ! -d "$DM_t"/Japanese ]; then
				mkdir "$DM_t"/Japanese
				mkdir "$DM_t"/Japanese/.share
				mkdir "$DC/topics"/Japanese
				mkdir "$DC_a/Learning with news"/Japanese
				mkdir "$DC_a/Learning with news"/Japanese/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Japanese" \
				"$DC_a/Learning with news/Japanese/subscripts/Example"
			fi
			echo "ja" > $DC_s/lang
			echo "Japanese" >> $DC_s/lang
			$DS/stop L
			$DS/addons/Learning_with_news/stp.sh
			cp -f $DS/images/flags/ja.png $DT/tryidmdicon
			chmod 777 $DT/tryidmdicon
			$ > $DC_s/topic_m
			if [ -f "$DC/topics/Japanese/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Japanese/.lst")
				"$DC/topics/Japanese/$LST/tpc.sh"
			else
				$ > $DC_s/topic_m
			fi
			$DS/mngr mkmn
		fi
		
		if cat "$cnf1" | grep "French" && [ French != $lgtl ] ; then
			if [ ! -d "$DM_t"/French ]; then
				mkdir "$DM_t"/French
				mkdir "$DM_t"/French/.share
				mkdir "$DC/topics"/French
				mkdir "$DC_a/Learning with news"/French
				mkdir "$DC_a/Learning with news"/French/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/French" \
				"$DC_a/Learning with news/French/subscripts/Example"
			fi
			echo "fr" > $DC_s/lang
			echo "French" >> $DC_s/lang
			$DS/stop L
			$DS/addons/Learning_with_news/stp.sh
			cp -f $DS/images/flags/fr.png $DT/tryidmdicon
			chmod 777 $DT/tryidmdicon
			$ > $DC_s/topic_m
			if [ -f "$DC/topics/French/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/French/.lst")
				"$DC/topics/French/$LST/tpc.sh"
			else
				$ > $DC_s/topic_m
			fi
			$DS/mngr mkmn
		fi
		
		if cat "$cnf1" | grep "Vietnamese" && [ Vietnamese != $lgtl ] ; then
			if [ ! -d "$DM_t"/Vietnamese ]; then
				mkdir "$DM_t"/Vietnamese
				mkdir "$DM_t"/Vietnamese/.share
				mkdir "$DC/topics"/Vietnamese
				mkdir "$DC_a/Learning with news"/Vietnamese
				mkdir "$DC_a/Learning with news"/Vietnamese/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Vietnamese" \
				"$DC_a/Learning with news/Vietnamese/subscripts/Example"
			fi
			echo "vi" > $DC_s/lang
			echo "Vietnamese" >> $DC_s/lang
			$DS/stop L
			$DS/addons/Learning_with_news/stp.sh
			cp -f $DS/images/flags/vi.png $DT/tryidmdicon
			chmod 777 $DT/tryidmdicon
			$ > $DC_s/topic_m
			if [ -f "$DC/topics/Vietnamese/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Vietnamese/.lst")
				"$DC/topics/Vietnamese/$LST/tpc.sh"
			else
				$ > $DC_s/topic_m
			fi
			$DS/mngr mkmn
		fi
		
		if cat "$cnf1" | grep "Chinese" && [ Chinese != $lgtl ] ; then
			if [ ! -d "$DM_t"/Chinese ]; then
				mkdir "$DM_t"/Chinese
				mkdir "$DM_t"/Chinese/.share
				mkdir "$DC/topics"/Chinese
				mkdir "$DC_a/Learning with news"/Chinese
				mkdir "$DC_a/Learning with news"/Chinese/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Chinese" \
				"$DC_a/Learning with news/Chinese/subscripts/Example"
			fi
			echo "zh-cn" > $DC_s/lang
			echo "Chinese" >> $DC_s/lang
			$DS/stop L
			$DS/addons/Learning_with_news/stp.sh
			cp -f $DS/images/flags/zh-cn.png $DT/tryidmdicon
			chmod 777 $DT/tryidmdicon
			$ > $DC_s/topic_m
			if [ -f "$DC/topics/Chinese/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Chinese/.lst")
				"$DC/topics/Chinese/$LST/tpc.sh"
			else
				$ > $DC_s/topic_m
			fi
			$DS/mngr mkmn
		fi
		
		rm -f $cnf1 $cnf2 $cnf3 $DT/.lc & exit 1
		
	elif [ $ret -eq 1 ]; then
		rm -f $cnf1 $cnf2 $cnf3 $DT/.lc & exit 1
		
	else
		rm -f $cnf1 $cnf2 $cnf3 $DT/.lc & exit 1
	fi
exit 0
