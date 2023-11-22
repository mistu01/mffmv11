## MFFM v11
## 2023.11.22

#Debugging mode enabled
set -xv

#Original Paths
[ -d ${ORIDIR:=`magisk --path`/.magisk/mirror} ] || \ # Borrowed From OMF
    ORIDIR=
[ -d ${ORIPRD:=$ORIDIR/product} ] || \ # Borrowed From OMF
    ORIPRD=$ORIDIR/system/product
[ -d ${ORISYSEXT:=$ORIDIR/system_ext} ] || \ # Borrowed From OMF
    ORISYSEXT=$ORIDIR/system/system_ext

ORIPRDFONT=$ORIPRD/fonts
ORIPRDETC=$ORIPRD/etc
#ORIPRDXML=$ORIPRDETC/fonts_customization.xml
ORIPRDXML=/sdcard/MFFM/fontsxml/fonts_customization.xml
ORISYSFONT=$ORIDIR/system/fonts
ORISYSETC=$ORIDIR/system/etc
#ORISYSXML=$ORISYSETC/fonts.xml
ORISYSXML=/sdcard/MFFM/fontsxml/fonts.xml

#MODPATH
PRDFONT="$MODPATH/$(if [ "$ORIPRD" = "$ORIDIR/product" ]; then echo "product"; else echo "system/product"; fi)/fonts"
PRDETC="$MODPATH/$(if [ "$ORIPRD" = "$ORIDIR/product" ]; then echo "product"; else echo "system/product"; fi)/etc"
PRDXML=$PRDETC/fonts_customization.xml
SYSFONT=$MODPATH/system/fonts
SYSETC=$MODPATH/system/etc
SYSEXTETC="$MODPATH/$(if [ "$ORISYSEXT" = "$ORIDIR/system_ext" ]; then echo "system_ext"; else echo "system/system_ext"; fi)/etc"
SYSXML=$SYSETC/fonts.xml
MODPROP=$MODPATH/module.prop
FONTDIR=$MODPATH/Files

#MFFM
MFFM=/sdcard/MFFM
[ ! -d $MFFM ] && mkdir -p $MFFM

#API
APILEVEL=$(getprop ro.build.version.sdk)

mffmex(){
    sleep 1
	ui_print ""
	ui_print "- Copying MFFM folder resources to module directory."	
	if [ -n "$(find "$FONTDIR" -maxdepth 1 -type f -name "MFFM.ttf" -o -name "Regular.ttf")" ]; then
        :
    else
        snglfnt=$(find "$MFFM" -maxdepth 1 -type f -name "MFFM.ttf")
        if [ -n $snglfnt ]; then
            cp $snglfnt $FONTDIR
        fi
    fi	
	fonts="Black.ttf BlackItalic.ttf Bold.ttf BoldItalic.ttf Medium.ttf MediumItalic.ttf Regular.ttf Italic.ttf Light.ttf LightItalic.ttf Thin.ttf ThinItalic.ttf"
    for file in $fonts; do
    if [ -e $FONTDIR/$file ] || [ -e $FONTDIR/MFFM.ttf ]; then
        :
    else
        fontstocopy="$MFFM/Fonts/$file"
        for i in "$fontstocopy"; do
            if [ -e $i ]; then
                cp $fontstocopy $FONTDIR
            fi
        done
    fi
    done
	if [ -n "$(find "$FONTDIR" -maxdepth 1 -type f \( -name "*.zip" -o -name "*.ttf" \) -name "*Beng*")" ]; then
        :
    else
        bengali=$(find "$MFFM" -maxdepth 1 -type f \( -name "*.zip" -o -name "*.ttf" \) -name "*Beng*")    
        if [ -n "$bengali" ]; then
            cp $bengali $FONTDIR
        fi
    fi
	if [ -n "$(find "$FONTDIR" -maxdepth 1 -type f \( -name "*.zip" -o -name "*.ttf" \) -name "*Serif*")" ]; then
        :
    else
        serif=$(find "$MFFM" -maxdepth 1 -type f \( -name "*.zip" -o -name "*.ttf" \) -name "*Serif*")    
        if [ -n "$serif" ]; then
            cp $serif $FONTDIR
        fi
    fi	
	if [ -n "$(find "$FONTDIR" -maxdepth 1 -type f -name "Mono*.ttf")" ]; then
       :
    else
        monofile=$(find "$MFFM" -maxdepth 1 -type f -name "Mono*.ttf")    
        if [ -n "$monofile" ]; then
            cp $monofile $FONTDIR
        fi
    fi
}

