---
name: informes-dedicacion-clientes-reinicia
description: >
  Skill para generar y actualizar Informes de Dedicación de Horas para clientes
  de Reinicia con Soporte Operativo contratado. Cubre el flujo completo: elicitación
  al PO, lectura de tarjetas y time entries de ClickUp, redacción de Resolution
  Summaries por ítem, construcción del Zoho Sheet con 7 pestañas (Informe/Histórico
  cara cliente + PO Breakdown / Pivot Table / ClickUp Data / Bonus History / Leyenda
  internas) con refinamiento visual canónico v1.4 (lavado base, Tabla Reinicia,
  bloques de configuración, Col G facturable en lavanda, redondeo a 2 decimales con
  preservación, notas obligatorias), fórmulas en español, bonus UPLIFT por producto
  y Operational Planning para Account Management con % congelado vía Bonus History,
  semáforo de consumo con comentarios automáticos, e inventario de anomalías al cierre.

  Actívala cuando el PO pida generar, crear o actualizar el informe de dedicación o
  el report de soporte de un cliente para un periodo concreto.

  No procesa soporte ni genera factura (skills separadas).
---

# SKILL: Informes de Dedicación de Horas a Clientes — Reinicia

> **Versión vigente: v1.4 — 21/06/2026** · ver changelog al final (`## Versiones`)

---

## 1. Propósito y alcance

### Qué hace esta skill
Genera y actualiza el **Informe de Dedicación de Horas** que Reinicia envía a sus clientes con Soporte Operativo contratado. El informe documenta para un periodo dado:
- Horas contratadas, consumidas y restantes
- Estado del consumo mediante semáforo visual
- Detalle por ítem de soporte trabajado con explicación del valor entregado
- Histórico de periodos anteriores (Historical)
- Detalle técnico interno de auditoría (Pivot Table, PO Breakdown, ClickUp Data)

El informe es la pieza clave de la rendición de cuentas al cliente y, a la vez, la palanca comercial para anticipar la renegociación de la siguiente bolsa de horas o ampliación de cuota.

Estructura del workbook en v1.3 (**7 pestañas**):
1. **Report** — pestaña cara al cliente
2. **Historical** *(reubicada en v1.3, era 5ª)* — histórico de periodos del cliente, también visible al cliente
3. **PO Breakdown Preparation** — pestaña interna del PO con tabla principal de bonus, tabla **Operational Planning** (nueva en v1.3) y fechas
4. **Pivot Table** — agregación interna por tarjeta
5. **ClickUp Data** — time entries crudos
6. **Bonus History** *(nueva en v1.2, **unificada en v1.3** con columna Type)* — fuente de verdad UNIFICADA del % congelado por ítem (Bonus, Management, Refinement)
7. **Leyenda** *(nueva en v1.3)* — documento de referencia interno con explicaciones de cada pestaña y ejemplos numéricos

**Visibilidad al cliente** (al cerrar el informe, antes de enviar): visibles **Report** + **Historical** únicamente. El resto se ocultan manualmente desde la UI (ver Sección 13).

### Qué NO hace esta skill
- **NO** procesa tareas de soporte llegadas por formulario o correo (skills `soporte-procesamiento-clickup-reinicia` y `soporte-correo-clickup-reinicia`).
- **NO** actualiza el Plan de Proyecto del cliente en Zoho Sheet (skill `plan-proyecto-zoho-sheet-reinicia`).
- **NO** genera la factura del periodo (proceso comercial gestionado en Zoho Books).
- **NO** crea, abre o cierra productos de Gestión mensuales (skills `apertura-gestion-mensual-clickup-reinicia` y `cierre-gestion-mensual-clickup-reinicia`).
- **NO** procesa Sprint Backlogs de equipo (skill `revision-sprint-backlog-equipo-reinicia`).

### Skills relacionadas
- `soporte-procesamiento-clickup-reinicia` — procesa el soporte que entra antes de que llegue al informe.
- `soporte-correo-clickup-reinicia` — crea tarjetas de soporte a partir de correos.
- `apertura-gestion-mensual-clickup-reinicia` — debería generar la subtarea de "Generación informe dedicación..." que esta skill cierra al terminar (ver sección 12 — pendiente de evolución detectado en v1.1).
- `cierre-gestion-mensual-clickup-reinicia` — cierre operativo del mes (esta skill alimenta su trabajo).
- `marca-reinicia` — referencia para paleta, fuentes y aplicación del logo en el informe.

### Modos de la skill
**Modo A — Generación**: nuevo informe desde cero para un periodo específico. Mayor parte del trabajo.
**Modo B — Actualización**: modificación de un informe ya generado. Versión mínima en v1.1, se irá refinando con casos reales.

---

## 2. Activación y triggers

### Triggers de generación (Modo A)
- "genera el informe de dedicación de [CLIENTE]"
- "informe de horas de [CLIENTE]"
- "genera el report de soporte de [CLIENTE] del mes [X]"
- "crea el informe de dedicación de [CLIENTE] del periodo [X] a [Y]"
- "informe de dedicación [CLIENTE]"
- "report de dedicación [CLIENTE]"

### Triggers de actualización (Modo B)
- "actualiza el informe de dedicación de [CLIENTE]"
- "modifica el informe de [CLIENTE]"
- "ajusta el informe v[N] de [CLIENTE]"
- "añade [algo] al informe de dedicación de [CLIENTE]"

### Detección automática de modo
Claude detecta el modo por contexto:
- Si el PO menciona un periodo y no hay informe previo conocido en la conversación → Modo A
- Si el PO menciona un informe existente, una v[N] específica, o pide ajustes/modificaciones → Modo B
- En caso de duda, **preguntar al PO** explícitamente.

### No usar esta skill para
- Tareas de soporte sin contexto de informe (usar las skills de soporte)
- Resumen de horas para uso interno sin entregable al cliente
- Información comparativa entre clientes (se desarrollará en v2.0)

---

## 3. Modo A: Generación de informe nuevo

### 3.1 Elicitación inicial (preguntas secuenciales al PO)

Claude hace las preguntas **de una en una**, esperando respuesta antes de la siguiente.

#### Pregunta 1: Cliente
> "¿Para qué cliente vamos a generar el informe de dedicación?"

Claude verifica que conoce listas ClickUp `Soporte [CLIENTE]` y `Gestión [CLIENTE]` con `clickup_search`.

#### Pregunta 2: Periodo a reportar
> "¿Qué periodo cubre el informe? Indícame fecha inicio y fecha fin (formato DD/MM/AAAA)."

**Si el cliente tiene modelo bolsa puntual multi-mes**: ofrecer periodo **acumulativo desde el inicio del Soporte** (recomendado), no solo el mes actual. Lo natural en bolsa puntual es "vida del Soporte hasta hoy" — un único informe acumulativo da mejor visibilidad del consumo real vs contractual.

#### Pregunta 3: Modelo de contrato
> "¿Cuál es el modelo de contrato del Soporte Operativo de este cliente?
> (A) Bolsa puntual: las horas son únicas para todo el periodo de validez (carry-over rola entre meses).
> (B) Cuota mensual: las horas se renuevan cada mes; lo no consumido NO rola.
> (C) Híbrido: especifica las reglas."

⚠️ Esta respuesta condiciona los textos del semáforo y de los comentarios automáticos. Ver sección 3.8.

#### Pregunta 4: Horas contratadas y fechas de validez
> "¿Cuántas horas tiene contratadas el cliente? ¿Y entre qué fechas es válido el contrato (inicio y fin)?"

#### Pregunta 5: Fecha de inicio del Soporte Operativo actual
> "¿Cuál es la fecha de inicio del Soporte Operativo último contratado?"

#### Pregunta 6: PO Cliente y equipo Reinicia
> "¿Quién es el PO Cliente asignado a este cliente? ¿Y qué consultores de Reinicia participan en el soporte?"

NO mencionar nunca Amigos Reinicia ni colaboradores externos al cliente (ver sección 5.10).

#### Pregunta 7: Listas ClickUp y carpeta Workdrive
> "¿Conoces los IDs de las listas `Soporte [CLIENTE]` y `Gestión [CLIENTE]` en ClickUp? ¿Y la carpeta de Workdrive donde guardar el informe?"

#### Pregunta 8: Idioma del informe
> "¿En qué idioma quieres el informe? (ES / EN)"

⚠️ **Decisión crítica codificada en v1.1**: el idioma del informe determina **TANTO el nombre del fichero COMO el banner del Report** — ambos en el idioma del cliente. Las fórmulas siempre en español (locale del workbook). Ver sección 5.11.

#### Pregunta 9: Carry-over from previous support pack
> "¿Es el primer informe de este Soporte Operativo, o continúa un Soporte anterior?
> - Si es el primero: el Carry-over from previous queda en 0,00 h.
> - Si continúa: dime cuántas horas no consumidas rolan del Soporte anterior."

#### Pregunta 10: Productos fuera de Soporte/Gestión
> "¿Hay tarjetas en otras listas (típicamente `General [CLIENTE]`) que se hayan imputado al Soporte Operativo en este periodo y deban aparecer en el informe?"

⚠️ **Política Q-E validada en v1.1**: por defecto, **solo Soporte + Gestión cuentan contra la bolsa**. Productos en `General` (SPIKEs, BUGs en General, conectores) son trabajo de proyecto y se cobran aparte. Excluir salvo indicación expresa del PO.

#### Pregunta 11 (nueva en v1.1): Modo de ejecución
> "¿Lanzamos los comentarios automáticos del semáforo al final, o vamos en modo **dry-run** (genero el informe pero NO disparo comentarios automáticos, los validamos juntos antes)?"

Mi recomendación por defecto: **modo dry-run** para primeras ejecuciones de cada cliente nuevo. Es más seguro: si algún texto del comentario no es óptimo, no ensucia el producto Gestión con comentarios reales que luego haya que borrar.

### 3.2 Recopilación de datos

#### 3.2.1 Listado de tarjetas relevantes
- En `Soporte [CLIENTE]`: filtrar con `clickup_filter_tasks` por fechas del periodo. Incluir tarjetas con cualquier status que tengan time tracked. Incluir `include_closed: True` y `subtasks: True`.
- En `Gestión [CLIENTE]`: buscar las tarjetas `Gestión [Mes] [CLIENTE]` que cubran el periodo. **Para periodos acumulativos** que abarcan varios meses, incluir todas las gestiones mensuales relevantes (Gestión Abril + Gestión Mayo, etc.).
- En `General [CLIENTE]` u otras listas: incluir las tarjetas que el PO haya indicado en Pregunta 10.

#### 3.2.1.bis Consulta a informes anteriores del cliente *(NUEVA v1.2)*

Antes de construir la pestaña `Bonus History` del informe nuevo, **siempre** consultar los informes anteriores del cliente:

1. Usar `ZohoWorkdrive_searchTeamFoldersFiles` o navegación directa a la carpeta del cliente para listar ficheros con patrón:
   - `Informe-Dedicacion-*-[CLIENTE]-*` (cliente ES)
   - `Operational-Support-Dedication-Report-*-[CLIENT]-*` (cliente EN)
2. Ordenar por `created_time` ascendente (más antiguo primero).
3. Para cada informe anterior, leer su pestaña `Bonus History` (`ZohoSheet_get_content_of_worksheet` rango `A6:D25`).
4. Construir un diccionario `{task_id: (First_Report_Date, Frozen_Bonus_%, Source_Report)}` reteniendo la **primera aparición** de cada producto.

Este diccionario se aplicará en la pestaña `Bonus History` del informe nuevo (sección 7.5 — algoritmo de regeneración).

⚠️ **Primera vez para el cliente**: si no hay informes anteriores, el diccionario queda vacío; todos los productos del periodo actual entrarán como "nuevos" con `First Report Date = hoy` y `Frozen Bonus % = B4 actual`.

#### 3.2.2 Detalle por tarjeta
Para cada tarjeta del listado anterior, obtener:
- `clickup_get_task` → nombre, status, custom_fields (Tiempo MIN, Tiempo MAX), start_date, due_date
- `clickup_get_task_time_entries` → time entries del periodo. Sumar horas.
- `clickup_get_task_comments` → para la Resolution Summary (ver 3.7).

⚠️ **Atención al cálculo de horas**: las horas del informe deben ser la suma de time entries en el periodo, NO el `time_spent` total acumulado de la tarjeta.

#### 3.2.3 Identificación de categorías
- **Support**: tarjetas de la lista `Soporte [CLIENTE]` con coste (no GUARANTEE)
- **Management**: la tarjeta `Gestión [Mes] [CLIENTE]` y subtareas de coordinación
- **Inquiry**: tarjetas de Soporte clasificadas como dudas/aclaraciones (`[DUDA]` en nombre)
- **In-warranty**: tarjetas marcadas como Garantía (`[ASSUMED IN THE GUARANTEE]` u otra marca)

#### 3.2.4 Productos sin Tiempo MIN/MAX
Detectar productos sin MIN/MAX rellenos. Guardar lista para incluir en comentario final (sección 3.9).

#### 3.2.5 Time entries crudos para pestaña ClickUp Data
Recopilar todos los time entries individuales del periodo. Será la fuente de las fórmulas SUMAR.SI de la Pivot Table.

⚠️ **Limitación conocida v1.0/v1.1**: `clickup_get_time_entries` solo devuelve entries del usuario autenticado salvo cuenta admin. Avisar al PO si faltan entries.

⚠️ **Política Q-G validada en v1.1**: el tiempo del PO Cliente (ej. Óscar Díez en Carritech) **SÍ cuenta contra la bolsa**. Típicamente va a Management (Gestión), pero hay que leer también sus time entries con `clickup_get_time_entries` por su user_id. Pendiente futuro: diferenciar lo que imputa y lo que no en Soporte (v1.2).

### 3.3 Cálculos derivados

#### Hardcoded al escribir el informe
- **Hours consumed**: suma de time entries del periodo
- **Total tracked entries**: número de time entries
- **Días naturales del periodo**: `(period_end - period_start).days`
- **Días laborables del periodo**: `días_naturales * 5/7` (regla simplificada)

#### Calculados con fórmula en el sheet (locale ES)
- **Hours remaining** = `=$B$15-$B$16` (referencia entre celdas)
- **Consumption %** = `=TEXTO($B$16/$B$15;"0,00%")` — fuerza formato porcentaje con coma decimal
- **Total consumed** (BREAKDOWN) = `=SUMA(B26:B29)`
- **Subtotal billable** = `=SUMA(E36:E46)`
- **Subtotal in-warranty** = `=SUMA(E50:E54)` (siempre 0 por política Q-F)
- **TOTAL CONSUMED** = `=$E$47+$E$55+$B$29`

⚠️ **Política Q-F validada en v1.1**: items GUARANTEE muestran **siempre 0,00 h en el informe** aunque tengan tiempo real imputado. La fórmula puede ser hardcoded `0` o un valor explícito — lo importante es la regla: no inflan la factura.

⚠️ **Política Q-H validada en v1.1**: usar **datos crudos actuales de ClickUp**, no respetar valores de informes anteriores. Pequeñas divergencias (±0,01-0,03h) entre v[N-1] y v[N] son normales por recálculos desde origen.

### 3.4 Semáforo, exhaustion date y Days to contract end

#### Semáforo de Consumption % (en C18)

| Rango | Estado | Texto EN | Texto ES | fill_color | font_color |
|---|---|---|---|---|---|
| 0% - 49,99% | 🟢 Healthy | `🟢 Healthy consumption — plenty of capacity remaining` | `🟢 Consumo sano — capacidad amplia disponible` | `#D1FAF2` | `#1A6B5E` |
| 50% - 74,99% | 🟡 Monitor | `🟡 Approaching mid-consumption — monitor closely` | `🟡 Consumo intermedio — vigilancia recomendada` | `#FEFDCD` | `#7A5C00` |
| 75% - 99,99% | 🟠 Negotiate | `🟠 High consumption — consider negotiating renewal` | `🟠 Consumo alto — valorar renovación` | `#FFE0CC` | `#A04000` |
| ≥ 100% | 🔴 Exceeded | `🔴 Contract limit exceeded` | `🔴 Límite contractual superado` | `#FFD0D0` | `#B0000F` |

⚠️ **Banner del semáforo extendido a C18:F18** (v1.1, no solo C18). El texto desborda visualmente y el fondo debe ser uniforme a lo largo. Aplicar mediante lógica Python al generar (no formato condicional del sheet).

⚠️ **C18 con `wrap_text: false`** para permitir que el texto desborde sobre D18, E18, F18 (que están vacías).

Acompañar con **nota en C18** (vía `cell.note.set`):
> "Calculated from Consumption % ([XX,XX]%). Threshold ranges: 🟢 Healthy 0-49% / 🟡 Monitor 50-74% / 🟠 Negotiate 75-99% / 🔴 Exceeded ≥100%."

Si la API devuelve "No approval received" en la nota, continuar y avisar al PO para que la añada manualmente.

#### Estimated exhaustion date — 3 celdas auxiliares (D20-F20)

⚠️ Ubicación canónica: **fila 20, columnas D-F**. Fondo gris claro `#F5F5F5`, tamaño 8. Etiqueta "AUX — do not edit" en D19 (sobre la celda) o nota en celda.

- **D20**: `=$B$16/[días_laborables_periodo]` — Rate per working day (hardcoded el divisor)
- **E20**: `=$B$17/$D$20` — Working days to exhaust
- **F20**: `=DIA.LAB(HOY();ENTERO($E$20))` — Exhaustion date raw

Y entonces:
- **B20**: `=$F$20` — referencia a la auxiliar
- **C20**: texto descriptivo "Projection at current consumption rate (working days only)"

⚠️ **Avisar al PO al cerrar el informe** de la ubicación D19-F20 para que no las modifique.

#### Days to contract end (B21)

Fórmula: `=ENTERO($B$9-HOY())`

⚠️ **Crítico (v1.1)**: envolver con `ENTERO()` para forzar tipo numérico. Sin `ENTERO()`, Sheet hereda el formato fecha de B9 y la celda muestra "30 abr 1900" en vez del número de días.

Texto descriptivo en C21 según rango:
- >30 días: "✅ Plenty of contractual margin" (fondo `#D1FAF2`, font `#1A6B5E`)
- 8-30 días: "⚠️ Contract approaching end — plan renewal" (`#FFE0CC` / `#A04000`)
- ≤7 días: "🚨 Contract expiring imminently" (`#FFD0D0` / `#B0000F`)

### 3.4.bis Lavado base — REGLA DEL LIENZO LIMPIO *(NUEVA v1.4)*

**Antes de poblar ninguna pestaña, ejecutar lavado base obligatorio.**

#### Por qué

`fill_color: #FFFFFF` **NO basta** por sí solo: las gridlines internas de Zoho Sheet siguen visibles y dan sensación de "rejilla fantasma" que rompe la marca Reinicia. Es necesario aplicar **simultáneamente** fondo blanco + bordes blancos en cada llamada de format. Detectado en Synuptic v2 y Gonher Mayo 2026.

#### Patrón canónico v1.4

```javascript
ZohoSheet_format_ranges({
  fill_color: "#FFFFFF",
  font_name: "Manrope",
  font_size: 10,
  border: {
    border_color: "#FFFFFF",
    border_style: "solid",
    border_type: "all_border"
  },
  range: "A1:Z100",
  worksheet_name: "[Pestaña]"
})
```

**Aplicar A1:Z100 a TODAS las pestañas como PASO 0**, antes de poblar banner, headers, tablas, etc. Esto neutraliza el formato heredado de la plantilla y previene sombreados fantasma.

#### Rangos adicionales a blanquear después de poblar (huecos internos)

Algunas filas y zonas quedan vacías por diseño del informe pero deben mantenerse limpias explícitamente para evitar que herede formato vecino:

**Informe**:
- M2:Z100 (cols a la derecha del Informe)
- A88:L100 (filas debajo del bloque de contacto)
- Rows internas vacías: 2, 12, 14, 22, 24, 31-32, 34, 44, 47, 49-59, 61, 68, 77, 83
- C25:L30 (zona limpia entre BREAKDOWN y DETAIL)

**Histórico**:
- I1:Z100 (cols a la derecha)
- A8:H100 (filas debajo)
- Rows 2, 4-5 (filas vacías entre banner, nota y tabla)

**PO Breakdown Preparation**:
- N1:Z100 (cols a la derecha)
- A38:M100 (filas debajo del TOTAL Operational Planning)
- Filas vacías obligatorias entre tabla principal y Operational Planning (rows 16-20, ver §5.A27)
- Rows internas: 2

**Pivot Table**:
- F1:Z100 + A10:E100 + rows vacías intermedias

**ClickUp Data**:
- I1:Z100 + A17:H100 (ajustar a tamaño real de datos)

**Bonus History**:
- F1:Z100 + A13:E100 (ajustar a tamaño real)
- Rows 2, 4

**Leyenda**:
- D1:Z100 (cols a la derecha)
- A37:C100 (filas debajo)
- Rows vacías intermedias entre secciones: 2, 4, 6, 15, 22, 28 (ajustar a estructura real)

#### Regla operativa

> **Cada vez que se aplica `format_ranges` debe incluir SIEMPRE las 3 propiedades juntas: `fill_color`, `border` (con `border_color` igual al `fill_color` si es zona limpia), y `font_name: "Manrope"`. Si falta cualquiera de las 3, las gridlines aparecen o la fuente cae a Roboto.** Ver §5.A19 y §5.A20.

### 3.4.ter Cliente con sistema de informes preexistente *(NUEVA v1.4)*

Caso aplicable cuando el cliente tiene ya en su carpeta de Workdrive informes previos en formato distinto al canónico v1.3+ (ej. informes quincenales, cadencia distinta, plantilla obsoleta).

**Detección** en fase 3.2.1.bis: al inventariar la carpeta del cliente, comprobar si hay ficheros que matchen el patrón de informe (Informe-Dedicacion-* / Operational-Support-*) pero con nomenclatura o estructura distinta a la canónica.

**Si se detectan**, preguntar al PO antes de continuar:

**Opción A — Migrar:**
> "Existen N informes previos con formato no canónico. ¿Quieres que rehaga el último en formato canónico v1.4 y descontinúe el sistema previo? Esto implica que el cliente vea un cambio de plantilla en el siguiente envío."

**Opción B — Coexistir (lo más habitual):**
> "Crear informe nuevo en canónico v1.4 sin tocar los antiguos. Carry-over de horas = 0 (no se arrastra consumo previo del sistema descontinuado). Documentar la coexistencia en una nota interna en la pestaña Leyenda."

**Opción C — Mantener formato previo:**
> "La skill no soporta replicar formatos antiguos. Si insistes en mantener el formato previo, hay que generar manualmente sin skill."

#### Si el PO elige B (Coexistir)

Añadir en la pestaña Leyenda, sección "Notas operativas", una fila explicativa:

```
| Coexistencia con informes previos | Hasta [fecha], los informes de soporte se generaron con plantilla antigua (cadencia [X]). A partir de este informe, se aplica la plantilla canónica v1.4. Carry-over = 0. Plan de unificación futura: [pendiente / fecha estimada]. |
```

**Validado en Gonher Mayo 2026** (3 informes quincenales previos de Alejandro Pont → elección B, plantilla canónica desde Mayo).

### 3.5 Creación del workbook

#### 3.5.1 Nombre canónico del workbook (v1.1)

⚠️ **Convención por idioma del cliente** (validada en v1.1 con Carritech):

**Cliente ES** — fichero en español:
```
Informe-Dedicacion-Soporte-Operativo-[CLIENTE]-[DD-MM-AAAA]-a-[DD-MM-AAAA]-AUTOIA-v[N]
```

**Cliente EN** — fichero en inglés:
```
Operational-Support-Dedication-Report-[CLIENT]-[DD-MM-YYYY]-to-[DD-MM-YYYY]-AUTOIA-v[N]
```

Reglas absolutas:
- **Hyphens** siempre, nunca espacios
- Sin caracteres especiales (`+`, `:`, acentos, ñ)
- `v1`, `v2`, `v3` para versiones (no `v01`, no `V1`)
- "Hours" o "Horas" en el nombre del fichero **DEPRECADO en v1.1** — siempre "Dedicacion" / "Dedication"

#### 3.5.2 Creación con ZohoSheet_create_workbook
```
method=workbook.create
workbook_name=[nombre canónico]
parent_id=[ID carpeta Workdrive del cliente]
```

