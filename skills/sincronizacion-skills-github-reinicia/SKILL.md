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

> **Versión vigente: v1.4 — 2026-07-05**

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
> SKILL.md, directamente en la raíz del ZIP —sin meterlas dentro de ninguna carpeta contenedora
> adicional—, y pásamelo para descargar."

Descarga el ZIP resultante.

> ⚠️ **Gotcha — el propio Claude debe autoverificar la estructura antes de entregarlo.** El fallo de
> origen (jul-2026, ver Paso 2 más abajo) fue que Claude generó el ZIP copiando primero a una carpeta
> local `skills-reinicia/` y comprimiendo esa carpeta entera, lo que dejó un nivel contenedor de más
> dentro del ZIP (`skills-reinicia/<skill>/SKILL.md` en vez de `<skill>/SKILL.md` en la raíz). Antes de
> presentar el ZIP para descarga, Claude debe correr `unzip -l` (o equivalente) sobre el fichero
> generado y comprobar que las primeras entradas son directamente carpetas de skill (`actas-reinicia/`,
> `marca-reinicia/`...), NO un único directorio que las envuelva a todas. Si al comprimir se usó una
> carpeta de trabajo intermedia (p. ej. `/home/claude/skills-reinicia/`), hay que comprimir su
> **contenido** (`zip -r salida.zip *` estando dentro de ella), no la carpeta en sí (`zip -r salida.zip
> skills-reinicia`) — esta última es precisamente la que introduce el nivel de más.

> 📌 **Convención fija — nombre del fichero.** El ZIP se llama siempre `skills-reinicia.zip` (Claude
> lo genera con ese nombre de forma consistente). No hace falta pedirlo ni confirmarlo cada vez;
> si algún día llega con otro nombre, renómbralo antes de descomprimir en el Paso 2.
> Importante: el **nombre del fichero** (`skills-reinicia.zip`) es independiente de la **estructura
> interna** — el nombre no debe reutilizarse como carpeta contenedora dentro del ZIP (ver gotcha arriba).

### Paso 2 — Preparar la carpeta de exportación

```bash
rm -rf ~/Downloads/claude-skills-export
mkdir -p ~/Downloads/claude-skills-export
ZIP=$(ls -t ~/Downloads/skills-reinicia*.zip | head -1)
unzip -q "$ZIP" -d ~/Downloads/claude-skills-export
```

> 📌 **Por qué el `ls -t ... | head -1` y no `skills-reinicia.zip` a pelo.** El navegador puede
> renombrar el fichero si ya existe uno igual en Descargas (`skills-reinicia (1).zip`,
> `skills-reinicia (2).zip`...). Este comando coge siempre el más reciente que empiece por
> `skills-reinicia`, así el nombre exacto no importa.

> ⚠️ **Gotcha — nada de `.md` sueltos.** La carpeta de exportación debe tener cada skill como
> subcarpeta con su `SKILL.md`. Un `.md` suelto en la raíz de la exportación se copiaría a `skills/`
> como basura. Descomprimir el ZIP tal cual deja la estructura correcta; no mezcles ahí ficheros
> `.md` descargados a mano.

> ⚠️ **Gotcha — nada de carpeta contenedora de más.** Tras descomprimir, `~/Downloads/claude-skills-export`
> debe contener las carpetas de skills **directamente** (`actas-reinicia/`, `marca-reinicia/`...), NO un
> único directorio envolvente (p. ej. `skills-reinicia/`) que a su vez contenga esas carpetas. Compruébalo
> con `ls ~/Downloads/claude-skills-export` antes del Paso 3: si ves una sola carpeta ahí en vez de ~30,
> el ZIP se generó mal (carpeta contenedora de más) — pide que se regenere sin ese nivel antes de
> importar. Si no lo detectas a tiempo, el import crea `skills/<contenedora>/<skill>/SKILL.md` en vez de
> `skills/<skill>/SKILL.md`, y `install-symlinks.sh` la enlaza como si fuera una skill real.
>
> Incidente que originó esta guarda (jul-2026): un ZIP con carpeta contenedora `skills-reinicia/` generó
> 30 rutas anidadas de más (`skills/skills-reinicia/*/SKILL.md`) y un symlink huérfano `skills-reinicia`
> en `~/.claude/skills`. `check-drift.sh` no lo detectó porque solo compara nombres de entrada en
> `skills/` vs `~/.claude/skills`, no la estructura interna de cada una.

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
| v1.1 | 2026-07-05 | Néstor + Claude | Fijada la convención: el ZIP del snapshot se llama siempre `skills-reinicia.zip`. Nota añadida en el Paso 1 para no tener que confirmarlo en cada sincronización. |
| v1.2 | 2026-07-05 | Néstor + Claude | Paso 2 corregido: el bloque solo tenía un comentario, no un comando real de descompresión. Sustituido por `unzip` real, localizando el ZIP con `ls -t ~/Downloads/skills-reinicia*.zip \| head -1` para tolerar renombrados por descarga duplicada (`(1)`, `(2)`...). |
| v1.3 | 2026-07-05 | Néstor + Claude | Nueva guarda en el Paso 2: comprobar que la exportación no tenga una carpeta contenedora de más (p. ej. `skills-reinicia/` envolviendo las skills) antes de importar. Incidente: un ZIP mal generado creó `skills/skills-reinicia/*/SKILL.md` en el repo y un symlink huérfano `skills-reinicia`; `check-drift.sh` no lo detectó porque no valida la estructura interna. |
| v1.4 | 2026-07-05 | Néstor + Claude | Cortado el fallo de raíz en el Paso 1: instrucción a Claude reformulada para exigir explícitamente "sin carpeta contenedora adicional", más gotcha obligando a Claude a autoverificar la estructura del ZIP (`unzip -l`) antes de entregarlo, y aclaración de que comprimir el *contenido* de la carpeta de trabajo (`zip -r salida.zip *`) no es lo mismo que comprimir la carpeta en sí (`zip -r salida.zip skills-reinicia`) — esta última fue la causa real del incidente de la v1.3. |
