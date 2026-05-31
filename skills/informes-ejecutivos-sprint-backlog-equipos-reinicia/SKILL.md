---
name: informes-ejecutivos-sprint-backlog-equipos-reinicia
description: >
  Skill para generar y actualizar los Informes Ejecutivos de Sprint Backlog por Equipo de Reinicia
  (Columbia, Proactive y futuros). Consume los Sprint Backlogs ya procesados por la skill
  revision-sprint-backlog-equipo-reinicia y produce un Zoho Sheet por Equipo con: portada, resumen
  ejecutivo agregado, comparativa entre miembros, detalle individual por persona (incluye Amigos
  Reinicia sin Sprint Backlog Zoho), alertas operativas (sobrecarga, productos vencidos, motivos
  de desvío) y acciones recomendadas para Dirección.

  Actívala cuando el PO líder pida: "genera el informe ejecutivo del Equipo [X]", "genera los
  informes ejecutivos por equipo", "actualiza los informes ejecutivos con los AUTOIA actuales",
  "cierre de sprint: dame los informes ejecutivos", o cuando se ejecute la tarea programada de
  cierre de sprint.

  Frecuencia: semanal (estado a mitad de sprint), al cierre de sprint, y a demanda.
  Skill secuencialmente posterior a revision-sprint-backlog-equipo-reinicia.
---

# SKILL: Informes Ejecutivos de Sprint Backlog por Equipo — Reinicia

> 📋 **VERSIÓN v0.2 — Primer ciclo real documentado.** Esta versión incorpora los aprendizajes de la primera ejecución de cierre real (Informes Columbia y Proactive, Sprint 06-26, parcial a Día 14): tools MCP confirmadas, mecanismo de duplicación parcial→cierre, patrón de formato de tabla canónico, homogeneización de columnas en pestañas de Detalle, depuración de timers solapados para miembros sin AUTOIA, y una **rutina de validación de formato obligatoria** (nacida de errores reales de filas que quedaron sin maquetar). Sigue sin ser definitiva: el contenido celda a celda exacto de Portada/Resumen/Comparativa se irá refinando en próximos ciclos.

---

## Propósito

Generar un **Informe Ejecutivo por Equipo** (Columbia, Proactive, futuros) que sirva a Dirección y al PO líder para:

- **Entender el estado del sprint** de un vistazo (cuadre, sobrecarga, % utilización).
- **Comparar miembros del Equipo** entre sí y detectar desequilibrios de carga.
- **Identificar problemas operativos**: productos vencidos, parking, motivos de desvío reincidentes, sobrecarga proactiva.
- **Tomar decisiones**: redistribuir carga, sacar productos del backlog, ampliar capacidad con Amigos Reinicia, ajustar estimaciones.
- **Documentar mejoras propuestas** a la metodología/skills detectadas durante el sprint.

La skill **NO procesa Sprint Backlogs individuales** (eso lo hace `revision-sprint-backlog-equipo-reinicia`). Solo **consume** sus outputs ya cuadrados y los **agrega** a nivel Equipo en un Zoho Sheet con formato canónico.

---

## RELACIÓN CON OTRAS SKILLS

```
sprint-planning-reinicia (al inicio del sprint)
  ↓
revision-sprint-backlog-equipo-reinicia (semanal durante el sprint)
  ↓ (consume sus outputs cuadrados)
informes-ejecutivos-sprint-backlog-equipos-reinicia (esta skill)
  ↓
Dirección y PO líder
```

**Precondición crítica**: la skill asume que **todos los Sprint Backlogs de los miembros del Equipo ya han sido procesados** por la skill de revisión (cuadre 100%, huérfanas integradas, bloque Metodología creado, motivos de desvío rellenos). Si no, la skill avisa y propone ejecutar antes la skill de revisión.

---

## ÁMBITO Y BÚSQUEDA DINÁMICA

