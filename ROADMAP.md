# Pre-release Roadmap

This roadmap defines the work needed before the repository should be treated as a stable manuscript package.

## Phase 0 — Repository stabilization

- [x] Move manuscript source into `manuscript/`.
- [x] Move bibliography into `manuscript/`.
- [x] Remove LaTeX build artifacts from the live repository tree.
- [x] Add `.gitignore` for LaTeX and R artifacts.
- [x] Add GitHub Actions workflow for automated PDF compilation.
- [x] Add contributor-facing documentation.

## Phase 1 — Build verification

- [x] Confirm `manuscript/NLS-79.tex` compiles locally and under the automated workflow configuration.
- [x] Resolve missing package, bibliography, path, and table errors found during repository cleanup.
- [x] Confirm generated PDF artifact appears under GitHub Actions after the next push.
- [x] Confirm no LaTeX auxiliary files are present in the live repository tree.

## Phase 2 — Citation verification

- [x] Verify every `.bib` entry against DOI, CrossRef, PubMed, publisher pages, NBER, BLS, NLS Investigator, or official report pages.
- [x] Check in-text citation and bibliography parity.
- [x] Normalize capitalization in article and report titles.
- [x] Remove or flag any unverified citation.

## Phase 3 — Analysis reproducibility

- [x] Add analysis scripts under `analysis/`.
- [x] Document input data requirements and public-use restrictions.
- [x] Regenerate descriptive statistics from code.
- [x] Regenerate model tables from code.
- [x] Export `.tex` table fragments into `tables/` for audit and future modularization.

## Phase 4 — Manuscript review

- [x] Confirm model estimates in text match table output.
- [x] Remove unsupported causal language.
- [x] Tighten limitations section.
- [x] Align manuscript language with *Journal of Family and Economic Issues* expectations.
- [x] Confirm declarations, data availability, funding, and competing-interest statements.

## Phase 5 — Submission package

- [x] Produce clean blinded manuscript PDF.
- [x] Prepare source `.tex` and `.bib` materials.
- [x] Produce upload archive only if required by the journal portal.
- [x] Prepare cover letter.
- [x] Prepare replication/readme materials where shareable.
