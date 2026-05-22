#!/usr/bin/env python3
"""Apply narrow JFEI pre-submission cleanup to the blinded LaTeX manuscript.

This script intentionally avoids changing model estimates, citations, or tables.
It only applies source-level packaging fixes identified during review:
- revised title aligned with the reported findings;
- hidden PDF hyperlink boxes;
- JFEI-compliant keyword count and wording;
- removal of any accidental declarations block from the blinded manuscript;
- basic blinding guard for author-identifying terms.
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
    "Statements and Declarations",
    "Declarations",
    "Author Contributions",
    "Acknowledgements",
    "Competing Interests",
    "Ethics Approval",
    "Consent to Participate",
    "Consent for Publication",
    "Funding",
]


def remove_declarations_block(text: str) -> str:
    """Remove declarations material from a blinded manuscript source."""
    text = re.sub(
        r"\n% \*{60}\n% STATEMENTS AND DECLARATIONS.*?(?=\n% \*{60}\n% REFERENCES)",
        "\n",
        text,
        flags=re.S,
    )
    text = re.sub(
        r"\n% \*{60}\n% DECLARATIONS.*?(?=\n% \*{60}\n% REFERENCES)",
        "\n",
        text,
        flags=re.S,
    )
    text = re.sub(
        r"\n\\section\*\{Statements and Declarations\}.*?(?=\n% \*{60}\n% REFERENCES)",
        "\n",
        text,
        flags=re.S,
    )
    text = re.sub(
        r"\n\\section\*\{Declarations\}.*?(?=\n% \*{60}\n% REFERENCES)",
        "\n",
        text,
        flags=re.S,
    )
    return text


def main() -> int:
    text = MANUSCRIPT.read_text(encoding="utf-8")

    text = text.replace(r"\usepackage{hyperref}", r"\usepackage[hidelinks]{hyperref}")
    text = text.replace(OLD_TITLE, NEW_TITLE)

    text = re.sub(
        r"\\noindent\s+\\textbf\{Keywords:\}.*",
        NEW_KEYWORDS,
        text,
        count=1,
    )

    text = remove_declarations_block(text)

    MANUSCRIPT.write_text(text, encoding="utf-8")

    violations = [term for term in FORBIDDEN_BLINDED_TERMS if term in text]
    if violations:
        print("Blinding check failed. Found forbidden terms:", file=sys.stderr)
        for term in violations:
            print(f"- {term}", file=sys.stderr)
        return 1

    required = [NEW_TITLE, r"\usepackage[hidelinks]{hyperref}", NEW_KEYWORDS]
    missing = [item for item in required if item not in text]
    if missing:
        print("Cleanup verification failed. Missing required source text:", file=sys.stderr)
        for item in missing:
            print(f"- {item}", file=sys.stderr)
        return 1

    print("JFEI pre-submission cleanup applied and verified.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
