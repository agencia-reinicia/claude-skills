---
name: revision-sprint-backlog-equipo-reinicia
description: >
  Skill para revisar y actualizar periódicamente los Sprint Backlogs operativos del Equipo de Reinicia.
  Cruza las horas reales de ClickUp con el plan comprometido en cada Sprint Backlog y deja el fichero
  al día: repuebla la hoja Data con los time entries del sprint, aplica renames en Tiempos para match
  exacto (con validación previa del PO), inserta huérfanas (productos fuera de plan, soporte, BUGs,
  forms) dentro del bloque principal, crea el bloque "Metodología y Gestión" (ceremonias y gestiones
  mensuales) fuera de la tabla principal, y registra todo cambio en la hoja Log de Cambios.

  Actívala cuando el PO líder pida: "actualiza el AUTOIA de [persona/equipo]", "actualiza los sprint
  backlogs del equipo con horas reales", "revisa el sprint backlog operativo de [persona/equipo]",
  "vamos a actualizar los sprint backlogs", o cuando se ejecute la tarea programada semanal.

  Frecuencia: semanal mediante tarea programada y a demanda. Complementa a sprint-planning-reinicia.
---

# SKILL: Revisión de Sprint Backlog del Equipo Operativo — Reinicia

## Propósito

Mantener al día los **Sprint Backlogs individuales** de cada miembro del Equipo Operativo durante el sprint, sincronizándolos con las horas reales trabajadas en ClickUp. Esto permite:

- **Visibilidad temprana de desvíos** entre lo planificado y lo ejecutado.
- **Captura sistemática del trabajo no planificado** (productos fuera de plan, soporte, microcampañas, ceremonias).
- **Insumo para los Informes Ejecutivos** semanales y de cierre de sprint por Equipo.
- **Detección de problemas operativos**: productos de Soporte sin estimación, sobrecarga estructural, dependencias entre miembros del equipo, motivos de desvío reincidentes.

La skill **NO planifica** (eso lo hace `sprint-planning-reinicia` al inicio del sprint) ni **crea productos en ClickUp**. Solo lee de ClickUp y escribe en el Sprint Backlog del Zoho Sheet.

---

## ÁMBITO DE APLICACIÓN

### En esta primera fase (validación)
La skill se aplica sobre los **ficheros AUTOIA duplicados** que el PO líder crea en la carpeta del sprint para cada miembro del equipo.

### Objetivo final
A futuro, la skill se aplicará **directamente sobre los ficheros oficiales de Sprint Backlog** que se generan en cada Sprint Planning, sin duplicación. La estructura del fichero es la misma; el flujo no cambia.

---

## EQUIPOS Y MIEMBROS — PRINCIPIO DE BÚSQUEDA DINÁMICA

⚠️ **Esta skill NO mantiene una lista hardcoded de Equipos ni de miembros.** Equipos, miembros y clientes cambian sprint a sprint: aparecen Amigos Reinicia, salen miembros, se reorganizan.

### Cómo identifica Equipos y miembros

Al activarse, la skill **siempre confirma** con el PO líder:

1. **Si el PO ya menciona persona(s) concreta(s)**: confirma que son las correctas y procede.
2. **Si el PO pide "el Equipo X" o "todo el equipo"**: la skill consulta ClickUp para listar los miembros que pertenecen a ese Equipo (vía espacios y asignaciones de tareas) y los presenta al PO para confirmación antes de procesar.
3. **Si hay personas transversales** (ej. una persona que trabaja en dos Equipos a la vez): la skill las detecta y pide al PO que confirme en qué contexto procesarlas.

**Ejemplo de confirmación inicial:**
```
He detectado estos miembros activos en ClickUp del Equipo [X] durante el Sprint actual:

  - [Persona 1] — [N] tareas, [H]h tracked
  - [Persona 2] — [N] tareas, [H]h tracked
  - [Persona 3] — [N] tareas, [H]h tracked (también activa en Equipo [Y])

¿Procedo con todas? ¿Excluyo a alguna? ¿Falta alguien que no aparezca aún?
```

### Caso especial: persona en ClickUp sin Sprint Backlog Zoho

Hay personas que están en ClickUp imputando horas pero **no tienen un Sprint Backlog propio en Zoho** — típicamente Amigos Reinicia que ayudan en soporte de clientes (ejemplo histórico: Síntaris — Óscar Seuba `99694542` y David Marco `99694543`).

La skill debe:

1. **Detectarlo** comprobando si el PO ha aportado un fichero AUTOIA para esa persona o si existe en la carpeta del sprint.
2. **Proponer al PO** un flujo reducido: no se procesa Sprint Backlog (no existe), pero **se crea una pestaña con sus horas reales agregadas en el Informe Ejecutivo del Equipo correspondiente**.
3. **Confirmación explícita** antes de proceder: "He detectado a [persona] imputando horas en ClickUp pero sin Sprint Backlog Zoho. Te propongo añadirla al Informe Ejecutivo del Equipo [X] como pestaña aparte con sus horas. ¿Procedo así o prefieres otro tratamiento?"

---

## ESTRUCTURA CANÓNICA DEL SPRINT BACKLOG

Todo Sprint Backlog (oficial o AUTOIA) debe tener al menos estas hojas:

| Hoja | Propósito | Formato |
|---|---|---|
| `Tiempos` | Plan vs ejecutado, fila por producto, totales y resumen | Plan + huérfanas + bloque metodología |
| `Data` | Time entries crudos pegados desde ClickUp | Una fila por entry |
| `Log de Cambios` | Auditoría de modificaciones de la skill | Append-only |

Otras hojas pueden coexistir (Hoja1, Hoja2, Ideas) pero la skill solo opera sobre `Tiempos`, `Data` y `Log de Cambios`.

### Estructura de la hoja Tiempos

⚠️ **Las columnas de Tiempos pueden estar desplazadas entre ficheros.** Algunos ficheros tienen Concepto en `D` (col 4) y otros en `E` (col 5). **La skill SIEMPRE inspecciona la fila de cabeceras primero** (típicamente fila 3 en AUTOIAs y fila 4 en algunas variantes) para mapear:

- Columna **Marca** (A en plantilla, col 1) — texto identificativo de huérfanas (`🤖 Fuera de plan` / `🤖 Soporte/WIP`)
- Columna **Orden** (B en plantilla, col 2) — numeración asignada en Sprint Planning
- Columna **Status** (C en plantilla, col 3)
- Columna **Concepto** (D en plantilla, col 4) — clave del SUMAR.SI
- Columna **Cliente** (E en plantilla, col 5)
- Columna **Horas estimadas** (F en plantilla, col 6)
- Columna **Fecha límite** (G en plantilla, col 7)
- Columna **ClickUp Registro** (J en plantilla, col 10) — suma SUMAR.SI
- Columna **Diferencia horas** (K en plantilla, col 11)
- Columna **Motivo desvío** (L en plantilla, col 12, dropdown)
- Columna **Comentario** (M en plantilla, col 13, texto libre)

⚠️ La skill verifica este mapeo en cada fichero antes de operar. Si las columnas están desplazadas, recalcula los offsets desde la fila de cabeceras detectada.

Bloques estándar (numeración variable según fichero):

1. **Sprint Backlog principal** — productos planificados con campo Orden numerado
2. **Buffer vacío** (1-3 filas) entre bloques distintos
3. **Productos Reinicia internos** — sin orden, status SPRINT BACKLOG (formación, marketing, etc.)
4. **Buffer vacío**
5. **Soportes mensuales por cliente** — sin orden, status SPRINT BACKLOG
6. **Buffer vacío** ← **importante: esta skill NO consume todos los huecos al insertar huérfanas; deja al menos 1 fila libre por bloque para futuras inserciones**
7. **TOTAL HORAS OPERATIVAS ESTIMADAS** — `=SUMA(F[ini]:F[fin])` del Sprint Backlog completo
8. **TOTAL HORAS OPERATIVAS DISPONIBLES** — capacidad del PO + suma SUMAR.SI de la columna I
9. **TOTAL BALANCE DE HORAS** — disponibles - estimadas
10. Bloque resumen (Horas totales sprint / Operativas / Facturable / No Facturable)

### Recomendación al Sprint Planning inicial

Cuando un Sprint Planning crea un nuevo Sprint Backlog (vía `sprint-planning-reinicia`), **debe dejar huecos entre bloques** (mínimo 2-3 filas vacías por bloque) para que esta skill pueda insertar huérfanas sin romper el formato heredado. Si el Sprint Backlog viene "comprimido" sin huecos, esta skill avisará al PO antes de continuar.

### Tabla de Metodología — pendiente de creación

A futuro, el bloque Metodología y Gestión que esta skill construye fuera de Tiempos pasará a ser una tabla canónica predefinida del Sprint Backlog (igual que las demás). De momento, la skill lo crea manualmente cada vez. Esto se gestionará externamente cuando se actualicen las plantillas oficiales.

---

## FLUJO COMPLETO

### PASO 0 — Confirmación inicial dinámica

