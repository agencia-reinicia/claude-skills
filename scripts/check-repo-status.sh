#!/usr/bin/env bash
# check-repo-status.sh
# Comprueba si el repo local está alineado con origin/main.
# Útil antes de un Sprint Planning o de redistribuir el repo a otra máquina.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

if [ ! -d ".git" ]; then
  echo "ERROR: $REPO_DIR no es un repositorio Git"
  exit 1
fi

echo "Repositorio: $REPO_DIR"
echo "─────────────────────────────────────────────────────"

# Fetch silencioso para tener referencia actualizada del remoto
echo "▸ Fetching origin..."
git fetch origin --quiet 2>/dev/null || {
  echo "⚠ No se pudo hacer fetch (¿sin red? ¿credenciales?)"
}

# Rama actual
BRANCH="$(git branch --show-current)"
echo "▸ Rama actual: $BRANCH"

# Cambios sin commitear
UNCOMMITTED="$(git status --porcelain | wc -l | tr -d ' ')"
if [ "$UNCOMMITTED" -gt 0 ]; then
  echo ""
  echo "⚠ $UNCOMMITTED ficheros con cambios sin commitear:"
  git status --short | sed 's/^/   /'
fi

# Comparar con remoto
if git rev-parse --verify --quiet "origin/$BRANCH" >/dev/null; then
  AHEAD="$(git rev-list --count "origin/$BRANCH..$BRANCH" 2>/dev/null || echo 0)"
  BEHIND="$(git rev-list --count "$BRANCH..origin/$BRANCH" 2>/dev/null || echo 0)"

  echo ""
  if [ "$AHEAD" -eq 0 ] && [ "$BEHIND" -eq 0 ] && [ "$UNCOMMITTED" -eq 0 ]; then
    echo "✓ Local y origin/$BRANCH están sincronizados"
  else
    [ "$AHEAD" -gt 0 ] && echo "▲ $AHEAD commit(s) sin pushear (local tiene cosas que origin no)"
    [ "$BEHIND" -gt 0 ] && echo "▼ $BEHIND commit(s) sin pullear (origin tiene cosas que local no)"
    [ "$BEHIND" -gt 0 ] && echo "  → Ejecuta: git pull --ff-only"
    [ "$AHEAD" -gt 0 ] && echo "  → Ejecuta: git push"
  fi
else
  echo "⚠ La rama '$BRANCH' no existe en origin"
fi

# Último commit
echo ""
echo "▸ Último commit local:"
git log -1 --format="   %h  %ci  %s" 2>/dev/null || echo "   (sin commits)"