mv $FONTDIR/bin $MODPATH/bin
base64 -d $MODPATH/bin > $MODPATH/f && tar xf $MODPATH/f -C $MODPATH
tar xf $MODPATH/data.xz -C $MODPATH
tar xf $FONTDIR/data -C $MODPATH
mkdir -p $PRDFONT $PRDETC $SYSFONT $SYSETC $SYSEXTETC
[ -f $ORISYSXML ] && cp $ORISYSXML $SYSXML
[ -f $ORIPRDXML ] && cp $ORIPRDXML $PRDXML

    SS="<family name=\"sans-serif\">" SSC="<family name=\"sans-serif-condensed\">" VRD="<alias name=\"verdana\" to=\"sans-serif\" \/>" GSN="<family customizationType=\"new-named-family\" name=\"googlesans\">"
	GS="<family customizationType=\"new-named-family\" name=\"google-sans\">" GST="<family customizationType=\"new-named-family\" name=\"google-sans-text\">" GSB="<family customizationType=\"new-named-family\" name=\"google-sans-bold\">"
	GSM="<family customizationType=\"new-named-family\" name=\"google-sans-medium\">" GSTM="<family customizationType=\"new-named-family\" name=\"google-sans-text-medium\">" GSTB="<family customizationType=\"new-named-family\" name=\"google-sans-text-bold\">"
	GSTBI="<family customizationType=\"new-named-family\" name=\"google-sans-text-bold-italic\">" GSTMI="<family customizationType=\"new-named-family\" name=\"google-sans-text-medium-italic\">" GSTI="<family customizationType=\"new-named-family\" name=\"google-sans-text-italic\">"

    thin="<font weight=\"100\" style=\"normal\">SourceSansPro-Regular.ttf<\/font>"	thinitalic="<font weight=\"100\" style=\"italic\">SourceSansPro-Italic.ttf<\/font>"
	light="<font weight=\"300\" style=\"normal\">SourceSansPro-Bold.ttf<\/font>"	lightitalic="<font weight=\"300\" style=\"italic\">SourceSansPro-BoldItalic.ttf<\/font>"
	regular="<font weight=\"400\" style=\"normal\">NotoSerif-Regular.ttf<\/font>"	italic="<font weight=\"400\" style=\"italic\">NotoSerif-Italic.ttf<\/font>"
	medium="<font weight=\"500\" style=\"normal\">SourceSansPro-SemiBold.ttf<\/font>"	mediumitalic="<font weight=\"500\" style=\"italic\">SourceSansPro-SemiBoldItalic.ttf<\/font>"
	black="<font weight=\"900\" style=\"normal\">DroidSans.ttf<\/font>"	blackitalic="<font weight=\"900\" style=\"italic\">DroidSans-Bold.ttf<\/font>"
	bold="<font weight=\"700\" style=\"normal\">NotoSerif-Bold.ttf<\/font>"    bolditalic="<font weight=\"700\" style=\"italic\">NotoSerif-BoldItalic.ttf<\/font>"

    gregular="<font weight=\"400\" style=\"normal\">Rubik-Regular.ttf<\/font>"	gitalic="<font weight=\"400\" style=\"italic\">Rubik-Italic.ttf<\/font>"
	gmedium="<font weight=\"500\" style=\"normal\">Rubik-Medium.ttf<\/font>"	gmediumitalic="<font weight=\"500\" style=\"italic\">Rubik-MediumItalic.ttf<\/font>"
	gbold="<font weight=\"700\" style=\"normal\">Rubik-Bold.ttf<\/font>"    gbolditalic="<font weight=\"700\" style=\"italic\">Rubik-BoldItalic.ttf<\/font>"