La skill **siempre confirma antes de tocar ningún fichero** lo siguiente:

1. **Equipo o persona(s) a procesar.** Si el PO no lo dice explícitamente, la skill consulta ClickUp y propone una lista para confirmar.
2. **Clientes activos en el sprint** para ese Equipo/persona (extraídos de las imputaciones reales).
3. **Personas transversales** detectadas (aparecen en varios Equipos): pedir al PO que indique en qué contexto procesarlas.
4. **Personas sin Sprint Backlog Zoho** (caso Amigos Reinicia): proponer flujo reducido.
5. **Modo de ejecución**: ¿pregunto antes de cada miembro o proceso todos seguidos?
   - Por defecto: preguntar antes de cada uno.
   - Si el PO dice explícitamente "procesa todos sin parar", omitir confirmaciones intermedias y reportar resumen al final.

### PASO 1 — Inspección inicial del fichero

1. **Listar worksheets** con `ZohoSheet_list_all_worksheets`. Identificar `worksheet_id` de Tiempos, Data y Log de Cambios.
2. **Si no existe Log de Cambios**, crearla (sub-paso 1a).
3. **Inspeccionar fila de cabeceras de Tiempos** (típicamente fila 4) para mapear columnas Concepto, Status, Cliente, Horas estimadas, ClickUp Registro, Diferencia horas, **Motivo desvío** y **Comentario**.
4. **Identificar la fila TOTAL HORAS OPERATIVAS ESTIMADAS** y guardar su número.
5. **Identificar el rango del Sprint Backlog principal** (de fila 5 hasta antes del TOTAL).
6. **Capturar estado pre-cambio** en Log de Cambios: total horas plan, total tracked actual, total filas Sprint Backlog, fecha y hora de la ejecución, número de huecos vacíos detectados entre bloques.

#### Sub-paso 1a — Asegurar hoja `Log de Cambios` con TablaLog y formato Reinicia

La hoja `Log de Cambios` debe estar estandarizada en todos los Sprint Backlogs **como tabla formal** (`TablaLog` o equivalente, ver nota más abajo) con formato Reinicia heredable. Esto garantiza que cada nueva entrada herede automáticamente Manrope, alto de fila y bandeo gris/blanco — lo que evita el bug histórico de inserciones sin formato.

##### Si el fichero no tiene la hoja `Log de Cambios`

1. **Crear la hoja** con `ZohoSheet_create_worksheet`.
2. **Escribir cabeceras canónicas en fila 1** (11 columnas):

   ```
   Fecha | Hora | Pestaña | Fila | Columna | Producto | Valor anterior | Valor nuevo | Motivo | Operador | Fuente
   ```

3. **Crear tabla con estilo Reinicia** vía `ZohoSheet_create_table`:

   ```
   start_row = 1, start_column = 1, end_row = 2, end_column = 11
   table_style = {
     template: "MEDIUM2",
     color: "#3812CF",
     properties: { banded_rows: true, first_column: false, last_column: false }
   }
   ```

   ⚠️ **Limitación conocida**: Zoho asignará automáticamente un nombre tipo `Table2` o `Table3` (numeración global secuencial). NO existe método `rename_table` en el MCP de Zoho — solo `rename_headers_of_table`. La skill no puede forzar el nombre `TablaLog`; convive con el nombre asignado.

4. **Aplicar formato celda Manrope a A2:K(última)** vía `ZohoSheet_format_ranges`:

   ```
   {
     range: "A2:K2",
     font_name: "Manrope",
     font_size: 10,
     row_height: 22,
     vertical_alignment: "middle",
     wrap_text: true
   }
   ```

5. **Aplicar formato cabecera A1:K1** (negrita azul Reinicia):

   ```
   {
     range: "A1:K1",
     bold: true,
     fill_color: "#D9D0FB",
     font_color: "#3812CF",
     font_name: "Manrope",
     font_size: 10,
     row_height: 28,
     vertical_alignment: "middle"
   }
   ```

6. **Registrar primera entrada** en fila 2: `[fecha] | [hora] | Log de Cambios | 1 | - | - | - | - | INICIALIZACIÓN | Skill | Hoja Log de Cambios creada por revision-sprint-backlog-equipo-reinicia`.

##### Si el fichero ya tiene la hoja `Log de Cambios` pero NO tiene tabla formal sobre ella

Detectado vía `ZohoSheet_list_all_tables` (ninguna tabla en la hoja `Log de Cambios`). Esto es típico en AUTOIAs procesados con versiones anteriores de la skill.

1. **Verificar el rango actual usado** con `ZohoSheet_get_used_area` para conocer `last_row`.
2. **Crear tabla formal sobre todo el rango actual** A1:K[last_row] con `table_style` y limitaciones idénticas al caso anterior (paso 3).
3. **Aplicar formato a A2:K[last_row]** (Manrope 10, alto 22pt, alineación middle, wrap_text true) vía `format_ranges`.
4. **Aplicar formato cabecera A1:K1** (idéntico al caso anterior).
5. **Aplicar bandeo manual fila a fila** (ver sub-paso 1b siguiente).
6. **Registrar entrada de migración**: `[fecha] | [hora] | Log de Cambios | - | - | - | - | - | TABLA_LOG_CREADA | Skill | TablaLog creada sobre Log de Cambios existente para garantizar formato Reinicia consistente`.

##### Si el fichero ya tiene tabla formal sobre Log de Cambios

Saltar a sub-paso 1b para asegurar bandeo correcto en filas existentes.

#### Sub-paso 1b — Bandeo manual explícito de filas

⚠️ **Limitación crítica**: el `template MEDIUM2` + `banded_rows: true` de `create_table` **no garantiza bandeo visible** cuando ya hay celdas con formato de fondo previo (típico en filas pegadas con `csvdata.set` que llevan fill blanco implícito). El bandeo de la tabla queda "tapado" por el fill explícito de las celdas.

**Solución**: tras crear/asegurar la tabla, aplicar bandeo manual fila a fila vía `format_ranges`:

```
for fila in range(2, last_row + 1):
    fill = "#EBEBEB" if fila % 2 == 1 else "#FFFFFF"
    format_ranges(range="A{fila}:K{fila}", fill_color=fill)
```

Convención: filas pares (2, 4, 6...) blancas (`#FFFFFF`), filas impares (3, 5, 7...) gris claro (`#EBEBEB`).

Aplicar este bandeo:
- Tras la creación inicial de la hoja (sub-paso 1a, caso "no existe").
- Tras la migración a TablaLog (sub-paso 1a, caso "existe sin tabla formal").
- Tras cada inserción de nuevas filas durante la ejecución (al final del proceso, recalculando `last_row`).

#### Sub-paso 1c — Sello de actualización en cabecera

La skill estampa la fecha y hora de la última ejecución en dos celdas:

- **Pestaña Tiempos, celda D1**: `Última actualización (skill): DD/MM/AAAA HH:MM — Sprint X-YY`. Aplicar también `row_height: 45, vertical_alignment: middle` sobre la fila 1 para que el sello se vea holgado.
- **Pestaña Log de Cambios, celda M1**: mismo texto, posición fuera del rango de TablaLog (que cubre A:K) para que actúe como metadato suelto sin entrar en la tabla.

Estos sellos se actualizan al final de cada ejecución (no al inicio). Si el sello previo existe, se sobreescribe con el timestamp actual.

Registrar en Log de Cambios: `[fecha] | [hora] | Tiempos | 1 | D | - | [sello previo o vacío] | [sello nuevo] | SELLO_ACTUALIZACION | Skill | Sello de fin de ejecución`.

### PASO 2 — Recopilación de time entries de ClickUp

Usar `clickup_get_time_entries` con `assignee_id` del miembro y rango de fechas del sprint.

Si el endpoint falla con error de validación JSON (caso típico: time entries sin task asociada), **fragmentar el rango en bloques temporales más pequeños** (días u horas) hasta aislar la entrada problemática. Las entradas no recuperables se omiten y se reportan al final del proceso (timestamp, duración aproximada, usuario).

El resultado de este paso es el listado completo de entries en memoria, listo para pegar en la pestaña Data en el Paso 3.

### PASO 3 — Poblar la pestaña Data con los time entries del sprint

⚠️ **Operación potencialmente destructiva**. Registrar en Log de Cambios antes de tocar nada.

La skill trabaja siempre sobre la pestaña `Data` original del fichero. **NO se crean pestañas auxiliares**: una sola fuente de verdad de time entries por AUTOIA.

#### Sub-paso 3a — Inspeccionar el estado actual de Data

Antes de tocar nada, inspeccionar la pestaña `Data` con `ZohoSheet_get_used_area` y `ZohoSheet_list_all_tables` para detectar:

- Cuántas filas tiene actualmente (excluida cabecera).
- Si tiene una tabla definida (típicamente `Tabla1`) y cuál es su rango.
- Si el contenido parece time entries del sprint actual, time entries de un sprint anterior, o datos de otro tipo (tasks, agregados, listados de referencia).

#### Sub-paso 3b — Confirmar con el PO cómo proceder