⚠️ **Esta skill, al igual que la de revisión, NO mantiene una lista hardcoded de Equipos ni de miembros.** Equipos, miembros y clientes cambian sprint a sprint.

### Confirmación inicial (Paso 0)

Al activarse, la skill **siempre confirma** con el PO líder:

1. **Equipo(s) a procesar**. Si el PO no lo dice explícitamente, la skill consulta ClickUp para listar Equipos detectados y los presenta al PO para confirmación.
2. **Miembros del Equipo** (incluidas personas transversales y Amigos Reinicia sin Sprint Backlog Zoho).
3. **Sprint a documentar** (sprint actual por defecto, con opción de seleccionar otro).
4. **Tipo de informe**: parcial (estado a mitad de sprint) o cierre (informe final).
5. **Carpeta destino en Workdrive** donde guardar el Sheet generado.

> ⚠️ **Aprendizaje v0.2 — confirmaciones en texto.** Los selectores interactivos (`ask_user_input_v0`) pueden no devolver la elección del PO en este entorno (devuelven solo las opciones). No bloquear la ejecución esperando el selector: si no llega respuesta estructurada, **reformular la pregunta en texto plano** y, mientras tanto, **adelantar el trabajo que es seguro en cualquier escenario** (p. ej. recopilar time entries de ClickUp). Nunca asumir una decisión irreversible (crear vs actualizar fichero) sin confirmación explícita del PO.

> ⚠️ **Aprendizaje v0.2 — miembros sin imputación.** Antes de crear pestañas, **verificar con ClickUp qué miembros tienen time entries reales** en el sprint. Para quien tenga **0 entries** (p. ej. Síntaris: Óscar Seuba/David Marco no imputaron en 06-26) o **no esté dado de alta** en el workspace (p. ej. Marcos Ortiz, alta pendiente), **NO crear pestaña vacía**: anotarlo en la pestaña Alertas Equipo como dato accionable para Dirección. Crear pestañas a 0h ensucia el informe sin aportar valor.

---

## ESTRUCTURA CANÓNICA DEL INFORME EJECUTIVO

Plantilla validada con el Informe Ejecutivo del Equipo Columbia Sprint 05-26 (`p9ticf86741d7ee6346b69645720b029c9618`).

### 7 pestañas estándar

| # | Pestaña | Propósito |
|---|---|---|
| 1 | **Portada** | Identificación del informe (Equipo, sprint, fechas, autoría, versión) |
| 2 | **Resumen Equipo** | KPIs agregados del Equipo (capacidad, tracked, % utilización, sobrecarga, top alertas) |
| 3 | **Comparativa Personas** | Tabla comparativa una fila por miembro del Equipo (incluyendo Amigos Reinicia) |
| 4..N | **Detalle [Persona]** | Una pestaña por miembro con desglose individual (productos, motivos de desvío, mejoras) |
| N+1 | **Detalle Alertas Equipo** | Alertas operativas consolidadas: sobrecarga, productos vencidos, parking, motivos reincidentes |
| N+2 | **Acciones Equipo** | Decisiones recomendadas y compromisos a discutir en Sprint Review |

### Pestaña adicional para casos especiales

- **Detalle [Amigo Reinicia]** (caso Síntaris, Chisco, etc.): si imputan horas en ClickUp pero no tienen Sprint Backlog Zoho propio, se les crea pestaña aparte con sus horas tracked agregadas.

---

## CONTENIDO POR PESTAÑA

> 📋 **v0.2 — Estructura macro confirmada en el primer ciclo real.** El contenido celda a celda exacto de Portada/Resumen/Comparativa se sigue refinando, pero la estructura de pestañas, el patrón de formato y las reglas de homogeneización de tablas (abajo) ya están validados.

