import os
import sys
import zipfile
import re
import datetime
import glob
import shutil
import hashlib
from pathlib import Path
from collections import Counter
from dataclasses import dataclass

@dataclass(frozen=True)
class StyleInfo:
    style: str
    weight_name: str
    weight_class: int
    width_name: str
    width_class: int | None
    is_italic: bool
    italic_word: str

WEIGHT_ALIASES = (
    ("ExtraBlack", 950),
    ("UltraBlack", 950),
    ("ExtraBold", 800),
    ("UltraBold", 800),
    ("SemiBold", 600),
    ("DemiBold", 600),
    ("ExtraLight", 200),
    ("UltraLight", 200),
    ("Thin", 100),
    ("Light", 300),
    ("Book", 400),
    ("Regular", 400),
    ("Normal", 400),
    ("Roman", 400),
    ("Medium", 500),
    ("Bold", 700),
    ("Black", 900),
    ("Heavy", 900),
)

WIDTH_ALIASES = (
    ("UltraCondensed", 1),
    ("ExtraCondensed", 2),
    ("SemiCondensed", 4),
    ("Condensed", 3),
    ("Normal", 5),
    ("SemiExpanded", 6),
    ("ExtraExpanded", 8),
    ("UltraExpanded", 9),
    ("Expanded", 7),
)

ITALIC_WORDS = ("Italic", "Oblique")

def normalize_spaces(value: str) -> str:
    return re.sub(r"\s+", " ", value.replace("\x00", "")).strip()

def compact_key(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "", value.lower())

def preferred_name_record(records):
    def score(record):
        if record.platformID == 3 and record.langID in (0x409, 0):
            return 0
        if record.platformID == 3:
            return 1
        if record.platformID == 0:
            return 2
        if record.platformID == 1 and record.langID == 0:
            return 3
        return 4

    return min(records, key=score, default=None)

def decode_name(record) -> str:
    try:
        return normalize_spaces(record.toUnicode())
    except Exception:
        try:
            return normalize_spaces(record.string.decode(record.getEncoding(), errors="replace"))
        except Exception:
            return normalize_spaces(str(record.string))

def get_name(font, *name_ids: int) -> str:
    name_table = font.get("name")
    if not name_table:
        return ""

    for name_id in name_ids:
        record = preferred_name_record(
            [record for record in name_table.names if record.nameID == name_id]
        )
        if record:
            value = decode_name(record)
            if value:
                return value
    return ""

def name_id_exists(font, name_id: int) -> bool:
    name_table = font.get("name")
    return bool(name_table and any(record.nameID == name_id for record in name_table.names))

def infer_style_from_filename(path: Path) -> str:
    stem = re.sub(r"[_-]+", " ", path.stem)
    stem = re.sub(r"(?<=[a-z])(?=[A-Z])", " ", stem)
    words = normalize_spaces(stem).split()
    style_words = []

    known = {name.lower() for name, _value in WEIGHT_ALIASES}
    known |= {name.lower() for name, _value in WIDTH_ALIASES}
    known |= {word.lower() for word in ITALIC_WORDS}

    for word in words:
        if word.lower() in known:
            style_words.append(word)

    return " ".join(style_words) or "Regular"

def replace_family_base(current_family: str, old_base: str, new_base: str) -> str:
    current_family = normalize_spaces(current_family)
    old_base = normalize_spaces(old_base)
    new_base = normalize_spaces(new_base)

    if not old_base:
        return new_base

    if current_family == old_base:
        return new_base

    prefix = f"{old_base} "
    if current_family.startswith(prefix):
        return normalize_spaces(new_base + current_family[len(old_base) :])

    return new_base

def find_alias(style_key: str, aliases: tuple[tuple[str, int], ...]) -> tuple[str, int] | None:
    for name, value in aliases:
        if compact_key(name) in style_key:
            return name, value
    return None

