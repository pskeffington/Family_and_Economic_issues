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

- [ ] Confirm `manuscript/NLS-79.tex` compiles under GitHub Actions.
- [ ] Resolve any missing package, bibliography, path, or table errors.
- [ ] Confirm generated PDF artifact appears under GitHub Actions.
- [ ] Confirm no LaTeX auxiliary files are reintroduced.

## Phase 2 — Citation verification

- [ ] Verify every `.bib` entry against DOI, CrossRef, PubMed, publisher pages, NBER, BLS, NLS Investigator, or official report pages.
- [ ] Check in-text citation and bibliography parity.
- [ ] Normalize capitalization in article and report titles.
- [ ] Remove or flag any unverified citation.

## Phase 3 — Analysis reproducibility

- [ ] Add analysis scripts under `analysis/`.
- [ ] Document input data requirements and public-use restrictions.
- [ ] Regenerate descriptive statistics from code.
- [ ] Regenerate model tables from code.
- [ ] Export publication-ready `.tex` table fragments into `tables/`.

## Phase 4 — Manuscript review

- [ ] Confirm model estimates in text match table output.
- [ ] Remove unsupported causal language.
- [ ] Tighten limitations section.
- [ ] Align manuscript language with *Journal of Family and Economic Issues* expectations.
- [ ] Confirm declarations, data availability, funding, and competing-interest statements.

## Phase 5 — Submission package

- [ ] Produce clean blinded manuscript PDF.
- [ ] Produce source `.tex` and `.bib` archive.
- [ ] Produce tables and figures as separate files if required.
- [ ] Prepare cover letter.
- [ ] Prepare replication/readme materials where shareable.
