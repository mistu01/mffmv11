## MFFM v11
## 2024.12.29

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
ORIPRDXML=$ORIPRDETC/fonts_customization.xml
#ORIPRDXML=/sdcard/MFFM/fontsxml/fonts_customization.xml
ORISYSFONT=$ORIDIR/system/fonts
ORISYSETC=$ORIDIR/system/etc
ORISYSXML=$ORISYSETC/fonts.xml
ORISYSXMLNEW=$ORISYSETC/font_fallback.xml
#ORISYSXML=/sdcard/MFFM/fontsxml/fonts.xml
#ORISYSXMLNEW=/sdcard/MFFM/fontsxml/font_fallback.xml

umount $ORISYSXML $ORISYSXMLNEW $ORIPRDXML &>/dev/null

#MODPATH
#PRDFONT="$MODPATH/$(if [ "$ORIPRD" = "$ORIDIR/product" ]; then echo "product"; else echo "system/product"; fi)/fonts"
PRDFONT=$MODPATH/system/product/fonts
#PRDETC="$MODPATH/$(if [ "$ORIPRD" = "$ORIDIR/product" ]; then echo "product"; else echo "system/product"; fi)/etc"
PRDETC=$MODPATH/system/product/etc
PRDXML=$PRDETC/fonts_customization.xml
SYSFONT=$MODPATH/system/fonts
SYSETC=$MODPATH/system/etc
#SYSEXTETC="$MODPATH/$(if [ "$ORISYSEXT" = "$ORIDIR/system_ext" ]; then echo "system_ext"; else echo "system/system_ext"; fi)/etc"
SYSEXTETC=$MODPATH/system/system_ext/etc
SYSXML=$SYSETC/fonts.xml
SYSXMLNEW=$SYSETC/font_fallback.xml
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
	fonts="Black.ttf BlackItalic.ttf ExtraBold.ttf ExtraBoldItalic.ttf SemiBold.ttf SemiBoldItalic.ttf ExtraLight.ttf ExtraLightItalic.ttf Bold.ttf BoldItalic.ttf Medium.ttf MediumItalic.ttf Regular.ttf Italic.ttf Light.ttf LightItalic.ttf Thin.ttf ThinItalic.ttf"
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

[ -f $ORIPRDXML ] && cp $ORIPRDXML $PRDXML
[ -f $ORISYSXMLNEW ] && cp $ORISYSXMLNEW $SYSXMLNEW
[ -f $ORISYSXML ] && cp $ORISYSXML $SYSXML

    SS="<family name=\"sans-serif\">" SSC="<family name=\"sans-serif-condensed\">" VRD="<alias name=\"verdana\" to=\"sans-serif\" \/>" GSN="<family customizationType=\"new-named-family\" name=\"googlesans\">"
	GS="<family customizationType=\"new-named-family\" name=\"google-sans\">" GST="<family customizationType=\"new-named-family\" name=\"google-sans-text\">" GSB="<family customizationType=\"new-named-family\" name=\"google-sans-bold\">"
	GSM="<family customizationType=\"new-named-family\" name=\"google-sans-medium\">" GSTM="<family customizationType=\"new-named-family\" name=\"google-sans-text-medium\">" GSTB="<family customizationType=\"new-named-family\" name=\"google-sans-text-bold\">"
	GSTBI="<family customizationType=\"new-named-family\" name=\"google-sans-text-bold-italic\">" GSTMI="<family customizationType=\"new-named-family\" name=\"google-sans-text-medium-italic\">" GSTI="<family customizationType=\"new-named-family\" name=\"google-sans-text-italic\">"

