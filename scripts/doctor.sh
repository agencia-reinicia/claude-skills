#!/usr/bin/env bash
# doctor.sh
# Verifica que cada skill tiene SKILL.md, frontmatter YAML válido con name+description.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_DIR/skills"

echo "Diagnóstico de skills en $SKILLS_SRC"
echo "─────────────────────────────────────────────────────"

ok=0
warn=0
err=0

for dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$dir")"
  skill_md="$dir/SKILL.md"

  if [ ! -f "$skill_md" ]; then
    echo "✗ $skill_name → falta SKILL.md"
    err=$((err + 1))
    continue
  fi

  # Comprobar frontmatter (primera línea es '---')
  first_line=$(head -n 1 "$skill_md")
  if [ "$first_line" != "---" ]; then
    echo "⚠ $skill_name → SKILL.md sin frontmatter YAML (primera línea: '$first_line')"
    warn=$((warn + 1))
    continue
  fi

  # Comprobar campos name y description en frontmatter
  has_name=$(awk '/^---$/{c++} c==1 && /^name:/' "$skill_md" | head -1)
  has_desc=$(awk '/^---$/{c++} c==1 && /^description:/' "$skill_md" | head -1)

  if [ -z "$has_name" ] || [ -z "$has_desc" ]; then
    echo "⚠ $skill_name → frontmatter incompleto (name: $([ -n "$has_name" ] && echo OK || echo FALTA), description: $([ -n "$has_desc" ] && echo OK || echo FALTA))"
    warn=$((warn + 1))
    continue
  fi

  echo "✓ $skill_name"
  ok=$((ok + 1))
done

echo "─────────────────────────────────────────────────────"
echo "OK: $ok   Avisos: $warn   Errores: $err"

if [ $err -gt 0 ]; then
  exit 1
fi