> ⚠️ **Aprendizaje v0.2 — la estructura de la pestaña Detalle VARÍA por persona.** No asumir una plantilla fija. Antes de escribir o formatear una pestaña de Detalle, **leerla siempre** (`ZohoSheet_get_content_of_worksheet`) para detectar su estructura real:
> - **Miembro operativo estándar** (José, Alejandro, Fabián): Resumen Ejecutivo + hasta 3 tablas (Productos destacados, Huérfanas, Metodología y Gestión).
> - **Miembro transversal** (Paolo): Resumen Ejecutivo + tabla de "principales productos ejecutados". Su capacidad NO se suma al agregado del Equipo (aparece en ambos informes si trabaja para los dos).
> - **PO sin AUTOIA** (Pablo, Óscar Díez): Resumen Ejecutivo + tabla de desglose de time entries de ClickUp por tarea/categoría (facturable / no facturable). Nota fija "no tiene Sprint Backlog AUTOIA propio; datos vía ClickUp".
> - **Miembro con incidencia de jornada** (Johanna con vacaciones): la pestaña puede ser **narrativa** (Resumen Ejecutivo clave-valor + bloque de texto), **sin tablas**. No forzar formato de tabla donde no hay listado tabular.

> ⚠️ **Aprendizaje v0.2 — homogeneización de columnas en tablas de Detalle.** Las tres tablas (Productos, Huérfanas, Metodología) deben compartir las **mismas columnas y anchos** que la tabla de Productos destacados: **Producto/Concepto · Cliente · Estimado · Tracked · Status/Tipo/Categoría** (B·C·D·E·F). Reglas del campo **Estimado**:
> - **`0h`** en Huérfanas y Metodología (es la verdad: no estaban estimadas en el plan).
> - **`—`** (guion) en productos que SÍ están en plan pero cuya estimación individual no se tiene a mano (evita inventar y mantiene la columna homogénea). NUNCA poner `0` a un producto que sí tiene estimación real.
> - En Metodología, la columna **Cliente va vacía** (son conceptos internos: Sprint Planning, Daily, Retro...).

### Pestaña 1 — Portada
- Logo y marca Reinicia
- Equipo (Columbia / Proactive / [Otro])
- Sprint identificador (ej. "Sprint 05-26")
- Fechas inicio-fin del sprint
- Tipo de informe (Parcial / Cierre)
- Autor + fecha de generación
- Enlace al Sprint Backlog AUTOIA de cada miembro

### Pestaña 2 — Resumen Equipo
KPIs principales:
- Capacidad total del Equipo (h)
- Total tracked (h) — desglose: plan / metodología / huérfanas
- % utilización
- Sobrecarga (estim - capacidad)
- Productos planificados completados / en curso / vencidos
- Productos huérfanos integrados (Grupo B+C)
- Distribución por cliente (top 5)
- Top 5 alertas más críticas (resumen, detalle en pestaña Alertas)
- Mejoras Propuestas Skill Sprint Backlog: documentar en Reinnova ClickUp (resumen)

### Pestaña 3 — Comparativa Personas
Tabla con una fila por miembro:

| Persona | Capacidad | Tracked plan | Tracked metodología | Tracked total | % util | Sobrecarga | Productos planif. | Huérfanas B+C | Filas con desvío negativo | Motivo desvío más frecuente |
|---|---|---|---|---|---|---|---|---|---|---|

Incluye fila para cada Amigo Reinicia con horas tracked aunque sin Sprint Backlog Zoho (capacidad y % util quedan en blanco o N/A).

### Pestaña 4..N — Detalle [Persona]
Una pestaña por miembro con:
- Cuadre AUTOIA del miembro (extraído del Log de Cambios del AUTOIA)
- Distribución de tiempo por cliente y por fase de proyecto
- Productos del Sprint Backlog principal con estado actual y horas
- Huérfanas integradas (Grupo B y C)
- Bloque Metodología y Gestión
- **Filas con desvío negativo (J<0)**: tabla con concepto, F-estim, I-tracked, J-diff, **Motivo desvío** (Col K) y **Comentario** (Col L)
- Alertas individuales (sobrecarga, productos sin estimación, etc.)
- Mejoras propuestas detectadas durante el procesamiento de su Sprint Backlog