def analyze_style(style: str) -> StyleInfo:
    style = normalize_spaces(style) or "Regular"
    style_key = compact_key(style)

    italic_word = ""
    for word in ITALIC_WORDS:
        if compact_key(word) in style_key:
            italic_word = word
            break

    weight = find_alias(style_key, WEIGHT_ALIASES)
    width = find_alias(style_key, WIDTH_ALIASES)

    weight_name, weight_class = weight if weight else ("Regular", 400)
    width_name, width_class = width if width else ("", None)

    if not weight and italic_word:
        weight_name, weight_class = "Regular", 400

    return StyleInfo(
        style=style,
        weight_name=weight_name,
        weight_class=weight_class,
        width_name=width_name,
        width_class=width_class,
        is_italic=bool(italic_word),
        italic_word=italic_word or "Italic",
    )

def legacy_names(family: str, style: StyleInfo) -> tuple[str, str]:
    variant_parts = []

    if style.width_name and style.width_name != "Normal":
        variant_parts.append(style.width_name)

    if style.weight_class not in (400, 700):
        variant_parts.append(style.weight_name)

    legacy_family = normalize_spaces(" ".join([family, *variant_parts]))
    subfamily_parts = []

    if style.weight_class == 700:
        subfamily_parts.append("Bold")
    if style.is_italic:
        subfamily_parts.append(style.italic_word)

    legacy_subfamily = " ".join(subfamily_parts) or "Regular"
    return legacy_family, legacy_subfamily

def full_font_name(family: str, style: StyleInfo) -> str:
    if style.style == "Regular":
        return family
    return normalize_spaces(f"{family} {style.style}")

def sanitize_postscript_part(value: str) -> str:
    value = normalize_spaces(value)
    value = re.sub(r"[^A-Za-z0-9]", "", value)
    return value or "Font"

def postscript_name(family: str, style: StyleInfo) -> str:
    ps_family = sanitize_postscript_part(family)
    if style.style == "Regular":
        candidate = ps_family
    else:
        candidate = f"{ps_family}-{sanitize_postscript_part(style.style)}"

    if len(candidate) <= 63:
        return candidate

    digest = hashlib.sha1(candidate.encode("ascii", errors="ignore")).hexdigest()[:8]
    keep = max(1, 63 - len(digest) - 1)
    return f"{candidate[:keep]}-{digest}"

def unique_identifier(version: str, ps_name: str, mode: str) -> str:
    if mode == "versioned" and version:
        return f"{version};{ps_name}"
    return ps_name.replace("-", "")

def encode_for_record(record, value: str) -> bytes:
    try:
        return value.encode(record.getEncoding(), errors="replace")
    except Exception:
        if record.platformID in (0, 3):
            return value.encode("utf-16-be", errors="replace")
        return value.encode("macroman", errors="replace")

def set_name(font, name_id: int, value: str, add_missing: bool) -> None:
    name_table = font["name"]
    found = False

    for record in name_table.names:
        if record.nameID == name_id:
            record.string = encode_for_record(record, value)
            found = True

    if add_missing and not found:
        name_table.setName(value, name_id, 3, 1, 0x409)
        name_table.setName(value, name_id, 1, 0, 0)

def update_os2_and_head(font, style: StyleInfo) -> None:
    is_bold = style.weight_class >= 700

    os2 = font.get("OS/2")
    if os2:
        os2.usWeightClass = style.weight_class
        if style.width_class is not None:
            os2.usWidthClass = style.width_class

        fs_selection = os2.fsSelection
        fs_selection &= ~((1 << 0) | (1 << 5) | (1 << 6))
        if style.is_italic:
            fs_selection |= 1 << 0
        if is_bold:
            fs_selection |= 1 << 5
        if not style.is_italic and not is_bold:
            fs_selection |= 1 << 6
        os2.fsSelection = fs_selection

    head = font.get("head")
    if head:
        mac_style = head.macStyle
        mac_style &= ~((1 << 0) | (1 << 1))
        if is_bold:
            mac_style |= 1 << 0
        if style.is_italic:
            mac_style |= 1 << 1
        head.macStyle = mac_style