Presentar el estado actual al PO y proponer una de tres acciones:

```
Pestaña Data — estado actual:
  - [N] filas pobladas
  - Tabla [Tabla1] con rango [start_row]:[end_row]
  - Muestra: [primera/última fila para que el PO identifique el contenido]

¿Cómo procedemos?

  (A) Borro yo el contenido actual de Data y pego los time entries del sprint.
  (B) Borras tú el contenido manualmente y luego me avisas para que pegue los nuevos.
  (C) Data ya tiene los time entries correctos del sprint actual y no hay que tocarla.
```

- Si el PO elige **(C)**, la skill verifica con `=SUMA(BE2:BE[última])` que las horas trackeadas coinciden con `clickup_get_time_entries` del rango del sprint y, si cuadran, salta al Paso 4 sin tocar Data.
- Si el PO elige **(B)**, la skill espera la confirmación del PO antes de continuar.
- Si el PO elige **(A)**, la skill ejecuta el sub-paso 3c.

#### Sub-paso 3c — Vaciar Data y pegar entries (acción automatizada)

1. **Anotar en Log de Cambios**: `[timestamp] | DATA_CLEAR | Vaciado de hoja Data antes de pegar registros sprint actual | [N] filas | 0 filas`.
2. **Vaciar** con `ZohoSheet_clear_contents_of_range` el rango `A2:BD[última fila]`. Esto preserva la cabecera (fila 1) y la estructura de Tabla1 si existe.
3. **Verificar el estado de Tabla1**: con `ZohoSheet_list_all_tables` comprobar si la tabla sigue existiendo y su rango. Si Tabla1 ha quedado con un rango antiguo inconsistente con los datos vacíos, se ajustará al pegar los nuevos entries (Zoho Sheet típicamente extiende la tabla automáticamente al pegar dentro de su rango).
4. **Pegar registros** en lotes de ~5-10 filas / ~3000 chars vía `worksheet.csvdata.set` empezando en fila 2 (la API soporta hasta ~5000 chars pero conviene mantenerlo conservador para evitar timeouts).
5. **Verificar Tabla1 post-pegado**: confirmar que el rango cubre todas las filas pegadas. Si no, reextender la tabla manualmente.
6. **Aplicar fórmula `Horas Traqueadas`** en col 57 fila 2 si no estaba ya (`=Tabla1[@Column11]/3600000`). La tabla la propaga automáticamente a las demás filas.
7. **Verificar suma**: `=SUMA(BE2:BE[última])` ≈ total ClickUp.
8. **Anotar en Log de Cambios**: `[timestamp] | DATA_PASTE | Pegado de N entries del sprint en Data | 0 filas | N filas | Total horas: [X]h`.

#### Cabeceras canónicas de Data (58 columnas)

```
Column1, Column2, Column3, Column4, Column5, Column6, Column7, Column8, Column9, Column10, Column11, Column12, Column13, Column14, Column15, Column16, Column17, Column18, Column19, Column20, Task Status, Due Date, Due Date Text, Start Date, Start Date Text, Task Time Estimated, Task Time Estimated Text, Task Time Spent, Task Time Spent Text, User Total Time Estimated, User Total Time Estimated Text, User Total Time Tracked, User Total Time Tracked Text, Tags, Checklists, User Period Time Spent, User Period Time Spent Text, Date Created, Date Created Text, Custom Task ID, Parent Task ID, AVANCE DE PRODUCTO, Sobrepasado, Tiempo Registrado Mayor que Estimado, Tiempo restante, CLIENTE, PO, REFINADO, TIPO DE PRODUCTO, OBJETIVO/NECESIDAD, PBIs PRIMER NIVEL, ÉPICA, ORDEN, Álvaro Estima, ID Propuesta, NOTAS PARA CLIENTE, Horas Traqueadas, Situación
```

Donde:
- `Column11` = Duration en ms (clave para fórmula `Horas Traqueadas`)
- `Column20` = Concepto = nombre de la tarea ClickUp (clave para SUMAR.SI)
- `Horas Traqueadas` (col 57) = `=Tabla1[@Column11]/3600000`

#### Estructura resumen de los datos pegados

| Col | Contenido |
|---|---|
| 1-19 | Datos del time entry (id, fechas, descripción, usuario, duración en ms, etc.) |
| 11 | Duration en ms (Column11) |
| 20 | **Concepto** = nombre de la tarea (Column20) ← **clave para SUMAR.SI** |
| 21+ | Status, Due Date, custom fields, tags, etc. |
| 57 (BE) | **Horas Traqueadas** = `=Tabla1[@Column11]/3600000` |

#### Caveats al pegar entries

- **Caracteres especiales en descripciones**: acentos, comillas, signos `+`. Al construir el CSV, escapar con comillas dobles. El motor de Zoho convierte `+` a espacio en algunos contextos (ej. timestamps Form Submission) — ver Bug 3 de la sección de bugs al final de la skill.
- **Timestamps**: vienen en ms epoch desde ClickUp. La columna `Horas Traqueadas` los convierte a horas decimales con fórmula.
- **Filas vacías intermedias**: si un lote falla a mitad, no continuar pegando hasta diagnosticar — reanudar con el lote completo desde el principio.

#### Registro en Log de Cambios

| Operación | Caso |
|---|---|
| `DATA_CLEAR` | Vaciado de Data (sub-paso 3c) |
| `DATA_PASTE` | Pegado de entries en Data (sub-paso 3c) |

### PASO 4 — Análisis de huérfanas y validación de emparejamientos

Se detectan los **conceptos en Data!Column20 que NO están en Tiempos!Concepto**.

#### Clasificación automática por keywords

| Grupo | Keywords / Heurística (mayúsculas) | Marca Col A | Destino |
|---|---|---|---|
| **A** Metodología y Gestión | `DAILY`, `SPRINT PLANNING`, `REFINAMIENTO`, `RETROSPECTIVE`, `GESTI` (matchea "Gestión", "Gestion"), `[REINICIA] FORMACIÓN`, `FORMACIÓN ZOHO` | (sin marca — se sitúa en bloque propio fuera de Tabla2) | Bloque "Metodología y Gestión" APARTE, después del TOTAL de Tabla2 |
| **B** Todo lo demás | Resto de conceptos no planificados | (ver sub-marcas abajo) | DENTRO de Tabla2, antes del TOTAL ESTIMADAS |

Sub-marcas dentro del Grupo B (columna A):

| Sub-marca | Heurística | Casos típicos |
|---|---|---|
| `🤖 Fuera de plan` | Producto digital nuevo no contemplado en planning, con corchete de cliente, estructura de producto reconocible | SPIKEs no planificados, productos cliente nuevos, gestiones cliente del mes (`Gestión abril 2026 [CLIENTE]`), gestiones internas Reinicia (`Gestión Reinicia TODOS [Mes]`), incidencias específicas (`Incidencia conector...`), productos en validación que entran fuera de plan |
| `🤖 Soporte/WIP` | Microtarea reactiva, prefijo `[SUPPORT]` o `[ASSUMED IN THE GUARANTEE]`, `[BUG]`, `Form Submission` en el nombre, o tarea de muy corta duración sin estructura de producto | Tickets de soporte vía formulario ClickUp, Form Submissions, BUGs reportados |

⚠️ Nota crítica sobre conceptos que empiezan por `Gestión` o `Refinamiento`: NO todos van al Grupo A. La regla operativa es:
- Ceremonias con sufijo `[METODOLOGÍA REINICIA]` (`Daily 2026`, `Sprint Planning 2026`, `Retrospective 2026`) → **Grupo A**
- Refinamientos del equipo (`Refinamiento 2026 [INEFSO]`, `Refinamiento 2026 [GONHER]`, etc. — donde el corchete identifica al equipo, no al cliente) → **Grupo A**
- `[REINICIA] Formación Zoho` y formaciones internas similares → **Grupo A**
- `Gestión [Mes] 2026 [CLIENTE]` (gestión mensual de un cliente concreto) → **Grupo B `🤖 Fuera de plan`**
- `Gestión Reinicia TODOS [Mes] 2026 [REINICIA]` (gestión interna del equipo Reinicia) → **Grupo B `🤖 Fuera de plan`**

La keyword `GESTI` del Grupo A se reserva a las ceremonias con sufijo `[METODOLOGÍA REINICIA]` o `[REINICIA]`. En caso de duda, preguntar al PO.

#### Caso ambiguo

Si la skill no encuentra match claro de keyword:

1. **Preguntar al PO líder**: "He encontrado el concepto huérfano `[X]` con `[Y]h` traqueadas. ¿Lo clasifico como A (Metodología/Gestión, va APARTE), B-Fuera de plan (producto digital, va DENTRO de Tabla2) o B-Soporte/WIP (microtarea reactiva, va DENTRO de Tabla2)?"
2. **Tras la respuesta, proponer mejorar la skill** con la nueva regla de clasificación: "Te propongo añadir keyword `[Z]` al Grupo `[X]` en la skill. ¿Lo hago?"
3. Si el PO acepta, **registrar el cambio propuesto** para incluirlo al final como entrada en "Mejoras Propuestas Skill Sprint Backlog: documentar en Reinnova ClickUp" del Informe Ejecutivo del Equipo correspondiente.