### Pestaña N+1 — Detalle Alertas Equipo
Consolidación de alertas operativas:
- **Sobrecarga**: huérfanas Grupo B con estimación significativa que rompen el plan
- **Productos vencidos**: status `DOING` o anterior con fecha límite ya pasada
- **Productos en `parking e incidencias`**: lista para discusión en Sprint Review
- **Productos de Soporte sin estimación informada** (norma Reinicia incumplida)
- **Time entries sin task asociada** detectados durante la revisión
- **Motivos de desvío más frecuentes** (agregado dropdown Col K)
- **Mejoras Propuestas Skill Sprint Backlog: documentar en Reinnova ClickUp** (lista completa)

### Pestaña N+2 — Acciones Equipo
Decisiones y compromisos recomendados:
- Productos a sacar del Sprint Backlog para abordar sobrecarga
- Reasignaciones a Amigos Reinicia propuestas
- Productos a renegociar con cliente (alcance, fechas)
- Estimaciones a revisar con el PO Cliente
- Cambios de proceso interno propuestos
- Acciones de retrospective (qué mejorar el siguiente sprint)
- Responsable de cada acción y plazo

---

## INPUTS DE LA SKILL

| Input | Origen | Usado en |
|---|---|---|
| Sprint Backlog AUTOIA por miembro | Workdrive (carpeta del sprint) | Pestañas Detalle [Persona], Comparativa, Resumen |
| Hoja `Tiempos` cuadrada | AUTOIA del miembro | Métricas de horas, motivos de desvío, alertas |
| Hoja `Log de Cambios` | AUTOIA del miembro | Trazabilidad de cambios aplicados durante revisión |
| Sheet de capacidad del Equipo | Workdrive (`7f4pe6b0dbe08986b48ad8a9242b549ad7eaf` Sprint 05-26 — verificar por sprint) | Capacidad por miembro |
| ClickUp time entries por persona | API ClickUp | Validación cruzada y horas de Amigos sin Sprint Backlog |
| ClickUp tareas filtradas por Equipo | API ClickUp | Productos vencidos, status, parking |
| Plantilla canónica del Informe Ejecutivo | Workdrive (referencia: `p9ticf86741d7ee6346b69645720b029c9618`) | Estructura de pestañas y formato |

---

## OUTPUT DE LA SKILL

Un **Zoho Sheet por Equipo** con las pestañas estándar, guardado en la carpeta del sprint en Workdrive. **Nomenclatura con guiones, sin espacios** (norma de naming Reinicia — los espacios y `:` se URL-encodean y rompen `display_url_name`):

```
Informe-Ejecutivo-Sprint-Backlog-Equipo-[Equipo]-Sprint-[NN-AA]-Semana-[N]
```

Ejemplo real (v0.2): `Informe-Ejecutivo-Sprint-Backlog-Equipo-Columbia-Sprint-06-26-Semana-3`.

---

## FLUJO DE EJECUCIÓN

> 📋 **v0.2 — Flujo confirmado en el primer ciclo real.** Las tool calls clave están abajo. El detalle fino de cada pestaña se sigue refinando.

### PASO 0 — Confirmación dinámica
- Confirmar Equipo(s) a procesar.
- Confirmar miembros (incluyendo transversales y Amigos Reinicia sin Sprint Backlog).
- Confirmar sprint a documentar.
- Confirmar tipo de informe (parcial / cierre).
- Confirmar carpeta destino.

### PASO 1 — Verificación de precondiciones
- Comprobar que **todos los AUTOIA del Equipo están procesados** (la skill de revisión se ha ejecutado en cada uno).
- Si falta alguno, **avisar al PO** y proponer ejecutar la skill de revisión antes.
- Si hay **Amigos Reinicia sin Sprint Backlog Zoho**, recopilar sus time entries de ClickUp para incluirlos como pestaña.

