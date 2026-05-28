#!/usr/bin/env python3
"""Apply double-anonymous compliance cleanup to the manuscript source.

This script does not change scholarly content, model estimates, citations, tables,
title wording, keywords, or interpretation. It only removes author/declaration
material that should not appear in reviewer-facing files and checks that the
reviewer manuscript remains anonymous.
"""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "manuscript" / "NLS-79.tex"

FORBIDDEN_BLINDED_TERMS = [
    "Paul A. Skeffington",
    "Paul Skeffington",
    "Skeffington",
    "Dartmouth College",
    "Dartmouth",
    "paulskeffington",
    "@pskeffington",
    "Statements and Declarations",
    "Statements \\& Declarations",
    "Declarations",
    "Author Contributions",
    "Author contribution",
    "Acknowledgements",
    "Acknowledgments",
    "Competing Interests",
    "Competing interests",
    "Conflict of Interest",
    "Conflict of interest",
    "Ethics Approval",
    "Consent to Participate",
    "Consent for Publication",
    "Funding",
]

FORBIDDEN_PATTERNS = [
    (r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}", "email address"),
    (r"\bwe\s+(previously|have previously|showed|demonstrated|reported)\b", "first-person self-citation phrasing"),
    (r"\bour\s+(previous|prior|earlier)\s+(work|study|article|paper|research)\b", "first-person self-citation phrasing"),
    (r"\bthe authors\s+(previously|have previously|showed|demonstrated|reported)\b", "author-identifying self-reference"),
]


def remove_declarations_block(text: str) -> str:
    """Remove declaration, funding, and acknowledgement material only."""
    anchor = r"(?=\n% \*{60}\n% REFERENCES|\n\\bibliographystyle|\n\\begin\{thebibliography\}|\n\\end\{document\})"
    starts = [
        r"\n% \*{60}\n% STATEMENTS AND DECLARATIONS",
        r"\n% \*{60}\n% DECLARATIONS",
        r"\n% \*{60}\n% ACKNOWLEDGEMENTS",
        r"\n% \*{60}\n% ACKNOWLEDGMENTS",
        r"\n\\section\*\{Statements and Declarations\}",
        r"\n\\section\*\{Declarations\}",
        r"\n\\section\*\{Acknowledgements\}",
        r"\n\\section\*\{Acknowledgments\}",
        r"\n\\section\*\{Funding\}",
    ]
    for start in starts:
        text = re.sub(start + r".*?" + anchor, "\n", text, flags=re.S)
    return text


def main() -> int:
    text = MANUSCRIPT.read_text(encoding="utf-8")
    text = remove_declarations_block(text)
    MANUSCRIPT.write_text(text, encoding="utf-8")

    violations = [term for term in FORBIDDEN_BLINDED_TERMS if term in text]
    pattern_violations = [
        label for pattern, label in FORBIDDEN_PATTERNS if re.search(pattern, text, flags=re.I)
    ]
    if violations or pattern_violations:
        print("Double-anonymous manuscript check failed.", file=sys.stderr)
        for term in violations:
            print(f"- Forbidden term: {term}", file=sys.stderr)
        for label in sorted(set(pattern_violations)):
            print(f"- Forbidden pattern: {label}", file=sys.stderr)
        return 1

    print("Double-anonymous compliance cleanup applied; no scholarly edits made.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
