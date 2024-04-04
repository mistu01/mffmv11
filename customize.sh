## MFFM v11
## 2024.03.12

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

grep -q 'miui' $SYSXML && {
  echo "- Miui detected, Not supported, Aborting installation."  
  exit 1
}

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

v() {
    sed -i "s/\(version=\)\(.*\)/\1\2$1/" module.prop
}

mv $FONTDIR/bin $MODPATH/bin
base64 -d $MODPATH/bin > $MODPATH/f && tar xf $MODPATH/f -C $MODPATH
tar xf $MODPATH/data.xz -C $MODPATH
tar xf $FONTDIR/data -C $MODPATH
mkdir -p $PRDFONT $PRDETC $SYSFONT $SYSETC $SYSEXTETC
if [ ! -f "$ORISYSXML" ]; then    
    nohup am start -a android.intent.action.VIEW -d https://telegra.ph/Installation-Logic-for-seamless-installing-updating-12-28 >/dev/null 2>&1 &
    exit 1
else    
    cp "$ORISYSXML" "$SYSXML"
fi
[ -f $ORIPRDXML ] && cp $ORIPRDXML $PRDXML

    SS="<family name=\"sans-serif\">" SSC="<family name=\"sans-serif-condensed\">" VRD="<alias name=\"verdana\" to=\"sans-serif\" \/>" GSN="<family customizationType=\"new-named-family\" name=\"googlesans\">"
	GS="<family customizationType=\"new-named-family\" name=\"google-sans\">" GST="<family customizationType=\"new-named-family\" name=\"google-sans-text\">" GSB="<family customizationType=\"new-named-family\" name=\"google-sans-bold\">"
	GSM="<family customizationType=\"new-named-family\" name=\"google-sans-medium\">" GSTM="<family customizationType=\"new-named-family\" name=\"google-sans-text-medium\">" GSTB="<family customizationType=\"new-named-family\" name=\"google-sans-text-bold\">"
	GSTBI="<family customizationType=\"new-named-family\" name=\"google-sans-text-bold-italic\">" GSTMI="<family customizationType=\"new-named-family\" name=\"google-sans-text-medium-italic\">" GSTI="<family customizationType=\"new-named-family\" name=\"google-sans-text-italic\">"

    thin="<font weight=\"100\" style=\"normal\">NotoSansBuhid-Regular.ttf<\/font>"	thinitalic="<font weight=\"100\" style=\"italic\">NotoSansCarian-Regular.ttf<\/font>"
	light="<font weight=\"300\" style=\"normal\">CarroisGothicSC-Regular.ttf<\/font>"	lightitalic="<font weight=\"300\" style=\"italic\">ComingSoon.ttf<\/font>"
	regular="<font weight=\"400\" style=\"normal\">DroidSans.ttf<\/font>"	italic="<font weight=\"400\" style=\"italic\">DroidSans-Bold.ttf<\/font>"
	medium="<font weight=\"500\" style=\"normal\">SourceSansPro-SemiBold.ttf<\/font>"	mediumitalic="<font weight=\"500\" style=\"italic\">SourceSansPro-SemiBoldItalic.ttf<\/font>"
	black="<font weight=\"900\" style=\"normal\">SourceSansPro-Regular.ttf<\/font>"	blackitalic="<font weight=\"900\" style=\"italic\">SourceSansPro-Italic.ttf<\/font>"
	bold="<font weight=\"700\" style=\"normal\">SourceSansPro-Bold.ttf<\/font>"    bolditalic="<font weight=\"700\" style=\"italic\">SourceSansPro-BoldItalic.ttf<\/font>"

    gregular="<font weight=\"400\" style=\"normal\">Rubik-Regular.ttf<\/font>"	gitalic="<font weight=\"400\" style=\"italic\">Rubik-Italic.ttf<\/font>"
	gmedium="<font weight=\"500\" style=\"normal\">Rubik-Medium.ttf<\/font>"	gmediumitalic="<font weight=\"500\" style=\"italic\">Rubik-MediumItalic.ttf<\/font>"
	gbold="<font weight=\"700\" style=\"normal\">Rubik-Bold.ttf<\/font>"    gbolditalic="<font weight=\"700\" style=\"italic\">Rubik-BoldItalic.ttf<\/font>"

patchsysxml(){
    sed -i 's/RobotoStatic/Roboto/g' $SYSXML	
	sed -i "s/$SS/$SS\n        $thin\n        $thinitalic\n        $light\n        $lightitalic\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $black\n        $blackitalic\n        $bold\n        $bolditalic\n   <\/family>\n   <family>/" $SYSXML
	sed -i -n '/<family name=\"sans-serif-condensed\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML   
	sed -i "s/$SSC/$SSC\n        $thin\n        $thinitalic\n        $light\n        $lightitalic\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic/" $SYSXML
}

