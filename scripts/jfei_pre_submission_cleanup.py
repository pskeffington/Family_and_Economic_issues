#!/usr/bin/env python3
"""Apply JFEI double-anonymous pre-submission cleanup to the manuscript.

This script avoids changing model estimates, citations, or tables. It applies only
source-level review-package fixes: title and keyword normalization, declaration
block removal, and double-anonymous reviewer-file guards.
"""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "manuscript" / "NLS-79.tex"

OLD_TITLE = "Financial Preparedness, Reproductive Education, and Completed Fertility: Evidence From the NLSY79"
NEW_TITLE = "Financial Preparedness, Birth-Control Education, and Family Formation in the NLSY79"
NEW_KEYWORDS = (
    r"\noindent \textbf{Keywords:} fertility; family economics; financial literacy; "
    r"emergency savings; birth-control education; NLSY79"
)

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
    """Remove declarations or acknowledgement material from manuscript source."""
    section_patterns = [
        r"\n% \*{60}\n% STATEMENTS AND DECLARATIONS.*?(?=\n% \*{60}\n% REFERENCES)",
        r"\n% \*{60}\n% DECLARATIONS.*?(?=\n% \*{60}\n% REFERENCES)",
        r"\n% \*{60}\n% ACKNOWLEDGEMENTS.*?(?=\n% \*{60}\n% REFERENCES)",
        r"\n% \*{60}\n% ACKNOWLEDGMENTS.*?(?=\n% \*{60}\n% REFERENCES)",
        r"\n\\section\*\{Statements and Declarations\}.*?(?=\n% \*{60}\n% REFERENCES)",
        r"\n\\section\*\{Declarations\}.*?(?=\n% \*{60}\n% REFERENCES)",
        r"\n\\section\*\{Acknowledgements\}.*?(?=\n% \*{60}\n% REFERENCES)",
        r"\n\\section\*\{Acknowledgments\}.*?(?=\n% \*{60}\n% REFERENCES)",
    ]
    for pattern in section_patterns:
        text = re.sub(pattern, "\n", text, flags=re.S)
    return text


def main() -> int:
    text = MANUSCRIPT.read_text(encoding="utf-8")

    text = text.replace(r"\usepackage{hyperref}", r"\usepackage[hidelinks]{hyperref}")
    text = text.replace(OLD_TITLE, NEW_TITLE)
    text = re.sub(
        r"\\noindent\s+\\textbf\{Keywords:\}.*",
        lambda _match: NEW_KEYWORDS,
        text,
        count=1,
    )
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

    required = [NEW_TITLE, r"\usepackage[hidelinks]{hyperref}", NEW_KEYWORDS]
    missing = [item for item in required if item not in text]
    if missing:
        print("Cleanup verification failed. Missing required source text:", file=sys.stderr)
        for item in missing:
            print(f"- {item}", file=sys.stderr)
        return 1

    print("JFEI double-anonymous pre-submission cleanup applied and verified.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