#### Renames de Tiempos (concepto del plan ≠ concepto de ClickUp)

A veces el plan inicial usa nombres "humanos" que no coinciden exactamente con el nombre canónico en ClickUp. Otras veces, en cambio, **un nombre similar corresponde a un producto distinto** y NO debe renombrarse. La skill propone emparejamientos pero **NO aplica nada hasta validación explícita del PO**.

#### Detección de candidatos a rename

Comparar cada concepto del Sprint Backlog principal con los conceptos de Data!Column20 buscando similitudes textuales: caracteres distintos en puntuación, espacios, corchetes, guiones, mayúsculas/minúsculas, acentos, prefijos/sufijos opcionales (`[SUPPORT]`, `[BUG]`, etc.).

#### Presentación al PO — propuesta y antipropuesta

Cada candidato se presenta con:

1. **Concepto del plan** (en Tiempos)
2. **Concepto candidato en Data** (que se propone como rename)
3. **Horas reales que se recuperarían si el rename se aplica**
4. **⚠️ Verificación previa**: la skill comprueba si en Data hay también **otra entrada distinta del candidato** que podría ser un producto independiente con el mismo cliente. Si la hay, se avisa explícitamente.

Formato de presentación:

```
He detectado posibles renames en Tiempos. Por favor, valida uno a uno:

✅ Caso 1 — Rename limpio (sin ambigüedad detectada):
  Fila 6 plan: "Despliegue Guadalajara y CDMX GONHER"
  Candidato Data: "Despliegue Guadalajara y CDMX [GONHER]"
  Diferencia: corchete de cliente.
  Recuperaría: 5,47h
  ¿Renombro?

⚠️ Caso 2 — Posible producto distinto:
  Fila 5 plan: "Despliegue Guadalajara y CDMX [GONHER]"
  Candidato Data: "Despliegue Guadalajara y CDMX 2 [GONHER]"
  Recuperaría: 4,12h
  PERO en Data también existe el literal exacto "Despliegue Guadalajara y CDMX [GONHER]"
  con 8,23h. Esto sugiere que son DOS productos distintos del mismo cliente.
  ¿Confirmas que son productos separados (no renombrar) o que son el mismo (renombrar)?
```

#### Criterios para NO renombrar

El PO debe rechazar el rename cuando:

1. **Existen ambos literales en Data**: el concepto del plan y el candidato aparecen simultáneamente como entradas independientes en Data!Column20. Esto indica dos productos distintos con nombres similares.
2. **El "rename" cambia el alcance del producto**: ej. añadir `[SUPPORT]` al inicio o `2` al final puede ser una microtarea relacionada pero no la misma. La skill **debe preguntar siempre** antes de añadir prefijos `[SUPPORT]` o sufijos numéricos.
3. **El cliente del corchete cambia**: nunca renombrar entre conceptos con corchetes de cliente distintos (`[GONHER]` vs `[CARRITECH]`).
4. **El PO así lo decide** por contexto que la skill no puede inferir (decisiones de producto, separación intencional de fases, etc.).

#### Casos validados de NO rename (sesión real Sprint 5-26)

- Johanna: `Despliegue Guadalajara y CDMX` (Row 5 plan) NO se renombra a la versión que aparece en Data — son tareas distintas según criterio del PO.
- Alejandro: casos 5 y 6 propuestos por la skill rechazados por el PO — productos distintos con nombres parecidos.

#### Aplicación del rename

⚠️ **Nunca aplicar un rename sin validación explícita del PO emparejamiento por emparejamiento.** Cada rename aprobado se registra en Log de Cambios:

```
[timestamp] | TIEMPOS_RENAME | Tiempos!D[fila] | "[antes]" | "[después]"
```

Cada rename rechazado también se registra como referencia para futuras revisiones del mismo sprint:

```
[timestamp] | TIEMPOS_RENAME_RECHAZADO | Tiempos!D[fila] | "[antes propuesto]" | "[concepto Data candidato]" | Motivo: [productos distintos / decisión PO / etc.]
```

#### Bug operativo: timestamps con `+`

Cuando se renombra un concepto que contiene un timestamp tipo `#2026-03-26T06:09:13+01:00`, hay que escribir el literal **sin `+`** (`#2026-03-26T06:09:13 01:00`) porque el motor de Zoho Sheet pierde el `+` al procesar la entrada de la fórmula SUMAR.SI. Verificar con `=COINCIDIR` que el match se produce. Detectado en sesión real con Fabián Sprint 5-26.

### PASO 5 — Inserción de huérfanas Grupo B en Tabla2

⚠️ **Operación destructiva**. Registrar antes en Log de Cambios.

#### Posición de inserción

🚨 **Regla crítica**: las huérfanas Grupo B se insertan SIEMPRE DENTRO del rango actual de Tabla2, en una posición intermedia que respete los siguientes criterios:

**Posición permitida**:
- Entre `Tabla2.start_row + 2` (segunda fila después de la cabecera) y `Tabla2.end_row - 1` (penúltima fila rellena de la tabla).
- NUNCA en la primera fila de datos, NUNCA en la última fila rellena, NUNCA fuera del rango de Tabla2.

**Por qué importa**:
1. **Tabla2 se extiende automáticamente** y las nuevas filas quedan incluidas en SUMA, SUMAR.SI y demás fórmulas de totales.
2. Las nuevas filas **heredan formato y fórmulas** de las filas adyacentes (Col K diferencia, validaciones de fechas, colores alternos, bordes).
3. La fila TOTAL ESTIMADAS, TOTAL DISPONIBLES y TOTAL BALANCE recalculan correctamente.

**Separación visual mínima**:
- 1 fila vacía DENTRO de Tabla2 ANTES del bloque de huérfanas.
- 1 fila vacía DENTRO de Tabla2 DESPUÉS del bloque de huérfanas.
- Esto separa visualmente el bloque de huérfanas del resto del plan original.

#### Cómo elegir la posición — algoritmo

1. **Consultar el rango actual de Tabla2** con `ZohoSheet_list_all_tables` (`start_row`, `end_row`).

2. **Buscar hueco existente** dentro del rango permitido (`start_row+2` a `end_row-1`):
   - Recorrer las filas y detectar zonas con N filas vacías consecutivas, donde N = número de huérfanas a insertar + 2 filas vacías de separación (1 antes + 1 después).
   - Si existe un hueco así, usarlo: pegar las huérfanas dejando una fila vacía libre antes y otra después.

3. **Si no hay hueco suficiente, crear filas**:
   - Elegir una posición intermedia dentro del rango permitido (típicamente justo después del último bloque de productos Reinicia internos, o en cualquier zona que no rompa un bloque temático existente).
   - Llamar `ZohoSheet_insert_row` (N + 2) veces consecutivas en la misma posición — N filas para las huérfanas + 2 filas vacías de separación.
   - Cada llamada inserta una fila vacía empujando el resto +1, y `Tabla2.end_row` se incrementa automáticamente.

⚠️ NO insertar:
- En `Tabla2.start_row + 1` (primera fila de datos — rompe coherencia visual).
- En `Tabla2.end_row` (última fila — quedaría como nueva penúltima sin separación).
- Fuera de Tabla2 (después de `end_row` o antes de `start_row`): la fila no se sumaría y habría que aplicar formato y fórmulas a mano.

#### Verificación post-inserción

Tras insertar las N filas:

1. Volver a llamar `ZohoSheet_list_all_tables` y confirmar que `Tabla2.end_row` se ha incrementado en (N + 2) — o (N) si se aprovechó un hueco existente.
2. Si `end_row` no creció lo esperado, alguna fila quedó fuera. Identificar cuáles y reinsertarlas correctamente. Bug detectado en sesión real (Alejandro Sprint 5-26): 4 huérfanas quedaron fuera de Tabla2 por inserción después de `end_row`.
3. Confirmar que las fórmulas SUMAR.SI propagan a las nuevas filas (Col K diferencia ya no aparece como `#VALUE!` ni en blanco). Si aparece `#VALUE!`, la celda Col J está como texto en lugar de número — reescribir con valor numérico (`0`, no `"0,00 horas"`).

#### Procedimiento

1. **Calcular `M = N + 2`** filas totales a insertar (N huérfanas + 2 filas de separación), salvo si se reutiliza un hueco existente.
2. **Insertar M filas físicas** llamando `ZohoSheet_insert_row` M veces consecutivas en la misma posición intermedia de Tabla2 (cada llamada empuja al resto +1).
3. **Verificar inmediatamente** que `Tabla2.end_row` creció en M.
4. **Pegar contenido** de las N huérfanas con `worksheet.csvdata.set` empezando en la segunda fila del bloque insertado (la primera queda como separador vacío). La última fila también queda vacía como separador.
5. **Verificar fórmulas SUMAR.SI** en Col J. Si Col K muestra `#VALUE!`, reescribir Col J con valor numérico `0` (no `"0,00 horas"` como texto).

