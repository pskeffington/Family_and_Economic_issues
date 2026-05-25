#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_URL="https://cms-resources.apps.public.k8s.springernature.io/springer-cms/rest/v1/content/18782940/data/v12"
TEMPLATE_DIR="templates/springer-nature-official"
ZIP_PATH="${TEMPLATE_DIR}/springer-nature-journal-article-template-december-2024.zip"
EXTRACT_DIR="${TEMPLATE_DIR}/template-package"

mkdir -p "${TEMPLATE_DIR}"

curl -L --fail --retry 3 --retry-delay 5 \
  -A "Mozilla/5.0" \
  -o "${ZIP_PATH}" \
  "${TEMPLATE_URL}"

test -s "${ZIP_PATH}"
rm -rf "${EXTRACT_DIR}"
mkdir -p "${EXTRACT_DIR}"
unzip -q "${ZIP_PATH}" -d "${EXTRACT_DIR}"

find "${EXTRACT_DIR}" -maxdepth 3 -type f | sort

echo "Springer Nature official journal article template downloaded and extracted to ${EXTRACT_DIR}."