#### 3.5.3 Validación post-creación (obligatoria)
Inmediatamente después, llamar `ZohoWorkdrive_getFileOrFolderDetails`:
- `status: 1`
- `name` exactamente igual al solicitado
- `display_url_name` sin `%3A` ni `%20`

Si algo falla, descartar el fichero (mover a papelera) y recrear.

### 3.6 Construcción de las 6 pestañas

Por defecto al crear el workbook hay una hoja `Hoja1` (locale ES). Renombrar a `Report` y crear las 5 restantes con `ZohoSheet_create_worksheet`.

Orden y nombres exactos:
1. `Report` (worksheet_id `0#`)
2. `PO Breakdown Preparation` (`1#`)
3. `Pivot Table` (`2#`)
4. `ClickUp Data` (`3#`)
5. `Historical` (`4#`)
6. `Bonus History` (`5#`) *(nueva en v1.2)*

### 3.7 Resolution Summary y Original Request *(ampliada en v1.2)*

Para cada tarjeta del DETAIL BY ITEM:

**Resolution Summary (col K)**: leer comentarios y descripción de la tarjeta. Redactar 1-3 frases en el idioma del informe — qué se hizo y qué valor se entregó al cliente.

**Original Request (col L, v1.2)**: extraer la petición original del cliente para que el cliente reconozca lo que pidió originalmente. Patrón:
`'Original name: <task name original ClickUp>. Cliente request: <texto del cliente>.'`

Fuentes en orden de prioridad para `Cliente request`:
1. Custom field `Cuéntanos con todo el detalle que puedas qué es lo que necesitas` (id `b969c43b-e83c-4ae9-9a22-2a1b8d4b3c82`) — para tareas form_response
2. Custom field `Pon nombre a lo que necesitas` (id `f2e37010-9f11-4a2b-b30c-0d8aa3aeb96c`) — título corto si el anterior está vacío
3. `description` de la tarea (primer párrafo) — para tareas creadas manualmente
4. Primer hilo de correo / primer comentario — fallback

Incluir nombre del solicitante si está disponible en `¿Quién realiza la solicitud?` (id `9ac2e551-f71b-4f2f-af2f-5720be57801d`).

⚠️ **Casos especiales**:
- Tareas in-warranty `[ASSUMED IN THE GUARANTEE]`: usar verbo "reported" (`Cliente reported X, addressed under project guarantee.`)
- Tareas Account management / Gestión mensual: **L vacío** (no hay petición original puntual)

Ver detalles completos en 6.bis.D sección "Contenido de col L".

**Manual de estilo Resolution Summary — ver sección 6.bis-G** para reglas completas y ejemplos.

**Presentación al PO**: antes de escribir las Resolution Summaries Y las Original Requests al sheet, **presentar todos los borradores en una tabla compacta** al PO para validación de un vistazo. Esperar OK explícito o ajustes.

### 3.8 Disparo de comentarios automáticos según semáforo

Tras escribir el sheet completo, evaluar estado del semáforo y disparar comentarios en ClickUp si aplica.

#### Tarea destino
**SIEMPRE** el producto `Gestión [Mes en curso] [CLIENTE]`, NUNCA la subtarea. Si se pone en subtarea, el comentario se pierde al cerrarla.

#### Reglas de disparo

| Semáforo | Comentario al PO Cliente | Comentario a Néstor |
|---|---|---|
| 🟢 Verde | NO | NO |
| 🟡 Amarillo | NO | NO |
| 🟠 Naranja (75-99%) | SÍ | SÍ |
| 🔴 Rojo (≥100%) | SÍ | SÍ + Comentario adicional |

#### Texto del comentario al PO (🟠)

⚠️ **Texto enriquecido en v1.1**: el comentario menciona **ambos plazos** (agotamiento de bolsa + fin de contrato) para dar contexto completo al PO.

**Si modelo de contrato = Bolsa puntual (A)**:
```
🟠 Semáforo del Soporte Operativo de [CLIENTE] ha entrado en zona de NEGOCIACIÓN

El consumo del Soporte Operativo de [CLIENTE] ha superado el 75% — actualmente al [XX,XX]% ([N,N] h consumidas de [M,M] h contratadas, [R,R] h restantes).

A ritmo actual, la bolsa se agotará el [fecha estimated exhaustion] ([día semana]) — en aproximadamente [D] días laborables.

Conviene anticipar la conversación con [CLIENTE] para la siguiente bolsa de horas antes del agotamiento previsto. El contrato actual es válido hasta el [fecha contract_end] ([X] días) así que hay margen contractual amplio, pero conviene no apurar al límite y plantear renovación o ampliación esta semana.

Enlace al informe:
[URL]

Aviso automático generado por la skill informes-dedicacion-clientes-reinicia v[N] al detectar semáforo en zona NEGOTIATE (75-99%).
```

**Si modelo de contrato = Cuota mensual (B)**: adaptar texto a "cuota mensual" en vez de "bolsa puntual".

**Si modelo de contrato = Híbrido (C)**: adaptar al detalle informado por el PO.

#### Texto del comentario a Néstor (🟠)

```
🟠 Aviso al 75% — Soporte Operativo [CLIENTE] cerca del agotamiento

El Soporte Operativo de [CLIENTE] está al [XX,XX]% de consumo ([N,N] h de [M,M] h). A ritmo actual, agotamiento previsto el [fecha].

Detalles completos y aviso al PO en el comentario inmediatamente anterior de esta misma tarea (ver hilo).

Enlace al informe:
[URL]

Esta es una alerta automática de Dirección de Operaciones para tu seguimiento del estado contractual. Generada por la skill informes-dedicacion-clientes-reinicia v[N] al detectar semáforo en zona NEGOTIATE (75-99%).
```

#### Texto adicional a Néstor (🔴)
```
🚨 Soporte Operativo [CLIENTE] ha superado el límite contractual ([XX,XX]%, [N,N] h por encima de las [M,M] h contratadas). Es necesario gestionar inmediatamente la regularización con el cliente: ampliación de horas, próxima bolsa, o conversión del modelo. Enlace al informe: [URL]
```

#### Asignación
- `assignee` del comentario al PO Cliente = ID del PO Cliente
- `assignee` del comentario a Néstor = `766716`

### 3.9 Comentario al PO con resumen del informe

Después de la fase del semáforo (y aunque no se haya disparado), Claude **siempre** deja un comentario en el producto `Gestión [Mes en curso] [CLIENTE]` asignado al PO Cliente con:

1. **Enlace al sheet**
2. **Datos clave del periodo**: horas / % / semáforo / exhaustion / días al fin de contrato
3. **Puntos a revisar antes de enviar al cliente**: Carry-over, logos pendientes, Resolution Summary, items en curso
4. **Productos sin Tiempo MIN/MAX** (lista completa)
5. **Inventario de anomalías detectadas** (ver §3.10.bis) con acción correctiva sugerida
6. **Aviso de subtarea cerrada**

⚠️ Va al **producto Gestión del cliente** (ej. `Gestión Mayo 2026 [SYNUPTIC]`), NO a la lista interna de Gestión Reinicia, NO a la subtarea de generación.

⚠️ **v1.4 — Refinamiento visual post-publicación**: si después de publicar el comentario inicial se aplican refinamientos visuales adicionales al workbook (ej. ajustes de marca, redondeos, notas), publicar un **comentario adicional** detallando los cambios visuales y conservando el enlace. **No borrar ni editar el comentario original** (preserva trazabilidad del estado entregado inicialmente).

### 3.10 Cierre formal

Marcar la subtarea de generación del informe como `Closed` con `clickup_update_task`.

⚠️ **Si la subtarea no existe (v1.1)**: crearla en el momento con `clickup_create_task` (padre = producto Gestión, nombre canónico `Generación informe dedicación horas periodo [DD-MM-AAAA] a [DD-MM-AAAA] [CLIENTE]`) y cerrarla. Esto deja registro de que el informe se generó.

📝 **Nota interna**: lo ideal es que `apertura-gestion-mensual-clickup-reinicia` cree la subtarea automáticamente al abrir cada mes. Ver sección 12.

### 3.10.bis Inventario automático de anomalías de cierre *(NUEVA v1.4)*

Antes de generar el comentario final al PO (§3.9), la skill ejecuta **6 chequeos automáticos** y, para cada anomalía encontrada, la incluye en el comentario con su acción correctiva sugerida.

#### 1. Time entries sin task asociada en el periodo

Buscar entries en `clickup_get_time_entries` cuyo campo `task.id` sea null o no resoluble.

**Reportar**: lista de time entry IDs con duración, usuario y fecha.

**Acción sugerida**: el PO debe revisar manualmente, asociar a una task existente o eliminar el time entry. La hora queda fuera del informe hasta que se resuelva.

#### 2. Time entries de personas no del equipo Reinicia confirmado

