# -= MFFM Template v.X.xx =-
- **Can be used as a template or as an installer**
- **Support for AOSP/LOS/Pixel Stock/Oxygen/~~Miui~~/Samsung (Miui is broken atm)**
- **Monospace / Bengali font / Emoji / ~~Serif support~~ (user dependent)**
- **Android 12/13/14 ready**
- **Compatible with Magisk and KSU**

# Usages:
You can use the template as an installer or as a regular Magisk module template, or both at the same time. \
To use it as a module template you can copy the renamed files directly to the template's `Files` folder to make a permanent module.

To use the template as an installer first you have to create a folder named `MFFM` in your local storage. Then you can copy your `renamed files` to the `MFFM` & `MFFM/fonts` folder.\ 
Other detailed instructions are in particular sections of the respective topis (Which file/script goes where).

Remember you can use both mode `(Template/Installer)` at the same, so it really doesn't matter where ever `(inside the template or in the MFFM foler)` you put your files. The template should work just fine.\
If same category files `(eg. Bengali Fonts)` are present in both the `MFFM` folder and inside of the module `(in Files folder)`, the module's content will be flashed and `MFFM` folder's content will be ignored. 

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
- If you want to use in installer mode, create a folder named `Fonts` inside `MFFM` folder. Put the renamed files in the `MFFM/Fonts` folder. Flash the template/Installer

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
 
## Emoji
 - Add `Emoji-` before the name of your Emoji font and put it in the `MFFM` folder. EG: rename `WhatsappEmoji.ttf`  to `Emoji-WhatsappEmoji.ttf`
 - Download the Emoji Addon from [here](https://github.com/charityrolfson433/mffmv11/raw/main/Emoji%20Fonts%20Packges/MFFM_UniEmoji_v5.1.sh). Put it inside the `MFFM Folder (/LocalStorage/MFFM)` folder alongside the renamed emoji file.
## Monospace
-  To use any `Monospace` font, add  `Mono-` before the name of your font and put it in `MFFM` folder.  EG: rename `Firacode-Regular.ttf` to `Mono-Firacode-Regular.ttf`
## Serif
- **Serif Support withdrawn due in rarity of usage and to use native spoof.**
# Magisk Hide / Zygisk Denylist Hidden App Crash
- **With the latest changes modules can be used without any major issue, yet if you find any issues, report in the group.**

# GApps Font
- If your Google Apps font don't change by default then flash [KillGMSFont](https://github.com/MrCarb0n/killgmsfont) Magisk Module by [MrCarb0n](https://github.com/MrCarb0n/)

# Credits
- [Magisk](https://github.com/topjohnwu/Magisk) | [Inter Font Pack By kdrag0n](https://github.com/kdrag0n/inter-font-pack)
# Tributes & Acknowledgements
- [OMF](https://gitlab.com/nongthaihoang/oh_my_font) | [OMF Template](https://gitlab.com/nongthaihoang/omftemplate) | [CFI](https://github.com/nongthaihoang/custom_font_installer) | [Noto Emoji Plus](https://gitlab.com/MrCarb0n/NotoEmojiPlus_OMF) | [KillGMSFont](https://github.com/MrCarb0n/killgmsfont) | [Magifont](https://t.me/Magifonts_Support)
# Support And Discussions
- [MFFM Discussion](https://t.me/MFFMDisc) | [MFFM Main](https://t.me/MFFMMain) | [MFFM Blog](https://t.me/mffmex)
