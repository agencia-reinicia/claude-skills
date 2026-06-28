#!/usr/bin/env bash
set -euo pipefail

# sync-skills.sh — Sincroniza las skills de Reinicia:
#   1) copia desde la exportación de claude.ai al repo (merge, sin borrar nada)
#   2) muestra el diff y pide confirmación antes de commit + push
#   3) crea los symlinks que falten en ~/.claude/skills y avisa de los rotos
#
# Uso:
#   ./sync-skills.sh ["mensaje de commit"]
# Variable opcional:
#   SRC=<carpeta>  origen de las skills (default: ~/Downloads/claude-skills-export)

SRC="${SRC:-$HOME/Downloads/claude-skills-export}"
REPO="$HOME/repos/claude-skills"
SKILLS_DIR="$REPO/skills"
LINKS_DIR="$HOME/.claude/skills"

b=$(tput bold 2>/dev/null || true); n=$(tput sgr0 2>/dev/null || true)

echo "${b}== sync-skills ==${n}"
echo "Origen : $SRC"
echo "Repo   : $SKILLS_DIR"
echo "Enlaces: $LINKS_DIR"
echo

# 1) Validaciones
[ -d "$SRC" ]        || { echo "ERROR: no existe la carpeta de origen: $SRC"; exit 1; }
[ -d "$SKILLS_DIR" ] || { echo "ERROR: no existe el repo: $SKILLS_DIR"; exit 1; }
mkdir -p "$LINKS_DIR"

# 2) Copiar (merge, sin borrar nada)
echo "${b}[1/5] Copiando skills al repo...${n}"
if [ -z "$(ls -A "$SRC" 2>/dev/null)" ]; then
  echo "  AVISO: el origen esta vacio. No se copia nada."
else
  cp -R "$SRC"/* "$SKILLS_DIR"/
  echo "  hecho."
fi
echo

# 3) Estado git
cd "$REPO"
if [ -z "$(git status --porcelain skills/)" ]; then
  echo "${b}[2/5] Sin cambios en skills/.${n} Nada que commitear."
  CHANGES=0
else
  echo "${b}[2/5] Cambios detectados:${n}"
  git status -s skills/
  CHANGES=1
fi
echo

# 4) Commit + push (con confirmación)
if [ "$CHANGES" -eq 1 ]; then
  MSG="${1:-}"
  while [ -z "$MSG" ]; do
    read -r -p "Mensaje de commit (no puede estar vacio): " MSG
  done

  git add skills/
  echo
  echo "${b}[3/5] Se va a commitear:${n}"
  git status -s skills/
  read -r -p "¿Confirmar commit + push? [y/N] " ok
  case "$ok" in
    y|Y|s|S)
      git commit -m "$MSG"
      echo "${b}[4/5] push...${n}"
      git push origin main
      ;;
    *)
      echo "Cancelado. Los cambios quedan staged pero SIN commit ni push."
      exit 0
      ;;
  esac
else
  echo "${b}[3-4/5] Nada que commitear/pushear.${n}"
fi
echo

# 5) Symlinks: crear los que falten + avisar de rotos
echo "${b}[5/5] Revisando symlinks en $LINKS_DIR...${n}"
created=0
for dir in "$SKILLS_DIR"/*/; do
  name=$(basename "$dir")
  link="$LINKS_DIR/$name"
  if [ ! -e "$link" ] && [ ! -L "$link" ]; then
    ln -s "$dir" "$link"
    echo "  + enlazada: $name"
    created=$((created+1))
  fi
done
[ "$created" -eq 0 ] && echo "  No faltaba ningun symlink."

broken=$(find "$LINKS_DIR" -type l ! -exec test -e {} \; -print)
if [ -n "$broken" ]; then
  echo
  echo "${b}AVISO: symlinks ROTOS (apuntan a algo inexistente):${n}"
  echo "$broken"
  echo "  Pueden ser skills borradas del repo. Revisalos a mano."
fi

echo
echo "Total skills enlazadas: $(ls -1 "$LINKS_DIR" | wc -l | tr -d ' ')"
echo "${b}Listo.${n}"
