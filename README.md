# claude-skills — Reinicia

Skills de Reinicia versionadas como **fuente única de verdad** para todas las herramientas de Claude (Claude Code, Claude Desktop, claude.ai).

## Por qué este repo existe

A día de hoy (mayo 2026), **Anthropic no sincroniza skills entre claude.ai y Claude Code de forma nativa**. Hay un issue abierto pidiéndolo ([anthropics/claude-code#20697](https://github.com/anthropics/claude-code/issues/20697)), pero hasta que llegue, cada herramienta guarda skills en sitios distintos:

- **claude.ai** → en la nube, sin acceso a sistema de ficheros.
- **Claude Code** → `~/.claude/skills/` (global) o `.claude/skills/` (por proyecto).
- **Claude Desktop** → `~/.claude/skills/` (compartido con Claude Code).
- **Codex / OpenCode / otros agentes** → cada uno con su carpeta.

Este repo resuelve el problema **donde se puede resolver** (Claude Code, Desktop, agentes terceros que respetan el estándar Agent Skills) y deja claro **dónde sigue siendo manual** (claude.ai).

## Contenido

20 skills (May 2026):

- **Productos digitales** (3): Zoho, Web, WABA en ClickUp
- **Diagramas Miro** (3): árbol navegación web, diagramas Zoho, flujograma WABA
- **Sprint operativo** (4): sprint planning, revisión sprint backlog, informes ejecutivos, plan de proyecto
- **Soporte y comercial** (3): soporte por correo, soporte por formulario, propuesta comercial Zoho CRM
- **Documentación** (3): actas, análisis de llamadas, nomenclatura
- **Skills auxiliares** (3): marca Reinicia, formato tarjeta ClickUp, SPIKE ClickUp
- **Meta** (1): skill-creator (skill nativa de Anthropic para crear y mejorar skills)

Cada skill es una carpeta con su `SKILL.md` siguiendo el estándar [Agent Skills](https://agentskills.io/). `skill-creator` además incluye `agents/`, `scripts/`, `references/` y `eval-viewer/` como assets auxiliares.

## ¿Cómo sé si las skills están actualizadas?

Lee [`docs/sync-strategy.md`](docs/sync-strategy.md) — explica los 4 lugares donde puede haber drift y qué automatizar vs qué seguirá siendo manual hasta que Anthropic resuelva el sync nativo.

Comandos rápidos:
- `bash scripts/check-repo-status.sh` — repo local vs origin
- `bash scripts/check-drift.sh` — repo vs `~/.claude/skills/`
- `bash scripts/doctor.sh` — integridad de SKILL.md

## Instalación rápida — Claude Code

### Opción A — Skills globales (recomendado)

Disponibles en cualquier proyecto de Claude Code:

```bash
# Clonar el repo en una carpeta de trabajo
git clone https://github.com/agencia-reinicia/claude-skills.git ~/repos/claude-skills

# Symlink de cada skill a ~/.claude/skills/
mkdir -p ~/.claude/skills
for dir in ~/repos/claude-skills/skills/*/; do
  ln -sfn "$dir" ~/.claude/skills/$(basename "$dir")
done

# Verificar
ls -la ~/.claude/skills/
```

A partir de ahora, cualquier `git pull` en `~/repos/claude-skills` actualiza automáticamente las skills en Claude Code (los symlinks apuntan al repo).

### Opción B — Skills de proyecto

Solo para un proyecto concreto:

```bash
cd /tu/proyecto
git submodule add https://github.com/agencia-reinicia/claude-skills.git .claude-skills
ln -s .claude-skills/skills .claude/skills
```

## Subida a claude.ai (manual, por limitación de Anthropic)

Hoy no existe API pública para subir skills a tu biblioteca personal de claude.ai. Workflow:

1. Edita la skill en local.
2. `git commit && git push` al repo.
3. Empaqueta la skill en ZIP: `cd skills && zip -r nombre-skill.zip nombre-skill/`
4. claude.ai → Settings → Capabilities → Skills → Upload skill → arrastra el ZIP.

El script `scripts/build-zips.sh` genera los 19 ZIPs listos para arrastrar.

## Workflow recomendado (single source of truth)

```
              ┌──────────────────────────────┐
              │  agencia-reinicia/           │
              │    claude-skills (GitHub)    │
              │  ◄── fuente de verdad ──►    │
              └──────────────┬───────────────┘
                             │ git pull / push
                ┌────────────┼────────────┐
                ▼            ▼            ▼
        ┌──────────┐  ┌──────────┐  ┌──────────┐
        │ Claude   │  │ Claude   │  │ ZIPs     │
        │ Code     │  │ Desktop  │  │ → upload │
        │ (auto)   │  │ (auto)   │  │ a        │
        │          │  │          │  │ claude.ai│
        └──────────┘  └──────────┘  └──────────┘
```

**Regla de oro:** edita siempre en local → commit → push. Si editas en claude.ai por comodidad, descarga la skill editada y haz commit antes de tocar nada en local, para no crear "skill drift".

## Estructura del repo

```
claude-skills/
├── README.md                       # este fichero
├── docs/
│   └── sync-strategy.md            # cómo evitar y detectar drift
├── scripts/
│   ├── install-symlinks.sh         # crea symlinks en ~/.claude/skills/
│   ├── build-zips.sh               # genera ZIPs listos para claude.ai
│   ├── doctor.sh                   # verifica integridad (SKILL.md presente, frontmatter válido)
│   ├── check-drift.sh              # detecta drift entre repo y ~/.claude/skills/
│   └── check-repo-status.sh        # detecta drift entre repo local y origin
└── skills/
    ├── actas-reinicia/SKILL.md
    ├── analisis-llamadas-reinicia/SKILL.md
    ├── ... (17 más)
    ├── sprint-planning-reinicia/SKILL.md
    └── skill-creator/              # skill nativa con agents, scripts, references
        ├── SKILL.md
        ├── LICENSE.txt
        ├── agents/
        ├── assets/
        ├── eval-viewer/
        ├── references/
        └── scripts/
```

## Mantenimiento

- Una skill nueva → carpeta nueva en `skills/` con su `SKILL.md`. Commit + push.
- Edición de skill existente → editar en local, commit + push, resubir ZIP a claude.ai si esa skill se usa allí.
- Skills nativas de Anthropic (`docx`, `pdf`, `pptx`, `xlsx`, etc.) **no se versionan aquí** — vienen precargadas en el sandbox de claude.ai y se mantienen automáticamente.

## Licencia

Uso interno de Reinicia. No redistribuir sin autorización.