def update_cff_names(font, new_family: str, full_name: str, ps_name: str, weight_name: str) -> None:
    cff_table = font.get("CFF ")
    if not cff_table:
        return

    top_dict = cff_table.cff.topDictIndex[0]
    top_dict.FontName = ps_name
    top_dict.FamilyName = new_family
    top_dict.FullName = full_name
    top_dict.Weight = weight_name

def update_fvar_axis_names(font, old_family: str, new_family: str) -> None:
    fvar = font.get("fvar")
    if not fvar:
        return

    for axis in fvar.axes:
        if getattr(axis, "axisNameID", 0xFFFF) == 0xFFFF:
            continue

        current_name = get_name(font, axis.axisNameID)
        if not current_name:
            continue

        if old_family and old_family.lower() in current_name.lower():
            new_axis_name = current_name.replace(old_family, new_family)
            set_name(font, axis.axisNameID, new_axis_name, add_missing=False)

def update_fvar_instance_names(font, new_family: str) -> None:
    fvar = font.get("fvar")
    if not fvar:
        return

    for instance in fvar.instances:
        if getattr(instance, "postscriptNameID", 0xFFFF) == 0xFFFF:
            continue

        instance_style = get_name(font, instance.subfamilyNameID) or "Regular"
        instance_ps = postscript_name(new_family, analyze_style(instance_style))
        set_name(font, instance.postscriptNameID, instance_ps, add_missing=False)

def update_stat_table(font, old_family: str, new_family: str) -> None:
    stat = font.get("STAT")
    if not stat:
        return

    if hasattr(stat, "table") and hasattr(stat.table, "designAxes"):
        for axis in stat.table.designAxes:
            if hasattr(axis, "axisNameID") and axis.axisNameID != 0xFFFF:
                current_name = get_name(font, axis.axisNameID)
                if current_name and old_family and old_family.lower() in current_name.lower():
                    new_axis_name = current_name.replace(old_family, new_family)
                    set_name(font, axis.axisNameID, new_axis_name, add_missing=False)

    if hasattr(stat, "table") and hasattr(stat.table, "axisValueArrays"):
        for axis_value_array in stat.table.axisValueArrays:
            if hasattr(axis_value_array, "axisValueRecords"):
                for record in axis_value_array.axisValueRecords:
                    if hasattr(record, "valueNameID") and record.valueNameID != 0xFFFF:
                        current_name = get_name(font, record.valueNameID)
                        if current_name and old_family and old_family.lower() in current_name.lower():
                            new_value_name = current_name.replace(old_family, new_family)
                            set_name(font, record.valueNameID, new_value_name, add_missing=False)

def get_font_name(font_path: str) -> str | None:
    try:
        from fontTools.ttLib import TTFont
    except ImportError:
        return None

    try:
        tt = TTFont(font_path, lazy=True)
        name_tbl = tt["name"]
        for name_id in (16, 1, 4):
            rec = name_tbl.getName(name_id, 3, 1, 0x0409)
            if rec is None:
                rec = name_tbl.getName(name_id, 1, 0, 0)
            if rec:
                return rec.toUnicode().strip()
    except Exception:
        pass
    return None

