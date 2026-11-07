#!/usr/bin/env bash
# Rebuild the public CV (no phone number) from the CV repo and copy it into the site.
# Then run `quarto render` and commit. The CV repo stays the single source.
set -euo pipefail

site_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cv_dir="${CV_DIR:-$HOME/OneDrive/documents/cv y experiencia/CV}"
# Build outside /home/peter: a stale sshfs mount there aborts TeX (see the CV repo's build.sh).
build_dir="${TMPDIR:-/tmp}/webcvbuild"

rm -rf "$build_dir"
mkdir -p "$build_dir"
cp "$cv_dir/main.tex" "$cv_dir/mypubs.bib" "$build_dir/"
sed -i '/^\\phone/d' "$build_dir/main.tex"

if ! (cd "$build_dir" && latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex > build.out 2>&1); then
  grep -E "^!" "$build_dir/main.log" || tail -20 "$build_dir/build.out"
  exit 1
fi

if pdftotext "$build_dir/main.pdf" - | grep -q "201.5380"; then
  echo "Phone number found in the public CV; not copied." >&2
  exit 1
fi

cp "$build_dir/main.pdf" "$site_dir/files/Olejua_CV.pdf"
echo "Updated $site_dir/files/Olejua_CV.pdf"