patchsysxml(){
    #sed -i '/<\!-- # MIUI Edit Start -->/,/<\!-- # MIUI Edit END -->/d' $SYSXML
    sed -i 's/RobotoStatic/Roboto/g' $SYSXML
	sed -i "s/$SS/$SS\n        $light\n        $lightitalic\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $black\n        $blackitalic\n        $bold\n        $bolditalic\n    <\/family>\n    <family >/" $SYSXML
	sed -i -n '/<family name=\"sans-serif-condensed\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML   
	sed -i "s/$SSC/$SSC\n        $light\n        $lightitalic\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic/" $SYSXML
    sed -i -n '/<family name=\"google-sans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "s/<family name=\"google-sans\">/<family name=\"google-sans\">\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic/" $SYSXML
	sed -i -n '/<family name=\"googlesans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "s/<family name=\"googlesans\">/<family name=\"google-sans\">\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic/" $SYSXML
	sed -i "s/$VRD/$VRD\n \n    <\!-- GS Starts -->\n    $GS\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic\n    <\/family>\n \n    $GSM\n        $medium\n    <\/family>\n \n    $GSB\n        $bold\n    <\/family>\n \n    $GST\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic\n    <\/family>\n \n    $GSTM\n        $medium\n    <\/family>\n \n    $GSTB\n        $bold\n    <\/family>\n \n    $GSTI\n        $italic\n    <\/family>\n \n    $GSTMI\n        $mediumitalic\n    <\/family>\n \n    $GSTBI\n        $bolditalic\n    <\/family>\n    <\!-- GS Ends -->/g" $SYSXML
}

gsans(){    
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"googlesansclock\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"googlesansclock\">/<family customizationType=\"new-named-family\" name=\"googlesansclock\">\n        $gregular/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-clock\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"google-sans-clock\">/<family customizationType=\"new-named-family\" name=\"googlesansclock\">\n        $gregular/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"audimat\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"audimat\">/<family customizationType=\"new-named-family\" name=\"audimat\">\n        $gregular/" $PRDXML
}

prdscrp(){    
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"manrope\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"manrope\">/<family customizationType=\"new-named-family\" name=\"manrope\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"noto-sans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"noto-sans\">/<family customizationType=\"new-named-family\" name=\"noto-sans\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"source-sans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"source-sans\">/<family customizationType=\"new-named-family\" name=\"source-sans\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"roboto-system\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"roboto-system\">/<family customizationType=\"new-named-family\" name=\"roboto-system\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"rubik\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"rubik\">/<family customizationType=\"new-named-family\" name=\"rubik\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"barlow\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"barlow\">/<family customizationType=\"new-named-family\" name=\"barlow\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"lato\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"lato\">/<family customizationType=\"new-named-family\" name=\"lato\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"fluid-sans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"fluid-sans\">/<family customizationType=\"new-named-family\" name=\"fluid-sans\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
	sed -i -n '/<family customizationType=\"new-named-family\" name=\"harmonyos-sans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"harmonyos-sans\">/<family customizationType=\"new-named-family\" name=\"harmonyos-sans\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
	sed -i -n '/<family customizationType=\"new-named-family\" name=\"op-sans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"op-sans\">/<family customizationType=\"new-named-family\" name=\"op-sans\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
    sed -i -n '/<family customizationType=\"new-named-family\" name=\"oneplusslate\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	sed -i "s/<family customizationType=\"new-named-family\" name=\"oneplusslate\">/<family customizationType=\"new-named-family\" name=\"op-sans\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
}

# Borrowed From OMF
delgsans(){ 
    sed -i '/<family customizationType="new-named-family" name="google-sans">/,/<\/family>/d' $PRDXML
    sed -i '/<family customizationType="new-named-family" name="google-sans-flex">/,/<\/family>/d' $PRDXML
    sed -i '/<family customizationType="new-named-family" name="google-sans-medium">/,/<\/family>/d' $PRDXML
    sed -i '/<family customizationType="new-named-family" name="google-sans-bold">/,/<\/family>/d' $PRDXML
    sed -i '/<family customizationType="new-named-family" name="google-sans-text">/,/<\/family>/d' $PRDXML
    sed -i '/<family customizationType="new-named-family" name="google-sans-text-medium">/,/<\/family>/d' $PRDXML
    sed -i '/<family customizationType="new-named-family" name="google-sans-text-bold">/,/<\/family>/d' $PRDXML
    sed -i '/<family customizationType="new-named-family" name="google-sans-text-italic">/,/<\/family>/d' $PRDXML
    sed -i '/<family customizationType="new-named-family" name="google-sans-text-medium-italic">/,/<\/family>/d' $PRDXML
    sed -i '/<family customizationType="new-named-family" name="google-sans-text-bold-italic">/,/<\/family>/d' $PRDXML
    sed -i '/<family customizationType="new-named-family" name="google-sans-inter">/,/<\/family>/d' $PRDXML
	sed -i '/<family customizationType="new-named-family" name="google-sans-medium-inter">/,/<\/family>/d' $PRDXML
	sed -i '/<family customizationType="new-named-family" name="google-sans-bold-inter">/,/<\/family>/d' $PRDXML
	sed -i '/<family customizationType="new-named-family" name="google-sans-text-inter">/,/<\/family>/d' $PRDXML
	sed -i '/<family customizationType="new-named-family" name="google-sans-text-medium-inter">/,/<\/family>/d' $PRDXML
	sed -i '/<family customizationType="new-named-family" name="google-sans-text-bold-inter">/,/<\/family>/d' $PRDXML
	sed -i '/<family customizationType="new-named-family" name="google-sans-text-italic-inter">/,/<\/family>/d' $PRDXML
	sed -i '/<family customizationType="new-named-family" name="google-sans-text-medium-italic-inter">/,/<\/family>/d' $PRDXML
	sed -i '/<family customizationType="new-named-family" name="google-sans-text-bold-italic-inter">/,/<\/family>/d' $PRDXML
}

