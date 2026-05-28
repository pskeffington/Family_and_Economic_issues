# Reproducibility Guide

This repository supports transparent manuscript drafting and audit for the NLSY79 family formation analysis.

## Canonical review paths

Use these UTF-8 text paths as the source of truth when repository-wide code search is incomplete:

```text
README.md
REPRODUCIBILITY.md
ROADMAP.md
CHANGELOG.md
manuscript/NLS-79.tex
manuscript/references.bib
analysis/NLS79_manuscript_analysis_public_git.R
.github/workflows/build-latex.yml
```

Reviewer-shared manuscript evidence should remain reviewable through these text files plus the GitHub Actions package described below. Generated PDFs and ZIP files are build artifacts, not the only copy of manuscript-critical evidence.

## Analysis workflow

Run the analysis from the repository root:

```bash
Rscript analysis/NLS79_manuscript_analysis_public_git.R
```

The script searches for input files in `NLS79 DATA/`, `NLS79_DATA/`, `data/`, `Data/`, the repository root, and parent-directory equivalents. To force a path, set:

```bash
NLS79_DATA_DIR="NLS79 DATA" Rscript analysis/NLS79_manuscript_analysis_public_git.R
```

The script uses the following R packages and will attempt to install any that are missing:

```text
dplyr
tidyr
tibble
purrr
sandwich
lmtest
MASS
survival
knitr
```

## Required inputs

The script expects two public-use NLSY79 CSV extracts:

```text
NLS79-FERTILITY.csv
NLS79_Data_Raw.csv
```

For compatibility with the original local extracts, the script also checks for:

```text
Capstone_data2.csv
default324.csv
```

The following optional file is used when available to preserve the exact respondent fixed-effects estimate already reported in the manuscript:

```text
nls79_emergency_fe_result.csv
```

If the optional fixed-effects result is absent, the script estimates the emergency-savings model directly from the public CSVs using `fixest` when installed, or a de-meaned linear probability fallback otherwise.

## Generated outputs

The script writes output to `tables/` by default. Override this location with:

```bash
NLS79_OUTPUT_DIR="tables" Rscript analysis/NLS79_manuscript_analysis_public_git.R
```

Current generated CSV audit outputs committed to the repository are:

```text
table1_descriptive_summary.csv
table1b_model_specific_samples.csv
table2_main_results.csv
table2b_effect_sizes.csv
table3_sensitivity_diagnostics.csv
variable_crosswalk.csv
```

The script also writes respondent-level and panel analytic audit files locally. These are intentionally not committed because they are derived respondent-level data:

```text
analytic_marital_panel.csv
analytic_person_file.csv
```

Generated LaTeX fragments committed for audit and future manuscript modularization are:

```text
table1_descriptive_summary.tex
table1b_model_specific_samples.tex
table2_main_results.tex
table3_sensitivity_diagnostics.tex
variable_crosswalk.tex
```

The manuscript currently embeds journal tables directly, so these generated fragments should be treated as audit outputs unless the manuscript is later converted to an `\input{}` workflow.

## Manuscript tables

The current manuscript keeps tables inline in `manuscript/NLS-79.tex` to preserve compilation stability. The generated table files are audit artifacts and may be used later to convert the manuscript to an `\input{}`-based table workflow.

## Build workflow

The manuscript PDF is built by GitHub Actions using:

```bash
latexmk -pdf -interaction=nonstopmode -halt-on-error NLS-79.tex
```

The workflow runs from the `manuscript/` directory and uses `manuscript/references.bib` for bibliography compilation.

The workflow also prepares an editor-safe blinded package named `JFEI-blinded-review-package`. The uploaded artifact is:

```text
output/JFEI-blinded-review-package.zip
```

The package is assembled from only these files:

```text
JFEI-blinded-review-package/NLS-79.pdf
JFEI-blinded-review-package/NLS-79.tex
JFEI-blinded-review-package/references.bib
```

Before upload, the workflow strips common PDF metadata with `exiftool`, rejects package contents containing author/declaration identifiers, rejects forbidden file names such as title, declaration, author, cover, or submission files, verifies the ZIP is non-empty, and confirms the expected three package members are present.

## Data-use note

The analysis uses de-identified public-use NLSY79 data. Users should obtain public-use extracts through the U.S. Bureau of Labor Statistics / NLS Investigator system and comply with applicable redistribution rules.

Do not commit raw NLSY79 extracts, raw data loaders, or respondent-level analytic files. The repository is designed to share manuscript source, code, metadata, and aggregate audit outputs while keeping raw and derived respondent-level data local.
