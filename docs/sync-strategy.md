# Cómo saber si las skills están actualizadas

Una skill puede estar "desactualizada" en cuatro lugares distintos. Esta guía es honesta sobre **qué se puede automatizar y qué no**, y te da el workflow mínimo viable para no perder horas en esto.

## Los cuatro lugares donde puede haber drift

```
┌──────────────────────────────────────────────────────────┐
│ 1. GitHub origin/main         ← fuente de verdad        │
│ 2. Repo local clonado         ← lo que ves en tu disco  │
│ 3. ~/.claude/skills/ local    ← lo que usa Claude Code  │
│ 4. claude.ai biblioteca       ← lo que usa la web       │
└──────────────────────────────────────────────────────────┘
```

## Verificación automática (lo que `scripts/` resuelve)

| Drift entre... | Script | Resuelve drift |
|---|---|---|
| GitHub ↔ Repo local | `check-repo-status.sh` | Sí, automático |
| Repo local ↔ `~/.claude/skills/` | `check-drift.sh` | Sí, automático |
| Lo anterior + integridad SKILL.md | `doctor.sh` | Sí, automático |
| Repo ↔ claude.ai (web) | **No automatizable hoy** | Manual |

### Comandos que importan

```bash
# Antes de empezar a trabajar (¿hay cambios remotos? ¿algo sin pushear?)
bash scripts/check-repo-status.sh

# Después de un git pull o de editar skills (¿el local tiene lo que el repo tiene?)
bash scripts/check-drift.sh

# Antes de subir un ZIP a claude.ai (¿la skill que voy a subir es válida?)
bash scripts/doctor.sh
```

## Estrategia práctica para evitar drift (la que de verdad funciona)

### Regla 1 — Edita en local, nunca en claude.ai directamente

Si nunca tocas la skill en la interfaz web, el drift entre repo y claude.ai es imposible: solo se puede crear si dos fuentes editan independientemente.

Workflow:
1. Edita `skills/<nombre>/SKILL.md` en VSCode (o Cursor, lo que uses).
2. `git commit && git push`.
3. Si la skill se usa en claude.ai: `bash scripts/build-zips.sh`, arrastra el ZIP nuevo a claude.ai (Settings → Capabilities → Skills → la skill → Update).

### Regla 2 — Symlinks, no copias

Si `~/.claude/skills/` son symlinks al repo (lo que hace `install-symlinks.sh`), un `git pull` actualiza Claude Code y Desktop **automáticamente**. No hay drift posible entre repo local y `~/.claude/skills/`.

### Regla 3 — Auditoría manual de claude.ai una vez al mes

Como la API no permite listar/descargar tu biblioteca personal, la única forma fiable es:

1. Abre claude.ai → Settings → Capabilities → Skills.
2. Por cada skill, descarga el ZIP (botón de exportar) o copia el contenido.
3. Compara con `skills/<nombre>/SKILL.md` del repo (`diff` o herramienta visual).

Si lo haces el primer lunes de cada mes te lleva 15-20 minutos para 20 skills. Si tu disciplina con la Regla 1 es buena, normalmente saldrá todo limpio.

### Regla 4 — Spot check con Claude

En una conversación de claude.ai, pídele a Claude que muestre el contenido completo de una skill activa concreta. Compara con el repo. Útil cuando sospeches drift de una skill específica (p.ej. "esta skill antes hacía X y ya no").

```
Yo: Muéstrame el contenido completo del SKILL.md de la skill "actas-reinicia"
    tal como lo tienes cargado tú ahora mismo.
```

## Checklist mensual de salud de skills

- [ ] `cd repo && git pull --ff-only` — traer cambios remotos
- [ ] `bash scripts/check-repo-status.sh` — sin commits sin pushear
- [ ] `bash scripts/check-drift.sh` — repo y `~/.claude/skills/` alineados
- [ ] `bash scripts/doctor.sh` — todas las skills con frontmatter válido
- [ ] Auditoría visual de 1-2 skills críticas en claude.ai vs repo
- [ ] Si has añadido skill nueva, `bash scripts/build-zips.sh` y subida manual a claude.ai

## Lo que está fuera de tu alcance (y de momento del de cualquiera)

- Anthropic no expone API pública para listar/leer/escribir tu biblioteca de skills personal de claude.ai.
- Los Projects de claude.ai snapshotean las skills cuando se crean/actualizan; no se refrescan solos cuando tú actualizas la skill en tu biblioteca personal. Si editas la skill, el Project sigue viendo la versión antigua hasta que el Project se actualiza.
- No hay webhook ni notificación cuando alguien (tú u otro PO) edita una skill en claude.ai.

Hasta que Anthropic resuelva [anthropics/claude-code#20697](https://github.com/anthropics/claude-code/issues/20697), la disciplina de "edita en local primero" es lo que separa a quien tiene skills al día de quien acumula drift silencioso.