### PASO 2 — Lectura de datos por miembro
- Por cada miembro, leer:
  - Hoja `Tiempos` completa (Sprint Backlog principal + huérfanas + bloque Metodología)
  - Hoja `Log de Cambios` (extraer alertas, propuestas de mejora, motivos de desvío)
  - Capacidad del miembro (de Sheet de capacidad)
- Acumular datos en estructura de Python para agregación.

### PASO 3 — Lectura de datos transversales de ClickUp
- Productos del Equipo con status `DOING` y fecha límite vencida.
- Productos en `parking e incidencias`.
- Time entries de miembros sin Sprint Backlog Zoho (POs como Pablo/Óscar Díez, Amigos Reinicia).
- **`clickup_get_time_entries` SÍ devuelve entries de cualquier usuario** pasando `assignee_id` + `start_date` + `end_date` + `workspace_id=762713`. (La antigua limitación "solo el usuario autenticado" es obsoleta.) IDs equipo conocidos: Néstor 766716, Pablo 87715920, Paolo 2447443, Alejandro 93805276, Johanna 56699411, José Barreiro 87739095, Fabián 93744950, Óscar Díez 93631901, Óscar Seuba 99694542, David Marco 99694543, Rocío Córdoba 8795157.
- **Aprendizaje v0.2 — depuración de timers solapados/fantasma (miembros sin AUTOIA).** Las horas brutas de ClickUp pueden estar infladas por cronómetros solapados (dos timers a la vez) o un timer fantasma sin cerrar. Para un PO muy transversal (caso Óscar Díez), **depurar antes de reportar**:
  1. Extraer los `start`/`end` (ms) de TODAS las entries.
  2. Calcular el **neto por unión de intervalos** (merge): el tiempo real es la unión de todos los [start,end), de modo que un tramo con dos timers cuenta una sola vez.
  3. Reportar **horas netas** como dato principal, con la salvedad del bruto (ej. "86,20h netas; bruto 88,59h −2,39h solapes"). Listar los solapes >3 min en la pestaña de Detalle.
  4. Si el solape es alto y reincidente, dejarlo como **alerta** (recordatorio al miembro de parar el cronómetro al cambiar de tarea). Síntoma de timer fantasma: una entry de muchas horas (>10h) o entries que solapan en el tiempo.
  5. Si un dato histórico de un informe previo no es reconciliable con los timestamps actuales, **documentarlo en el Log sin inventar causa** y sin alterar el histórico.

### PASO 4 — Cálculo de KPIs agregados
- Capacidad total Equipo.
- Total tracked y desglose plan / metodología / huérfanas.
- % utilización.
- Sobrecarga.
- Distribución por cliente.
- Productos por status.
- Motivos de desvío agregados (dropdown Col K).

### PASO 5 — Creación / actualización del Zoho Sheet
- **Duplicar SIEMPRE con `ZohoSheet_copy`** (API nativa de Sheet), NO crear desde cero ni usar `ZohoWorkdrive_copyFileOrFolder`. `ZohoSheet_copy` hereda estructura, fórmulas y formato del informe anterior, y permite nombrar al crear con `workbook_name` + `parent_id`. Params: `method=workbook.copy`, `resource_id` (informe base), `workbook_name`, `parent_id` (carpeta del sprint).
- **Mecanismo parcial → cierre (confirmado v0.2): crear un fichero NUEVO duplicando el de la semana anterior**, dejando el anterior intacto como histórico. NO actualizar in situ salvo que el PO lo pida explícitamente. Ej.: el informe "Semana 2" se duplica a "Semana 3" y se actualiza este último.
- **Protocolo de validación de fichero** (heredado de Workdrive): tras `ZohoSheet_copy`, llamar `getFileOrFolderDetails` y verificar `status=1`, nombre exacto sin timestamps, `display_url_name` sin `%3A`/`%20` raros. Si algo falla, AVISAR antes de trabajar encima.
- La copia ya trae todas las pestañas: NO hay que recrearlas. Solo se actualiza contenido y, si un miembro nuevo entra/sale, se añade/oculta su pestaña.