[ -f "$FONTDIR/Thin.ttf" ] && thin="<font weight=\"100\" style=\"normal\">Thin.ttf</font>" || unset thin
[ -f "$FONTDIR/ThinItalic.ttf" ] && thinitalic="<font weight=\"100\" style=\"italic\">ThinItalic.ttf</font>" || unset thinitalic
[ -f "$FONTDIR/ExtraLight.ttf" ] && extralight="<font weight=\"200\" style=\"normal\">ExtraLight.ttf</font>" || unset extralight
[ -f "$FONTDIR/ExtraLightItalic.ttf" ] && extralightitalic="<font weight=\"200\" style=\"italic\">ExtraLightItalic.ttf</font>" || unset extralightitalic
[ -f "$FONTDIR/Light.ttf" ] && light="<font weight=\"300\" style=\"normal\">Light.ttf</font>" || unset light
[ -f "$FONTDIR/LightItalic.ttf" ] && lightitalic="<font weight=\"300\" style=\"italic\">LightItalic.ttf</font>" || unset lightitalic
[ -f "$FONTDIR/Regular.ttf" ] && regular="<font weight=\"400\" style=\"normal\">Regular.ttf</font>" || unset regular
[ -f "$FONTDIR/Italic.ttf" ] && italic="<font weight=\"400\" style=\"italic\">Italic.ttf</font>" || unset italic
[ -f "$FONTDIR/Medium.ttf" ] && medium="<font weight=\"500\" style=\"normal\">Medium.ttf</font>" || unset medium
[ -f "$FONTDIR/MediumItalic.ttf" ] && mediumitalic="<font weight=\"500\" style=\"italic\">MediumItalic.ttf</font>" || unset mediumitalic
[ -f "$FONTDIR/SemiBold.ttf" ] && semibold="<font weight=\"600\" style=\"normal\">SemiBold.ttf</font>" || unset semibold
[ -f "$FONTDIR/SemiBoldItalic.ttf" ] && semibolditalic="<font weight=\"600\" style=\"italic\">SemiBoldItalic.ttf</font>" || unset semibolditalic
[ -f "$FONTDIR/Black.ttf" ] && black="<font weight=\"900\" style=\"normal\">Black.ttf</font>" || unset black
[ -f "$FONTDIR/BlackItalic.ttf" ] && blackitalic="<font weight=\"900\" style=\"italic\">BlackItalic.ttf</font>" || unset blackitalic
[ -f "$FONTDIR/Bold.ttf" ] && bold="<font weight=\"700\" style=\"normal\">Bold.ttf</font>" || unset bold
[ -f "$FONTDIR/BoldItalic.ttf" ] && bolditalic="<font weight=\"700\" style=\"italic\">BoldItalic.ttf</font>" || unset bolditalic
[ -f "$FONTDIR/ExtraBold.ttf" ] && extrabold="<font weight=\"800\" style=\"normal\">ExtraBold.ttf</font>" || unset extrabold
[ -f "$FONTDIR/ExtraBoldItalic.ttf" ] && extrabolditalic="<font weight=\"800\" style=\"italic\">ExtraBoldItalic.ttf</font>" || unset extrabolditalic
#-----
[ -f "$FONTDIR/Light.ttf" ] && glight="<font weight=\"300\" style=\"normal\">Light.ttf</font>" || unset glight
[ -f "$FONTDIR/LightItalic.ttf" ] && glightitalic="<font weight=\"300\" style=\"italic\">LightItalic.ttf</font>" || unset glightitalic
[ -f "$FONTDIR/Regular.ttf" ] && gregular="<font weight=\"400\" style=\"normal\">Regular.ttf</font>" || unset gregular
[ -f "$FONTDIR/Italic.ttf" ] && gitalic="<font weight=\"400\" style=\"italic\">Italic.ttf</font>" || unset gitalic
[ -f "$FONTDIR/Medium.ttf" ] && gmedium="<font weight=\"500\" style=\"normal\">Medium.ttf</font>" || unset gmedium
[ -f "$FONTDIR/MediumItalic.ttf" ] && gmediumitalic="<font weight=\"500\" style=\"italic\">MediumItalic.ttf</font>" || unset gmediumitalic
[ -f "$FONTDIR/Bold.ttf" ] && gbold="<font weight=\"700\" style=\"normal\">Bold.ttf</font>" || unset gbold
[ -f "$FONTDIR/BoldItalic.ttf" ] && gbolditalic="<font weight=\"700\" style=\"italic\">BoldItalic.ttf</font>" || unset gbolditalic