# Borrowed From OMF
gfntdsbl(){
    [ ! -f "$MODPATH/service.sh" ] && echo > "$MODPATH/service.sh"
	sed -i '1i( until pm disable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider; do sleep 60; done ) &' $MODPATH/service.sh #Borrowed from OMF
    [ ! -f "$MODPATH/uninstall.sh" ] && echo > "$MODPATH/uninstall.sh"
	sed -i '1i( until pm enable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider; do sleep 5; done ) &' $MODPATH/uninstall.sh #Borrowed from OMF
    echo '( [ -d "/data/fonts" ] && rm -rf /data/fonts ) &' >> $MODPATH/service.sh
}

bengpatch(){
    sed -i '/<family lang="und-Beng" variant="elegant">/,/<\/family>/c\<family lang="und-Beng" variant="elegant">\n    <font weight="400" style="normal">NotoSansBengali-VF.ttf<\/font>\n    <font weight="500" style="normal">NotoSerifBengali-VF.ttf<\/font>\n    <font weight="700" style="normal">NotoSansBengaliUI-VF.ttf<\/font>\n<\/family>' $SYSXML
    sed -i '/<family lang="und-Beng" variant="compact">/,/<\/family>/c\<family lang="und-Beng" variant="compact">\n    <font weight="400" style="normal">NotoSansBengali-VF.ttf<\/font>\n    <font weight="500" style="normal">NotoSerifBengali-VF.ttf<\/font>\n    <font weight="700" style="normal">NotoSansBengaliUI-VF.ttf<\/font>\n<\/family>' $SYSXML
}

beng(){
    sleep 0.5	
    unzip -qq $FONTDIR/Beng*.zip -d $FONTDIR
	cp $FONTDIR/Beng-Regular.ttf $SYSFONT/NotoSansBengali-VF.ttf &&	cp $FONTDIR/Beng-Medium.ttf $SYSFONT/NotoSerifBengali-VF.ttf &&	cp $FONTDIR/Beng-Bold.ttf $SYSFONT/NotoSansBengaliUI-VF.ttf
    [ -f $SYSFONT/NotoSansBengali-VF.ttf ] && { bengpatch && ui_print "  Installing BENGALI fonts."; } || ui_print "  Skipping BENGALI font installation."
}

prdfnt(){
    if [ -f $ORIPRDXML ]; then
	    ln -s $SYSFONT/NotoSerif-Regular.ttf $PRDFONT/Rubik-Regular.ttf
	    ln -s $SYSFONT/NotoSerif-Italic.ttf $PRDFONT/Rubik-Italic.ttf
	    ln -s $SYSFONT/NotoSerif-Bold.ttf $PRDFONT/Rubik-Bold.ttf
	    ln -s $SYSFONT/NotoSerif-BoldItalic.ttf $PRDFONT/Rubik-BoldItalic.ttf
	    ln -s $SYSFONT/SourceSansPro-SemiBold.ttf $PRDFONT/Rubik-Medium.ttf
	    ln -s $SYSFONT/SourceSansPro-SemiBoldItalic.ttf $PRDFONT/Rubik-MediumItalic.ttf
	fi
	if [ -f $PRDFONT/Rubik-Regular.ttf ]; then
	    gsans
	    prdscrp
	fi
}