### PASO 6 — Rellenar pestaña Portada
- Datos identificativos del Equipo, sprint, fechas, autor, versión.

### PASO 7 — Rellenar pestaña Resumen Equipo
- KPIs agregados, top 5 alertas, top 5 mejoras propuestas.

### PASO 8 — Rellenar pestaña Comparativa Personas
- Una fila por miembro con métricas comparables.

### PASO 9 — Crear pestañas Detalle por Persona
- Una pestaña por miembro con desglose individual.
- Pestañas adicionales para Amigos Reinicia sin Sprint Backlog Zoho.

### PASO 10 — Rellenar pestaña Detalle Alertas Equipo
- Consolidación de alertas operativas detectadas en cada AUTOIA + transversales de ClickUp.

### PASO 11 — Rellenar pestaña Acciones Equipo
- Decisiones recomendadas, derivadas de las alertas y de la sobrecarga detectada.
- Esta pestaña puede requerir **input del PO líder** para validar las acciones propuestas antes de incluirlas.

### PASO 12 — Validación y entrega
- Verificar coherencia de datos entre pestañas (ej. suma de tracked en Comparativa = suma en Detalle de cada persona; un transversal como Paolo debe mostrar el MISMO total en ambos informes).
- **RUTINA DE VALIDACIÓN DE FORMATO OBLIGATORIA (v0.2 — nacida de errores reales).** Tras formatear CUALQUIER tabla:
  1. Calcular el rango de la tabla como `[fila_encabezado, última_fila_con_contenido]`, leyendo el `used_row` del worksheet — NO fijar la última fila "de memoria".
  2. Tras aplicar `format_ranges`, **releer explícitamente la ÚLTIMA fila de datos** y confirmar que tiene contenido en su sitio. Las últimas filas (TOTAL, último patrón, última alerta) son el punto ciego: se escaparon del formato en el primer ciclo (filas 16 y 22, dos veces).
  3. No dar una tabla por terminada hasta verificar su última fila.
- **Formatear es un paso SEPARADO de mover/escribir contenido.** Al mover contenido entre columnas (p. ej. compactar G→F o E→D), el formato NO se arrastra: hay que reaplicarlo después. Llevar checklist explícito "¿esta tabla tiene formato aplicado hasta su última fila?" para CADA tabla de CADA pestaña (incluidas Alertas y Acciones, que es fácil olvidar porque no son tablas de "datos numéricos").
- **Límite de payload (~414 Request-URI Too Large).** `set_content_to_multiple_cells` por URL falla con payloads grandes. Partir las escrituras en lotes de ≤ ~33 celdas.
- Generar URL de acceso al Sheet (`https://sheet.zoho.eu/sheet/open/{resource_id}`).
- Reporte final al PO líder con resumen y enlace. **No tengo vista previa del render**: recomendar siempre al PO una ojeada visual a una pestaña de Detalle (con tablas) y una de Acciones para confirmar anchos y alineación.

---

## INTERACCIÓN CON EL PO LÍDER DURANTE LA EJECUCIÓN

> 📋 **v0.2 — Puntos de validación confirmados.**

Casos donde la skill **debe pedir input al PO** antes de continuar:

- Discrepancias detectadas entre AUTOIA (ej. cuadre KO en alguno).
- Acciones propuestas en la pestaña Acciones Equipo.
- Mejoras propuestas a la skill `revision-sprint-backlog-equipo-reinicia` detectadas durante la generación.
- Inclusión de un Amigo Reinicia con horas tracked como pestaña aparte.

---

## OPERACIONES DESTRUCTIVAS Y AUDITORÍA

