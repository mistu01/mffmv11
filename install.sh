## MFFM Installer v11 by MFFM
## 2022/07/21

set -xv

MIRRORPATH=$(magisk --path)/.magisk/mirror
APILEVEL=$(getprop ro.build.version.sdk)
#Original
ORIPRDFONT=$MIRRORPATH/system/product/fonts
ORIPRDETC=$MIRRORPATH/system/product/etc
ORIPRDXML=$ORIPRDETC/fonts_customization.xml
ORISYSFONT=$MIRRORPATH/system/fonts
ORISYSETC=$MIRRORPATH/system/etc
ORISYSXML=$ORISYSETC/fonts.xml
#MODPATH
PRDFONT=$MODPATH/system/product/fonts
PRDETC=$MODPATH/system/product/etc
PRDXML=$PRDETC/fonts_customization.xml
SYSFONT=$MODPATH/system/fonts
SYSETC=$MODPATH/system/etc
SYSEXTETC=$MODPATH/system/system_ext/etc
SYSXML=$SYSETC/fonts.xml
MODPROP=$MODPATH/module.prop
FONTDR=$MODPATH/Files
#MFFM
MFFM=/sdcard/MFFM
[ ! -d $MFFM ] && echo 'MFFM folder and resourecs not found..' && mkdir -p $MFFM

mffmex(){
    cp $MFFM/Emoji*.ttf $FONTDR; cp $MFFM/NotoSansBengali-VF.ttf $FONTDR; cp $MFFM/NotoSansSymbols*.ttf $FONTDR; cp $MFFM/Beng*.ttf $FONTDR; cp $MFFM/Beng*.zip $FONTDR; cp $MFFM/Beng*.xml $FONTDR; cp $MFFM/Mono*.ttf $FONTDR; cp $MFFM/Serif*.ttf $FONTDR
	cp $ORISYSXML $SYSXML; cp $ORIPRDXML $PRDXML
}

mv $FONTDR/bin $MODPATH/bin
base64 -d $MODPATH/bin > $MODPATH/f && tar xf $MODPATH/f -C $MODPATH
mkdir -p $PRDFONT $PRDETC $SYSFONT $SYSETC $SYSEXTETC

    SS="<family name=\"sans-serif\">" SSC="<family name=\"sans-serif-condensed\">" VRD="<alias name=\"verdana\" to=\"sans-serif\" \/>" GSN="<family customizationType=\"new-named-family\" name=\"googlesans\">"
	GS="<family customizationType=\"new-named-family\" name=\"google-sans\">" GST="<family customizationType=\"new-named-family\" name=\"google-sans-text\">" GSB="<family customizationType=\"new-named-family\" name=\"google-sans-bold\">"
	GSM="<family customizationType=\"new-named-family\" name=\"google-sans-medium\">" GSTM="<family customizationType=\"new-named-family\" name=\"google-sans-text-medium\">" GSTB="<family customizationType=\"new-named-family\" name=\"google-sans-text-bold\">"
	GSTBI="<family customizationType=\"new-named-family\" name=\"google-sans-text-bold-italic\">" GSTMI="<family customizationType=\"new-named-family\" name=\"google-sans-text-medium-italic\">" GSTI="<family customizationType=\"new-named-family\" name=\"google-sans-text-italic\">"

    thin="<font weight=\"100\" style=\"normal\">Thin.ttf<\/font>"	thinitalic="<font weight=\"100\" style=\"italic\">ThinItalic.ttf<\/font>"
	light="<font weight=\"300\" style=\"normal\">Light.ttf<\/font>"	lightitalic="<font weight=\"300\" style=\"italic\">LightItalic.ttf<\/font>"
	regular="<font weight=\"400\" style=\"normal\">Regular.ttf<\/font>"	italic="<font weight=\"400\" style=\"italic\">Italic.ttf<\/font>"
	medium="<font weight=\"500\" style=\"normal\">Medium.ttf<\/font>"	mediumitalic="<font weight=\"500\" style=\"italic\">MediumItalic.ttf<\/font>"
	black="<font weight=\"900\" style=\"normal\">Black.ttf<\/font>"	blackitalic="<font weight=\"900\" style=\"italic\">BlackItalic.ttf<\/font>"
	bold="<font weight=\"700\" style=\"normal\">Bold.ttf<\/font>"    bolditalic="<font weight=\"700\" style=\"italic\">BoldItalic.ttf<\/font>"
	
