# Fase C — Webapp Vite de marca desde terminal (Claude Code)

Convierte el markdown del Diseño Funcional en una **webapp Vite** con marca Reinicia, **100 % ejecutable desde terminal** en Claude Code. Es una **alternativa a la Fase B** (`.docx`): salida navegable en el navegador en lugar de documento ofimático.

**Por qué es autosuficiente (a diferencia del `.docx`):** Manrope se instala vía npm (`@fontsource/manrope`) y el logo real va **empaquetado** en la skill (`assets/webapp-vite/public/logo-reinicia.png`, extraído de Workdrive, nunca sintético). No necesita MCP de Workdrive ni el skill `docx`. Solo requiere Node y acceso a npm.

## Qué genera

Un proyecto Vite en la carpeta de salida con:
- Cabecera corporativa (logo real izquierda · nombre de fichero derecha · filete azul `#3812CF` debajo).
- Ficha de metadatos (desde el front-matter: cliente, proyecto, fecha, stack, repo/commit, idioma).
- Índice (TOC) lateral pegajoso construido desde los H2/H3.
- Las 6 secciones renderizadas con la paleta y tipografía de marca: tablas con cabecera lila `#D9D0FB`, bordes blancos y filas alternas; H2 con filete azul; cuerpo `#545454`; enlaces/acentos azules; listas de tareas (criterios de aceptación) con checkbox.
- Manrope (300/400/700) empaquetada → render de marca **offline**.

El idioma de la interfaz se toma del `idioma` del front-matter; el contenido ya viene en ese idioma desde la Fase A.

## Flujo desde terminal

Desde la raíz del repo, con el markdown del DF ya revisado (p. ej. `docs/diseno-funcional-<cliente>.md`):

```bash
# 1) Generar la webapp (el script vive dentro de la skill)
node ~/.claude/skills/diseno-funcional-repo-reinicia/scripts/generar-webapp.mjs \
  docs/diseno-funcional-<cliente>.md --out df-webapp

# 2) Instalar y arrancar
cd df-webapp
npm install
npm run dev        # servidor local con recarga en caliente
# o, para desplegar:
npm run build      # genera dist/ estático (base relativa, portable)
npm run preview    # sirve el dist/ para revisarlo
```

`generar-webapp.mjs` **no tiene dependencias** (corre antes de `npm install`): copia la plantilla `assets/webapp-vite/`, inyecta el markdown en `src/diseno-funcional.md` y ajusta el `<title>` desde el front-matter. Es idempotente: relanzarlo regenera la carpeta.

> Ruta del script: se resuelve sola vía `import.meta.url`, así que funciona esté la skill symlinkeada en `~/.claude/skills/` (estándar Reinicia) o dentro del `.claude/skills/` del repo. Si dudas de la ruta, localízala: `find ~ -path '*diseno-funcional-repo-reinicia/scripts/generar-webapp.mjs' 2>/dev/null`.

## Estructura de la plantilla (`assets/webapp-vite/`)

- `package.json` — vite + marked + js-yaml + @fontsource/manrope.
- `vite.config.js` — `base: "./"` para que el `dist/` sea portable.
- `index.html` — punto de montaje.
- `src/main.js` — separa front-matter (YAML) del cuerpo, renderiza con `marked`, construye ficha y TOC, aplica la marca.
- `src/style.css` — **tokens canónicos de `marca-reinicia`** (paleta, tipografía, patrones de tabla). Fuente de verdad visual de la webapp.
- `src/diseno-funcional.md` — el DF (lo sustituye el generador).
- `public/logo-reinicia.png` — logo oficial (741×138).

## Mantenimiento de marca

Los valores visuales de `src/style.css` deben permanecer alineados con `marca-reinicia`. Si la marca cambia (paleta, tipografía, logo), actualiza:
1. `src/style.css` (variables `--*`).
2. `public/logo-reinicia.png` si cambia el logo.
No inventes colores fuera de la paleta canónica.

## Notas

- Si `npm install` no tiene red, la webapp no se puede construir; avísalo (no hay fallback offline sin las dependencias).
- La webapp es una salida de **presentación/consulta** del DF; no sustituye al `.docx` cuando el cliente pide documento formal. Puedes generar ambos (B y C) desde el mismo markdown.
- Para publicarla, el `dist/` es estático: sirve en cualquier hosting o dentro de una web existente (base relativa).