**Confirmado v0.2:** el Informe mantiene su propia pestaña **"Log Generación"** que registra cada generación/actualización (fecha, hora, snapshot, descripción de cambios, autor). Cada ejecución añade una fila. Ojo: en la plantilla heredada las filas antiguas del Log pueden tener el contenido desplazado una columna a la izquierda respecto a la cabecera; alinear las filas nuevas con la cabecera (col 2=Fecha, 3=Hora, 4=Snapshot, 5=Cambios, 7=Generado por). Como esta skill crea un fichero nuevo por snapshot (no actualiza in situ), el Log del fichero anterior queda congelado como histórico.

---

## RECURSOS CLAVE

### Constantes de marca Reinicia
- Azul primario: `#3812CF`
- Acento: `#D9D0FB`
- Filas alternas: `#EBEBEB`
- Total fila: `#D9D0FB`
- Fuentes: Manrope Regular y Manrope Bold

### Plantilla canónica de referencia
- Informe Ejecutivo Equipo Columbia Sprint 05-26: `p9ticf86741d7ee6346b69645720b029c9618`
- Informe Ejecutivo Equipo Proactive Sprint 05-26: `p9ticd3012db452cd4137b59248ed46b5512b`
- **Referencia viva v0.2** (primer ciclo real, formato y homogeneización aplicados):
  - Columbia Sprint 06-26 Semana 3: `kcqv400e4b313c2a74dffb218af6c0f2d7d85`
  - Proactive Sprint 06-26 Semana 3: `kcqv42d71de82d2144edeb66e148de743109d`

### Herramientas MCP usadas (confirmadas en v0.2)
- **Zoho Sheet**: `ZohoSheet_list_all_worksheets`, `ZohoSheet_get_content_of_worksheet`, `ZohoSheet_get_content_of_range`, `ZohoSheet_set_content_to_multiple_cells` (escritura por celdas, en lotes ≤33), `ZohoSheet_format_ranges` (formato), `ZohoSheet_copy` (duplicar informe base → nuevo, nombrando con `workbook_name`+`parent_id`).
- **Zoho Workdrive**: `ZohoWorkdrive_getFileOrFolderDetails` (validación de fichero tras copiar).
- **ClickUp**: `clickup_get_time_entries` (horas por persona, ver Paso 3), `clickup_filter_tasks`, `clickup_get_task`, `clickup_resolve_assignees` (verificar si alguien existe en el workspace, p. ej. confirmar alta pendiente de Marcos Ortiz → devuelve `null`).

### Patrón de formato de tabla canónico (v0.2)
Para toda tabla del informe (Detalle, Alertas, Acciones):
- **Fila de encabezado de columnas**: `fill_color=#3812CF`, `font_color=#FFFFFF`, `bold=true`, `font_name=Manrope`, bordes blancos `solid all_border`, `vertical_alignment=middle`.
- **Filas de datos**: `fill_color=#EBEBEB`, `font_color=#1A1A2E`, `font_name=Manrope`, bordes blancos, `wrap_text=true` en celdas de texto largo.
- **Fila TOTAL**: `fill_color=#D9D0FB` (lavanda acento), `bold=true`, resto igual.
- **Título de sección** (rótulo sobre la tabla): se deja como texto normal, NO es encabezado de tabla — cuidado de no pisarlo al insertar la fila de encabezado de columnas.
- Manrope ya suele ser la fuente por defecto de la plantilla; aplicarla no hace daño.
- **Anchos de columna**: las columnas de texto largo (Acción sugerida en Alertas, Plazo/Notas/Recomendación en Acciones) necesitan ~300px. No estrechar columnas al formatear.

---

## LIMITACIONES TÉCNICAS CONOCIDAS

> 📋 **v0.2 — Limitaciones confirmadas en el primer ciclo real.**

Heredadas de la skill de revisión:
1. **Formato numérico personalizado no soportado en API**: aceptar decimales largos en celdas con fórmula.
2. **Time entries sin task no recuperables**: reportar al PO como anomalía.
3. **`worksheet_id`/`worksheet_name` varía entre ficheros**: siempre listar primero.