patchsysxml(){
    sed -i 's/RobotoStatic/Roboto/g' $SYSXML
	sed -i "s/$SS/$SS\n        $thin\n        $thinitalic\n        $light\n        $lightitalic\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $black\n        $blackitalic\n        $bold\n        $bolditalic\n    <\/family>\n	<family>/" $SYSXML
	sed -i -n '/<family name=\"sans-serif-condensed\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML   
	sed -i "s/$SSC/$SSC\n        $light\n        $lightitalic\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic/" $SYSXML
    sed -i "s/$VRD/$VRD\n \n    <\!-- GS Starts -->\n    $GS\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic\n    <\/family>\n \n    $GSM\n        $medium\n    <\/family>\n \n    $GSB\n        $bold\n    <\/family>\n \n    $GST\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic\n    <\/family>\n \n    $GSTM\n        $medium\n    <\/family>\n \n    $GSTB\n        $bold\n    <\/family>\n \n    $GSTI\n        $italic\n    <\/family>\n \n    $GSTMI\n        $mediumitalic\n    <\/family>\n \n    $GSTBI\n        $bolditalic\n    <\/family>\n    <\!-- GS Ends -->/g" $SYSXML
    sed -i -n '/<family name=\"serif\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "s/<family name=\"serif\">/<family name=\"serif\">\n        $regular\n        $bold\n        $italic\n        $bolditalic\n    <\/family>\n    <family>\n        <font weight=\"400\" style=\"normal\" fallbackFor=\"serif\">NotoSerif-Regular.ttf<\/font>\n        <font weight=\"700\" style=\"normal\" fallbackFor=\"serif\">NotoSerif-Bold.ttf<\/font>\n        <font weight=\"400\" style=\"italic\" fallbackFor=\"serif\">NotoSerif-Italic.ttf<\/font>\n        <font weight=\"700\" style=\"italic\" fallbackFor=\"serif\">NotoSerif-BoldItalic.ttf<\/font>/" $SYSXML
}

gsans(){    
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/$GS/$GS\n        $regular\n        $medium\n        $bold\n        $italic\n        $mediumitalic\n        $bolditalic/" $PRDXML    
	sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-text\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/$GST/$GST\n        $regular\n        $medium\n        $bold\n        $italic\n        $mediumitalic\n        $bolditalic/" $PRDXML	
	sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-bold\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/$GSB/$GSB\n        $bold/" $PRDXML	
	sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-medium\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/$GSM/$GSM\n        $medium/" $PRDXML	
	sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-text-medium\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/$GSTM/$GSTM\n        $medium/" $PRDXML	
	sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-text-bold\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/$GSTB/$GSTB\n        $bold/" $PRDXML	
	sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-text-bold-italic\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/$GSTBI/$GSTBI\n        $bolditalic/" $PRDXML	
	sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-text-medium-italic\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/$GSTMI/$GSTMI\n        $mediumitalic/" $PRDXML	
	sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-text-italic\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/$GSTI/$GSTI\n        $italic/" $PRDXML
	sed -i -n '/<family customizationType=\"new-named-family\" name=\"googlesans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/$GSN/$GSN\n        $regular\n        $medium\n        $bold\n        $italic\n        $mediumitalic\n        $bolditalic/" $PRDXML	
}

