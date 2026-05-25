#!/usr/bin/env python3
"""Build a journal-ready blinded review package for JFEI submission."""
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "manuscript"
OUTPUT = ROOT / "output"
PACKAGE = OUTPUT / "jfei_blinded_review_package"
ZIP_PATH = OUTPUT / "JFEI_blinded_review_package.zip"

FILES = {
    MANUSCRIPT / "NLS-79.pdf": PACKAGE / "NLS-79_blinded_manuscript.pdf",
    MANUSCRIPT / "NLS-79.tex": PACKAGE / "NLS-79_blinded_manuscript.tex",
    MANUSCRIPT / "references.bib": PACKAGE / "references.bib",
}

FORBIDDEN = [
    "Paul A. Skeffington",
    "Paul Skeffington",
    "Skeffington",
    "Dartmouth",
    "Author Contributions",
    "Acknowledgements",
    "Competing Interests",
    "Ethics Approval",
    "Consent to Participate",
    "Consent for Publication",
    "Data Availability",
    "Code Availability",
    "Declarations",
    "Statements and Declarations",
]


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)


def strip_pdf_metadata(path: Path) -> None:
    exiftool = shutil.which("exiftool")
    if not exiftool:
        print("WARNING: exiftool not available; PDF metadata stripping skipped.")
        return
    subprocess.run([exiftool, "-overwrite_original", "-all=", str(path)], check=True)


def audit_text_file(path: Path, errors: list[str]) -> None:
    text = path.read_text(encoding="utf-8", errors="ignore")
    for term in FORBIDDEN:
        if term in text:
            errors.append(f"{path.relative_to(ROOT)} contains forbidden term: {term}")
    if "@" in text:
        errors.append(f"{path.relative_to(ROOT)} contains an at-sign; inspect for email addresses")


def main() -> int:
    if OUTPUT.exists():
        shutil.rmtree(OUTPUT)
    PACKAGE.mkdir(parents=True, exist_ok=True)

    errors: list[str] = []
    for src, dest in FILES.items():
        if not src.exists():
            errors.append(f"Missing required source file: {src.relative_to(ROOT)}")
            continue
        shutil.copy2(src, dest)

    if errors:
        for error in errors:
            fail(error)
        return 1

    strip_pdf_metadata(PACKAGE / "NLS-79_blinded_manuscript.pdf")

    for path in PACKAGE.iterdir():
        if not path.is_file() or path.stat().st_size == 0:
            errors.append(f"Missing or empty package file: {path.relative_to(ROOT)}")
        if path.suffix.lower() in {".tex", ".bib", ".txt", ".md", ".csv"}:
            audit_text_file(path, errors)

    if errors:
        for error in errors:
            fail(error)
        return 1

    shutil.make_archive(str(ZIP_PATH.with_suffix("")), "zip", PACKAGE)
    if not ZIP_PATH.exists() or ZIP_PATH.stat().st_size == 0:
        fail("ZIP package was not created")
        return 1

    print(f"Created {ZIP_PATH.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
