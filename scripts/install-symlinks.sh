#!/usr/bin/env bash
# install-symlinks.sh
# Crea symlinks de cada skill del repo en ~/.claude/skills/ para que
# Claude Code y Claude Desktop las descubran globalmente.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"

if [ ! -d "$SKILLS_SRC" ]; then
  echo "ERROR: no encuentro $SKILLS_SRC"
  exit 1
fi

mkdir -p "$SKILLS_DST"

echo "Origen:  $SKILLS_SRC"
echo "Destino: $SKILLS_DST"
echo ""

count=0
for dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$dir")"
  target="$SKILLS_DST/$skill_name"

  if [ -L "$target" ]; then
    echo "↻ $skill_name (symlink existente, actualizado)"
  elif [ -e "$target" ]; then
    echo "⚠ $skill_name → ya existe como carpeta real, NO sobrescribo. Borra manualmente si quieres usar el symlink."
    continue
  else
    echo "+ $skill_name"
  fi

  ln -sfn "$dir" "$target"
  count=$((count + 1))
done

echo ""
echo "✓ $count skills enlazadas en $SKILLS_DST"
echo ""
echo "Verifica con: ls -la $SKILLS_DST"
