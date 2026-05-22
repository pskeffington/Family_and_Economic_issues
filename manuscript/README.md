# Manuscript Directory

Place the main LaTeX manuscript and bibliography here.

## Required files for automated build

```text
manuscript/NLS-79.tex
manuscript/references.bib
```

The GitHub Actions workflow compiles `NLS-79.tex` from this directory.

## Tables

The current manuscript keeps journal tables inline in `NLS-79.tex` for compilation stability. Generated CSV and LaTeX table fragments live under `../tables/` as audit outputs and can be used for future modularization.

Current generated table fragments are:

```latex
\input{../tables/table1_descriptive_summary.tex}
\input{../tables/table1b_model_specific_samples.tex}
\input{../tables/table2_main_results.tex}
\input{../tables/table3_sensitivity_diagnostics.tex}
\input{../tables/variable_crosswalk.tex}
```

## Bibliography

For `natbib`, keep `references.bib` in this directory and use:

```latex
\bibliographystyle{apalike}
\bibliography{references}
```

For `biblatex`, use:

```latex
\addbibresource{references.bib}
\printbibliography
```
