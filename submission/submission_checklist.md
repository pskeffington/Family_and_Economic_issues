# Journal Submission Checklist

Target journal: *Journal of Family and Economic Issues*

## Files to upload

- `NLS-79.pdf` — blinded manuscript PDF generated from GitHub Actions artifact `NLS-79-compiled-pdf`.
- `manuscript/NLS-79.tex` — editable blinded LaTeX manuscript source.
- `manuscript/references.bib` — manuscript bibliography.
- `submission/title_page.tex` — unblinded title page with author, affiliations, email, ORCID, and declarations.
- `submission/cover_letter.md` — cover letter text for the submission portal.
- `submission/author_disclosures.md` — disclosure statements for portal fields.
- `REPRODUCIBILITY.md` — optional reproducibility note if requested.

## Files not to upload

- Raw NLSY79 extract files.
- Local `.dat`, `.csv`, `.sdf`, `.sas`, `.sps`, `.dct`, `.cdb`, or `.NLSY79` data files.
- LaTeX build artifacts such as `.aux`, `.bbl`, `.blg`, `.fdb_latexmk`, `.fls`, `.log`, or `.out`.
- Local helper scripts or patch files used during cleanup.
- Unblinded title-page material inside the blinded manuscript.

## Portal fields

Article type: Original Paper

Title: Financial Preparedness, Reproductive Education, and Completed Fertility: Evidence From the NLSY79

Keywords: fertility; family economics; financial literacy; emergency savings; reproductive education; NLSY79

Corresponding author: Paul A. Skeffington

Email: paul@skeffington.us

ORCID: 0009-0009-7786-5903

Affiliations:
1. Southern New Hampshire University
2. Dartmouth College

Affiliation note: This work was initiated while the author was affiliated with Southern New Hampshire University and completed while the author was affiliated with Dartmouth College.

## Declarations

Funding: The author received no financial support for the research, authorship, or publication of this article.

Competing interests: The author declares no competing interests.

Ethics approval: This study used de-identified public-use data from the National Longitudinal Survey of Youth 1979. No human subjects research involving identifiable private information was conducted by the author for this manuscript.

Consent to participate: Not applicable. The analysis used secondary de-identified public-use survey data.

Consent for publication: Not applicable. No individual-level identifiable information is reported.

Data availability: The NLSY79 public-use data are available from the U.S. Bureau of Labor Statistics and the NLS Investigator platform. The analytic code and manuscript materials are available in the project repository, subject to public-use data redistribution rules and repository documentation.

Author contributions: Paul A. Skeffington was responsible for conceptualization, data construction, analysis, interpretation, and manuscript preparation.

## Final checks before submission

- Confirm the GitHub Actions artifact PDF opens correctly.
- Confirm the blinded manuscript contains no author name, email, ORCID, acknowledgments, or institutional self-identification.
- Confirm tables in the manuscript match the audit files in `tables/`.
- Confirm `references.bib` metadata and title capitalization are stable after the final build.
- Confirm no raw NLSY79 files are committed or uploaded.
- Confirm the repository working tree is clean after final push.