prdscrp(){
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"manrope\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"manrope\">/<family customizationType=\"new-named-family\" name=\"manrope\">\n        $regular\n        $medium\n        $bold\n        $italic\n        $mediumitalic\n        $bolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"noto-sans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"noto-sans\">/<family customizationType=\"new-named-family\" name=\"noto-sans\">\n        $regular\n        $medium\n        $bold\n        $italic\n        $mediumitalic\n        $bolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"source-sans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"source-sans\">/<family customizationType=\"new-named-family\" name=\"source-sans\">\n        $regular\n        $medium\n        $bold\n        $italic\n        $mediumitalic\n        $bolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"roboto-system\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"roboto-system\">/<family customizationType=\"new-named-family\" name=\"roboto-system\">\n        $regular\n        $medium\n        $bold\n        $italic\n        $mediumitalic\n        $bolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"rubik\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"rubik\">/<family customizationType=\"new-named-family\" name=\"rubik\">\n        $regular\n        $medium\n        $bold\n        $italic\n        $mediumitalic\n        $bolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"barlow\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"barlow\">/<family customizationType=\"new-named-family\" name=\"barlow\">\n        $regular\n        $medium\n        $bold\n        $italic\n        $mediumitalic\n        $bolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"lato\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"lato\">/<family customizationType=\"new-named-family\" name=\"lato\">\n        $regular\n        $medium\n        $bold\n        $italic\n        $mediumitalic\n        $bolditalic/" $PRDXML
}

bengpatch(){
    BXML="$FONTDR/Beng*.xml"
	sed '/<\!-- elegant -->/,/<\!-- elegant ends -->/!d' $BXML > $MODPATH/elegant.xml
	sed '/<\!-- compact -->/,/<\!-- compact ends -->/!d' $BXML > $MODPATH/compact.xml
	sed -i -n '/<family lang=\"und-Beng\" variant=\"elegant\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "/<family lang=\"und-Beng\" variant=\"elegant\">/r $MODPATH/elegant.xml" $SYSXML
	sed -i -n '/<family lang=\"und-Beng\" variant=\"compact\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "/<family lang=\"und-Beng\" variant=\"compact\">/r $MODPATH/compact.xml" $SYSXML
	sed -i '/<\!-- elegant -->/d;/<\!-- elegant ends -->/d;/<\!-- compact -->/d;/<\!-- compact ends -->/d' $SYSXML
}

beng(){
    unzip -qq $FONTDR/Beng*.zip -d $FONTDR
    cp $FONTDR/Beng-Regular.ttf $SYSFONT/NotoSansBengali-VF.ttf
    cp $FONTDR/NotoSansBengali-VF.ttf $SYSFONT/NotoSansBengali-VF.ttf
	cp $FONTDR/Beng-Medium.ttf $SYSFONT/NotoSerifBengali-VF.ttf
	cp $FONTDR/Beng-Bold.ttf $SYSFONT/NotoSansBengaliUI-VF.ttf
    if [ -f $SYSFONT/NotoSansBengali-VF.ttf ]; then		
	    bengpatch && ui_print "- Installing Bengali Fonts..."
	else
	    ui_print "- Bengali Fonts Resources not found..."
	fi
}

prdfnt(){
    if [ -f $ORIPRDXML ]; then
	    set Black BlackItalic Bold BoldItalic Medium MediumItalic Regular Italic Light LightItalic Thin ThinItalic
	    for i do ln -s $SYSFONT/$i.ttf $PRDFONT/$i.ttf; done
	    gsans
	    prdscrp
	fi
}

singlefont(){
    if [ -f $FONTDR/MFFM.ttf ]; then
        set Black BlackItalic Bold BoldItalic Medium MediumItalic Regular Italic Light LightItalic Thin ThinItalic
	    for i do cp $FONTDR/MFFM.ttf $SYSFONT/$i.ttf; done
    fi
}

sfont() {
    set Black BlackItalic Bold BoldItalic Medium MediumItalic Regular Italic Light LightItalic Thin ThinItalic
	for i do cp $FONTDR/$i.ttf $SYSFONT/$i.ttf; done
	singlefont
    patchsysxml
}

monospace(){
    if [ -f $FONTDR/Mono*.ttf ]; then
        cp $FONTDR/Mono*.ttf $SYSFONT/CutiveMono.ttf
	    cp $FONTDR/Mono*.ttf $SYSFONT/DroidSansMono.ttf
	    ui_print "- Installing Monospace Fonts..."
	else
	    ui_print "- Monospace Font Resources Not Found..."
    fi
}