singlefont(){
    if [ -f $FONTDIR/MFFM.ttf ]; then
        set Black BlackItalic Bold BoldItalic Medium MediumItalic Regular Italic Light LightItalic Thin ThinItalic
	    for i do cp $FONTDIR/MFFM.ttf $FONTDIR/$i.ttf; done
    fi
}

sfont() {
    singlefont
    cp $FONTDIR/Regular.ttf $SYSFONT/NotoSerif-Regular.ttf
    cp $FONTDIR/Italic.ttf $SYSFONT/NotoSerif-Italic.ttf
    cp $FONTDIR/Medium.ttf $SYSFONT/SourceSansPro-SemiBold.ttf
    cp $FONTDIR/MediumItalic.ttf $SYSFONT/SourceSansPro-SemiBoldItalic.ttf
    cp $FONTDIR/Bold.ttf $SYSFONT/NotoSerif-Bold.ttf
    cp $FONTDIR/BoldItalic.ttf $SYSFONT/NotoSerif-BoldItalic.ttf
    cp $FONTDIR/Black.ttf $SYSFONT/DroidSans.ttf
    cp $FONTDIR/BlackItalic.ttf $SYSFONT/DroidSans-Bold.ttf
    #cp $FONTDIR/Thin.ttf $SYSFONT/SourceSansPro-Regular.ttf
    #cp $FONTDIR/ThinItalic.ttf $SYSFONT/SourceSansPro-Italic.ttf	
    cp $FONTDIR/Light.ttf $SYSFONT/SourceSansPro-Bold.ttf
    cp $FONTDIR/LightItalic.ttf $SYSFONT/SourceSansPro-BoldItalic.ttf	
	if [ -f $SYSFONT/NotoSerif-Regular.ttf ]; then
	    sleep 0.5
        ui_print ""		
		ui_print "- Installing Fonts"
		ui_print "  Installing SANS-SERIF fonts"
		patchsysxml
	else
	    sleep 0.5
		ui_print ""		
		ui_print "- Installing Fonts"
		ui_print "  Skipping SANS-SERIF installation."
	fi	
}

monospace(){
    if [ -f $FONTDIR/Mono*.ttf ]; then
        cp $FONTDIR/Mono*.ttf $SYSFONT/CutiveMono.ttf
	    cp $FONTDIR/Mono*.ttf $SYSFONT/DroidSansMono.ttf
		sleep 0.5
	    ui_print "  Installing MONOSPACE fonts."
	else
	    sleep 0.5
	    ui_print "  Skipping MONOSPACE font installation."
    fi
}

