# Cómo saber si las skills están actualizadas

Una skill puede estar "desactualizada" en cuatro lugares distintos. Esta guía es honesta sobre **qué se puede automatizar y qué no**, y te da el workflow mínimo viable para no perder horas en esto.

## Los cuatro lugares donde puede haber drift

```
┌────────────────────────────────────────────────────────────────┐
│ 1. claude.ai biblioteca   ← DONDE EDITAS (fuente de autoría)   │
│ 2. GitHub origin/main     ← respaldo y fuente de verdad p/ Code │
│ 3. Repo local clonado     ← lo que ves en tu disco             │
│ 4. ~/.claude/skills/      ← lo que usan Claude Code y Desktop  │
└────────────────────────────────────────────────────────────────┘
```

**Dos roles distintos, no los confundas:**
- **claude.ai** es donde de verdad editas las skills (su interfaz es cómoda y es donde trabajas). Es la **fuente de autoría**: lo más nuevo nace ahí.
- **GitHub** es el **respaldo versionado** y la fuente de verdad para Claude Code / Desktop (que leen del repo vía symlinks). Si no bajas lo de claude.ai al repo, tu trabajo reciente no está respaldado ni disponible para las Routines.

La dirección del flujo es, por tanto: **claude.ai → GitHub → repo local → `~/.claude/skills/`**.

## Verificación automática (lo que `scripts/` resuelve)

| Drift entre... | Script | Resuelve drift |
|---|---|---|
| claude.ai → Repo (importar) | `import-from-claude-ai.sh` | Semi-asistido (la extracción es manual) |
| GitHub ↔ Repo local | `check-repo-status.sh` | Sí, automático |
| Repo local ↔ `~/.claude/skills/` | `check-drift.sh` | Sí, automático |
| Lo anterior + integridad SKILL.md | `doctor.sh` | Sí, automático |
| Repo → claude.ai (re-subir) | `build-zips.sh` | Manual (subida por la web) |

### Comandos que importan

```bash
# Traer a GitHub lo que has editado en claude.ai (ver "Regla 1")
bash scripts/import-from-claude-ai.sh "sync: snapshot claude.ai"

# Antes de empezar a trabajar (¿hay cambios remotos? ¿algo sin pushear?)
bash scripts/check-repo-status.sh

# Después de un git pull o de importar (¿el local tiene lo que el repo tiene?)
bash scripts/check-drift.sh

# Integridad de las skills (¿todas con frontmatter válido?)
bash scripts/doctor.sh

# Solo si necesitas RE-subir una skill del repo a claude.ai
bash scripts/build-zips.sh
```

## Estrategia práctica para evitar drift (la que de verdad funciona)

### Regla 1 — Una sola dirección: edita en claude.ai, respalda en GitHub

En la práctica editas las skills **en claude.ai** (es donde trabajas). Perfecto: que sea tu única fuente de autoría. El drift aparece solo si editas **la misma** skill en dos sitios a la vez. La disciplina no es *dónde* editas, sino **no editar en los dos sitios en paralelo**.

Workflow para respaldar en GitHub lo que editas en claude.ai:

1. Edita la skill en claude.ai (una o varias, da igual).
2. Genera un snapshot **completo** de tu biblioteca (ver Regla 3 — **importante: en un chat nuevo FUERA de cualquier Project**).
3. Descomprime el ZIP en `~/Downloads/claude-skills-export` (borrando antes la carpeta vieja).
4. `cd ~/repos/claude-skills && bash scripts/import-from-claude-ai.sh "sync: snapshot claude.ai"`.

El script copia al repo, te enseña el diff, hace commit + push con tu confirmación, refresca los symlinks y verifica drift. Trae tres guardas: aborta si hay `.md` sueltos en la exportación, avisa si el snapshot trae menos skills que el repo, y **avisa si alguna skill bajaría de versión** (anti-rollback).

> ⚠️ **Gotcha — nada de `.md` sueltos.** La carpeta de exportación debe tener cada skill como **subcarpeta con su `SKILL.md` dentro**. Un `.md` suelto en la raíz de la exportación se copiaría a `skills/` como basura. El descomprimir el ZIP tal cual ya deja la estructura correcta; no mezcles ahí ficheros `.md` sueltos descargados a mano.

### Regla 2 — Symlinks, no copias