patchsysxml(){
    #sed -i 's/RobotoStatic/Roboto/g' $SYSXML	
	#sed -i "s/$SS/$SS\n        $thin\n        $thinitalic\n        $light\n        $lightitalic\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $black\n        $blackitalic\n        $bold\n        $bolditalic\n   <\/family>\n   <family>/" $SYSXML
	FONT_ENTRIES=""
	for font in thin thinitalic extralight extralightitalic light lightitalic regular italic medium mediumitalic semibold semibolditalic bold bolditalic extrabold extrabolditalic black blackitalic; do
    	[ -n "$(eval echo \$$font)" ] && FONT_ENTRIES="$FONT_ENTRIES        $(eval echo \$$font)\n"
	done
	FONT_ENTRIES=$(echo "$FONT_ENTRIES" | sed 's/\\n$//')

	if [ -n "$SS" ] && [ -n "$FONT_ENTRIES" ]; then
    	sed -i "/$SS/a\\
	$FONT_ENTRIES\\
   	</family>\\
   	<family>" "$SYSXML"
	fi
	
	if [ -n "$SS" ] && [ -n "$FONT_ENTRIES" ]; then
    	sed -i "/$SS/a\\
	$FONT_ENTRIES\\
   	</family>\\
   	<family>" "$SYSXMLNEW"
	fi
	
	sed -i -n '/<family name=\"sans-serif-condensed\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i -n '/<family name=\"sans-serif-condensed\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXMLNEW
	#sed -i "s/$SSC/$SSC\n        $thin\n        $thinitalic\n        $light\n        $lightitalic\n        $regular\n        $italic\n        $medium\n        $mediumitalic\n        $bold\n        $bolditalic/" $SYSXML
    if [ -n "$SSC" ] && [ -n "$FONT_ENTRIES" ]; then
        sed -i "/$SSC/a\\
    $FONT_ENTRIES" "$SYSXML"
    fi
	if [ -n "$SSC" ] && [ -n "$FONT_ENTRIES" ]; then
        sed -i "/$SSC/a\\
    $FONT_ENTRIES" "$SYSXMLNEW"
    fi
	sed -i -n '/<family name=\"roboto-flex\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXML
	sed -i -n '/<family name=\"roboto-flex\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $SYSXMLNEW
	if [ -n "<family name=\"roboto-flex\">" ] && [ -n "$FONT_ENTRIES" ]; then
        sed -i "/<family name=\"roboto-flex\">/a\\
    $FONT_ENTRIES" "$SYSXML"
    fi
	if [ -n "<family name=\"roboto-flex\">" ] && [ -n "$FONT_ENTRIES" ]; then
        sed -i "/<family name=\"roboto-flex\">/a\\
    $FONT_ENTRIES" "$SYSXMLNEW"
    fi
}

