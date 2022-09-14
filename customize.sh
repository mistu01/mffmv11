## MFFM Installer v11 by MFFM
## 2022.09.14

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
FONTDIR=$MODPATH/Files
#MFFM
MFFM=/sdcard/MFFM
[ ! -d $MFFM ] && mkdir -p $MFFM

mffmex(){
    sleep 1
	ui_print "║                                        ║"
	ui_print "║ ■ COPYING MFFM FOLDER RESOURCES TO THE ║"
	ui_print "║   MODULE DIRECTORY.                    ║"
    f='Thin.ttf ThinItalic.ttf Light.ttf LightItalic.ttf Regular.ttf Italic.ttf Medium.ttf MediumItalic.ttf Bold.ttf BoldItalic.ttf Black.ttf BlackItalic.ttf'
	for i in $f; do
	    if [ ! -f "$FONTDIR/$i" ]; then
		    cp $MFFM/$i $FONTDIR
		fi
	done
	if [ ! -f $FONTDIR/MFFM.ttf ]; then cp $MFFM/MFFM.ttf $FONTDIR; fi
    if [ ! -f $FONTDIR/Beng*.ttf ] && [ ! -f $FONTDIR/Beng*.zip ] && [ ! -f $MFFM/Beng*.ttf ] && [ -f $MFFM/Beng*.zip ]; then
        cp $MFFM/Beng*.zip $FONTDIR
    fi
	if [ ! -f $FONTDIR/Beng*.ttf ] && [ ! -f $FONTDIR/Beng*.zip ] && [ -f $MFFM/Beng*.ttf ] && [ ! -f $MFFM/Beng*.zip ]; then
        cp $MFFM/Beng*.ttf $FONTDIR
    fi
	if [ ! -f $FONTDIR/NotoSansBengali-VF.ttf ] && [ -f $MFFM/NotoSansBengali-VF.ttf ]; then
	    cp $MFFM/NotoSansBengali-VF.ttf $FONTDIR
	fi
	if [ ! -f $FONTDIR/Beng*.xml ] && [ -f $MFFM/Beng*.xml ]; then
	    cp $MFFM/Beng*.xml $FONTDIR
	fi
	if [ ! -f $FONTDIR/Serif*.ttf ] && [ ! -f $FONTDIR/Serif*.zip ] && [ ! -f $MFFM/Serif*.ttf ] && [ -f $MFFM/Serif*.zip ]; then
        cp $MFFM/Serif*.zip $FONTDIR
    fi	
	if [ ! -f $FONTDIR/Serif*.ttf ] && [ ! -f $FONTDIR/Serif*.zip ] && [ -f $MFFM/Serif*.ttf ] && [ ! -f $MFFM/Serif*.zip ]; then
        cp $MFFM/Serif*.ttf $FONTDIR
    fi	
    if [ ! -f $FONTDIR/Mono*.ttf ]; then cp $MFFM/Mono*.ttf $FONTDIR; fi
	if [ ! -f $FONTDIR/Emoji*.ttf ]; then cp $MFFM/Emoji*.ttf $FONTDIR; fi
	cp $ORISYSXML $SYSXML; cp $ORIPRDXML $PRDXML
}

mv $FONTDIR/bin $MODPATH/bin
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
	sed -i -n '/<family name=\"sans-serif\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "s/$SS/$SS\n        $thin\n        $thinitalic\n        $light\n        $lightitalic\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $black\n        $blackitalic\n        $bold\n        $bolditalic/" $SYSXML
	sed -i -n '/<family name=\"sans-serif-condensed\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML   
	sed -i "s/$SSC/$SSC\n        $light\n        $lightitalic\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic/" $SYSXML
    sed -i -n '/<family name=\"google-sans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "s/<family name=\"google-sans\">/<family name=\"google-sans\">\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic/" $SYSXML
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
	sed -i -n '/<family customizationType=\"new-named-family\" name=\"fluid-sans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"fluid-sans\">/<family customizationType=\"new-named-family\" name=\"fluid-sans\">\n        $regular\n        $medium\n        $bold\n        $italic\n        $mediumitalic\n        $bolditalic/" $PRDXML
}

fallback(){
    cp $FONTDIR/Roboto-Regular.ttf $SYSFONT/DroidSans.ttf
	sed -i 's/<\/familyset>//g' $SYSXML
	cat $FONTDIR/fallback.xml >> $SYSXML
}

