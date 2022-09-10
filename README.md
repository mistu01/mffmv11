# -= MFFM Template v.X.xx =-
- **Can be used as a template or as an installer**
- **Support for AOSP/LOS/Pixel Stock/Oxygen/Miui/Samsung**
- **Monospace / Bengali font / Emoji / Serif support (user dependent)**
- **Android 12/13 ready**
- **Flashable *only* in Magisk**

# Usages:
You can use the template as an installer or as a regular Magisk module template, or both at the same time.\
To use it as a module template you can copy the `renamed files` directly to the template's `Files` foler to make a permanent module.

To use the template as an installer first you have to create a folder named `MFFM` in your local storage. Then you can copy your `renamed files` to the `MFFM` folder.

Remember you can use both mode `(Template/Installer)` at the same, so it really doesn't matter where ever `(inside the template or in the MFFM foler)` you put your files. The template should work just fine. If same category files `(eg. Bengali Fonts)` are present in both the `MFFM` folder and inside of the module `(in Files folder)`, the module's content will be flashed and `MFFM` folder's content will be ignored. 

## Latin/English Fonts
- Download the template from [Releases](https://github.com/mistu2020/mffm_v11_public/tree/main/Releases) folder.
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
- And then copy those font files to `Files` folder of the template to make a module. 
- If you have only one font file or want to use only one weight/style then rename the file to `MFFM.ttf` and copy it to `Files` folder of the template.
- Put the file to the `MFFM` folder if you want to use it in the `installer` mode. 

# Optional Usage
- Even though the following tutorial follows the `installer` mode, you can shove the `renamed files` directly to the Template's `Files` folder to use it as a permanent module.

## Bengali Fonts
 - You are gonna need 3 styles/weights of your Bengali font, Bold/Medium/Regular. If you have only one weight (ie. Regular), copy it and make total 3 copies.
 - Rename the 3 weight (Bold/Medium/Regular) Bengali font like this:
```
Beng-Regular.ttf  
Beng-Medium.ttf  
Beng-Bold.ttf
 ```
- Then you can directly copy the font files to `MFFM Folder (/LocalStorage/MFFM)` or make a zip archive directly `(without putting them in a folder)` and rename it to `Beng-FontName.zip` and then copy it to `MFFM` folder to avoid messy environment inside the `MFFM` folder. Eg: `Beng-Kalpurush.zip`
- Download the Generic Bengali font configuration file from [here](https://github.com/charityrolfson433/mffmv11/raw/main/Bengali%20Font%20Packages/Beng-MFFM_v1.2.xml) and copy it to the `MFFM` folder.
 
## Emoji
 - Add `Emoji-` before the name of your Emoji font and put it in the `MFFM` folder. EG: rename `WhatsappEmoji.ttf`  to `Emoji-WhatsappEmoji.ttf`
## Monospace
-  To use any `Monospace` font, add  `Mono-` before the name of your font and put it in `MFFM` folder.  EG: rename `Firacode-Regular.ttf` to `Mono-Firacode-Regular.ttf`
## Serif
- To use serif family you should have 4 styles of the font family. `Regular` `Italic` `Bold` & `BoldItalic`. So if you have this 4 files to use with your module, then rename the files according to this:
```
Serif-Regular.ttf
Serif-Italic.ttf
Serif-Bold.ttf
Serif-BoldItalic.ttf
```
- Now you can directly put those files in `MFFM` folder or zip the four files directly `(without putting them in a folder)` and name it `Serif-NameOfYourFont.zip`, Eg: `Serif-SourceSerif.zip` and copy it to the `MFFM` folder.
# Magisk Hide / Zygisk Denylist Hidden App Crash
- If you hide any of your app in your `zygisk denylist` and it crashes due to the font module you just flashed created using this template. Then: 
- To solve this issue please follow this solution carefully. 
- Uninstall the font module first and then: 
- Download any of this packages from [HERE](https://github.com/mistu2020/mffm_v11_public/tree/main/Font%20Spoof%20Package) and flash in your `TWRP recovery`
- Reboot and flash your font module once again.

# GApps Font
- If your Google Apps font don't change by default then flash [KillGMSFont](https://github.com/MrCarb0n/killgmsfont) Magisk Module by [MrCarb0n](https://github.com/MrCarb0n/)

# Credits
- [Magisk](https://github.com/topjohnwu/Magisk) | [Inter Font Pack By kdrag0n](https://github.com/kdrag0n/inter-font-pack)
# Tributes & Acknowledgements
- [OMF](https://gitlab.com/nongthaihoang/oh_my_font) | [OMF Template](https://gitlab.com/nongthaihoang/omftemplate) | [CFI](https://github.com/nongthaihoang/custom_font_installer) | [Noto Emoji Plus](https://gitlab.com/MrCarb0n/NotoEmojiPlus_OMF) | [KillGMSFont](https://github.com/MrCarb0n/killgmsfont) | [Magifont](https://t.me/Magifonts_Support)
# Support And Discussions
- [MFFM Discussion](https://t.me/MFFMDisc) | [MFFM Main](https://t.me/MFFMMain) | [MFFM Blog](https://t.me/mffmex)