#Emoji Replacement | Thanks to @MrCarb0n
emojiplus(){
    [ $FONTDR/Emoji*.ttf ] && ui_print "- Installing Custom Emoji" || ui_print "- Custom Emoji Resources Not Found."
    DEMJ="NotoColorEmoji.ttf"
    [ $ORISYSFONT/$DEMJ ] && cp $FONTDR/Emoji*.ttf $SYSFONT/$DEMJ &&  ui_print "- Replacing $DEMJ ✅" || ui_print "- Replacing $DEMJ ❎"
	
	SEMJ="$(find $ORISYSFONT -type f ! -name 'NotoColorEmoji.ttf' -name "*Emoji*.ttf" -exec basename {} \;)"	
	for i in $SEMJ ; do
        if [ -f $SYSFONT/$DEMJ ]; then
		    ln -s $SYSFONT/$DEMJ $SYSFONT/$i && ui_print "- Replacing $i ✅" || ui_print "- Replacing $i ❎"
        fi
    done
	
    [ -d /data/fonts ] && rm -f -rf /data/fonts
    [ -d /data/data/com.google.android.inputmethod.latin ] &&
        find /data -type d -path '*inputmethod.latin*/*cache*' -exec rm -f -rf {} + &&
        am force-stop com.google.android.inputmethod.latin
}

# Services
# KillGMSFont By @MrCarb0n | https://github.com/MrCarb0n/killgmsfont
# Disable GMS' font service / Emoji Recheck on Boot
{
    echo '(   '    
    echo '    # wait till proper boot up'
    echo '    until [ "$(resetprop sys.boot_completed)" = "1" -a -d "/data" ]; do'
    echo '        sleep 1'
    echo '    done'
    echo ''
    echo "    # disable GMS's font service"
    echo '    STATE_GMSF() {'
    echo '        local PM="$(which pm)"'
    echo '        local GMSF="com.google.android.gms/com.google.android.gms.fonts"'
    echo ''
    echo '        for s in $(ls /data/user); do'
    echo '            $PM $@ --user $s "$GMSF.update.UpdateSchedulerService"'
    echo '            $PM $@ --user $s "$GMSF.provider.FontsProvider"'
    echo '        done'
    echo '    } &> /dev/null'
    echo ''
    echo "    # delete GMS's generated fonts"
    echo '    DEL_GMSF() {'
    echo '        local GMSFD=com.google.android.gms/files/fonts'
    echo ''
    echo '        for d in /data/fonts \'
    echo '            /data/data/$GMSFD \'
    echo '            /data/user/*/$GMSFD; do'
    echo '            [ -d $d ] && rm -rf $d'
    echo '        done'
    echo '    }'
    echo ''
    echo '    # run primary tasks'
    echo '    STATE_GMSF disable; DEL_GMSF'
	echo ''
	echo '    # Change possible in-app emojis on boot time'
	echo '    find /data/data -name "*Emoji*.ttf" -exec cp $MODPATH/system/fonts/NotoColorEmoji.ttf {} \;'
	echo ''
	echo '    # Android 12+ | extended checking.. [?!]'
    echo '    [ -d /data/fonts ] && rm -f -rf /data/fonts'
	echo ''
    echo ')'
} > $MODPATH/service.sh

# KillGMSFont (Uninstall Script) By @ MrCarb0n | https://github.com/MrCarb0n/killgmsfont
{
    echo '('
    echo ''
    echo '    # wait till proper boot up'
    echo '    until [ "$(resetprop sys.boot_completed)" = "1" ]; do'
    echo '        sleep 1'
    echo '    done'
    echo ''
    echo "    # enable GMS's font service"
    echo '    STATE_GMSF() {'
    echo '        local PM="$(which pm)"'
    echo '        local GMSF="com.google.android.gms/com.google.android.gms.fonts"'
    echo ''
    echo '        for u in $(ls /data/user); do'
    echo '            $PM $@ --user $u "$GMSF.update.UpdateSchedulerService"'
    echo '            $PM $@ --user $u "$GMSF.provider.FontsProvider"'
    echo '        done'
    echo '    } &> /dev/null'
    echo ''
    echo '    STATE_GMSF enable'
    echo ')'
} > $MODPATH/uninstall.sh