bengpatch(){
    BXML="$FONTDIR/Beng*.xml"
	sed '/<\!-- elegant -->/,/<\!-- elegant ends -->/!d' $BXML > $MODPATH/elegant.xml
	sed '/<\!-- compact -->/,/<\!-- compact ends -->/!d' $BXML > $MODPATH/compact.xml
	sed -i -n '/<family lang=\"und-Beng\" variant=\"elegant\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "/<family lang=\"und-Beng\" variant=\"elegant\">/r $MODPATH/elegant.xml" $SYSXML
	sed -i -n '/<family lang=\"und-Beng\" variant=\"compact\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "/<family lang=\"und-Beng\" variant=\"compact\">/r $MODPATH/compact.xml" $SYSXML
	sed -i '/<\!-- elegant -->/d;/<\!-- elegant ends -->/d;/<\!-- compact -->/d;/<\!-- compact ends -->/d' $SYSXML
}

beng(){
    sleep 0.5	
    unzip -qq $FONTDIR/Beng*.zip -d $FONTDIR
    cp $FONTDIR/Beng-Regular.ttf $SYSFONT/NotoSansBengali-VF.ttf
    cp $FONTDIR/NotoSansBengali-VF.ttf $SYSFONT/NotoSansBengali-VF.ttf
	cp $FONTDIR/Beng-Medium.ttf $SYSFONT/NotoSerifBengali-VF.ttf
	cp $FONTDIR/Beng-Bold.ttf $SYSFONT/NotoSansBengaliUI-VF.ttf
    if [ -f $SYSFONT/NotoSansBengali-VF.ttf ]; then		
	    bengpatch && ui_print "║   Installing BENGALI fonts.            ║"
	else
	    ui_print "║   Skipping BENGALI font installation.  ║"
	fi
}

prdfnt(){
    if [ -f $ORIPRDXML ]; then
	    set Black BlackItalic Bold BoldItalic Medium MediumItalic Regular Italic Light LightItalic Thin ThinItalic
	    for i do ln -s $SYSFONT/$i.ttf $PRDFONT/$i.ttf; done	    
	fi
	if [ -f $PRDFONT/Regular.ttf ]; then
	    sleep 0.5
	    gsans
	    prdscrp
	fi
}

singlefont(){
    if [ -f $FONTDIR/MFFM.ttf ]; then
        set Black BlackItalic Bold BoldItalic Medium MediumItalic Regular Italic Light LightItalic Thin ThinItalic
	    for i do cp $FONTDIR/MFFM.ttf $SYSFONT/$i.ttf; done
    fi
}

sfont() {
    set Black BlackItalic Bold BoldItalic Medium MediumItalic Regular Italic Light LightItalic Thin ThinItalic
	for i do cp $FONTDIR/$i.ttf $SYSFONT/$i.ttf; done
	singlefont
	if [ -f $SYSFONT/Regular.ttf ]; then
	    sleep 0.5
        ui_print "║                                        ║"		
		ui_print "║ ■ INSTALLING FONTS.                    ║"
		ui_print "║   Installing SANS-SERIF fonts.         ║"
        patchsysxml
	else
	    sleep 0.5
		ui_print "║                                        ║"		
		ui_print "║ ■ INSTALLING FONTS.                    ║"
		ui_print "║   Skipping SANS-SERIF installation.    ║"
	fi
}

monospace(){
    if [ -f $FONTDIR/Mono*.ttf ]; then
        cp $FONTDIR/Mono*.ttf $SYSFONT/CutiveMono.ttf
	    cp $FONTDIR/Mono*.ttf $SYSFONT/DroidSansMono.ttf
		sleep 0.5	    
	    ui_print "║   Installing MONOSPACE fonts.          ║"
	else
	    sleep 0.5	    
	    ui_print "║   Skipping MONOSPACE font installation.║"
    fi
}

srf(){
    unzip -qq $FONTDIR/Serif*.zip -d $FONTDIR
	cp $FONTDIR/Serif-Regular.ttf $SYSFONT/SourceSansPro-Regular.ttf
	cp $FONTDIR/Serif-Italic.ttf $SYSFONT/SourceSansPro-Italic.ttf
	cp $FONTDIR/Serif-Bold.ttf $SYSFONT/SourceSansPro-Bold.ttf
	cp $FONTDIR/Serif-BoldItalic.ttf $SYSFONT/SourceSansPro-BoldItalic.ttf
	if [ -f $SYSFONT/SourceSansPro-Regular.ttf ]; then
	    sleep 0.5	    
		ui_print "║   Installing SERIF fonts.              ║"
		sed -i -n '/<family name=\"serif\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	    sed -i 's/<family name=\"serif\">/<family name=\"serif\">\n        <font weight=\"400\" style=\"normal\">SourceSansPro-Regular.ttf<\/font>\n        <font weight=\"700\" style=\"normal\">SourceSansPro-Bold.ttf<\/font>\n        <font weight=\"400\" style=\"italic\">SourceSansPro-Italic.ttf<\/font>\n        <font weight=\"700\" style=\"italic\">SourceSansPro-BoldItalic.ttf<\/font>/' $SYSXML  
	else
	    sleep 0.5	    
		ui_print "║   Skipping SERIF font installation.    ║"
	fi
}

