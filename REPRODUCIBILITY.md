# Reproducibility Guide

This repository supports transparent manuscript drafting and audit for the NLSY79 family formation analysis.

## Analysis workflow

Run the analysis from the repository root:

```bash
Rscript analysis/NLS79_manuscript_analysis_public_git.R
```

The script searches for input files in `NLS79 DATA/`, `NLS79_DATA/`, `data/`, `Data/`, the repository root, and parent-directory equivalents. To force a path, set:

```bash
NLS79_DATA_DIR="NLS79 DATA" Rscript analysis/NLS79_manuscript_analysis_public_git.R
```

## Required inputs

The script expects two public-use NLSY79 CSV extracts:

```text
NLS79-FERTILITY.csv
NLS79_Data_Raw.csv
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

Primary audit outputs:

```text
table1_descriptive_summary.csv
table1b_model_specific_samples.csv
table2_main_results.csv
table2b_effect_sizes.csv
table3_sensitivity_diagnostics.csv
variable_crosswalk.csv
analytic_marital_panel.csv
analytic_person_file.csv
```

LaTeX fragments are also written for audit and future manuscript modularization:

```text
table1_descriptive_summary.tex
table1b_model_specific_samples.tex
table2_main_results.tex
table3_sensitivity_diagnostics.tex
variable_crosswalk.tex
```

## Manuscript tables

The current manuscript keeps tables inline in `manuscript/NLS-79.tex` to preserve compilation stability. The generated table files are audit artifacts and may be used later to convert the manuscript to an `\input{}`-based table workflow.

## Build workflow

The manuscript PDF is built by GitHub Actions using:

```bash
latexmk -pdf -interaction=nonstopmode -halt-on-error NLS-79.tex
```

The workflow runs from the `manuscript/` directory and uses `manuscript/references.bib` for bibliography compilation.

## Data-use note

The analysis uses de-identified public-use NLSY79 data. Users should obtain public-use extracts through the U.S. Bureau of Labor Statistics / NLS Investigator system and comply with applicable redistribution rules.
