#!/usr/bin/env python3
"""Verify manuscript table values against generated CSV audit outputs.

This is a lightweight pre-submission guard. It does not recompute models.
It checks that the manuscript source contains the exact values exported by
analysis-generated CSV tables.
"""

from pathlib import Path
import csv
import sys

ROOT = Path(__file__).resolve().parents[1]
MANUSCRIPT = ROOT / "manuscript" / "NLS-79.tex"
TABLES = ROOT / "tables"


def read_csv(path: Path):
    with path.open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)


def main() -> int:
    text = MANUSCRIPT.read_text(encoding="utf-8")
    errors = []

    desc = read_csv(TABLES / "table1_descriptive_summary.csv")
    for row in desc:
        value = row["Exact value"]
        value_tex = value.replace("%", r"\%")
        if value not in text and value_tex not in text:
            errors.append(
                f"Missing Table 1 value for {row['Measure']}: {value}"
            )

    samples = read_csv(TABLES / "table1b_model_specific_samples.csv")
    for row in samples:
        obs = f"{int(row['Analytic observations']):,}"
        resp = f"{int(row['Unique respondents']):,}"
        if obs not in text:
            errors.append(f"Missing sample observation count for {row['Model']}: {obs}")
        if resp not in text:
            errors.append(f"Missing respondent count for {row['Model']}: {resp}")

    main_results = read_csv(TABLES / "table2_main_results.csv")
    for row in main_results:
        checks = [row["Estimate"], row["SE"], row["Statistic"], row["p"], row["CI_95"]]
        for value in checks:
            if value and value not in text:
                errors.append(
                    f"Missing Table 2 value for {row['Outcome']} / {row['Predictor']}: {value}"
                )

    diagnostics = read_csv(TABLES / "table3_sensitivity_diagnostics.csv")
    for row in diagnostics:
        value = row["Exact value"]
        alt = value.replace("<.001", r"< .001")
        if value not in text and alt not in text:
            errors.append(f"Missing Table 3 diagnostic for {row['Check']}: {value}")

    forbidden = [
        "Paul A. Skeffington",
        "Paul Skeffington",
        "Skeffington",
        "Dartmouth",
        "Statements and Declarations",
        "Author Contributions",
        "Acknowledgements",
    ]
    for term in forbidden:
        if term in text:
            errors.append(f"Blinded manuscript contains forbidden term: {term}")

    if errors:
        for error in errors:
            fail(error)
        return 1

    print("Manuscript table values match generated CSV audit outputs; blinding guard passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