Confirmadas en v0.2:
- **`ZohoSheet_copy` SÍ resuelve la duplicación** (heredando estructura, fórmulas y formato). Queda descartado el TODO de "crear cada pestaña programáticamente".
- **No hay vista previa del render**: la validación visual final la hace el PO. Compensar con la rutina de validación de última fila (Paso 12).
- **Payload ~414 (Request-URI Too Large)** en `set_content_to_multiple_cells`: lotes de ≤ ~33 celdas.
- **`format_ranges` no se puede "leer"** (get_content devuelve solo contenido, no formato): por eso la validación de formato verifica el CONTENIDO de la última fila como proxy de que el rango llegó hasta el final.
- **Eliminar columnas físicas no es seguro** vía API (afecta a toda la hoja, no solo a la tabla): para "quitar" una columna sobrante, mover el contenido a la izquierda y dejar la columna vacía; informar al PO de que la columna física permanece (se puede ocultar/borrar manualmente en la UI).
- Generación de gráficos integrados: sigue pendiente de validar; por ahora formato solo tabular.

---

## VERSIONES

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v0.1 (esqueleto)** | 2026-05-03 | Néstor + Claude | Esqueleto inicial. Estructura validada con el Informe Ejecutivo Columbia Sprint 05-26 (7 pestañas). Inputs/outputs/flujo en alto nivel. Pendiente detalle técnico tras primera ejecución real. |
| **v0.2** | 2026-05-26 | Néstor + Claude | Primer ciclo real (Columbia + Proactive, Sprint 06-26, parcial Día 14). Confirmado: duplicación con `ZohoSheet_copy`; mecanismo parcial→cierre = fichero nuevo conservando histórico; nomenclatura con guiones; patrón de formato de tabla canónico (cabecera azul / cuerpo gris / TOTAL lavanda); homogeneización de columnas en Detalle (Estimado 0h vs —); estructura de Detalle variable por persona (operativo/transversal/PO sin AUTOIA/narrativo); depuración de timers solapados por unión de intervalos para miembros sin AUTOIA; `clickup_get_time_entries` para cualquier usuario; no crear pestañas vacías (anotar en Alertas). **Rutina de validación de formato obligatoria** (verificar última fila de cada tabla; formatear es paso separado de mover contenido) nacida de errores reales. Confirmaciones en texto si el selector no llega. |

---

## PENDIENTES DE EVOLUCIÓN

### Resuelto en v0.2 (primer ciclo real)
- ✅ **Especificar tool calls exactas** del flujo → hecho (Paso 5, Paso 3, Herramientas MCP).
- ✅ **Mecanismo "actualización" vs "regeneración"** → fichero nuevo por snapshot conservando histórico.
- ✅ **Punto de validación humana** → render visual lo confirma el PO; rutina de validación de última fila incorporada.
- ✅ **Plantilla canónica que se duplica** → `ZohoSheet_copy` sobre el informe del snapshot anterior.

### Para la próxima iteración (sigue abierto)
- **Detallar contenido celda a celda** exacto de Portada/Resumen/Comparativa (filas y columnas fijas) inspeccionando la plantilla viva — aún se hace leyendo cada vez.
- **Definir fórmulas** de la pestaña Comparativa Personas (hoy se escriben valores, no fórmulas).
- **Validar generación de gráficos** o aceptar formato solo tabular.
- **Plantear `wrap_text` y altura de fila automática** para celdas largas de Alertas/Acciones.

### A futuro (medio plazo)
- **Export adicional a Word/PDF** para Dirección si se solicita.
- **Comparativa entre sprints** (sprint actual vs anteriores) en una pestaña aparte.
- **Detección automática de patrones de desvío** entre sprints (ej. mismo cliente con `COORDINACIÓN CLIENTE` recurrente).
- **Dashboard agregado de varios Equipos** para vista global de Reinicia.
- **Tabla canónica de Motivos de desvío en ClickUp** alimentada con los hallazgos de cada sprint.