Columnas a poblar en cada huérfana:

| Col A (Marca) | Col B (Orden) | Col C (Status) | Col D (Concepto) | Col E (Cliente) | Col F (Estim) |
|---|---|---|---|---|---|
| `🤖 Fuera de plan` o `🤖 Soporte/WIP` | (vacío — Orden lo asigna Sprint Planning) | Status real ClickUp | Concepto exacto Data | Cliente extraído del corchete | Horas estimadas (regla abajo) |

#### Regla para Col F (Horas estimadas) — Decisión pragmática

⚠️ **Nota crítica sobre `time_estimate` de ClickUp**: el `time_estimate` que figura en una tarjeta de ClickUp representa el **TOTAL del producto/microcampaña en TODAS las personas y en TODA su duración** (puede abarcar varios sprints). El estimado del Sprint Backlog Zoho es solo lo asignado **a esa persona en ese sprint concreto**. Por tanto, no se puede tomar `time_estimate` directamente como Col F sin matizar.

**Orden de prioridad para Col F en huérfanas:**

1. Si se puede obtener el **estimado-persona-sprint específico** (vía `User Total Time Estimated` de Data si está disponible, o desagregando custom fields por asignado y semana) → usar ese valor.
2. Si no, y el `time_estimate` general parece razonable para una sola persona en este sprint (ej. tarea pequeña asignada solo a esta persona) → usar `time_estimate`.
3. Si no, y los custom fields **Tiempo MIN** y **Tiempo MAX** están informados → usar `(MIN + MAX) / 2`.
4. Si nada de lo anterior → **Col F = horas reales traqueadas** (Col J), igualando estimado a lo ejecutado. Esto evita inflar el TOTAL ESTIMADAS con valores irreales.

#### 🚨 Alerta proactiva al PO sobre sobrecarga

Si una huérfana del **Grupo B con sub-marca `🤖 Fuera de plan`** (producto digital fuera de plan) trae una **estimación significativa** que supone una sobrecarga del Sprint, la skill emite alerta:

```
🚨 Alerta de sobrecarga detectada:

  El producto "[X]" (huérfano Grupo B) trae [N]h de estimación.
  Capacidad disponible del miembro: [Y]h
  Plan original: [Z]h
  Plan actualizado con huérfanas: [Z+N]h → sobrecarga de [(Z+N)-Y]h

  Recomendación: considera sacar productos del Sprint Backlog para abordar este nuevo esfuerzo,
  o reasignar a Amigos Reinicia.

  Esto se llevará al Informe Ejecutivo del Equipo [X].
```

Esta alerta se registra para que la consuma la skill de Informes Ejecutivos.

#### ⚠️ Aviso de productos sin estimación

Si una huérfana del **Grupo B con sub-marca `🤖 Soporte/WIP`** tiene `time_estimate = null` y `MIN/MAX = null`, **es una violación de la norma Reinicia**: no se debería empezar trabajo de Soporte sin estos campos. Listar todos al final del proceso para que el PO los revise:

```
⚠️ Productos sin estimación informada (norma Reinicia incumplida):
  - [task_id] | [lista] | [nombre]
  - ...
```

#### Patrón especial: producto plan agregado + desglose individual paralelo

Algunos productos del Sprint Backlog son **agregados intencionales**: el plan los crea como una bolsa de horas para englobar múltiples microtareas que se irán recibiendo a lo largo del sprint. Ejemplos típicos:

- `Soporte Carritech` (8h estim) — bolsa que engloba todos los SUPPORT/ASSUMED del sprint
- `Soporte INEFSO` (4h estim) — equivalente para INEFSO
- `Soporte Breezom`, `Soporte Mazarea`, etc.
- `Microcampañas [CLIENTE]` cuando se reservan horas para campañas no especificadas aún

Cuando llegan huérfanas individuales que claramente pertenecen a uno de estos agregados (por ejemplo, `[SUPPORT] Networking equipment [CARRITECH] - Form Submission - #...` pertenece a `Soporte Carritech`), hay dos opciones:

**Opción A — Mantener solo el agregado**: actualizar las horas reales del agregado (vía SUMAR.SI con criterio amplio o sumando manualmente) y NO insertar las individuales como huérfanas. Pros: menos filas. Contras: no hay trazabilidad de qué incidencias concretas se atendieron.

**Opción B — Agregado + desglose individual paralelo (PREFERIDA)**: mantener la fila agregada con sus horas estimadas originales, pero **vaciar Col J a `0` numérico** para evitar duplicación, y **insertar las N microtareas individuales como huérfanas Grupo B con sub-marca `🤖 Soporte/WIP`** dentro de Tabla2. Las individuales se cargan con sus horas reales vía SUMAR.SI canónica y `F = 0` (sin estimación porque son tareas que entraron sin estimar individualmente).

##### Por qué Opción B es preferida (validado con PO el 03/05/2026)

1. **Trazabilidad completa**: queda registrado en el Sprint Backlog cada incidencia concreta atendida, con sus horas reales. Útil para revisión con cliente y para informes ejecutivos.
2. **Comparación estimación vs realidad**: el agregado conserva su estimación inicial (ej. 8h), y las individuales muestran el consumo real desglosado (ej. 12,68h en 8 microtareas). La diferencia entre Col F del agregado y la suma de horas reales de las individuales es información valiosa para replantear la bolsa de horas en el próximo sprint.
3. **No se duplican horas**: la fila agregada tiene Col J = 0 (no suma horas reales), así que el TOTAL DISPONIBLES de Tabla2 no las cuenta dos veces. Las horas reales solo se contabilizan en las filas individuales.

##### Procedimiento

1. **Identificar el agregado**: detectar conceptos en el plan original que tienen formato `Soporte [CLIENTE]`, `Microcampañas [CLIENTE]` o equivalentes.
2. **Detectar huérfanas que pertenecen al agregado**: filtrar conceptos en Data!Column20 que coincidan con la heurística del agregado (ej. para `Soporte Carritech`: conceptos con prefijo `[SUPPORT]` o `[ASSUMED IN THE GUARANTEE]` y corchete `[CARRITECH]`).
3. **Confirmar con el PO** la opción a aplicar (A o B). Por defecto, proponer Opción B.
4. **Si Opción B**:
   - **Vaciar Col J del agregado**: escribir `0` numérico (no `"0,00 horas"` como texto, porque rompe la fórmula de Col K). Verificar que Col K recalcula correctamente (debe mostrar `[F] horas` sin `#VALUE!`).
   - **Aplicar motivo NO SE TOCA en Col L del agregado** y comentario en Col M: "Producto agregado del soporte [CLIENTE]: estim [F]h. Las horas reales se desglosan en huérfanas B individuales (N microtareas) por trazabilidad."
   - **Insertar las N huérfanas individuales** siguiendo el procedimiento estándar del Paso 5 (sub-marca `🤖 Soporte/WIP`, `F = 0`, SUMAR.SI canónica en Col J).
   - **Aplicar motivo NO SE TOCA en cada huérfana individual** con comentario: "Huérfana B (Soporte [CLIENTE]). Desglose individual del producto agregado 'Soporte [CLIENTE]' (fila [N])."
5. **Registrar en Log de Cambios** ambas operaciones.

##### Reflejo en cuadre matemático

El Total Disponibles de Tabla2 sigue cuadrando con ClickUp porque:
- El agregado aporta `0h` reales (Col J vacía).
- Las N individuales aportan sus horas reales vía SUMAR.SI.
- La estimación del agregado (Col F) se sigue contando en TOTAL ESTIMADAS, lo cual es correcto: el plan inicial reservó esa bolsa de horas.

### PASO 6 — Bloque "Metodología y Gestión" (Grupo A) APARTE de Tabla2

Las huérfanas del Grupo A (ceremonias y formación interna) NO se insertan dentro de Tabla2 — van en un bloque propio, después del TOTAL BALANCE de Tabla2 y de la tabla resumen del fichero (si existe), separado por al menos 2 filas vacías.

Esto es porque las ceremonias y la formación interna **no son productos del Sprint Backlog operativo**: son tiempo invertido en metodología y formación que necesita contabilizarse aparte para que el Sprint Backlog principal refleje únicamente trabajo de cliente y desarrollo.

> 📌 **Pendiente de evolución**: en la plantilla del próximo Sprint Backlog (oficial, no AUTOIA) seguramente se incluirá una **tabla canónica predefinida** en este espacio (al estilo de Tabla2). Cuando esté lista, esta skill se actualizará para insertar filas dentro de esa tabla en lugar de construir el bloque manualmente, lo que permitirá heredar formato Reinicia automáticamente y simplificar el procedimiento.

#### Posición

Tras la tabla resumen del fichero (Horas totales / Operativas / Facturable / No Facturable), dejar **2 filas vacías de separador** y empezar el bloque a continuación.

