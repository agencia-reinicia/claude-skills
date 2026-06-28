---
name: plan-proyecto-reinicia-modo-desatendido
description: >
  Versión desatendida (cloud) de plan-proyecto-zoho-sheet-reinicia para Claude Code Routines. NO
  crea Planes de Proyecto ni decide su estructura: es una skill de MANTENIMIENTO que asume que el
  fichero Plan de Proyecto v2 ya existe y lo reconcilia sprint a sprint. Vuelca de ClickUp al Sheet
  PBI, Tipo, Entregable, Descripción, Fecha de entrega (due_date), Notas Reinicia, Estatus y
  calendario; empuja del Sheet a ClickUp la Fecha de validación (subtarea Validación Cliente) y las
  Notas del Cliente. Si el PBI o la Épica de negocio faltan, Claude los rellena y avisa al PO.
  Genera las Ideas de la ronda dominical. Es troceada, idempotente y reanudable. Al terminar reporta
  como comentario en el producto Gestión [CLIENTE] de ClickUp (NO en Cliq). Actívala SOLO en la
  Routine programada o cuando un humano pida "ejecuta la reconciliación desatendida del plan de
  [CLIENTE]". Para creación o edición supervisada, usa la hermana plan-proyecto-zoho-sheet-reinicia.
---

# SKILL: Plan de Proyecto — Modo Desatendido (Reconciliación) — Reinicia

> **Versión vigente: v0.9 (esqueleto) — 2026-06-28**

> ⚠️ **VERSIÓN ESQUELETO v0.4.** Respecto a v0.3, corrige la clasificación de campos según la
> aclaración del PO: desaparece la "lista negra pura"; el modelo es ClickUp→Sheet / Sheet→ClickUp /
> Generado por Claude. La Fecha de entrega esperada es el due_date de ClickUp (se vuelca). El
> semáforo es un desplegable con formato asociado al valor. Pendiente solo el calibrado de 1ª pasada.

---

## Propósito

Mantener sincronizado, sin intervención humana, el **Plan de Proyecto v2** (Zoho Sheet) con el
backlog de ClickUp, sprint a sprint, **sin romper estructura ni identidad visual**, generando las
Ideas de la ronda y sincronizando en ambos sentidos lo que corresponde. NO crea el plan ni decide
su arquitectura (eso es la supervisada en CREACIÓN).

---

## RELACIÓN CON OTRAS SKILLS

```
plan-proyecto-zoho-sheet-reinicia (CREACIÓN, supervisada)   ← crea el fichero v2 desde cero
  ↓ (produce el fichero v2 que esta skill mantiene)
plan-proyecto-reinicia-modo-desatendido (ESTA skill)        ← reconcilia + Ideas + sync, sprint a sprint
  ↓
Producto Gestión [CLIENTE] en ClickUp (reporte + nota al PO)
```

**Precondición crítica:** el fichero v2 ya existe. Si no, **no crea nada**: lo reporta como omitido (PASO 1).

---

## ÁMBITO DEL PILOTO

| Proyecto | Fichero v2 | Estado |
|---|---|---|
| **Líder System** | lo crea la 1ª pasada (creación desatendida) | **Activo** en la Routine |
| **Carritech** | lo crea la 1ª pasada (creación desatendida) | Se añade a las rutinas tras Líder System |
| **Breezom** | lo crea la 1ª pasada (creación desatendida) | Se añade a las rutinas tras Líder System |

Ejecución: Claude Code Routine. **Modelo: Sonnet 4.6.** Los 3 ficheros los crea la propia skill en
su 1ª pasada (creación desatendida); no requieren creación supervisada previa. Arranque escalonado:
primero **Líder System**; luego se añaden **Carritech** y **Breezom** a las rutinas. Cliente como
parámetro (sin hardcode).
Plantilla canónica v2: `pnync351d56992b6d4026906a6fec5d56e682`.

---

