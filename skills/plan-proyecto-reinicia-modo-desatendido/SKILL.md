---
name: plan-proyecto-reinicia-modo-desatendido
description: >
  Versión desatendida (cloud) de plan-proyecto-zoho-sheet-reinicia para Claude Code Routines.
  Gestiona el CICLO DE VIDA del Plan de cada cliente: lo localiza por el producto "Plan de
  Proyecto/Marketing [año]" de ClickUp (enlace en un comentario) con respaldo en la carpeta de
  Workdrive del proyecto; solo si fallan AMBOS lo crea, en la carpeta del proyecto (NUNCA en
  Seguimiento), delegando en la creación de la supervisada; al cambiar de año crea el fichero del
  nuevo año sembrado con los productos vivos. Reconcilia sprint a sprint (ClickUp es la fuente de
  verdad): refleja en el Sheet los campos del producto y el calendario, y empuja Sheet→ClickUp la
  Fecha de validación y las Notas del Cliente. Congela el Plan
  si la carpeta se archiva en ClickUp. Genera las Ideas dominicales. Troceada e idempotente.
  Reporta en el producto Gestión [CLIENTE] de ClickUp. Actívala SOLO en la Routine o si piden
  "ejecuta la gestión desatendida del plan de [CLIENTE]". Para edición supervisada, usa
  plan-proyecto-zoho-sheet-reinicia.
---

# SKILL: Plan de Proyecto — Modo Desatendido (Gestión de ciclo de vida) — Reinicia

> **Versión vigente: v1.14 — Notas cara cliente sin ratios (resumen de estatus real); contadores/riesgos solo en el Interno — 2026-07-12**

> **Estado:** skill de producción en evolución — gestiona el ciclo de vida del Plan (localiza, crea
> si falta, reconcilia las tres tablas, congela). Lo que queda por calibrar en ejecución real va
> marcado con 🚧 en el texto y en «Pendientes de evolución».

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
| **Líder System** | `pnync16…` — enlazar en comentario del producto Plan de ClickUp | **Activo** (reconciliación; validar v0.9) |
| **Carritech** | lo crea la desatendida (ciclo de vida) vía creación unificada | Tras LS y tras cablear la creación unificada |
| **Breezom** | lo crea la desatendida (ciclo de vida) vía creación unificada | Tras LS y tras cablear la creación unificada |

Ejecución: Claude Code Routine. **Modelo: Sonnet 4.6.** La desatendida **gestiona el ciclo de vida**
(localiza, crea si falta, reconcilia, congela). La **creación usa la lógica ÚNICA de la supervisada**,
no una versión abreviada. **Orden operativo:** primero validar reconciliación con Líder System;
habilitar creación autónoma solo cuando la creación unificada esté cableada.
Plantilla canónica v2: `pnync351d56992b6d4026906a6fec5d56e682`.

---

## ESTRUCTURA CANÓNICA DEL PLAN v2 (leída de la plantilla)

### Pestañas (worksheet_id reales)
`36#` Portada · `40#` **Plan Proyecto** (cara cliente) · `41#` **Plan Proyecto Interno** ·
`42#` **Ideas** · `45#` Objetivos Cliente (lectura, priorización) · `43#` Log Cambios (solo añadir) ·
`44#` Config. En reconciliación la desatendida escribe en 40#, 41#, 42# y 43# (Log); en creación también 36# (Portada) y 44# (Config).

> **Portada (`36#`):** `C3` = título (sustituir el marcador `[NOMBRE CLIENTE]` por el cliente real) · `D5` = `=HYPERLINK("<web real>";"<Nombre Cliente>")` (semicolon es-ES, `https`; **reemplaza** el hyperlink `ackstorm` de la plantilla) · **limpiar el residuo `ackstorm` desparramado en `E5:G5`** · etiquetas ya en `C6`–`C10`, **valores en `D6`–`D10`** sobrescribiendo los placeholders de la plantilla (`Español`/`España`/`Columbia o Proactive u otro`/`Nombre y Apellidos`); etiquetas traducidas en planes EN. **Header col 12 de 40#:** renombrar `Notas Nombre Cliente` → `Notas <Cliente real>`.
> **Sello de última actualización — `C3` de AMBAS pestañas** (placeholder `DD/MM/AAAA` en la plantilla): **`40#` solo fecha `DD/MM/YYYY`**; **`41#` fecha + hora `DD/MM/YYYY HH:MM`** (24h). **Reescribirlo en CADA pasada de reconciliación** (y al crear).
> **Estatus = desplegable:** la API **solo escribe el VALOR**; el color (incl. PARKING/CANCELADO) lo asigna la interfaz. **Nunca** pintar el color del Estatus ni intentar manipular el desplegable vía API. El desplegable ya viene en la plantilla.

### Tablas dentro de 40#/41# y su FUENTE en ClickUp (cada tabla, su lista)
Tres por pestaña, y **cada una se reconcilia contra una lista distinta** — NO todo sale de General:

> ⚠️ **Los números de fila-título de abajo son ORIENTATIVOS y NO se dan por buenos: se releen EN VIVO (regla de escritura 5, paso a) antes de tocar nada.** La plantilla puede traer más/menos placeholders y cualquier inserción previa los desplaza (incidente real: SOPORTE ACTIVO apareció en la fila 36, no en la 32). Localizar cada sección **por el texto de su fila-título** (`PLAN …`), nunca por índice fijo.

| Tabla del Plan | Fuente ClickUp | Filtro | Fila-título (orientativa) |
|---|---|---|---|
| **PLAN IMPLEMENTACIÓN** | `General [CLIENTE]` (LS `211763746`) | productos digitales / SPIKEs | ~fila 7 |
| **PLAN SOPORTE ACTIVO** | `Soporte [CLIENTE]` (LS `211763780`) | tareas **no cerradas** | ~fila 32 |
| **PLAN SOPORTE CERRADO** | `Soporte [CLIENTE]` (LS `211763780`) | tareas **cerradas en el año del Plan** (p. ej. 2026); las cerradas en años anteriores quedan en el Plan de su año (histórico), NO se traen | ~fila 57 |
| **RESUMEN HISTÓRICO** (rollup de años anteriores) | agregado interno | **2 filas: Implementation / Support** | ~fila 81 |

Cabecera de tabla en la fila **inmediatamente posterior** al título (1ª sección: filas 3–5 = leyenda de hitos; fila 7 = meses; fila 8 = cabecera). Localizar por texto, no por índice.
> **Los meses se repiten en la fila-título de CADA sección.** En planes **EN**, traducirlos **por sección** (no basta con la primera).
> **Años anteriores** (alcance histórico completo): los productos de años previos van **individuales, con su fecha real**, y el **calendario del año en blanco**; el **RESUMEN HISTÓRICO (fila 81)** es el que los **agrega** en 2 filas (Implementation / Support).

> ⚠️ **Regla anti-fallo de alcance** (la pasada del 29/06 dejó sin reconciliar las filas 39–79 por
> mirar solo General): reconciliar SIEMPRE las tres tablas, cada una contra su lista. Una fila del
> Sheet **sin tarea** en su lista fuente → **avisar al PO y NO tocarla** (probable renombrado/movido).