def port_ren41(files_dir: str):
    from fontTools.ttLib import TTFont
    
    font_paths = glob.glob(os.path.join(files_dir, "*.[to]tf")) + glob.glob(os.path.join(files_dir, "*.[TO]TF"))
    if not font_paths:
        print("No font files found for renaming.")
        return
        
    print(f"[Step 1/4] Running ren41 font renaming on {len(font_paths)} file(s)...")
    for font_path in font_paths:
        try:
            with TTFont(font_path, lazy=True) as tt:
                name_tbl = tt["name"]
                rec = name_tbl.getName(6, 3, 1, 0x0409)
                if rec is None:
                    rec = name_tbl.getName(6, 1, 0, 0)
                
                if rec:
                    name_val = rec.toUnicode().strip()
                else:
                    print(f"  Skipping '{os.path.basename(font_path)}': No nameID 6 found.")
                    continue
                    
                if not name_val:
                    print(f"  Skipping '{os.path.basename(font_path)}': nameID 6 is empty.")
                    continue
                    
                if "-" in name_val:
                    new_name = name_val.split("-", 1)[1]
                else:
                    new_name = ""
                    
                if not new_name:
                    print(f"  Skipping '{os.path.basename(font_path)}': No valid suffix after '-' in nameID 6 ({name_val}).")
                    continue
                    
                new_ttf_path = os.path.join(files_dir, f"{new_name}.ttf")
                if font_path != new_ttf_path:
                    if os.path.exists(new_ttf_path):
                        os.remove(new_ttf_path)
                    os.rename(font_path, new_ttf_path)
                    print(f"  Renamed '{os.path.basename(font_path)}' to '{new_name}.ttf'")
        except Exception as e:
            print(f"  Error processing '{os.path.basename(font_path)}' in ren41: {e}")

    # Check for RegularItalic.ttf and rename to Italic.ttf
    reg_italic_path = os.path.join(files_dir, "RegularItalic.ttf")
    if os.path.exists(reg_italic_path):
        italic_path = os.path.join(files_dir, "Italic.ttf")
        if os.path.exists(italic_path):
            os.remove(italic_path)
        os.rename(reg_italic_path, italic_path)
        print("  Detected 'RegularItalic.ttf', renamed it to 'Italic.ttf'")

    # Warn if Regular.ttf is missing and auto-rename if a *Regular*.ttf is found
    reg_path = os.path.join(files_dir, "Regular.ttf")
    if not os.path.exists(reg_path):
        regular_matches = []
        for f in os.listdir(files_dir):
            if f.lower().endswith(".ttf") and "regular" in f.lower() and f != "Regular.ttf":
                regular_matches.append(f)
                
        if regular_matches:
            match_file = regular_matches[0]
            match_path = os.path.join(files_dir, match_file)
            shutil.move(match_path, reg_path)
            print("\n" + "!" * 80)
            print(f"WARNING: 'Regular.ttf' was missing, but detected '{match_file}'.")
            print(f"Automatically renamed '{match_file}' to 'Regular.ttf' to resolve this.")
            print("!" * 80 + "\n")
        else:
            print("\n" + "!" * 80)
            print("WARNING: 'Regular.ttf' was not found in the Files directory!")
            print("Please check your font files and rename the eligible base font to 'Regular.ttf'")
            print("so that Magisk, KernelSU, or APatch can load the main sans-serif style correctly.")
            print("!" * 80 + "\n")

def port_remove_hinting(files_dir: str, SCRIPT_DIR: str):
    from dehinter.font import dehint
    from fontTools.ttLib import TTFont
    
    font_paths = glob.glob(os.path.join(files_dir, "*.ttf"))
    if not font_paths:
        print("No .ttf files found for dehinting.")
        return
        
    originals_dir = os.path.join(SCRIPT_DIR, "hinted_originals")
    os.makedirs(originals_dir, exist_ok=True)
    
    print(f"[Step 2/4] Starting dehinting using dehinter on {len(font_paths)} file(s)...")
    for font_path in font_paths:
        basename = os.path.basename(font_path)
        try:
            backup_path = os.path.join(originals_dir, basename)
            if not os.path.exists(backup_path):
                shutil.copy2(font_path, backup_path)
                print(f"  Original file backed up to: {backup_path}")
            else:
                print(f"  Backup already exists: {basename}. Using backup for safety.")
                
            font = TTFont(backup_path)
            dehint(font)
            font.save(font_path)
            print(f"  Successfully removed hinting from {basename}")
        except Exception as e:
            print(f"  Error removing hinting from {basename}: {e}")