Si `~/.claude/skills/` son symlinks al repo (lo que hace `install-symlinks.sh`), un `git pull` actualiza Claude Code y Desktop **automáticamente**. No hay drift posible entre repo local y `~/.claude/skills/`. `import-from-claude-ai.sh` ya llama a `install-symlinks.sh` al final, así que las skills nuevas quedan enlazadas sin pasos extra.

### Regla 3 — El snapshot fiable se genera en un chat nuevo FUERA del Project

Como la API no permite listar/descargar tu biblioteca personal, la forma de extraerla es pedirle a Claude que empaquete las skills en un ZIP. **Pero dónde lo pidas importa muchísimo:**

- **Un chat dentro de un Project ve una FOTO CONGELADA** de las skills (la de cuando el Project se creó/actualizó por última vez). Si generas el ZIP ahí, bajarás **versiones viejas**.
- **Un chat nuevo, fuera de cualquier Project, ve tu biblioteca personal al día.** Ese es el único sitio fiable para el snapshot.

Procedimiento:

1. Abre un **chat nuevo, fuera de todo Project**.
2. Pídele: *"empaqueta todas las skills de `/mnt/skills/user` en un ZIP, cada una en su subcarpeta con su `SKILL.md`, y pásamelo para descargar."*
3. Descárgalo y pásalo por `import-from-claude-ai.sh` (Regla 1). El script compara versiones por ti y avisa de cualquier rollback: si ves un aviso de rollback, es señal de que el ZIP salió de un sitio congelado — regenéralo desde un chat fuera del Project.

> 📌 **Por qué esta regla existe (incidente de junio 2026).** Durante la puesta en marcha se generó el snapshot desde dentro de un Project, que estaba congelado en versiones viejas. Resultado: varios intentos de importación querían hacer **rollback** de skills que ya se habían actualizado (p.ej. bajar `plan-proyecto-reinicia-modo-desatendido` de v0.10 a v0.6). Se comprobó en vivo que el mismo `SKILL.md` se veía en tres versiones a la vez: v0.6 dentro del Project, v0.7 en un chat suelto y v0.10 en GitHub. La guarda anti-rollback del script nace de aquí. Lección: **el snapshot SIEMPRE desde un chat fuera del Project**, y si el script avisa de rollback, no fuerces — revisa el origen.

### Regla 4 — Spot check con Claude

Para verificar una skill concreta, en un chat (mejor fuera del Project) pídele a Claude que muestre el contenido completo de esa skill tal como la ve. Compara con el repo. Útil cuando sospeches drift de una skill específica.

```
Yo: Muéstrame el contenido completo del SKILL.md de la skill "actas-reinicia"
    tal como lo tienes cargado tú ahora mismo, incluida la línea de "Versión vigente".
```

## Checklist de sincronización (mensual, o tras una tanda de ediciones)

- [ ] Editaste en claude.ai → genera el snapshot **en un chat fuera del Project** (Regla 3)
- [ ] `bash scripts/import-from-claude-ai.sh "sync: snapshot claude.ai"` — importar, revisar diff, push
- [ ] Atiende los avisos del script (rollback / menos skills / `.md` sueltos) antes de confirmar
- [ ] `bash scripts/check-repo-status.sh` — sin commits sin pushear
- [ ] `bash scripts/check-drift.sh` — repo y `~/.claude/skills/` alineados
- [ ] `bash scripts/doctor.sh` — todas las skills con frontmatter válido
- [ ] Si actualizaste el Project de trabajo, recuerda que su foto de skills no se refresca sola

## Lo que está fuera de tu alcance (y de momento del de cualquiera)

- Anthropic no expone API pública para listar/leer/escribir tu biblioteca de skills personal de claude.ai. Por eso la extracción del snapshot es manual (pedir el ZIP a Claude).
- Los Projects de claude.ai snapshotean las skills cuando se crean/actualizan; **no se refrescan solos** cuando actualizas la skill en tu biblioteca personal. Un chat dentro del Project seguirá viendo la versión antigua hasta que el Project se actualice. (De aquí sale la Regla 3.)
- No hay webhook ni notificación cuando alguien (tú u otro PO) edita una skill en claude.ai.

Hasta que Anthropic resuelva [anthropics/claude-code#20697](https://github.com/anthropics/claude-code/issues/20697), la disciplina de **"edita solo en claude.ai y respalda con `import-from-claude-ai.sh` desde un chat fuera del Project"** es lo que separa a quien tiene skills al día de quien acumula drift silencioso.