## ESTRUCTURA CANÓNICA DEL PLAN v2 (leída de la plantilla)

### Pestañas (worksheet_id reales)
`36#` Portada · `40#` **Plan Proyecto** (cara cliente) · `41#` **Plan Proyecto Interno** ·
`42#` **Ideas** · `45#` Objetivos Cliente (lectura, priorización) · `43#` Log Cambios (solo añadir) ·
`44#` Config. La desatendida escribe en 40#, 41# y 42#.

### Tablas dentro de 40#/41#
Tres por pestaña: **PLAN IMPLEMENTACIÓN · ACTIVO · CERRADO**. Cabecera de tabla en **fila 8** (no
fila 1). Filas 3–5 = leyenda de hitos; fila 7 = meses; fila 8 = nº de semana.

### ⚠️ MAPA DE COLUMNAS — LAS DOS PESTAÑAS DIFIEREN (leer cabecera por pestaña, NUNCA hardcodear)

**`40#` Plan Proyecto (cara cliente):**
| col | Campo | Flujo |
|---|---|---|
| 2 | Épica (agrupación: plataforma/fase) | Derivada consistente con el fichero (NO objetivo de negocio; NO del ÉPICA funnel). Filas nuevas: Claude la deriva del tipo/plataforma. |
| 3 | Tipo Producto | ⬜ ClickUp → Sheet |
| 4 | Mes | Derivado = **mes de la Fecha de entrega** (col 8). Recomputar al cambiar la fecha. |
| 5 | PBI de Primer Nivel | ⬜ ClickUp → Sheet; si vacío en ClickUp → Claude rellena en Sheet+ClickUp + nota PO |
| 6 | Entregable | ⬜ ClickUp → Sheet (nombre de tarea) |
| 7 | Descripción | ⬜ ClickUp → Sheet (formato historia/resumen) |
| 8 | **Fecha de entrega esperada** | ⬜ **ClickUp → Sheet (due_date)** |
| 9 | **Fecha de validación esperada** | 🔼 **Sheet → ClickUp** (Cliente edita en Sheet → subtarea Validación Cliente) |
| 10 | Notas Reinicia | ⬜ ClickUp → Sheet (operativa automática: ratios + riesgos) |
| 11 | **Notas [NombreCliente]** | 🔼 **Sheet → ClickUp** (Cliente escribe; nunca pisar; leer e informar en ClickUp) |
| 12 | Estatus | ⬜ ClickUp → Sheet (desplegable; color automático) |
| 13+ | Calendario (semanas) | Generado de las fechas del Sheet (col 8 due_date + col 9 validación) |

**`41#` Plan Proyecto Interno** (igual hasta col 9; luego CAMBIA):
| col | Campo | Flujo |
|---|---|---|
| 2–9 | igual que 40# | igual |
| 10 | Notas (una sola) | ⬜ ClickUp → Sheet (operativa) |
| 11 | Estatus | ⬜ ClickUp → Sheet (desplegable; color automático) |
| 12+ | Calendario | Generado |

