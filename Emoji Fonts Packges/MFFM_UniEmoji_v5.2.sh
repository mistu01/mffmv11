# Universal Emoji Extension For MFFM v5.2
# By MFFM
# 2023-11-20
# Special Thanks To @MrCarb0n

echo ""
uniemoji(){
    [ $MFFM/Emoji*.ttf ] && ui_print "- Installing Custom Emoji" || ui_print "- Custom Emoji Resources Not Found."
    DEMJ="NotoColorEmoji.ttf"
    [ $ORISYSFONT/$DEMJ ] && cp $MFFM/Emoji*.ttf $SYSFONT/$DEMJ &&  ui_print "- Replacing $DEMJ ✅" || ui_print "- Replacing $DEMJ ❎"
	
	SEMJ="$(find $ORISYSFONT -type f ! -name 'NotoColorEmoji.ttf' -name "*Emoji*.ttf" -exec basename {} \;)"	
	for i in $SEMJ ; do
        if [ -f $SYSFONT/$DEMJ ]; then
		    ln -s $SYSFONT/$DEMJ $SYSFONT/$i && ui_print "- Replacing $i ✅" || ui_print "- Replacing $i ❎"
        fi
    done
	
	find /data/data/ -type f -name '*Emoji*.ttf' | while read -r newfile; do    
        cp $MFFM/Emoji*.ttf $newfile &&  ui_print "- Replacing $newfile ✅" || ui_print "- Replacing $newfile ❎"
        set_perm_recursive $newfile 0 0 0755 755
		am force-stop com.facebook.orca
        am force-stop com.facebook.katana 
    done
	
    echo "- Clearing Gboard Cache"    
    [ -d /data/data/com.google.android.inputmethod.latin ] &&
        find /data -type d -path '*inputmethod.latin*/*cache*' -exec rm -f -rf {} + &&
        am force-stop com.google.android.inputmethod.latin && echo "  Done ✅"
		
	[ -d /data/fonts ] && rm -f -rf /data/fonts
}

uniemoji

[ ! -f "$MODPATH/service.sh" ] && echo > "$MODPATH/service.sh"

cat <<EOL >> "$MODPATH/service.sh"

# Universal Emoji Extension For MFFM
# By MFFM
# 2023-11-08
# Special Thanks To @MrCarb0n
{
while [ "\$(getprop sys.boot_completed)" != "1" ]
do
    sleep 60
done

file="/system/fonts/NotoColorEmoji.ttf"

find /data/data/ -type f -name '*Emoji*.ttf' | while read -r newfile; do    
    cp "\$file" "\$newfile"
    set_perm_recursive "\$newfile" 0 0 0755 755
done

am force-stop com.facebook.orca
am force-stop com.facebook.katana
} &

EOL
