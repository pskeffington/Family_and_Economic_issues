#!/usr/bin/env python3
"""Build a Springer Nature template-aligned blinded manuscript source.

This script preserves the manuscript text while converting the wrapper to the
Springer Nature `sn-jnl` article-template structure. It intentionally writes a
separate source file so the narrow technical-check return manuscript remains
unchanged.
"""

from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "manuscript" / "NLS-79.tex"
TARGET = ROOT / "manuscript" / "NLS-79-springer-template.tex"

FORBIDDEN_DECLARATION_TERMS = [
    "Statements and Declarations",
    "Declarations",
    "Author Contributions",
    "Acknowledgements",
    "Competing Interests",
    "Ethics Approval",
    "Consent to Participate",
    "Consent for Publication",
    "Funding",
    "Paul A. Skeffington",
    "Paul Skeffington",
    "Skeffington",
    "Dartmouth",
]


def require_match(pattern: str, text: str, label: str, flags: int = 0) -> re.Match[str]:
    match = re.search(pattern, text, flags)
    if not match:
        raise ValueError(f"Could not find {label} in manuscript source")
    return match


def clean_keywords(raw: str) -> str:
    raw = re.sub(r"\\noindent\s*\\textbf\{Keywords:\}\s*", "", raw).strip()
    raw = raw.rstrip(".")
    return raw.replace(";", ",")


def extract_body(text: str) -> str:
    intro = require_match(r"\\section\{Introduction\}", text, "Introduction section")
    refs = require_match(r"% \*{60}\n% REFERENCES", text, "references divider")
    body = text[intro.start(): refs.start()].rstrip()
    return body


def main() -> int:
    text = SOURCE.read_text(encoding="utf-8")

    title = require_match(r"\\title\{(.+?)\}", text, "title", re.S).group(1).strip()
    abstract = require_match(
        r"\\begin\{abstract\}\s*(.*?)\s*\\end\{abstract\}",
        text,
        "abstract",
        re.S,
    ).group(1).strip()
    keywords_line = require_match(
        r"\\noindent\s*\\textbf\{Keywords:\}.*",
        text,
        "keywords",
    ).group(0)
    keywords = clean_keywords(keywords_line)
    body = extract_body(text)

    output = rf"""% ============================================================
% SPRINGER NATURE TEMPLATE-ALIGNED BLINDED MANUSCRIPT
% Generated from manuscript/NLS-79.tex by scripts/build_springer_template_manuscript.py
% ============================================================

\documentclass[pdflatex,sn-basic]{{sn-jnl}}

\usepackage{{amsmath,amssymb}}
\usepackage{{booktabs}}
\usepackage{{threeparttable}}
\usepackage{{graphicx}}
\usepackage{{adjustbox}}
\usepackage{{array}}
\usepackage{{tabularx}}
\usepackage[hidelinks]{{hyperref}}

\newcolumntype{{Y}}{{>{{\raggedright\arraybackslash}}X}}
\setlength{{\tabcolsep}}{{4pt}}
\renewcommand{{\arraystretch}}{{1.15}}

\jyear{{2026}}

\begin{{document}}

\title[{title}]{{{title}}}

\author*[1]{{\fnm{{Anonymous}} \sur{{Author}}}}
\affil*[1]{{\orgname{{Blinded for review}}}}

\abstract{{{abstract}}}

\keywords{{{keywords}}}

\maketitle

{body}

\bibliography{{references}}

\end{{document}}
"""

    violations = [term for term in FORBIDDEN_DECLARATION_TERMS if term in output]
    # Anonymous Author and Blinded for review are intentionally allowed.
    violations = [term for term in violations if term not in {"Author Contributions"}]
    if violations:
        print("Springer-aligned source contains forbidden declaration or identifying terms:", file=sys.stderr)
        for term in violations:
            print(f"- {term}", file=sys.stderr)
        return 1

    TARGET.write_text(output, encoding="utf-8")
    print(f"Wrote Springer Nature template-aligned source: {TARGET}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