def port_rename_font_metadata(files_dir: str):
    from fontTools.ttLib import TTFont
    
    font_paths = [Path(p) for p in glob.glob(os.path.join(files_dir, "*.ttf"))]
    if not font_paths:
        print("No .ttf files found for renaming metadata.")
        return
        
    metadata = []
    for path in font_paths:
        try:
            with TTFont(path, lazy=True, recalcBBoxes=False, recalcTimestamp=False) as font:
                family = get_name(font, 16, 1) or path.stem
                style = get_name(font, 17, 2) or infer_style_from_filename(path)
                version = get_name(font, 5)
                is_variable = "fvar" in font
                metadata.append((path, family, style, version, is_variable))
        except Exception as e:
            print(f"  Cannot read font metadata for {path.name}: {e}")
            
    if not metadata:
        return
        
    families = [item[1] for item in metadata if item[1]]
    if not families:
        return
    counts = Counter(families)
    highest = max(counts.values())
    candidates = [family for family, count in counts.items() if count == highest]
    old_base_family = sorted(candidates, key=lambda f: (len(f), f.lower()))[0]
    
    if not old_base_family.startswith("MFFM"):
        new_family_base = f"MFFM {old_base_family}"
    else:
        new_family_base = old_base_family
        
    print(f"[Step 3/4] Renaming internal font family: '{old_base_family}' -> '{new_family_base}'")
    
    for path, family, style_text, version, is_variable in metadata:
        try:
            new_family = replace_family_base(family, old_base_family, new_family_base)
            style = analyze_style(style_text)
            legacy_family_name, legacy_subfamily_name = legacy_names(new_family, style)
            full_name = full_font_name(new_family, style)
            ps_name = postscript_name(new_family, style)
            unique_id = unique_identifier(version, ps_name, "compact")
            
            with TTFont(path, recalcBBoxes=False) as font:
                set_name(font, 1, legacy_family_name, add_missing=True)
                set_name(font, 2, legacy_subfamily_name, add_missing=True)
                set_name(font, 3, unique_id, add_missing=True)
                set_name(font, 4, full_name, add_missing=True)
                set_name(font, 6, ps_name, add_missing=True)
                set_name(font, 16, new_family, add_missing=True)
                set_name(font, 17, style.style, add_missing=True)
                
                if name_id_exists(font, 18):
                    set_name(font, 18, full_name, add_missing=False)
                    
                if name_id_exists(font, 21) or name_id_exists(font, 22):
                    set_name(font, 21, new_family, add_missing=False)
                    set_name(font, 22, style.style, add_missing=False)
                    
                if is_variable or name_id_exists(font, 25):
                    set_name(font, 25, sanitize_postscript_part(new_family), add_missing=True)
                    
                update_os2_and_head(font, style)
                update_cff_names(font, new_family, full_name, ps_name, style.weight_name)
                update_fvar_axis_names(font, old_base_family, new_family)
                update_fvar_instance_names(font, new_family)
                update_stat_table(font, old_base_family, new_family)
                
                temp_path = path.with_name(f".{path.name}.tmp")
                font.save(temp_path)
                
            temp_path.replace(path)
            print(f"  Successfully renamed metadata in {path.name}")
        except Exception as e:
            print(f"  Error renaming metadata in {path.name}: {e}")

