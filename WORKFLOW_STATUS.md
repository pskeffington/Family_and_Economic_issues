# Workflow Output Status

**Status date:** 2026-05-28  
**Repository:** `pskeffington/Family_and_Economic_issues`  
**Default branch:** `main`  
**Workflow:** `.github/workflows/build-latex.yml`  
**Manuscript source:** `manuscript/NLS-79.tex`

## Current status

The repository is configured for JFEI pre-submission manuscript build and editor package review. The active GitHub Actions workflow should produce a narrow editor-facing source package containing only the cleaned manuscript source and the references file.

The workflow should perform the following sequence:

1. Checks out the repository.
2. Installs LaTeX, bibliography, metadata-cleaning, and archive dependencies.
3. Runs `scripts/jfei_pre_submission_cleanup.py` to apply the requested pre-submission cleanup, including removal of declarations material from the manuscript source.
4. Runs `scripts/verify_table_values.py` to confirm manuscript table values match generated CSV audit outputs and to guard the manuscript state.
5. Builds `manuscript/NLS-79.tex` with `latexmk` as a compile check only.
6. Creates `output/JFEI-manuscript-source-package.zip` containing only:
   - `NLS-79.tex`
   - `references.bib`
7. Blocks the package if PDF files, title/declaration files, cover files, submission-support files, or other unexpected members appear in the zip.
8. Uploads the package as the workflow artifact `JFEI-manuscript-source-package`.

## Output artifact

Expected artifact after a successful workflow run:

```text
JFEI-manuscript-source-package
```

Expected archive inside the artifact:

```text
JFEI-manuscript-source-package.zip
```

Expected package contents:

```text
JFEI-manuscript-source-package/NLS-79.tex
JFEI-manuscript-source-package/references.bib
```

The package should contain zero PDF files. It should not contain the compiled manuscript PDF, title page, declarations file, cover letter, author-identifying submission files, raw data, tables, figures, logs, or LaTeX auxiliary files.

## Trigger conditions

The workflow runs on pushes and pull requests to `main` when relevant manuscript, table, figure, submission-support, script, or workflow files change. It can also be started manually through `workflow_dispatch` from the GitHub Actions tab.

## Verification state

Repository documentation and roadmap indicate the build and submission-package preparation steps are complete. Final external confirmation should come from the next push, pull request, or manual `workflow_dispatch` run, followed by inspection of the `JFEI-manuscript-source-package` artifact.

## Security and publication note

The repository is currently public. This manuscript repository is not classified here as a designated operational repository, but the public visibility should still be reviewed before journal submission if any non-shareable data, draft correspondence, identifying files, or sensitive submission materials are added.

## Next action

Trigger the GitHub Actions workflow manually or make a small commit touching an included workflow path. Confirm that the `JFEI-manuscript-source-package` artifact appears and contains exactly `NLS-79.tex` and `references.bib`, with zero PDF files.