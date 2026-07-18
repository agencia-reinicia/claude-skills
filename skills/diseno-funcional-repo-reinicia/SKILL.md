---
name: diseno-funcional-repo-reinicia
description: "Redacta el Diseño Funcional de un proyecto de código de Reinicia analizando el código fuente y las SPECS de un repositorio (repo de GitHub en Claude Code) y lo materializa, desde un único markdown, en tres salidas: (A) DF en markdown revisable, (B) .docx con marca Reinicia, y (C) webapp Vite de marca ejecutable desde terminal. Actívala cuando el PO pida 'genera el diseño funcional de este repo', 'analiza el código y las specs y redacta un DF', 'documenta funcionalmente este proyecto', 'DF a partir del código', 'diseño funcional del conector/plugin/widget'; en la fase docx con 'genera el docx del DF' o 'pásame el DF a docx de marca'; y en la fase webapp con 'convierte el DF en una webapp', 'monta la webapp Vite del DF con la marca de Reinicia' o 'sirve el DF como web desde terminal'. Cubre repos Deluge/Zoho, WordPress/PHP y React/widgets JS. NO usar para cerrar un SPIKE desde ClickUp (esa es spike-clickup-reinicia), ni para crear productos en ClickUp, ni para actas o análisis de llamada."
---

# Diseño Funcional a partir de repositorio — Reinicia

> **Versión vigente: v1.2 — 14/07/2026** · ver changelog al final (`## Versiones`)

## Propósito

Genera el **Diseño Funcional (DF)** de un desarrollo de Reinicia partiendo de lo que ya está implementado: el **código fuente** y las **SPECS** que viven en el repositorio. A diferencia de `spike-clickup-reinicia` (que sintetiza un DF desde el cierre de un SPIKE en ClickUp), aquí el origen es el propio repo.

Reutiliza la **estructura canónica de DF de Reinicia** (6 secciones) y el **pipeline docx de marca** de `marca-reinicia`. No los reinventa.

## Cuándo NO usar

- Cerrar un SPIKE y generar su DF desde ClickUp → `spike-clickup-reinicia`.
- Crear productos, tarjetas o SPIKEs en ClickUp → skills `productos-digitales-*`.
- Actas de reunión → `actas-reinicia`. Análisis de llamada → `analisis-llamadas-reinicia`.

---

## Arquitectura: un markdown, tres salidas

El markdown del DF es el **artefacto central y revisable**. Hay una **puerta de revisión humana** después de la Fase A; a partir del markdown ya validado se generan, según convenga, dos salidas de marca (puedes generar una, la otra, o ambas):

```
FASE A  (en el repo · Claude Code)
────────────────────────────────
Inventario repo + SPECS
Propuesta de alcance + gaps  ── PO valida
Redacta DF en markdown  ─────► [revisión del PO]
                                     │
        ┌────────────────────────────┴────────────────────────────┐
        ▼                                                          ▼
FASE B  (claude.ai / Cowork)                     FASE C  (Claude Code · terminal)
────────────────────────────                     ──────────────────────────────
.docx con marca Reinicia                         webapp Vite con marca Reinicia
(reutiliza marca-reinicia + skill docx;          (autosuficiente y offline: logo
 requiere logo Workdrive + Manrope embebida)      empaquetado + Manrope vía npm)
Documento formal para el cliente                 Presentación/consulta navegable
```

**Por qué entornos distintos:**
- La **Fase B** (`.docx`) necesita el logo de Workdrive, el skill `docx` y el embebido de Manrope → se hace en **claude.ai/Cowork**.
- La **Fase C** (webapp) es **autosuficiente**: el logo va empaquetado en la skill y Manrope se instala vía npm, así que corre **entera desde terminal** en Claude Code, sin MCP.

El puente entre fases es un **markdown autosuficiente**: su front-matter (incl. `idioma`) y sus 6 secciones bastan para generar cualquiera de las dos salidas sin tener el repo delante.

