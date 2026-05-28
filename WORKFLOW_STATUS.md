# Workflow Output Status

**Status date:** 2026-05-28  
**Repository:** `pskeffington/Family_and_Economic_issues`  
**Default branch:** `main`  
**Workflow:** `.github/workflows/build-latex.yml`  
**Manuscript source:** `manuscript/NLS-79.tex`

## Current status

The repository is configured for JFEI pre-submission manuscript build and blinded-package review. The active GitHub Actions workflow is designed to produce an editor-safe blinded review package, not merely a raw compiled PDF.

The workflow currently performs the following sequence:

1. Checks out the repository.
2. Installs LaTeX, bibliography, metadata-cleaning, and archive dependencies.
3. Runs `scripts/jfei_pre_submission_cleanup.py` to apply narrow JFEI pre-submission source cleanup.
4. Runs `scripts/verify_table_values.py` to confirm manuscript table values match generated CSV audit outputs and to guard the blinded manuscript state.
5. Builds `manuscript/NLS-79.tex` with `latexmk`.
6. Creates `output/JFEI-blinded-review-package.zip` containing:
   - `NLS-79.pdf`
   - `NLS-79.tex`
   - `references.bib`
7. Strips common PDF metadata from the packaged PDF.
8. Blocks the package if author-identifying or declarations material appears in the blinded review package.
9. Uploads the package as the workflow artifact `JFEI-blinded-review-package`.

## Output artifact

Expected artifact after a successful workflow run:

```text
JFEI-blinded-review-package
```

Expected archive inside the artifact:

```text
JFEI-blinded-review-package.zip
```

Expected package contents:

```text
JFEI-blinded-review-package/NLS-79.pdf
JFEI-blinded-review-package/NLS-79.tex
JFEI-blinded-review-package/references.bib
```

## Trigger conditions

The workflow runs on pushes and pull requests to `main` when relevant manuscript, table, figure, submission-support, script, or workflow files change. It can also be started manually through `workflow_dispatch` from the GitHub Actions tab.

## Verification state

Repository documentation and roadmap indicate the build and submission-package preparation steps are complete. A direct workflow-run lookup for the most recent matched JFEI cleanup commit did not return an associated pull-request workflow run through the connector. Therefore, the workflow should be treated as configured and ready, with final external confirmation pending the next push, pull request, or manual `workflow_dispatch` run.

## Security and publication note

The repository is currently public. This manuscript repository is not classified here as a designated operational repository, but the public visibility should still be reviewed before journal submission if any non-shareable data, draft correspondence, identifying files, or sensitive submission materials are added.

## Next action

Trigger the GitHub Actions workflow manually or make a small documentation/script commit that touches an included path. Confirm that the `JFEI-blinded-review-package` artifact appears and contains only the blinded manuscript PDF, blinded source, and bibliography.