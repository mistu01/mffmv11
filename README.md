# -= MFFM Template v11 =-
- **Can be used as a template or as an installer**
- **Support for AOSP/LOS/PixelStock and Closest Kin Like ROMS**
- **Monospace / Bengali font / Emoji / Serif support (user dependent)**
- **Android 12/13/14/15 ready**
- **Compatible with Magisk, KernelSU/KernelSU Next, and APatch**

# Important Info Before Installation:
Install like a normal module from Magisk, KernelSU/KernelSU Next, or APatch Manager. KernelSU/APatch installs should be done from their manager apps, not from custom recovery.

KernelSU/APatch users: current mount implementations may require an active mount metamodule before regular modules can mount files under `system/`. If fonts do not apply after reboot, install and reboot with a mount metamodule first, such as `meta-overlayfs`, `magic mount`, or `hybrid mount`, then reinstall this module.

# Usages:
You can use the template as an installer or as a regular Magisk module template, or both at the same time. 
To use it as a module template you can copy the renamed files directly to the template's `Files` folder to make a permanent module.

To use the template as an installer first you have to create a folder named `MFFM` in your local storage. Then you can copy your `renamed files` to the `MFFM` & `MFFM/Fonts` folder. Other detailed instructions are in particular sections of the respective topics (Which file/script goes where).

Remember you can use both mode `(Template/Installer)` at the same, so it really doesn't matter where ever `(inside the template or in the MFFM foler)` you put your files. The template should work just fine.

If same category files `(eg. Bengali Fonts)` are present in both the `MFFM` folder and inside of the module `(in Files folder)`, the module's content will be flashed and `MFFM` folder's content will be ignored. 

## Latin/English Fonts
- Download the template from [Releases](https://github.com/mistu2020/mffm_v11_public/tree/main/Releases) folder.
- The best way is to use the template is to use it with `MT Manager` file manager.  With [MT Manager](https://m.apkpure.com/mt-manager/bin.mt.plus) you can directly edit the zip file without unpacking it.
- Eitherway you can unpack the zip file with any file manager, I recommend Mixplorer. And after editing/copying files in the template, repack the template content to `.zip` archive to make a module.
- You are going to need at least one style `Regular.ttf` to use this template. You can use upto 18 styles currently. Rename your font file as stated bellow:
    ```
    Black.ttf
    BlackItalic.ttf
    ExtraBold.ttf
    ExtraBoldItalic.ttf
    Bold.ttf
    BoldItalic.ttf
    SemiBold.ttf
    SemiBoldItalic.ttf
    Medium.ttf
    MediumItalic.ttf
    Regular.ttf
    Italic.ttf
    Light.ttf
    LightItalic.ttf
    ExtraLight.ttf
    ExtraLightItalic.ttf
    Thin.ttf
    ThinItalic.ttf
    ```
- And then copy those font files to `Files` folder of the template to make a module. 
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
 - Put `MFFM_UniEmoji_v5.5.sh` inside the `MFFM Folder (/LocalStorage/MFFM)` folder alongside the renamed emoji file. The add-on stages `NotoColorEmoji.ttf`, scans system emoji font targets, repairs app data emoji fonts with backups, and hooks the module action/service/boot/uninstall lifecycle.
 - UniEmoji writes runtime logs/status under `/sdcard/MFFM/EmojiModule`. KernelSU/APatch without a mount metamodule fall back to data-only emoji repair.
## Monospace
-  To use any `Monospace` font, add  `Mono-` before the name of your font and put it in `MFFM` folder.  EG: rename `Firacode-Regular.ttf` to `Mono-Firacode-Regular.ttf`
## Serif
- To use Serif font, you will need 4 styles. Regular, Italic, Bold and BoldItalic. Rename your fonts like this:
```
Serif-Regular.ttf
Serif-Italic.ttf
Serif-Bold.ttf
Serif-BoldItalic.ttf
```
- After renaming, either copy them direct to `MFFM` folder or make a `zip archive` following this naming pattern, '`Serif-YourFontName.zip`' eg `Serif-SourceSerif.zip` and as usual copy the archive to `MFFM` folder.
- Lastly, however you place your files in `MFFM` folder, if the naming patterns are followed it will be installed once you flash your original font module. 

# GApps Font
- If your MFFM template powered modules stop working in Google Apps or do not change at all, use the module action button in Magisk, KernelSU/KernelSU Next, or APatch Manager. The action disables the Google Fonts provider, clears Google font caches, and restarts Gboard. No reboot is needed for the action path; force close any Google app if it still has old font cache.
- If method mentioned above is not working for you then flash [KillGMSFont](https://github.com/MrCarb0n/killgmsfont) Magisk Module by [MrCarb0n](https://github.com/MrCarb0n/)

# Release Workflow
- Push a tag like `v2026.05.10` to build and publish a GitHub Release automatically.
- You can also run `Build and Release Template` manually from GitHub Actions and provide `version` / `version_code` inputs.
- If `version_code` is not provided, date versions like `2026.05.10` become `20260510`; semver versions like `11.2.3` become `11002003`.

# Credits
- [Magisk](https://github.com/topjohnwu/Magisk) | [Inter Font Pack By kdrag0n](https://github.com/kdrag0n/inter-font-pack)
# Tributes & Acknowledgements
- [OMF](https://gitlab.com/nongthaihoang/oh_my_font) | [OMF Template](https://gitlab.com/nongthaihoang/omftemplate) | [CFI](https://github.com/nongthaihoang/custom_font_installer) | [Noto Emoji Plus](https://gitlab.com/MrCarb0n/NotoEmojiPlus_OMF) | [KillGMSFont](https://github.com/MrCarb0n/killgmsfont) | [Magifont](https://t.me/Magifonts_Support)
# Support And Discussions
- [MFFM Discussion](https://t.me/MFFMDisc) | [MFFM Main](https://t.me/MFFMMain) | [MFFM Blog](https://t.me/mffmex)
