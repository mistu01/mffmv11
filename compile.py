import os
import sys
import zipfile
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
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    
    # 1. Look for a font in Files to extract name
    files_dir = os.path.join(SCRIPT_DIR, "Files")
    font_files = []
    if os.path.isdir(files_dir):
        font_files = glob.glob(os.path.join(files_dir, "*.[to]tf")) + glob.glob(os.path.join(files_dir, "*.[TO]TF"))
    
    detected_name = None
    if font_files:
        # Try to extract name from the first font found
        detected_name = get_font_name(font_files[0])
        if detected_name:
            if re.search(r"MFFM|Mistu", detected_name, re.IGNORECASE):
                cleaned_name = re.sub(r"(?i)mffm|mistu", "", detected_name)
                cleaned_name = re.sub(r"\s+", " ", cleaned_name).strip(" -_")
                if cleaned_name:
                    print(f"Extracted font name '{detected_name}' contained MFFM/Mistu. Cleaned to: '{cleaned_name}'")
                    detected_name = cleaned_name
                else:
                    detected_name = None
    
    # 2. Ask user for name
    if detected_name:
        print(f"Extracted font name: {detected_name}")
        custom = input(f"Press Enter to use '{detected_name}', or type a custom name: ").strip()
        name = custom if custom else detected_name
    else:
        if font_files:
            print("Font found, but 'fonttools' is not installed or unable to read name.")
            print("Run 'pip install fonttools' to enable automatic name extraction.")
        name = input("Enter module name: ").strip()
        
    if not name:
        print("Name cannot be empty.", file=sys.stderr)
        sys.exit(1)
        
    # 3. Update module.prop
    today = datetime.datetime.now()
    date_str = today.strftime("%Y%m%d")
    version = today.strftime("%Y.%m.%d")
    modified_name = f"[MFFMv11] {name}"
    description = f'Replaces the Android default Roboto font family with "{name}". Compatible with Magisk, KernelSU/KernelSU Next, and APatch; KSU/APatch system mounting may require an active mount metamodule.'
    
    prop_path = os.path.join(SCRIPT_DIR, "module.prop")
    
    updates = {
        "id": "mffm11",
        "name": modified_name,
        "version": version,
        "versionCode": date_str,
        "description": description
    }
    
    if os.path.exists(prop_path):
        with open(prop_path, "r", encoding="utf-8") as f:
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
            
            # Add any missing keys
            for k, v in updates.items():
                if k not in updated_keys:
                    f.write(f"{k}={v}\n")
    else:
        with open(prop_path, "w", encoding="utf-8", newline="\n") as f:
            for k, v in updates.items():
                f.write(f"{k}={v}\n")
            
    # 4. Create ZIP archive
    no_spaces = "".join(c for c in name if not c.isspace())
    safe_name = "".join(c for c in no_spaces if c.isalnum() or c in "._-")
    if not safe_name:
        safe_name = "MFFM"
    
    archive_name = f"{safe_name}_v{date_str}[MFFMv11].zip"
    dist_dir = os.path.join(SCRIPT_DIR, "Dist")
    os.makedirs(dist_dir, exist_ok=True)
    archive_path = os.path.join(dist_dir, archive_name)
    
    items_to_zip = ["Files", "META-INF", "module.prop", "customize.sh", "LICENSE"]
    
    print(f"Created archive: Dist/{archive_name}")
    
    with zipfile.ZipFile(archive_path, "w", zipfile.ZIP_DEFLATED) as zf:
        # Create directories explicitly for META-INF and Files
        for d in ["Files/", "META-INF/", "META-INF/com/", "META-INF/com/google/", "META-INF/com/google/android/"]:
            zi = zipfile.ZipInfo(d)
            zf.writestr(zi, "")
            
        for item in items_to_zip:
            item_path = os.path.join(SCRIPT_DIR, item)
            if not os.path.exists(item_path):
                continue
                
            if os.path.isfile(item_path):
                zf.write(item_path, item)
            elif os.path.isdir(item_path):
                for root, dirs, files in os.walk(item_path):
                    for file in files:
                        abs_file = os.path.join(root, file)
                        rel_file = os.path.relpath(abs_file, SCRIPT_DIR).replace("\\", "/")
                        if rel_file == "Files/.gitkeep":
                            continue
                        zf.write(abs_file, rel_file)

if __name__ == "__main__":
    main()
