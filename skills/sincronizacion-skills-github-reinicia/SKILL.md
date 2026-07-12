---
name: sincronizacion-skills-github-reinicia
description: >
  Guía el respaldo en GitHub de las skills de Reinicia que se editan en claude.ai, para que Claude
  Code las use en las Routines. claude.ai es la fuente de autoría; GitHub (agencia-reinicia/claude-skills)
  es el respaldo y la fuente de verdad para Claude Code/Desktop vía symlinks en ~/.claude/skills.
  Cubre el flujo: generar el snapshot COMPLETO de la biblioteca (por defecto en un chat nuevo FUERA de
  cualquier Project, porque un Project puede servir una foto congelada), descomprimirlo en
  ~/Downloads/claude-skills-export y ejecutar scripts/import-from-claude-ai.sh (copia + commit/push con
  confirmación + symlinks + verificación, con guardas anti-rollback, recuento y .md sueltos). Actívala
  cuando el usuario diga "sincroniza las skills", "sube las skills a GitHub", "haz el snapshot de skills"
  o "respalda las skills en el repo". Detalle canónico: docs/sync-strategy.md. NO usar para crear o
  editar el contenido de una skill concreta ni para las skills de negocio de clientes.
---

# SKILL: Sincronización de Skills a GitHub — Reinicia

> **Versión vigente: v1.5 — 2026-07-12**

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

## ⚠️ Regla de oro — Genera el snapshot fuera del Project por prudencia, pero confía en la guarda anti-rollback

Un chat **dentro de un Project** **puede** ver una **foto congelada** de las skills (la de cuando el
Project se actualizó por última vez) y generar un ZIP con **versiones viejas** — pero **no siempre**:
a veces el mount está al día. El problema es que **desde dentro no se distingue a ojo**, y verificarlo
tiene su coste. Por eso, **por defecto y por prudencia, el ZIP del snapshot se pide desde un chat nuevo
fuera del Project**, donde la biblioteca se ve siempre al día. Si esta skill se ejecuta dentro de un
Project, lo primero sigue siendo ofrecer generar el snapshot desde un chat fuera del Project.

**Pero lo que de verdad te cubre no es *dónde* generas el ZIP: es la guarda anti-rollback del script.**
Aunque el snapshot saliera viejo, `import-from-claude-ai.sh` compara versión a versión y **se detiene
antes de retroceder ninguna skill** (Paso 4). Un snapshot congelado se traduce entonces en un aborto
controlado, no en pérdida de trabajo. La regla "fuera del Project" es higiene para no toparte con ese
aborto; la guarda es la red de seguridad.

> Si aun así generas desde dentro de un Project, sal de dudas antes de importar: lista la "Versión
> vigente" de cada skill de la exportación (ver *Verificaciones útiles*). Si vienen al día — o por
> delante de lo que recordabas — el mount no estaba congelado y puedes seguir.

> Incidente que originó la guarda (jun-2026): se generó el snapshot desde dentro de un Project
> congelado y la importación intentó hacer rollback de skills ya actualizadas (bajar de v0.10 a v0.6).
> El mismo SKILL.md se vio en tres versiones a la vez: v0.6 (Project), v0.7 (chat suelto), v0.10
> (GitHub).

> Contraejemplo (12-jul-2026): en una sincronización lanzada **desde dentro de un Project**, el mount
> de `/mnt/skills/user` traía versiones **de ese mismo día**, algunas por delante de las que se daban
> por vigentes (p. ej. `plan-proyecto-zoho-sheet-reinicia` v2.13). Un Project **no siempre** sirve una
> foto vieja. Se verificó listando versiones antes de importar, la guarda anti-rollback no saltó y el
> push entró correctamente. Moraleja: el "siempre congelado" es falso; trata el origen del ZIP como
> prudencia y la guarda como seguridad.

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
- **Menos skills que el repo** → puede ser snapshot parcial/viejo. Antes de decidir, corre el `diff`
  exportación↔repo (ver *Verificaciones útiles*) para ver **qué** skill sobra en el repo:
  - Si la que falta es **`skill-creator`** → es **normal y esperado**: es la meta-skill de ejemplo de
    Anthropic, vive en `/mnt/skills/examples` (no en tu biblioteca `/mnt/skills/user`), así que **nunca
    entra en el snapshot** aunque esté copiada en el repo. Contesta `y`; el merge no la toca.
  - Si es una skill que **retiraste a propósito** → continúa (el merge no borra la que sobra).
  - Si es una skill que **debería estar viva** (p. ej. creada hoy, tras el último refresco del Project)
    → aborta y regenera el snapshot desde un chat fuera del Project, no sea que se quede sin respaldar.
- **Rollback** (alguna skill bajaría de versión) → **casi siempre significa que el ZIP salió de un
  sitio congelado**. No fuerces: regenera el ZIP desde un chat fuera del Project (Paso 1) y repite.

## Verificaciones útiles (opcionales)

```bash
bash scripts/check-repo-status.sh   # ¿repo local alineado con origin?
bash scripts/check-drift.sh         # ¿repo y ~/.claude/skills/ alineados?
bash scripts/doctor.sh              # ¿todas las skills con frontmatter válido?
```

**Comprobar que el snapshot viene al día** — antes de importar; útil sobre todo si lo generaste desde
dentro de un Project. Lista la "Versión vigente" de cada skill de la exportación (si vienen al día o
por delante de lo recordado, el mount no estaba congelado):

```bash
for d in ~/Downloads/claude-skills-export/*/; do
  v=$(grep -m1 -i "versión vigente" "$d/SKILL.md" 2>/dev/null | sed 's/^[>*# ]*//')
  printf "%-52s %s\n" "$(basename "$d")" "${v:-<sin línea de versión>}"
done
```

**Ver qué skill sobra/falta entre la exportación y el repo** — útil ante el aviso "menos skills que el
repo" del Paso 4. La línea con `>` es la que está en el repo pero no en el snapshot:

```bash
diff <(ls ~/Downloads/claude-skills-export | sort) <(ls ~/repos/claude-skills/skills | sort)
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
| v1.5 | 2026-07-12 | Néstor + Claude | Corregido el absoluto falso de la Regla de oro: un Project **puede** servir una foto congelada, pero **no siempre** (contraejemplo del 12-jul: mount al día, con versiones por delante de lo recordado, p. ej. `plan-proyecto-zoho-sheet-reinicia` v2.13). Regla reenfocada como prudencia y la **guarda anti-rollback** del script como red de seguridad real. Paso 4: documentado el caso benigno "menos skills que el repo" cuando la que falta es `skill-creator` (meta-skill de ejemplo de Anthropic en `/mnt/skills/examples`, nunca entra en el snapshot). Verificaciones útiles: añadidos one-liners para listar la "Versión vigente" de la exportación y el `diff` exportación↔repo. |
