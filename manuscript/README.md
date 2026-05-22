# Manuscript Directory

Place the main LaTeX manuscript and bibliography here.

## Required files for automated build

```text
manuscript/NLS-79.tex
manuscript/references.bib
```

The GitHub Actions workflow compiles `NLS-79.tex` from this directory.

## Table imports

Generated model tables should live under `../tables/` and be imported from the manuscript with:

```latex
\input{../tables/table1_descriptive_statistics.tex}
\input{../tables/table2_main_models.tex}
\input{../tables/table3_robustness_diagnostics.tex}
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
