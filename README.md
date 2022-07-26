# -= MFFM Template v.X.xx =-
- *Support for AOSP/LOS/Pixel Stock/Oxygen/Miui/Samsung*
- *Monospace / Bengali font / Emoji support (user dependent)*
- *Android 12/13 ready*
- *Flashable only in Magisk*

# Usage
- Download the template from [Releases](https://github.com/mistu2020/mffm_v11_public/tree/main/releases) folder.
- The best way is to use the template is to use it with `MT Manager` file manager.  With [MT Manager](https://m.apkpure.com/mt-manager/bin.mt.plus) you can directly edit the zip file without unpacking it.
- Eitherway you can unpack the zip file with any file manager, I recommend Mixplorer. And after editing/copying files in the template, repack the template content to `.zip` archive to make a module.
- You are going to need 12 font style to use this template. Rename your font file as stated bellow: 
    ```
    Black.ttf
    BlackItalic.ttf
    Bold.ttf
    BoldItalic.ttf
    Medium.ttf
    MediumItalic.ttf
    Regular.ttf
    Italic.ttf
    Light.ttf
    LightItalic.ttf
    Thin.ttf
    ThinItalic.ttf
    ```
- And then copy those font files to `Files` folder of the template. 
- If you have only one font file or want to use only one weight/style then rename the file to `MFFM.ttf` and copy it to `Files` folder of the template. 

## Optional Usages:
You can use these options if you like. For example you want to use you favourite Emoji Font with this module, or want to use Bengali Font, then you can follow this tutorial stated bellow.\
Remember you can copy the files directly to the template's `Files` foler to make a permanent module, even though the tutorial says to put them in your local storage's `MFFM` folder.\
If you put these optional files directly in `Files` folder of the module, make sure your Local Storage's `MFFM` Folder is empty, otherwise if conflicting files are found in the `MFFM` Folder, the original module's optional content will be overwritten.
## Bengali Fonts 
 - You are gonna need 3 styles/weights of your Bengali font, Bold/Medium/Regular. If you have only one weight (ie. Regular), copy it and make total 3 copies.
 - Rename the 3 weight (Bold/Medium/Regular) Bengali font like this:
```
Beng-Regular.ttf  
Beng-Medium.ttf  
Beng-Bold.ttf
 ```
 - You can directly copy the font files to `MFFM Folder (/LocalStorage/MFFM)` or make a zip of the fonts and rename it to `Beng-FontName.zip` and then copy it to avoid messy environment inside the `MFFM` folder. Eg: `Beng-Kalpurush.zip` 

## Emoji
 - Add `Emoji-` before the name of your Emoji font and put it in the `MFFM` folder. EG: rename `WhatsappEmoji.ttf`  to `Emoji-WhatsappEmoji.ttf`
## Monospace
-  To use any `Monospace` font, add  `Mono-` before the name of your font and put it in `MFFM` folder.  EG: rename `Firacode-Regular.ttf` to `Mono-Firacode-Regular.ttf`

# Magisk Hide / Zygisk Denylist Hidden App Crash
- If you hide any of your app in your `zygisk denylist` and it crashes due to the font module you just flashed created using this template. Then: 
- To solve this issue please follow this solution carefully. 
- Uninstall the font module first and then: 
- Download any of this packages from [HERE](https://github.com/mistu2020/mffm_v11_public/tree/main/Font%20Spoof%20Package) and flash in your `TWRP recovery`
- Reboot and flash your font module once again. 

# Credits
- [Magisk](https://github.com/topjohnwu/Magisk)
- [MrCarb0n's KillGMSFont](https://github.com/MrCarb0n/killgmsfont)
# Tributes
- [OMF Template](https://gitlab.com/nongthaihoang/omftemplate) | [CFI](https://github.com/nongthaihoang/custom_font_installer) | [Noto Emoji Plus](https://gitlab.com/MrCarb0n/NotoEmojiPlus_OMF)
# Support And Discussions
- [MFFM Discussion](https://t.me/MFFMDisc) | [MFFM Main](https://t.me/MFFMMain) | [Magifont](https://t.me/Magifonts_Support) (Automated Bot To Create Magisk Font Module)