Ejemplo de posición típica en un AUTOIA:
- Filas 56-58: TOTAL ESTIMADAS / DISPONIBLES / BALANCE de Tabla2
- Fila 60: encabezado tabla resumen ("Horas totales sprint")
- Filas 61-64: filas de la tabla resumen
- Filas 65-66: vacías (separador)
- Fila 67 en adelante: bloque Metodología y Gestión

#### Estructura del bloque

| Fila | Contenido | Formato |
|---|---|---|
| N (cabecera de sección) | `METODOLOGÍA Y GESTIÓN` en col C; cabeceras "CONCEPTO" en col D, "Horas estim" en col F, "Reales" en col J | Negrita, fill `#D9D0FB`, font `#3812CF` |
| N+1 a N+M | Una fila por concepto Grupo A | Sin marca en Col A (el bloque mismo identifica el grupo); Col D = Concepto exacto literal de Data!Column20 (sin `+` si el original lo tiene); Col F = `0` numérico; Col J = fórmula SUMAR.SI; Col K opcional (diferencia, casi siempre negativa) |
| N+M+1 (TOTAL) | `TOTAL METODOLOGÍA Y GESTIÓN` en col D; `=SUMA(J[N+1]:J[N+M])` en col J | Negrita, fill `#D9D0FB`, font `#3812CF` |

⚠️ **Sin marca en Col A**: a diferencia de las huérfanas Grupo B, los conceptos del Grupo A no llevan emoji `🤖` en columna A. La separación visual del bloque (cabecera + ubicación fuera de Tabla2) basta para identificarlos.

#### Regla para Col F (Horas estimadas) — siempre `0` numérico

⚠️ **Cambio de criterio respecto a versiones anteriores**: ya NO se usa "estimación retroactiva = horas reales". La columna F del bloque Metodología se rellena siempre con `0` numérico (no `"0,00 horas"` como texto, no vacío) por dos razones:

1. **Las ceremonias no estiman**: Daily, Sprint Planning, Retrospective y Refinamiento no tienen estimación previa porque son tiempo de equipo no asignado a un producto. Lo mismo aplica a la formación interna.
2. **Cuadre matemático limpio**: Col F del bloque Metodología no entra en TOTAL ESTIMADAS de Tabla2 (está fuera), pero sí afecta la diferencia local del bloque. Con F=0 la diferencia K es siempre negativa y refleja el tiempo real invertido — información útil que se traslada al informe ejecutivo.

⚠️ **Coma decimal en es-ES**: Zoho Sheet espera coma decimal al escribir números vía API (`set_content`). Punto decimal se interpreta como texto y rompe SUMA. Usar siempre `0`, nunca `0.0` ni `0.00`.

#### Aplicar fórmulas manualmente

Al estar fuera del bloque heredado de Tabla2, hay que escribirlas explícitamente celda a celda:

- **Col J (ClickUp Registro)**:
  ```
  =SUMAR.SI(Tabla1[[#All];[Column20]];D[fila];Tabla1[[#All];[Horas Traqueadas]])
  ```
  Referencia directa a la celda Concepto del bloque (`D68`, `D69`, etc.) — NO `Tabla2[@Concepto]` (esto solo funciona dentro de Tabla2 y aquí no aplica).

- **Col K (Diferencia)**, opcional:
  ```
  =F[fila]-J[fila]
  ```

- **TOTAL fila**:
  ```
  =SUMA(J[N+1]:J[N+M])
  ```

Donde `D[fila]`, `F[fila]`, `J[fila]` son las celdas con la letra de columna correcta del fichero (puede ser D o E para Concepto según el mapeo del Paso 1).

#### Verificación post-construcción

1. Confirmar que cada celda Col J del bloque devuelve un valor numérico (no `#NAME?` ni `0` por bug NFC/NFD ni texto plano).
2. Si una celda devuelve `0` y la suma de horas reales esperada para ese concepto en ClickUp es mayor:
   - Verificar bug NFC/NFD: usar fórmula `=COINCIDIR(D[fila];Tabla1[Column20];0)` en una celda auxiliar. Si devuelve `#N/A!`, hay diferencia textual no visible.
   - Verificar bug del `+` perdido: si el concepto contiene un timestamp con `+01:00` o `+02:00`, comprobar que el valor en Tabla1 (Data) tiene espacio en su lugar (`01:00` sin `+`). Reescribir el concepto en el bloque sin `+`.
3. Confirmar que `=SUMA(J[N+1]:J[N+M])` del TOTAL coincide con la suma esperada del bloque.

### PASO 7 — Rellenar Motivo desvío y Comentario en filas con K negativo

Cuando la columna **Diferencia horas (K)** es negativa, significa que el tiempo registrado supera al estimado. La norma Reinicia exige rellenar dos campos en esa fila:

#### Col L — Motivo desvío (dropdown)

Valores fijos del desplegable:

| Valor | Significado |
|---|---|
| `MALA ESTIMACIÓN` | El estimado original era irrealista para el alcance del producto |
| `PARKING` | Hubo cambios de prioridad o pausas externas que prolongaron la ejecución |
| `NO ESTIMADO` | El producto se trabajó sin estimación previa (frecuente en huérfanas y Soporte sin MIN/MAX) |
| `COORDINACIÓN CLIENTE` | Bloqueos por demoras o cambios en la coordinación con cliente |
| `MALA COORDINACIÓN INTERNA` | Bloqueos o duplicidades por mala coordinación dentro del equipo Reinicia |

#### Col M — Comentario (texto libre breve)

Nota orientativa de qué pasó concretamente. Ejemplo: "Estimación de 2h pero el cliente cambió el alcance dos veces; se llegó a 5,5h reales".

#### Procedimiento de la skill

1. **Identificar todas las filas con K < 0** del Sprint Backlog principal (incluidas huérfanas Grupo B insertadas en Paso 5) y del bloque Metodología (Paso 6).
2. **Por cada fila, proponer al PO** un motivo y comentario sugerido en base al contexto disponible:
   - Si la huérfana fue Soporte/WIP sin estimación → sugerir `NO ESTIMADO`.
   - Si el producto está en `parking e incidencias` o `validación cliente` con tiempo real >> estimado → sugerir `PARKING` o `COORDINACIÓN CLIENTE`.
   - Si el producto cerró en `done` con desvío grande → sugerir `MALA ESTIMACIÓN`.
   - El comentario se sugiere a partir de las descripciones de los time entries de la tarea (campo `description` de ClickUp).
3. **Pedir validación del PO** antes de escribir. El PO puede aceptar la sugerencia, cambiar el motivo o ajustar el comentario.
4. **Escribir** Col L (dropdown) y Col M (texto) tras validación.
5. **Registrar en Log de Cambios** cada motivo y comentario añadido.

Estos motivos y comentarios se llevarán al Informe Ejecutivo del Equipo correspondiente para tener visibilidad de causas reincidentes y poder mejorar el sprint siguiente.

### PASO 8 — Validación matemática

```
Tiempos!J[TOTAL DISPONIBLES] (suma SUMAR.SI Sprint Backlog principal)
+ Tiempos!J[TOTAL METODOLOGÍA Y GESTIÓN]
= Total real ClickUp del miembro en el sprint
```

Si no cuadra:
- Diferencia < 0,1h: aceptable (redondeo).
- Diferencia significativa: hay conceptos huérfanos no clasificados o renames pendientes. Volver al Paso 4.

Registrar en Log de Cambios: `[timestamp] | VALIDACION | Cuadre AUTOIA | Plan: [X]h, Metodología: [Y]h, Total: [X+Y]h | ClickUp real: [Z]h | Match: [OK/KO]`.

### PASO 8b — Sello de actualización y bandeo final

Tras la validación, antes de generar el reporte, asegurar que el fichero queda con metadato y formato correctos.

#### Sello de actualización

1. **Tiempos!D1**: escribir `Última actualización (skill): DD/MM/AAAA HH:MM — Sprint X-YY` (timestamp del momento de cierre, no del inicio). Aplicar `row_height: 45` y `vertical_alignment: middle` sobre fila 1 si aún no estaba.
2. **Log de Cambios!M1**: mismo texto.

Estos sellos se sobreescriben siempre — el valor anterior se descarta (se asume que la última ejecución es la fuente de verdad).

#### Bandeo final del Log de Cambios

Tras todas las inserciones del proceso (renames, datas, motivos, sello), el Log de Cambios habrá crecido en N filas nuevas que probablemente vienen sin bandeo. Recalcular `last_row` con `ZohoSheet_get_used_area` y aplicar bandeo manual fila a fila desde la primera nueva hasta `last_row`:

```
for fila in range(primera_fila_nueva, last_row + 1):
    fill = "#EBEBEB" if fila % 2 == 1 else "#FFFFFF"
    format_ranges(range="A{fila}:K{fila}", fill_color=fill,
                  font_name="Manrope", font_size=10, row_height=22,
                  vertical_alignment="middle", wrap_text=true)
```

Esta es la garantía operativa de que el Log queda visualmente coherente al final de cada ejecución, independientemente de cuántas inserciones se hayan hecho durante el proceso.

#### Registro de cierre

