# Family and Economic Issues

**Status:** Pre-release / contributor review.

LaTeX manuscript repository for research on family formation, financial preparedness, reproductive education, and completed fertility using the National Longitudinal Survey of Youth 1979 (NLSY79).

## Current manuscript

**Working title:** *Financial Preparedness, Reproductive Education, and Completed Fertility: Evidence From the NLSY79*

This repository is currently in pre-release form. The manuscript source is being organized for reproducible drafting, contributor review, citation verification, model-output cleanup, and automated LaTeX compilation. The work should not yet be treated as a final submission package.

## Repository structure

```text
manuscript/
  NLS-79.tex
  references.bib

tables/
  table1_descriptive_statistics.tex
  table2_main_models.tex
  table3_robustness_diagnostics.tex

figures/
  figure files as needed

analysis/
  R or Python scripts used to regenerate tables

.github/workflows/
  build-latex.yml
```

## Automated LaTeX build

The GitHub Actions workflow compiles:

```text
manuscript/NLS-79.tex
```

The compiled PDF is uploaded as a workflow artifact named:

```text
NLS-79-compiled-pdf
```

The workflow runs when manuscript, table, figure, or workflow files are pushed to `main`. It can also be started manually from the GitHub Actions tab.

## Table convention

Model tables should be generated from R as standalone `.tex` fragments and saved under `tables/`. The manuscript should import them with paths such as:

```latex
\input{../tables/table1_descriptive_statistics.tex}
```

## Contributor priorities

Current pre-release priorities are citation verification, LaTeX compilation stability, table reproducibility, model-output alignment, journal-format cleanup, and transparent documentation of analytic limitations.

## Notes

Build artifacts are intentionally ignored. Commit manuscript source, bibliography files, table fragments, figures, and analysis scripts; do not commit LaTeX auxiliary files.
