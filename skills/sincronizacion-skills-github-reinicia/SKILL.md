---
name: sincronizacion-skills-github-reinicia
description: >
  Guía el respaldo en GitHub de las skills de Reinicia que se editan en claude.ai, para que Claude
  Code las use en las Routines. claude.ai es la fuente de autoría; GitHub (agencia-reinicia/claude-skills)
  es el respaldo y la fuente de verdad para Claude Code/Desktop vía symlinks en ~/.claude/skills.
  Cubre el flujo: generar el snapshot COMPLETO de la biblioteca (SIEMPRE en un chat nuevo FUERA de
  cualquier Project, porque un Project ve una foto congelada con versiones viejas), descomprimirlo en
  ~/Downloads/claude-skills-export y ejecutar scripts/import-from-claude-ai.sh (copia + commit/push con
  confirmación + symlinks + verificación, con guardas anti-rollback, recuento y .md sueltos). Actívala
  cuando el usuario diga "sincroniza las skills", "sube las skills a GitHub", "haz el snapshot de skills"
  o "respalda las skills en el repo". Detalle canónico: docs/sync-strategy.md. NO usar para crear o
  editar el contenido de una skill concreta ni para las skills de negocio de clientes.
---

# SKILL: Sincronización de Skills a GitHub — Reinicia

> **Versión vigente: v1.0 — 2026-06-29**

## Propósito

Respaldar en GitHub las skills que editas en **claude.ai**, de forma que Claude Code y Claude
Desktop (que leen del repo vía symlinks) usen siempre la versión al día. Esta skill **no reimplementa**
la estrategia: la orquesta. El detalle canónico vive en `docs/sync-strategy.md` del repo
`agencia-reinicia/claude-skills`.

## Modelo mental (no lo olvides)

- **claude.ai = fuente de autoría.** Es donde editas. Lo más nuevo nace ahí.
- **GitHub = respaldo y fuente de verdad para Claude Code.** Si no bajas lo de claude.ai al repo, tu
  trabajo reciente no está respaldado ni disponible para las Routines.
- **Dirección del flujo:** claude.ai → GitHub → repo local → `~/.claude/skills/`.
- **Disciplina única:** no edites la MISMA skill en dos sitios a la vez. Edita solo en claude.ai.

## ⚠️ Regla de oro — El snapshot se genera FUERA del Project

Un chat **dentro de un Project** ve una **foto congelada** de las skills (la de cuando el Project se
actualizó por última vez): generará un ZIP con **versiones viejas**. Un chat **nuevo, fuera de todo
Project**, ve tu biblioteca personal **al día**.

**Por tanto: el ZIP del snapshot SIEMPRE se pide desde un chat nuevo fuera del Project.** Si esta skill
se está ejecutando dentro de un Project, lo primero es avisar al usuario de que abra un chat fuera del
Project para generar el ZIP.

> Incidente que originó esta regla (jun-2026): se generó el snapshot desde dentro de un Project
> congelado y la importación intentó hacer rollback de skills ya actualizadas (bajar de v0.10 a v0.6).
> El mismo SKILL.md se vio en tres versiones a la vez: v0.6 (Project), v0.7 (chat suelto), v0.10
> (GitHub). De ahí nace la guarda anti-rollback del script.

## Flujo paso a paso

### Paso 1 — Generar el snapshot completo (en chat nuevo FUERA del Project)

Pídele a Claude, en ese chat:

> "Empaqueta todas las skills de /mnt/skills/user en un ZIP, cada una en su subcarpeta con su
> SKILL.md, y pásamelo para descargar."

Descarga el ZIP resultante.

### Paso 2 — Preparar la carpeta de exportación

```bash
rm -rf ~/Downloads/claude-skills-export
# descomprimir el ZIP nuevo en ~/Downloads/claude-skills-export
# (cada skill debe quedar como subcarpeta con su SKILL.md dentro)
```

> ⚠️ **Gotcha — nada de `.md` sueltos.** La carpeta de exportación debe tener cada skill como
> subcarpeta con su `SKILL.md`. Un `.md` suelto en la raíz de la exportación se copiaría a `skills/`
> como basura. Descomprimir el ZIP tal cual deja la estructura correcta; no mezcles ahí ficheros
> `.md` descargados a mano.

### Paso 3 — Importar al repo

```bash
cd ~/repos/claude-skills
bash scripts/import-from-claude-ai.sh "sync: snapshot claude.ai"
```

El script hace: copia (merge, no borra nada) → muestra diff → commit + push con tu confirmación →
`install-symlinks.sh` (enlaza skills nuevas) → `check-drift.sh` (informe final).

### Paso 4 — Atender las guardas del script

El script se detiene y pide confirmación si detecta:

- **`.md` sueltos** en la raíz de la exportación → **aborta**. Corrige la carpeta y reejecuta.
- **Menos skills que el repo** → puede ser snapshot parcial/viejo. Solo continúa si retiraste skills
  a propósito.
- **Rollback** (alguna skill bajaría de versión) → **casi siempre significa que el ZIP salió de un
  sitio congelado**. No fuerces: regenera el ZIP desde un chat fuera del Project (Paso 1) y repite.

## Verificaciones útiles (opcionales)

```bash
bash scripts/check-repo-status.sh   # ¿repo local alineado con origin?
bash scripts/check-drift.sh         # ¿repo y ~/.claude/skills/ alineados?
bash scripts/doctor.sh              # ¿todas las skills con frontmatter válido?
```

## Comprobar la versión de una skill en GitHub

```bash
cd ~/repos/claude-skills && git fetch origin --quiet && \
git show origin/main:skills/<nombre-skill>/SKILL.md | grep -m1 -i "versión vigente"
```

Si una skill no muestra versión, puede que no lleve la línea "Versión vigente" en cabecera (algunas la
tienen en un addendum o no versionan). El script lo trata como "sin versión comparable" y no bloquea.

## Re-subir del repo a claude.ai (caso inverso, poco habitual)

Solo si necesitas llevar una versión del repo de vuelta a claude.ai:

```bash
bash scripts/build-zips.sh
# subir el ZIP de la skill en claude.ai → Settings → Capabilities → Skills → Update
```

## Notas

- **No editar en dos sitios a la vez.** Es la causa raíz del drift.
- **Esta skill vive también en claude.ai:** para tenerla disponible en el chat nuevo donde generas el
  snapshot, debe estar en tu biblioteca. Tras crearla/actualizarla, súbela como cualquier otra.
- **Fuente canónica del detalle:** `docs/sync-strategy.md`. Si esta skill y la doc discrepan, manda la
  doc; actualiza esta skill en consecuencia.
- **Rutas asumidas:** repo en `~/repos/claude-skills`, symlinks en `~/.claude/skills`, exportación en
  `~/Downloads/claude-skills-export`. Si cambian, ajústalas.

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0 | 2026-06-29 | Néstor + Claude | Versión inicial. Skill-guía del flujo claude.ai→GitHub: snapshot fuera del Project, import-from-claude-ai.sh con guardas, gotchas (.md sueltos, Project congelado, anti-rollback) y verificaciones. Remite a docs/sync-strategy.md como fuente canónica. |
