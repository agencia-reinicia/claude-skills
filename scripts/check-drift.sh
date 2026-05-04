#!/usr/bin/env bash
# check-drift.sh
# Detecta diferencias entre las skills del repo (fuente de verdad) y las
# instaladas en ~/.claude/skills/ (Claude Code y Claude Desktop).
#
# Salida:
#   ✓ skill alineada (symlink al repo, o copia idéntica)
#   ⚠ skill con drift (existe en ambos pero el contenido difiere)
#   + skill solo en repo (falta instalar en local)
#   - skill solo en local (no está en el repo, candidata a ser añadida)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_REPO="$REPO_DIR/skills"
SKILLS_LOCAL="$HOME/.claude/skills"

if [ ! -d "$SKILLS_REPO" ]; then
  echo "ERROR: no encuentro $SKILLS_REPO"
  exit 1
fi

if [ ! -d "$SKILLS_LOCAL" ]; then
  echo "ERROR: no existe $SKILLS_LOCAL — ejecuta antes scripts/install-symlinks.sh"
  exit 1
fi

echo "Comparando:"
echo "  Repo:  $SKILLS_REPO"
echo "  Local: $SKILLS_LOCAL"
echo "─────────────────────────────────────────────────────"

aligned=0
drift=0
only_repo=0
only_local=0

# Recorrer skills del repo
for dir in "$SKILLS_REPO"/*/; do
  skill_name="$(basename "$dir")"
  local_path="$SKILLS_LOCAL/$skill_name"

  if [ ! -e "$local_path" ]; then
    echo "+ $skill_name → SOLO EN REPO (falta instalar)"
    only_repo=$((only_repo + 1))
    continue
  fi

  # Si es symlink al repo, está alineada por construcción
  if [ -L "$local_path" ]; then
    target="$(readlink "$local_path")"
    # Normalizar paths para comparación
    target_abs="$(cd "$(dirname "$target")" 2>/dev/null && pwd)/$(basename "$target")" || target_abs="$target"
    repo_abs="$(cd "$dir" && pwd)"
    # Comparar ignorando trailing slash
    if [ "${target%/}" = "${repo_abs%/}" ] || [ "${target_abs%/}" = "${repo_abs%/}" ]; then
      echo "✓ $skill_name (symlink)"
      aligned=$((aligned + 1))
      continue
    fi
  fi

  # Comparar contenido recursivamente
  if diff -rq "$dir" "$local_path" >/dev/null 2>&1; then
    echo "✓ $skill_name (copia idéntica)"
    aligned=$((aligned + 1))
  else
    echo "⚠ $skill_name → DRIFT detectado"
    drift=$((drift + 1))
    # Mostrar resumen de diferencias
    diff -rq "$dir" "$local_path" 2>&1 | sed 's/^/      /' | head -5
  fi
done

# Recorrer skills de local que no estén en repo
for dir in "$SKILLS_LOCAL"/*/; do
  [ -e "$dir" ] || continue  # nullglob fallback
  skill_name="$(basename "$dir")"
  if [ ! -e "$SKILLS_REPO/$skill_name" ]; then
    echo "- $skill_name → SOLO EN LOCAL (candidata a añadir al repo)"
    only_local=$((only_local + 1))
  fi
done

echo "─────────────────────────────────────────────────────"
echo "Alineadas: $aligned   Drift: $drift   Solo repo: $only_repo   Solo local: $only_local"
echo ""

if [ $drift -gt 0 ]; then
  echo "⚠ Hay drift. Para resolver:"
  echo "   - Si el cambio bueno está en el repo → reinstala con scripts/install-symlinks.sh"
  echo "   - Si el cambio bueno está en local → cópialo al repo, commit + push"
  echo "   - Para ver diferencias detalladas: diff -r $SKILLS_REPO/<skill> $SKILLS_LOCAL/<skill>"
  exit 1
fi

if [ $only_repo -gt 0 ]; then
  echo "ℹ Hay skills sin instalar localmente. Ejecuta: bash scripts/install-symlinks.sh"
fi

if [ $only_local -gt 0 ]; then
  echo "ℹ Hay skills locales que no están en el repo."
  echo "  Decide si versionarlas (cópialas a skills/ y commit) o ignorarlas."
fi