srf(){
    unzip -qq $FONTDIR/Serif*.zip -d $FONTDIR
	if [ ! -f $FONTDIR/Serif-Regular.ttf ]; then
	    sleep 0.5
        ui_print "  Installing SERIF fonts."
	    cp $FONTDIR/Regular.ttf $SYSFONT/NotoSerif-Regular.ttf
	    cp $FONTDIR/Italic.ttf $SYSFONT/NotoSerif-Italic.ttf
	    cp $FONTDIR/Bold.ttf $SYSFONT/NotoSerif-Bold.ttf
	    cp $FONTDIR/BoldItalic.ttf $SYSFONT/NotoSerif-BoldItalic.ttf
	elif [ -f $FONTDIR/Serif-Regular.ttf ]; then
	    sleep 0.5
        ui_print "  Installing SERIF fonts."
	    cp $FONTDIR/Serif-Regular.ttf $SYSFONT/NotoSerif-Regular.ttf
	    cp $FONTDIR/Serif-Italic.ttf $SYSFONT/NotoSerif-Italic.ttf
	    cp $FONTDIR/Serif-Bold.ttf $SYSFONT/NotoSerif-Bold.ttf
	    cp $FONTDIR/Serif-BoldItalic.ttf $SYSFONT/NotoSerif-BoldItalic.ttf
	else
	    sleep 0.5 
        ui_print "  Skipping SERIF font installation."
	fi
}

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
	if [ $APILEVEL -ge 30 ]; then
	    #LCClock
		milc='MiSansLatinVF.ttf MiSansTCVF.ttf MiSansRoundedSC.ttf MiSansRoundedTC.ttf MiSansRound-Medium.otf MiClock.otf MiClockThin.otf MiClockMono.otf MiClockUyghur-Thin.ttf MiClockTibetan-Thin.ttf MiSansC_3.005.ttf Interscaled-Regular.otf Interscaled-Medium.otf'
		for i in $milc; do
	        if [ -f "$ORIPRDFONT/$i" ]; then
		        ln -s $SYSFONT/NotoSerif-Regular.ttf $PRDFONT/$i
		    fi
	    done
		
		#LCxml
        sed -i -e '/<family customizationType="new-named-family" name="miclock-misans-rounded-sc">/,/<\/family>/ { /<family customizationType="new-named-family" name="miclock-misans-rounded-sc">/b; /<\/family>/b; d; }' $PRDXML
		sed -i '/<family customizationType="new-named-family" name="miclock-misans-rounded-sc">/a\        <font weight="400" style="normal" postScriptName="MiSansRoundedSC-Regular">MiSansRoundedSC.ttf</font>' $PRDXML		
		sed -i -e '/<family customizationType="new-named-family" name="miclock-misans-rounded-tc">/,/<\/family>/ { /<family customizationType="new-named-family" name="miclock-misans-rounded-tc">/b; /<\/family>/b; d; }' $PRDXML
		sed -i '/<family customizationType="new-named-family" name="miclock-misans-rounded-tc">/a\        <font weight="400" style="normal" postScriptName="MiSansRoundedTC-Regular">MiSansRoundedTC.ttf</font>' $PRDXML
	
	if grep -q 'miui-regular' "$SYSXML" && grep -q 'mipro' "$SYSXML"; then		
		#miui xml
		sed -i -e '/<!-- first font is default -->/,/<!-- Note that aliases must come after the fonts they reference. -->/ {
            /<!-- first font is default -->/!{
                /<!-- Note that aliases must come after the fonts they reference. -->/! {
                    /<family name="sans-serif">/!d
                }
            }
        }' $SYSXML
		sed -i "s/$SS/$SS\n        $light\n        $lightitalic\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $black\n        $blackitalic\n        $bold\n        $bolditalic\n    <\/family>/" $SYSXML
	    cp $ORISYSFONT/Roboto-Regular.ttf $SYSFONT/SourceSansPro-Regular.ttf
		sed -i -e '/<\/familyset>/ {' -e 'r /dev/stdin' -e 'd' -e '}' $SYSXML <<'XML'
    <family>
        <font weight="100" style="normal">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="0" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="100" />
        </font>
        <font weight="200" style="normal">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="0" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="200" />
        </font>
        <font weight="300" style="normal">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="0" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="300" />
        </font>
        <font weight="400" style="normal">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="0" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="400" />
        </font>        
        <font weight="500" style="normal">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="0" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="500" />
        </font>
        <font weight="600" style="normal">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="0" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="600" />
        </font>
        <font weight="700" style="normal">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="0" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="700" />
        </font>
        <font weight="800" style="normal">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="0" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="800" />
        </font>
        <font weight="900" style="normal">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="0" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="900" />
        </font>
        <font weight="100" style="italic">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="1" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="100" />
        </font>
        <font weight="200" style="italic">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="1" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="200" />
        </font>
        <font weight="300" style="italic">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="1" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="300" />
        </font>
        <font weight="400" style="italic">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="1" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="400" />
        </font>
        <font weight="500" style="italic">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="1" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="500" />
        </font>
        <font weight="600" style="italic">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="1" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="600" />
        </font>
        <font weight="700" style="italic">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="1" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="700" />
        </font>
        <font weight="800" style="italic">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="1" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="800" />
        </font>
        <font weight="900" style="italic">SourceSansPro-Regular.ttf
          <axis tag="ital" stylevalue="1" />
          <axis tag="wdth" stylevalue="100" />
          <axis tag="wght" stylevalue="900" />
        </font>
   </family>
