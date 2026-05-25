# Springer Nature Official Template Anchor

This directory is reserved for the official Springer Nature LaTeX journal article template package.

## Official source

Springer Nature LaTeX author support:

https://www.springernature.com/gp/authors/campaigns/latex-author-support

Official template package download used by the fetch script:

https://cms-resources.apps.public.k8s.springernature.io/springer-cms/rest/v1/content/18782940/data/v12

## Fetch command

From the repository root, run:

```bash
bash scripts/fetch_springer_template.sh
```

The script downloads the official template ZIP, extracts it under:

```text
templates/springer-nature-official/template-package/
```

## Journal-specific use

For the Journal of Family and Economic Issues technical-check return, the current action is intentionally narrow:

- keep the blinded manuscript free of author declarations and funding text;
- keep the funding statement on a separate submission page;
- do not reformat or restructure the manuscript beyond the editor-requested technical correction unless the editor requests it.

The Springer template is retained here as the official formatting baseline for future conversion or deeper production cleanup, not as a reason to alter the technical-check return package.
