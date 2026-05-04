#!/usr/bin/env bash
# build-zips.sh
# Genera un ZIP por cada skill en dist/ listos para arrastrar a claude.ai
# (Settings → Capabilities → Skills → Upload skill).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
DIST_DIR="$REPO_DIR/dist"

if ! command -v zip >/dev/null 2>&1; then
  echo "ERROR: 'zip' no está instalado. Instala con: brew install zip / apt install zip"
  exit 1
fi

mkdir -p "$DIST_DIR"
rm -f "$DIST_DIR"/*.zip

echo "Generando ZIPs en $DIST_DIR ..."
echo ""

count=0
for dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$dir")"
  zip_path="$DIST_DIR/${skill_name}.zip"

  (cd "$SKILLS_SRC" && zip -qr "$zip_path" "$skill_name")
  size=$(du -h "$zip_path" | cut -f1)
  echo "✓ ${skill_name}.zip ($size)"
  count=$((count + 1))
done

echo ""
echo "✓ $count ZIPs generados en $DIST_DIR"
echo ""
echo "Para subir a claude.ai:"
echo "  1. Ve a Settings → Capabilities → Skills"
echo "  2. Pulsa 'Upload skill'"
echo "  3. Arrastra el ZIP correspondiente"
