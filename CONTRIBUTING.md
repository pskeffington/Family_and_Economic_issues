# Contributing

This repository is in pre-release contributor review. Contributions should improve reproducibility, citation accuracy, LaTeX build stability, manuscript clarity, and journal-readiness.

## Contribution priorities

High-priority contributions include:

- verifying citations against DOI records, publisher pages, PubMed, CrossRef, NBER, BLS, NLS Investigator, or official reports;
- checking in-text citation and bibliography parity;
- improving LaTeX compilation stability;
- moving generated model output into clean `.tex` table fragments under `tables/`;
- documenting R or Python scripts needed to reproduce model outputs;
- identifying unsupported causal language;
- improving journal-format alignment for the *Journal of Family and Economic Issues*;
- checking whether reported model estimates match the underlying analytic outputs.

## Repository conventions

Use this structure:

```text
manuscript/
  NLS-79.tex
  references.bib

tables/
  generated .tex table fragments

figures/
  manuscript figures

analysis/
  analysis scripts and reproducibility notes
```

Do not commit LaTeX build artifacts such as `.aux`, `.bbl`, `.blg`, `.log`, `.out`, `.toc`, `.fls`, or `.fdb_latexmk` files.

## Manuscript edits

When editing manuscript text, preserve the LaTeX source structure and avoid changes that break compilation. Keep estimates, sample sizes, and model claims tied to the analytic output. Do not introduce new citations unless they have been verified.

## Citation standard

All references should be verifiable. Preferred verification sources include DOI records, CrossRef, PubMed, publisher pages, official government sites, NBER, BLS, and NLS Investigator documentation. Do not add simulated, unverifiable, or placeholder citations.

## Pull request expectations

A useful pull request should explain:

- what changed;
- why the change was needed;
- whether the manuscript still compiles;
- whether any citation or estimate was verified;
- whether the change affects tables, figures, references, or interpretation.

## Current status

This is not a final publication package. Treat the repository as a pre-release manuscript workspace for review, cleanup, and reproducibility work.