### ⚠️ MAPA DE COLUMNAS v2 — LAS DOS PESTAÑAS DIFIEREN (leer cabecera por pestaña, NUNCA hardcodear)

> ⚠️ **v1.8:** la plantilla v2 añade la columna **`Fecha de petición` (H = col 8)** (`date_created`), que **desplaza +1** todo lo que venía a partir de ella. El mapa anterior ("Estatus col 12/11; calendario 13/12") **ya NO aplica**.

**`40#` Plan Proyecto (cara cliente):**
| col | letra | Campo | Flujo |
|---|---|---|---|
| 2 | B | Épica (modelo HÍBRIDO) | Microcampaña→fase de funnel (campo ÉPICA de ClickUp, ⬜ lista blanca). Producto digital→**objetivo de negocio propuesto por Claude** con prefijo numérico (🟪 + validación PO). NUNCA la app/plataforma. |
| 3 | C | Tipo Producto | ⬜ ClickUp → Sheet |
| 4 | D | Mes | Derivado = **mes de la Fecha de entrega** (col 9). Recomputar al cambiar la fecha. |
| 5 | E | PBI de Primer Nivel | ⬜ ClickUp → Sheet; si vacío en ClickUp → Claude rellena en Sheet+ClickUp + nota PO |
| 6 | F | Entregable | ⬜ ClickUp → Sheet (nombre de tarea, con hyperlink a la tarjeta) |
| 7 | G | Descripción | ⬜ ClickUp → Sheet (por defecto **Historia de usuario + Resumen ejecutivo** combinados en la misma celda; en EN, ambos en inglés) |
| 8 | **H** | **Fecha de petición** (`date_created`) | **COLUMNA NUEVA** — se lee del hyperlink del Entregable; fija el orden dentro de la tabla |
| 9 | I | **Fecha de entrega esperada** | ⬜ **ClickUp → Sheet (due_date)** |
| 10 | J | **Fecha de validación esperada** | ↕ **Sheet ↔ ClickUp (bidireccional)** — subtarea "Validación Cliente"; rellenar el lado vacío desde el otro, **nunca pisar** un valor ya puesto |
| 11 | K | Notas Reinicia | ⬜ ClickUp → Sheet (**resumen de estatus real en prosa**: hecho/pendiente/siguiente paso; **SIN contadores**; los ratios `X/Y subtareas · X/Y criterios` + riesgos ⚠️ van en `Notas` del Interno 41#) |
| 12 | L | **Notas [NombreCliente]** | 🔼 **Sheet → ClickUp** (Cliente escribe; nunca pisar; leer e informar en ClickUp) |
| 13 | **M** | Estatus | ⬜ ClickUp → Sheet (desplegable; color automático) |
| 14–37 | **N–AK** | Calendario (24 quincenas) | Generado de las fechas del Sheet (col 9 due_date + col 10 validación) · **col = 13 + quincena** |

**`41#` Plan Proyecto Interno** (igual hasta col 10; luego CAMBIA — no tiene "Notas [Cliente]"):
| col | letra | Campo | Flujo |
|---|---|---|---|
| 2–10 | B–J | igual que 40# (incluye **H = Fecha de petición**) | igual |
| 11 | **K** | Notas (una sola) | ⬜ ClickUp → Sheet (operativa) |
| 12 | **L** | Estatus | ⬜ ClickUp → Sheet (desplegable; color automático) |
| 13–36 | **M–AJ** | Calendario (24 quincenas) | Generado · **col = 12 + quincena** |

> ⚠️ **Estatus = col M (13) en 40# / col L (12) en 41#; calendario desde N (14) en 40# / M (13) en 41#.**
> **quincena = (mes − 1)·2 + (1 si día ≤ 15; 2 si día > 15).** Resolver por **nombre leyendo la cabecera**
> de cada pestaña, nunca por letra fija. `41#` no tiene "Notas [Cliente]".

---

## MODELO DE SINCRONIZACIÓN (tres flujos, no hay "lista negra pura")

- **⬜ ClickUp → Sheet** (ClickUp manda; si difiere, se actualiza el Sheet): Tipo, PBI, Entregable,
  Descripción, **Fecha de entrega (due_date)**, Notas Reinicia/Notas, Estatus, calendario. **La
  lista fuente depende de la tabla** (Implementación←General; Soporte Activo/Cerrado←Soporte).
- **🔼 Sheet → ClickUp** (origen en el Sheet, se propaga a ClickUp; nunca se pisa la celda del Sheet):
  - **↕ Fecha de validación esperada** (**col 10** J) ↔ fecha de la subtarea **"Validación Cliente"** de ClickUp: **sincronización bidireccional (decisión PO nº5)**. Si un lado tiene valor y el otro está vacío, **rellenar el vacío desde el que lo tiene** (Sheet→ClickUp o ClickUp→Sheet). **Nunca inventar** y **nunca pisar** un valor ya puesto por el Cliente (si ambos difieren, no tocar y avisar en el reporte).
  - **Notas [Cliente]** (**col 12** L, solo 40#) → informar en ClickUp (🚧 mecanismo: comentario en la
    tarea del producto en `General [CLIENTE]`; confirmar en 1ª pasada).
- **🟪 Generado por Claude** (criterio, + nota PO): **PBI** (col 5) cuando falta en ClickUp, y la
  **Épica** (col 2) de **productos digitales** = **objetivo de negocio** que propone Claude (p. ej.
  "Retención y fidelización de alumnos"), NUNCA la app/plataforma. Marcar BORRADOR + validar con el PO.
- **Épica de microcampañas / marketing** = **fase de funnel** del campo ÉPICA de ClickUp
  (`6e3bf4c0-…`): ⬜ ClickUp → Sheet. Si ese campo tiene valor, se usa tal cual.

> **Reflejo completo (no solo divergencias):** en CADA fila que se lee de ClickUp, refrescar TODOS
> los campos de lista blanca (Tipo, Entregable, Descripción, Notas Reinicia, Estatus, Fecha de
> entrega), no solo las celdas que cambiaron. **Backfill inicial troceado** para filas antiguas con
> lista blanca incompleta (p. ej. Tipo de Producto vacío).
> **due_date null** (producto abierto) → escribir **"A definir"** en **col 9** (no vaciar) y calendario en blanco.
> **Cerrado sin `due_date`** → **`date_closed` como fecha de entrega (proxy, decisión B):** col 9 = `date_closed` (`DD/MM/YYYY`) + marca de calendario en su quincena (color entrega `#70EED6`). `date_closed` sigue atribuyendo el año. Solo Entrega `"-"` y calendario en blanco si **tampoco** hay `date_closed`.
> **Al cambiar la fecha de entrega**, recomputar **col 4 "Mes"** (= mes de **col 9**) y la marca de calendario.
> Sin divergencia con la supervisada en la fecha de entrega: ambas la actualizan desde el due_date.

---

## IDENTIDAD VISUAL — INVARIANTES A PRESERVAR

- Cabecera de tabla: `fill #3812CF` · `font #FFFFFF` · negrita · center/middle · alto 36 · wrap.
- Banding datos: par `#FFFFFF` / impar `#EBEBEB` · alto 60 · valign top.
- Zona calendario (encabezado meses/quincenas): `fill #EBEBEB` · negrita · `font #3812CF` · center/middle.
- **Rejilla del calendario, celdas de datos (40# cols N–AK = 14–37; 41# cols M–AJ = 13–36): la
  plantilla ya la trae en gris.** Son 24 quincenas (2 por mes). **NO repintar la base** (las filas
  insertadas heredan el gris de la de arriba). Pintar SOLO los hitos encima: entrega `#70EED6`,
  validación `#EBE31B`, desde las fechas (**col 9 due_date / col 10 validación**; quincena =
  (mes−1)·2 + (1 si día≤15; 2 si>15)). **Para MOVER un hito, restaurar la celda que se vacía al mismo
  gris de la plantilla, NUNCA a blanco** (ese gris no se lee por API → fijarlo una vez confirmándolo a
  ojo). Al redibujar hitos, recorrer la
  rejilla COMPLETA (todas las filas de datos), no solo las que cambian.
- **Estatus = desplegable con formato asociado al valor** → escribir solo el texto exacto del
  desplegable y el color sale solo (TERMINADO verde · EN PROCESO amarillo · PENDIENTE lila ·
  POSPUESTO gris · PARKING/CANCELADO según desplegable). No reaplicar color nunca.
- Hitos Gantt: entrega Reinicia `#70EED6` ("Azul Claro Reinicia") · validación Cliente `#EBE31B`
  ("Amarillo Claro Reinicia"). Leyenda en filas 3–5.
- **Agrupación visual por Épica (40# y 41#, columna 2):** colorear el FONDO de la celda de Épica por
  grupos consecutivos de la misma épica, **alternando `#70EED6` y `#BFBFBF`** cada vez que cambia el
  nombre de la épica (grupo 1 `#70EED6`, grupo 2 `#BFBFBF`, grupo 3 `#70EED6`…). Así se ven agrupadas
  las filas de una misma épica. Recalcular al insertar/reordenar filas.
- Bordes blancos `#FFFFFF` sólidos en todas las pestañas.
- Log Cambios: cabecera `#3812CF`/`#FFFFFF`; fila 2 `#D9D0FB`/`#555555` itálica. **EXCEPCIÓN a la
  regla de inserción**: el Log NO es una tabla precreada con formato, así que sus entradas se
  **añaden al final** (no "antes de la penúltima") y hay que **aplicar el formato explícitamente** —
  fill `#EBEBEB`, bordes blancos `#FFFFFF` sólidos, Manrope, color de fuente `#545454`, altura ~48,
  wrap — igual que las filas 6–14 existentes. Lavado base blanco.
- Fuentes Manrope. Azul de marca `#3812CF` (no `#3812CB`).

---

## REGLAS DE ESCRITURA SEGURA

0. **Estilo canónico SIEMPRE al escribir** (regla de oro): al escribir/insertar cualquier celda,
   aplicar el estilo que le corresponde por la maqueta canónica (fondo, bordes, fuente Manrope,
   color de fuente, alineación, altura). **NUNCA dejar el formato "por defecto"** por no poder leer
   el existente vía API — "por defecto" es lo que dejó el Log en negro/blanco y el Config a medias.
   Si el estilo canónico de una zona no está documentado, usar el de las filas/celdas equivalentes
   ya existentes y, si hay duda, aplicar el de marca (Manrope, `#545454`) y avisar en el reporte.
1. **Nunca `range.content.clear`** (resetea formato). Vaciar con `" "`, nunca `""` (error 2831).
2. **No pisar fill/font de cabecera** (solo `font_name="Manrope"` seguro sobre ella).
3. **`cells.content.set` plural, lotes ≤40.** Decimal con coma. Nunca `csvdata.set` para nº con coma.
4. **Estatus = valor exacto del desplegable** (PENDIENTE · EN PROCESO · TERMINADO · POSPUESTO ·
   PARKING · CANCELADO / EN). El color es automático por el desplegable; no tocar formato.
5. **Inserción de filas (§8) — PROTOCOLO GATED OBLIGATORIO, en CUALQUIER tabla de CUALQUIER pestaña.**
   **INVARIANTES — NUNCA** (violarlos corrompe la estructura; incidente real: se aplastaron el título y la
   cabecera de "PLAN SOPORTE ACTIVO" al insertar sobre su fila-título):
   - NUNCA escribir en la **fila-título** (`PLAN …`) ni en la **fila-cabecera** de una tabla.
   - NUNCA escribir en las **2 últimas filas de datos** de una tabla (buffer: última = borde de cierre;
     penúltima = ancla de formato/desplegable/semáforo). Se dejan vacías.
   - NUNCA insertar con `row` en una fila-título/cabecera. **Ancla = `título_siguiente − 2`** (fila interior).
   - NUNCA usar números de fila memorizados/del prompt/de versiones (7/32/57/81): **releer EN VIVO**.
   - NUNCA localizar títulos/cabeceras **contando filas de una lectura por rango**: `worksheet.content.get` en
     array **COLAPSA las vacías** (índice del array ≠ nº de fila; hizo creer que SOPORTE CERRADO estaba en 63
     cuando estaba en 59). Localizar **SIEMPRE con `ZohoSheet_find`** (da `row_index` real); las lecturas por
     rango solo para leer contenido de filas ya localizadas. Aserciones de celda → **`get_content_of_cell`**.

   **Secuencia obligatoria LOCALIZAR → CALCULAR → INSERTAR → VERIFICAR → ESCRIBIR:**
   (a) **LOCALIZAR con `find`** las **4 filas-título** (`ZohoSheet_find`, una búsqueda por título) → `row_index`
       real de cada una; la cabecera es la fila siguiente. **No** contar filas de un array.
   (b) **CALCULAR** por sección: rango escribible = `[cabecera+1 … título_siguiente − 3]`; contar filas
       necesarias de TODA la sección vs. las que caben.
   (c) **INSERTAR** el déficit por adelantado, `row = título_siguiente − 2`, **1 fila/llamada**, replicado en
       **AMBAS pestañas** al mismo índice. (En un proyecto con soporte real, SOPORTE CERRADO puede pedir ~18.)
   (d) **VERIFICAR (aserción DURA y BLOQUEANTE):** re-localizar con `find`; los **4 títulos** deben seguir
       presentes (`matches_found` correcto) y desplazados lo insertado; cada cabecera no vacía por
       `get_content_of_cell`; recuento OK (`insert_row` a veces deja una de menos).
   (e) **ESCRIBIR — con GUARDA DE LÍMITE POR LOTE:** antes de CADA `cells.content.set`, verificar que **todas**
       las filas destino caen en `[cabecera+1 … título_siguiente−3]`; si una sola se sale → **no escribir**,
       volver a (c). Aserción por escritura, no solo el cálculo de (b) — evita **desbordar una tabla sobre el
       título/cabecera de la siguiente** (incidente real: se mezclaron IMPLANTACIÓN y SOPORTE ACTIVO).

   **CHEQUEO DE INTEGRIDAD (antes y después de toda operación estructural — inserción y borrado de Formación
   Interna):** con `find`, exactamente 4 títulos por pestaña + cada cabecera (celda `B(título+1)`) no vacía por
   `get_content_of_cell`. **Si (d), (e) o el chequeo fallan → ABORTAR: no escribir/insertar nada más, dejar la
   hoja como estaba y REPORTAR el incidente estructural en el producto `Gestión [CLIENTE]` de ClickUp** (fichero,
   sección y filas afectadas), en vez de continuar a ciegas. En desatendido este error sería invisible: por eso
   es bloqueante, no un aviso más.
   **Excepción: Log de Cambios** (no hay tabla precreada) → añadir al final + aplicar formato explícito
   (ver identidad visual).
6. **Índices de Estatus/calendario por cabecera leída** (difiere entre 40# y 41#).
7. **Columnas de origen Cliente = solo lectura→push (nunca pisar):** son **col 10** (Fecha de validación)
   y **col 12** (Notas [Cliente], solo 40#). En cambio **col 9 SÍ se escribe** (due_date desde ClickUp).
8. **Log de Cambios:** añadir la entrada al final y **aplicar el formato de fila explícitamente** (fill `#EBEBEB`, bordes blancos, Manrope, color `#545454`, altura ~48, wrap) para igualar las filas existentes — el Log no tiene cuerpo preformateado del que heredar. **Registrar SIEMPRE** una entrada al cierre de cada pasada con los cambios aplicados. **No `Create_New_File`.**

---

## REGLA DE PBI VACÍO (criterio autónomo)

Por fila: leer ClickUp. Campo con valor → sincronizar Sheet (gana ClickUp; nunca pisar ClickUp).
**PBI** vacío en ClickUp → Claude escribe PBI afinado en Sheet **y** ClickUp + nota PO. **Épica**
(col 2), modelo HÍBRIDO: microcampaña → fase de funnel del campo ÉPICA de ClickUp; producto digital →
**objetivo de negocio propuesto por Claude** (BORRADOR + validación PO), NUNCA la app/plataforma.
Idempotente.

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

## ORDEN Y AGRUPACIÓN POR ÉPICA

- **Épica = objetivo de negocio** (modelo B) con **prefijo numérico** que fija el orden ("1. …",
  "2. …"), para que el orden sea **intrínseco al dato** (ordenar por el texto de col 2 = ordenar por
  épica). No se deriva de la app ni del ÉPICA funnel.
- **Orden de filas dentro de CADA tabla (Implementación, Soporte Activo, Soporte Cerrado):**
  **Épica (prefijo) → fecha de petición (`date_created`, col 8 H) → fecha de entrega (col 9 I).**
- **`date_created`** (fecha de petición) se escribe en la **columna propia `H` (col 8)** y también se
  puede cruzar con el **`task_id` del hyperlink del Entregable** (col 6, `app.clickup.com/t/<task_id>`)
  → identidad determinista de fila, sin matching difuso.
- **Reorden, recoloreado de Épica y redibujado del calendario van SIEMPRE juntos** (un cambio de
  orden invalida las marcas del calendario, que son solo fondo). Al reordenar: mover la fila
  completa, recomputar el color de Épica (fondo alternando `#70EED6`/`#BFBFBF` por grupo contiguo) y
  redibujar el calendario (heredar el gris de la plantilla, **sin repintar la base**; solo (re)pintar hitos, restaurando al gris las celdas que se vacíen). Operación delicada → hacerla como paso dedicado.
- **Reorden desfasado entre pestañas:** 40# y 41# pueden no estar alineadas (p. ej. Soporte Cerrado
  va una fila desplazado); mapear SIEMPRE por Entregable, no por número de fila.

---

## FLUJO

### PASO 0 — Parámetros
Cliente(s) (piloto: Líder System) · sprint vigente · presupuesto de troceo (🚧 calibrar) · Sonnet 4.6.

### PASO 1 — Precondiciones
Existe el fichero v2 · `worksheet.list` para ids · **leer cabecera (fila 8) de 40# y 41#** y mapear
columnas por nombre. Si no existe → **omitido** y siguiente.

> **Localizar el fichero por descubrimiento determinista** (ver Ciclo de Vida §A): producto "Plan de
> Proyecto/Marketing [año]" en ClickUp → enlace en comentario; respaldo carpeta Workdrive. Solo si
> fallan AMBOS → crear (§B). Estados: BORRADOR / ACTIVO / CONGELADO.

### PASO 2 — Reanudación
Primera fila pendiente por el contenido de la columna PBI. 🚧 criterio exacto a definir.

### PASO 3 — Reconciliación por tabla, fila a fila (hasta agotar troceo)
- **Recorrer las TRES tablas**, cada una contra su lista fuente (Implementación←General;
  Soporte Activo←Soporte no cerradas; Soporte Cerrado←Soporte cerradas en el año del Plan). No
  limitar la reconciliación a General.
- Leer tarjeta ClickUp (campos, subtareas, comentarios, checklist, due_date, subtarea Validación Cliente).
- **Reflejo completo** de la lista blanca en CADA fila (no solo divergencias), **incluida Notas
  Reinicia/Notas** (refrescarla aunque solo cambie el estatus); **↕ validación** (bidireccional) + 🔼 **Notas Cliente** (Sheet→ClickUp, nunca pisar); 🟪 PBI vacío → generar; **recomputar Mes y marca de calendario** al cambiar la fecha.
- **Fila huérfana** (en el Sheet, sin tarea en su lista fuente) → avisar al PO en el reporte y NO tocarla.
- **Tarea sin fila** (existe en General y está `done`, pero no tiene fila en Implementación) → **añadirla
  a Implementación** por inserción, en BORRADOR, y avisar al PO para validar.
- **Ticket de Soporte cerrado SIN fecha de cierre** → no se puede atribuir a un año → **dejar fuera de
  Soporte Cerrado y avisar** (no adivinar el año). **Cerrado con fecha pero sin `due_date`** → **`date_closed` como proxy de entrega (B)**: col 9 = `date_closed` (DD/MM/YYYY) + marca de calendario; `"-"` solo si tampoco hay `date_closed`.
- **Formación Interna FUERA del Plan:** los productos de «Formación interna» **no figuran** (ni 40# ni 41#): no se escribe Descripción ni se hace write-back de PBI; **borrar su fila**. El borrado es ESTRUCTURA → hacerlo **al final de la fase de contenido** y **repintar** calendario/Gantt después.
- **Soporte Cerrado — tratamiento ligero por lotes:** Descripción de **1 línea** derivada de **Deliverable + Épica + PBI** (o vacía si es duda/consulta sin entregable real), **sin leer tarjeta a tarjeta**; procesar en lotes grandes; write-back de PBI igual que el resto. (Cuando `clickup_plan_fields` esté desplegada, esto sale de una sola consulta; hoy, por lotes con `clickup_get_task`.)
- **Al cierre: registrar SIEMPRE la entrada en el Log de Cambios** (3 columnas Fecha | Autor | Cambio; paso obligatorio, no opcional).
- **Reescribir el sello de última actualización** en `C3` de ambas: `40#` `DD/MM/YYYY`; `41#` `DD/MM/YYYY HH:MM` (24h), en cada pasada.
- (Re)dibujar calendario: **heredar el gris de la plantilla, sin repintar la base**; pintar solo los hitos de **cols 9/10** encima (entrega `#70EED6`, validación `#EBE31B`) y restaurar al gris las celdas que se vacíen al mover un hito.
- **Insertar filas — PROTOCOLO GATED (regla de escritura 5):** LEER→CALCULAR→INSERTAR→VERIFICAR→ESCRIBIR. Insertar el déficit por adelantado con ancla `título_siguiente − 2` (nunca sobre título/cabecera; respetar el buffer de 2 filas finales), en AMBAS pestañas. En proyecto con soporte real, SOPORTE CERRADO puede pedir **~18 inserciones**. **VERIFICAR es aserción bloqueante** (4 títulos + 4 cabeceras intactos y desplazados lo esperado; recuento OK — `insert_row` a veces deja una de menos). **Si falla → ABORTAR y reportar el incidente estructural en `Gestión [CLIENTE]`, sin escribir nada más.** Persistir en lotes ≤40.

### PASO 4 — Ideas (solo Routine dominical)
≤7 ideas nuevas en 42# con trazabilidad y priorización por Objetivos (45#).

### PASO 5 — Cierre y reporte en ClickUp (NO Cliq)
Comentario en `Gestión [CLIENTE]`: filas reconciliadas · PBIs/Épicas escritos por Claude (validar) ·
validaciones sincronizadas · notas de Cliente informadas · ideas nuevas · omitidos · punto de reanudación.
- **Comentarios ClickUp:** texto plano, sin markdown ni hipervínculos; descripción + URL en línea aparte.
- **Divergencia intencional** vs. hermanas (Cliq): aquí a ClickUp por decisión del PO.

---

## CICLO DE VIDA DEL PLAN

Máquina de estados por cliente:

```
sin Plan del año ─(alta / cambio de año)→ crear BORRADOR (sembrado) + enlace en comentario de ClickUp
   → PO valida / limpia → ACTIVO ⇄ reconciliación (ClickUp manda)
   → carpeta archivada en ClickUp → CONGELADO (deja de reconciliar; no borra)
```

### §A. Localización del fichero (determinista, NUNCA búsqueda difusa que dispare creación)
1. **ClickUp primero:** localizar el producto **"Plan de Proyecto/Marketing [año en curso]"** en la
   lista del cliente. El nombre **puede variar** → inferir por similitud (tipo + año), no match exacto.
   El **enlace al fichero vive en un COMENTARIO** del producto → de ahí se saca el `file_id` (determinista).
2. **Workdrive como respaldo:** si en ClickUp no aparece, buscar la **carpeta/fichero** "Plan de
   Proyecto / Plan de Marketing o similar" del proyecto.
3. **Regla del doble fallo:** solo se considera **"sin Plan del año"** si **fallan AMBOS**. Un único
   fallo **NUNCA** crea. (Esto evita el duplicado de v0.5–v0.9.)

### §B. Creación (solo tras doble fallo; lógica ÚNICA, NO reimplementada)
- **Construir con el procedimiento de la supervisada** (`plan-proyecto-zoho-sheet-reinicia`, CREACIÓN):
  backlog **COMPLETO**, Config, Log con tabla y estilos, enlaces en Entregables, portada. **NO**
  reimplementar una versión abreviada (fue lo que falló: 7 de 57, Config/Log vacíos, sin enlaces).
- Sustituir las preguntas al PO por **inferencia + defaults deterministas** (no hay PO al que preguntar). Marcar **BORRADOR pendiente de validación PO**:
  - **Idioma:** si el fichero ya existe, **leerlo de la Config (`44#`) / Portada (`36#`)**; si se crea de cero, **inferirlo del cliente** (país/idioma de trabajo) + nota al PO.
  - **Traducción de Entregables:** por defecto en planes EN se traduce **todo**, incluidos los **nombres de Entregables** (la trazabilidad la mantiene el **HYPERLINK al `task_id`** de ClickUp, no el texto). Solo se dejan sin traducir si la Config/Portada indica que el PO lo pidió.
  - **Años anteriores (histórico completo):** productos de años previos **individuales, con su fecha real**, y **calendario del año en blanco**; el **RESUMEN HISTÓRICO (fila 81)** los **agrega**.
  - **Granularidad = quincenas · alcance = backlog completo.**
- **Ubicación: SIEMPRE la carpeta "Plan de Proyecto/Marketing o similar" del proyecto en Workdrive.
  NUNCA "01. Seguimiento".** Si esa carpeta no existe, **crearla** en la raíz del proyecto antes de
  poner el fichero.
- Copiar de la plantilla canónica `pnync351…` con `ZohoSheet_copy` (nunca `Create_New_File`);
  verificar status=1 y sin `%3A`.
- **Tras crear: dejar el enlace al fichero en un COMENTARIO** del producto "Plan de Proyecto [año]"
  de ClickUp (y crear/actualizar ese producto si falta), para que la siguiente pasada lo localice
  sin buscar a ciegas.

### §C. Cambio de año
Buscar el Plan del **año en curso**; si no existe → **crear el del nuevo año** (misma lógica §B),
**sembrado**:
- **Productos vivos** (abiertos/en curso) del año anterior → se arrastran siempre.
- **Caso especial — proyecto General de implementación inicial aún no cerrado:** arrastrar **también
  los productos cerrados** de esa implementación (sigue "viva" como un todo hasta cerrarse).
- **Nota al PO en Gestión** avisando de que puede hacer limpieza manual.

### §D. Limpieza del PO vs ClickUp — **gana ClickUp**
Si el PO quita un producto del Sheet pero **sigue vivo en ClickUp**, la desatendida lo **vuelve a
añadir** y deja **nota al PO**: para quitarlo de verdad, debe **borrarlo/cerrarlo en ClickUp**, no
solo en el Sheet. (Vivo en ClickUp = presente en el Plan, siempre; sin marcas de arrastre.)

### §E. Baja por archivado
Carpeta/lista del proyecto **archivada en ClickUp** → estado **CONGELADO**: deja de reconciliar (no
borra). 🚧 `archived` es campo estándar de carpeta/lista en ClickUp (`clickup_get_folder`/`_get_list`);
confirmar la lectura en vivo vía MCP en la primera baja real (la lectura quedó pendiente de aprobación).

---

## INPUTS / OUTPUT

**Inputs:** fichero v2 (40#/41#/42#/45#/43#) · plantilla `pnync351…` · tarjetas `General [CLIENTE]`
(campos + subtarea Validación Cliente + due_date) · actas/Gestión/histórico/proyectos similares (Ideas) ·
`Gestión [CLIENTE]` (reporte).

**Output:** 40#/41# reconciliadas sin romper formato · due_date volcado a col 9 · validación y notas
de Cliente empujadas a ClickUp · Épica/PBI vacíos rellenados · ≤7 ideas en 42# · comentario en Gestión.

---

## RECURSOS CLAVE

- **Pestañas v2:** 36# Portada · 40# Plan Proyecto · 41# Plan Proyecto Interno · 42# Ideas ·
  45# Objetivos Cliente · 43# Log Cambios · 44# Config.
- **Config a TRES columnas (v1.8):** **Parámetro** (nombre del parámetro) · **Valor** (nombre legible) ·
  **ID/Resource** (que lee la máquina, en la **col D**, ancho ~400). Aplica a: Lista ClickUp General,
  Lista ClickUp Soporte, Lista ClickUp Gestión, Carpeta ClickUp, Space ClickUp, Carpeta Workdrive (Plan)
  y Resource ID (fichero). La skill **lee el ID de la col D**, nunca lo parsea de un texto "Nombre (ID)".
  Viene **VACÍA** en la plantilla → construirla en creación.
- **IDs ClickUp Líder System:** General `211763746` · **Soporte `211763780`** (fuente de las tablas
  de Soporte) · Gestión `211763776`. Custom fields: PBI `6758065a-bd4f-4d7d-9a48-926e81fe343f` · TIPO
  `5bd9072e-deae-4352-b35b-bdbaa3cc216d` · ÉPICA funnel (NO para Épica de negocio)
  `6e3bf4c0-354b-4a8c-8cb5-dbedeec1cf6e` · ORDEN `a2fac0a6-0f12-4c9b-9f2f-c5bbc2aa7a98`. Verificar
  custom fields si el cliente no es Carritech/LS.
- **Marca:** `#3812CF` · `#D9D0FB` · `#EBEBEB` · `#545454` · hitos `#70EED6` / `#EBE31B` · `#FFFFFF` · Manrope.

---

## LIMITACIONES TÉCNICAS

1. `clickup_get_task` con campos ~15k tokens. **Palanca objetivo:** la función Catalyst `clickup_plan_fields` (por lista, `{id, name, status, pbi, epica, tipo, date_created, due_date, date_closed}` en **<2k tokens**) para que el volcado **quepa en una sola pasada**. ⚠️ **AÚN NO DESPLEGADA (2026-07-11):** hasta que exista, el **default operativo es `clickup_get_task` troceado** (esta skill sigue troceada e idempotente por eso). Antes de asumir la vía barata, **comprobar que la función responde**; si no, caer a `clickup_get_task`. Este es el que exigen subtareas/comentarios/criterios en cualquier caso.
2. Sin API directa de ClickUp desde bash → solo MCP (en Routines).
3. Zoho Sheet (validado en vivo): `cells.content.set` **≤ 40 celdas/llamada** (63 → **error 400**); **`HYPERLINK` en lotes pequeños** (lote grande → 400); **`insert_row` 1 fila/llamada** → verificar recuento con lectura; celda <~200 chars; decimal coma; vaciar con `" "` (nunca `""`).
4. Comentarios ClickUp: texto plano.
4b. **El API de Zoho Sheet NO permite LEER el formato de una celda** (solo escribirlo). Por tanto,
    nunca intentar "igualar" un formato existente leyéndolo: aplicar SIEMPRE el estilo canónico
    que corresponde (regla de oro §0). Si hace falta uniformar, reescribir el estilo de todo el
    rango de una vez.
5. Roll-back: Historial de versiones de Zoho Sheet + Log de Cambios.

---

## VERSIONES

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v1.14** | 2026-07-12 | Néstor + Claude | **Alineada con la supervisada v2.14: Notas cara cliente sin ratios + resumen de estatus real.** `Notas Reinicia` (40#, col 11) = resumen de estatus en prosa (hecho/pendiente/siguiente paso), SIN contadores; los ratios `X/Y subtareas · X/Y criterios` y los riesgos ⚠️ se reservan a `Notas` del Interno (41#, col 11). Actualizada la línea del mapa de la col 11 (antes «operativa automática: ratios + riesgos»). El resumen se construye de subtareas (nombres+estado) + comentarios/hilos + checklist. |
| **v1.13** | 2026-07-12 | Néstor + Claude | **Blindaje del §8 (regla de escritura 5), alineada con la supervisada v2.13, tras mezclarse IMPLANTACIÓN y SOPORTE ACTIVO.** (1) **Localización de secciones SOLO con `ZohoSheet_find`** (`row_index` real); prohibido contar filas de `worksheet.content.get` en array porque **COLAPSA las vacías** (índice ≠ fila — hizo creer que SOPORTE CERRADO estaba en 63 cuando estaba en 59). El paso (a) pasa de "LEER" a "LOCALIZAR con find". (2) **Guarda de límite por lote en (e) ESCRIBIR**: antes de cada `cells.content.set`, verificar que todas las filas destino caen en `[cabecera+1 … título_siguiente−3]`; si una se sale → no escribir, volver a insertar. Aserción por escritura, no solo cálculo previo. (3) **Verificación por celda con `get_content_of_cell`** en VERIFICAR y en el chequeo de integridad (títulos contados con `find`, cabeceras validadas por celda). Se mantiene el carácter **bloqueante** y el **reporte en `Gestión [CLIENTE]`** ante fallo. |
| **v1.12** | 2026-07-12 | Néstor + Claude | **Regla de escritura 5 (inserción) reforzada como PROTOCOLO GATED + invariantes + chequeo de integridad, alineada con la supervisada v2.12** (tras incidente: se aplastaron título y cabecera de "PLAN SOPORTE ACTIVO" al insertar sobre su fila-título y escribir en filas de buffer). Invariantes NUNCA (no escribir en título/cabecera; no escribir en las 2 últimas filas de datos; ancla de inserción = `título_siguiente − 2`; no usar filas memorizadas 7/32/57/81 → releer en vivo). Secuencia obligatoria **LEER→CALCULAR→INSERTAR→VERIFICAR→ESCRIBIR** con rango escribible `[cabecera+1 … título_siguiente−3]`, inserción del déficit por adelantado en AMBAS pestañas, y **VERIFICAR/integridad como aserción BLOQUEANTE**: ante fallo (título/cabecera perdidos, recuento KO) → **ABORTAR y reportar el incidente en `Gestión [CLIENTE]` (canal propio de esta skill, no Cliq), sin escribir nada más**. Tabla de secciones de §4.0 marcada como orientativa (localizar por texto). Aplica al borrado de Formación Interna igual que a la inserción. |
| **v1.11** | 2026-07-11 | Néstor + Claude | **Sello con hora en el Interno (alineada con supervisada v2.11).** El sello de `C3` se escribe en AMBAS pestañas: **`40#` solo fecha `DD/MM/YYYY`**; **`41#` fecha + hora `DD/MM/YYYY HH:MM`** (24h), reescrito en cada pasada. Actualizadas §4.0 y PASO 3. |
| **v1.10** | 2026-07-11 | Néstor + Claude | **Alineada con la supervisada v2.10 (verificación en vivo de la plantilla).** (1) **Calendario = heredar la base gris de la plantilla, NO repintar** (filas insertadas heredan el gris); pintar solo hitos; al mover un hito, restaurar la celda vaciada al gris de la plantilla (no a blanco) — ese gris no se lee por API. Actualizadas las 3 menciones (identidad, reorden, PASO 3). (2) **Portada:** valores en `D6`–`D10` sobrescribiendo placeholders; `D5`=HYPERLINK reemplaza el `ackstorm` + limpiar `E5:G5`; renombrar header col 12 de 40# (`Notas Nombre Cliente` → `Notas <Cliente>`) y el marcador del título. |
| **v1.9** | 2026-07-11 | Néstor + Claude | **Proxy `date_closed` (decisión B) + bump alineado con la supervisada v2.9.** (1) **Cerrados sin `due_date`** usan **`date_closed` como fecha de entrega** (col 9 = fecha de cierre DD/MM/YYYY) **y marcan el calendario** en su quincena (color entrega); antes se dejaba `"-"`/blanco. Solo `"-"` si tampoco hay `date_closed`. `date_closed` sigue atribuyendo el año de la tabla. (2) Subida de versión (v1.8→v1.9) para mantener el par sincronizado con la supervisada. (3) **Cotejo de las 5 DECISIONES PO:** nº1–4 y nº5a ya cubiertas en la desatendida; **corregido el hueco nº5b** — la **Fecha de validación esperada** ahora sincroniza en **AMBOS sentidos** (Sheet ↔ ClickUp: rellenar el lado vacío desde el otro, nunca pisar el valor del Cliente; si difieren, avisar), antes solo Sheet→ClickUp. Actualizados mapa, MODELO DE SINCRONIZACIÓN y línea-resumen. |
| **v1.8** | 2026-07-11 | Néstor + Claude | **Mapa de columnas v2 (piloto Carritech) + reglas deterministas + palanca de coste.** (1) Columna nueva **`Fecha de petición` (H = col 8)** (`date_created`) que desplaza +1 todo lo posterior: Estatus 40#=M(13)/41#=L(12); Fecha entrega=col 9; validación=col 10; Notas Reinicia=col 11; Notas Cliente=col 12; calendario 40#=N–AK(14–37)/41#=M–AJ(13–36), 24 quincenas, `quincena=(mes−1)·2+(1 si día≤15;2 si>15)`. Actualizados MAPA DE COLUMNAS, identidad visual, MODELO DE SINCRONIZACIÓN y reglas de escritura. (2) **4ª sección RESUMEN HISTÓRICO** (fila 81, 2 filas Implementation/Support) que agrega años previos; productos de años anteriores individuales con fecha real + calendario en blanco; meses repetidos por sección (7/32/57/81) traducidos en EN. (3) **Portada real** (C3/D5 HYPERLINK/limpiar `ackstorm` E5:G5/C6–C10), **Config 3 columnas** (Parámetro|Valor|ID/Resource, ID col D), **Log 3 columnas** (Fecha|Autor|Cambio), **sello de última actualización** en 41# C3 (DD/MM/YYYY) reescrito en cada pasada. (4) Estatus = desplegable: la API solo escribe el valor, color automático; nunca pintar el Estatus. (5) **Reglas deterministas (sin PO)**: idioma leído de Config/Portada (o inferido), Entregables NO traducidos por defecto, años previos agregados en Resumen Histórico. (6) Formación Interna fuera del Plan; Soporte Cerrado ligero por lotes; cerrados sin due_date → Entrega "-". (7) Límites API validados (≤40 celdas [63→400], HYPERLINK en lotes, insert_row 1 fila/llamada con verificación); **`clickup_plan_fields`** (Catalyst) como palanca objetivo para que el volcado quepa en una pasada — **aún sin desplegar; hasta entonces el default operativo es `clickup_get_task` troceado**. (8) **Cotejo con el proyecto Asesor PO:** Descripción = **ambos formatos combinados** por defecto (Historia + Resumen); en planes EN **SÍ se traducen los nombres de Entregables** (trazabilidad vía HYPERLINK al task_id). |
| **v0.1** | 2026-06-28 | Néstor + Claude | Esqueleto: mantenimiento; reconciliación por campo; PBI vacío; idempotente; reporte a Gestión; piloto Sonnet 4.6 LS. |
| **v0.2** | 2026-06-28 | Néstor + Claude | Estructura + identidad visual + reglas de escritura segura; 5 decisiones PO formalizadas. |
| **v0.3** | 2026-06-28 | Néstor + Claude | Mapa de columnas real (40# y 41# difieren); Ideas (§9) y sync de validación dentro del alcance. |
| **v0.4** | 2026-06-28 | Néstor + Claude | **Corrección de clasificación de campos (PO):** desaparece la lista negra pura. Fecha de entrega esperada (col 8) = due_date de ClickUp (se vuelca, sin divergencia). Fecha de validación (col 9) y Notas [Cliente] (col 11) = Sheet→ClickUp (origen Cliente, nunca pisar, propagar a ClickUp). Notas Reinicia automáticas. Semáforo = desplegable con formato asociado al valor (solo escribir texto). Modelo en 3 flujos: ClickUp→Sheet / Sheet→ClickUp / Generado por Claude. |
| **v0.5** | 2026-06-28 | Néstor + Claude | Documentado el modo CREACIÓN desatendido como evolución futura. |
| **v0.6** | 2026-06-28 | Néstor + Claude | **Creación desatendida = modo activo del piloto.** Si falta el fichero v2, la skill lo crea: guardia anti-duplicados (no negociable), copia de plantilla, **idioma inferido** del cliente + nota, **granularidad por defecto = quincenas**, reflejo de ClickUp, criterio (Épica/Descripción/alcance/portada) propuesto y marcado BORRADOR pendiente de validación PO, nota consolidada en Gestión. El almacén de config por cliente pasa a mejora opcional (inferencia+defaults mientras no exista). |
| **v0.7** | 2026-06-28 | Néstor + Claude | Ámbito del piloto: los 3 (Líder System, Carritech, Breezom) los crea la skill en su 1ª pasada (sin creación supervisada previa); arranque escalonado (LS primero, luego Carritech y Breezom). |
| **v0.8** | 2026-06-28 | Néstor + Claude | **Hallazgos 1ª pasada (Líder System).** Reflejo COMPLETO de lista blanca por fila (no solo divergencias) + backfill inicial de filas viejas. **Mes** confirmado = mes de la fecha de entrega → recomputar Mes y marca de calendario al cambiar la fecha. **due_date null → "A definir"** (no vaciar). **Épica (col 2)** deja de ser objetivo de negocio (modelo B): es la agrupación del fichero (plataforma/fase), derivada consistente; no se inventa. **Log de Cambios: dar formato a las filas nuevas** (fill #EBEBEB, bordes blancos, Manrope). Orden cronológico de filas nuevas → pendiente futuro (de momento, al final). |
| **v0.9** | 2026-06-28 | Néstor + Claude | Aclaración de formato del Log: el fondo de las filas de datos es `#EBEBEB` y NUNCA blanco (sobre blanco los bordes blancos no se ven como rejilla). Aplicado a mano a las filas 10–12 del fichero de Líder System. El valor `#EBEBEB` ya estaba bien en v0.8; el fallo fue en la aplicación manual. |
| **v0.10** | 2026-06-28 | Néstor + Claude | **Endurecido el guardia; creación fuera de alcance.** La desatendida identifica el fichero por ID registrado (prompt/registro), NUNCA por búsqueda de nombre, y NUNCA crea: sin fichero por ID → reporta y omite. Motivo: la creación autónoma duplicó el Plan de LS y construyó mal (7 de 57 tareas, Config/Log vacíos, sin enlaces, fecha de validación inventada). Col 9 (validación): nunca inventar, vacía si no hay valor del Cliente. Creación de ciclo de vida (altas/bajas) reservada a v1.0. |
| **v1.0** | 2026-06-28 | Néstor + Claude | **Gestión de ciclo de vida.** Localiza el Plan por el producto "Plan de Proyecto/Marketing [año]" de ClickUp (enlace en comentario) con respaldo en la carpeta Workdrive del proyecto; **regla del doble fallo** (solo crea si fallan ambos). Creación con la lógica ÚNICA de la supervisada (backlog completo, Config, Log, enlaces), en la **carpeta del proyecto, NUNCA en Seguimiento** (crea la carpeta si falta); deja el enlace en un comentario de ClickUp. **Cambio de año:** crea el fichero del nuevo año sembrado con productos vivos (+ cerrados si la implementación inicial sigue abierta), nota al PO. **Limpieza vs ClickUp: gana ClickUp** (re-añade lo vivo + nota al PO de borrar en ClickUp). **Baja:** carpeta archivada → CONGELADO. |
| **v1.1** | 2026-06-29 | Néstor + Claude | **Reconciliación multi-tabla** (fallo de alcance detectado en la pasada del 29/06: solo se reconciliaba General y quedaban sin tocar las filas de Soporte, 39–79). Cada tabla del Plan tiene su fuente: Implementación←General; Soporte Activo←Soporte (no cerradas); Soporte Cerrado←Soporte (cerradas en el año del Plan; el resto, histórico del año de cierre). Reflejo completo incluye refrescar Notas Reinicia aunque solo cambie el estatus. Fila del Sheet sin tarea en su lista fuente → avisar al PO y no tocar. Añadido el ID de Soporte LS 211763780. |
| **v1.7** | 2026-07-04 | Néstor + Claude | **Orden y agrupación por Épica.** Épica = objetivo de negocio con prefijo numérico (orden intrínseco). Filas ordenadas por Épica → `date_created` (fecha de petición, leída del hyperlink de ClickUp del Entregable) → fecha de entrega, dentro de cada tabla. Reorden + recoloreado de Épica + redibujado de calendario van juntos (paso dedicado); mapear por Entregable entre pestañas desfasadas. |
| **v1.6** | 2026-07-04 | Néstor + Claude | **Regla de oro de formato: estilo canónico SIEMPRE al escribir.** Al escribir o insertar cualquier celda, aplicar el estilo que le corresponde (fondo, bordes, Manrope, color `#545454`, alineación, altura); nunca dejar el formato "por defecto" por no poder leer el existente — es lo que dejó el Log en negro/blanco y el Config a medias. |
| **v1.5** | 2026-07-04 | Néstor + Claude | **Épica híbrida (se deshace el "alinear a la app" de v0.8) + Config a dos columnas.** Épica: microcampaña → fase de funnel (campo ÉPICA de ClickUp, lista blanca); producto digital → objetivo de negocio propuesto por Claude (BORRADOR + validación PO), NUNCA la app/plataforma. Config: cada referencia en dos columnas (Nombre legible · ID/Resource que lee la máquina) para 7 campos; la skill lee el ID de su columna, sin parsear. |
| **v1.4** | 2026-07-04 | Néstor + Claude | **Base gris de la rejilla del calendario.** Las celdas de datos del calendario (40# cols M–AJ; 41# cols L–AI) llevan fondo `#F2F2F2` por defecto (no blanco); los hitos (`#70EED6` entrega / `#EBE31B` validación) se pintan encima. Al (re)dibujar, poner primero toda la rejilla de datos en `#F2F2F2` y luego los hitos; redibujar la rejilla completa. |
| **v1.3** | 2026-07-04 | Néstor + Claude | **Inserción antes de la penúltima (todas las tablas) + agrupación de Épica + reglas de la 1ª validación multi-tabla.** (a) En CUALQUIER tabla de cualquier pestaña, nunca rellenar hasta el final: insertar antes de la penúltima fila y pegar (el Log es la excepción: añadir al final + aplicar formato explícito, porque no hay cuerpo preformateado). (b) Agrupación visual por Épica en col 2 de 40#/41#: fondo alternando `#70EED6`/`#BFBFBF` cada vez que cambia la épica. (c) Tarea `done` en General sin fila → añadir a Implementación en BORRADOR + avisar. (d) Ticket de Soporte cerrado sin fecha → dejar fuera + avisar. (e) Registrar SIEMPRE en el Log al cierre (la 1ª pasada multi-tabla se lo saltó). Corregidos a mano en LS: realineación de Descripción en 40# (filas 70–79) y las dos entradas del Log que faltaban. |
| **v1.2** | 2026-06-29 | Néstor + Claude | **Filas nuevas por herencia de formato.** Toda fila nueva (Log y cualquier tabla) se añade por INSERCIÓN (`ZohoSheet_insert_row`), heredando el formato de la fila anterior — NUNCA escribiendo en celdas vacías + reformateando a mano (que dejó las filas 13–14 del Log de PRUEBA-2 sin cuadrar). Generaliza §8 al Log. |

---

## PENDIENTES DE EVOLUCIÓN
- **Limpiar filas placeholder vacías** sobrantes bajo las tablas (p. ej. Soporte Cerrado) tras sembrar/insertar.
- ✅ *(Resuelto v2.8 supervisada)* La skill hermana `plan-proyecto-zoho-sheet-reinicia` ya lleva el **bloque de versión estándar** (cabecera + tabla `## Versiones`); el script de sync puede protegerla por versión.
- ✅ *(Resuelto v1.8)* El **filtro de "cerrada en el año"** del Soporte usa **`date_closed`** (hoy leído de `clickup_get_task`; lo expondrá `clickup_plan_fields` cuando se despliegue); cerrado sin fecha → fuera + aviso. Confirmar el campo exacto en la 1ª pasada multi-tabla real.
- **Cablear la creación unificada** (que la desatendida ejecute el procedimiento de creación de la
  supervisada, no una versión propia) ANTES de habilitar creación autónoma en producción. Es la
  dependencia crítica de §B/§C.
- **Desplegar `clickup_plan_fields`** en Catalyst (`Reinicia-Clickup-Audit`) — dependencia de coste para el volcado en una pasada (§palanca de coste / LIMITACIONES #1).
- **Confirmar la lectura del flag `archived`** de carpeta/lista vía MCP de ClickUp (gatea §E/bajas).
- **Afinar la inferencia** del nombre del producto Plan (similitud tipo+año) y del idioma del cliente
  en la 1ª ejecución real.
- **Almacén de configuración por cliente** (granularidad/formato/alcance atípicos) como mejora
  opcional (hoy: idioma leído de Config/Portada + defaults deterministas — ver §B).
- Calibrar presupuesto de troceo y criterio de reanudación (1ª pasada).
- Confirmar mecanismo exacto de "informar Notas [Cliente] en ClickUp" (comentario en la tarea).
- **Orden cronológico** de filas nuevas dentro de cada tabla (futuro; de momento al final, a revisar cuando los POs trabajen los Planes).
- Especificar tool calls celda a celda del PASO 3 y de los empujes Sheet→ClickUp.
- Confirmar nomenclatura de la skill.
- Incorporar Breezom y Carritech cuando tengan fichero v2.
