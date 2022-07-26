# -= MFFM Template v.X.xx =-

- *Support for AOSP/LOS/Pixel Stock/Oxygen/Miui/Samsung*
- *Monospace / Bengali font / Emoji support (user dependent)*
- *Android 12/13 ready*
- *Flashable only in Magisk*
# Usage
**Create a folder named MFFM in your local storage to use the extended custom option support. The folder should be automatically created if you flash for the first time. The following Bengali Font/Monospace Font/Emoji font tutorial shows how you can get the best out of this template.
You can prepare all this files and put them to MFFM Folder or you can directly push them to your Module's Files folder. If you make a module with all this custom option then make sure to keep your Local Storage's MFFM folder empty otherwise the module's custom option will be overwritten.**
## Bengali Fonts 
 - You are gonna need 3 styles/weights of your Bengali font, Bold/Medium/Regular. If you have only one weight (ie. Regular), copy it and make total 3 copies.
 - Rename the 3 weight (Bold/Medium/Regular) Bengali font like this:
  
       Beng-Regular.ttf  
       Beng-Medium.ttf  
       Beng-Bold.ttf
   
 - From this point you can directly copy the font files to `MFFM Folder (/LocalStorage/MFFM)` or make a zip of the fonts and rename it to `Beng-FontName.zip` and then copy it to avoid messy environment inside the `MFFM` folder. Eg: `Beng-Kalpurush.zip` 

## Emoji
 - Add `Emoji-` before the name of your Emoji font and put it in the `MFFM` folder. EG: rename `WhatsappEmoji.ttf`  to `Emoji-WhatsappEmoji.ttf`
## Monospace
-  To use any `Monospace` font, add  `Mono-` before the name of your font and put it in `MFFM` folder.  EG: rename `Firacode-Regular.ttf` to `Mono-Firacode-Regular.ttf`

# Magisk Hide / Zygisk Denylist Hidden App Crash
- If you hide any of your app in your `zygisk denylist` and it crashes due to the font module you just flashed created using this template. Then: 
- To solve this issue please follow this solution carefully. 
- Uninstall the font module first and then: 
- Download any of this packages from [HERE](https://github.com/mistu2020/mffm_v11_public/tree/main/Font%20Spoof%20Package) and flash in your `TWRP recovery` before flashing the font module in magisk. 