---

## FASE A — Análisis del repo y redacción del DF en markdown

Corre dentro del repositorio. Es de **solo lectura** sobre el código; lo único que escribe es el fichero markdown del DF.

### A0. Encuadre

Antes de analizar, confirma con el PO (infiere del repo lo que puedas y pregunta solo lo que falte):
- **Cliente** y **nombre del proyecto/producto** — condicionan convenciones y el nombre del fichero final; no arranques a ciegas si el cliente no está claro.
- **Idioma del Diseño Funcional** — **pregúntalo siempre de forma explícita**, no lo asumas. Por defecto **español** (estándar Reinicia); el alternante habitual es **inglés** (clientes internacionales, Amigos Reinicia, INEFSO LATAM). El idioma elegido se registra en el front-matter (`idioma`) y gobierna **tanto el markdown (Fase A) como el `.docx` (Fase B)**, para que ambos salgan coherentes.

### A1. Inventario del repo y de las SPECS

Hazte primero un mapa antes de leer a fondo: estructura de carpetas, perfil de lenguajes, puntos de entrada y manifiestos, y localización de las SPECS (README, `docs/`, contratos de API, tests, comentarios de cabecera).

Lee **`references/analisis-codigo-por-stack.md`** para el detalle de qué buscar y qué extraer:
- §1 Localizar SPECS · §2 Inventario inicial (ambos transversales).
- §3 Deluge/Zoho · §4 WordPress/PHP · §5 React/widgets JS (según el/los stack detectados; pueden convivir varios).
- §6 Integraciones y contratos entre piezas · §7 Señales de deuda técnica.

Principio clave: **las SPECS dicen la intención; el código dice la realidad.** Cuando difieran, documenta ambas y regístralo como *gap* para el PO — no asumas cuál gana. **No inventes** comportamiento, reglas de negocio ni riesgos que el código no respalde: cada afirmación funcional del DF debe poder rastrearse a un fichero o función real.

### A2. Propuesta de alcance + gaps (validación con el PO)

Patrón Reinicia de **propuesta antes de ejecutar**. Antes de redactar el DF completo, presenta al PO, de forma concisa:
1. **Qué has detectado:** stack(s), piezas principales, flujos e integraciones identificados.
2. **Alcance propuesto del DF:** qué vas a documentar (y qué queda fuera).
3. **Gaps y preguntas abiertas:** contradicciones SPEC↔código, supuestos sin confirmar, zonas del código ambiguas.

Espera una confirmación ("adelante") antes de escribir el DF. Los gaps que el PO no resuelva ahora se registran en el front-matter (`gaps_pendientes`) y, donde toque, dentro de las secciones.

### A3. Redacción del DF en markdown

Copia y rellena **`assets/plantilla-diseno-funcional.md`**. Es la estructura canónica:

- **Front-matter YAML (obligatorio):** `cliente`, `proyecto`, `idioma` (el confirmado en A0), `descripcion_corta` (para el nombre de fichero), `fecha`, `autor`, `stack`, `repo`, `commit`, `fuentes_analizadas` (rutas reales), `gaps_pendientes`. Es lo que la Fase B necesita para idioma, nombre, cabecera y trazabilidad.
- **6 secciones canónicas:**
  1. **Objetivo** — qué resuelve, en negocio, sin jerga.
  2. **Contexto y problemática** — situación de partida (anclada en repo/SPECS).
  3. **Análisis y propuesta** — flujos paso a paso, reglas de negocio, integraciones, casuística; cada punto rastreable al código.
  4. **Diseño técnico-funcional** — 4.1 Mapa de componentes · 4.2 Modelo de datos (módulos y campos API reales, lectura vs escritura).
  5. **Criterios de aceptación** — lista verificable "cuando X, el sistema hace Y".
  6. **Riesgos** — deuda técnica y riesgos reales, con impacto y mitigación.

