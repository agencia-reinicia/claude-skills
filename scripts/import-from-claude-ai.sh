#!/usr/bin/env bash
# import-from-claude-ai.sh
# Importa un snapshot COMPLETO de skills exportado de claude.ai al repo.
#
# Fuente de verdad: claude.ai. El snapshot fiable se genera pidiendole a Claude,
# EN UN CHAT NUEVO FUERA DE CUALQUIER PROJECT, que empaquete /mnt/skills/user en
# un ZIP (cada skill en su subcarpeta con SKILL.md). Un Project puede estar
# "congelado" y mostrar versiones viejas: no generes el ZIP desde dentro de uno.
#
# Flujo recomendado:
#   1. rm -rf ~/Downloads/claude-skills-export
#   2. descomprimir el ZIP nuevo en ~/Downloads/claude-skills-export
#   3. bash scripts/import-from-claude-ai.sh ["mensaje de commit"]
#
# Variable opcional:  SRC=<carpeta>  (default: ~/Downloads/claude-skills-export)
#
# Guardas antes de copiar:
#   - .md sueltos en la raiz de la exportacion  -> ABORTA
#   - la exportacion trae MENOS skills que el repo -> pide confirmacion
#   - alguna skill BAJARIA de version (rollback) -> pide confirmacion

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DST="$REPO_DIR/skills"
SRC="${SRC:-$HOME/Downloads/claude-skills-export}"

echo "Origen: $SRC"
echo "Repo:   $SKILLS_DST"
echo "-----------------------------------------------------"

# --- Validaciones basicas ---
[ -d "$SRC" ]        || { echo "ERROR: no existe la carpeta de origen: $SRC"; exit 1; }
[ -d "$SKILLS_DST" ] || { echo "ERROR: no existe $SKILLS_DST"; exit 1; }
[ -n "$(ls -A "$SRC" 2>/dev/null)" ] || { echo "ERROR: la carpeta de origen esta vacia."; exit 1; }

# --- Guarda 1: .md sueltos en la raiz de la exportacion ---
loose_md="$(find "$SRC" -maxdepth 1 -type f -name '*.md' 2>/dev/null || true)"
if [ -n "$loose_md" ]; then
  echo "ERROR: hay ficheros .md SUELTOS en la raiz de la exportacion:"
  echo "$loose_md" | sed 's/^/   /'
  echo "  Cada skill debe ir en su subcarpeta con SKILL.md dentro. Corrige y reejecuta."
  exit 1
fi

# Helper: extrae "vX.Y" de la linea 'Version vigente' de un SKILL.md (vacio si no hay)
get_ver() {
  grep -m1 -iE "versi.n vigente:[[:space:]]*v[0-9]+\.[0-9]+" "$1" 2>/dev/null \
    | grep -oiE "v[0-9]+\.[0-9]+" | head -1 | tr -d 'vV' || true
}
# Helper: es $1 < $2 ? (versiones "MAJOR.MINOR" comparadas numericamente)
ver_lt() {
  local a_major="${1%%.*}" a_minor="${1##*.}"
  local b_major="${2%%.*}" b_minor="${2##*.}"
  if [ "$a_major" -lt "$b_major" ]; then return 0; fi
  if [ "$a_major" -eq "$b_major" ] && [ "$a_minor" -lt "$b_minor" ]; then return 0; fi
  return 1
}

# --- Guarda 2 y 3: recuento y anti-rollback ---
src_count=0
repo_count=$(find "$SKILLS_DST" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')
rollbacks=""
nover=""
for dir in "$SRC"/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  src_count=$((src_count+1))
  src_md="$dir/SKILL.md"
  repo_md="$SKILLS_DST/$name/SKILL.md"
  [ -f "$src_md" ] || { echo "AVISO: $name no tiene SKILL.md en el origen."; continue; }
  [ -f "$repo_md" ] || continue
  sv="$(get_ver "$src_md")"
  rv="$(get_ver "$repo_md")"
  if [ -z "$sv" ] || [ -z "$rv" ]; then
    nover="$nover  $name (origen: ${sv:--} | repo: ${rv:--})\n"
  elif ver_lt "$sv" "$rv"; then
    rollbacks="$rollbacks  $name: repo v$rv  ->  origen v$sv\n"
  fi
done

echo "Skills en origen: $src_count   |   en repo: $repo_count"
echo ""

confirm() { read -r -p "$1 [y/N] " a; case "$a" in y|Y|s|S) return 0;; *) return 1;; esac; }

if [ "$src_count" -lt "$repo_count" ]; then
  echo "AVISO: la exportacion trae MENOS skills que el repo ($src_count < $repo_count)."
  echo "  Puede ser un snapshot parcial o viejo. Si es correcto (retiraste skills), continua."
  confirm "Continuar de todos modos?" || { echo "Cancelado."; exit 1; }
  echo ""
fi

if [ -n "$rollbacks" ]; then
  echo "AVISO: ROLLBACK detectado - estas skills BAJARIAN de version:"
  printf "%b" "$rollbacks" | sed '/^$/d'
  echo "  Suele indicar un origen desactualizado (ZIP generado dentro de un Project congelado?)."
  confirm "Copiar igualmente y bajar esas versiones?" || { echo "Cancelado. Nada copiado."; exit 1; }
  echo ""
fi

if [ -n "$nover" ]; then
  echo "INFO: skills sin version comparable en cabecera (no se pudo verificar rollback):"
  printf "%b" "$nover" | sed '/^$/d'
  echo ""
fi

# --- Copia (merge, sin borrar nada del repo) ---
echo "Copiando exportacion al repo..."
cp -R "$SRC"/* "$SKILLS_DST"/
echo "  hecho."
echo ""

# --- Commit + push (con confirmacion) ---
cd "$REPO_DIR"
if [ -z "$(git status --porcelain skills/)" ]; then
  echo "Sin cambios en skills/. Nada que commitear."
else
  echo "Cambios detectados en skills/:"
  git status -s skills/
  echo ""
  MSG="${1:-}"
  while [ -z "$MSG" ]; do read -r -p "Mensaje de commit (no puede estar vacio): " MSG; done
  git add skills/
  echo ""
  echo "Se va a commitear y pushear:"
  git status -s skills/
  if confirm "Confirmar commit + push?"; then
    git commit -m "$MSG"
    echo "push..."
    git push origin main
  else
    echo "Cancelado. Cambios staged pero SIN commit ni push."
    echo "(Aun asi creare los symlinks que falten.)"
  fi
fi
echo ""

# --- Symlinks (delegado) + verificacion (informe) ---
echo "-----------------------------------------------------"
echo "Symlinks (install-symlinks.sh):"
bash "$REPO_DIR/scripts/install-symlinks.sh"
echo ""
echo "-----------------------------------------------------"
echo "Verificacion de drift (check-drift.sh):"
bash "$REPO_DIR/scripts/check-drift.sh" || true

echo ""
echo "Importacion terminada."