Registrar en Log de Cambios:
- `[timestamp] | Tiempos | 1 | D | - | [sello previo o vacío] | [sello nuevo] | SELLO_ACTUALIZACION | Skill | Sello de fin de ejecución`
- `[timestamp] | Log de Cambios | 1 | M | - | [sello previo o vacío] | [sello nuevo] | SELLO_ACTUALIZACION | Skill | Sello de fin de ejecución`

### PASO 9 — Reporte y siguientes pasos

```
✅ Sprint Backlog actualizado — [Persona]

Cuadre AUTOIA:
  - Plan original (Tiempos principal):  [X,XX]h
  - Metodología y Gestión:              [Y,YY]h
  - TOTAL AUTOIA:                       [X+Y]h
  - Total real ClickUp:                 [Z,ZZ]h
  - Match: ✅ / ⚠️ desvío [Δ]h

Huérfanas integradas:
  - Grupo B - Fuera de plan (DENTRO Tabla2): [N] productos, [Hb1]h reales
  - Grupo B - Soporte/WIP   (DENTRO Tabla2): [N] productos, [Hb2]h reales
  - Grupo A - Metodología y Gestión (APARTE): [N] conceptos, [Ha]h reales
  - TOTAL huérfanas: [Hb1+Hb2+Ha]h

Filas con desvío negativo (K < 0): [N]
  - Motivos más frecuentes: [resumen]

Avisos:
  - [N] productos de Soporte sin estimación informada (ver lista)
  - [N] time entries sin task asociada (ver lista)
  - [N] alertas de sobrecarga emitidas
  - [N] propuestas de mejora de skill identificadas (Mejoras Propuestas Skill Sprint Backlog: documentar en Reinnova ClickUp)

Próximo paso sugerido: [siguiente miembro del equipo, o generación de Informes Ejecutivos si es el último].
```

Si quedan miembros pendientes y el modo es por defecto (preguntar antes de cada uno), preguntar:

```
¿Sigo con [siguiente miembro]?
```

---

## OPERACIONES DESTRUCTIVAS — REGISTRO EN LOG DE CAMBIOS

Toda operación que modifique el fichero **debe registrarse** en la hoja `Log de Cambios` con timestamp, tipo de operación, detalle, estado anterior y posterior. Tipos de operación estandarizados:

| Tipo | Descripción |
|---|---|
| `INICIALIZACIÓN` | Creación de la hoja Log de Cambios |
| `TABLA_LOG_CREADA` | Creación de tabla formal sobre Log de Cambios preexistente (migración a TablaLog) |
| `SELLO_ACTUALIZACION` | Actualización de timestamp en Tiempos!D1 y Log de Cambios!M1 al cierre de la ejecución |
| `DATA_CLEAR` | Vaciado de la hoja Data antes de pegar registros nuevos |
| `DATA_PASTE` | Pegado de registros desde ClickUp en la hoja Data |
| `TIEMPOS_RENAME` | Modificación de un concepto en Tiempos!Concepto para forzar match (validado por PO) |
| `TIEMPOS_RENAME_RECHAZADO` | Rename propuesto y rechazado por el PO (registro de referencia para no reproponerlo en revisiones siguientes del mismo sprint) |
| `TIEMPOS_INSERT` | Inserción de filas físicas en Tiempos para huérfanas |
| `TIEMPOS_PASTE` | Escritura de datos de huérfanas en filas insertadas |
| `METODOLOGIA_CREATE` | Creación o actualización del bloque Metodología y Gestión |
| `MOTIVO_DESVIO` | Escritura de motivo y comentario en filas con K negativo |
| `VALIDACION` | Resultado de la validación matemática final |

El registro permite **revertir manualmente** si algo sale mal (no es automático, pero es auditable).

---

## INSUMO PARA INFORMES EJECUTIVOS POR EQUIPO

> ⚠️ **La generación del Informe Ejecutivo NO es responsabilidad de esta skill.** Existirá una skill aparte (a futuro) que consume los datos producidos por esta skill y los agrega a nivel Equipo.

Tras procesar todos los miembros de un Equipo, esta skill produce los siguientes datos consumibles por la skill de Informes Ejecutivos:

| Métrica por equipo | Origen |
|---|---|
| Total horas trabajadas equipo | Suma de `Tiempos!J[TOTAL DISPONIBLES]` + `[TOTAL METODOLOGÍA]` de todos los miembros |
| Capacidad equipo | Suma de capacidades individuales |
| % utilización equipo | Total / Capacidad |
| Sobrecarga (estim - capacidad) | Plan vs capacidad |
| Distribución por cliente | Cruzando Col E (Cliente) de Tiempos de todos los miembros |
| Productos vencidos (Plan vs ejecución) | Status `DOING` o anterior con fecha límite ya pasada |
| Productos en `parking e incidencias` | Lista para discusión en Sprint Review |
| Carga de Metodología y Gestión por cliente | Bloque "Metodología y Gestión" agrupado por col Cliente |
| Huérfanas Grupo B totales (desglosadas en Fuera de plan / Soporte/WIP) | Diagnóstico de trabajo no planificado |
| Alertas de sobrecarga emitidas | Lista de productos huérfanos Grupo B - Fuera de plan con sobrecarga |
| Motivos de desvío por miembro | Cruce Col L + Col M de filas con K negativo |
| Personas sin Sprint Backlog (caso Amigos Reinicia) | Pestaña aparte con horas tracked agregadas |
| Mejoras Propuestas Skill Sprint Backlog | Lista de propuestas de mejora identificadas durante el procesamiento, con etiqueta "documentar en Reinnova ClickUp" |

---

## RECURSOS CLAVE

### Constantes de marca Reinicia

- Azul primario: `#3812CF`
- Acento: `#D9D0FB`
- Filas alternas: `#EBEBEB`
- Total fila: `#D9D0FB`
- Fuentes: Manrope Regular y Manrope Bold

### Herramientas MCP usadas

- **ClickUp**: `clickup_get_time_entries`, `clickup_resolve_assignees`, `clickup_get_task` (para verificar `time_estimate` y `Tiempo MIN/MAX` de huérfanas), `clickup_filter_tasks` (para listar miembros activos por Equipo).
- **Zoho Workdrive Sheet**: `ZohoSheet_list_all_worksheets`, `ZohoSheet_get_content_of_range`, `ZohoSheet_set_content_to_range`, `ZohoSheet_clear_contents_of_range`, `ZohoSheet_insert_row`, `ZohoSheet_delete_rows`, `ZohoSheet_format_ranges`.

---

## LIMITACIONES TÉCNICAS Y BUGS CONOCIDOS DE ZOHO SHEET

### Limitaciones genéricas

1. **Formato numérico personalizado no soportado en API**: las celdas con fórmula muestran decimales largos (ej. `6,802107778` en lugar de `6,80 horas`). Aceptar.
2. **Inserción fuera de tabla no hereda**: las filas insertadas fuera del rango de Tabla2 no copian formato ni fórmulas. Por eso la regla del Paso 5 obliga a insertar dentro del rango actual de Tabla2 (`start_row+2` a `end_row-1`), y por eso el bloque Metodología (Paso 6) se construye con fórmulas explícitas celda a celda.
3. **Time entries sin task no recuperables**: la validación JSON del MCP falla cuando un entry no tiene `task_id`. Fragmentar el rango temporal hasta aislar la entrada problemática y omitirla. Reportar al PO al final qué entradas no se pudieron recuperar (timestamp, duración aproximada, usuario).
4. **`worksheet_id` varía entre ficheros**: siempre listar primero con `ZohoSheet_list_all_worksheets`.
5. **Las columnas de Tiempos pueden estar desplazadas**: mapear siempre desde la cabecera real (fila 3 en AUTOIA, fila 4 en variantes).

### Bugs específicos detectados en sesiones reales

#### Bug 1 — Col J/K hardcoded en lugar de SUMAR.SI

**Síntoma**: la Col J (ClickUp Registro) de algunas filas muestra valores numéricos literales (`11,45 horas`, `12,63 horas`) en lugar de la fórmula SUMAR.SI canónica. La suma del TOTAL se mantiene "cuadrada" pero el cuadre es engañoso: si en revisiones posteriores cambian las horas reales en Data, la fila no se actualiza.

**Causa**: en algún momento (Sprint Planning manual, ajuste rápido) alguien escribió el valor en lugar de la fórmula.

**Solución**: antes de cualquier validación de cuadre, sustituir TODA la columna J del Sprint Backlog principal por la fórmula canónica:

```
=SUMAR.SI(Tabla1[[#All];[Column20]];Tabla2[@Concepto];Tabla1[[#All];[Horas Traqueadas]])
```

(Detectado en AUTOIA José Sprint 5-26.)

#### Bug 2 — Coma decimal en es-ES vs punto

**Síntoma**: una celda con valor `0.92` se interpreta como **texto** (no número), rompiendo fórmulas SUMA y restas. La celda muestra el valor pero `=SUMA(...)` la ignora o devuelve `#VALUE!`.

**Causa**: Zoho Sheet en configuración es-ES usa coma decimal. Punto decimal escrito vía API (`set_content`) se interpreta como string.