Redacta en el **idioma confirmado en A0** (por defecto español), incluidos los títulos de sección; tono claro y directo, orientado a que lo entienda negocio en las secciones 1-2 y el equipo técnico en las 3-6. Las **claves** del front-matter se mantienen tal cual (son metadatos, no se traducen).

### A4. Entrega de la Fase A

- Guarda el markdown en el repo en una ruta razonable (por defecto `docs/diseno-funcional-[cliente].md`; propón la ruta y confirma si hay dudas). Recuerda al PO que **revise y haga commit** cuando esté conforme.
- Cierra indicando explícitamente que, sobre este markdown ya revisado, hay dos salidas de marca posibles: el **`.docx`** (Fase B, en claude.ai/Cowork) y/o la **webapp Vite** (Fase C, desde terminal en Claude Code). No intentes generar el `.docx` dentro del repo; la webapp sí se genera aquí.

---

## FASE B — Generación del `.docx` de marca (en claude.ai / Cowork)

Se dispara cuando el PO, ya de vuelta en claude.ai/Cowork, aporta el markdown revisado y pide el documento ("genera el docx del DF", "pásalo a docx de marca").

Lee **`references/generacion-docx-marca.md`** y síguela. En resumen:
1. Parsea el front-matter del markdown; consulta `marca-reinicia`; extrae el logo real y prepara Manrope para embebido.
2. Construye el `.docx` con los patrones de `marca-reinicia` y el skill público `docx` (cabecera corporativa, tipografía, tablas con bordes blancos y anchos **DXA absolutos** sumando 9602 twips —nunca porcentaje—, cuerpo limpio). Estructura = las 6 secciones, con **títulos y contenido en el `idioma` del front-matter** (el markdown ya viene en ese idioma; respétalo).
3. Nombre: `YYYYMMDD-Diseno-Funcional-[descripcion_corta]-[CLIENTE].docx`.
4. Valida: `patch_fonts.py` → `validate.py` → `pdffonts` (Manrope `emb=yes`) + revisión visual.
5. Copia a `/mnt/user-data/outputs/` y entrega con `present_files`.
6. Recuerda el flujo Opción C (subir a Workdrive → convertir a Zoho Writer).

Si en el entorno no hay logo/fuentes de marca, dilo y no generes un documento "casi de marca": el DF de marca requiere logo real y Manrope embebida.

---

## FASE C — Webapp Vite de marca desde terminal (en Claude Code)

Alternativa (o complemento) a la Fase B. Convierte el markdown revisado en una **webapp Vite** con marca Reinicia, **ejecutable entera desde terminal**. Se dispara cuando el PO pide "monta la webapp del DF", "conviértelo en web con la marca de Reinicia", "quiero servir/ejecutar el DF como web desde terminal".

**Es autosuficiente:** el logo real va empaquetado en la skill y Manrope se instala vía npm, así que **no necesita MCP de Workdrive ni el skill `docx`**. Solo Node + acceso a npm.

Lee **`references/generacion-webapp-vite.md`** para el detalle. Flujo desde la raíz del repo:

```bash
node ~/.claude/skills/diseno-funcional-repo-reinicia/scripts/generar-webapp.mjs \
  docs/diseno-funcional-<cliente>.md --out df-webapp
cd df-webapp && npm install && npm run dev     # o npm run build para dist/ estático
```

El generador (sin dependencias) copia la plantilla `assets/webapp-vite/`, inyecta el markdown y fija el título desde el front-matter. La webapp toma la ficha de metadatos y el idioma del front-matter, construye el índice desde los H2/H3 y renderiza las 6 secciones con la paleta, tipografía y patrones de tabla de `marca-reinicia`. Es una salida de **presentación/consulta**; no sustituye al `.docx` cuando el cliente pide documento formal.

---

## Principios transversales