</familyset>
XML

		# Attempt To Fix Weight #Doesn't Work #Disbable Miui Optimization
		sed -i -e '/<family name="miui">/,/<\/family>/ { /<\/family>/! { /<family name="miui">/!d } }; /<family name="miui">/a\    <font weight="400" style="normal" postScriptName="MiSansVF">NotoSerif-Regular.ttf</font>' $SYSXML
		sed -i -e '/<family name="miui-thin">/,/<\/family>/ { /<\/family>/! { /<family name="miui-thin">/!d } }; /<family name="miui-thin">/a\    <font weight="100" style="normal" postScriptName="MiSansVF">SourceSansPro-Bold.ttf</font>' $SYSXML
		sed -i -e '/<family name="miui-light">/,/<\/family>/ { /<\/family>/! { /<family name="miui-light">/!d } }; /<family name="miui-light">/a\    <font weight="300" style="normal" postScriptName="MiSansVF">SourceSansPro-Bold.ttf</font>' $SYSXML
		sed -i -e '/<family name="miui-regular">/,/<\/family>/ { /<\/family>/! { /<family name="miui-regular">/!d } }; /<family name="miui-regular">/a\    <font weight="400" style="normal" postScriptName="MiSansVF">NotoSerif-Regular.ttf</font>' $SYSXML
		sed -i -e '/<family name="miui-bold">/,/<\/family>/ { /<\/family>/! { /<family name="miui-bold">/!d } }; /<family name="miui-bold">/a\    <font weight="700" style="normal" postScriptName="MiSansVF">NotoSerif-Bold.ttf</font>' $SYSXML
		sed -i -e '/<family name="mipro">/,/<\/family>/ { /<\/family>/! { /<family name="mipro">/!d } }; /<family name="mipro">/a\    <font weight="400" style="normal" postScriptName="MiSansVF">NotoSerif-Regular.ttf</font>' $SYSXML
		sed -i -e '/<family name="mipro-thin">/,/<\/family>/ { /<\/family>/! { /<family name="mipro-thin">/!d } }; /<family name="mipro-thin">/a\    <font weight="100" style="normal" postScriptName="MiSansVF">SourceSansPro-Bold.ttf</font>' $SYSXML
		sed -i -e '/<family name="mipro-extralight">/,/<\/family>/ { /<\/family>/! { /<family name="mipro-extralight">/!d } }; /<family name="mipro-extralight">/a\    <font weight="200" style="normal" postScriptName="MiSansVF">SourceSansPro-Bold.ttf</font>' $SYSXML
		sed -i -e '/<family name="mipro-light">/,/<\/family>/ { /<\/family>/! { /<family name="mipro-light">/!d } }; /<family name="mipro-light">/a\    <font weight="300" style="normal" postScriptName="MiSansVF">SourceSansPro-Bold.ttf</font>' $SYSXML
		sed -i -e '/<family name="mipro-normal">/,/<\/family>/ { /<\/family>/! { /<family name="mipro-normal">/!d } }; /<family name="mipro-normal">/a\    <font weight="400" style="normal" postScriptName="MiSansVF">NotoSerif-Regular.ttf</font>' $SYSXML
		sed -i -e '/<family name="mipro-regular">/,/<\/family>/ { /<\/family>/! { /<family name="mipro-regular">/!d } }; /<family name="mipro-regular">/a\    <font weight="400" style="normal" postScriptName="MiSansVF">NotoSerif-Regular.ttf</font>' $SYSXML
		sed -i -e '/<family name="mipro-medium">/,/<\/family>/ { /<\/family>/! { /<family name="mipro-medium">/!d } }; /<family name="mipro-medium">/a\    <font weight="500" style="normal" postScriptName="MiSansVF">SourceSansPro-SemiBold.ttf</font>' $SYSXML
		sed -i -e '/<family name="mipro-semibold">/,/<\/family>/ { /<\/family>/! { /<family name="mipro-semibold">/!d } }; /<family name="mipro-semibold">/a\    <font weight="500" style="normal" postScriptName="MiSansVF">SourceSansPro-SemiBold.ttf</font>' $SYSXML
		sed -i -e '/<family name="mipro-demibold">/,/<\/family>/ { /<\/family>/! { /<family name="mipro-demibold">/!d } }; /<family name="mipro-demibold">/a\    <font weight="600" style="normal" postScriptName="MiSansVF">SourceSansPro-SemiBold.ttf</font>' $SYSXML
		sed -i -e '/<family name="mipro-bold">/,/<\/family>/ { /<\/family>/! { /<family name="mipro-bold">/!d } }; /<family name="mipro-bold">/a\    <font weight="700" style="normal" postScriptName="MiSansVF">NotoSerif-Bold.ttf</font>' $SYSXML
		sed -i -e '/<family name="mipro-heavy">/,/<\/family>/ { /<\/family>/! { /<family name="mipro-heavy">/!d } }; /<family name="mipro-heavy">/a\    <font weight="900" style="normal" postScriptName="MiSansVF">DroidSans.ttf</font>' $SYSXML
		sed -i 's/<font weight="400" style="normal" postScriptName="MIUIEX-Normal">MiuiEx-Regular.ttf<\/font>/<font weight="400" style="normal" postScriptName="MIUIEX-Normal">NotoSerif-Regular.ttf<\/font>/' $SYSXML
        sed -i 's/<font weight="700" style="normal" postScriptName="MIUIEX-Bold">MiuiEx-Bold.ttf<\/font>/<font weight="700" style="normal" postScriptName="MIUIEX-Bold">NotoSerif-Bold.ttf<\/font>/' $SYSXML
        sed -i 's/<font weight="300" style="normal" postScriptName="MIUIEX-Light">MiuiEx-Light.ttf<\/font>/<font weight="300" style="normal" postScriptName="MIUIEX-Light">SourceSansPro-Bold.ttf<\/font>/' $SYSXML
    fi
	fi
}