Comprobar `user.id` contra la lista oficial del equipo Reinicia (memoria #27).

**Reportar**: lista de time entries con nombre de usuario externo, total de horas.

**Acción sugerida**: típicamente un colaborador externo (Amigo Reinicia o consultor puntual). Si imputaron por error, eliminar; si era intencionado, validar inclusión con el PO Cliente antes de facturar.

Caso Gonher Mayo: bug `invalid_type` en `task.id` de un time entry de José Barreiro.

#### 3. Time entries de miembros del equipo Reinicia en productos de OTROS clientes

Para cada miembro del equipo Reinicia presente en este informe, comprobar si tiene además time entries en el mismo periodo asociados a tareas de otros clientes.

**Reportar**: lista con persona, otro cliente, horas imputadas allí.

**Acción sugerida**: verificar que la asignación a otro cliente es correcta (no error de imputación). Si lo era, no hacer nada — son horas legítimas del otro cliente. Si fue error, mover entry al cliente correcto.

Caso Gonher Mayo: Ronald Urquidi imputó 2h en Breezom mientras supuestamente estaba dedicado a Gonher.

#### 4. Tarjetas duplicadas en ClickUp del mismo nombre

Buscar tareas en la lista de cliente con `name` idéntico (case-insensitive).

**Reportar**: lista de duplicados con task IDs.

**Acción sugerida**: el PO debe consolidar (mover horas + comentarios a una y cerrar/eliminar la otra). Riesgo: doble facturación si ambos están en el informe.

Caso Gonher Mayo: `869d2dz57` y `869d2rjh6` ambas como "Gestión Mayo 2026 [GONHER]".

#### 5. Tarjetas de Soporte sin Tiempo MIN/MAX informado

Para tareas en la lista `Soporte [CLIENTE]`, verificar que `Tiempo MIN` y `Tiempo MAX` (custom fields canónicos) están rellenos.

**Reportar**: lista de tareas sin MIN/MAX.

**Acción sugerida**: norma Reinicia exige siempre estimación de ventana min-max al cualificar soporte. El PO debe completar antes del próximo informe.

#### 6. Modo dry-run con ClickUp Data agregada vs individual

Si el informe se generó en modo dry-run con time entries agregados por (task_id, user), advertir que en la versión oficial debe repoblarse con entries individuales (uno por entry de ClickUp).

**Reportar**: cantidad de entries agregadas vs total real.

**Acción sugerida**: si el informe va a enviarse al cliente, repoblar ClickUp Data con `cells.content.set` por lotes de 50 con time entries individuales (necesario para que el cliente pueda auditar línea por línea).

Caso Gonher v1: dry-run agregado, oficial individual.

#### Formato canónico de la sección "Anomalías" en el comentario

```
🔍 Anomalías detectadas en este periodo

1. [Tipo anomalía]
   - [Detalle 1 con IDs / horas / personas afectados]
   - [Detalle 2]
   → Acción: [acción correctiva sugerida]

2. [Tipo anomalía]
   ...

Si todas las anomalías se resuelven antes de enviar al cliente, regenerar el informe oficial.
```

Si **no hay anomalías**, incluir en el comentario:

```
✅ Sin anomalías detectadas en este periodo. El workbook está listo para los pendientes manuales de §13.
```

---

## 4. Modo B: Actualización de informe existente (versión mínima v1.1)

### 4.1 Identificación del informe
El PO menciona el informe o Claude lo busca:
- En la carpeta Workdrive del cliente: filtrar por nombre con patrón `Informe-Dedicacion-*` (ES) o `Operational-Support-Dedication-Report-*` (EN)
- Si hay varias versiones, el PO indica cuál

### 4.2 Validación pre-modificación
1. Abrir el sheet con `ZohoSheet_get_content_of_worksheet`
2. Confirmar con el PO qué cambia exactamente

### 4.3 Aplicación de cambios
Patrón:
1. `range.clear` del área afectada (no de toda la fila/columna salvo necesidad)
2. `cells.content.set` o `worksheet.csvdata.set` con contenido nuevo
3. `ranges.format.set` para reaplicar formato canónico
4. Si los datos modifican el semáforo, recalcular y actualizar texto del semáforo + comentarios automáticos si los umbrales cruzan
5. Si se modifica una named range, usar `namedrange.update` (no borrar+recrear)

### 4.4 Cambios estilísticos pestaña a pestaña

Cuando el PO pide cambios visuales pestaña a pestaña (como ocurrió en Carritech v3):
- Aplicar **bloque a bloque** (no celda a celda) usando `format_ranges`
- Para anchos de columna, usar SIEMPRE `ZohoSheet_column_width` (NO `format_ranges` — ver sección 5.A1)
- Validar con el PO al final de cada pestaña antes de pasar a la siguiente

### 4.5 Limitaciones conocidas del Modo B en v1.1
- **No detecta cell merges huérfanas** automáticamente. Avisar al PO si visualmente aparece un bloque de color tapando contenido.
- **No tiene tool de unmerge** vía MCP — siempre manual desde la UI.
- **No tiene tool de renombrado** de Zoho Sheet — siempre manual desde la UI.

> **TODO v1.2**: desarrollar Modo B completo con casos reales acumulados — flujo de "diff visual" entre versiones, gestión sistemática de merges huérfanas, recálculo automático del semáforo con disparo condicional de comentarios.

---

## 5. Buenas prácticas y aprendizajes incorporados

### 5.A1 (BUG crítico v1.1) — Anchos de columna

⚠️ **`column_width` en `ZohoSheet_format_ranges` se ignora silenciosamente** — el parámetro no está en el schema documentado y la API devuelve `success` sin aplicar nada.

**Para anchos usar SIEMPRE el tool específico `ZohoSheet_column_width`** (`worksheet.columns.width`):
```
column_index_array: [{start_column, end_column}]   # rangos discontinuos posibles
column_width: integer (1-2000 px)
```

Ejemplo:
```python
{
  "method": "worksheet.columns.width",
  "worksheet_id": "0#",
  "column_index_array": [{"start_column": 4, "end_column": 7}],
  "column_width": 120
}
```

### 5.A2 — Decimales coma es-ES

Todos los números numéricos escritos al sheet deben usar **coma decimal** si vienen como strings:
- ✅ `"24,26"` → Sheet lo interpreta como número 24,26
- ❌ `24.26` (literal JSON con punto) → Sheet lo interpreta como **texto** y rompe fórmulas

Las fórmulas escritas como strings también deben usar coma decimal y `;` como separador de argumentos:
- ✅ `=SUMAR.SI('ClickUp Data'!$B$2:$B$44;$A2;'ClickUp Data'!$F$2:$F$44)`
- ✅ `=D7*1,05`
- ❌ `=D7*1.05`

### 5.A3 — Fechas con función FECHA()

Strings de fechas como `"09/04/2026"` son interpretados inconsistentemente. Usar fórmula explícita:
- ✅ `=FECHA(2026;4;9)` → fecha real
- ❌ `"09/04/2026"` → puede quedar como texto o fecha mal interpretada

### 5.A4 — BUSCARV con 0 (no FALSO)

⚠️ Aunque la sintaxis con `FALSO` es correcta según documentación, **devuelve `#REF!` silenciosamente** en Zoho Sheet. Usar `0` como 4º argumento:
- ✅ `=BUSCARV("869cmwb40";'Pivot Table'!$A$2:$D$17;4;0)`
- ❌ `=BUSCARV("869cmwb40";'Pivot Table'!$A$2:$D$17;4;FALSO)`

### 5.A5 — Rangos BUSCARV acotados

⚠️ Columnas completas (`$A:$D`) expanden internamente a 262144 filas y rompen BUSCARV con búsqueda exacta. Acotar siempre:
- ✅ `'Pivot Table'!$A$2:$D$17`
- ❌ `'Pivot Table'!$A:$D`

### 5.A6 — Resta de fechas con ENTERO()

Cuando una fórmula devuelve un número pero está heredando formato de fecha (porque referencia una celda de fecha), envolver con `ENTERO()` fuerza tipo numérico:
- ✅ `=ENTERO($B$9-HOY())` → devuelve `121`
- ❌ `=$B$9-HOY()` → devuelve `121` pero formateado como fecha → "30 abr 1900"

### 5.A7 — CSV en lotes de ~10 filas

`worksheet.csvdata.set` rompe con HTTP 400 si el payload supera ~5KB. Partir en lotes de ~10 filas máximo:
```python
batch_size = 10
for i in range(0, len(rows), batch_size):
    batch = rows[i:i+batch_size]
    # llamar API con batch
```

### 5.A8 — update_named_range existe

Para reapuntar una celda nombrada a otra ubicación, usar `ZohoSheet_update_named_range` (`namedrange.update`):
```
method: namedrange.update
name_of_range: "Carry_over_previous"
range: "B29:B29"   # nueva ubicación
worksheet_id: "0#"
```

No hace falta borrar + recrear.

### 5.A9 — Notación de rango en namedrange.create

⚠️ `namedrange.create` requiere notación de rango con dos celdas, incluso para celdas individuales:
- ✅ `"B6:B6"`
- ❌ `"B6"` (devuelve "Invalid range reference")

### 5.A10 — Porcentajes con TEXTO()

`format_ranges` con `date_time: "0.00%"` no funciona (rechaza valores que no sean date formats). Usar TEXTO() en la fórmula:
- ✅ `=TEXTO($B$16/$B$15;"0,00%")` → devuelve string "80,87%"
- ❌ `format_ranges` con `date_time: "0,00%"` → error

### 5.A11 *(NUEVA v1.2)* — Formato fecha SÍ funciona vía API

⚠️ A diferencia del formato numérico personalizado (5.A10 — `"0,00%"`, `"0,00"`, etc., que NO funcionan vía `format_ranges.date_time`), **los formatos de fecha SÍ funcionan**:

- ✅ `format_ranges` con `date_time: "dd/MM/yyyy"` → aplica formato fecha corta
- ✅ `format_ranges` con `date_time: "dd/MM/yyyy HH:mm"` → fecha con hora
- ✅ `format_ranges` con `date_time: "MMM yyyy"` → mes abreviado + año

Esto resuelve un problema visual común: cuando se escriben fechas como strings (ej. `"04/05/2026"`, `"1/05/2026"`) en celdas vía `cells.content.set` o `worksheet.csvdata.set`, Zoho Sheet auto-interpreta algunas (días con un solo dígito) como fechas y las muestra inconsistentes (`1/05/2026` vs `04/05/2026`). **Solución**: tras escribir las strings, aplicar `format_ranges` con `date_time: "dd/MM/yyyy"` (o `"dd/MM/yyyy HH:mm"` si lleva hora) al rango. El resultado: todas las fechas se muestran de forma consistente con cero inicial.

**Excepción confirmada al límite de formato numérico**: el formato fecha es la única familia de formatos personalizados que la API acepta. Para porcentajes y números con decimales fijos, seguir usando workarounds (`=TEXTO(...; "0,00%")` y `=TEXTO(SUMA(...); "0,00")`).

### 5.A12 *(NUEVA v1.2)* — Validación post-reordenamiento obligatoria

Cuando se reordenan filas en una tabla vía reescritura del contenido (no hay tool MCP de "sort rows" nativo), el procedimiento canónico es:

1. Construir el orden nuevo en Python (típicamente `sorted(items, key=..., reverse=True)`)
2. Reescribir el bloque de datos vía `cells.content.set` o `set_content_to_multiple_cells` en el nuevo orden
3. Las fórmulas con referencias relativas se regeneran apuntando a sus nuevas filas
4. Las notas y formato visual permanecen ligados a la celda física, **no se mueven con el contenido**
5. **VALIDACIÓN OBLIGATORIA**: `ZohoSheet_get_content_of_worksheet` del rango afectado y **verificar visualmente** el orden contra el criterio de ordenación antes de dar el cambio por completado

⚠️ **Lección aprendida (Carritech v4)**: construir el reordenamiento "de memoria" sin verificación intermedia es propenso a errores cuando el ordenamiento mezcla criterios cercanos (ej. días `01/05`, `04/05`, `05/05` en el mismo mes). Siempre verificar con un `get_content_of_worksheet` tras la reescritura.

⚠️ **Reordenamiento seguro solo si formato/notas son homogéneos a lo largo del bloque**. Si en el futuro hay notas o formato distintos por fila (ej. tag de "alerta" en un producto puntual), habría que mover también las notas/formatos celda a celda — no basta con reescribir contenido.

### 5.A13 *(NUEVA v1.2)* — Conversión píxeles ↔ puntos en column_width

`ZohoSheet_column_width` recibe `column_width` en **píxeles** aunque la UI de Zoho Sheet muestra los anchos en **puntos (pt)**. Factor de conversión:

```
píxeles = puntos × 4/3
puntos = píxeles × 3/4
```

Tabla de referencia común:

| pt (UI) | px (API) |
|---|---|
| 75 | 100 |
| 100 | 133 |
| 120 | 160 |
| 140 | 187 |
| 200 | 267 |
| 280 | 373 |
| 300 | 400 |
| 342 | 456 |
| 350 | 467 |
| 380 | 507 |

Al recibir indicaciones del PO en pt (ej. "ancho 342pt"), convertir antes de llamar a la API.

⚠️ **REGLA DE ORO v1.3**: si el ancho aplicado parece más estrecho que el deseado (típico ratio 0,75), has olvidado el factor 4/3. Verificar visualmente cada column_width antes de aceptar el resultado.

### 5.A14 *(NUEVA v1.3)* — AUX cells ocultas fuera del rango visible

Para celdas auxiliares que sostienen cálculos intermedios pero no deben ser visibles al cliente (ej. cálculo de "Estimated exhaustion date" en Report), aplicar el patrón:

1. **Ubicar las celdas fuera del área visible** del informe — ej. cols G:I cuando el área visible llega hasta col D
2. **Aplicar `font_color: #FFFFFF`** (texto blanco sobre fondo blanco → invisible)
3. **Añadir nota informativa** en la primera celda del bloque AUX explicando qué hacen las celdas. ⚠️ Aplicar la nota **DESPUÉS** de haber decidido la ubicación final del bloque AUX — recuerda que las notas no se pueden eliminar vía API (ver 5.A15). Si mueves el bloque luego, la nota antigua quedará huérfana y solo podrá ser borrada manualmente.
4. Combinar con **Protect Sheet** (manual desde UI, ver Sección 13) para que el cliente no pueda hacer clic y ver las fórmulas

Ejemplo Carritech v4 — Report:
- B20 "Estimated exhaustion date" = `=$I$20` (mostrada al cliente)
- G19 = nota explicativa "AUX cells G20-I20 — do NOT edit. G20=consumption rate per working day, H20=working days remaining at that rate, I20=projected exhaustion date."
- G20 = `=$B$16/22.86` (consumo medio)
- H20 = `=$B$17/$G$20` (días restantes)
- I20 = `=WORKDAY(HOY();ENTERO($H$20))` (fecha estimada)
- Todas G19:I20 con `font_color: #FFFFFF`

### 5.A15 *(NUEVA v1.3)* — API NO permite eliminar notas de celda

⚠️ **REGLA PREVENTIVA v1.3**: dado que las notas **NO se pueden eliminar vía API**, **insertar siempre la nota correcta a la primera**, en la celda correcta y con el texto definitivo. Antes de aplicar `cell.note.set`:
1. Verificar que la celda de destino es la correcta (no una "preliminar" que luego se mueve)
2. Verificar que el texto de la nota referencia celdas/rangos definitivos (no posiciones provisionales como `D20-F20` que luego se moverán a `G20-I20`)
3. Si vas a mover el bloque de celdas (ej. AUX cells del Report), aplicar la nota **DESPUÉS** del movimiento, no antes

**Comportamiento real de la API observado en Carritech v4**:

`cell.note.set` permite **crear y sobrescribir** notas pero **NO eliminarlas**:
- Pasar `note: ""` → error 2831 (`"parameter [note] required for processing this request is missing"`)
- Pasar `note: " "` (espacio) → reporta `success` pero la nota original **persiste sin cambios**

**Workarounds si ya tienes una nota mal puesta**:
1. Sobrescribir con un texto puntero claro: `"Note moved to G19 — see auxiliary cells G20-I20."` o `"(deprecated)"`
2. Eliminar manualmente desde la UI (clic derecho → Delete comment) antes de entregar el workbook

### 5.A16 *(NUEVA v1.3)* — `content: ""` asimétrico entre tools single vs batch

Comportamiento de la API al intentar vaciar el contenido de una celda:

| Tool | `content: ""` | `content: " "` |
|---|---|---|
| `cell.content.set` (single) | ❌ Error 2831 | ✅ Success — pero deja un espacio que bloquea desbordamiento |
| `cells.content.set` (batch) | ✅ Success — vacía la celda correctamente | ✅ Success — también deja espacio |

**Regla**: para **vaciar una celda**, usar siempre `cells.content.set` (batch) con `content: ""`. NUNCA `cell.content.set` con `""`. Para vaciar una única celda, usar el batch con un solo elemento.

### 5.A17 *(NUEVA v1.3)* — Deshacer merge implícito al re-formatear

Aunque la API no expone `unmerge` explícito, **re-aplicar `format_ranges` SIN el parámetro `merge_cell`** sobre un rango previamente merged **deshace el merge** automáticamente. Verificable escribiendo contenido en la celda B del rango: si la API acepta el set y `get_content_of_cell` lo devuelve, el merge se ha deshecho.

### 5.A18 *(NUEVA v1.3)* — Reordenar pestañas requiere acción manual

La API MCP de Zoho Sheet **no expone el método `worksheet.move`** (sí existe en la API REST de Zoho Sheet, pero no en este MCP). Los métodos disponibles son `create`, `copy`, `delete`, `rename`, pero **no `move`**.

**Implicación**: si tras crear todas las pestañas el orden no coincide con el canónico (ej. Historical debe ir 2ª pero quedó 5ª), **avisar al PO** para que arrastre la pestaña a su posición desde la UI. Apuntarlo en la Sección 13 como paso manual del cierre del informe.

### 5.A19 *(NUEVA v1.4)* — Manrope con fallback a Roboto

**Síntoma**: el `format_ranges` aplica `font_name: "Manrope"` correctamente (la API acepta el cambio), pero algunas celdas se renderizan en Roboto al abrir el workbook.

**Causa**: Zoho Sheet puede hacer fallback a Roboto si la fuente Manrope no está instalada en el catálogo de fuentes del usuario propietario del workbook (no del usuario que abre el sheet, sino del owner del fichero).

**Workaround**:
- La skill debe seguir enviando `font_name: "Manrope"` siempre en todo `format_ranges`.
- **Apuntar en el comentario final al PO**: "Si visualmente aparece Roboto en lugar de Manrope, añadir Manrope al catálogo de fuentes desde Configuración Zoho > Fuentes personalizadas (operación de usuario, no de fichero)".

**Diagnóstico rápido**: cuando una pestaña recién creada aparece en Roboto pero las pestañas viejas en Manrope, el problema NO es el código de la skill, sino el catálogo de fuentes del owner.

### 5.A20 *(NUEVA v1.4)* — Re-formato pisa formato previo (orden crítico)

**Síntoma**: aplicar `fill_color: #FFFFFF` a A1:Z100 al final del proceso borra todo el formato visual previamente aplicado (banner, headers, tablas).

**Aprendizaje**: el método `ranges.format.set` **REEMPLAZA completamente** el estilo del rango, no lo fusiona. Cada llamada de format pisa el estado anterior.

**Patrón canónico de construcción de pestaña**:
1. **Reset masivo primero**: aplicar lienzo blanco (§3.4.bis) + Manrope 10 a A1:Z100.
2. **Después aplicar formatos específicos en orden de generalidad**: banner → nota descriptiva → headers → tablas → chips de status → filas TOTAL → bloques de configuración → notas en celda.
3. **Cuando se MODIFICA una pestaña ya existente**: aplicar bloque a bloque, **nunca** hacer reset masivo seguido de re-aplicar todo (cuello de botella + riesgo de perder ajustes manuales).

**Regla operativa**: si en algún momento durante la generación necesitas "limpiar y rehacer", clona la pestaña, aplica formato a la copia, y elimina la original. Pisar formato sobre una pestaña parcialmente formateada lleva a inconsistencias visibles.

### 5.A21 *(NUEVA v1.4)* — Inserción de filas rompe referencias externas

**Síntoma**: al insertar 3 filas entre la Tabla Bonus UPLIFT y el banner Operational Planning en PO Breakdown Preparation, la fórmula `Informe!B27 = 'PO Breakdown Preparation'!G34` queda apuntando a una celda vacía (debería apuntar a G37 tras la inserción).

**Causa**: `worksheet.row.insert` actualiza fórmulas relativas **dentro de la misma pestaña** pero **no toca referencias externas** desde otras pestañas a la pestaña modificada.

**Patrón canónico v1.4**:
1. Cuando se inserten filas en una pestaña, **inventariar todas las referencias externas** a esa pestaña antes de la operación (búsqueda por nombre de pestaña en las otras pestañas).
2. Después de la inserción, **re-apuntar manualmente** las fórmulas externas a la nueva fila.

**Alternativa más robusta (aplicada en v1.4)**:
- Evitar referencias por número de fila absoluto en fórmulas externas.
- Usar `SUMAR.SI` por categoría sobre Pivot Table en lugar de apuntar a `G34/G37` directamente.

Ejemplo aplicado:
```
ANTES (v1.3):
Informe!B27 = ='PO Breakdown Preparation'!G34

DESPUÉS (v1.4 canónico):
Informe!B27 = =SUMAR.SI('Pivot Table'!$C$2:$C$N;"Account management";'Pivot Table'!$D$2:$D$N)
```

La versión nueva es robusta frente a cualquier reestructuración futura de PO Breakdown.

### 5.A22 *(NUEVA v1.4)* — Anti-Roboto: font_name explícito en TODO format_ranges

**Regla absoluta**: `font_name: "Manrope"` debe incluirse **explícitamente** en CADA llamada a `format_ranges`, incluso si parece redundante.

**Por qué**: aunque la plantilla aparente tener Manrope por defecto, Zoho cae a Roboto en cuanto se aplica un cambio de formato (`fill_color`, `border`, `bold`, etc.) sin especificar `font_name`. Una sola llamada sin `font_name` corrompe la consistencia tipográfica de todo el rango afectado.

**Aprendido en Histórico v2 Synuptic**: la pestaña heredó Roboto silenciosamente al aplicar bordes blancos sin `font_name`.

**Verificación**: tras una sesión de formateo, comprobar visualmente una muestra de cada pestaña. Si aparece Roboto, identificar la llamada `format_ranges` problemática y reaplicar con `font_name: "Manrope"`.

### 5.A23 *(NUEVA v1.4)* — Redondeo a 2 decimales con preservación de fórmulas dependientes

**Regla**: toda columna que represente horas (raw, final, billed) en cualquier pestaña se muestra con **2 decimales**, no 4.

**Algoritmo de redondeo**:

```python
from decimal import Decimal, ROUND_HALF_UP, ROUND_CEILING

# Paso 1: candidato con half-up estándar
candidato = Decimal(valor_original).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

# Paso 2: validar consistencia con fórmulas dependientes
# Ej. en PO Breakdown, G = INT(D × (1+F) × 100) / 100
g_recalculado = int(float(candidato) * 1.15 * 100) / 100
if g_recalculado != g_actual:
    # Probar ceiling
    candidato = Decimal(valor_original).quantize(Decimal("0.01"), rounding=ROUND_CEILING)
    g_recalc2 = int(float(candidato) * 1.15 * 100) / 100
    if g_recalc2 != g_actual:
        # Aceptar half-up y documentar el cambio
        candidato = Decimal(valor_original).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
        documentar_cambio_en_log()
```

**Por qué importa**: preservar la coherencia matemática que el cliente puede recalcular con calculadora. Si lee `D=3,79` y `G=4,35`, el cliente recalcula `3,79 × 1,15 = 4,3585 → 4,35` ✓. Si lee `D=3,78` y `G=4,35`, recalcula `3,78 × 1,15 = 4,347 → 4,34` ≠ 4,35 → detecta inconsistencia y pierde confianza en el informe.

**Caso validado v1.4** (Synuptic v2):
- D13 = 3,784 → con half-up daría 3,78 → G13 = 4,34 (cambia, ≠ G actual = 4,35).
- Con ceiling D13 = 3,79 → G13 = 4,35 ✓ (preserva consistencia).
- Aplicar ceiling solo en D13, half-up estándar en resto de filas.

**Pestañas afectadas por la regla**:
- Informe (cara cliente): cifras a 2 decimales.
- Histórico (cara cliente): cifras a 2 decimales.
- PO Breakdown Preparation (interna): cifras a 2 decimales para coherencia con cara cliente.
- Pivot Table (interna): mantener 4 decimales (auditoría interna).
- ClickUp Data (interna): mantener 4 decimales (datos crudos).
- Bonus History (interna): mantener formato de % (no horas).

### 5.A24 *(NUEVA v1.4)* — Notas obligatorias en headers y configuración

**Regla**: toda celda de **configuración** (valores editables por el PO que afectan a cálculos) y todo **header de tabla** DEBE llevar nota explicativa con `set_note_to_cell`.

**Catálogo verbatim** de notas obligatorias por celda: ver **ANEXO B — Catálogo de notas obligatorias por celda**.

**Principio general**: cualquier celda cuyo significado no sea autoevidente para el PO, o cualquier celda con fórmula compleja, → nota obligatoria. Esto reduce el coste cognitivo del PO al revisar el workbook y evita malentendidos sobre qué editar y qué no.

### 5.A25 *(NUEVA v1.4)* — Patrón canónico "Tabla Reinicia"

**Toda tabla en cualquier pestaña del workbook sigue este patrón visual**:

```
Row N:     Banner          → fondo #3812CF, font #FFFFFF Manrope 14 bold, alineación center
Row N+1:   (vacía)          → lavado base
Row N+2:   Nota italic      → fondo blanco, Manrope 10 italic, wrap_text: false, bordes blancos, row_height: 20
Row N+3:   (vacía)          → lavado base
Row N+4:   Header           → fondo #3812CF, font #FFFFFF Manrope 11 bold, center
Row N+5..: Datos            → fondo #F2F2F2, font #000000 (NO azul), bordes #FFFFFF, Manrope 10
Row N+M:   TOTAL            → fondo #D9D0FB, font #3812CF Manrope 11 bold (PEGADO a la última fila de datos, SIN espacio entre medio)
```

**Refinamientos canónicos**:
- **Col "horas finales facturables"** (ej. G en PO Breakdown principal y G en Operational Planning) → fondo `#D9D0FB` + font `#3812CF` + bold. Destaque visual del valor facturable. La fila TOTAL es lavanda completa; la columna G es lavanda fila a fila.
- **Headers de tabla**: borde del mismo color que el fondo (#3812CF azul). Excepción: si la fila header se extiende más allá del ancho de la tabla, las columnas sobrantes (ej. K-M cuando la tabla termina en J) llevan bordes blancos para no parecer "header extendido".
- **Col A del cuerpo de tabla**: texto **negro bold** (NO azul Reinicia). El azul `#3812CF` queda reservado a headers, totales y banners — destacar la col A en azul ensucia visualmente.

**Aplica a**: BREAKDOWN del Informe, DETAIL del Informe, glosario del Informe, Histórico, tabla principal y Operational Planning en PO Breakdown, Pivot Table, ClickUp Data, Bonus History, las 4 secciones de Leyenda.

### 5.A26 *(NUEVA v1.4)* — Patrón "bloque de configuración" (verde menta + gris validación)

**Bloques de configuración editables** (defaults que el PO puede ajustar para afectar cálculos de la tabla siguiente):

```
Col A (etiqueta):    fondo #D1FAF2 (verde menta), font #000000 Manrope 10 bold
Col B (valor):       fondo #D1FAF2, font #000000 Manrope 10 bold
Col C (validación):  fondo #F2F2F2 (gris), font #000000 Manrope 10 italic
```

**Bordes blancos** en las 3 celdas. **Notas obligatorias** en celda de valor (B) y en celda de validación (C).

**Aplica a** (en PO Breakdown Preparation):
- A4:B4 — Default Bonus % UPLIFT
- A5:B5 — Bonus % bounds (validación cap 0-25%)
- A24:B24 — Default % Management to bill (Operational Planning)
- A25:B25 — Default % Refinement to bill (Operational Planning)

Si en futuras versiones aparece otro bloque de configuración (ej. tasa horaria editable, recargo por urgencia), aplicar el mismo patrón.

### 5.A27 *(NUEVA v1.4)* — Espaciado canónico entre bloques

**Reglas de espaciado vertical en pestañas con múltiples bloques**:

1. **Fila TOTAL pegada a la tabla**: NUNCA dejar filas vacías entre la última fila de datos y la fila TOTAL del mismo bloque.
2. **Entre bloques distintos**: dejar **EXACTAMENTE 5 filas vacías** entre el TOTAL de un bloque y el banner del siguiente bloque.
3. **Lavado base** en las filas vacías intermedias (fondo blanco + bordes blancos + Manrope 10).

**Caso canónico — PO Breakdown Preparation**:

```
Row 1:        Banner Tabla principal
Row 2:        (vacía)
Row 3:        Nota italic
Row 4:        Default Bonus %       (bloque config)
Row 5:        Bonus % bounds        (bloque config)
Row 6:        Header tabla principal
Rows 7..14:   8 productos individuales
Row 15:       TOTAL tabla principal (PEGADO a row 14)
Rows 16-20:   5 filas vacías        ← ESPACIADO CANÓNICO
Row 21:       Banner Operational Planning
Row 22:       (vacía)
Row 23:       Nota italic
Row 24:       Default % Management  (bloque config)
Row 25:       Default % Refinement  (bloque config)
Row 26:       Header tabla Operational
Rows 27..N:   Filas Management / Refinement
Row N+1:      TOTAL Operational (PEGADO a row N)
```

**Validado**: 5 filas vacías es lo decidido como canónico v1.4 (Synuptic v2 ya cumplía; Gonher Mayo se actualiza retroactivamente en propagación post-skill).

### 5.A28 *(NUEVA v1.4)* — Patrón canónico de fila de nota italic (row 3)

**Aplica** a todas las pestañas con nota descriptiva en row 3: Informe, Histórico, PO Breakdown Preparation, Bonus History, Leyenda.

**Formato canónico unificado**:

```
font_name: Manrope
font_size: 10
italic: true
horizontal_alignment: start
vertical_alignment: middle
wrap_text: false             ← REGLA: el texto desborda en celdas vacías a la derecha
fill_color: #FFFFFF
border: { border_color: #FFFFFF, border_style: solid, border_type: all_border }
row_height: 20               ← fijo, no auto_fit
```

**Causa del cambio**: `auto_fit + wrap_text: true` inflaba la fila a ~80px con notas largas. `wrap_text: false + row_height: 20` da consistencia visual entre pestañas.

### 5.A29 *(NUEVA v1.4)* — Cabeceras col A del Informe con wrap_text + row_height

**En el bloque "Cabecera + SUMMARY" del Informe (cols A:I, rows 3-21)**:

- Col A (etiquetas) → `wrap_text: true`, `row_height: 30`, `vertical_alignment: middle`.
- Permite etiquetas largas como "Fecha inicio Soporte Operativo" o "Hours consumed (period)" sin truncar.

**Aplica a**: A3:A11 (cabecera identificación cliente) y A15:A21 (SUMMARY métricas del periodo) del Informe.

### 5.1 Convención de nomenclatura de ficheros (v1.1 actualizado)
Ver sección 3.5.1. Resumen:
- **Cliente ES**: `Informe-Dedicacion-Soporte-Operativo-[CLIENTE]-[fechas]-AUTOIA-v[N]`
- **Cliente EN**: `Operational-Support-Dedication-Report-[CLIENT]-[dates]-AUTOIA-v[N]`
- Hyphens siempre, sin espacios, sin acentos, sin caracteres especiales
- "Hours" / "Horas" en nombre DEPRECADO desde v1.1

### 5.2 Decimal coma es-ES siempre
Ver 5.A2.

### 5.3 Bug del carácter `+` en CSV
`worksheet.csvdata.set` pierde el carácter `+`. No usar en fechas con offset horario (`06:09:13+01:00` → `06:09:13 01:00`).

### 5.4 Unicode NFC vs NFD en SUMAR.SI
SUMAR.SI compara byte a byte; un nombre con `ó` NFC vs NFD devuelve 0 silenciosamente. Normalizar a NFC siempre.

### 5.5 display_url_name sin %3A ni %20
Si tras crear un workbook el `display_url_name` contiene `%3A` o `%20` URL-encoded, el fichero está corrupto. Descartar y recrear.

### 5.6 ZohoSheet_set_note_to_cell puede dar "No approval received"
No bloqueante pero la nota no se aplica. Avisar al PO para que la añada manualmente.

### 5.7 NUNCA combinar celdas — REGLA DE ORO v1.3

⚠️ **Regla absoluta validada con Néstor el 16/05/2026**: **NUNCA usar `merge_cell`** (`merge_range`, `merge_down`, `merge_across`, `merge_and_center`) en ningún workbook de Reinicia. Aplica a **TODAS las pestañas** y a **TODOS los elementos**: banners, notas, headers de sección, headers de tabla, totales, todo.

**Patrón canónico para banners y headers extendidos visualmente**:
1. Aplicar `fill_color` al rango completo (ej. `A1:E1` para banner)
2. Escribir el texto solo en la celda izquierda (ej. A1)
3. Mantener celdas a la derecha (B1, C1, D1, E1) **vacías** para permitir el desbordamiento visual del texto largo
4. Si en una celda a la derecha hay contenido (incluso un espacio), el desbordamiento se corta — vaciarla con `cells.content.set` y `content: ""` (ver 5.A16)

**Razones**:
- Las celdas merged rompen el copy-paste, los filtros, y las referencias relativas
- La API MCP de Zoho Sheet no expone `unmerge` explícito (workaround: re-aplicar formato SIN `merge_cell` deshace el merge — ver 5.A17)
- El comportamiento visual del banner sin merge es idéntico al merged si las celdas a la derecha están vacías

### 5.8 Locale y fórmulas siempre en español
Aunque el contenido del informe sea en inglés, las fórmulas se escriben en español (locale ES del workbook):
- `SUMA`, `SUMAR.SI`, `BUSCARV`, `HOY`, `DIA.LAB`, `SI`, `ENTERO`, `REDONDEAR`, `TEXTO`, `FECHA`

### 5.9 Time entries solo del usuario autenticado
Avisar al PO si faltan entries de otros consultores y proponer reejecutar con cuenta admin.

### 5.10 No mencionar nunca Amigos Reinicia al cliente
Los Amigos Reinicia (Síntaris, Marcos Ortiz, Chisco Álvarez, Rocío Córdoba, etc.) **no aparecen jamás** en texto visible al cliente:
- No en cabecera del Report
- No en Resolution Summary
- No en glosario
- No en comentarios

Si participaron, referenciarlos genéricamente como "the Reinicia delivery team" / "el equipo de Reinicia".

### 5.11 (nuevo v1.1) — Idioma del cliente determina nombre + banner

- Nombre del fichero: idioma del cliente
- Banner del Report row 1: idioma del cliente
- Fórmulas internas del sheet: SIEMPRE español (locale del workbook)
- Resolution Summaries: idioma del cliente

Esto da coherencia total: el cliente recibe un fichero con nombre, título y contenido en su idioma; Reinicia mantiene las fórmulas en español para coherencia técnica.

---

## 6. Estructura canónica del Report (pestaña principal — "Informe" en ES, "Report" en EN)

### 6.0 Nombres de pestañas según idioma *(NUEVA v1.4)*

| Pestaña interna técnica | Cliente ES (Informe) | Cliente EN (Report) |
|---|---|---|
| Pestaña principal cara cliente | **Informe** | **Report** |
| Pestaña histórico cara cliente | **Histórico** | **Historical** |
| PO Breakdown Preparation | (sin cambio) | PO Breakdown Preparation |
| Pivot Table | (sin cambio) | Pivot Table |
| ClickUp Data | (sin cambio) | ClickUp Data |
| Bonus History | (sin cambio) | Bonus History |
| Leyenda | (sin cambio) | Legend |

**Regla operativa**:
- Las pestañas **cara cliente** se localizan al idioma del informe (Informe/Histórico para ES, Report/Historical para EN).
- Las pestañas **internas** mantienen nombre técnico en inglés porque solo las ve el equipo Reinicia. Excepción: la Leyenda se localiza a "Legend" en EN, "Leyenda" en ES (la lee el equipo + opcionalmente el cliente si se desoculta).

**Renombrado post-creación obligatorio cuando idioma = ES**:
- `ZohoSheet_create_workbook` crea por defecto "Hoja1" → renombrar a "Informe" (o "Report" en EN).
- Al crear la segunda pestaña con `create_worksheet`, especificar directamente "Histórico" (o "Historical").
- Si por error queda con nombre técnico inglés en informe ES, renombrar con `ZohoSheet_rename_worksheet` antes de poblar.

### 6.1 Plano de filas

| Row(s) | Contenido | Notas |
|---|---|---|
| 1 | Banner título | Ver 6.2. Bordes invisibles **A1:L1** *(v1.2 — extendido a L)*. Texto según idioma cliente |
| 2 | (blank) | |
| 3 | Client / [Nombre cliente] | Col A bold |
| 4 | Period / [DD MMM YYYY - DD MMM YYYY] | |
| 5 | Contract type | "Ongoing Operational Support · Pay-as-you-go support pack" (EN) o equivalente ES |
| 6 | Contracted hours / [N] | **Celda nombrada `Hours_contracted`**, valor numérico |
| 7 | Support contract start date | Fórmula `=FECHA(...)` |
| 8 | Contract validity start | Fórmula `=FECHA(...)` |
| 9 | Contract validity end | **Celda nombrada `Contract_end`**, fórmula `=FECHA(...)` |
| 10 | Reinicia team | Lista consultores, NO Amigos Reinicia |
| 11 | Report issued by | "Reinicia · Equipo [Equipo]" |
| 12 | (blank) | |
| 13 | SUMMARY | Bold tamaño 13 |
| 14 | (blank) | |
| 15 | Hours contracted / [valor] | `=$B$6` |
| 16 | Hours consumed (this period) / [valor] | **Celda nombrada `Hours_consumed`**. Hardcoded numérico con coma |
| 17 | Hours remaining / [valor] | `=$B$15-$B$16`. **Celda nombrada `Hours_remaining`** |
| 18 | Consumption % / [%] / [texto semáforo] | B18 fórmula `=TEXTO($B$16/$B$15;"0,00%")`. C18 texto del semáforo |
| 19 | Carry-over to next periods / [valor] | `=$B$17`. **Celda nombrada `Carry_over_next`** |
| 20 | Estimated exhaustion date / [fecha] / texto descriptivo | B20 `=$F$20`. Cols D-F = auxiliares |
| 21 | Days to contract end / [N] / texto estado | B21 `=ENTERO($B$9-HOY())` |
| 22 | (blank) | |
| 23 | BREAKDOWN BY CATEGORY | Bold tamaño 13 |
| 24 | (blank) | |
| 25 | Category / Hours | **En cols A-B** (v1.1, no C-D). Header `#3812CF` blanco |
| 26 | Support tickets / [valor] | Fórmula SUMAR.SI |
| 27 | Account management / [valor] | Fórmula SUMAR.SI |
| 28 | In-warranty support (no charge) / 0 | Hardcoded 0 |
| 29 | Carry-over from previous support pack / [valor] | **Celda nombrada `Carry_over_previous`**. Hardcoded del input PO. **Nota en B29** |
| 30 | Total consumed / [valor] | `=SUMA(B26:B29)` |
| 31 | (blank) | |
| 32 | (blank) | |
| 33 | DETAIL BY ITEM | Bold tamaño 13 |
| 34 | (blank) | |
| 35 | # / Item / Category / Application Area / Hours / Start Date / Delivery Date / Min h / Max h / Status / Resolution Summary / **Original Request** | Header `#3812CF` blanco. **12 cols A-L** *(v1.2 — añadida L)* |
| 36..N | Items billable, **orden Start Date DESC** *(v1.2)* | Hours con `=BUSCARV(...; 'Pivot Table'!$A$2:$D$17; 4; 0)` |
| N+1 | Subtotal billable / [valor] | `=SUMA(E36:EN)`. **Fila lavanda extendida A-L** |
| N+2 | (blank) | |
| N+3 | Additionally addressed under project guarantee (no charge): | Italic. **Fila lavanda extendida A-L** |
| N+4..M | Items in-warranty, **orden Start Date DESC** *(v1.2)* | Hours = 0 hardcoded |
| M+1 | Subtotal in-warranty / 0 | `=SUMA(E[guarantee_range])`. **Fila lavanda extendida A-L** |
| M+2 | (blank) | |
| M+3 | TOTAL CONSUMED / [valor] | `=$E$47+$E$55+$B$29`. **Fila azul Reinicia extendida A-L con bordes `#3812CF`** *(v1.2)* |
| M+4 | (blank) | |
| M+5 | GLOSSARY | Bold tamaño 13 |
| M+6 | (blank) | |
| M+7 | Term / Description | Header bold italic |
| M+8 | **Categories** (sub-header italic) | |
| M+9..M+12 | Support / Inquiry / Management / In-warranty con descripción | |
| M+14 | **Statuses** (sub-header italic) | |
| M+15..M+21 | **Orden ciclo de vida v1.2**: Open / Product Backlog / Sprint Backlog / Doing / Validation Client / Closed / Parking | |
| M+23 | **Consumption levels** (sub-header italic) | |
| M+24..M+27 | 🟢 / 🟡 / 🟠 / 🔴 con descripción | |
| M+29 | **Notes** (sub-header italic) | |
| M+30 | Reporting | "Hours include execution time and a standard delivery overhead..." |
| M+31 | Closing message | Mensaje cordial de cierre |
| M+32 | Contact | **Solo Product Owner** del cliente, NO Néstor |

### 6.2 Banner row 1 (canónico v1.2)

**Texto**: `[CLIENTE] - [Título según idioma] - [Periodo formateado]`

- **ES**: `[CLIENTE] - Informe Dedicación Soporte Operativo - 09 Abr 2026 - 11 May 2026`
- **EN**: `[CLIENT] - Operational Support Dedication Report - 09 Apr 2026 - 11 May 2026`

**Formato**:
- Fill `#3812CF`, font `#FFFFFF`, Manrope bold size 14
- Alineación start + vertical middle
- **Bordes invisibles**: `border_color: "#3812CF"` (= fill_color) → el banner se ve continuo A-L sin separaciones blancas
- Rango aplicado: **A1:L1** *(v1.2 — extendido a L tras añadir Original Request)*

### 6.3 Anchos de columna del Report

Aplicar SIEMPRE con `ZohoSheet_column_width`:

| Col | Ancho (px) | Contenido |
|---|---|---|
| A | 200 | Etiquetas SUMMARY / BREAKDOWN / DETAIL # |
| B | 280 | Item / valores principales |
| C | 100 | Category |
| D | 160 | Application Area |
| E | 75 | Hours |
| F | 95 | Start Date |
| G | 95 | Delivery Date |
| H | 60 | Min h |
| I | 60 | Max h |
| J | 130 | Status (chips) |
| K | 380 | Resolution Summary |
| **L** | **456** | **Original Request** *(v1.2)* |

### 6.4 Celdas auxiliares D19-F20

- **D19**: etiqueta "AUX — do not edit"
- **D20**: `=$B$16/[días_laborables_periodo]`
- **E20**: `=$B$17/$D$20`
- **F20**: `=DIA.LAB(HOY();ENTERO($E$20))`

Formato: fondo `#F5F5F5`, font size 8.

⚠️ **Avisar al PO en el comentario final** de la ubicación de las auxiliares para que no las modifique.

### 6.5 Banner del semáforo (v1.1)

Rango: **C18:F18** (no solo C18). Fondo uniforme según estado del semáforo derivado del % en B18.

Texto en C18 hardcoded según estado (ver tabla en 3.4). C18 con `wrap_text: false` para que desborde sobre D18, E18, F18 (vacías).

### 6.5.bis Orden canónico del Report DETAIL *(NUEVA v1.2)*

⚠️ **Ambos bloques (billable e in-warranty) ordenados por Start Date DESC** — más reciente arriba.

- Billable rows (36..N): ordenar por col F (Start Date) descendente
- In-warranty rows (N+4..M): ordenar por col F (Start Date) descendente

**Por qué descendente**: el cliente lee cronológicamente lo más fresco primero. Lo que pasó hace 6 semanas ya lo conoce; lo de la última semana es lo que tiene en mente.

**Diferencia con PO Breakdown Preparation** *(intencional)*:
- PO Breakdown → **Fecha entrada DESC** (date_created en ClickUp): el PO ve "orden de entrada al sistema"
- Report → **Start Date DESC** (fecha de arranque del trabajo): el cliente ve "cronología del trabajo"

Son fechas distintas. Cuando el PO planifica el sprint, el orden de entrada al sistema es relevante para él. Cuando el cliente lee el informe, prefiere ver primero el trabajo más reciente que recuerda fresco.

### 6.6 Mensajes de cierre canónicos

**EN**:
> "Reinicia is committed to delivering responsive, high-quality support to the [CLIENT] team. We hope this report gives you a clear view of the work done this period — your trust is what makes this collaboration possible."

**ES**:
> "En Reinicia nos comprometemos a ofrecer un soporte ágil y de alta calidad al equipo de [CLIENTE]. Esperamos que este informe os dé una visión clara del trabajo realizado en el periodo — vuestra confianza es lo que hace posible esta colaboración."

### 6.7 Contacto (v1.1)

⚠️ **SOLO Product Owner del cliente**, NO Néstor.

**EN**: `For any questions or to discuss this report, please contact [PO] (Product Owner).`
**ES**: `Para cualquier consulta o para hablar del informe, contacta con [PO] (Product Owner).`

---

## 6.bis (NUEVA v1.1) — Identidad visual canónica completa

### 6.bis.A — Paleta de colores oficial

| Función | Hex | Uso |
|---|---|---|
| Azul Reinicia | `#3812CF` | Banner row 1, headers de tabla, TOTAL CONSUMED |
| Lila acento | `#D9D0FB` | Total rows, Subtotales, Sprint Backlog status, fila tabla Total interna |
| Verde menta sutil | `#D1FAF2` | Col A de cabecera/SUMMARY/sub-secciones GLOSSARY, chips Closed, semáforo Healthy |
| Gris claro Report | `#F2F2F2` | **Pestaña Report**: fondo de filas de datos (cabecera B-K, SUMMARY B-K, DETAIL A-L, sub-secciones GLOSSARY B-K) |
| Gris Reinicia PO Breakdown | `#EBEBEB` | **Pestaña PO Breakdown Preparation**: fondo de columnas K-L-M (fechas internas Reinicia). NO usar en Report — desentona |
| Gris auxiliar | `#F5F5F5` | Solo celdas auxiliares D19-F20 |
| Gris oscuro banner | `#545454` | Banner GLOSSARY row 60 |
| Amarillo Monitor | `#FEFDCD` / font `#7A5C00` | Semáforo 🟡, status Validation Client |
| Naranja Negotiate | `#FFE0CC` / font `#A04000` | Semáforo 🟠, chips Doing |
| Rojo Exceeded | `#FFD0D0` / font `#B0000F` | Semáforo 🔴 |
| Texto Closed verde | `#1A6B5E` | Sobre fondo `#D1FAF2` |
| Texto Sprint Backlog | `#3812CF` | Sobre fondo `#D9D0FB` |
| Texto Product Backlog | `#3812CF` | Sobre fondo `#E8DDFC` |
| Texto Open | `#404040` | Sobre fondo `#E0E0E0` |
| Texto Parking | `#555555` | Sobre fondo `#CCCCCC` |

⚠️ **Regla canónica v1.2 — dos grises distintos por pestaña**:
- **Report (cara cliente)** → `#F2F2F2` (gris más claro, lectura más cómoda)
- **PO Breakdown Preparation (interno)** → `#EBEBEB` (gris Reinicia estándar) en cols K-L-M

Aplicarlos en su pestaña respectiva. No intercambiarlos: al añadir columnas nuevas, **replicar el color que ya esté presente en las columnas existentes de las mismas filas** para mantener coherencia visual.

### 6.bis.B — Bloque "Cabecera + SUMMARY" del Report

Estilo paramétrico aplicable a rows 3-11 (cabecera) y 15-21 (SUMMARY):

| Columna | Fondo | Notas |
|---|---|---|
| A | `#D1FAF2` | Etiquetas |
| B | `#F2F2F2` | Valores principales, alineación izquierda |
| C | `#F2F2F2` | Excepto C18 que tiene color del semáforo |
| D | `#F2F2F2` | Excepto D19-D20 que son auxiliares gris claro |
| E-F | `#F2F2F2` | Extensión visual lateral |

### 6.bis.C — BREAKDOWN BY CATEGORY del Report

⚠️ **Ubicación canónica en cols A-B** (no C-D como en v2 inicial). Validado en Carritech v3.

| Row | Contenido | Formato |
|---|---|---|
| 23 | Título "BREAKDOWN BY CATEGORY" | Bold size 13 |
| 25 | Header "Category / Hours" en A-B | `#3812CF` blanco bold, alineación center |
| 26-29 | Datos (Support / Account mgmt / In-warranty / Carry-over previous) | Col A `#D1FAF2`, col B `#F2F2F2` alineación izquierda |
| 30 | "Total consumed" en A-B | `#D9D0FB` con texto `#3812CF` bold |

**Cols C-D del rango**: fondo **blanco + bordes blancos** (zona limpia tras el movimiento desde versiones antiguas).

### 6.bis.D — DETAIL BY ITEM del Report

⚠️ **Sin zebra alternada** (v1.1, regla canónica). Toda la tabla en `#F2F2F2`.

| Row | Contenido | Formato |
|---|---|---|
| 33 | Título "DETAIL BY ITEM" | Bold size 13 |
| 35 | Header **12 cols A-L** *(v1.2)* | `#3812CF` blanco bold, alineación center |
| 36..N | Items billable, **orden Start Date DESC** *(v1.2)* | Fondo `#F2F2F2` A-L. Chips de status en col J |
| N+1 | Subtotal billable | `#D9D0FB` con texto `#3812CF` bold, **extendido A-L** |
| N+3 | Banner "Additionally addressed under project guarantee" | `#D9D0FB` con texto `#3812CF` italic, **extendido A-L** |
| N+4..M | Items in-warranty, **orden Start Date DESC** *(v1.2)* | Fondo `#F2F2F2` A-L. Chips de status en col J |
| M+1 | Subtotal in-warranty | `#D9D0FB` con texto `#3812CF` bold, **extendido A-L** |
| M+3 | TOTAL CONSUMED | **`#3812CF`** con texto blanco bold size 12, **bordes `#3812CF`, extendido A-L** *(v1.2)* |

**Chips de status en col J** (sobreescriben el fondo `#F2F2F2`):

| Status | fill | font |
|---|---|---|
| Closed / done | `#D1FAF2` | `#1A6B5E` |
| Doing / doing amigos | `#FFE0CC` | `#A04000` |
| Validation Client | `#FEFDCD` | `#7A5C00` |
| Sprint Backlog | `#D9D0FB` | `#3812CF` |
| Product Backlog | `#E8DDFC` | `#3812CF` |
| Open | `#E0E0E0` | `#404040` |
| Parking | `#CCCCCC` | `#555555` |

**Col K Resolution Summary**: `wrap_text: true`, `vertical_alignment: top`, `horizontal_alignment: start`, `font_size: 9`.

**Col L Original Request** *(NUEVA v1.2)*: `wrap_text: true`, `vertical_alignment: middle`, `horizontal_alignment: start`, Manrope. Fondo `#F2F2F2` (mismo que la tabla — NO `#EBEBEB`). Bordes blancos solid all_border. Ancho 456px API.

**Cabecera col L row 35**: `#3812CF` blanco bold Manrope 10, alineación start + middle, bordes `#3812CF` solid all_border.

#### Contenido de col L "Original Request" *(v1.2)*

Patrón canónico: `'Original name: <task name original ClickUp>. Cliente request: <texto del cliente extraído de "Pon nombre" / "Cuéntanos con todo el detalle" o del correo>.'`

- **Tareas tipo `form_response`** (creadas por el bot ClickUp desde un Zoho Form):
  - `Original name`: nombre completo de la tarea con prefijo (`[SUPPORT]`, `[URGENT]`, etc.)
  - `Cliente request`: contenido del custom field `Cuéntanos con todo el detalle que puedas qué es lo que necesitas` (id `b969c43b-e83c-4ae9-9a22-2a1b8d4b3c82`). Si vacío, usar `Pon nombre a lo que necesitas` (id `f2e37010-9f11-4a2b-b30c-0d8aa3aeb96c`). Si ambos vacíos, fallback a primera frase de la descripción o aviso "Cliente attached image/document with description".
  - Incluir nombre del solicitante si está disponible en `¿Quién realiza la solicitud?` (id `9ac2e551-f71b-4f2f-af2f-5720be57801d`): `... (Yura).`

- **Tareas creadas manualmente** (vía skill `soporte-correo-clickup-reinicia` o intervención directa del PO):
  - `Original name`: nombre con que el PO la creó (incluir contexto: "created manually following [evento]")
  - `Cliente request`: extraer del primer hilo de correo o de la descripción de la tarea

- **Tareas in-warranty** (`[ASSUMED IN THE GUARANTEE] X`):
  - `Original name: [ASSUMED IN THE GUARANTEE] X`
  - `Cliente reported Y, addressed under project guarantee.` (uso del verbo "reported", no "request")

- **Tareas de Account management / Gestión mensual recurrente**: **dejar la celda vacía**. No hay petición original puntual del cliente, es trabajo PMO recurrente acordado en contrato. Forzar texto inventado rompe la honestidad del informe.

### 6.bis.E — GLOSSARY del Report

| Row | Contenido | Formato |
|---|---|---|
| 60 | Banner "GLOSSARY" | **`#545454`** con texto `#FFFFFF` bold size 13, **extendido A-L** *(v1.2)* |
| 62 | "Term / Description" | Bold italic |
| 63 | "Categories" sub-header | Bold italic size 11 |
| 64-67 | 4 categorías (Support / Inquiry / Management / In-warranty) | Col A `#D1FAF2`, cols B-L `#F2F2F2` |
| 69 | "Statuses" sub-header | Bold italic size 11 |
| 70-76 | 7 statuses **en orden ciclo de vida v1.2**: Open → Product Backlog → Sprint Backlog → Doing → Validation Client → Closed → Parking | Col A `#D1FAF2`, cols B-L `#F2F2F2` |
| 78 | "Consumption levels" sub-header | Bold italic size 11 |
| 79-82 | 4 niveles 🟢🟡🟠🔴 | Col A `#D1FAF2`, cols B-L `#F2F2F2` |
| 84 | "Notes" sub-header | Bold italic size 11 |
| 85 | Reporting | |
| 86 | Closing message | Texto canónico (ver 6.6) |
| 87 | Contact | Solo Product Owner (ver 6.7) |

⚠️ **Orden de statuses en ciclo de vida v1.2**: representa el viaje natural de una tarjeta de soporte (Open al entrar → Product Backlog tras refinar → Sprint Backlog al planificar → Doing al ejecutar → Validation Client al entregar → Closed al cerrar). **Parking siempre al final** porque es un estatus lateral/excepcional. Este orden ayuda al cliente a entender cómo fluyen las peticiones internamente.

⚠️ **v1.4 — Col B sin wrap_text** (regla §5.A28 generalizada al glosario):
- Col B del glosario (B64:L76 + B79:L82 + B85:L87) → `wrap_text: false` (desborda lateralmente sobre cols vacías a la derecha).
- Antes (v1.3) la col B tenía `wrap_text: true` lo cual **recortaba textos largos** y obligaba a aumentar la altura de fila.
- Aplica también a **row 56** (separación entre TOTAL CONSUMIDO y banner GLOSSARY): bordes blancos explícitos para mantener la zona limpia (§3.4.bis).

### 6.bis.F — Pestañas internas (PO Breakdown / Pivot Table / ClickUp Data)

Patrón común:

| Bloque | Formato |
|---|---|
| Banner row 1 (PO Breakdown, NO en Pivot Table / ClickUp Data) | Igual que Report row 1: `#3812CF` blanco Manrope bold size 14 alineación start, bordes invisibles |
| Note row 3 (PO Breakdown) | Italic |
| Header row N (azul) | `#3812CF` blanco bold alineación center |
| Filas de datos | **Fondo `#F2F2F2` + bordes blancos** |
| Fila Total | **`#D9D0FB` con texto `#3812CF` bold, extendida hasta cubrir TODAS las columnas de la tabla** (no solo las con fórmula) |
| Cols laterales (después de la última col tabla, hasta Z) | **Fondo blanco + bordes blancos** |
| 50 filas tras la última row de datos | **Fondo blanco + bordes blancos** |

⚠️ **ClickUp Data NO lleva fila Total** porque es la fuente cruda. Las demás pestañas internas sí.

### 6.bis.G — Pestaña Historical

Caso especial — pestaña con crecimiento vertical entre informes:

| Bloque | Formato |
|---|---|
| Banner row 1 | Igual que Report: `#3812CF` blanco Manrope bold size 14, bordes invisibles |
| Note row 3 | Italic descriptivo |
| Header row 6 (azul) | `#3812CF` blanco bold alineación center |
| Filas de datos (row 7+) | Fondo `#F2F2F2` + bordes blancos en la fila recién añadida |
| 50 filas extra tras la última row de datos | Fondo blanco + bordes blancos |

⚠️ **No pre-formatear filas futuras vacías** — solo formatear la fila recién añadida en cada generación.

### 6.bis.H — Anchos canónicos

| Pestaña | Cols |
|---|---|
| Report | A=200, B=280, C=100, D=160, E=75, F=95, G=95, H=60, I=60, J=130, K=380, **L=456** *(v1.2 — Original Request)* |
| PO Breakdown Preparation *(v1.2)* | A=350, B=130, C=130, D=100, E=160, F=160, G=130, H=80, I=80, J=400, K=187, L=187, M=187 |
| Pivot Table | A=120, B=350, C=100, D=80, E=120 |
| ClickUp Data | A=120, B=100, C=200, D=80, E=110, F=80, G=110, H=325 |
| Historical | A=180, B=110, C=110, D=120, E=120, F=120, G=120, H=450 |
| **Bonus History** *(nueva v1.2)* | A=160, B=213, C=213, D=480 |

Aplicar SIEMPRE con `ZohoSheet_column_width` (ver 5.A1).

⚠️ **Unidades**: la API acepta valores en **píxeles** aunque la UI muestra puntos. Factor `px = pt × 4/3`. Para introducir 140pt UI, pasar 187 a la API.

### 6.bis.I — Fuente y tamaños

- Familia: **Manrope**
- Banner row 1: size 14 bold
- Headers de bloque (SUMMARY, BREAKDOWN, DETAIL, GLOSSARY): size 13 bold
- Header de tabla (azul): size 11 bold
- Sub-headers italic (Categories, Statuses, Consumption levels, Notes): size 11 bold italic
- Contenido normal: size 10
- Resolution Summary, ClickUp Data: size 9
- Celdas auxiliares (D19-F20): size 8

### 6.bis.J — Bordes

- Por defecto: bordes blancos `#FFFFFF` en todas las pestañas
- Banner row 1: bordes color del fondo (`#3812CF`) para que sean invisibles
- Cols laterales y rows tras la tabla en pestañas internas: bordes blancos
- BREAKDOWN cols C-D limpias: bordes blancos

---

## 7. Estructura canónica de pestañas secundarias

> ⚠️ **MAPA orden visual ↔ subsección** *(NUEVA v1.3)*
>
> Las subsecciones 7.x están numeradas históricamente, NO por orden visual del workbook. El **orden canónico de pestañas en el workbook** (Sección 1) es:
>
> | Posición visual | Pestaña | Subsección donde se documenta |
> |---|---|---|
> | 1ª | Report | Sección 6 (pestaña principal, no en Sección 7) |
> | 2ª | **Historical** | 7.4 |
> | 3ª | PO Breakdown Preparation | 7.1 |
> | 4ª | Pivot Table | 7.2 |
> | 5ª | ClickUp Data | 7.3 |
> | 6ª | Bonus History | 7.6 |
> | 7ª | Leyenda | 7.7 |
>
> La subsección **7.5 (Operational Planning)** NO es una pestaña: es una **tabla DENTRO de la pestaña PO Breakdown Preparation** (3ª visual), rows 24-34.
>
> ⚠️ **Reordenamiento manual**: al crear el workbook desde cero las pestañas aparecen en orden de creación. Tras crearlas todas, **arrastrar Historical a 2ª posición** desde la UI (la API MCP no expone `worksheet.move` — ver 5.A18 y Sección 13.2).

### 7.1 PO Breakdown Preparation *(reescrita en v1.4)*

Tabla de uso interno del PO para decidir qué horas se facturan al cliente. La pestaña aplica un **bonus UPLIFT** sobre las horas raw de productos individuales (cubre overhead no imputado: gestión técnica, contexto, comunicaciones, micro-interrupciones, revisiones) y un **bloque Operational Planning** independiente para Account Management (Gestión mensual + Refinamiento), donde el % es multiplicativo (no UPLIFT). Deja trazabilidad de fechas operativas (entrada y refinamiento) de cada producto.

#### Plano canónico v1.4

```
Row 1:        Banner principal (lavanda, fondo extendido A1:M1)
Row 2:        (vacía — lavado base)
Row 3:        Nota italic descriptiva (Manrope 10, wrap_text:false, row_height:20, ver §5.A28)
Row 4:        Default Bonus %    | A4:B4 verde menta #D1FAF2 + bold | C4 vacía
Row 5:        Bonus % bounds     | A5:B5 verde menta + bold | C5 gris #F2F2F2 + italic (fórmula validación)
Row 6:        Header tabla principal (A:M, azul #3812CF + blanco + bold)
Rows 7..14:   Productos individuales (típicamente 8, máximo 16 en periodos extensos)
Row 15:       TOTAL tabla principal (lavanda #D9D0FB + bold, A15:M15 PEGADO a row 14)
Rows 16-20:   5 filas vacías (§5.A27)
Row 21:       Banner Operational Planning (lavanda, fondo extendido A21:M21)
Row 22:       (vacía)
Row 23:       Nota italic Operational
Row 24:       Default % Management | A24:B24 verde menta + bold | C24 gris + italic (validación 0-100%)
Row 25:       Default % Refinement | A25:B25 verde menta + bold | C25 gris + italic (validación 0-100%)
Row 26:       Header tabla Operational (A:J azul + blanco + bold | K:M bordes blancos)
Rows 27..N:   Filas Management/Refinement
Row N+1:      TOTAL Operational (lavanda + bold, A:M PEGADO a row N)
```

#### Bloque de configuración tabla principal (rows 4-5)

| Celda | Contenido | Formato |
|---|---|---|
| A4 | "Default bonus % this period" | Verde menta + bold |
| B4 | Valor numérico (ej. `0,15` = 15%). Aplicable solo a productos NUEVOS — productos preexistentes preservan su % vía Bonus History | Verde menta + bold |
| A5 | "Bonus % bounds" | Verde menta + italic |
| B5 | Misma celda etiqueta extendida o leyenda | Verde menta + italic |
| C5 | Fórmula validación: `=SI(O($B$4<0;$B$4>0,25);"⚠ Out of range 0% - 25%";"0% – 25% OK")` | Gris #F2F2F2 + italic |

⚠️ **Manual obligatorio post-creación**: aplicar formato porcentaje a B4 (limitación API — `format_ranges` con `date_time:"0,00%"` no funciona; ver 5.A10).

#### Bloque de configuración Operational Planning (rows 24-25)

| Celda | Contenido | Formato |
|---|---|---|
| A24 | "Default % Management a facturar" | Verde menta + bold |
| B24 | `0,8` (80%) — % de horas de Gestión mensual que se facturan al cliente | Verde menta + bold |
| C24 | Fórmula validación: `=SI(O($B$24<0;$B$24>1);"⚠ Out of range 0%-100%";"0% – 100% OK")` | Gris + italic |
| A25 | "Default % Refinement a facturar" | Verde menta + bold |
| B25 | `0,5` (50%) — % de horas de Refinamiento que se facturan | Verde menta + bold |
| C25 | Fórmula validación análoga | Gris + italic |

⚠️ Igualmente aplicar formato porcentaje manualmente a B24 y B25.

#### Cabecera tabla principal (row 6) y columnas

| Col | Letra | Contenido |
|---|---|---|
| 1 | A | Item (nombre tarjeta) |
| 2 | B | Task ID (ClickUp) |
| 3 | C | Category |
| 4 | D | Hours raw (BUSCARV a Pivot Table) — **redondeado a 2 decimales con preservación G** (§5.A23) |
| 5 | E | **Bonus % override** (PO puede sobreescribir manualmente) |
| 6 | F | **Bonus % applied** (fórmula con fallback a Bonus History) |
| 7 | G | **Hours final** (= ENTERO(Hours raw × (1 + Bonus %)×100)/100) — fondo lavanda `#D9D0FB` + font azul `#3812CF` + bold |
| 8 | H | Tiempo MIN |
| 9 | I | Tiempo MAX |
| 10 | J | PO Comments |
| 11 | K | **Fecha entrada** (date_created en ClickUp) |
| 12 | L | **Fecha refinamiento** (primer time_in_status en `product backlog` o `sprint backlog`) |
| 13 | M | **Fecha informe** (BUSCARV a Bonus History — fecha primera aparición en cualquier informe) |

#### Fórmulas canónicas

⚠️ **Bonus es UPLIFT, NO descuento**. El bonus se SUMA a las horas raw para cubrir overhead no imputado. NO se resta.

**Columna F (Bonus % applied)** — con fallback a Bonus History:
```
=SI(ESBLANCO(E_n);
   SI.ERROR(BUSCARV(B_n;'Bonus History'!$A$6:$C$25;3;0);
            MAX(0;MIN(0,25;$B$4)));
   MAX(0;MIN(0,25;E_n)))
```

Prioridad:
1. Si E_n (override) tiene valor → usar ese (clampeado a 0%-25%)
2. Si no, buscar producto en Bonus History → usar % congelado
3. Si tampoco está → caer al default B4 (clampeado a 0%-25%)

**Columna G (Hours final)**: `=ENTERO(D_n*(1+F_n)*100)/100` — multiplica raw × (1 + bonus%), trunca a 2 decimales.

**Columna M (Fecha informe)**: `=SI.ERROR(BUSCARV(B_n;'Bonus History'!$A$6:$B$25;2;0);"")` — fecha primera aparición.

**Fila TOTAL tabla principal (row 15 en v1.4)**:
- D15: `=TEXTO(SUMA(D7:D14);"0,00")` (workaround formato numérico)
- G15: `=SUMA(G7:G14)`

⚠️ **Cambio v1.4 — referencia robusta desde Informe**: la fórmula `Informe!B27` (Account Management en BREAKDOWN BY CATEGORY) ya **no debe** apuntar a una fila absoluta de PO Breakdown. En su lugar:
```
Informe!B27 = =SUMAR.SI('Pivot Table'!$C$2:$C$N;"Account management";'Pivot Table'!$D$2:$D$N)
```
Ver §5.A21 (inserción de filas rompe referencias externas).

#### Notas obligatorias en celda *(REFORZADO v1.4)*

Ver **ANEXO B — Catálogo de notas obligatorias por celda** para texto verbatim de cada nota. Resumen:

- **B4**: explicación UPLIFT, fórmula `G = ENTERO(D × (1+F) × 100)/100`, rangos 0%-25%, ámbito (productos nuevos), interacción con Bonus History.
- **B5**: fórmula de validación y política Reinicia sobre el cap 25%.
- **E6**: cascada de prioridad override → history → default, valores válidos.
- **F6**: fórmula completa de Bonus % applied con los 3 niveles de prioridad.
- **G6**: fórmula con ejemplo numérico explícito.
- **K6**: origen del dato (date_created ClickUp), formato dd/MM/yyyy HH:mm, uso operativo (ordenar por antigüedad).
- **L6**: origen heurístico (status_history), formato, casos en que la celda queda vacía.
- **F7:F14** (cada fila individualmente): `"Frozen from informe vN — primera aparición del producto. Bonus aplicado: X%. Valor heredado vía BUSCARV a Bonus History. Para sobrescribir en este informe, rellena la columna E (Bonus % override)."`
- **B24**: por qué 80% default, fórmula multiplicativa (no UPLIFT), ejemplo numérico.
- **B25**: por qué 50% default, desagregación anual→mensual.
- **A26**: explicación del Item Key (formato según tipo Management/Refinement).
- **B26**: valores permitidos Management/Refinement y mapeo a default B24/B25.
- **C26**: formato Period (rango fechas).
- **E27:E29**: cascada de prioridad override → history → default Operational.
- **F27:F29** (cada fila individualmente): `"Frozen from informe vN — primera aparición de esta fila [Type]. % aplicado: X% (default Y). Valor heredado vía BUSCARV a Bonus History. Para sobrescribir en este informe, rellena la columna E."`

#### Orden de filas — canónico v1.2 (mantiene v1.4)

⚠️ **Por Fecha de entrada DESC (más reciente arriba)**. Distinto del Informe (que va por Start Date DESC). Intencional:
- PO Breakdown: orden "entrada al sistema" — útil para el PO operativamente
- Informe: orden "cronología del trabajo" — útil para el cliente

#### Formato canónico v1.4

| Bloque | Formato |
|---|---|
| Banner row 1 | Azul Reinicia `#3812CF` blanco bold Manrope 14, bordes `#3812CF` solid all_border. **Extender hasta M1** |
| Note row 3 | Italic Manrope 10, wrap_text:false, row_height:20, bordes blancos (§5.A28) |
| Bloque config B4-B5 | Verde menta #D1FAF2 + bold para A:B + gris #F2F2F2 italic para C (§5.A26) |
| Header row 6 | Azul #3812CF + blanco + bold Manrope 11 |
| Items rows 7-14 cols A-J | Fondo #F2F2F2 + bordes blancos + Manrope 10 |
| **Items rows 7-14 col G** | **Fondo lavanda `#D9D0FB`** + font `#3812CF` + bold Manrope 10 (destaque Hours final) |
| Items rows 7-14 cols K-M | Fondo gris `#EBEBEB`, bordes blancos, Manrope, alineación center+middle |
| K-L formato fecha | `dd/MM/yyyy HH:mm` (vía `format_ranges.date_time` — SÍ funciona, ver 5.A11) |
| M formato fecha | `dd/MM/yyyy` |
| Fila TOTAL row 15 | Lavanda `#D9D0FB`, Manrope bold, **extender de A15 a M15** (banda continua, pegada a row 14) |
| Rows 16-20 (5 filas vacías) | Lavado base (blanco + bordes blancos + Manrope 10) |
| Banner row 21 (Operational Planning) | Mismo estilo que banner row 1, extender A21:M21 |
| Note row 23 | Mismo estilo §5.A28 |
| Bloque config rows 24-25 | Mismo patrón §5.A26 |
| Header row 26 | A26:J26 azul + blanco + bold | K26:M26 bordes blancos |
| Filas Operational rows 27..N cols A-J | Fondo #F2F2F2 + bordes blancos |
| **Filas Operational col G** | **Fondo lavanda + font azul + bold** (Billed hours destacadas) |
| Fila TOTAL Operational | Lavanda, extender A:M |

#### Anchos canónicos v1.2 (mantienen v1.4)

| Col | Ancho (px API) |
|---|---|
| A | 350 |
| B | 130 |
| C | 130 |
| D | 100 |
| E | 160 |
| F | 160 |
| G | 130 |
| H | 80 |
| I | 80 |
| J | 400 |
| K | 187 |
| L | 187 |
| M | 187 |

⚠️ **Conversión px↔pt**: la API acepta px aunque la UI muestra pt. Factor `px = pt × 4/3`. Ej: 140pt UI = 187px API. 300pt UI = 400px API.

#### Recopilación de datos para K, L

Para cada tarjeta del DETAIL:

**Columna K (Fecha entrada)**: `date_created` del objeto tarea de ClickUp. Es timestamp ms; convertir a `dd/MM/yyyy HH:mm` aplicando offset Europe/Madrid (+01:00 o +02:00 según DST).

**Columna L (Fecha refinamiento)**: extraer del array `time_in_status` de `clickup_get_task` (campo `current_status` + `status_history`). Buscar el primer evento donde la tarea entra al estatus `product backlog` o `sprint backlog` (lo que ocurra primero). Si la tarea nunca pasó por backlog (ej: tarea de Gestión mensual, o tarea creada manualmente que saltó directo a Doing), dejar la celda **vacía**.

⚠️ **Heurística temporal**: el time_in_status es la mejor aproximación disponible vía API hasta que la skill `soporte-procesamiento-clickup-reinicia` añada un custom field tipo fecha "Fecha refinamiento Claude" (ver sección 12.3).

⚠️ **Memoria global obsoleta**: la skill de procesamiento de soporte NO aplica el tag `primer-refinamiento-individual-realizado` (era una expectativa que no se llegó a implementar). El comentario `"Resolution Summary"` no es fuente fiable porque se escribe tras la resolución, no tras el refinamiento.

### 7.2 Pivot Table — fuente de fórmulas SUMAR.SI

| Col | Contenido |
|---|---|
| A | task_id |
| B | Item |
| C | Category |
| D | Hours total (fórmula `=SUMAR.SI('ClickUp Data'!$B$2:$B$N;$A2;'ClickUp Data'!$F$2:$F$N)`) |
| E | Status |

Row 1 = header. Rows 2..N+1 = items. Última row = TOTAL.

⚠️ **El Report DETAIL lee Hours de aquí** con `=BUSCARV($task_id_en_Report;'Pivot Table'!$A$2:$D$17;4;0)`.

### 7.3 ClickUp Data — time entries crudos

| Col | Contenido |
|---|---|
| A | entry_id |
| B | task_id |
| C | task_name |
| D | user |
| E | start (sin `+`) |
| F | duration_h (coma decimal) |
| G | end (sin `+`) |
| H | description |

Row 1 = header. Rows 2..N+1 = entries. **No tiene row TOTAL**.

⚠️ Columna `task_id` (B) **obligatoria** para fórmulas SUMAR.SI.

### 7.4 Histórico / Historical *(reubicada a 2ª posición en v1.3; renombrada en v1.4)*

⚠️ **v1.4 — Nombre de la pestaña**:
- Cliente ES: **Histórico**
- Cliente EN: **Historical**

⚠️ En v1.3 se movió de 5ª a 2ª posición en el workbook (justo después del Informe). El **orden de aparición en la skill se mantiene aquí** (7.4) por coherencia con la numeración de las secciones; pero al crear el workbook, **Histórico debe quedar como pestaña #2**. Como la API MCP de Zoho Sheet **no expone el método `worksheet.move`**, el reordenamiento se hace **manualmente** desde la UI (drag & drop de la pestaña) tras crear todas las pestañas.

| Col | Contenido |
|---|---|
| A | Period (DD/MM/YYYY - DD/MM/YYYY) |
| B | Contract start |
| C | Contract end |
| D | Hours contracted |
| E | Hours consumed |
| F | Hours remaining (fórmula `=D-E`) |
| G | Consumption % (fórmula `=TEXTO(E/D;"0,00%")`) |
| H | Notes (incluye estado del semáforo: "🟠 Negotiate level — 80,87%") |

Row 1 = banner. Row 3 = nota (Manrope italic, wrap_text:false, row_height:20, §5.A28). Row 6 = header. Rows 7+ = un periodo por fila (crecimiento entre informes).

⚠️ **v1.4 — Patrón canónico Tabla Reinicia obligatorio** (§5.A25):
- Filas de datos: fondo `#F2F2F2` + bordes blancos + Manrope 10 + col A texto negro bold.
- Cifras de horas a **2 decimales** (§5.A23) — no 4.
- `font_name: "Manrope"` explícito en TODOS los format_ranges (§5.A22), pues Histórico es una pestaña creada con `create_worksheet` que tiende a heredar Roboto por defecto.

### 7.5 Operational Planning — Tabla separada para Account Management *(NUEVA v1.3)*

A partir de v1.3, **Account Management** (Gestión mensual del cliente + Refinamiento) **deja de mezclarse con la tabla principal de Bonus UPLIFT** y se gestiona en una tabla separada en PO Breakdown Preparation con su propio mecanismo de % facturable.

#### Diferencia conceptual con el Bonus UPLIFT

| Aspecto | Tabla principal (Bonus UPLIFT) | Tabla Operational Planning |
|---|---|---|
| **Cobertura** | Productos individuales de soporte (Support / Inquiry / In-warranty) | Account Management (Gestión mensual + Refinamiento anual) |
| **Operación del %** | `Hours final = Raw × (1 + bonus%)` (SUMA, uplift al alza) | `Billed hours = Raw × % applied` (MULTIPLICA, fracción facturable) |
| **Default** | `B4` (ej. 0,15 = +15%) | `B27` Management (ej. 0,8 = 80%) / `B28` Refinement (ej. 0,5 = 50%) |
| **Cap** | `MAX(0;MIN(0,25;...))` — cap al 25% | Sin cap (rango 0-100%) |

#### Estructura de la tabla Operational Planning

Ubicación en PO Breakdown Preparation: **rows 24-34**.

| Row | Contenido |
|---|---|
| 24 | Banner "Operational Planning · Billing configuration" — `#3812CF` blanco bold Manrope 12 |
| 25 | Nota italic explicando el sistema |
| 27 | A27 = "Default % Management to bill" / B27 = valor numérico (ej. 0,8) / C27 = validación |
| 28 | A28 = "Default % Refinement to bill" / B28 = valor numérico (ej. 0,5) / C28 = validación |
| 29 | Cabecera 10 cols A:J — `#3812CF` fondo, texto blanco bold Manrope |
| 30..33 | Filas datos (2 Management + 2 Refinement por mes) — fondo `#F2F2F2` con bordes blancos |
| 34 | TOTAL Operational Planning billed — lavanda `#D9D0FB` con texto azul Reinicia bold |

#### Columnas de la tabla Operational Planning

| Col | Letra | Contenido |
|---|---|---|
| 1 | A | ClickUp task / Item Key — clave única (incluye periodo para Refinement) |
| 2 | B | Type — "Management" o "Refinement" |
| 3 | C | Period — periodo cubierto (ej. `01/05/2026 - 11/05/2026`) |
| 4 | D | Raw hours — horas tracked del periodo |
| 5 | E | **% override** — el PO puede sobrescribir el % por fila (vacío = usa default) |
| 6 | F | **% applied (frozen)** — fórmula condicional: override → BUSCARV Bonus History → default |
| 7 | G | Billed hours — fórmula `=ENTERO(D_n*F_n*100)/100` |
| 8 | H | Report version — `v4`, `v5`, etc. |
| 9 | I | Generation date — fecha del informe |
| 10 | J | PO Comments — texto libre |

#### Fórmulas canónicas

**Col F % applied (fila n)**:
```
Management: =SI(ESBLANCO(E_n);SI.ERROR(BUSCARV(A_n;'Bonus History'!$A$6:$E$25;3;0);$B$27);E_n)
Refinement: =SI(ESBLANCO(E_n);SI.ERROR(BUSCARV(A_n;'Bonus History'!$A$6:$E$25;3;0);$B$28);E_n)
```

**Col G Billed hours (fila n)**: `=ENTERO(D_n*F_n*100)/100`

**Row 34 TOTAL G**: `=SUMA(G30:G33)`

Este TOTAL alimenta **B27 del Report** (BREAKDOWN BY CATEGORY · Account Management):
```
Report!B27 = ='PO Breakdown Preparation'!G34
```

#### Refinement separado por meses — CRÍTICO

La tarjeta ClickUp `Refinamiento [Año] [Cliente]` es **ANUAL**, no mensual. Pero en la tabla Operational Planning **se desagrega por mes** en filas paralelas a las de Management (Mayo, Abril, etc.). Razones:

1. **Coherencia visual con Management** que sí es mensual
2. **Trazabilidad temporal**: el cliente ve cómo se reparte el Refinamiento entre meses
3. **Clave única**: cada fila Refinement tiene su propio Identifier en Bonus History (`Refinamiento 2026 [Carritech] - Mayo 2026`)

**Cálculo de horas por mes** (col D): suma de time entries cuyo `start` cae dentro del mes:
```python
horas_refinement_mes = sum(
    entry.duration_horas for entry in clickup_time_entries
    if entry.task_id == REFINAMIENTO_TASK_ID
    and entry.start.month == MES and entry.start.year == AÑO
)
```

Si no hay time entries en el mes → fila con D=0, **informativa** (mantiene continuidad temporal pero no afecta al TOTAL).

#### Identifier en col A para Refinement

A diferencia de Management (donde col A = nombre de la tarjeta ClickUp tal cual: "Gestión Mayo 2026 [CARRITECH]"), Refinement requiere **clave compuesta** porque la tarjeta es anual y aparece varias veces:

- Row Mayo: `Refinamiento 2026 [Carritech] - Mayo 2026`
- Row Abril: `Refinamiento 2026 [Carritech] - Abril 2026`

Esta clave compuesta es la que se usa para el BUSCARV a Bonus History (donde se registra el % congelado de cada fila).

#### Congelación del % entre informes

Cuando una fila Operational Planning aparece en el informe **por primera vez**, se registra en `Bonus History` con su `Frozen %`. En informes posteriores, la fórmula de Col F siempre consultará primero Bonus History (vía BUSCARV) y solo caerá al default global si la clave no existe.

**Resultado**: cambiar B27 o B28 (defaults globales) NO afecta retroactivamente a filas históricas. Cada fila preserva su % original.

---

### 7.6 Bonus History UNIFICADO *(reescrita v1.3, original v1.2)*

Pestaña de uso interno que actúa como **fuente de verdad UNIFICADA del % congelado por ítem** — para Bonus UPLIFT, Account Management y Refinement.

#### Propósito (v1.3)

El sistema garantiza que:
1. Una vez que un **ítem** (producto de bonus, fila Management o fila Refinement) aparece en un informe con un % determinado, ese % **NUNCA cambia** en futuros informes.
2. Cambiar defaults globales (`B4`, `B27`, `B28`) en PO Breakdown Preparation **no afecta retroactivamente** a ítems preexistentes.
3. El override por fila (col E en cada tabla) sigue funcionando como mecanismo manual del PO.

#### Estructura

| Row | Contenido |
|---|---|
| 1 | Banner "Bonus History · Internal use only — DO NOT EDIT MANUALLY" — fondo `#3812CF` extendido A1:E1, **SIN combinar celdas** (texto solo en A1, B1:E1 vacías) |
| 3 | Note italic A1:E3, **SIN combinar celdas** |
| 5 | Header lavanda `#D9D0FB` A5:E5 con texto azul Reinicia bold |
| 6..N | Datos — Manrope center, fondo `#F2F2F2` con bordes blancos |

#### Columnas (v1.3 — 5 columnas, antes 4)

| Col | Letra | Contenido | Notas |
|---|---|---|---|
| 1 | A | **Identifier** (clave única) | Antes "Task ID". Ahora puede contener: task_id (Bonus), nombre tarjeta (Management), nombre compuesto (Refinement) |
| 2 | B | First Report Date (formato `dd/MM/yyyy`) | |
| 3 | C | **Frozen %** | Antes "Frozen Bonus %". Renombrado genérico |
| 4 | D | Source Report | Nombre del informe sin timestamps |
| 5 | E | **Type** *(NUEVA v1.3)* | `Bonus` \| `Management` \| `Refinement` |

#### Anchos canónicos (px aplicados, recordar factor 4/3 al enviar a API)

| Col | Ancho deseado px | Valor a pasar a API (×4/3) |
|---|---|---|
| A | 140 | 187 |
| B | 140 | 187 |
| C | 140 | 187 |
| D | 360 | 480 |
| E | Default (≈80) | — |

#### Manual obligatorio post-creación

- Aplicar formato porcentaje a `C6:CN` (limitación API).

#### Algoritmo de regeneración entre informes — CRÍTICO

Cuando la skill genera o regenera un informe del cliente:

1. **Listar informes anteriores** del cliente en Workdrive ordenados por `created_time` ascendente.

2. **Para cada ítem del nuevo informe** (tanto productos individuales como filas de Operational Planning):
   - Comprobar si su `Identifier` ya tiene entrada en la pestaña `Bonus History` local: si sí, no tocar.
   - Si NO está en la local: buscar en informes anteriores la primera aparición de ese `Identifier` en su Bonus History. Copiar fielmente esa entrada (todas las 5 columnas, incluyendo Type) a la Bonus History local.
   - Si **no existe en ningún informe anterior** → es ítem verdaderamente nuevo. Crear entrada con:
     - `Identifier` = clave única (task_id para Bonus, nombre tarjeta para Management, nombre+mes para Refinement)
     - `First Report Date` = hoy
     - `Frozen %` = default según tipo: `B4` para Bonus, `B27` para Management, `B28` para Refinement
     - `Source Report` = nombre del informe actual sin timestamps
     - `Type` = `Bonus` | `Management` | `Refinement`

3. **Resultado garantizado**: la pestaña `Bonus History` del informe nuevo contiene exactamente las mismas entradas heredadas que la del informe anterior, más las entradas nuevas.

⚠️ **No hay colisión entre tipos**: los task_ids (Bonus) son alfanuméricos `869xxxxxx` y los nombres compuestos (Management/Refinement) son descriptivos. La columna A es clave única natural sin necesidad de filtrar por Type en el BUSCARV.

⚠️ **Renombre v1.2 → v1.3**: la columna A "Task ID" se renombra a "Identifier" (genérica). La columna C "Frozen Bonus %" se renombra a "Frozen %". El esquema v1.2 (4 cols sin Type) debe migrarse añadiendo col E con `Bonus` para todas las filas existentes.

---

### 7.7 Pestaña Leyenda *(NUEVA v1.3)*

Pestaña de **uso interno** que documenta cada elemento del informe para que cualquier PO de Reinicia pueda interpretarlo sin contexto adicional.

#### Visibilidad

- **Interna**: se oculta antes de enviar al cliente (Sección 13).
- **Idioma**: castellano (uso interno del equipo Reinicia).

#### Estructura

3 columnas: **Concepto** (col A, 240px) / **Ubicación** (col B, 200px) / **Explicación** (col C, 600px).

| Row | Contenido |
|---|---|
| 1 | Banner azul "Leyenda · Uso interno Reinicia" — fondo `#3812CF` extendido A1:C1 SIN merge |
| 3 | Nota italic explicativa A1:C3 SIN merge |
| 5 | Header sección 1 "SECCIÓN 1 · Pestaña Report (cara cliente)" — fondo `#3812CF` extendido A5:C5 SIN merge |
| 6 | Cabecera tabla — lavanda `#D9D0FB` con texto azul |
| 7-23 | 17 conceptos sección 1: SUMMARY (6), semáforo (4 niveles), BREAKDOWN (4 categorías), DETAIL (3 cols) |
| 25 | Header sección 2 "SECCIÓN 2 · Pestaña PO Breakdown Preparation (interna)" |
| 26 | Cabecera tabla |
| 27-40 | 14 conceptos sección 2: tabla principal (6) + tabla Operational Planning (8) |
| 42 | Header sección 3 "SECCIÓN 3 · Pestañas auxiliares" |
| 43 | Cabecera tabla (Pestaña / Visibilidad / Propósito) |
| 44-47 | 4 pestañas auxiliares |
| 49 | Header sección 4 "SECCIÓN 4 · Notas operativas" |
| 50 | Cabecera tabla (Ámbito / Detalle / Explicación) |
| 51-55 | 5 ámbitos: visibilidad cliente, locale, decimales, fechas, marca |

#### Reglas de contenido

- **Incluir ejemplos numéricos siempre** (recomendación validada con Carritech v4). Ej.: `Hours final UPLIFT: 0,65h × (1 + 0,15) = 0,74h`.
- **Word wrap activado** en col C (Explicación).

#### Reglas de formato canónico v1.4 *(REFORZADO)*

- **Col A**: texto **NEGRO bold** sobre fondo `#F2F2F2` (NO azul Reinicia). Convención específica de la Leyenda — distinta del Informe/Histórico. Razón: la Leyenda tiene mucha densidad de texto y el azul en concepto+azul en sección de cabecera generaba ruido visual.
- **Col B y C**: texto negro normal sobre fondo `#F2F2F2`, bordes blancos.
- **Banners de sección**: fondo `#3812CF` + texto blanco bold Manrope 14, extendidos A:C SIN merge.
- **Headers de tabla**: fondo `#3812CF` + blanco + bold Manrope 11.
- **`font_name: "Manrope"` obligatorio** en TODO format_ranges de Leyenda (§5.A22), especialmente porque algunas secciones con texto largo tienden a heredar Roboto.
- **Row 3 nota italic**: aplicar patrón §5.A28 (wrap_text:false, row_height:20, bordes blancos).
- **Las 4 secciones (Informe / PO Breakdown / Pestañas auxiliares / Notas operativas)**: cada una con su propio banner + header + tabla. Entre secciones, **5 filas vacías** (§5.A27) si hay espacio; mínimo 2 si la pestaña es densa.
- **Nota operativa adicional v1.4**: si el cliente tenía sistema de informes preexistente (caso §3.4.ter opción B), añadir fila explicativa en sección 4 "Notas operativas" sobre la coexistencia.

---

---

## 8. Constantes de marca Reinicia y paleta canónica

Ver sección 6.bis.A (paleta completa unificada).

### 8.1 Fuentes
- Familia: **Manrope** (Regular y Bold)
- Tamaños: 14 (banner row 1), 13 (headers bloque), 12 (TOTAL CONSUMED), 11 (header tabla / sub-headers italic), 10 (contenido), 9 (Resolution Summary, ClickUp Data), 8 (celdas auxiliares)

### 8.2 Logo Reinicia
Fuente: archivo .docx en Workdrive (resource ID `okcqm65a2ea3684c2473583559fb91f0c3a59`).
Procedimiento de extracción:
1. Descargar el .docx
2. Descomprimirlo como ZIP
3. Extraer `word/media/image3.png` (741×138px)
4. Insertar en el sheet en posición canónica

⚠️ **Síntesis de logo prohibida**. Si no se puede extraer, dejar hueco y avisar al PO.

### 8.3 Bordes blancos por defecto
- `border_color: #FFFFFF`
- `border_style: solid`
- `border_type: all_border`
- Aplicar a rango `A1:Z100` en todas las pestañas
- **Excepciones**: banner row 1 (bordes color del fondo), zonas limpias específicas (BREAKDOWN cols C-D)

---

## 9. Recursos clave y herramientas MCP

### 9.1 Tools de ClickUp
| Tool | Uso |
|---|---|
| `clickup_search` | Buscar listas Soporte/Gestión por nombre |
| `clickup_filter_tasks` | Listar tarjetas del periodo |
| `clickup_get_task` | Detalle de tarjeta |
| `clickup_get_task_comments` | Comentarios para Resolution Summary |
| `clickup_get_task_time_entries` | Time entries por tarjeta |
| `clickup_get_time_entries` | Time entries por usuario en rango fechas (más eficiente que tarjeta a tarjeta) |
| `clickup_create_task_comment` | Comentarios automáticos y resumen al PO |
| `clickup_create_task` | Crear subtarea de generación si no existe |
| `clickup_update_task` | Marcar subtarea como Closed |

### 9.2 Tools de Zoho Sheet
| Tool | Uso |
|---|---|
| `ZohoSheet_create_workbook` | Crear el workbook desde cero |
| `ZohoSheet_create_worksheet` | Crear pestañas adicionales |
| `ZohoSheet_rename_worksheet` | Renombrar `Hoja1` → `Report` |
| `ZohoSheet_list_all_worksheets` | Verificar nombres y orden |
| `ZohoSheet_set_content_to_cell` | Escribir UNA celda (recomendado para fórmulas críticas) |
| `ZohoSheet_set_content_to_multiple_cells` | Escribir varias celdas individuales (límite ~50 por lote) |
| `ZohoSheet_set_content_to_range` (csvdata.set) | Escribir filas consecutivas (límite ~10 filas / 5KB) |
| `ZohoSheet_get_content_of_worksheet` | Verificación post-escritura |
| `ZohoSheet_get_content_of_range` | Lectura específica |
| `ZohoSheet_format_ranges` | Aplicar formato (color, fuente, alineación, bordes). **NO para anchos** |
| **`ZohoSheet_column_width`** | **EXCLUSIVO para anchos de columna** (ver 5.A1) |
| `ZohoSheet_clear_range` | Limpiar contenido + formato |
| `ZohoSheet_clear_contents_of_range` | Limpiar solo contenido |
| `ZohoSheet_set_note_to_cell` | Notas en celda (puede fallar con "No approval received") |
| `ZohoSheet_create_named_range` | Crear celdas nombradas (rango `B6:B6`, no `B6`) |
| `ZohoSheet_update_named_range` | Reapuntar named range existente |
| `ZohoSheet_delete_named_range` | Eliminar named range |

### 9.3 Tools de Workdrive
| Tool | Uso |
|---|---|
| `ZohoWorkdrive_getFileOrFolderDetails` | Validación post-creación (status, name, display_url_name) |
| `ZohoWorkdrive_getFolderFiles` | Navegación jerárquica |

### 9.4 IDs de referencia (constantes Reinicia)
- Néstor user_id ClickUp: `766716`
- Workspace ClickUp Reinicia: `762713`
- Workdrive Team ID: `2km7j4dc468f82ead4a8489e55b64bfd3ecfe`
- Logo Reinicia source docx: `okcqm65a2ea3684c2473583559fb91f0c3a59`

---

## 10. Limitaciones técnicas conocidas

### 10.1 column_width en format_ranges
⚠️ **No funciona** silenciosamente. Usar SIEMPRE `ZohoSheet_column_width`. Ver 5.A1.

### 10.2 BUSCARV con FALSO devuelve #REF!
Usar `0` como 4º argumento. Ver 5.A4.

### 10.3 Columna completa en BUSCARV expande a 262144 filas
Acotar rangos siempre. Ver 5.A5.

### 10.4 Cell merges huérfanas al duplicar workbooks
La skill **no usa merges** salvo banner row 1 intencional. En Modo B, si el PO reporta bloques de color tapando contenido, pedirle deshacer el merge desde la UI.

### 10.5 No hay tool de unmerge vía MCP
Manual desde la UI.

### 10.6 No hay tool de renombrado de Zoho Sheet
`ZohoWriter_Update_Document_Meta` solo Writer, no Sheet. Si nombre incorrecto al crear, descartar y recrear.

### 10.7 Notas en celda pueden requerir aprobación
`ZohoSheet_set_note_to_cell` puede devolver "No approval received" sin razón evidente. Avisar al PO.

### 10.8 ~~Time entries solo del usuario autenticado~~ — OBSOLETO (rectificado v1.5)
Limitación reportada en v1.0/v1.1 era incorrecta. `clickup_get_time_entries` SÍ devuelve entries de cualquier usuario del workspace pasando `assignee_id` + `start_date` + `end_date` + `workspace_id=762713`. Ver §10.15 para el patrón canónico de recopilación "por persona".

### 10.9 Carácter `+` perdido en CSV
No usar en fechas con offset horario.

### 10.10 NFC/NFD silencioso
SUMAR.SI compara bytes. Normalizar a NFC.

### 10.11 Locale fórmulas
Asumido locale ES. Si workbook EN, fórmulas dan `#NAME?`.

### 10.12 Payload CSV >5KB → HTTP 400
Partir en lotes de ~10 filas.

### 10.13 Formato porcentaje vía format_ranges
No funciona con `date_time`. Usar `=TEXTO(...; "0,00%")`. Ver 5.A10.

### 10.14 Tipo numérico heredado de fecha
Restas de fechas devuelven número con formato fecha heredado. Envolver con `ENTERO()`. Ver 5.A6.

### 10.15 Bug `clickup_get_task_time_entries` devuelve vacío *(NUEVA v1.5)*

⚠️ **Bug observado en lista Soporte Avaderm y Gestión Avaderm.** El endpoint `clickup_get_task_time_entries` (entries de una tarjeta concreta) devuelve `200 OK` con array vacío en tarjetas que SÍ tienen tiempo imputado real. Verificado en:
- `869c23tnw` (Refinamiento - 2026 [AVADERM])
- `869d2rmd6` (Gestión Mayo 2026 [AVADERM])

No es error de permisos ni de filtros: responde sin error pero el array `data` viene vacío. Comportamiento inconsistente entre ejecuciones.

**WORKAROUND CANÓNICO — "Recopilación por persona":**
En lugar de iterar `por tarjeta → get_task_time_entries`, invertir el bucle:

1. Para cada miembro del equipo Reinicia (resolver IDs con `clickup_find_member_by_name` o usar memoria):
   ```
   clickup_get_time_entries(
     assignee_id=<member_id>,
     start_date=<periodo_inicio_ms>,
     end_date=<periodo_fin_ms>,
     workspace_id=762713
   )
   ```
2. Filtrar los entries devueltos cuya `task.id` pertenezca a las tarjetas del cliente del periodo (cruce con la lista de tarjetas Q-E del Soporte + Gestión).
3. Acumular por persona y por tarjeta.

Este patrón "por persona" es el **flujo correcto y canónico**, no un workaround temporal. Aplicar siempre en Modo A §3.2.5 y Modo B §4.3, independientemente de si `get_task_time_entries` funciona o no en la tarjeta. Garantiza consistencia y captura entries de todo el equipo (no solo del usuario autenticado, ver §10.8 rectificada).

IDs canónicos del equipo Reinicia (referencia rápida):
- Néstor `766716` · Pablo `87715920` · Paolo `2447443` · Alejandro Pont `93805276` · Johanna `56699411` · José Barreiro `87739095` · Fabián `93744950` · Óscar Díez `93631901` · Mario `81733832` · Álvaro `2441281`.

### 10.16 Bug `invalid_type` en `task.id` de algún entry *(NUEVA v1.5)*

⚠️ **Bug intermitente del endpoint `clickup_get_time_entries`.** El response puede contener entries con `task.id = "invalid_type"` (string literal, no error). Visto en sesión Avaderm v1 con el entry de José Barreiro (assignee_id `87739095`) sobre `869c23tnw`. No bloquea el response global, solo afecta a entries puntuales.

**WORKAROUND:**
- Si el entry afectado **es relevante** para el informe (cubre una imputación importante) y existe una versión anterior del informe (v1, v_anterior) donde el entry sí está bien capturado: **heredar el valor** de la versión anterior y documentarlo en notas internas (ej. "Heredado v1 — bug invalid_type en API").
- Si el entry **no se puede verificar** contra una versión anterior: registrarlo en el **Inventario automático de anomalías al cierre** (§3.10.bis chequeo 1, time entries sin task asociada o anómalas) y reportarlo en el comentario al PO como anomalía sin impacto en datos.
- Si afecta a >10% del total de horas del periodo: detener generación y avisar al PO antes de continuar.

### 10.17 Acumulación de error por redondeo en subtotales *(NUEVA v1.5)*

⚠️ **Bug metodológico, no técnico.** Si la skill calcula subtotales (por persona, por tarjeta, por categoría) redondeando cada uno a 2 decimales antes de sumarlos, el error acumulado puede llegar a `±0,03h` por bloque y romper el cuadre con los time entries reales de ClickUp.

**Ejemplo real (Avaderm v2 17/05/2026):**
- Cálculo inicial con subtotales redondeados: 11,11h.
- Cálculo correcto con minutos exactos: 10,73h (10:44 en minutos).
- Pivot Table sobre celdas escritas con 2 decimales: 10,76h.
- Discrepancia: 0,35h respecto al cálculo inicial, 0,03h respecto al exacto.

**PATRÓN CANÓNICO:**
- **Cálculo interno**: sumar en minutos enteros (no horas con decimales). Solo redondear al final, cuando se escribe en celda destino.
- **Celdas escritas**: aceptar redondeo a 2 decimales porque es lo que ve el cliente, pero garantizar coherencia con la Pivot Table (que aplica `SUMAR.SI` sobre las celdas escritas, no sobre los minutos exactos).
- **Fuente de verdad**: lo que la Pivot Table calcula a partir de ClickUp Data es el dato oficial para Informe + PO Breakdown. Documentar discrepancia esperable `±0,03h` en notas internas si la hay.
- **No usar `clickup_get_time_entries` con la suma en horas** que devuelve la API — recalcular siempre desde la duración en milisegundos de cada entry.

Algoritmo correcto en pseudo-Python:
```python
total_minutos = sum(entry["duration"] // 60000 for entry in entries)
horas_decimales = round(total_minutos / 60, 2)  # solo redondear AL FINAL
```

---

## 11. Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v1.0** | 2026-05-11 | Néstor + Claude | Versión inicial. Generación y actualización de informes. 5 pestañas con formato canónico Reinicia. Fórmulas en español. Semáforo de consumo y comentarios automáticos al PO + Néstor. Estimated exhaustion date con 3 celdas auxiliares. Carry-over from previous como celda nombrada. Manual de estilo Resolution Summary como stub. Modo B en versión mínima. Validado con piloto Carritech v2. |
| **v1.1** | 2026-05-11 | Néstor + Claude | Refinamiento tras primera ejecución real (Carritech v3). Incorpora: (A) bugs técnicos descubiertos (column_width, decimales coma, BUSCARV con 0, ENTERO en restas de fechas, rangos acotados, CSV en lotes, update_named_range, namedrange con notación rango, TEXTO para porcentajes, FECHA en lugar de strings); (B) identidad visual canónica completa (paleta unificada, banner sin bordes, cabecera/SUMMARY/BREAKDOWN en A-B, DETAIL sin zebra, GLOSSARY banner gris extendido, pestañas internas con cols laterales y rows extra limpias); (C) convención de naming por idioma del cliente (ES y EN); (D) políticas operativas validadas (Q-E solo Soporte+Gestión, Q-F GUARANTEE a 0h, Q-G PO cuenta, Q-H datos crudos); (F) crecimiento vertical Historical paramétrico; (G) manual de estilo Resolution Summary ampliado con ejemplos del v3 Carritech. Modo B reforzado con sección de cambios estilísticos pestaña a pestaña. Banner del semáforo extendido a C18:F18. Contacto solo PO. Creación de subtarea si no existe en cierre formal. |
| **v1.2** | 2026-05-16 | Néstor + Claude | Evolución tras segunda ejecución real (Carritech v4). Cambios principales: (A) **Sistema Bonus por producto** — nueva pestaña 6 `Bonus History` que congela el % de bonus aplicado tras la primera aparición de cada producto en cualquier informe del cliente; fórmula F en PO Breakdown con BUSCARV fallback a Bonus History; algoritmo de regeneración entre informes que consulta informes anteriores en Workdrive; bonus es UPLIFT (`1+bonus%`) no descuento. (B) **PO Breakdown Preparation con fechas** — cols K (Fecha entrada / date_created ClickUp), L (Fecha refinamiento / primer time_in_status en backlog), M (Fecha informe / BUSCARV a Bonus History). Bloque config B4-B5 con default bonus y validación de rango. Fila TOTAL extendida A-M lavanda. Orden canónico Fecha entrada DESC. (C) **Report con col L Original Request** — 12 cols A-L con el "Original name" de ClickUp + "Cliente request" del custom field del form, vacío para Account Management recurrente, "Cliente reported X, addressed under project guarantee" para in-warranty. Banner row 1 extendido A-L. Subtotales y TOTAL CONSUMED extendidos A-L. (D) **Orden Report DETAIL por Start Date DESC** en ambos bloques (billable e in-warranty). Intencional distinto del PO Breakdown. (E) **Glosario statuses reordenado al ciclo de vida**: Open → Product Backlog → Sprint Backlog → Doing → Validation Client → Closed → Parking. (F) **Bug fixes técnicos**: 5.A11 (formato fecha SÍ funciona vía API, excepción al límite de formato numérico), 5.A12 (validación post-reordenamiento obligatoria), 5.A13 (conversión px↔pt en column_width factor 4/3). (G) **Paleta clarificada**: dos grises distintos por pestaña (`#F2F2F2` en Report, `#EBEBEB` en PO Breakdown cols K-L-M). |
| **v1.3** | 2026-05-16/17 | Néstor + Claude | Evolución tras sesión iterativa sobre Carritech v4. Cambios principales: **(A) Sistema Operational Planning (Sección 7.5)** — tabla separada en PO Breakdown rows 24-34 para Account Management (Gestión mensual + Refinamiento) con cols A:J incluyendo nueva col E "% override" y col F "% applied (frozen)". Defaults globales B27 (Management) y B28 (Refinement). Diferencia clave con Bonus UPLIFT: aquí el % MULTIPLICA (`Billed = Raw × %`), no SUMA. Refinement separado por meses aunque la tarjeta ClickUp sea anual (clave compuesta `Nombre - Mes Año`). **(B) Bonus History UNIFICADO (Sección 7.6)** — única fuente de verdad para Bonus, Management y Refinement. Esquema migra a 5 cols: `Identifier` (antes Task ID), First Report Date, `Frozen %` (antes Frozen Bonus %), Source Report, `Type` (NUEVA: Bonus \| Management \| Refinement). Fórmulas de PO Breakdown consultan por col A sin filtrar por Type (clave única natural). **(C) Pestaña Leyenda (Sección 7.7)** — nuevo deliverable interno con 4 secciones (Report, PO Breakdown, Pestañas auxiliares, Notas operativas), 3 cols (Concepto / Ubicación / Explicación), ejemplos numéricos obligatorios, ~40 filas de contenido. Castellano. Se oculta antes de enviar al cliente. **(D) REGLA DE ORO "NUNCA combinar celdas"** (Sección 5.7 endurecida) — aplica a TODO el workbook. Patrón canónico: fill_color extendido + texto solo en celda A + celdas a la derecha vacías para desbordamiento visual. **(E) AUX cells del Report (5.A14)** — movidas de D19:F20 a G19:I20 con `font_color: #FFFFFF` para ocultarlas. B20 referencia ahora `$I$20`. Combinar con Protect Sheet manual. **(F) Historical reubicada a 2ª posición** (tras Report) — reordenamiento manual desde UI porque API MCP no expone `worksheet.move` (5.A18). **(G) A27 Report con etiqueta "Account Management"** (no "Operational Planning") por coherencia con el DETAIL. **(H) 4 nuevas reglas técnicas**: 5.A14 (AUX cells ocultas), 5.A15 (notas no eliminables vía API), 5.A16 (`content: ""` asimétrico single vs batch), 5.A17 (unmerge implícito re-formateando sin merge_cell), 5.A18 (reordenar pestañas requiere acción manual). **(I) Sección 13 NUEVA** — pasos previos al envío al cliente (ocultar pestañas, reordenar, Protect Sheet, verificación numérica final). |
| **v1.4** | 2026-05-17 | Néstor + Claude | Refinamiento visual canónico completo tras sesión cruzada con Synuptic v2 y Gonher Mayo. Validación dual: workbook `egjr6445b8cb54cb14b0e94fa1eaa97d5c24e` (Synuptic) + workbook Gonher Mayo 2026. Cambios principales: **(A) Lavado base PASO 0 (§3.4.bis)** — REGLA DEL LIENZO LIMPIO: `fill_color: #FFFFFF` + `border: {all_border, #FFFFFF, solid}` SIEMPRE juntos, hasta col Z fila 100, en TODAS las pestañas, antes de poblar. Lista exhaustiva de rangos por pestaña. **(B) Localización pestañas cara cliente (§6.0)** — Informe/Histórico en ES, Report/Historical en EN. Internas mantienen nombre técnico. Renombrado obligatorio post-creación de Hoja1. **(C) Patrón canónico "Tabla Reinicia" (§5.A25)** — banner + nota + header + datos + TOTAL pegado (sin espacio), refinamiento col A texto NEGRO bold (no azul Reinicia). Col G "Hours final" en lavanda `#D9D0FB` + bold para destacar valor facturable. **(D) Patrón "bloque de configuración" (§5.A26)** — verde menta `#D1FAF2` + bold para etiqueta+valor, gris `#F2F2F2` + italic para celda de validación. Notas obligatorias. **(E) Espaciado canónico 5 filas vacías (§5.A27)** entre bloques distintos (validado vs alternativa 3-filas-Gonher, decisión canónica: 5). **(F) Redondeo a 2 decimales con preservación de fórmulas (§5.A23)** — algoritmo half-up con fallback ceiling cuando fórmulas dependientes lo requieren. Caso validado: Synuptic D13 = 3,79 (ceiling) preserva G13 = 4,35. **(G) Anti-Roboto (§5.A22)** — `font_name: "Manrope"` obligatorio en TODO `format_ranges`. **(H) Notas obligatorias en headers y configuración (§5.A24 + ANEXO B)** — catálogo verbatim de notas por celda en B4, B5, E6, F6, G6, K6, L6, A26, B26, C26, B24, B25, F7:F14, F27:F29, C18, G19, etc. **(I) Cambio arquitectónico Informe!B27 (§5.A21)** — usar `SUMAR.SI` sobre Pivot Table en lugar de referencia directa `'PO Breakdown'!G34` para robustez frente a reestructuraciones futuras. **(J) Cliente con sistema preexistente (§3.4.ter)** — 3 opciones A/B/C (Migrar/Coexistir/Manual). Validado en Gonher Mayo (3 informes quincenales previos → Coexistir). **(K) Inventario automático de anomalías al cierre (§3.10.bis)** — 6 chequeos: time entries sin task, no-Reinicia, cross-cliente, tarjetas duplicadas, soporte sin MIN/MAX, dry-run vs oficial. Incluir en comentario al PO. **(L) 3 reglas técnicas nuevas (5.A19, 5.A20, 5.A21)** — Manrope fallback Roboto (catálogo fuentes usuario), re-formato pisa formato previo (orden crítico construcción pestaña), inserción de filas rompe referencias externas (justifica SUMAR.SI). **(M) Patrón row 3 nota italic (§5.A28)** — `wrap_text: false` + `row_height: 20` fijo + bordes blancos. **(N) Cabeceras col A del Informe (§5.A29)** — `wrap_text: true` + `row_height: 30` para etiquetas largas. **(O) Col B glosario sin wrap (§6.bis.E)** — `wrap_text: false` (desborda lateralmente, más legible). **(P) Leyenda col A negra bold (§7.7)** — sobre `#F2F2F2`, distinto del Informe (verde menta). |
| **v1.5** | 2026-05-17 | Néstor + Claude | Aprendizajes de bugs y patrones canónicos tras ejecución Avaderm v2 (01/05/2026 a 17/05/2026, workbook `egjr6793a20a2f473419bbbb04bf6d28fda97`). Sin cambios estructurales en las 7 pestañas. Cambios en §10 Limitaciones técnicas conocidas: **(A) §10.8 RECTIFICADA** — la entrada anterior decía que `clickup_get_time_entries` solo devuelve entries del usuario autenticado. Es FALSO. La tool SÍ devuelve entries de cualquier usuario del workspace pasando `assignee_id` + `start_date` + `end_date` + `workspace_id=762713`. Esta corrección elimina la limitación reportada en v1.0/v1.1. **(B) §10.15 NUEVA** — Bug `clickup_get_task_time_entries` devuelve `200 OK` con array vacío en tarjetas con tiempo imputado real (verificado en `869c23tnw` Refinamiento y `869d2rmd6` Gestión Mayo de Avaderm). Patrón canónico de recopilación: invertir el bucle a "por persona" en lugar de "por tarjeta", usando `clickup_get_time_entries(assignee_id, start_date, end_date)` para cada miembro del equipo Reinicia y filtrando por `task.id` perteneciente a las tarjetas del cliente. Incluye IDs canónicos del equipo Reinicia para referencia rápida. Este patrón aplica siempre en §3.2.5 y §4.3, no es un workaround temporal. **(C) §10.16 NUEVA** — Bug intermitente `task.id = "invalid_type"` en algún entry concreto del response de `clickup_get_time_entries` (visto con José Barreiro `87739095` en `869c23tnw`). Workaround documentado: heredar del informe v_anterior si existe, o registrar en §3.10.bis chequeo 1 como anomalía si no. Umbral de bloqueo: >10% del total de horas afectado. **(D) §10.17 NUEVA** — Bug metodológico de acumulación de error por redondeo en subtotales. Si la skill calcula subtotales redondeando cada uno a 2 decimales antes de sumarlos, acumula error `±0,03h` por bloque. Patrón canónico obligatorio: sumar siempre en minutos enteros internamente, redondear SOLO al escribir en celda destino. La Pivot Table es la fuente de verdad para Informe + PO Breakdown. Ejemplo real Avaderm v2: cálculo erróneo 11,11h vs. correcto 10,73h (Pivot 10,76h por redondeo en celdas escritas). Algoritmo en pseudo-Python incluido. |

---

## 12. Pendientes de evolución

### 12.1 Cumplido en v1.2 (referencia)

- ✅ **Sistema Bonus por producto** con congelación (pestaña Bonus History)
- ✅ **Algoritmo de regeneración** que preserva % bonus entre informes consecutivos
- ✅ **Columnas K-L-M de fechas** en PO Breakdown Preparation
- ✅ **Columna L Original Request** en Report
- ✅ **Orden canónico** PO Breakdown (Fecha entrada DESC) y Report (Start Date DESC)
- ✅ **Glosario statuses** ordenado al ciclo de vida
- ✅ **Bug fixes técnicos**: formato fecha API, validación post-reordenamiento, conversión px↔pt

### 12.1.bis Cumplido en v1.3 (referencia)

- ✅ **Sistema Operational Planning** (tabla separada Account Management con % override y congelación)
- ✅ **Bonus History UNIFICADO** (5 cols con Type, Identifier, Frozen %)
- ✅ **Pestaña Leyenda** como deliverable interno
- ✅ **Regla de oro "NUNCA combinar celdas"** (5.7 endurecida)
- ✅ **AUX cells ocultas** con `font_color: #FFFFFF` (5.A14)
- ✅ **Refinement separado por meses** con clave compuesta
- ✅ **A27 Report = "Account Management"** (coherencia con DETAIL)
- ✅ **Reglas técnicas**: 5.A14 a 5.A18 (5 nuevas)
- ✅ **Sección 13 NUEVA**: pasos previos al envío al cliente

### 12.1.ter Cumplido en v1.4 (referencia)

- ✅ **Lavado base PASO 0** (§3.4.bis) — REGLA DEL LIENZO LIMPIO con fill + border simultáneos
- ✅ **Localización pestañas cara cliente** (§6.0) — Informe/Histórico ES, Report/Historical EN
- ✅ **Patrón canónico "Tabla Reinicia"** (§5.A25) — banner+nota+header+datos+TOTAL pegado, col A negra bold
- ✅ **Patrón "bloque de configuración"** (§5.A26) — verde menta + gris validación
- ✅ **Espaciado canónico 5 filas vacías** (§5.A27) entre bloques
- ✅ **Col G facturable en lavanda + bold** en TODAS las tablas con horas finales
- ✅ **Redondeo a 2 decimales con preservación** (§5.A23) — algoritmo half-up + fallback ceiling
- ✅ **Anti-Roboto** (§5.A22) — `font_name: "Manrope"` obligatorio
- ✅ **Notas obligatorias en headers y configuración** (§5.A24 + ANEXO B con catálogo verbatim)
- ✅ **Cambio arquitectónico Informe!B27** (§5.A21) — `SUMAR.SI` sobre Pivot Table
- ✅ **Cliente con sistema preexistente** (§3.4.ter) — 3 opciones A/B/C
- ✅ **Inventario automático de anomalías al cierre** (§3.10.bis) — 6 chequeos
- ✅ **Reglas técnicas nuevas**: 5.A19 (Manrope fallback Roboto), 5.A20 (re-formato pisa), 5.A21 (inserción rompe externas), 5.A22 (anti-Roboto), 5.A23 (redondeo con preservación), 5.A24 (notas obligatorias), 5.A25 (Tabla Reinicia), 5.A26 (bloque config), 5.A27 (5 filas vacías), 5.A28 (row 3 nota italic), 5.A29 (cabeceras Informe)

### 12.2 Para v1.5 (medio plazo, próximo)

- **Plantilla canónica en Workdrive** que la skill duplique con `ZohoSheet_copy` en lugar de generar pestaña a pestaña (gran ahorro de llamadas API)
- **Automatización de los pasos manuales de Sección 13** si la API MCP los expone en el futuro (ocultar pestañas, reordenar pestañas, Protect Sheet, formato porcentaje)
- **Manual de estilo Resolution Summary y Original Request completo**: 5-10 ejemplos por categoría, glosario terminológico, longitud óptima medida
- **Catálogo de clientes activos** para acelerar elicitación: lista, listas ClickUp conocidas, idioma, PO Cliente, modelo contractual por defecto
- **Modo B completo**: flujo de diff visual entre versiones, gestión sistemática de merges, recálculo automático del semáforo con disparo condicional de comentarios
- **Cron de programación automática** (depende de skills hermanas, ver 12.4)
- **Custom field "Fecha refinamiento Claude" en ClickUp** (depende de skill `soporte-procesamiento-clickup-reinicia` v1.9+ y `soporte-correo-clickup-reinicia` v1.x+): que esas skills escriban un timestamp limpio al cerrar el refinamiento, en vez de inferirlo de `time_in_status` heurísticamente. Una vez disponible, columna L de PO Breakdown leería directamente del custom field.
- **Diferenciación PO en Soporte vs Gestión** (Q-G futuro): cómo discriminar qué imputa el PO contra qué bolsa
- **Información adicional en Informe**: comparativa con periodos anteriores, top 3 items por horas, SLA de respuesta/resolución
- **Información adicional en Histórico**: modelo de contrato vigente, % variación entre periodos, carry-over rolado explícito
- **Ocultar pestañas vía API**: si Zoho expone el método `worksheet.hide` en el MCP en el futuro, automatizar el paso 13.1
- **Endurecer §3.10.bis (inventario anomalías)**: añadir chequeos de productos retrasados (DOING con fecha límite vencida), productos sin actividad >2 sprints, time entries de fin de semana.

### 12.3 Para v2.0 (largo plazo)
- **Export a Word/PDF** para Dirección
- **Dashboard agregado de varios clientes** con Soporte activo
- **Cross-comparison entre clientes**: KPIs internos Reinicia
- **Detección automática de patrones**: clientes con consumo recurrente alto, ítem-types más frecuentes
- **Integración con CRM**: oportunidad comercial automática en Zoho CRM al 🟠
- **Envío automatizado al cliente** una vez validado por PO (con email tracking)

### 12.4 Dependencias en skills hermanas

⚠️ **`apertura-gestion-mensual-clickup-reinicia` v1.1**: debería crear automáticamente la subtarea "Generación informe dedicación..." al abrir cada mes, con el periodo correcto según modelo de contrato del cliente:
- Cliente con bolsa puntual multi-mes → subtarea con periodo acumulativo (desde inicio Soporte hasta fin de mes)
- Cliente con cuota mensual → subtarea con periodo del mes natural
- Cliente con periodicidad quincenal/semanal → subtareas correspondientes

Actualmente esta skill (`informes-dedicacion-...`) suple la falta creando la subtarea en el momento del cierre formal (sección 3.10), pero el orden lógico es que la skill de apertura mensual la cree desde el principio. Apuntado para v1.1 de `apertura-gestion-mensual-clickup-reinicia`.

⚠️ **`soporte-procesamiento-clickup-reinicia` y `soporte-correo-clickup-reinicia` (NUEVO v1.2)**: añadir custom field tipo fecha **"Fecha refinamiento Claude"** que la skill escriba al cerrar el refinamiento del producto en Soporte. Esto sustituirá al heurístico actual de `time_in_status` que usa la skill de informes para rellenar la columna L "Fecha refinamiento" del PO Breakdown.

Notas relevantes del análisis v1.2:
- La memoria global indicaba que esas skills aplicaban un tag `primer-refinamiento-individual-realizado`, pero **NO se hace** en la implementación actual.
- El comentario "Resolution Summary" en la tarea es escrito por el consultor humano tras la resolución, no tras el refinamiento — no fiable como timestamp de refinamiento.
- Mientras no exista el custom field, la skill de informes usa la heurística `time_in_status` (primer evento que pasa a `product backlog` o `sprint backlog`).

---

## 13. Pasos previos al envío al cliente *(NUEVA v1.3)*

Antes de compartir el Zoho Sheet con el cliente, el PO debe ejecutar **manualmente desde la UI** los siguientes pasos (la API MCP no los expone):

### 13.1 Ocultar pestañas internas

Pestañas que **se ocultan** antes de enviar:
- PO Breakdown Preparation
- Pivot Table
- ClickUp Data
- Bonus History
- Leyenda

Pestañas que **quedan visibles** para el cliente:
- **Report** (pestaña principal cara cliente)
- **Historical** (histórico de periodos del cliente)

⚠️ Las pestañas se ocultan: clic derecho sobre el nombre → "Hide sheet" (o equivalente en el idioma de la UI).

### 13.2 Reordenar pestañas (Historical en 2ª posición)

Si tras crear todas las pestañas el orden no coincide con el canónico, **arrastrarlas manualmente** desde la UI hasta dejarlas en este orden:

| Posición | Pestaña |
|---|---|
| 1ª | Report |
| 2ª | Historical |
| 3ª | PO Breakdown Preparation |
| 4ª | Pivot Table |
| 5ª | ClickUp Data |
| 6ª | Bonus History |
| 7ª | Leyenda |

⚠️ La API MCP no expone `worksheet.move` (ver 5.A18). En la práctica, lo más habitual al crear desde cero es que **Historical quede en 5ª posición** (porque se crea después de PO Breakdown, Pivot Table, ClickUp Data) y haya que **arrastrarla a 2ª**. El resto suele quedar bien si se respeta el orden de creación: Report → Historical → PO Breakdown → Pivot Table → ClickUp Data → Bonus History → Leyenda.

⚠️ **Mejor práctica recomendada para v1.3**: al crear el workbook desde la skill, crear las pestañas **en el orden canónico** (Report, Historical, PO Breakdown, ...). Así no hay reordenamiento manual posterior. Si la plantilla canónica (pendiente v1.4) existe, esto se resolverá automáticamente.

### 13.3 Bloquear edición y ocultar fórmulas — Protect Sheet

Para que el cliente no pueda editar el sheet ni ver fórmulas haciendo clic en celdas:

1. Activar **Tools → Protect Sheet** en la pestaña Report
2. Configurar protección sobre **todas las celdas** o, más conservador, sobre las cols G:I de la row 20 (donde están las AUX cells con texto blanco)
3. **Verificar** que con la protección activa, clicar en G20 (por ejemplo) no muestra la fórmula

⚠️ Protect Sheet **NO está disponible vía MCP**. Es paso manual obligatorio.

### 13.4 Última verificación numérica

Antes de enviar, comprobar manualmente que las celdas clave del Report siguen cuadrando:

| Celda | Qué verificar |
|---|---|
| B16 | Hours consumed = B26 + B27 + B28 + B29 |
| B17 | Hours remaining = B15 − B16 (no negativo si % < 100%) |
| B18 | % consumido formateado como `XX,XX%` (no `XX.XX%`) |
| C18 | Semáforo coherente con %: 🟢 <50%, 🟡 50-75%, 🟠 75-100%, 🔴 ≥100% |
| F20 | Estimated exhaustion date en formato `dd/MM/yyyy` |
| B26 | Support tickets = SUMAR.SI(Support + Inquiry) |
| B27 | Account Management = `='PO Breakdown Preparation'!G34` |
| E47 | Subtotal billable DETAIL = B16 |
| E57 | TOTAL CONSUMED = B16 |

### 13.5 Renombrado final del fichero (si aplica)

Si tras revisar con los POs hay cambios, **subir versión** del nombre del fichero (`v4` → `v5`). La API MCP no permite renombrar Zoho Sheet files — hacerlo manualmente desde la UI de Workdrive.

### 13.6 Compartir con el cliente

Tras todos los pasos anteriores, compartir el sheet con permisos de **solo lectura** desde Workdrive UI.

---

## 6.bis-G (NUEVA v1.1) — Manual de estilo Resolution Summary

### Principios generales

**Audiencia**: el cliente del Soporte Operativo (típicamente Operations Manager, Dirección, o Product Owner del lado cliente). Persona ocupada que necesita entender el valor entregado sin entrar en jerga técnica interna.

**Objetivo**: dejar claro qué se pidió, qué hicimos, y qué valor entregamos. Cada ítem debe defender por sí solo las horas que reporta.

**Longitud**: 1-3 frases. Máximo 4. Nunca párrafos.

**Idioma**: el del informe (NO del consultor ni de los comentarios internos de ClickUp).

### Reglas operativas

#### G1 — Estructura típica
1. **Qué se pidió** (1 frase, contexto)
2. **Qué hicimos** (1-2 frases, diagnóstico + acciones técnicas)
3. **Valor entregado** (opcional, 1 frase si añade valor — formación, evitar problema futuro, etc.)

#### G2 — Tono "consultor experto"
- Sí: "Diagnosed the issue where Opportunity Probability could not be edited..."
- Sí: "Walked the user through creating a custom view..."
- No: "Hicimos lo que pedían" (vago, no transmite valor)
- No: "We ran a Python script to scrape the data" (jerga técnica innecesaria)

#### G3 — Items GUARANTEE: tono sobrio
Recordar que va sin coste, no inflar el trabajo. Plantilla típica:
> "Reviewed reports of [X]. Investigated root cause and applied corrections within the implementation guarantee. No charge to the support pack."

Si el item GUARANTEE fue complejo, se puede ampliar (hasta 3 frases), pero siempre cerrando con "No charge to the support pack."

#### G4 — Items en curso / pending
Si el item está en curso o esperando validación del cliente, dejar claro el estado:
- "Currently in product backlog awaiting Carritech's confirmation of..."
- "Solution prototype delivered by video; development is currently in progress and pending impact assessment on..."

#### G5 — Confidencialidad Amigos Reinicia
NUNCA mencionar Síntaris, Marcos Ortiz, Chisco Álvarez, Rocío Córdoba u otros colaboradores externos. Sustituir por:
- "the Reinicia delivery team" (EN) / "el equipo de Reinicia" (ES)
- "internal coordination" (sin nombrar a quién)

#### G6 — Urgencia comercial
Cuando hay urgencia comercial (lead loss, integración crítica caída, etc.), destacar el SLA de respuesta:
- "Same-day call scheduled..."
- "Fast turnaround minimized commercial impact."

#### G7 — Cuando el item es muy simple
Items rápidos (aclaración, walkthrough, configuración menor) no necesitan inflarse:
- "Quick clarification for [usuario] on how to [acción]. Walked the user through [solución] and provided a written response for future reference."

### Ejemplos validados (Carritech v3)

**Ejemplo 1 — Item complejo técnico (Networking equipment, 8,30h)**:
> "Loaded the full 'Hardware Profile' picklist values from NAV into Zoho CRM. Required transforming and pivoting the source data with Zoho DataPrep, validating in sandbox first, then deploying to production with a verification report. Approach designed to keep CRM aligned with NAV without manual data entry."

Análisis: 3 frases. Qué se hizo + cómo + por qué. Tono consultor experto sin jerga interna.

**Ejemplo 2 — Item Management (Account management - April, 5,53h)**:
> "Day-to-day account management for the period: ticket triage as new requests came in, sprint planning, follow-up calls with Carritech, internal coordination of the Reinicia delivery team, and progress reporting. Proactive communication kept Miguel informed of every item's status throughout the month."

Análisis: 2 frases. Lista de acciones + valor entregado (proactividad + visibilidad al cliente). NO menciona Síntaris.

**Ejemplo 3 — Item Support con diagnóstico (Log a call, 0,75h)**:
> "Investigated why user Yura could not register a call against the contact linked to 'Korean National Railway'. Root cause identified: the same company existed twice in the database — once as Account, once as Contact — with different identifiers. Performed record merge to consolidate the duplicate and provided a walkthrough so the team can resolve similar cases independently in the future."

Análisis: 3 frases. Pregunta → diagnóstico → acción + formación. Cierre potente (transferencia de conocimiento).

**Ejemplo 4 — Item urgencia comercial (Zoho CRM Form Support, 0,58h)**:
> "Diagnostic of the Zoho Forms → Zoho CRM integration that had stopped pushing leads, with Nick urgently reporting that incoming leads were being lost. Same-day call scheduled, integration reviewed end-to-end (form mapping, CRM module destination, OAuth token, audit log) and resolution applied so leads flowed correctly again. Fast turnaround minimized commercial impact."

Análisis: 3 frases. Urgencia explícita + acciones técnicas + valor (turnaround rápido).

**Ejemplo 5 — Item simple aclaración (Excel export, 0,27h)**:
> "Quick clarification for Miguel on how to export filtered records to Excel: in Zoho CRM, the Excel export action exports the full module unless a custom view is selected first. Walked the user through creating a custom view with the desired filters and exporting from that view, and provided a written response for future reference."

Análisis: 2 frases. Acción + valor (referencia futura). Sin inflar.

**Ejemplo 6 — Item GUARANTEE (Duplicate Contacts, 0h en informe, 12,68h reales)**:
> "Reviewed reports of duplicate Contact records created during early CRM operation. Investigated root cause and applied corrections within the implementation guarantee. No charge to the support pack."

Análisis: 3 frases sobrias. Plantilla GUARANTEE aplicada limpio.

**Ejemplo 7 — Item en curso (Contact association, 1,00h, status Doing)**:
> "Analysis of the request to model many-to-many relationships between Contacts and Accounts. Recommended approach: keep one primary Account on the Contact and add a secondary relationship structure for additional branches/companies, preserving NAV alignment. Solution prototype delivered by video; development is currently in progress and pending impact assessment on Opportunities, Sales Quotes and Brokerbin scraper integrations."

Análisis: 3 frases. Análisis + recomendación + estado actual + dependencias pendientes. NO menciona Síntaris (que es quien desarrolla).

**Ejemplo 8 — Item Product Backlog (Lead assignment rules, 0,45h)**:
> "Scoping work for setting up Zoho CRM Assignment Rules so leads from Zoho Forms get routed automatically to the right salesperson. Currently in product backlog awaiting Carritech's confirmation of the assignment criteria (country/language, product line, value tier, round-robin or generic 'Carritech' user). Estimate prepared (4.5–5.5h) covering rule configuration, test leads for each rule, and a short maintenance guide for Carritech."

Análisis: 3 frases. Trabajo realizado + estado + entregable (estimate). Implícitamente: la pelota está en el cliente.

### Anti-patrones (NO hacer)

❌ **Mencionar herramientas internas Reinicia**:
- ❌ "We ran the automatic-scraper-skill v3.2 to extract..."
- ✅ "Extracted the data using our internal automation toolkit"

❌ **Mencionar Amigos Reinicia o subcontratas**:
- ❌ "Development handled by Síntaris team"
- ✅ "Development in progress with the Reinicia delivery team"

❌ **Inflar items GUARANTEE**:
- ❌ "Reviewed 287 duplicate contacts over 12 hours of deep investigation, applying advanced merging algorithms..."
- ✅ "Reviewed reports of duplicate Contact records... within the implementation guarantee. No charge to the support pack."

❌ **Jerga técnica innecesaria**:
- ❌ "Implemented a webhook-driven Bidirectional OAuth refresh token rotation via Zoho Flow"
- ✅ "Integration reviewed end-to-end and resolution applied"

❌ **Vago sin valor**:
- ❌ "Resolved the issue"
- ✅ "Diagnosed [causa específica] and applied [acción específica]"

❌ **Párrafos largos**:
- ❌ 5+ frases con detalle exhaustivo
- ✅ 1-3 frases (4 máximo) ejecutivas

---

## ANEXO — Checklist de generación rápida (uso al ejecutar la skill)

```
ELICITACIÓN
□ 1. Cliente
□ 2. Periodo (DD/MM/AAAA - DD/MM/AAAA)
□ 3. Modelo de contrato (A/B/C)
□ 4. Horas contratadas + fechas validez
□ 5. Fecha inicio Soporte Operativo actual
□ 6. PO Cliente + equipo Reinicia
□ 7. Lista ClickUp Soporte + Gestión + carpeta Workdrive
□ 8. Idioma (ES/EN) — determina nombre fichero + banner
□ 9. Carry-over from previous (0 si primer informe)
□ 10. Productos fuera de Soporte/Gestión (Q-E: por defecto NO)
□ 11. Modo dry-run (recomendado primer informe)

RECOPILACIÓN
□ Listar tarjetas Soporte + Gestión del periodo
□ Tiempo del PO Cliente (Q-G: SÍ cuenta)
□ Detalle por tarjeta (name, status, MIN/MAX, fechas)
□ Time entries del periodo (Q-H: datos crudos actuales)
□ Comentarios para Resolution Summary
□ Identificar categorías (Support/Management/Inquiry/In-warranty)
□ Lista de productos sin MIN/MAX
□ Time entries crudos para ClickUp Data

CÁLCULOS
□ Hours consumed (Python, suma time entries del periodo)
□ Días laborables del periodo (5/7)
□ Velocidad/día laborable
□ Estado del semáforo según %
□ Textos del semáforo y Days to contract end

CREACIÓN WORKBOOK
□ Nombre canónico por idioma (ES o EN)
□ ZohoSheet_create_workbook
□ Validar status=1, nombre exacto, display_url_name limpio
□ **Renombrar Hoja1 → Informe (ES) o Report (EN)** (v1.4)
□ Crear 5 pestañas con nombre localizado: PO Breakdown / Pivot Table / ClickUp Data / **Histórico** (ES) o Historical (EN) / **Bonus History** / Leyenda
□ **LAVADO BASE PASO 0 (v1.4)**: format_ranges con fill_color:#FFFFFF + border:{#FFFFFF, solid, all_border} + font_name:"Manrope" en A1:Z100 de TODAS las pestañas ANTES de poblar (§3.4.bis)

CONTENIDO POR PESTAÑA
□ ClickUp Data: header + filas con cells.content.set en lotes ≤50 (NO csvdata.set por bug coma decimal — memoria #30)
□ Pivot Table: header + filas con SUMAR.SI sobre ClickUp Data + Total
□ **Bonus History (v1.2/v1.3)**: banner + nota + header + filas heredadas de informes anteriores + entradas nuevas
□ PO Breakdown Preparation (v1.4): banner + nota + bloque B4-B5 config (verde menta + gris validación) + header + items rows 7-14 con G en lavanda + bold + TOTAL row 15 + **5 filas vacías rows 16-20** + banner Operational Planning row 21 + nota row 23 + bloque B24-B25 + header row 26 + filas Management/Refinement + TOTAL
□ Histórico: banner + nota italic (row_height:20, wrap_text:false) + header + fila del periodo actual con cifras a 2 decimales
□ Informe: cabecera (col A wrap_text + row_height:30), SUMMARY (con celdas auxiliares G19:I20), BREAKDOWN en A-B (Q-F: GUARANTEE a 0, **B27 con SUMAR.SI sobre Pivot Table v1.4**), DETAIL (Hours=BUSCARV con 0, col L Original Request), GLOSSARY (con Consumption levels, statuses ordenados al ciclo de vida, **col B wrap_text:false v1.4**), Contacto solo PO
□ **Leyenda**: 4 secciones (Informe / PO Breakdown / Pestañas auxiliares / Notas operativas), col A texto negro bold + bordes blancos (v1.4)

VALORES Y FÓRMULAS — REGLAS CRÍTICAS
□ Decimales con coma es-ES ("24,26", no 24.26)
□ Fechas con =FECHA(YYYY;M;D)
□ BUSCARV con 4º arg = 0 (no FALSO)
□ Rangos BUSCARV acotados ($A$2:$D$17)
□ ENTERO() en restas de fechas
□ TEXTO(;"0,00%") para porcentajes
□ Fórmulas en español (locale ES)
□ **Redondeo a 2 decimales en cara cliente** (v1.4 §5.A23) con preservación de fórmulas dependientes (half-up + fallback ceiling)
□ **Informe!B27 = SUMAR.SI sobre Pivot Table** (v1.4) en lugar de referencia directa a celda

CELDAS NOMBRADAS (con notación de rango B6:B6)
□ Hours_contracted = B6:B6
□ Contract_end = B9:B9
□ Hours_consumed = B16:B16
□ Hours_remaining = B17:B17
□ Carry_over_next = B19:B19
□ Carry_over_previous = B29:B29 (no D29:D29)

ANCHOS DE COLUMNA (usar ZohoSheet_column_width, NO format_ranges)
□ Informe A=200, ..., K=380, **L=456** (v1.2)
□ PO Breakdown Preparation A=350, B=130, ..., M=187 (v1.2)
□ Pivot Table A=120, B=350, ..., E=120
□ ClickUp Data A=120, ..., H=325
□ Histórico A=180, ..., H=450
□ **Bonus History (v1.2)** A=160, B=213, C=213, D=480
□ Leyenda A=240, B=200, C=600

FORMATO CANÓNICO (sección 6.bis + v1.4)
□ **font_name: "Manrope" OBLIGATORIO en CADA format_ranges** (§5.A22)
□ Bordes blancos por defecto en todas las pestañas (§3.4.bis)
□ Banner row 1 con bordes invisibles (color = fondo) en Informe (A1:L1) / PO Breakdown (A1:M1) / Histórico
□ Cabecera y SUMMARY: col A #D1FAF2, cols B-F #F2F2F2 — **col A wrap_text:true + row_height:30** (v1.4 §5.A29)
□ BREAKDOWN en A-B con header azul, datos col A #D1FAF2 col B #F2F2F2, total #D9D0FB
□ DETAIL: A-L en #F2F2F2 SIN zebra (v1.2), chips status col J, col L Original Request wrap_text+middle, subtotales A-L #D9D0FB, TOTAL CONSUMED A-L #3812CF blanco bold con bordes #3812CF
□ Statuses glossary en orden ciclo de vida (v1.2): Open → Product Backlog → Sprint Backlog → Doing → Validation Client → Closed → Parking
□ GLOSSARY: banner #545454 extendido A-L (v1.2), sub-secciones col A #D1FAF2 cols B-L #F2F2F2, **col B wrap_text:false** (v1.4)
□ PO Breakdown rows 7-14 col G: **fondo lavanda #D9D0FB + font #3812CF + bold** (Hours final destacado, v1.4)
□ PO Breakdown rows 27-29 col G: **fondo lavanda + bold** (Billed hours destacadas, v1.4)
□ PO Breakdown bloques config rows 4-5 + 24-25: **verde menta #D1FAF2 + bold para A:B; gris #F2F2F2 + italic para C** (v1.4 §5.A26)
□ PO Breakdown rows 16-20: **5 filas vacías** entre tabla principal y Operational Planning (v1.4 §5.A27)
□ PO Breakdown cols K-L-M (v1.2): fondo #EBEBEB (NO #F2F2F2 — distinto del Informe), bordes blancos, formato fecha dd/MM/yyyy HH:mm en K-L y dd/MM/yyyy en M
□ PO Breakdown fila TOTAL row 15: lavanda extendido A-M (PEGADO a row 14, v1.4)
□ Pestañas internas: datos #F2F2F2 o #EBEBEB según pestaña, total #D9D0FB extendido, cols laterales y rows extra blanco (§3.4.bis)
□ Leyenda col A: **texto NEGRO bold sobre #F2F2F2** (no azul Reinicia, v1.4 §7.7)
□ Banner del semáforo extendido C18:F18 con color del estado
□ C18 con wrap_text:false (texto desborda)
□ Celdas auxiliares G19:I20 ocultas con texto blanco (v1.3 §5.A14)
□ Resolution Summary col K wrap_text + vertical top + size 9
□ Original Request col L wrap_text + vertical middle + alineación start + Manrope (v1.2)
□ Row 3 nota italic en TODAS las pestañas: wrap_text:false + row_height:20 + bordes blancos (v1.4 §5.A28)

NOTAS EN CELDA *(catálogo completo en ANEXO B v1.4)*
□ C18 (semáforo) con thresholds
□ B29 (Carry-over previous) explicando que el PO lo actualiza
□ G19 (AUX cells) explicando algoritmo del ritmo de consumo
□ **B4 PO Breakdown** (Default Bonus %): explicación UPLIFT, fórmula, rangos
□ **B5 PO Breakdown** (Bonus bounds): fórmula validación
□ **E6, F6, G6 PO Breakdown** (headers tabla principal)
□ **K6, L6 PO Breakdown** (headers fechas)
□ **B24, B25 PO Breakdown** (defaults Operational Planning)
□ **A26, B26, C26 PO Breakdown** (headers Operational)
□ **F7:F14 PO Breakdown**: "Frozen from informe vN — Bonus aplicado: X%..."
□ **F27:F29 PO Breakdown**: "Frozen from informe vN — Type [X], % aplicado Y%..."
□ **E27:E29 PO Breakdown** (% override Operational): cascada prioridad
□ **M6 PO Breakdown**: explicar BUSCARV a Bonus History

RESOLUTION SUMMARY + ORIGINAL REQUEST (v1.2 — manual de estilo sección 6.bis-G y 6.bis.D)
□ Borrador 1-3 frases por ítem en idioma del informe (col K)
□ **Borrador Original Request por ítem (col L v1.2)**: Original name + Cliente request
□ Tono consultor experto, sin jerga interna
□ NUNCA mencionar Amigos Reinicia
□ Items GUARANTEE: sobrios, "no charge to the support pack", L con "Cliente reported X..."
□ Items Account management / Gestión: L vacío
□ Items en curso: dejar claro estado y dependencias
□ Presentar tabla compacta al PO para validación
□ Esperar OK explícito
□ Escribir en cols K y L rows correspondientes

ORDEN DE FILAS (v1.2)
□ PO Breakdown items 7-14: por **Fecha entrada DESC** (date_created) — máx 8 productos individuales en v1.4 (antes 16 hasta row 22)
□ Informe billable items 36..N: por **Start Date DESC**
□ Informe in-warranty items N+4..M: por **Start Date DESC**
□ **VALIDACIÓN POST-REORDENAMIENTO obligatoria**: get_content_of_worksheet del rango y verificar orden contra criterio

INVENTARIO ANOMALÍAS DE CIERRE *(NUEVA v1.4 §3.10.bis)*
□ Time entries sin task asociada → listar
□ Time entries de personas no del equipo Reinicia → listar
□ Time entries cross-cliente del equipo → listar
□ Tarjetas duplicadas (mismo name) → listar
□ Tarjetas de Soporte sin Tiempo MIN/MAX → listar
□ Si dry-run con ClickUp Data agregada → advertir repoblar individual en oficial

COMENTARIOS AUTOMÁTICOS (si semáforo 🟠 o 🔴)
□ Comentario al PO Cliente con texto según modelo (A/B/C) — mencionar agotamiento bolsa Y fin contrato
□ Comentario a Néstor (user_id 766716)
□ Si 🔴: comentario adicional a Néstor

COMENTARIO FINAL AL PO
□ En producto Gestión [Mes en curso] **del cliente** (ej. Gestión Mayo 2026 [SYNUPTIC]), NO en lista Gestión Reinicia interna, NO en subtarea
□ Asignado al PO Cliente
□ Incluye: enlace + datos clave + revisar + productos sin MIN/MAX + **inventario anomalías (v1.4 §3.10.bis)** + aviso aux cells G19:I20
□ Si después se aplican refinamientos visuales: comentario ADICIONAL (no borrar el original)

CIERRE
□ Buscar subtarea "Generación informe dedicación..."
□ Si existe: marcar como Closed
□ Si NO existe: crearla con nombre canónico + cerrarla inmediatamente
□ Avisar pendientes manuales (logo, notas que dieron "No approval received", rename de fichero si aplica, formato porcentaje a B4/B24/B25/C6:CN Bonus History, ocultar pestañas internas, Protect Sheet)
```

---

## ANEXO B — Catálogo de notas obligatorias por celda *(NUEVA v1.4)*

Texto verbatim de las notas que la skill debe aplicar con `set_note_to_cell` para garantizar trazabilidad y autodocumentación del workbook. **Todas las notas en castellano** (uso interno del equipo Reinicia), independientemente del idioma del informe.

### Pestaña Informe (cara cliente)

**C18 — Semáforo de consumo:**
```
Semáforo de consumo (4 niveles):
  🟢 Healthy (≤ 60%): consumo dentro de previsión, sin acciones requeridas.
  🟡 Monitor (60-80%): seguir de cerca, alertar al cliente del ritmo.
  🟠 Negotiate (80-100%): comentario automático al PO Cliente y a Néstor (§3.8).
  🔴 Exceeded (>100%): regularización inmediata, comentario adicional a Néstor.

Valor actual: [estado calculado en B18].

Conclusión operativa: [calculada según semáforo].
```

**G19 — AUX cells (algoritmo ritmo de consumo):**
```
Celdas auxiliares de cálculo del ritmo de consumo proyectado:
  G19 = horas tracked en el periodo (= B16)
  H19 = días laborables transcurridos del periodo (= ENTERO((HOY()-B7)×5/7))
  I19 = velocidad diaria laborable (= G19/H19)
  G20 = horas restantes de la bolsa (= B17)
  H20 = días laborables hasta fin de contrato (= ENTERO((B9-HOY())×5/7))
  I20 = días laborables que duraría la bolsa al ritmo actual (= G20/I19)

Fecha de agotamiento proyectada (B20) = HOY() + I20×7/5 días naturales.

⚠️ NO MODIFICAR ESTAS CELDAS. Son cálculo intermedio.
Ocultas con texto blanco. Para inspeccionarlas, seleccionar A19:I20.
```

### Pestaña PO Breakdown Preparation (interna)

**B4 — Default Bonus % (UPLIFT):**
```
Default Bonus % aplicable a productos NUEVOS este periodo.

Es un UPLIFT (porcentaje que se SUMA a las horas raw) para cubrir overhead no imputado por los consultores: análisis previo, contexto, comunicaciones, micro-interrupciones, revisiones internas y micro-tareas no trackeadas.

Fórmula aplicada en la tabla principal:
  Hours final = ENTERO(Hours raw × (1 + Bonus %) × 100) / 100

Ejemplo: 1,45h raw × (1 + 0,15) = 1,66h final.

Rangos:
  • 0% — sin uplift (no recomendado)
  • 15% — default Reinicia
  • 25% — máximo permitido

Los productos PREEXISTENTES (que ya aparecieron en informes anteriores) conservan su % congelado en Bonus History y NO se ven afectados por este default.

Para sobrescribir manualmente el % de un producto en este informe, rellenar la columna E (Bonus % override) de la fila correspondiente.
```

**B5 — Bonus % bounds (validación):**
```
Regla de validación del Bonus %:

Fórmula:
  =SI(O($B$4<0;$B$4>0,25);"⚠ Out of range 0% - 25%";"0% – 25% OK")

Verifica que el valor en B4 esté dentro del rango permitido [0%, 25%].

Política Reinicia: el bonus UPLIFT no debe exceder 25% porque el cliente percibiría una sobrefacturación no justificada por overhead razonable. Si se necesita una facturación mayor por circunstancias excepcionales (ej. trabajo fuera de horario, urgencias), no usar el bonus: documentarlo como concepto aparte en la propuesta comercial.

La misma fórmula MAX(0;MIN(0,25;$B$4)) se aplica en cada fila (col F) para clampear el % aplicado al rango válido.
```

**E6 — Bonus % override (header):**
```
Bonus % override (opcional, manual del PO)

Permite sobrescribir el bonus % aplicado a esta fila concreta sin afectar al default global (B4) ni al resto de productos.

Uso típico:
  • Vacío (recomendado): la fila usa Bonus History (si el producto ya apareció en informes anteriores) o el default B4 (si es producto nuevo).
  • Con valor: el PO impone manualmente un % para este producto en este informe. Solo afecta a esta versión del informe; las versiones posteriores recuperarán el % congelado en Bonus History.

Rangos válidos: 0 a 0,25 (0%-25%). Valores fuera de rango se clampean automáticamente.
```

**F6 — Bonus % applied (header):**
```
Bonus % applied (calculado, frozen)

% efectivo que se aplica a esta fila. Calculado con prioridad descendente:
  1. Si E (override) tiene valor → ese %.
  2. Si NO hay override pero el Task ID está en Bonus History → el % congelado allí (preserva continuidad entre informes).
  3. Si no existe en Bonus History → cae al default B4.

Fórmula:
  =SI(ESBLANCO(En);SI.ERROR(BUSCARV(Bn;'Bonus History'!$A$6:$C$25;3;0);MAX(0;MIN(0,25;$B$4)));MAX(0;MIN(0,25;En)))

Cláusula MAX(0;MIN(0,25;...)) asegura que el valor siempre esté entre 0% y 25% incluso si el override está fuera de rango.

Propósito de congelar: el % de un producto NO debe cambiar entre informes salvo decisión explícita del PO.
```

**G6 — Hours final (header):**
```
Hours final (horas finales facturables)

Horas facturables al cliente para este producto, tras aplicar el uplift del bonus %.

Fórmula:
  =ENTERO(D × (1+F) × 100) / 100

Desglose:
  • D = Hours raw (horas tracked en ClickUp por todo el equipo de entrega)
  • F = Bonus % applied
  • (1 + F) = factor multiplicador (1,15 para 15% default)
  • ENTERO(...×100)/100 = truncado a 2 decimales

Ejemplo numérico:
  Producto con D = 1,45h y F = 0,15:
  G = ENTERO(1,45 × 1,15 × 100) / 100 = ENTERO(166,75) / 100 = 1,66h

Estas horas se trasladan al Subtotal facturable del Informe (cara cliente).
```

**K6 — Fecha entrada (header):**
```
Fecha entrada

Fecha y hora en que la tarea fue creada en ClickUp (date_created). Es el primer punto de trazabilidad temporal del producto.

Formato: dd/MM/yyyy HH:mm (timezone Europe/Madrid, ajustado automáticamente para DST).

Origen del dato: campo date_created del objeto tarea de ClickUp.

Uso operativo:
  • Ordenar la tabla principal por esta columna (DESC) para ver los productos más recientes arriba.
  • Calcular antigüedad del producto: HOY() - Fecha entrada.
  • Detectar productos que llevan mucho tiempo sin moverse al backlog.
```

**L6 — Fecha refinamiento (header):**
```
Fecha refinamiento

Fecha en que la tarea fue movida por primera vez a uno de los estatus product backlog o sprint backlog (el primero que ocurra). Marca el momento en que el PO consideró la petición lista para entrar al backlog formal.

Formato: dd/MM/yyyy HH:mm (timezone Europe/Madrid).

Origen del dato: array time_in_status / status_history del objeto tarea en ClickUp.

Celda vacía: la tarea nunca pasó por backlog (típicamente Gestión mensual, o creada manualmente y saltada directamente a Doing).

⚠️ Heurística temporal: es la mejor aproximación disponible vía API hasta que ClickUp incorpore un custom field tipo fecha "Fecha refinamiento" para uso de Reinicia.
```

**B24 — Default % Management a facturar:**
```
Default % Management a facturar

Fracción de las horas de Gestión mensual (Account Management) que se facturan al cliente.

A diferencia del Bonus UPLIFT (B4), aquí el % MULTIPLICA en lugar de sumar:
  Billed hours = ENTERO(Raw hours × % × 100) / 100

Por qué 80% (default Reinicia):
  La Gestión mensual incluye coordinación interna, planificación, refinamiento, comunicaciones, follow-ups internos y otros gastos que no todos son repercutibles al 100% al cliente. El default 80% refleja la política de facturación estándar.

Ejemplo numérico:
  14,87h tracked en Gestión Abril × 0,80 = 11,89h facturables.

Rangos válidos: 0%-100%. La fórmula de validación en C24 controla este límite.

⚠️ Cada fila de Operational Planning puede sobrescribir este default rellenando la col E (% override) de esa fila.
```

**B25 — Default % Refinement a facturar:**
```
Default % Refinement a facturar

Fracción de las horas de Refinamiento anual que se facturan al cliente.

Fórmula:
  Billed hours = ENTERO(Raw hours × % × 100) / 100

Por qué 50% (default Reinicia):
  El Refinamiento es una actividad interna que beneficia tanto al cliente (mejor priorización y estimación de sus productos) como al equipo de Reinicia (mejor comprensión del backlog). Se considera apropiado repercutir el 50% al cliente.

Desagregación por mes:
  La tarjeta ClickUp Refinamiento es ANUAL, pero en Operational Planning se desagrega por mes en filas paralelas a Management, para coherencia visual y trazabilidad temporal.

Ejemplo numérico:
  3,2h tracked en Refinamiento Mayo × 0,50 = 1,60h facturables.

Rangos válidos: 0%-100%. La fórmula de validación en C25 controla este límite.

⚠️ Cada fila de Refinamiento puede sobrescribir este default rellenando la col E (% override) de esa fila.
```

**A26 — Item Key (header Operational):**
```
ClickUp task / Item Key

Clave única que identifica esta fila para los BUSCARV a Bonus History.

Formato según tipo:
  • Management: nombre exacto de la tarjeta ClickUp — ej. "Gestión Mayo 2026 [SYNUPTIC]"
  • Refinement: clave compuesta con periodo — ej. "Refinamiento 2026 [SYNUPTIC] - Mayo 2026"

Por qué distinto del Task ID:
  La tabla principal usa Task ID (col B) como clave de Bonus History porque cada producto individual tiene su task_id único. En Operational Planning, en cambio:
  • Las tarjetas de Gestión son mensuales y cambian de task_id mes a mes — mejor usar el nombre humano.
  • Las filas de Refinement comparten una sola tarjeta anual — mejor usar clave compuesta con mes.

El BUSCARV en Bonus History (col A = Identifier) acepta tanto task_ids como nombres compuestos sin colisión.
```

**B26 — Type (header Operational):**
```
Type (tipo de fila Operational)

Valores permitidos:
  • Management — fila correspondiente a una tarjeta de Gestión mensual del cliente.
  • Refinement — fila correspondiente a una desagregación mensual de la tarjeta Refinamiento anual del cliente.

La columna Type controla qué % default toma la fila:
  • Management → mira $B$24 (Default % Management = 80%)
  • Refinement → mira $B$25 (Default % Refinement = 50%)

⚠️ Otros valores no soportados. Si se introduce un valor distinto, la fórmula F devolverá el default Refinement (50%) como fallback.
```

**C26 — Period (header Operational):**
```
Period (rango temporal de la fila)

Rango de fechas que cubre esta fila, en formato dd/MM/yyyy - dd/MM/yyyy.

Para filas Management: coincide con el mes natural cubierto por la tarjeta de Gestión.
  Ej. Gestión Abril 2026 → 01/04/2026 - 30/04/2026
  Ej. Gestión Mayo 2026 (informe cortado a media de mes) → 01/05/2026 - 14/05/2026

Para filas Refinement: el mes desagregado del Refinamiento anual.

Por qué truncar por periodo de informe:
  El informe se cierra en una fecha concreta (Period end). Las horas de gestión del mes en curso se truncan a esa fecha para no facturar tiempo futuro al cliente.
```

**F7:F14 — Frozen % UPLIFT (por fila individual):**
```
Frozen from informe v[N] — primera aparición del producto. Bonus aplicado: [X]%. Valor heredado vía BUSCARV a Bonus History. Para sobrescribir en este informe, rellena la columna E (Bonus % override).
```

**E27:E29 — % override Operational (por fila):**
```
% override (manual del PO, opcional)

Permite sobrescribir el % aplicado a esta fila concreta de Operational Planning sin afectar al default global (B24 para Management, B25 para Refinement).

Uso típico:
  • Vacío (recomendado): la fila usa Bonus History (si la entrada ya apareció en informes anteriores) o el default según Type (col B).
  • Con valor: el PO impone manualmente un % para esta fila en este informe.

Rangos válidos: 0 a 1 (0%-100%).

⚠️ Cualquier override aquí se congela en Bonus History al cerrar el informe, igual que los % default. En informes posteriores, esa fila usará el override histórico salvo nuevo override.
```

**F27:F29 — Frozen % Operational (por fila individual):**
```
Frozen from informe v[N] — primera aparición de esta fila [Type]. % aplicado: [X]% (default [Type]). Valor heredado vía BUSCARV a Bonus History. Para sobrescribir en este informe, rellena la columna E.
```

### Pestaña Histórico (cara cliente)

Sin notas obligatorias específicas más allá de la nota descriptiva del banner en row 3.

### Pestaña Bonus History (interna)

**A5 — Header Identifier:**
```
Identifier

Clave única que se busca desde PO Breakdown Preparation (BUSCARV col B → A5+).

Para productos individuales: task_id de ClickUp (ej. "869d71qj5").
Para filas Management: nombre de la tarjeta de Gestión (ej. "Gestión Mayo 2026 [SYNUPTIC]").
Para filas Refinement: clave compuesta con mes (ej. "Refinamiento 2026 [SYNUPTIC] - Mayo 2026").

NO modificar manualmente: la skill mantiene esta columna automáticamente.
```

**E5 — Header Type:**
```
Type

Discrimina la categoría de la fila:
  • Bonus — producto individual con UPLIFT
  • Management — fila de Gestión mensual con % multiplicativo
  • Refinement — fila de Refinamiento mensual con % multiplicativo

Las fórmulas de PO Breakdown consultan Bonus History por Identifier (col A), no por Type, porque las claves son únicas dentro del dataset. Type es informativo para el equipo Reinicia al auditar el histórico.
```

### Pestaña Leyenda (interna)

Sin notas obligatorias en celda — el contenido es ya descriptivo por sí mismo. Excepción: si la columna C de algún concepto no es autoexplicativa con ejemplo numérico, añadir nota.

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.4 | 21/06/2026 | Néstor + Claude | Evolución de v1.3 tras sesión cruzada con Synuptic v2 (17/05/2026) y Gonher Mayo (17/05/2026). Refinamiento visual canónico completo: **(A)** Lavado base obligatorio (REGLA DEL LIENZO LIMPIO: fill_color blanco + border blanco simultáneos hasta col Z fila 100); **(B)** Pestañas cara cliente localizadas al idioma del informe (Informe / Histórico para ES, Report / Historical para EN); **(C)** Patrón canónico "Tabla Reinicia" formalizado (banner + nota + header + datos + TOTAL pegado, sin separaciones intermedias); **(D)** Patrón "bloque de configuración" (verde menta `#D1FAF2` + bold para valor editable; gris `#F2F2F2` + italic para validación); **(E)** Espaciado canónico **5 filas vacías** entre bloques distintos en una misma pestaña; **(F)** Col G "Hours final / Billed hours" siempre en lavanda `#D9D0FB` + bold (destaca el valor facturable); **(G)** Redondeo a 2 decimales con algoritmo half-up + fallback ceiling para preservar fórmulas dependientes (`G = ENTERO(D × (1+F) × 100) / 100`); **(H)** Anti-Roboto: `font_name: "Manrope"` obligatorio en TODO format_ranges; **(I)** Notas obligatorias en celdas de configuración y headers (catálogo verbatim en ANEXO B); **(J)** Cambio arquitectónico Informe!B27: usar `SUMAR.SI` sobre Pivot Table en lugar de referencia directa a fila absoluta (robustez frente a reestructuraciones); **(K)** Sección nueva — cliente con sistema de informes preexistente (3 opciones: Migrar / Coexistir / Manual); **(L)** Inventario automático de anomalías de cierre (6 chequeos); **(M)** 3 reglas técnicas nuevas (5.A19 Manrope fallback Roboto, 5.A20 re-formato pisa formato previo, 5.A21 inserción de filas rompe referencias externas). |
| v1.3 | — | Néstor + Claude | Versión anterior. Incorporaba: **(A)** sistema **Operational Planning** en PO Breakdown rows 24-34 con tabla separada para Account Management (Gestión mensual + Refinamiento) con % override por fila, defaults globales y congelación vía Bonus History; **(B)** **Bonus History UNIFICADO** con columna `Type` (Bonus \| Management \| Refinement), columna `Identifier` (genérica) y `Frozen %` — única fuente de verdad para TODAS las congelaciones; **(C)** nueva **pestaña Leyenda** como deliverable interno con explicaciones de Report, PO Breakdown, pestañas auxiliares y notas operativas, incluyendo ejemplos numéricos; **(D)** Refinamiento separado por meses con clave compuesta `Nombre - Mes Año` (la tarjeta ClickUp es ANUAL pero las horas se reparten por mes vía filtro `start` de time entries); **(E)** **REGLA DE ORO: NUNCA combinar celdas** (`merge_cell`) — banners y headers con fondo extendido + texto solo en celda A + celdas a la derecha vacías para permitir desbordamiento visual; **(F)** AUX cells del Report movidas a G19:I20 con texto blanco para ocultarlas; **(G)** Historical reubicado a 2ª posición tras Report (manual desde UI, no MCP); **(H)** A27 Report con etiqueta "Account Management" para coherencia con DETAIL; **(I)** múltiples reglas técnicas nuevas (5.A14-5.A18) sobre límites de la API Zoho Sheet (notas no eliminables, content="" asimétrico entre single/batch, unmerge implícito). |
| v1.2 | — | Néstor + Claude | Versión anterior. Cubría sistema Bonus por producto en `Bonus History` (esquema simple con Task ID + Frozen Bonus % + Source Report), columnas de fechas en PO Breakdown, columna L "Original Request" en Report DETAIL, órdenes canónicos validados, glosario statuses reordenado al ciclo de vida. |
