#!/usr/bin/env python3
"""Import ui_strings.csv → app_id.arb + app_id_SBS.arb (CSV wins).

Kontrak: docs/mobile/MOBILE-I18N.md Section 13.

- Cell non-kosong yang beda dari ARB → nilai CSV dipakai.
- Cell kosong → ARB lama tidak diubah (anti-wipe).
- Key CSV wajib sudah ada di app_id.arb.
- Placeholder ICU di sambas (jika diisi) wajib sama dengan id final baris itu.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from pathlib import Path

SHEET_DIR = Path(__file__).resolve().parent
MOBILE_ROOT = SHEET_DIR.parent.parent
DEFAULT_CSV = SHEET_DIR / "ui_strings.csv"
DEFAULT_ID_ARB = MOBILE_ROOT / "lib" / "l10n" / "app_id.arb"
DEFAULT_SBS_ARB = MOBILE_ROOT / "lib" / "l10n" / "app_id_SBS.arb"
DEFAULT_CATATAN = SHEET_DIR / "catatan.csv"

HEADER = ("key", "indonesia", "sambas", "catatan")
PLACEHOLDER_RE = re.compile(r"\{([^{}]+)\}")


def load_arb(path: Path) -> dict:
    with path.open(encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise SystemExit(f"ARB bukan object JSON: {path}")
    return data


def write_arb(path: Path, data: dict) -> None:
    text = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    path.write_text(text, encoding="utf-8")


def message_keys(arb: dict) -> set[str]:
    return {k for k in arb if not k.startswith("@")}


def placeholders(text: str) -> list[str]:
    return PLACEHOLDER_RE.findall(text)


def load_csv_rows(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        if reader.fieldnames is None:
            raise SystemExit(f"CSV kosong / tanpa header: {path}")
        fields = tuple(h.strip() for h in reader.fieldnames)
        if fields != HEADER:
            raise SystemExit(
                f"Header CSV harus persis {list(HEADER)}, dapat {list(fields)}"
            )
        rows: list[dict[str, str]] = []
        for i, raw in enumerate(reader, start=2):
            key = (raw.get("key") or "").strip()
            if not key:
                raise SystemExit(f"Baris {i}: key kosong")
            rows.append(
                {
                    "key": key,
                    "indonesia": (raw.get("indonesia") or "").strip(),
                    "sambas": (raw.get("sambas") or "").strip(),
                    "catatan": (raw.get("catatan") or "").strip(),
                }
            )
        return rows


def load_catatan(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    with path.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        out: dict[str, str] = {}
        for raw in reader:
            key = (raw.get("key") or "").strip()
            if not key:
                continue
            out[key] = (raw.get("catatan") or "").strip()
        return out


def write_catatan(path: Path, data: dict[str, str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["key", "catatan"])
        writer.writeheader()
        for key in sorted(data):
            writer.writerow({"key": key, "catatan": data[key]})


def import_sheet(
    *,
    csv_path: Path,
    id_arb_path: Path,
    sbs_arb_path: Path,
    catatan_path: Path,
    dry_run: bool,
) -> int:
    rows = load_csv_rows(csv_path)
    id_arb = load_arb(id_arb_path)
    sbs_arb = load_arb(sbs_arb_path)
    id_keys = message_keys(id_arb)
    sbs_keys = message_keys(sbs_arb)

    missing = sorted({r["key"] for r in rows} - id_keys)
    if missing:
        preview = ", ".join(missing[:10])
        more = f" (+{len(missing) - 10})" if len(missing) > 10 else ""
        raise SystemExit(f"Key CSV tidak ada di app_id.arb: {preview}{more}")

    missing_sbs = sorted({r["key"] for r in rows} - sbs_keys)
    if missing_sbs:
        preview = ", ".join(missing_sbs[:10])
        more = f" (+{len(missing_sbs) - 10})" if len(missing_sbs) > 10 else ""
        raise SystemExit(f"Key CSV tidak ada di app_id_SBS.arb: {preview}{more}")

    id_changed = 0
    sbs_changed = 0
    catatan_changed = 0
    placeholder_errors: list[str] = []
    catatan = load_catatan(catatan_path)

    for row in rows:
        key = row["key"]
        csv_id = row["indonesia"]
        csv_sbs = row["sambas"]
        csv_note = row["catatan"]

        final_id = csv_id if csv_id else str(id_arb[key])

        if csv_id and csv_id != id_arb[key]:
            id_arb[key] = csv_id
            id_changed += 1

        if csv_sbs:
            if placeholders(csv_sbs) != placeholders(final_id):
                placeholder_errors.append(
                    f"{key}: placeholder sambas {placeholders(csv_sbs)!r} "
                    f"!= id {placeholders(final_id)!r}"
                )
            elif csv_sbs != sbs_arb[key]:
                sbs_arb[key] = csv_sbs
                sbs_changed += 1

        if csv_note and catatan.get(key) != csv_note:
            catatan[key] = csv_note
            catatan_changed += 1

    if placeholder_errors:
        shown = "\n".join(placeholder_errors[:20])
        more = (
            f"\n... dan {len(placeholder_errors) - 20} error lain"
            if len(placeholder_errors) > 20
            else ""
        )
        raise SystemExit(f"Placeholder ICU tidak cocok:\n{shown}{more}")

    print(
        f"rows={len(rows)} id_changed={id_changed} "
        f"sbs_changed={sbs_changed} catatan_changed={catatan_changed} "
        f"dry_run={dry_run}"
    )

    if dry_run:
        return 0

    if id_changed:
        write_arb(id_arb_path, id_arb)
    if sbs_changed:
        write_arb(sbs_arb_path, sbs_arb)
    if catatan_changed or (catatan and not catatan_path.exists()):
        write_catatan(catatan_path, catatan)

    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Import ui_strings.csv ke ARB (CSV wins jika non-kosong & beda)."
    )
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV)
    parser.add_argument("--id-arb", type=Path, default=DEFAULT_ID_ARB)
    parser.add_argument("--sbs-arb", type=Path, default=DEFAULT_SBS_ARB)
    parser.add_argument("--catatan", type=Path, default=DEFAULT_CATATAN)
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Validasi + hitung perubahan, tanpa menulis file",
    )
    args = parser.parse_args(argv)
    return import_sheet(
        csv_path=args.csv,
        id_arb_path=args.id_arb,
        sbs_arb_path=args.sbs_arb,
        catatan_path=args.catatan,
        dry_run=args.dry_run,
    )


if __name__ == "__main__":
    sys.exit(main())