**Solución**: usar siempre coma al escribir números numéricos:
- `0` (entero, válido)
- `0,92` (decimal con coma, válido)
- `0.92` ❌ (texto en es-ES)

(Detectado al escribir Col F de huérfanas y bloque Metodología.)

#### Bug 3 — Carácter `+` perdido al pegar CSV

**Síntoma**: literales con `+` como timestamps `06:09:13+01:00` se transforman en `06:09:13 01:00` (espacio en lugar de `+`) al pegarlos en una celda vía CSV en el campo de fórmula. Como consecuencia, los conceptos del plan que llevan `+` no machean con los de Data y SUMAR.SI devuelve 0.

**Causa**: el motor de pegado de Zoho Sheet interpreta el `+` como operador en algunas rutas de procesamiento.

**Solución**:
- Al rellenar la pestaña Data vía `worksheet.csvdata.set`, los timestamps con `+` ya quedarán sin `+` automáticamente.
- En la columna Concepto del plan / huérfanas en Tiempos, escribir el literal **sin `+`** (con espacio en su lugar) para asegurar match.
- Verificar siempre con `=COINCIDIR(D[fila];Tabla1[Column20];0)` en una celda auxiliar; si devuelve `#N/A!`, el match no funciona.

(Detectado en AUTOIA Fabián Sprint 5-26.)

#### Bug 4 — Mismatch silencioso por NFC/NFD (acentos descompuestos)

**Síntoma**: dos textos visualmente idénticos no machean. SUMAR.SI devuelve 0, MATCH devuelve `#N/A!`. Las celdas tienen el mismo `LEN()` pero la comparación `=A1=A2` da `FALSO`.

**Causa**: los conceptos en Tiempos pueden estar en **NFD** (Normalization Form D — acentos descompuestos: la `ó` es código `o` + combining-acute), mientras los entries pegados desde Python u otra fuente vienen en **NFC** (Normalization Form C — caracter precompuesto). Visualmente idénticos, bytes distintos.

**Solución**:
- Verificar siempre con `=COINCIDIR(D[fila];Tabla1[Column20];0)` antes de aceptar un `0` como válido. Si devuelve `#N/A!` y los textos parecen iguales, hay diferencia NFC/NFD.
- Reescribir la celda en Tiempos copiando el literal exacto desde Data (que viene en NFC). Esto regenera la celda en NFC y restaura el match.
- Conceptos típicamente afectados: cualquiera con tildes (`Configuración`, `Gestión`, `Cualificación`, `Análisis`, `Categorización`).

(Detectado en AUTOIA Alejandro Sprint 5-26 con `[SPIKE] Taller Práctico IA`.)

### Checklist rápido ante un `0` inesperado en Col J

Si Col J de una fila devuelve `0` pero ClickUp reporta horas reales para ese concepto:

1. ¿Hay tildes? → probar Bug 4 (NFC/NFD) con `=COINCIDIR`.
2. ¿Hay timestamps con `+`? → probar Bug 3 (`+` perdido), reescribir sin `+`.
3. ¿Hay diferencia visible en el literal (espacios, mayúsculas, guiones, prefijos)? → es un caso de rename, ir al Paso 4.
4. Si Col K muestra `#VALUE!` (no `0`) → probar Bug 2 (Col J como texto), reescribir con número numérico.

---

## VERSIONES

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v1.0** | 2026-05-03 | Néstor + Claude | Primera versión. Validada con Paolo Bergamelli en Sprint 05-26 (cuadre 74,33h al céntimo). Incluye flujo completo de 8 pasos, gestión de Log de Cambios, clasificación A/B/C de huérfanas con keywords. |
| **v2.0** | 2026-05-03 | Néstor + Claude | Skill agnóstica de personas concretas (búsqueda dinámica desde ClickUp). Soporte para Amigos Reinicia sin Sprint Backlog Zoho. Validación PO obligatoria de emparejamientos en renames. Nueva regla Col F priorizando estimado-persona-sprint, con fallback a horas reales si nada informado. Alerta proactiva de sobrecarga al PO. **Nuevo Paso 7**: rellenar Motivo desvío (dropdown: MALA ESTIMACIÓN / PARKING / NO ESTIMADO / COORDINACIÓN CLIENTE / MALA COORDINACIÓN INTERNA) y Comentario en filas con J<0. Aclaración explícita sobre `time_estimate` ClickUp ≠ estimado-persona-sprint. Mención a futura skill aparte de Informes Ejecutivos. Etiqueta "Mejoras Propuestas Skill Sprint Backlog: documentar en Reinnova ClickUp". |
| **v3.0** | 2026-05-03 | Néstor + Claude | Revisión integral tras procesamiento real de 4 AUTOIAs (José, Alejandro, Johanna, Fabián) en Sprint 5-26. **Reorganización de pasos**: Paso 2 simplificado a solo recopilación; Paso 3 reescrito con tres opciones al PO (A: Claude borra/B: PO borra/C: ya está bien) sobre la pestaña Data original (NO se crean pestañas auxiliares). **Nuevo mapeo de columnas** correcto: F=Estim, J=Registro, K=Diferencia, L=Motivo, M=Comentario; cabecera fila 3 AUTOIA / 4 variantes; añadidas Col A (Marca) y Col B (Orden). **Eliminado Grupo C**; clasificación reducida a A vs B con sub-marcas en Col A: `🤖 Fuera de plan` (productos digitales nuevos, gestiones cliente/Reinicia, SPIKEs, incidencias) y `🤖 Soporte/WIP` (microtareas reactivas: `[SUPPORT]`, `[ASSUMED]`, `[BUG]`, Form Submission). **Inserción de huérfanas Grupo B DENTRO de Tabla2** con regla `start_row+2` a `end_row-1`, separadores visuales obligatorios, M=N+2 filas a insertar, verificación post-inserción de `end_row` extendido. **Patrón especial Opción B** validado para productos plan agregados (ej. `Soporte Carritech`) + desglose individual paralelo: agregado con J=0 numérico + NO SE TOCA, individuales como huérfanas B-Soporte/WIP con SUMAR.SI canónica y F=0. **Bloque Metodología APARTE de Tabla2** (no dentro), F=0 numérico (NO estimación retroactiva), fórmula SUMAR.SI con `D[fila]` directa (no `Tabla2[@Concepto]`). **Renames con criterio NO renombrar**: 4 criterios objetivos (ambos literales en Data, cambio de alcance, cliente distinto, decisión PO), formato presentación con casos `✅ rename limpio` / `⚠️ posible producto distinto`, nuevo log type `TIEMPOS_RENAME_RECHAZADO`. **Sección consolidada de bugs Zoho Sheet**: 5 limitaciones genéricas + 4 bugs específicos (Bug 1: Col J/K hardcoded → SUMAR.SI canónica; Bug 2: coma decimal es-ES vs punto; Bug 3: `+` perdido al pegar CSV; Bug 4: NFC/NFD silencioso) + checklist rápido ante 0 inesperado en Col J. **Sello de actualización** en Tiempos!D1 y Log de Cambios!M1 con texto `Última actualización (skill): DD/MM/AAAA HH:MM — Sprint X-YY`, alto fila 45pt en Tiempos. **TablaLog formal** sobre Log de Cambios con `template MEDIUM2` + `color #3812CF` + Manrope 10 + alto 22pt + cabecera `#D9D0FB`/`#3812CF`; bandeo manual fila a fila (`#EBEBEB`/`#FFFFFF`) tras cada inserción para sortear el bug que el `template MEDIUM2` no garantiza bandeo visible cuando hay celdas con fill previo. Limitación documentada: Zoho asigna nombre de tabla automáticamente (no hay método rename_table). **Nuevo Paso 8b** de cierre con sello + bandeo final. Nuevas operaciones de Log: `TABLA_LOG_CREADA`, `SELLO_ACTUALIZACION`, `TIEMPOS_RENAME_RECHAZADO`. Validada con AUTOIAs Fabián, Alejandro, Johanna, José Sprint 5-26. |

---

## PENDIENTES DE EVOLUCIÓN

- **Aplicar la skill directamente sobre Sprint Backlogs oficiales sin duplicar AUTOIA** (cuando se valide el flujo en todo el equipo).
- **Tabla canónica de "Metodología y Gestión"** dentro del Sprint Backlog (a incorporar en la plantilla del próximo Sprint Planning). Cuando esté disponible, esta skill se actualizará para insertar filas dentro de esa tabla — equivalente al manejo actual de Tabla2 — eliminando la construcción manual del bloque y heredando formato Reinicia automáticamente. Ver Paso 6 para detalle del comportamiento provisional actual.
- **Skill aparte de Informes Ejecutivos por Equipo** que consuma los datos producidos por esta skill.
- **Ampliar lista de keywords** para clasificación de huérfanas conforme aparezcan casos nuevos.
- **Consultar dinámicamente Equipos desde ClickUp** (espacios y asignaciones) en lugar de mantener lista fija.
- **Detección automática de personas transversales** (presencia en varios Equipos) y propuesta al PO.