#Emoji Replacement | Thanks to @MrCarb0n
emojiplus(){
    sleep 0.5	
    
	[ $FONTDIR/Emoji*.ttf ] && ui_print "║   Installing Emoji font.               ║" || ui_print "║   Skipping Emoji installation.  ║"
    
	DEMJ="NotoColorEmoji.ttf"
    [ $ORISYSFONT/$DEMJ ] && cp $FONTDIR/Emoji*.ttf;
	
	SEMJ="$(find $ORISYSFONT -type f ! -name 'NotoColorEmoji.ttf' -name "*Emoji*.ttf" -exec basename {} \;)"	
	for i in $SEMJ; do
        if [ -f $SYSFONT/$DEMJ ]; then
		    ln -s $SYSFONT/$DEMJ $SYSFONT/$i
        fi
    done
	
    [ -d /data/fonts ] && rm -f -rf /data/fonts
}


{
    echo '#!/system/bin/sh'  
    echo '## MFFM Installer v11 by MFFM'
    echo '## 2022.09.14'
    echo ''
    echo '('
    echo 'sleep 90'
    echo ''
    echo 'F1="$(find /data/data -name FacebookEmoji.ttf)"'
    echo 'for i in $F1; do'
    echo '    cp -f /system/fonts/NotoColorEmoji.ttf $i'
    echo 'done'
	echo ''
    echo 'am force-stop com.facebook.orca'
    echo 'am force-stop com.facebook.katana'
    echo ''
    echo 'set_perm_recursive /data/data/com.facebook.katana/app_ras_blobs/FacebookEmoji.ttf 0 0 0755 700'
    echo 'set_perm_recursive /data/data/com.facebook.orca/app_ras_blobs/FacebookEmoji.ttf 0 0 0755 700'
    echo 'set_perm_recursive /data/data/com.facebook.katana/app_ras_blobs 0 0 0755 755'
    echo 'set_perm_recursive /data/data/com.facebook.orca/app_ras_blobs 0 0 0755 755'
    echo ''
    echo '[ -d /data/fonts ] && rm -f -rf /data/fonts'
    echo ')'
} > $MODPATH/service.sh

xmi(){
    #miui main
	mimain='MiLanProVF.ttf MiSansVF.ttf RobotoVF.ttf MiSansVF_Overlay.ttf'
	for i in $mimain; do
	    if [ -f "$ORISYSFONT/$i" ]; then
		    cp $FONTDIR/Regular.ttf $SYSFONT/$i
		fi
	done	
	#miui extra
	miextra='MitypeClock.otf MitypeClockMono.otf MiClock.otf MiClockThin.otf MiClockMono.otf MiClockUyghur-Thin.ttf MiClockTibetan-Thin.ttf MitypeVF.ttf MitypeMonoVF.ttf'
	for i in $miextra; do
	    if [ -f "$ORISYSFONT/$i" ]; then
		    cp $FONTDIR/Regular.ttf $SYSFONT/$i
		fi
	done
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
	if [ -f $MIRRORPATH/system/system_ext/etc/fonts_base.xml ]; then
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

perm() {
    sleep 0.5	
	ui_print "║                                        ║"
	ui_print "║ ■ SETTING UP PERMISSIONS.              ║"
    set_perm_recursive $MODPATH 0 0 0755 0644
    set_perm $MODPATH/service.sh 0 0 0777 0777
}

finish(){
    sleep 0.5	
	ui_print "║                                        ║"
	ui_print "║ ■ CLEANING LEFTOVERS.                  ║"
    rm -f $MODPATH/*.ttf
	rm -f $MODPATH/*.xml
	rm -f $MODPATH/f
	rm -f $MODPATH/bin
	rm -f $MODPATH/*.md
	rm -f $MODPATH/*.zip
	rm -f $MODPATH/LICENSE
	rm -rf $MODPATH/Files
}

mffmex
sfont
prdfnt
monospace
beng
oxygen
xmi
samsung
emojiplus
srf
src
fallback
finish
perm