#!/usr/bin/env python3
"""Export app_id.arb + app_id_SBS.arb → ui_strings.csv.

Kontrak: docs/mobile/MOBILE-I18N.md Section 13.
Kolom catatan diambil dari catatan.csv bila ada (merge by key).
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path

SHEET_DIR = Path(__file__).resolve().parent
MOBILE_ROOT = SHEET_DIR.parent.parent
DEFAULT_CSV = SHEET_DIR / "ui_strings.csv"
DEFAULT_ID_ARB = MOBILE_ROOT / "lib" / "l10n" / "app_id.arb"
DEFAULT_SBS_ARB = MOBILE_ROOT / "lib" / "l10n" / "app_id_SBS.arb"
DEFAULT_CATATAN = SHEET_DIR / "catatan.csv"

HEADER = ("key", "indonesia", "sambas", "catatan")


def load_arb(path: Path) -> dict:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def load_catatan(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    with path.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        out: dict[str, str] = {}
        for raw in reader:
            key = (raw.get("key") or "").strip()
            if key:
                out[key] = (raw.get("catatan") or "").strip()
        return out


def export_sheet(
    *,
    csv_path: Path,
    id_arb_path: Path,
    sbs_arb_path: Path,
    catatan_path: Path,
) -> int:
    id_arb = load_arb(id_arb_path)
    sbs_arb = load_arb(sbs_arb_path)
    catatan = load_catatan(catatan_path)

    keys = sorted(k for k in id_arb if not k.startswith("@"))
    missing_sbs = [k for k in keys if k not in sbs_arb]
    if missing_sbs:
        preview = ", ".join(missing_sbs[:10])
        raise SystemExit(f"Key hilang di app_id_SBS.arb: {preview}")

    with csv_path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(HEADER), lineterminator="\n")
        writer.writeheader()
        for key in keys:
            writer.writerow(
                {
                    "key": key,
                    "indonesia": id_arb[key],
                    "sambas": sbs_arb.get(key, ""),
                    "catatan": catatan.get(key, ""),
                }
            )

    print(f"wrote {len(keys)} rows → {csv_path}")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Export ARB → ui_strings.csv")
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV)
    parser.add_argument("--id-arb", type=Path, default=DEFAULT_ID_ARB)
    parser.add_argument("--sbs-arb", type=Path, default=DEFAULT_SBS_ARB)
    parser.add_argument("--catatan", type=Path, default=DEFAULT_CATATAN)
    args = parser.parse_args(argv)
    return export_sheet(
        csv_path=args.csv,
        id_arb_path=args.id_arb,
        sbs_arb_path=args.sbs_arb,
        catatan_path=args.catatan,
    )


if __name__ == "__main__":
    sys.exit(main())