def port_android_metrics(files_dir: str):
    from fontTools.ttLib import TTFont
    
    font_paths = glob.glob(os.path.join(files_dir, "*.ttf"))
    if not font_paths:
        print("No .ttf files found for metrics adjustment.")
        return
        
    print(f"[Step 4/4] Scaling Android font metrics on {len(font_paths)} file(s)...")
    for font_path in font_paths:
        basename = os.path.basename(font_path)
        try:
            tt = TTFont(font_path)
            upem = tt['head'].unitsPerEm
            
            new_ascent = int(2128 * upem / 2048)
            new_descent = int(-550 * upem / 2048)
            new_linegap = 0
            new_typo_ascender = int(2128 * upem / 2048)
            new_typo_descender = int(-550 * upem / 2048)
            new_typo_linegap = 0
            new_cap_height = int(1456 * upem / 2048)
            new_x_height = int(1082 * upem / 2048)
            new_ymax = int(2163 * upem / 2048)
            new_ymin = int(-555 * upem / 2048)
            
            changed = []
            
            if 'hhea' in tt:
                hhea = tt['hhea']
                if hhea.ascent != new_ascent:
                    hhea.ascent = new_ascent
                    changed.append("ascent")
                if hhea.descent != new_descent:
                    hhea.descent = new_descent
                    changed.append("descent")
                if hhea.lineGap != new_linegap:
                    hhea.lineGap = new_linegap
                    changed.append("lineGap")
                    
            if 'OS/2' in tt:
                os2 = tt['OS/2']
                if os2.sTypoAscender != new_typo_ascender:
                    os2.sTypoAscender = new_typo_ascender
                    changed.append("sTypoAscender")
                if os2.sTypoDescender != new_typo_descender:
                    os2.sTypoDescender = new_typo_descender
                    changed.append("sTypoDescender")
                if os2.sTypoLineGap != new_typo_linegap:
                    os2.sTypoLineGap = new_typo_linegap
                    changed.append("sTypoLineGap")
                if hasattr(os2, 'sCapHeight') and os2.sCapHeight != new_cap_height:
                    os2.sCapHeight = new_cap_height
                    changed.append("sCapHeight")
                if hasattr(os2, 'sxHeight') and os2.sxHeight != new_x_height:
                    os2.sxHeight = new_x_height
                    changed.append("sxHeight")
                    
                old_fs = os2.fsSelection
                new_fs = old_fs & 127
                if old_fs != new_fs:
                    os2.fsSelection = new_fs
                    changed.append("fsSelection")
                    
                if 'fvar' in tt:
                    if os2.usWeightClass != 400:
                        os2.usWeightClass = 400
                        changed.append("usWeightClass=400")
                        
            if 'head' in tt:
                head = tt['head']
                if head.yMax != new_ymax:
                    head.yMax = new_ymax
                    changed.append("yMax")
                if head.yMin != new_ymin:
                    head.yMin = new_ymin
                    changed.append("yMin")
                    
            if changed:
                tt.save(font_path)
                print(f"  Fixed metrics for {basename}: {', '.join(changed)}")
            else:
                print(f"  No metric changes needed for {basename}")
        except Exception as e:
            print(f"  Error fixing metrics for {basename}: {e}")

def main():
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    
    # 1. Dependency checks
    fonttools_available = True
    dehinter_available = True
    try:
        import fontTools
    except ImportError:
        fonttools_available = False
    try:
        import dehinter
    except ImportError:
        dehinter_available = False

    if not fonttools_available or not dehinter_available:
        print("\nMissing required dependencies for font compilation:")
        if not fonttools_available:
            print(" - fonttools (Install with: pip install fonttools)")
        if not dehinter_available:
            print(" - dehinter (Install with: pip install dehinter)")
        print("\nPlease install the missing dependencies and run compile.py again.\n")
        sys.exit(1)
        
    # 2. Run font transformations
    files_dir = os.path.join(SCRIPT_DIR, "Files")
    if not os.path.isdir(files_dir):
        print(f"Error: Files directory not found at '{files_dir}'", file=sys.stderr)
        sys.exit(1)
        
    # Step 1: ren41 renaming
    port_ren41(files_dir)
    
    # Step 2: remove_hinting
    port_remove_hinting(files_dir, SCRIPT_DIR)
    
    # Step 3: rename font metadata
    port_rename_font_metadata(files_dir)
    
    # Step 4: fix android metrics
    port_android_metrics(files_dir)
    
    # 3. Extract name for Magisk Module
    font_files = glob.glob(os.path.join(files_dir, "*.[to]tf")) + glob.glob(os.path.join(files_dir, "*.[TO]TF"))
    detected_name = None
    if font_files:
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
                    
    if detected_name:
        print(f"Extracted font name: {detected_name}")
        custom = input(f"Press Enter to use '{detected_name}', or type a custom name: ").strip()
        name = custom if custom else detected_name
    else:
        name = input("Enter module name: ").strip()
        
    if not name:
        print("Name cannot be empty.", file=sys.stderr)
        sys.exit(1)
        
    # 4. Update module.prop
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
            
            for k, v in updates.items():
                if k not in updated_keys:
                    f.write(f"{k}={v}\n")
    else:
        with open(prop_path, "w", encoding="utf-8", newline="\n") as f:
            for k, v in updates.items():
                f.write(f"{k}={v}\n")
                
    # 5. Create ZIP archive
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