xmi(){
    #miui main
    if [ -f $ORISYSFONT/MiLanProVF.ttf ]; then cp $FONTDR/Regular.ttf $SYSFONT/MiLanProVF.ttf; fi
	if [ -f $ORISYSFONT/MiSansVF.ttf ]; then cp $FONTDR/Regular.ttf $SYSFONT/MiSansVF.ttf; fi
	if [ -f $ORISYSFONT/RobotoVF.ttf ]; then cp $FONTDR/Regular.ttf $SYSFONT/RobotoVF.ttf; fi
	#miui extra
	if [ -f $ORISYSFONT/MitypeClock.otf ]; then cp $FONTDR/Regular.ttf $SYSFONT/MitypeClock.otf; fi
	if [ -f $ORISYSFONT/MitypeClockMono.otf ]; then cp $FONTDR/Regular.ttf $SYSFONT/MitypeClockMono.otf; fi
	if [ -f $ORISYSFONT/MiClock.otf ]; then cp $FONTDR/Regular.ttf $SYSFONT/MiClock.otf; fi
	if [ -f $ORISYSFONT/MiClockThin.otf ]; then cp $FONTDR/Regular.ttf $SYSFONT/MiClockThin.otf; fi
	if [ -f $ORISYSFONT/MiClockMono.otf ]; then cp $FONTDR/Regular.ttf $SYSFONT/MiClockMono.otf; fi
	if [ -f $ORISYSFONT/MiClockUyghur-Thin.ttf ]; then cp $FONTDR/Regular.ttf $SYSFONT/MiClockUyghur-Thin.ttf; fi
	if [ -f $ORISYSFONT/MiClockTibetan-Thin.ttf ]; then cp $FONTDR/Regular.ttf $SYSFONT/MiClockTibetan-Thin.ttf; fi
	if [ -f $ORISYSFONT/MitypeVF.ttf ]; then cp $FONTDR/Regular.ttf $SYSFONT/MitypeVF.ttf; fi
	if [ -f $ORISYSFONT/MitypeMonoVF.ttf ]; then cp $FONTDR/Regular.ttf $SYSFONT/MitypeMonoVF.ttf; fi
}

samsung(){
    sed -i -n '/<family name=\"sec-roboto-light\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "s/<family name=\"sec-roboto-light\">/<family name=\"sec-roboto-light\">\n        $regular\n        $medium/" $SYSXML
	sed -i -n '/<family name=\"sec-roboto-condensed\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "s/<family name=\"sec-roboto-condensed\">/<family name=\"sec-roboto-condensed\">\n        $cregular\n        $cbold/" $SYSXML
	sed -i -n '/<family name=\"sec-roboto-condensed-light\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "s/<family name=\"sec-roboto-condensed-light\">/<family name=\"sec-roboto-condensed-light\">\n        $clight/" $SYSXML
}

oxygen(){ 
    if [ -f $ORISYSETC/fonts_base.xml ]; then
	cp $SYSXML $SYSETC/fonts_base.xml
	fi
	if [ -f /system/system_ext/etc/fonts_base.xml ]; then
	cp $SYSXML $SYSEXTETC/fonts_base.xml
	fi
	if [ -f $ORISYSETC/fonts_slate.xml ]; then
	cp $SYSXML $SYSETC/fonts_slate.xml
	fi
}

src(){
    if [ -f $MFFM/MFFM*.sh ]; then
	cp $MFFM/MFFM*.sh $MODPATH
    . $MODPATH/MFFM*.sh    
    fi
}

finish(){
    rm -f $MODPATH/*.ttf
	rm -f $MODPATH/*.xml
	rm -f $MODPATH/f
	rm -f $MODPATH/bin
	rm -f $MODPATH/install.sh
	rm -f $MODPATH/*.md
	rm -f $MODPATH/*.zip
	rm -f $MODPATH/LICENSE
	rm -rf $MODPATH/Files
}

mffmex; ui_print "- Copying MFFM Resources to MODPATH..."
sfont; ui_print "- Installing Fonts and Patching Fonts.xml..."
prdfnt
monospace
beng
oxygen
xmi
samsung
emojiplus
src
finish; ui_print "- Cleaning Leftovers..."