sfont() {    
    cp $FONTDIR/*.ttf $SYSFONT
	if [ -f $SYSFONT/Regular.ttf ]; then
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

delgsans(){
    sed -i -E "/<family customizationType=\"new-named-family\" name=\"(google-sans|google-sans-flex|google-sans-medium|google-sans-bold|google-sans-text|google-sans-text-medium|google-sans-text-bold|google-sans-text-italic|google-sans-text-medium-italic|google-sans-text-bold-italic|google-sans-inter|google-sans-medium-inter|google-sans-bold-inter|google-sans-text-inter|google-sans-text-medium-inter|google-sans-text-bold-inter|google-sans-text-italic-inter|google-sans-text-medium-italic-inter|google-sans-text-bold-italic-inter)\">/,/<\/family>/d" $PRDXML
}

gsans(){
    var1="google-sans-clock sfroundedtime sfsofttime-semibold googlesansclock audimat"
	for v1 in $var1; do
        sed -i "/<family customizationType=\"new-named-family\" name=\"$v1\">/,/<\/family>/{/<family customizationType=\"new-named-family\" name=\"$v1\">/b;/<\/family>/b;d}" $PRDXML
    done
	if [ -n "$bold" ]; then
        for name in "google-sans-clock" "googlesansclock" "audimat" "sfroundedtime" "sfsofttime-semibold"; do
            sed -i "/<family customizationType=\"new-named-family\" name=\"$name\">/,/<\/family>/c\    <family customizationType=\"new-named-family\" name=\"$name\">\n        $bold\n    <\/family>" $PRDXML
        done
    elif [ -n "$medium" ]; then
        for name in "google-sans-clock" "googlesansclock" "audimat" "sfroundedtime" "sfsofttime-semibold"; do
            sed -i "/<family customizationType=\"new-named-family\" name=\"$name\">/,/<\/family>/c\    <family customizationType=\"new-named-family\" name=\"$name\">\n        $medium\n    <\/family>" $PRDXML
        done
    elif [ -n "$regular" ]; then
        for name in "google-sans-clock" "googlesansclock" "audimat" "sfroundedtime" "sfsofttime-semibold"; do
            sed -i "/<family customizationType=\"new-named-family\" name=\"$name\">/,/<\/family>/c\    <family customizationType=\"new-named-family\" name=\"$name\">\n        $regular\n    <\/family>" $PRDXML
        done
    fi
	delgsans
}

prdscrp(){    
    GFONT_ENTRIES=""
    for gfont in light lightitalic regular italic medium mediumitalic black blackitalic bold bolditalic; do
        [ -n "$(eval echo \$$gfont)" ] && GFONT_ENTRIES="$GFONT_ENTRIES        $(eval echo \$$gfont)\n"
    done
    
    GFONT_ENTRIES=$(echo "$GFONT_ENTRIES" | sed 's/\\n$//')
    
    if [ -n "$GFONT_ENTRIES" ]; then
        for name in "oneplusslate" "op-sans" "harmonyos-sans" "fluid-sans" "lato" "barlow" "rubik" "roboto-system" "source-sans" "noto-sans" "manrope" "zilla-slab-medium"; do
            sed -i -n '/<family customizationType=\"new-named-family\" name=\"$name\">/{p; :a; N; /<\/family>/!ba; s/.*\n//}; p' $PRDXML
			sed -i "/<family customizationType=\"new-named-family\" name=\"$name\">/,/<\/family>/c\    <family customizationType=\"new-named-family\" name=\"$name\">\n        $GFONT_ENTRIES\n    <\/family>" $PRDXML
        done
    fi    
}

gfntdsbl() {
    echo ""
    echo "  [INFO] Starting Google Fonts disable operation..."
    sleep 0.5

    # Create action.sh
    echo "  [INFO] Creating action.sh script..."
    cat > "$MODPATH/action.sh" << 'EOF'
#!/bin/sh

# Define variables
mod_path=/data/adb/modules/mffm11
post_fs_data="$mod_path/post-fs-data.sh"

echo "[INFO] Starting action script execution..."
sleep 0.5

# Check if post-fs-data.sh exists
if [ -f "$post_fs_data" ]; then
    echo "[INFO] Found $post_fs_data"
    sleep 0.5
    
    echo "[INFO] Changing directory to $mod_path"
    cd "$mod_path" || {
        echo "[ERROR] Failed to change directory to $mod_path"
        exit 1
    }
    sleep 0.5
    
    echo "[INFO] Setting executable permissions for post-fs-data.sh"
    chmod +x "$post_fs_data"
    sleep 0.5
    
    echo "[INFO] Executing post-fs-data.sh"
    exec "$post_fs_data"
else
    echo "[WARNING] post-fs-data.sh does not exist in $mod_path"
    sleep 0.5
    exit 1
fi

sleep 0.5
exit 0
EOF

    # Set executable permission for action.sh
    echo "  [INFO] Setting executable permissions for action.sh"
    chmod +x "$MODPATH/action.sh"
    sleep 0.5

    # Create post-fs-data.sh
    echo "  [INFO] Creating post-fs-data.sh script..."
    cat > "$MODPATH/post-fs-data.sh" << 'EOF'
#!/system/bin/sh

echo "[INFO] Disabling Google Fonts Provider..."
pm disable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider
sleep 0.5

echo "[INFO] Disabling Fonts Update Scheduler..."
pm disable com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService
sleep 0.5

echo "[INFO] Removing fonts data directory..."
rm -rf /data/fonts
sleep 0.5

echo "[INFO] Removing Google GMS fonts..."
rm -rf /data/data/com.google.android.gms/files/fonts/opentype/*ttf
sleep 0.5

echo "[INFO] Font disable operations completed successfully"
EOF

    echo "  [INFO] All scripts created successfully"
    sleep 0.5
}

bengpatch(){
    sed -i '/<family lang="und-Beng" variant="elegant">/,/<\/family>/c\<family lang="und-Beng" variant="elegant">\n    <font weight="400" style="normal">NotoSansBengali-VF.ttf<\/font>\n    <font weight="500" style="normal">NotoSerifBengali-VF.ttf<\/font>\n    <font weight="700" style="normal">NotoSansBengaliUI-VF.ttf<\/font>\n<\/family>' $SYSXML
    sed -i '/<family lang="und-Beng" variant="elegant">/,/<\/family>/c\<family lang="und-Beng" variant="elegant">\n    <font weight="400" style="normal">NotoSansBengali-VF.ttf<\/font>\n    <font weight="500" style="normal">NotoSerifBengali-VF.ttf<\/font>\n    <font weight="700" style="normal">NotoSansBengaliUI-VF.ttf<\/font>\n<\/family>' $SYSXMLNEW
    sed -i '/<family lang="und-Beng" variant="compact">/,/<\/family>/c\<family lang="und-Beng" variant="compact">\n    <font weight="400" style="normal">NotoSansBengali-VF.ttf<\/font>\n    <font weight="500" style="normal">NotoSerifBengali-VF.ttf<\/font>\n    <font weight="700" style="normal">NotoSansBengaliUI-VF.ttf<\/font>\n<\/family>' $SYSXML
    sed -i '/<family lang="und-Beng" variant="compact">/,/<\/family>/c\<family lang="und-Beng" variant="compact">\n    <font weight="400" style="normal">NotoSansBengali-VF.ttf<\/font>\n    <font weight="500" style="normal">NotoSerifBengali-VF.ttf<\/font>\n    <font weight="700" style="normal">NotoSansBengaliUI-VF.ttf<\/font>\n<\/family>' $SYSXMLNEW
}

beng(){
    sleep 0.5	
    unzip -qq $FONTDIR/Beng*.zip -d $FONTDIR
	cp $FONTDIR/Beng-Regular.ttf $SYSFONT/NotoSansBengali-VF.ttf &&	cp $FONTDIR/Beng-Medium.ttf $SYSFONT/NotoSerifBengali-VF.ttf &&	cp $FONTDIR/Beng-Bold.ttf $SYSFONT/NotoSansBengaliUI-VF.ttf
    [ -f $SYSFONT/NotoSansBengali-VF.ttf ] && { bengpatch && ui_print "  Installing BENGALI fonts."; } || ui_print "  Skipping BENGALI font installation."
}

prdfnt(){
    if [ -f $ORIPRDXML ]; then
	    ln -s $SYSFONT/Regular.ttf $PRDFONT/Regular.ttf
	    ln -s $SYSFONT/Italic.ttf $PRDFONT/Italic.ttf
	    ln -s $SYSFONT/Bold.ttf $PRDFONT/Bold.ttf
	    ln -s $SYSFONT/BoldItalic.ttf $PRDFONT/BoldItalic.ttf
	    ln -s $SYSFONT/Medium.ttf $PRDFONT/Medium.ttf
	    ln -s $SYSFONT/MediumItalic.ttf $PRDFONT/MediumItalic.ttf
	    ln -s $SYSFONT/Regular.ttf $PRDFONT/Regular.ttf
	    ln -s $SYSFONT/Italic.ttf $PRDFONT/Italic.ttf
	fi
	if [ -f $PRDFONT/Regular.ttf ]; then
	    gsans
	    prdscrp
	fi
}

prdfnt2() {
    if [ -f $ORIPRDXML ]; then
	    ln -s $SYSFONT/Regular.ttf $PRDFONT/Regular.ttf
	    ln -s $SYSFONT/Regular.ttf $PRDFONT/GoogleSansClock-Regular.ttf
	    ln -s $SYSFONT/Italic.ttf $PRDFONT/Italic.ttf
	    ln -s $SYSFONT/Bold.ttf $PRDFONT/Bold.ttf
	    ln -s $SYSFONT/BoldItalic.ttf $PRDFONT/BoldItalic.ttf
	    ln -s $SYSFONT/Medium.ttf $PRDFONT/Medium.ttf
	    ln -s $SYSFONT/MediumItalic.ttf $PRDFONT/MediumItalic.ttf
	    ln -s $SYSFONT/Light.ttf $PRDFONT/Light.ttf
	    ln -s $SYSFONT/LightItalic.ttf $PRDFONT/LightItalic.ttf
	fi
	if [ -f "$MODPATH/system/product/etc/fonts_customization.xml" ]; then
        echo -e '<fonts-modification version="1">\n<family customizationType="new-named-family" name="google-sans-clock">\n<font>GoogleSansClock-Regular.ttf</font>\n</family>\n</fonts-modification>' > $MODPATH/system/product/etc/fonts_customization.xml
	fi
}

a15() {
    [ -f "/system/etc/font_fallback.xml" ] && cp "$SYSXML" "$MODPATH/system/etc/font_fallback.xml"
    sed -i 's/<familyset version="23">/<familyset>/g' "$MODPATH/system/etc/font_fallback.xml"
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

srf(){
    unzip -qq $FONTDIR/Serif*.zip -d $FONTDIR
	if [ ! -f $FONTDIR/Serif-Regular.ttf ]; then
	    sleep 0.5
        ui_print "  Installing SANS-SERIF as SERIF fonts."    
		replacement=""
		for style in regular italic bold bolditalic; do
    		value=$(eval echo \$$style)
    		[ -n "$value" ] && echo -e "$value" >> $MODPATH/replacement_tmp
		done
		replacement=$(cat $MODPATH/replacement_tmp)
		rm $MODPATH/replacement_tmp
		# Replace the <family name="serif"> block in the XML file
		awk -v replacement="$(echo -e "$replacement")" '
		BEGIN { in_family = 0 }
		/<family name="serif">/ {
    		print $0; 
    		in_family = 1; 
    		print replacement;
    		next;
		}
		/<\/family>/ && in_family {
    		print $0;  # Ensure </family> is printed
    		in_family = 0;
    		next;
		}
		!in_family { print $0 }
		' "$SYSXML" > temp.xml && mv temp.xml "$SYSXML"
		
		awk -v replacement="$(echo -e "$replacement")" '
		BEGIN { in_family = 0 }
		/<family name="serif">/ {
    		print $0; 
    		in_family = 1; 
    		print replacement;
    		next;
		}
		/<\/family>/ && in_family {
    		print $0;  # Ensure </family> is printed
    		in_family = 0;
    		next;
		}
		!in_family { print $0 }
		' "$SYSXMLNEW" > temp.xml && mv temp.xml "$SYSXMLNEW"
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
#prdfnt
prdfnt2
monospace
beng
srf
gfntdsbl
src
#fallback
#a15
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
 |_|  |_|_| |_| |_|  |_| ©2025
EOF