samsung(){
    sed -i -n '/<family name=\"sec-roboto-light\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "s/<family name=\"sec-roboto-light\">/<family name=\"sec-roboto-light\">\n        $regular\n        $medium/" $SYSXML
	sed -i -n '/<family name=\"sec-roboto-condensed\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "s/<family name=\"sec-roboto-condensed\">/<family name=\"sec-roboto-condensed\">\n        $regular\n        $bold/" $SYSXML
	sed -i -n '/<family name=\"sec-roboto-condensed-light\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i "s/<family name=\"sec-roboto-condensed-light\">/<family name=\"sec-roboto-condensed-light\">\n        $light/" $SYSXML
}

oxyp(){
    sed -i '/<\!-- #ifdef/,/*\/ -->/d' $SYSXML
	sed -i '/<family >/,/<\/family>/d' $SYSXML
	sed -i '/<\!-- #ifdef/,/*\/ -->/d' $SYSEXTETC/fonts_base.xml
	sed -i '/<family >/,/<\/family>/d' $SYSEXTETC/fonts_base.xml    	
}

oxygen(){    
    if [ -f $ORISYSETC/fonts_base.xml ]; then
	cp $SYSXML $SYSETC/fonts_base.xml
	fi
	if [ -f $ORIDIR/system_ext/etc/fonts_base.xml ]; then
	cp $SYSXML $SYSEXTETC/fonts_base.xml
	fi
	if [ -f $ORISYSETC/fonts_slate.xml ]; then
	cp $SYSXML $SYSETC/fonts_slate.xml
	fi
	if grep -q 'SysSans-En-Regular.ttf' $ORISYSXML; then oxyp; fi
}

src(){
    local sh="$(find $MFFM -maxdepth 1 -type f -name '*.sh' -exec basename {} \;)"
    local i
    for i in $sh; do
        . $MFFM/$i
    done
}

perm() {
    sleep 0.5	
	ui_print "- Setting up permissions."
    set_perm_recursive $MODPATH 0 0 0755 0644
    set_perm $MODPATH/service.sh 0 0 0777 0777
    set_perm $MODPATH/uninstall.sh 0 0 0777 0777
}

finish(){
    sleep 0.5
	ui_print ""
	ui_print "- Cleaning leftovers."
    rm -f $MODPATH/*.ttf
    rm -f $MODPATH/*.xz
	rm -f $MODPATH/*.xml
	rm -f $MODPATH/f
	rm -f $MODPATH/bin
	rm -f $MODPATH/*.md
	rm -f $MODPATH/*.zip
	rm -f $MODPATH/LICENSE
	rm -rf $MODPATH/Files
	rm -rf $MODPATH/Spoof
}

mffmex
sfont
prdfnt
delgsans
monospace
beng
oxygen
grep -q 'miui' $SYSXML && xmi
samsung
#srf
gfntdsbl
src
finish
perm

sleep 0.5
ui_print "- Done. Reboot to see changes."
ui_print ""
sleep 0.5
ui_print "******************************************"
sleep 0.5
cat << "EOF"
  __  __ ___ ___ __  __ 
 |  \/  | __| __|  \/  |
 | |\/| | _|| _|| |\/| | v11
 |_|  |_|_| |_| |_|  |_| ©2024
EOF