- **No inventar.** Todo lo funcional se rastrea al código/SPECS. Lo que no se pueda confirmar es un *gap*, no una afirmación.
- **Propuesta antes de ejecutar** (A2): valida alcance y gaps con el PO antes de redactar el DF, y el PO revisa el markdown antes del `.docx`.
- **Trazabilidad.** Cita ficheros/funciones en las secciones 3-4; lista `fuentes_analizadas` y `commit` en el front-matter.
- **Reutiliza, no dupliques.** La estructura del DF y el pipeline docx son de Reinicia (`spike-clickup-reinicia` / `marca-reinicia`); esta skill los aplica al origen "repositorio".
- **Idioma** confirmado con el PO en A0 (por defecto español; inglés como alternante habitual), **coherente entre el markdown y el `.docx`**, junto con las convenciones de marca de Reinicia en todo el output cara a cliente.

---

## Ficheros de la skill

- `assets/plantilla-diseno-funcional.md` — plantilla canónica del DF en markdown (front-matter + 6 secciones). Cópiala y rellénala en A3.
- `assets/webapp-vite/` — plantilla del proyecto Vite de marca Reinicia (logo real empaquetado, tokens de marca en `src/style.css`, render con `marked`). Base de la Fase C.
- `scripts/generar-webapp.mjs` — generador sin dependencias que convierte el markdown del DF en la webapp Vite lista para `npm install`. Se usa en la Fase C.
- `references/analisis-codigo-por-stack.md` — qué leer y extraer por stack (Deluge/Zoho, WordPress/PHP, React/widgets JS), cómo localizar SPECS y señales de riesgo. Consúltala en A1.
- `references/generacion-docx-marca.md` — orquestación de la Fase B reutilizando `marca-reinicia` + skill `docx`. Consúltala en Fase B.
- `references/generacion-webapp-vite.md` — flujo de terminal, estructura de la plantilla y mantenimiento de marca de la webapp. Consúltala en Fase C.

---

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0 | 14/07/2026 | Néstor + Claude | Creación. Flujo de dos fases (markdown revisable en el repo vía Claude Code → .docx de marca en claude.ai/Cowork). Reutiliza la estructura canónica de DF (6 secciones) y el pipeline docx de `marca-reinicia`. Referencias de análisis por stack (Deluge/Zoho, WordPress/PHP, React/widgets JS) y de generación docx; plantilla markdown con front-matter para el puente entre fases. |
| v1.1 | 14/07/2026 | Néstor + Claude | **Idioma como elicitación explícita en A0** (por defecto español; inglés como alternante habitual). Nuevo campo `idioma` en el front-matter que gobierna markdown (Fase A) y `.docx` (Fase B) de forma coherente; propagado a la plantilla, a la redacción (A3), a la Fase B (render en el idioma, con nota de que el token del nombre de fichero no se traduce) y a los principios. Corregido typo "Encradre" → "Encuadre". |
| v1.2 | 14/07/2026 | Néstor + Claude | **Fase C — webapp Vite de marca ejecutable desde terminal** (Claude Code), como salida alternativa/complementaria al `.docx` desde el mismo markdown. Autosuficiente y offline: logo oficial (741×138) empaquetado en `assets/webapp-vite/public/` y Manrope vía `@fontsource/manrope`; sin MCP. Nueva plantilla Vite (`assets/webapp-vite/`) con tokens de `marca-reinicia` en `src/style.css` (cabecera + filete azul, ficha de metadatos lila, TOC, tablas cabecera lila/bordes blancos/filas alternas, H2 con filete azul, listas de tareas), generador sin dependencias `scripts/generar-webapp.mjs` (idempotente, resuelve su ruta vía `import.meta.url`) y referencia `references/generacion-webapp-vite.md`. Arquitectura reescrita a "un markdown, tres salidas"; descripción ampliada con triggers de webapp/terminal. Validado end-to-end: generar → `npm install` → `npm run build` + captura de marca. |
