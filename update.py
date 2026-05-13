import os
import sys
import zipfile
import shutil
import tempfile
import re
import datetime
import glob

def get_font_name(font_path: str) -> str | None:
    try:
        from fontTools.ttLib import TTFont  # type: ignore
    except ImportError:
        return None

    try:
        tt = TTFont(font_path, lazy=True)
        name_tbl = tt["name"]
        for name_id in (16, 1, 4):
            # Prefer Windows / English (platformID=3, platEncID=1, langID=0x0409)
            rec = name_tbl.getName(name_id, 3, 1, 0x0409)
            if rec is None:
                # Mac fallback (platformID=1, platEncID=0, langID=0)
                rec = name_tbl.getName(name_id, 1, 0, 0)
            if rec:
                return rec.toUnicode().strip()
    except Exception:
        pass
    return None

def main():
    print("========================================")
    print("     MFFMv11 Module Updater")
    print("========================================\n")

    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    OLD_MODULES_DIR = os.path.join(SCRIPT_DIR, "Old Modules")
    DIST_DIR = os.path.join(SCRIPT_DIR, "Dist")
    
    if not os.path.isdir(OLD_MODULES_DIR):
        print(f"Error: '{OLD_MODULES_DIR}' folder not found.")
        print("Please create an 'Old Modules' folder and place the zip files there.")
        sys.exit(1)

    zip_files = [f for f in os.listdir(OLD_MODULES_DIR) if f.endswith(".zip")]
    if not zip_files:
        print("No zip files found in 'Old Modules' folder.")
        sys.exit(0)

    os.makedirs(DIST_DIR, exist_ok=True)
    today = datetime.datetime.now()
    date_str = today.strftime("%Y%m%d")
    version = today.strftime("%Y.%m.%d")

    for zip_file in zip_files:
        zip_path = os.path.join(OLD_MODULES_DIR, zip_file)
        print(f"\nProcessing: {zip_file}")

        # Basic check to see if it's a magisk module
        is_valid = False
        with zipfile.ZipFile(zip_path, 'r') as zf:
            names = zf.namelist()
            if "module.prop" in names or "META-INF/com/google/android/update-binary" in names:
                is_valid = True
                
        if not is_valid:
            print(f"  [!] '{zip_file}' doesn't look like a valid module. Skipping.")
            continue

        with tempfile.TemporaryDirectory() as temp_dir:
            old_module_dir = os.path.join(temp_dir, "Old")
            os.makedirs(old_module_dir)
            
            # 1. Extract old module
            with zipfile.ZipFile(zip_path, 'r') as zf:
                zf.extractall(old_module_dir)
                
            # 2. Try to get old name from module.prop
            old_prop_path = os.path.join(old_module_dir, "module.prop")
            name_input = "Unknown Module"
            if os.path.exists(old_prop_path):
                with open(old_prop_path, "r", encoding="utf-8") as f:
                    for line in f:
                        if line.startswith("name="):
                            name_input = line.split("=", 1)[1].strip()
                            break
                # Strip previous version tags like [MFFMv11]
                name_input = re.sub(r"^\[MFFM[^\]]*\]\s*", "", name_input)

            # 3. Try to extract from font in Files/
            old_files_dir = os.path.join(old_module_dir, "Files")
            detected_name = None
            if os.path.exists(old_files_dir):
                font_files = glob.glob(os.path.join(old_files_dir, "*.[to]tf")) + glob.glob(os.path.join(old_files_dir, "*.[TO]TF"))
                if font_files:
                    detected_name = get_font_name(font_files[0])
            
            # Prefer extracted font name, otherwise fallback to old prop name
            final_name = detected_name if detected_name else name_input
            if detected_name:
                print(f"  -> Extracted name from font: {final_name}")
            else:
                print(f"  -> Using name from old module.prop: {final_name}")
            
            modified_name = f"[MFFMv11] {final_name}"
            description = f'Replaces the Android default Roboto font family with "{final_name}". Compatible with Magisk, KernelSU/KernelSU Next, and APatch; KSU/APatch system mounting may require an active mount metamodule.'
            
            # 4. Create a temporary template structure to zip
            temp_template_dir = os.path.join(temp_dir, "Template")
            os.makedirs(temp_template_dir)
            
            # Copy META-INF, customize.sh, LICENSE from current project template
            for item in ["META-INF", "customize.sh", "LICENSE"]:
                src = os.path.join(SCRIPT_DIR, item)
                dst = os.path.join(temp_template_dir, item)
                if os.path.exists(src):
                    if os.path.isdir(src):
                        shutil.copytree(src, dst)
                    else:
                        shutil.copy2(src, dst)
                        
            # Copy Files from old module
            dst_files = os.path.join(temp_template_dir, "Files")
            if os.path.exists(old_files_dir):
                shutil.copytree(old_files_dir, dst_files)
            else:
                os.makedirs(dst_files)
                
            # 5. Create updated module.prop based on current template
            updates = {
                "id": "mffm11",
                "name": modified_name,
                "version": version,
                "versionCode": date_str,
                "author": "MFFM",
                "description": description
            }
            prop_path = os.path.join(temp_template_dir, "module.prop")
            
            current_prop = os.path.join(SCRIPT_DIR, "module.prop")
            if os.path.exists(current_prop):
                with open(current_prop, "r", encoding="utf-8") as f:
                    lines = f.readlines()
                updated_keys = set()
                with open(prop_path, "w", encoding="utf-8", newline="\n") as f:
                    for line in lines:
                        if "=" in line and not line.strip().startswith("#"):
                            k, _ = line.split("=", 1)
                            k = k.strip()
                            if k in updates:
                                f.write(f"{k}={updates[k]}\n")
                                updated_keys.add(k)
                            else:
                                f.write(line)
                        else:
                            f.write(line)
                    # Append any remaining keys
                    for k, v in updates.items():
                        if k not in updated_keys:
                            f.write(f"{k}={v}\n")
            else:
                with open(prop_path, "w", encoding="utf-8", newline="\n") as f:
                    for k, v in updates.items():
                        f.write(f"{k}={v}\n")
                        
            # 6. Zip the new module
            no_spaces = "".join(c for c in final_name if not c.isspace())
            safe_name = "".join(c for c in no_spaces if c.isalnum() or c in "._-")
            if not safe_name:
                safe_name = "MFFM"
                
            archive_name = f"{safe_name}_v{date_str}[MFFMv11].zip"
            archive_path = os.path.join(DIST_DIR, archive_name)
            
            print(f"  -> Building Dist/{archive_name}...")
            
            with zipfile.ZipFile(archive_path, "w", zipfile.ZIP_DEFLATED) as zf:
                # Add explicit directories
                for d in ["Files/", "META-INF/", "META-INF/com/", "META-INF/com/google/", "META-INF/com/google/android/"]:
                    zi = zipfile.ZipInfo(d)
                    zf.writestr(zi, "")
                    
                for root, dirs, files in os.walk(temp_template_dir):
                    for file in files:
                        abs_file = os.path.join(root, file)
                        rel_file = os.path.relpath(abs_file, temp_template_dir).replace("\\", "/")
                        if rel_file == "Files/.gitkeep":
                            continue
                        zf.write(abs_file, rel_file)

    print("\nAll modules updated successfully!")

if __name__ == "__main__":
    main()