> ⚠️ Estatus = col 12 (40#) / col 11 (41#); calendario desde col 13 (40#) / col 12 (41#). Resolver
> por nombre leyendo la cabecera de cada pestaña. `41#` no tiene "Notas [Cliente]".

---

## MODELO DE SINCRONIZACIÓN (tres flujos, no hay "lista negra pura")

- **⬜ ClickUp → Sheet** (ClickUp manda; si difiere, se actualiza el Sheet): Tipo, PBI, Entregable,
  Descripción, **Fecha de entrega (due_date)**, Notas Reinicia/Notas, Estatus, calendario.
- **🔼 Sheet → ClickUp** (origen en el Sheet, se propaga a ClickUp; nunca se pisa la celda del Sheet):
  - **Fecha de validación esperada** (col 9) → fecha de la subtarea "Validación Cliente" en ClickUp.
  - **Notas [Cliente]** (col 11, solo 40#) → informar en ClickUp (🚧 mecanismo: comentario en la
    tarea del producto en `General [CLIENTE]`; confirmar en 1ª pasada).
- **🟪 Generado por Claude** (criterio, + nota PO): **PBI** (col 5) cuando falta en ClickUp. La
  **Épica** (col 2) NO es objetivo de negocio: es la agrupación que ya usa el fichero (plataforma/
  fase); en filas nuevas Claude la deriva consistente con el resto, sin inventar.

> **Reflejo completo (no solo divergencias):** en CADA fila que se lee de ClickUp, refrescar TODOS
> los campos de lista blanca (Tipo, Entregable, Descripción, Notas Reinicia, Estatus, Fecha de
> entrega), no solo las celdas que cambiaron. **Backfill inicial troceado** para filas antiguas con
> lista blanca incompleta (p. ej. Tipo de Producto vacío).
> **due_date null** → escribir **"A definir"** en col 8 (no vaciar) y calendario en blanco.
> **Al cambiar la fecha de entrega**, recomputar col 4 "Mes" (= mes de col 8) y la marca de calendario.
> Sin divergencia con la supervisada en la fecha de entrega: ambas la actualizan desde el due_date.

---

## IDENTIDAD VISUAL — INVARIANTES A PRESERVAR

- Cabecera de tabla: `fill #3812CF` · `font #FFFFFF` · negrita · center/middle · alto 36 · wrap.
- Banding datos: par `#FFFFFF` / impar `#EBEBEB` · alto 60 · valign top.
- Zona calendario: `fill #EBEBEB` · negrita · `font #3812CF` · center/middle.
- **Estatus = desplegable con formato asociado al valor** → escribir solo el texto exacto del
  desplegable y el color sale solo (TERMINADO verde · EN PROCESO amarillo · PENDIENTE lila ·
  POSPUESTO gris · PARKING/CANCELADO según desplegable). No reaplicar color nunca.
- Hitos Gantt: entrega Reinicia `#70EED6` ("Azul Claro Reinicia") · validación Cliente `#EBE31B`
  ("Amarillo Claro Reinicia"). Leyenda en filas 3–5.
- Bordes blancos `#FFFFFF` sólidos en todas las pestañas.
- Log Cambios: cabecera `#3812CF`/`#FFFFFF`; fila 2 `#D9D0FB`/`#555555` itálica. **Filas de datos nuevas: fill `#EBEBEB` (NUNCA blanco — sobre blanco los bordes blancos no se ven) + bordes blancos `#FFFFFF` sólidos + Manrope, sin banding.** Lavado base blanco.
- Fuentes Manrope. Azul de marca `#3812CF` (no `#3812CB`).

---

## REGLAS DE ESCRITURA SEGURA

1. **Nunca `range.content.clear`** (resetea formato). Vaciar con `" "`, nunca `""` (error 2831).
2. **No pisar fill/font de cabecera** (solo `font_name="Manrope"` seguro sobre ella).
3. **`cells.content.set` plural, lotes ≤40.** Decimal con coma. Nunca `csvdata.set` para nº con coma.
4. **Estatus = valor exacto del desplegable** (PENDIENTE · EN PROCESO · TERMINADO · POSPUESTO ·
   PARKING · CANCELADO / EN). El color es automático por el desplegable; no tocar formato.
5. **Inserción de filas (§8):** insertar las necesarias ANTES de la penúltima fila del cuerpo (hereda
   formato + desplegable); luego pegar. Una fila por llamada a `ZohoSheet_insert_row`. **Recalcular
   índices** de tablas inferiores y revisar Gantt/hitos.
6. **Índices de Estatus/calendario por cabecera leída** (difiere entre 40# y 41#).
7. **No pisar nunca** col 8 (¡sí se actualiza desde ClickUp!) — matiz: col 8 SÍ se escribe (due_date);
   las que NO se pisan son col 9 y col 11 (origen Cliente, solo lectura→push a ClickUp).
8. **Log Cambios:** solo añadir al final **y dar formato a las filas nuevas** (fill `#EBEBEB` — NUNCA blanco —, bordes blancos `#FFFFFF` sólidos, Manrope; sin banding) — no dejarlas sin formato. **No `Create_New_File`.**

---

## REGLA DE PBI VACÍO (criterio autónomo)

Por fila: leer ClickUp. Campo con valor → sincronizar Sheet (gana ClickUp; nunca pisar ClickUp).
**PBI** vacío en ClickUp → Claude escribe PBI afinado en Sheet **y** ClickUp + nota PO. **Épica**
(col 2) vacía → Claude la deriva de la plataforma/tipo, consistente con el fichero (no objetivo de
negocio; no toca ClickUp). Idempotente.

---

## GENERACIÓN DE IDEAS (pestaña 42#) — §9, dentro del alcance desatendido

- **Cadencia:** una ronda por ejecución de la **Routine dominical**. ≤ **7 ideas nuevas** por ronda.
- **5 fuentes** (tope **2–3 por fuente**): actas · notas de Gestión · histórico de productos
  (General+Soporte) · referencias de internet sobre Zoho · proyectos similares de Reinicia en ClickUp.
- **Objetivos Cliente (45#)** NO es fuente: se LEE como criterio de priorización. No se genera ni modifica.
- **Excedentes** (>7): Estatus Plan = "Pendiente Incluir" (la pestaña acumula histórico).
- **Trazabilidad (col Notas de Ideas):** autoría Claude · fuente · URLs · "porqué" de una línea (si es
  proyecto similar, enlazar la tarea ClickUp de referencia).

---

## FLUJO

### PASO 0 — Parámetros
Cliente(s) (piloto: Líder System) · sprint vigente · presupuesto de troceo (🚧 calibrar) · Sonnet 4.6.

### PASO 1 — Precondiciones
Existe el fichero v2 · `worksheet.list` para ids · **leer cabecera (fila 8) de 40# y 41#** y mapear
columnas por nombre. Si no existe → **omitido** y siguiente.

> **Si falta el fichero v2 → CREAR (modo CREACIÓN desatendido, sección dedicada).** Activo en el
> piloto. La rama de "omitir" queda obsoleta.

### PASO 2 — Reanudación
Primera fila pendiente por el contenido de la columna PBI. 🚧 criterio exacto a definir.

### PASO 3 — Reconciliación fila a fila (hasta agotar troceo)
- Leer tarjeta ClickUp (campos, subtareas, comentarios, checklist, due_date, subtarea Validación Cliente).
- **Reflejo completo** de la lista blanca en CADA fila (no solo divergencias); 🔼 Sheet→ClickUp (validación + notas Cliente); 🟪 PBI vacío → generar; **recomputar Mes y marca de calendario** al cambiar la fecha.
- Construir Notas Reinicia/Notas (ratios + riesgos ⚠️). (Re)dibujar calendario de cols 8/9 con colores de hito.
- **Insertar filas (§8)** si falta espacio, ANTES de pegar. Persistir en lotes ≤40.

### PASO 4 — Ideas (solo Routine dominical)
≤7 ideas nuevas en 42# con trazabilidad y priorización por Objetivos (45#).

### PASO 5 — Cierre y reporte en ClickUp (NO Cliq)
Comentario en `Gestión [CLIENTE]`: filas reconciliadas · PBIs/Épicas escritos por Claude (validar) ·
validaciones sincronizadas · notas de Cliente informadas · ideas nuevas · omitidos · punto de reanudación.
- **Comentarios ClickUp:** texto plano, sin markdown ni hipervínculos; descripción + URL en línea aparte.
- **Divergencia intencional** vs. hermanas (Cliq): aquí a ClickUp por decisión del PO.

---

## CREACIÓN DESATENDIDA (modo activo del piloto)

Si en el PASO 1 falta el fichero v2, la skill **lo crea** sin intervención humana y deja al PO el
comentario para revisar. Reglas deterministas que sustituyen la elicitación supervisada:

1. **Guardia anti-duplicados (NO negociable):** antes de crear, comprobar por convención de nombre
   que NO existe ya un Plan v2 del cliente. Si existe (aunque con nombre algo distinto), NO crear:
   reconciliar el existente.
2. **Copiar la plantilla canónica** (`ZohoSheet_copy` de `pnync351…`; nunca `Create_New_File`).
   Verificar status=1 y sin `%3A`.
3. **Idioma:** **inferido** del cliente (ClickUp/CRM/Workdrive: ES para clientes españoles, EN para
   internacionales). Dejarlo anotado en el comentario ("creado en ES porque…") para que el PO lo corrija.
4. **Granularidad del calendario:** **default = quincenas** (recomendado en la supervisada), salvo
   config explícita del cliente.
5. **Reflejar ClickUp** (lista blanca) en las filas, con la regla de inserción §8.
6. **Criterio propuesto y marcado:** Épica de negocio, formato de Descripción, alcance histórico y
   portada los **propone Claude**; el fichero se marca **BORRADOR pendiente de validación PO**.
7. **Nota consolidada al PO en Gestión:** "Plan de [CLIENTE] creado en borrador en [idioma],
   granularidad [X]; valida estos N puntos de criterio".

> **Mejora opcional (no bloqueante):** un almacén de configuración por cliente para idioma/
> granularidad/formato/alcance atípicos. Mientras no exista, se usa inferencia + defaults.

---

## INPUTS / OUTPUT

**Inputs:** fichero v2 (40#/41#/42#/45#/43#) · plantilla `pnync351…` · tarjetas `General [CLIENTE]`
(campos + subtarea Validación Cliente + due_date) · actas/Gestión/histórico/proyectos similares (Ideas) ·
`Gestión [CLIENTE]` (reporte).

**Output:** 40#/41# reconciliadas sin romper formato · due_date volcado a col 8 · validación y notas
de Cliente empujadas a ClickUp · Épica/PBI vacíos rellenados · ≤7 ideas en 42# · comentario en Gestión.

---

## RECURSOS CLAVE

- **Pestañas v2:** 36# Portada · 40# Plan Proyecto · 41# Plan Proyecto Interno · 42# Ideas ·
  45# Objetivos Cliente · 43# Log Cambios · 44# Config.
- **IDs ClickUp (General LS `211763746`):** PBI `6758065a-bd4f-4d7d-9a48-926e81fe343f` · TIPO
  `5bd9072e-deae-4352-b35b-bdbaa3cc216d` · ÉPICA funnel (NO para Épica de negocio)
  `6e3bf4c0-354b-4a8c-8cb5-dbedeec1cf6e` · ORDEN `a2fac0a6-0f12-4c9b-9f2f-c5bbc2aa7a98`.
  Gestión LS `211763776`. Verificar custom fields si el cliente no es Carritech/LS.
- **Marca:** `#3812CF` · `#D9D0FB` · `#EBEBEB` · `#545454` · hitos `#70EED6` / `#EBE31B` · `#FFFFFF` · Manrope.

---

## LIMITACIONES TÉCNICAS

1. `clickup_get_task` con campos ~15k tokens → skill troceada.
2. Sin API directa de ClickUp desde bash → solo MCP (en Routines).
3. Zoho Sheet: `set_content_to_multiple_cells` ~50 máx (30–40); celda <~200 chars; decimal coma; vaciar con `" "`.
4. Comentarios ClickUp: texto plano.
5. Roll-back: Historial de versiones de Zoho Sheet + Log de Cambios.

---

## VERSIONES

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v0.1** | 2026-06-28 | Néstor + Claude | Esqueleto: mantenimiento; reconciliación por campo; PBI vacío; idempotente; reporte a Gestión; piloto Sonnet 4.6 LS. |
| **v0.2** | 2026-06-28 | Néstor + Claude | Estructura + identidad visual + reglas de escritura segura; 5 decisiones PO formalizadas. |
| **v0.3** | 2026-06-28 | Néstor + Claude | Mapa de columnas real (40# y 41# difieren); Ideas (§9) y sync de validación dentro del alcance. |
| **v0.4** | 2026-06-28 | Néstor + Claude | **Corrección de clasificación de campos (PO):** desaparece la lista negra pura. Fecha de entrega esperada (col 8) = due_date de ClickUp (se vuelca, sin divergencia). Fecha de validación (col 9) y Notas [Cliente] (col 11) = Sheet→ClickUp (origen Cliente, nunca pisar, propagar a ClickUp). Notas Reinicia automáticas. Semáforo = desplegable con formato asociado al valor (solo escribir texto). Modelo en 3 flujos: ClickUp→Sheet / Sheet→ClickUp / Generado por Claude. |
| **v0.5** | 2026-06-28 | Néstor + Claude | Documentado el modo CREACIÓN desatendido como evolución futura. |
| **v0.9** | 2026-06-28 | Néstor + Claude | Aclaración de formato del Log: el fondo de las filas de datos es `#EBEBEB` y NUNCA blanco (sobre blanco los bordes blancos no se ven como rejilla). Aplicado a mano a las filas 10–12 del fichero de Líder System. El valor `#EBEBEB` ya estaba bien en v0.8; el fallo fue en la aplicación manual. |
| **v0.8** | 2026-06-28 | Néstor + Claude | **Hallazgos 1ª pasada (Líder System).** Reflejo COMPLETO de lista blanca por fila (no solo divergencias) + backfill inicial de filas viejas. **Mes** confirmado = mes de la fecha de entrega → recomputar Mes y marca de calendario al cambiar la fecha. **due_date null → "A definir"** (no vaciar). **Épica (col 2)** deja de ser objetivo de negocio (modelo B): es la agrupación del fichero (plataforma/fase), derivada consistente; no se inventa. **Log de Cambios: dar formato a las filas nuevas** (fill #EBEBEB, bordes blancos, Manrope). Orden cronológico de filas nuevas → pendiente futuro (de momento, al final). |
| **v0.7** | 2026-06-28 | Néstor + Claude | Ámbito del piloto: los 3 (Líder System, Carritech, Breezom) los crea la skill en su 1ª pasada (sin creación supervisada previa); arranque escalonado (LS primero, luego Carritech y Breezom). |
| **v0.6** | 2026-06-28 | Néstor + Claude | **Creación desatendida = modo activo del piloto.** Si falta el fichero v2, la skill lo crea: guardia anti-duplicados (no negociable), copia de plantilla, **idioma inferido** del cliente + nota, **granularidad por defecto = quincenas**, reflejo de ClickUp, criterio (Épica/Descripción/alcance/portada) propuesto y marcado BORRADOR pendiente de validación PO, nota consolidada en Gestión. El almacén de config por cliente pasa a mejora opcional (inferencia+defaults mientras no exista). |

---

## PENDIENTES DE EVOLUCIÓN
- **Almacén de configuración por cliente** (idioma/granularidad/formato/alcance atípicos) como mejora
  opcional de la creación desatendida (hoy: inferencia + defaults).
- Calibrar presupuesto de troceo y criterio de reanudación (1ª pasada).
- Confirmar mecanismo exacto de "informar Notas [Cliente] en ClickUp" (comentario en la tarea).
- **Orden cronológico** de filas nuevas dentro de cada tabla (futuro; de momento al final, a revisar cuando los POs trabajen los Planes).
- Especificar tool calls celda a celda del PASO 3 y de los empujes Sheet→ClickUp.
- Confirmar nomenclatura de la skill.
- Incorporar Breezom y Carritech cuando tengan fichero v2.