sfont() {
    singlefont
    cp $FONTDIR/Regular.ttf $SYSFONT/DroidSans.ttf
    cp $FONTDIR/Italic.ttf $SYSFONT/DroidSans-Bold.ttf
    cp $FONTDIR/Medium.ttf $SYSFONT/SourceSansPro-SemiBold.ttf
    cp $FONTDIR/MediumItalic.ttf $SYSFONT/SourceSansPro-SemiBoldItalic.ttf
    cp $FONTDIR/Bold.ttf $SYSFONT/SourceSansPro-Bold.ttf
    cp $FONTDIR/BoldItalic.ttf $SYSFONT/SourceSansPro-BoldItalic.ttf
    cp $FONTDIR/Black.ttf $SYSFONT/SourceSansPro-Regular.ttf
    cp $FONTDIR/BlackItalic.ttf $SYSFONT/SourceSansPro-Italic.ttf
    cp $FONTDIR/Thin.ttf $SYSFONT/NotoSansBuhid-Regular.ttf
    cp $FONTDIR/ThinItalic.ttf $SYSFONT/NotoSansCarian-Regular.ttf	
    cp $FONTDIR/Light.ttf $SYSFONT/CarroisGothicSC-Regular.ttf
    cp $FONTDIR/LightItalic.ttf $SYSFONT/ComingSoon.ttf	
	if [ -f $SYSFONT/DroidSans.ttf ]; then
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

gsans(){
    if grep -q '<family customizationType="new-named-family" name="google-sans">' $PRDXML; then 
        sed -i -n '/<family customizationType=\"new-named-family\" name=\"googlesansclock\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	    sed -i "s/<family customizationType=\"new-named-family\" name=\"googlesansclock\">/<family customizationType=\"new-named-family\" name=\"googlesansclock\">\n        $gmedium/" $PRDXML
        sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-clock\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	    sed -i "s/<family customizationType=\"new-named-family\" name=\"google-sans-clock\">/<family customizationType=\"new-named-family\" name=\"googlesansclock\">\n        $gmedium/" $PRDXML
        sed -i -n '/<family customizationType=\"new-named-family\" name=\"audimat\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	    sed -i "s/<family customizationType=\"new-named-family\" name=\"audimat\">/<family customizationType=\"new-named-family\" name=\"audimat\">\n        $gmedium/" $PRDXML
        #----------
		sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	    sed -i "s/<family customizationType=\"new-named-family\" name=\"google-sans\">/<family customizationType=\"new-named-family\" name=\"google-sans\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
        sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-text\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	    sed -i "s/<family customizationType=\"new-named-family\" name=\"google-sans-text\">/<family customizationType=\"new-named-family\" name=\"google-sans-text\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
        sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-flex\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	    sed -i "s/<family customizationType=\"new-named-family\" name=\"google-sans-flex\">/<family customizationType=\"new-named-family\" name=\"google-sans-flex\">\n        $gregular\n        $gmedium\n        $gbold\n        $gitalic\n        $gmediumitalic\n        $gbolditalic/" $PRDXML
        sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-medium\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	    sed -i "s/<family customizationType=\"new-named-family\" name=\"google-sans-medium\">/<family customizationType=\"new-named-family\" name=\"google-sans-medium\">\n        $gmedium/" $PRDXML
        sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-text-medium\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	    sed -i "s/<family customizationType=\"new-named-family\" name=\"google-sans-text-medium\">/<family customizationType=\"new-named-family\" name=\"google-sans-text-medium\">\n        $gmedium/" $PRDXML
        sed -i -n '/<family customizationType=\"new-named-family\" name=\"google-sans-bold\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
	    sed -i "s/<family customizationType=\"new-named-family\" name=\"google-sans-bold\">/<family customizationType=\"new-named-family\" name=\"google-sans-bold\">\n        $gbold/" $PRDXML
        sed -i '/<family customizationType="new-named-family" name="google-sans-text-bold">/{p; :a; N; /<\/family>/!ba; s/.*\n/        '"$gbold"'\n/}; s/<family customizationType="new-named-family" name="google-sans-text-bold">/<family customizationType="new-named-family" name="google-sans-text-bold">\n        '"$gbold"'/' $PRDXML
	    sed -i '/<family customizationType="new-named-family" name="google-sans-text-italic">/{p; :a; N; /<\/family>/!ba; s/.*\n/        '"$gitalic"'\n/}; s/<family customizationType="new-named-family" name="google-sans-text-italic">/<family customizationType="new-named-family" name="google-sans-text-italic">\n        '"$gitalic"'/' $PRDXML
	    sed -i '/<family customizationType="new-named-family" name="google-sans-text-medium-italic">/{p; :a; N; /<\/family>/!ba; s/.*\n/        '"$gmediumitalic"'\n/}; s/<family customizationType="new-named-family" name="google-sans-text-medium-italic">/<family customizationType="new-named-family" name="google-sans-text-medium-italic">\n        '"$gmediumitalic"'/' $PRDXML
	    sed -i '/<family customizationType="new-named-family" name="google-sans-text-bold-italic">/{p; :a; N; /<\/family>/!ba; s/.*\n/        '"$gbolditalic"'\n/}; s/<family customizationType="new-named-family" name="google-sans-text-bold-italic">/<family customizationType="new-named-family" name="google-sans-text-bold-italic">\n        '"$gbolditalic"'/' $PRDXML 
	else    
        sed -i "s/$VRD/$VRD\n \n    <!-- GS Starts -->\n    $GS\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic\n    <\/family>\n \n    $GSM\n        $medium\n    <\/family>\n \n    $GSB\n        $bold\n    <\/family>\n \n    $GST\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic\n    <\/family>\n \n    $GSTM\n        $medium\n    <\/family>\n \n    $GSTB\n        $bold\n    <\/family>\n \n    $GSTI\n        $italic\n    <\/family>\n \n    $GSTMI\n        $mediumitalic\n    <\/family>\n \n    $GSTBI\n        $bolditalic\n    <\/family>\n    <!-- GS Ends -->/g" $SYSXML
    fi  
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
gfntdsbl(){
    echo 'MODDIR=${0%/*}
until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
until [ -d /sdcard ]; do sleep 1; done
sleep 1 

pm disable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider
pm disable com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService
rm -rf /data/fonts
rm -rf /data/data/com.google.android.gms/files/fonts/opentype/*ttf
rm -rf /data/user/0/com.google.android.gms/files/fonts/opentype/*ttf' > $MODPATH/service.sh
    #[ ! -f "$MODPATH/uninstall.sh" ] && echo > "$MODPATH/uninstall.sh"
	#sed -i '1i( until pm enable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider; do sleep 5; done ) &' $MODPATH/uninstall.sh #Borrowed from OMF
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
	    ln -s $SYSFONT/DroidSans.ttf $PRDFONT/Rubik-Regular.ttf
	    ln -s $SYSFONT/DroidSans-Bold.ttf $PRDFONT/Rubik-Italic.ttf
	    ln -s $SYSFONT/SourceSansPro-Bold.ttf $PRDFONT/Rubik-Bold.ttf
	    ln -s $SYSFONT/SourceSansPro-BoldItalic.ttf $PRDFONT/Rubik-BoldItalic.ttf
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

moto(){
    sed -i "/<family name=\"hanyiqihei\" customizationType=\"new-named-family\">/,/<\/family>/c\<family name=\"hanyiqihei\" customizationType=\"new-named-family\">\n\t<font weight=\"400\" style=\"normal\" postScriptName=\"HYQiHei-EES\">\n\t\tRubik-Regular.ttf\n\t</font>\n</family>" $PRDXML
    sed -i "/<family name=\"zhongsong\" customizationType=\"new-named-family\">/,/<\/family>/c\<family name=\"zhongsong\" customizationType=\"new-named-family\">\n\t<font weight=\"400\" style=\"normal\" postScriptName=\"AaZhongsongNon-CommercialUse\">\n\t\tRubik-Regular.ttf\n\t</font>\n</family>" $PRDXML
    sed -i "/<family name=\"Inter-Thin\" customizationType=\"new-named-family\">/,/<\/family>/c\<family name=\"Inter-Thin\" customizationType=\"new-named-family\">\n\t<font weight=\"400\" style=\"normal\" postScriptName=\"Inter-Thin\">\n\t\tRubik-Regular.ttf\n\t</font>\n</family>" $PRDXML
    sed -i "/<family name=\"Rookery-Regular\" customizationType=\"new-named-family\">/,/<\/family>/c\
    <font weight=\"400\" style=\"normal\" postScriptName=\"Rookery-Regular\">\n\
        Rubik-Regular.ttf\n\
    <\/font>\n\
    <font weight=\"500\" style=\"normal\" postScriptName=\"Rookery-Medium\">\n\
        Rubik-Medium.ttf\n\
    <\/font>\n\
    <font weight=\"400\" style=\"italic\" postScriptName=\"Rookery-Italic\">\n\
        Rubik-Italic.ttf\n\
    <\/font>" $PRDXML
}

srf(){
    unzip -qq $FONTDIR/Serif*.zip -d $FONTDIR
	if [ ! -f $FONTDIR/Serif-Regular.ttf ]; then
	    sleep 0.5
        ui_print "  Installing SANS-SERIF as SERIF fonts."
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

fallback() {
    cp $FONTDIR/DroidSans.ttf $SYSFONT
	sed -i -e '/<\/familyset>/ {r '"$FONTDIR"'/fallback.xml' -e 'd;}' $SYSXML
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
monospace
beng
srf
gfntdsbl
src
moto
#fallback
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
