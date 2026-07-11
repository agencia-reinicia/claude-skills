---
name: plan-proyecto-zoho-sheet-reinicia
description: >
  Crea y mantiene el Plan de Proyecto (y el Plan de Marketing) de un cliente de Reinicia en Zoho
  Sheet, alineado con las listas General, Soporte y Gestión [CLIENTE] de ClickUp. Dos modos:
  CREACIÓN y ACTUALIZACIÓN sprint a sprint. Vuelca PBI de Primer Nivel y Tipo de Producto desde
  ClickUp (y escribe en ClickUp los PBI que falten), aplica el modelo de Épica híbrido (fase de
  funnel para microcampañas; objetivo de negocio para productos digitales), mantiene estatus con
  semáforo, fechas de entrega y validación con sus hitos y la sincronización con ClickUp, e
  inserta filas antes de poblar. Genera la pestaña Ideas (máx. 7 por ronda, tope por fuente) desde
  actas, notas de Gestión, histórico de productos, referencias de Zoho y proyectos similares de
  Reinicia, priorizadas por los Objetivos del Cliente. Actívala con: 'crea/actualiza el plan de
  proyecto de [CLIENTE]', 'sincroniza el plan con ClickUp', 'actualiza el plan de marketing'. No
  usar para crear productos en ClickUp ni actas de reunión.
---

# SKILL: Plan de Proyecto en Zoho Sheet — Reinicia

> **Versión vigente: v2.11 — sello con hora en 41#, fecha en 40# — 2026-07-11**

> ⚠️ **Prevalece el ANEXO B (v2.7 o vigente).** Antes de aplicar los pasos 3.x del cuerpo, **leer el ANEXO B completo**. La creación se hace **SIEMPRE** copiando la plantilla canónica `pnync351d56992b6d4026906a6fec5d56e682` con `ZohoSheet_copy`, **nunca** con `createNativeDocument`, `Create_New_File` ni `create_workbook`. La estructura canónica del fichero v2 (pestañas + tablas + mapa de columnas + portada + Config + Log + Resumen Histórico) está en **«4.0 ESTRUCTURA CANÓNICA DEL PLAN v2»** (más abajo, en el cuerpo) y en el ANEXO B. Los antiguos pasos 3.2–3.7 del cuerpo están **SUPERADOS** y quedan reescritos según el ANEXO B.

## Propósito
Crear y mantener el Plan de Proyecto de un cliente como documento vivo en Zoho Sheet,
alineado con el backlog de `General [CLIENTE]` en ClickUp. Sirve tanto al PO (seguimiento
interno) como al cliente (visibilidad sobre entregas comprometidas y su estado real).

**Recursos de referencia en Workdrive:**
- **Plantilla canónica v2 (Recursos Comunes Reinicia):** `pnync351d56992b6d4026906a6fec5d56e682` — 40#/41# + 3 tablas (IMPLANTACIÓN / SOPORTE ACTIVO / SOPORTE CERRADO) + Config + Ideas (42#) + Objetivos (45#) + Log de Cambios + Resumen Histórico. **Crear SIEMPRE copiándola con `ZohoSheet_copy`.**
- ⛔ ~~Plantilla antigua `47q3o1a477a21d2f848d28c957304f083b0b6`~~ **OBSOLETA** (1 sola pestaña, con residuos de marketing). **NO usar en ninguna circunstancia.**
- Ejemplo Web en inglés (Birdease): `hpgmh7de8cab0fd9e4fb58b51298dee7cb465`
- Ejemplo Zoho (Mazarea): `halr9080af8d0477045b3a9c56babd3aff12c`

---

## PASO 0 — DETERMINAR MODO: CREACIÓN o ACTUALIZACIÓN

Claude pregunta primero:
> "¿Quieres **crear** el Plan de Proyecto de este cliente desde cero, o **actualizar** uno que ya existe?"

→ CREACIÓN → ir a PASO 1A
→ ACTUALIZACIÓN → ir a PASO 1B

---

## PASO 1A — ELICITACIÓN (modo CREACIÓN)

Preguntas secuenciales, una a una:

### Pregunta 1: Cliente
"¿Para qué cliente es el Plan de Proyecto?"

### Pregunta 2: Carpeta en Workdrive
"¿Sabes el ID de la carpeta `Plan de Proyecto` del cliente en Workdrive? Si no, lo busco yo."
→ Buscar con `ZohoWorkdrive_searchTeamFoldersFiles` (team_id: `2km7j4dc468f82ead4a8489e55b64bfd3ecfe`)
  usando `search[name]` con el nombre del cliente.
→ ⚠️ **El Plan va SIEMPRE en la carpeta del proyecto** (p. ej. `Plan de Proyecto` / `Plan de marketing` del cliente), **NUNCA en `01. Seguimiento`.** Si la carpeta no existe, avisar al PO o crearla en la raíz del proyecto.
→ Dentro de la carpeta raíz del cliente, localizar la subcarpeta `Plan de Proyecto`.
  Si no existe, avisar al PO — debe crearla manualmente o confirmar en qué carpeta guardarlo.

### Pregunta 3: Lista en ClickUp
"¿Cuál es el ID de la lista `General [CLIENTE]` en ClickUp? Si no lo tienes, lo busco."
→ Buscar con `clickup_search` usando el nombre del cliente.

### Pregunta 4: Idioma
"¿El plan de proyecto va en **español** o en **inglés**?"
→ Condiciona todos los textos: cabeceras, estatus, etiquetas del calendario **y los meses que se repiten en la fila-título de cada sección** (filas 7/32/57/81 — ver §4.0).

### Pregunta 4b: Idioma de los Entregables (convención a elicitar)
"En un plan en **inglés**, confirmo que **traduzco también los nombres de los Entregables** al inglés (la trazabilidad la mantiene el hipervínculo a ClickUp), ¿o prefieres dejarlos tal cual en ClickUp?"
→ **Por defecto en planes EN, SÍ se traduce todo**: cabeceras, estatus, etiquetas del calendario, etiquetas de la portada, meses de cada sección **y los nombres de Entregables**. La **trazabilidad no se pierde**: el nombre traducido va sobre un **HYPERLINK al `task_id`** de ClickUp (col F de 41#). Solo si el PO lo pide → dejar los nombres tal cual en ClickUp. Guardar la elección.

### Pregunta 5: Granularidad del calendario
"¿Cómo quieres organizar el calendario de entregas?"
- **Por quincenas** (recomendado para la mayoría de proyectos)
- **Por semanas** (para proyectos intensivos con sprints cortos)
- **Por meses** (para proyectos largos o de mantenimiento)

### Pregunta 6: Alcance histórico
"¿El plan de proyecto debe incluir **todos los productos** (histórico completo del proyecto, incluyendo los ya completados) o solo los **productos activos y pendientes** (en curso o por hacer)?"

→ Histórico completo: útil para proyectos en curso avanzados o cuando el cliente quiere visibilidad del trabajo ya entregado. Los productos TERMINADO/CERRADO se incluyen con su estatus correspondiente.
→ Solo activos y pendientes: más limpio y operativo, recomendado para proyectos en fase inicial o cuando el plan se usa como herramienta de seguimiento hacia adelante.
→ Guardar la elección. En modo ACTUALIZACIÓN: mantener la misma elección salvo que el PO indique lo contrario.

### Pregunta 7: Formato de la columna Descripción
> **Por defecto, cada celda de Descripción lleva los DOS formatos combinados** (convención Reinicia): **Historia de usuario** ("Como [rol], quiero…, para…") + **salto de párrafo** + **Resumen ejecutivo** (lenguaje natural, sin jerga). En planes EN, ambos en inglés.
"Uso la convención por defecto (Historia de usuario **+** Resumen ejecutivo en cada celda), ¿o prefieres solo uno de los dos para este cliente?"
- Solo si el PO lo pide → **Historia de usuario** sola (cliente con madurez ágil) o **Resumen ejecutivo** solo (cliente con menor madurez digital).

→ Guardar la preferencia. Se aplicará de forma consistente a todos los productos.
→ En modo ACTUALIZACIÓN: preguntar si se mantiene el formato anterior o se cambia.

### Pregunta 8: Datos de portada
"Para la portada necesito confirmar: URL del cliente, país/es donde opera, y PO de Reinicia asignado."
→ Claude puede prerellenar desde lo que ya sabe del cliente. El PO confirma o corrige.

---

## PASO 1B — ELICITACIÓN (modo ACTUALIZACIÓN)

### Pregunta 1: Cliente y fichero
"¿Para qué cliente actualizamos el plan? ¿Sabes el nombre o ID del fichero en Workdrive?"
→ Si no lo sabe: buscar con `ZohoWorkdrive_searchTeamFoldersFiles` + nombre cliente + "Plan-Proyecto".
→ El PO confirma cuál es el fichero correcto antes de continuar.

### Pregunta 2: Lista en ClickUp
"¿El ID de la lista `General [CLIENTE]` en ClickUp sigue siendo el mismo, o ha cambiado?"

---

## PASO 2 — CONFIRMACIÓN DE ESTRUCTURA CON EL PO

Antes de leer ClickUp, Claude recuerda al PO el contexto de esta skill:

> "El Plan de Proyecto refleja fielmente lo que ya está en `General [CLIENTE]` en ClickUp.
> Asumo que el backlog ya está construido y validado contigo usando las skills de productos
> digitales. Si hay productos pendientes de crear o ajustar en ClickUp, hazlo primero y
> después generamos el plan.
>
> ¿Confirmas que el backlog de ClickUp está listo para volcar al plan?"

→ Si el PO dice que no está listo: pausar y recordarle las skills de backlog disponibles
  (productos-digitales-zoho-clickup-reinicia, productos-digitales-web-clickup-reinicia,
  productos-digitales-waba-clickup-reinicia).
→ Si el PO confirma: continuar al Paso 3.

> ✅ **Checklist obligatoria antes de escribir en Workdrive (modo CREACIÓN).** Antes de tocar el fichero, Claude confirma que ha leído **ANEXO A + ANEXO B + §6/§7/§8/§9 + «4.0 ESTRUCTURA CANÓNICA DEL PLAN v2»**. **Si no los ha leído, para y los lee** antes de continuar. La creación se hace copiando la plantilla `pnync351…` con `ZohoSheet_copy` (nunca `createNativeDocument`/`Create_New_File`/`create_workbook`).

> 🔁 **Convención de volcado por defecto (proyectos grandes).** El volcado se hace en **dos fases**: primero la **estructura** (copiar plantilla, portada, Config, Log, cabeceras, filas vacías insertadas donde haga falta) y después el **contenido** (PBI · Descripción · Notas · fechas · estatus · calendario), tarjeta a tarjeta y en tandas reanudables. Es el modo por defecto salvo que el PO indique lo contrario.

---

## PASO 3 — LECTURA DE DATOS EN CLICKUP

Con el list_id confirmado, Claude lee todos los productos:

```
clickup_filter_tasks(list_id=..., include_closed=true)
```

Para cada tarea extraer:
- `name` → Entregable
- `url` → URL ClickUp
- `description` → fuente para columna Descripción (ver procesamiento abajo)
- `due_date` → Fecha estimada de entrega
- `status.status` → mapear a estatus estándar (ver tabla de mapeo abajo)
- subtareas → fuente para columna Notas (ver procesamiento abajo)
- comentarios → fuente adicional para columna Notas (ver procesamiento abajo)
- custom_fields:
  - ÉPICA → `6e3bf4c0-354b-4a8c-8cb5-dbedeec1cf6e`
  - PBIs PRIMER NIVEL → `6758065a-bd4f-4d7d-9a48-926e81fe343f`
  - TIPO DE PRODUCTO → `5bd9072e-deae-4352-b35b-bdbaa3cc216d`
  - ORDEN → `a2fac0a6-0f12-4c9b-9f2f-c5bbc2aa7a98`

**Nota:** si la lista tiene custom field IDs diferentes (cliente distinto de Carritech),
verificar con `clickup_get_custom_fields(list_id=...)` antes de extraer.

### Procesamiento de la columna Descripción

Por defecto (convención Reinicia), **producir los DOS bloques en la misma celda**, separados por salto de párrafo:

**Bloque 1 — Historia de usuario:**
Extraer de la descripción de la tarea el bloque que empieza por "Como" / "As a".
Si no existe explícitamente, construirla a partir del campo `description` de ClickUp.
Formato: "Como [rol], quiero [qué], para [para qué]." Máx. 2 líneas.

**Bloque 2 — Resumen ejecutivo (debajo, tras salto de párrafo):**
Extraer el objetivo principal del producto desde el campo `description` de ClickUp
(sección de descripción, no comentarios). Redactar en lenguaje natural, sin términos
de Scrum. Máx. 2 líneas. Si la descripción es muy técnica, simplificar para que
sea comprensible por un interlocutor no técnico del lado del cliente.

> Solo si el PO pidió en la Pregunta 7 **un único formato**, escribir ese bloque solo. En planes EN, ambos bloques en inglés.

### Procesamiento de la columna Notas

La columna Notas no es un campo libre genérico — contiene un **estatus breve y operativo**
del producto, con énfasis en riesgos. Se construye en dos pasos:

**Paso A — Leer subtareas:** `clickup_get_task(task_id=..., include_subtasks=true)`
Calcular el ratio de subtareas completadas vs. total. Ej: "3/5 subtareas completadas".
Identificar subtareas bloqueadas o con fecha vencida sin completar → posible riesgo.

**Paso B — Leer comentarios y sus hilos:** 
- `clickup_get_task_comments(task_id=...)`
- `clickup_get_threaded_comments(comment_id=...)` para cada comentario con respuestas
Extraer información relevante sobre el estado actual: bloqueos mencionados, dependencias
pendientes, validaciones en curso, decisiones tomadas recientemente.

**Paso C — Leer checklist de criterios de aceptación:**
Buscar en la tarea el checklist denominado "CRITERIOS DE ACEPTACIÓN" (o "ACCEPTANCE CRITERIA"
en proyectos en inglés, o checklist equivalente en proyectos de marketing/microcampañas).
Calcular el ratio de criterios marcados vs. total. Ej: "5/8 criterios cumplidos".
Identificar criterios no cumplidos que puedan ser bloqueantes para la entrega.

**Formato de la celda Notas** (máx. 3 líneas):
```
[ratio subtareas] · [ratio criterios] · [estatus operativo en 1 frase]
⚠️ [riesgo si existe] — [detalle breve]
```

Ejemplos:
- `4/4 subtareas · 6/6 criterios · Validación cliente en curso`
- `2/5 subtareas · 3/8 criterios · Pendiente acceso al entorno de staging`\n`⚠️ Sin acceso desde hace 2 semanas — posible retraso`
- `0/3 subtareas · sin criterios definidos aún · No iniciado`

Si no hay checklist de criterios: omitir ese ratio y no mencionar su ausencia
salvo que el producto esté EN PROCESO o en fase de validación, en cuyo caso
sí alertar: `⚠️ Criterios de aceptación no definidos — riesgo para la validación`.

### Tabla de mapeo de estatus ClickUp → Plan de Proyecto

| ClickUp status | ES | EN |
|---|---|---|
| to do / open / **sprint backlog** / product backlog | PENDIENTE | PENDING |
| in progress / en curso / **validación reinicia / validación cliente** | EN PROCESO | IN PROGRESS |
| complete / done / closed (**done sin cierre = terminado**) | TERMINADO | COMPLETED |
| on hold / blocked / pospuesto | POSPUESTO | ON HOLD |
| **parking / parking e incidencias** | **PARKING** | **PARKING** |
| **cancelado / descartado** | **CANCELADO** | **CANCELLED** |

> Las fases de **validación** (reinicia/cliente) cuentan como **EN PROCESO / IN PROGRESS**. **`parking e incidencias` → PARKING** (no POSPUESTO). Estos valores se escriben tal cual en el desplegable de Estatus (la interfaz colorea sola).

### Composición del tipo de proyecto (para nomenclatura del fichero)
Inspeccionar el campo TIPO DE PRODUCTO de todas las tareas y componer el tipo combinado:
- CRM → `Zoho`
- DESARROLLO WEB (WordPress/Drupal) → `Web`
- DESARROLLO WEB (framework JS) → `WebApp`
- WhatsApp / WABA → `WABA`
- EMAIL MARKETING / MARKETING AUTOMÁTICO / ESTRATEGIA → `MKT`

Si hay más de un tipo, combinarlos por orden de volumen: ej. `Zoho-Web`, `Zoho-WABA-MKT`.

### Formación Interna — FUERA del Plan (excluir)
Los productos de **«Formación interna»** (formación del propio equipo de Reinicia, no del cliente) **NO figuran en el Plan** — ni en 40# ni en 41#. Para ellos:
- **NO** se escribe Descripción ni se hace write-back de PBI a ClickUp.
- Se **excluye/borra** su fila del Plan.
- ⚠️ El **borrado de fila es operación de ESTRUCTURA**: hacerlo al **FINAL de la fase de contenido** (para no romper referencias de fila mientras se vuelca), y **después comprobar/repintar el calendario y el Gantt** por el desplazamiento.

### Soporte Cerrado — tratamiento ligero (por lotes)
Para las tarjetas de **Soporte Cerrado** (tabla SOPORTE CERRADO), no se lee tarjeta a tarjeta:
- **Descripción de UNA sola línea** derivada del **Deliverable + Épica + PBI** (o **vacía** si la tarjeta es una duda/consulta sin entregable real).
- Procesar en **lotes grandes** con **visto bueno rápido del PO**, sin abrir cada tarjeta.
- El **write-back de PBI** (cuando falta en ClickUp) se hace **igual que en el resto** de tablas.

---

## PASO 4 — MODO CREACIÓN: CONSTRUIR EL DOCUMENTO (por copia de la plantilla v2)

### 4.0 ESTRUCTURA CANÓNICA DEL PLAN v2

> Esta es la estructura **real** del fichero que se obtiene al copiar la plantilla `pnync351…`. Prevalece sobre cualquier descripción anterior del cuerpo. La creación NO construye pestañas a mano: **copia la plantilla** y **puebla** lo que viene vacío (Config y Log de Cambios) + el contenido.

**Pestañas canónicas (worksheet_id reales):**
`36#` **Portada** · `40#` **Plan Proyecto** (cara cliente) · `41#` **Plan Proyecto Interno** · `42#` **Ideas** · `45#` **Objetivos Cliente** (solo lectura, priorización de Ideas) · `43#` **Log de Cambios** (solo añadir) · `44#` **Config**.

**Cuatro secciones dentro de 40# y 41#** (una tabla cada una; **cada una se reconcilia contra una lista distinta de ClickUp** — NO todo sale de General):

| Sección / Tabla | Fuente ClickUp | Filtro | Fila-título (meses) |
|---|---|---|---|
| **PLAN IMPLANTACIÓN** | `General [CLIENTE]` | productos digitales / SPIKEs | **fila 7** |
| **PLAN SOPORTE ACTIVO** | `Soporte [CLIENTE]` | tareas **no cerradas** | **fila 32** |
| **PLAN SOPORTE CERRADO** | `Soporte [CLIENTE]` | tareas **cerradas en el año del Plan** | **fila 57** |
| **RESUMEN HISTÓRICO** (rollup de años anteriores) | agregado interno | 2 filas: **Implementation / Support** | **fila 81** |

- Cabecera de cada tabla (nombres de columna / nº de semana) en la fila **inmediatamente posterior** a su fila-título (la 1ª sección: leyenda de hitos en filas 3–5, meses en fila 7, cabecera en fila 8, datos desde fila 9).
- **Los meses se repiten en la fila-título de CADA sección (7 / 32 / 57 / 81).** En planes **EN**, traducirlos **por sección** (no basta con traducir la primera).

**⚠️ MAPA DE COLUMNAS — LAS DOS PESTAÑAS DIFIEREN (leer la cabecera por pestaña, NUNCA hardcodear).** La columna **`Fecha de petición` (H = col 8)** es **nueva** y desplaza +1 todo lo que venía a partir de ella:

**`40#` Plan Proyecto (cara cliente):**
| col | letra | Campo |
|---|---|---|
| 2 | B | Épica (modelo híbrido: microcampaña→fase de funnel; producto digital→objetivo de negocio con prefijo numérico) |
| 3 | C | Tipo de Producto |
| 4 | D | Mes (= mes de la Fecha de entrega, col I; recomputar al cambiar la fecha) |
| 5 | E | PBI de Primer Nivel |
| 6 | F | Entregable (con hyperlink a la tarjeta de ClickUp) |
| 7 | G | Descripción |
| 8 | **H** | **Fecha de petición** (`date_created`) — **columna NUEVA** |
| 9 | I | Fecha de entrega esperada (`due_date`) |
| 10 | J | Fecha de validación esperada (↕ **Sheet ↔ ClickUp, bidireccional**; rellenar el lado vacío desde el otro, **nunca pisar** el valor puesto por el Cliente) |
| 11 | K | Notas Reinicia |
| 12 | L | Notas [Cliente] (🔼 Sheet → ClickUp; nunca pisar) |
| 13 | **M** | **Estatus** (desplegable; color automático) |
| 14–37 | **N–AK** | Calendario — 24 quincenas · **col = 13 + quincena** |

**`41#` Plan Proyecto Interno** (igual hasta col I; luego CAMBIA):
| col | letra | Campo |
|---|---|---|
| 2–9 | B–I | igual que 40# (incluye **H = Fecha de petición**) |
| 10 | J | Fecha de validación esperada (↕ **Sheet ↔ ClickUp, bidireccional**; rellenar el lado vacío desde el otro, **nunca pisar** el valor puesto por el Cliente) |
| 11 | **K** | Notas (una sola) |
| 12 | **L** | **Estatus** (desplegable; color automático) |
| 13–36 | **M–AJ** | Calendario — 24 quincenas · **col = 12 + quincena** |

> **quincena = (mes − 1)·2 + (1 si día ≤ 15; 2 si día > 15).** Resolver Estatus y calendario **por el nombre leído en la cabecera de cada pestaña**, no por letra fija — **cruzando la cabecera contra una fila de datos ya poblada para confirmar la columna** (así se evita el error K/L del piloto LS, donde se escribió Estatus en K en vez de L). `41#` no tiene «Notas [Cliente]».

**Portada (`36#`) — celdas reales:**
- `C3` = **título** ("Calendario de entregas [CLIENTE]" / "[CLIENTE] Project Calendar").
- `D5` = `=HYPERLINK("<web real del cliente>";"<Nombre Cliente>")` — **semicolon (es-ES), `https`**. Corregir el residuo de plantilla en `E5:G5` (tipo **`ackstorm`**) → limpiarlo/rehacerlo.
- **Etiquetas ya presentes en `C6`–`C10`** = Idioma · País · Equipo · PO Cliente · PO Técnico. **Escribir los VALORES en `D6`–`D10`**, sobrescribiendo los placeholders de la plantilla (`Español`/`España`/`Columbia o Proactive u otro`/`Nombre y Apellidos`). En planes EN, traducir también las etiquetas de la col C.
- En planes **EN**, traducir también las **etiquetas** de la portada.

**Config (`44#`) — 3 columnas (viene VACÍA → construirla):**
- Cabeceras: **Parámetro | Valor | ID/Resource**. El **ID/Resource va en la col D** (ancho ~**400**).
- La skill **lee el ID de su columna (col D)**, nunca lo parsea de un texto "Nombre (ID)".
- Campos: Lista ClickUp General · Soporte · Gestión · Carpeta ClickUp · Space ClickUp · Carpeta Workdrive (Plan) · Resource ID (fichero).
- Estilo canónico: cabecera `fill #3812CF`/fuente blanca negrita; datos `fill #EBEBEB`/`#545454`; **bordes blancos `#FFFFFF`**; Manrope. Lavado base blanco fuera de la tabla.

**Log de Cambios (`43#`) — 3 columnas (viene VACÍO → construirlo):**
- Cabeceras: **Fecha | Autor | Cambio** + **bordes blancos perimetrales**.
- Estilo: cabecera `#3812CF`/blanca; filas de datos `fill #EBEBEB`/`#545454`, bordes blancos, Manrope, altura ~48, wrap. Solo se **añade** al final (nunca modificar entradas previas).

**Estatus = campo DESPLEGABLE con color por valor.**
> ⚠️ **Vía API NO se pueden manipular desplegables ni fijar su color.** La API **solo escribe el VALOR** del estado y la **interfaz le asigna el color automáticamente**. **PARKING, CANCELADO y el resto de estados se colorean solos** al escribir su valor exacto en el desplegable. **Nunca** definir colores de estado ni pintar el color del Estatus a mano. El desplegable **ya viene en la plantilla**: no hay que crearlo.

**Sello de última actualización — celda `C3` de AMBAS pestañas** (ambas traen "Fecha actualización:" en B3 con placeholder `DD/MM/AAAA`):
- **`40#` (pública):** solo fecha → **`DD/MM/YYYY`**.
- **`41#` (Interno):** fecha + hora → **`DD/MM/YYYY HH:MM`** (24h).
- **Reescribir al crear el Plan y en CADA actualización.**

**Años anteriores (alcance «histórico completo»):**
- Los productos de **años previos** van **individuales, con su fecha real**, y el **calendario del año en blanco** (no se marca el Gantt del año en curso con fechas de otro año).
- El **RESUMEN HISTÓRICO (fila 81)** es el que **agrega** esos años previos en 2 filas (Implementation / Support).
- **Cerrados sin `due_date`** → **usar `date_closed` como fecha de entrega (proxy, decisión B):** col 9 = `date_closed` en `DD/MM/YYYY` **y marcar el calendario** en esa quincena con el color de entrega `#70EED6`. En un item cerrado, la fecha de cierre es un proxy justo de cuándo se resolvió. (`date_closed` sigue atribuyendo además el año de la tabla.) Solo si **tampoco** hay `date_closed` (raro) → Entrega `"-"` y calendario en blanco.

### 4.1 Nomenclatura del fichero
```
[AÑO]-Plan-Proyecto-[TIPO]-[CLIENTE EN MAYÚSCULAS]-INTERNOIA
```
Ejemplos:
- `2026-Plan-Proyecto-Web-HOMEESPANA-INTERNOIA`
- `2026-Plan-Proyecto-Zoho-CARRITECH-INTERNOIA`
- `2026-Plan-Proyecto-Zoho-Web-WABA-GONHER-INTERNOIA`

El sufijo `-INTERNOIA` identifica que es el documento de trabajo interno. Siempre presente.
El renombrado debe hacerse manualmente desde Workdrive — ver paso 3.7.

> ⛔ **SUPERADO — los antiguos pasos 3.2–3.7 quedan reescritos aquí según el ANEXO B.** Ya NO se crea el fichero con `createNativeDocument` ni una estructura simple Portada/Plan/Log de 1 pestaña. Se **copia la plantilla canónica v2** (que ya trae las 4 secciones, el desplegable de Estatus, el logo y las 3 filas superiores) y solo se **puebla** lo que viene vacío (Config, Log) + el contenido. La estructura de referencia es **§4.0**.

### 4.2 Crear el fichero copiando la plantilla v2

**Copiar SIEMPRE la plantilla canónica** `pnync351d56992b6d4026906a6fec5d56e682` con `ZohoSheet_copy` hacia la carpeta `Plan de Proyecto` del cliente. **Nunca** `createNativeDocument` / `Create_New_File` / `create_workbook` (crean ficheros corruptos / de 1 pestaña).

Guardar el `resource_id` del fichero resultante para todas las operaciones siguientes.

⚠️ **Inmediatamente después de copiar**, verificar el estado del fichero con `ZohoWorkdrive_searchTeamFoldersFiles` (por nombre). Si `status` = `4` (papelera), restaurarlo con `ZohoSheet_restore`. Confirmar además que el `resource_id` **no contiene `%3A`/`%2F`** (URL-encoding roto).

### 4.3 Rellenar la Portada (`36#`)
Rellenar según **§4.0**:
- `C3` = **título** → sustituir el marcador `[NOMBRE CLIENTE]` por el cliente real ("Calendario de entregas <Cliente>").
- `D5` = `=HYPERLINK("<web real>";"<Nombre Cliente>")` (semicolon es-ES, `https`) — esto **reemplaza** el hyperlink `ackstorm` de la plantilla. Además **limpiar el residuo `ackstorm` desparramado en `E5:G5`** (borrar contenido y URL).
- **Las etiquetas ya vienen en `C6`–`C10`** (Idioma / País / Equipo / PO Cliente / PO Técnico). **Los VALORES se escriben en `D6`–`D10`**, sobrescribiendo los placeholders de ejemplo de la plantilla (`Español` · `España` · `Columbia o Proactive u otro` · `Nombre y Apellidos` · `Nombre y Apellidos`). En planes **EN**, traducir también las etiquetas de la col C.

Usar `ZohoSheet_set_content_to_multiple_cells` (lotes ≤40).

### 4.4 Poblar las 4 tablas (40# y 41#)
- La plantilla ya trae las cabeceras, el banding, la base gris del calendario y el desplegable de Estatus. **No** reconstruir la estructura: **insertar filas** donde falte espacio (§8) y **pegar el contenido** según el **mapa de columnas de §4.0** (¡difieren 40# y 41#!).
- **Renombrar el header de la col 12 en `40#` (fila 8)** de `Notas Nombre Cliente` a `Notas <Cliente real>` (p. ej. `Notas Líder System`). En las 4 filas-cabecera de sección (8/33/58/82) que repitan ese placeholder, ídem.
- **Estatus:** escribir **solo el valor exacto** del desplegable; **el color sale solo** (no pintar nada — ver §4.0 y punto de desplegable).
- **Calendario:** la plantilla **ya trae el calendario formateado**. **NO repintar la base** — las filas que insertes **heredan** el gris de la fila de arriba. Pintar **solo los hitos** encima (entrega `#70EED6`, validación `#EBE31B`), en la celda de la `quincena = (mes−1)·2 + (1 si día ≤ 15; 2 si >15)`. (No fijar `#F2F2F2` a mano: evita descuadres si el gris real de la plantilla fuese otro.)
- **Orden / agrupación de Épica / redibujado de calendario van SIEMPRE juntos** (ver ANEXO B B.5/B.7).
- **Regla de oro (ANEXO B B.1):** al escribir/insertar cualquier celda, aplicar SIEMPRE su estilo canónico; el API **no lee** formato.

### 4.5 Construir la Config (`44#`) — viene VACÍA
3 columnas **Parámetro | Valor | ID/Resource** (ID en **col D**, ancho ~400). La skill lee el ID de la col D. Estilo canónico (ver §4.0). Rellenar los 7 campos (Listas General/Soporte/Gestión · Carpeta ClickUp · Space ClickUp · Carpeta Workdrive Plan · Resource ID del fichero).

### 4.6 Construir el Log de Cambios (`43#`) — viene VACÍO
3 columnas **Fecha | Autor | Cambio** + **bordes blancos perimetrales**. **Estilo canónico completo de las filas de datos (7 atributos):** fill `#EBEBEB` · `font_color #545454` · **bordes blancos** · **Manrope** · `row_height ~48` · `wrap_text` · `vertical_alignment middle`. Aplicar SIEMPRE los 7 al escribir (la API no lee formato → si se omite alguno, la fila queda descuadrada). Solo se **añade** al final.

### 4.7 Sello de última actualización (`C3` de ambas pestañas)
Escribir la fecha/hora de ahora en **`C3`**, sobrescribiendo el placeholder `DD/MM/AAAA`: **`40#` (pública) solo fecha `DD/MM/YYYY`**; **`41#` (Interno) fecha + hora `DD/MM/YYYY HH:MM`** (24h). Reescribir al crear y en cada actualización.

### 4.8 Ajuste manual único (no automatizable vía MCP)
- **Renombrado del fichero:** el MCP no puede renombrar ficheros Zoho Sheet. Hacerlo manualmente desde Workdrive (clic derecho → Renombrar) con la nomenclatura de §4.1.
- El resto de ajustes que antes eran manuales (**3 filas superiores, logotipo, desplegable de Estatus**) **ya vienen en la plantilla v2** — no hay que rehacerlos.

---

## PASO 5 — MODO ACTUALIZACIÓN: DETECTAR Y APLICAR CAMBIOS

### 5.1 Leer el estado actual del Plan de Proyecto

```
ZohoSheet_get_content_of_worksheet(resource_id=..., worksheet_name="General",
  response_type="array", major_dimension="rows")
```

Construir un mapa interno: `nombre_entregable → {fila, estatus_actual, fecha_actual}`

### 5.2 Comparar con ClickUp

Para cada producto de ClickUp, comparar contra el mapa del sheet y detectar:

| Tipo de diferencia | Acción propuesta |
|---|---|
| Producto en ClickUp no existe en el sheet | Añadir nueva fila |
| Estatus cambió | Actualizar celda de estatus |
| Due_date cambió | Actualizar fecha + recalcular marca en calendario |
| Producto en sheet no existe en ClickUp | Alertar al PO (¿eliminado del backlog?) |

### 5.3 Presentar las diferencias al PO

Antes de tocar nada, Claude presenta un resumen:

```
📊 DIFERENCIAS DETECTADAS — [CLIENTE]
Fecha de revisión: [fecha actual]

🆕 Productos nuevos en ClickUp (no están en el plan):
  - [Nombre producto] → propuesta: añadir en fila [N]

🔄 Cambios de estatus:
  - [Nombre producto]: PENDIENTE → EN PROCESO
  - [Nombre producto]: EN PROCESO → TERMINADO

📅 Cambios de fecha:
  - [Nombre producto]: [fecha anterior] → [nueva fecha] ⚠️ RETRASO

⚠️ Productos en el plan que ya no están en ClickUp:
  - [Nombre producto] → ¿confirmas que se ha eliminado del alcance?

¿Aplico todos estos cambios? ¿O quieres revisar/excluir alguno?
```

### 5.4 Aplicar cambios confirmados

Una vez el PO confirma:
1. Actualizar celdas de estatus y fecha con `ZohoSheet_set_content_to_multiple_cells`
2. Añadir nuevas filas con `ZohoSheet_addrecords` o `ZohoSheet_set_content_to_multiple_cells`
3. Recalcular marcas del calendario para las filas modificadas

### 5.5 Proponer entradas para el Log de Cambios

Para cada cambio relevante (retrasos, adelantos, productos añadidos/eliminados),
proponer la fila correspondiente en el Log. **El Log v2 tiene 3 columnas: `Fecha | Autor | Cambio`** (§4.0) — el detalle del cambio va condensado en la columna **Cambio**:

```
📝 ENTRADAS SUGERIDAS PARA EL LOG DE CAMBIOS (Fecha | Autor | Cambio):

| Fecha | Autor | Cambio |
|---|---|---|
| [hoy] | [PO] | Retraso en entrega — [producto]: [fecha ant.] → [fecha nueva] |
| [hoy] | [PO] | Producto añadido — [producto], incorporado al alcance en Sprint [N] |

¿Las añado al Log, o quieres modificar algo primero?
```

---

## PASO 6 — CONFIRMACIÓN FINAL

```
✅ PLAN DE PROYECTO [MODO] — [CLIENTE]

Fichero: [nombre del fichero]
Ubicación en Workdrive: [carpeta]
URL de acceso: [si disponible]

Contenido:
  - [N] productos incluidos
  - Calendario: [granularidad] — [mes inicio] a [mes fin]
  - Estatus: [N] PENDIENTE / [N] EN PROCESO / [N] TERMINADO / [N] POSPUESTO

⚠️ Pendiente de completar manualmente:
  - Columna "Notas" — campo libre para el PO
  - Marcas del calendario para productos sin fecha de entrega definida
  - [Si actualización] Log de Cambios — confirmar entradas sugeridas

⚠️ Recordatorio ajustes manuales (aplica siempre):
  - La lista de selección del campo Estatus (columna I) cubre el rango I2:I200.
    Si se han añadido filas nuevas en esta actualización, verifica que la lista
    de selección las cubre correctamente — debería ser automático si se configuró
    con el rango amplio al crear el fichero.
  - Si el fichero es nuevo, recuerda aplicar los 4 ajustes manuales post-creación:
    3 filas superiores · logotipo · lista de selección I2:I200 · renombrado INTERNOIA
```

---

## NOTAS IMPORTANTES

- **Limitaciones técnicas Zoho Sheet API (validadas en vivo):**
  - `cells.content.set` / `set_content_to_multiple_cells`: **≤ 40 celdas por llamada** (63 celdas devolvió **error 400**). Trocear en lotes de ≤40.
  - Fórmulas **`HYPERLINK`**: escribir en **lotes pequeños** (un lote grande de fórmulas devuelve **error 400**).
  - **`insert_row` inserta 1 fila por llamada** → para N filas, N llamadas. **Verificar el recuento con una lectura** tras insertar (una vez salieron **17 filas en vez de 18**).
  - Tamaño de petición HTTP limitado: mantener descripciones y notas bajo ~200 caracteres por celda.
  - Vaciar celda con `" "` (espacio), **nunca `""`**. Decimales con coma (es-ES).
  - Tras **copiar** la plantilla, verificar su `status` inmediatamente: si devuelve `4` está en papelera (ocurre cuando el MCP crea/copia el fichero con una cuenta distinta al propietario del workspace). Usar `ZohoSheet_restore` para recuperarlo antes de continuar.
- **Productos eliminados o movidos en ClickUp:** si un producto aparece en el plan pero ya no existe en `General [CLIENTE]` (porque fue borrado o movido a otra lista), la skill **nunca borra la fila automáticamente**. En su lugar propone al PO marcarlo como `CANCELADO` y añade una entrada al Log indicando que el producto ya no está en el backlog activo — con la nota de que puede ser una cancelación real o un movimiento de lista. El PO confirma antes de aplicar cualquier cambio.
- **Mecanismo de roll-back:** la skill no implementa deshacer programático. Hay dos mecanismos nativos disponibles: (1) **Historial de versiones de Zoho Sheet** (Archivo → Historial de versiones) para restaurar el fichero completo a cualquier punto anterior — es el roll-back más robusto; (2) **Log de Cambios** como referencia para reversiones quirúrgicas de un cambio concreto — la skill puede leer el Log y revertir manualmente ese valor específico si el PO lo solicita.
- **Prerequisito obligatorio:** el backlog de ClickUp debe estar construido y validado
  con el PO antes de generar el Plan de Proyecto. Esta skill es siempre posterior a las
  skills de productos digitales (Zoho, Web, WebApp, WABA). Si el backlog no está listo,
  pausar y redirigir al PO a la skill correspondiente.
- **La estructura no se propone aquí:** Épicas, PBIs de primer nivel, orden de productos
  y tipos ya están definidos en ClickUp. Esta skill los lee y los refleja fielmente, sin
  sugerir cambios de estructura ni de contenido del backlog.
- **El PO confirma siempre antes de crear o modificar:** en CREACIÓN, confirmar nombre
  del fichero; en ACTUALIZACIÓN, confirmar el listado de cambios detectados.
- **Orden de filas:** ordenar por campo ORDEN de ClickUp si está asignado; si no,
  agrupar por ÉPICA y dentro de cada épica por TIPO DE PRODUCTO.
- **Productos sin due_date:** incluirlos igualmente en el plan con "A definir" en la
  columna de fecha. No omitir ningún producto del backlog.
- **Columna Descripción:** por defecto **ambos formatos combinados** (Historia de usuario + Resumen ejecutivo en la misma celda); el PO puede pedir uno solo. Se aplica de forma consistente
  a todos los productos. En modo ACTUALIZACIÓN, verificar si el PO quiere mantener el
  formato o cambiarlo.
- **Columna Notas:** no es un campo libre — es un estatus operativo breve construido a
  partir de tres fuentes: (1) subtareas — ratio completadas/total y bloqueadas; (2) checklist
  de criterios de aceptación ("CRITERIOS DE ACEPTACIÓN" / "ACCEPTANCE CRITERIA" o equivalente
  en proyectos de marketing) — ratio cumplidos/total, con alerta si están ausentes en productos
  EN PROCESO; (3) comentarios e hilos (`clickup_get_threaded_comments`) — bloqueos, dependencias
  y validaciones en curso. Siempre resaltar riesgos con ⚠️. Máx. 3 líneas por producto.
- **Subtareas:** no incluir subtareas como filas del plan, solo tareas principales de
  `General [CLIENTE]`. Las subtareas se usan únicamente como fuente para la columna Notas.
- **Idioma coherente:** todos los textos del documento (cabeceras, estatus, log) deben
  estar en el idioma elegido en la elicitación. No mezclar.
- **Granularidad del calendario:** puede cambiar en cada actualización si el PO lo pide.
  En ese caso, reconstruir todas las columnas de calendario antes de marcar.
- **Log de Cambios:** nunca modificar entradas ya existentes — solo añadir al final.
- **Tipos de producto combinados:** si un cliente tiene productos de varios tipos,
  el nombre del fichero los combina por orden de volumen (el tipo con más productos, primero).
- **Custom field IDs:** los IDs de la skill están validados para la lista General Carritech.
  Para otros clientes, verificar siempre con `clickup_get_custom_fields(list_id=...)`.
- **Pestañas específicas de la plantilla** (ej. "Entregas APP Creator", "Formulario Camps"):
  son pestañas específicas de proyectos concretos. No incluirlas en documentos nuevos
  salvo que el PO lo indique explícitamente para un proyecto con ese tipo de entregables.

---

## PASO 7 — TRAZABILIDAD EN CLICKUP

Tras completar la creación o actualización del plan, Claude busca el producto correspondiente en `Gestión [CLIENTE]` y deja constancia del trabajo realizado.

### 7.1 Buscar el producto en Gestión [CLIENTE]

```
clickup_search(keywords="Plan de Proyecto [AÑO] [CLIENTE]",
  filters={location: {subcategories: [ID_LISTA_GESTION]}})
```

→ Si existe: localizar el producto y proceder al paso 7.2.
→ Si no existe: informar al PO y preguntar si quiere crearlo.

```
⚠️ No encuentro el producto "Plan de Proyecto [AÑO] [CLIENTE]" en la lista
Gestión [CLIENTE]. ¿Quieres que lo cree ahora?

Nota: este producto debería haberse creado previamente usando la skill de
productos digitales correspondiente (Zoho, Web o WABA). Si aún no existe,
puedo crearlo ahora con los campos básicos, pero te recomiendo revisarlo
después con la skill adecuada para completar su contenido.
```

→ Si el PO confirma la creación: usar `clickup_create_task` en la lista
  `Gestión [CLIENTE]` con nombre `Plan de Proyecto [AÑO] [CLIENTE]`,
  campo PROYECTO = [CLIENTE], PO = [PO asignado].
→ Si el PO rechaza: omitir el comentario y finalizar.

### 7.2 Proponer el comentario al PO antes de publicarlo

Presentar el borrador del comentario para confirmación:

```
💬 BORRADOR DE COMENTARIO EN CLICKUP — Plan de Proyecto [AÑO] [CLIENTE]

📊 Plan de Proyecto [creado / actualizado] — [FECHA]

[🔄 Cambios de estatus: [N]  ← omitir bloque si N=0]
  - [Producto]: [estado anterior] → [estado nuevo]

[📅 Cambios de fecha: [N]  ← omitir bloque si N=0]
  - [Producto]: [fecha anterior] → [fecha nueva]

[🆕 Productos añadidos: [N]  ← omitir bloque si N=0]
  - [Producto] · [Estatus] · [Fecha prevista]

📁 Plan de Proyecto en Workdrive:
  [permalink del fichero Zoho Sheet]

¿Publico este comentario en ClickUp?
```

### 7.3 Publicar el comentario

Una vez confirmado por el PO:

```
clickup_create_task_comment(task_id=..., comment_text=...)
```

El permalink del fichero tiene este formato:
`https://sheet.zoho.eu/sheet/open/[resource_id]`

---

| Recurso | ID |
|---|---|
| Team Workdrive Reinicia | `2km7j4dc468f82ead4a8489e55b64bfd3ecfe` |
| **Plantilla canónica v2 (Recursos Comunes)** | **`pnync351d56992b6d4026906a6fec5d56e682`** |
| ⛔ Plantilla antigua (OBSOLETA — 1 pestaña, residuos MKT; NO usar) | ~~`47q3o1a477a21d2f848d28c957304f083b0b6`~~ |
| Ejemplo Birdease (Web, EN) | `hpgmh7de8cab0fd9e4fb58b51298dee7cb465` |
| Ejemplo Mazarea (Zoho, ES) | `halr9080af8d0477045b3a9c56babd3aff12c` |
| General Carritech (ClickUp) | `901207893908` |
| Gestión Gonher (ClickUp) | `901205582846` |
| Gestión Avaderm (ClickUp) | `901202330083` |
| ÉPICA (custom field ID) | `6e3bf4c0-354b-4a8c-8cb5-dbedeec1cf6e` |
| PBIs PRIMER NIVEL (custom field ID) | `6758065a-bd4f-4d7d-9a48-926e81fe343f` |
| TIPO DE PRODUCTO (custom field ID) | `5bd9072e-deae-4352-b35b-bdbaa3cc216d` |
| ORDEN (custom field ID) | `a2fac0a6-0f12-4c9b-9f2f-c5bbc2aa7a98` |


---

# ANEXO A — Volcado ClickUp, Épica híbrida, inserción de filas e Ideas (Addendum v2.6 integrado)

> Este anexo consolida los aprendizajes del piloto **Líder System (Plan de Proyecto v2)** y prevalece sobre el cuerpo anterior donde haya conflicto. Mantiene su propia tabla de versiones.

# Addendum v2.6 — Plan de Proyecto Reinicia
## Volcado de PBI / Tipo de Producto / Épica desde ClickUp + reanudación del piloto Líder System

> **Versión: v2.6 — 2026-06-28 — Autor: Néstor + Claude**
> Complementa los addenda v2.1 y v2.2. Donde haya conflicto, **prevalece v2.6**.
> Aplica a las dos skills: `plan-proyecto-zoho-sheet-reinicia` (supervisada) y `plan-proyecto-reinicia-modo-desatendido`.

---

## 1. Modelo de Épica — HÍBRIDO según tipo de fila

La columna **Épica** del Plan se rellena con criterio distinto según la naturaleza del producto, y la frontera la marca **el documento + el campo `TIPO DE PRODUCTO` de ClickUp**:

| Tipo de fila | Documento | Criterio de Épica | Modelo |
|---|---|---|---|
| **Microcampaña de marketing** (Email Marketing, SEM, Redes, Publicidad…) | Plan de Marketing | **Fase del funnel de ClickUp** tal cual (`00. BRAND AWARENESS` … `08. ADVOCACY` + transversales) | **A** |
| **Producto digital** (CRM, Desarrollo Web, WhatsApp Corporativo, Analítica…) | Plan de Proyecto | **Objetivo de negocio** que Claude propone y el PO ajusta en el propio Plan | **B** |

- En **modelo B**, Claude **propone** la Épica de negocio (no la vuelca de ClickUp) y **NO toca el campo `ÉPICA` de ClickUp** (sus fases quedan como dimensión interna de marketing).
- La "app/plataforma" (Zoho CRM, WhatsApp, Web) **NO es la Épica**: corresponde al campo **`TIPO DE PRODUCTO`** de ClickUp.
- Líder System: los 57 son productos digitales → **todo el piloto va por modelo B**.

---

## 2. Campos reales de ClickUp (lista `General [CLIENTE]`)

Verificado en vivo (28/06/2026) sobre la lista General Líder System `211763746`:

| Campo | ID | Tipo | Notas |
|---|---|---|---|
| **PBIs PRIMER NIVEL** | `6758065a-bd4f-4d7d-9a48-926e81fe343f` | **text (libre)** | NO predefinido. Algunas tarjetas lo tienen escrito, otras vacío (mixto). |
| **ÉPICA** | `6e3bf4c0-354b-4a8c-8cb5-dbedeec1cf6e` | **drop_down (predefinido)** | 12 valores (fases funnel + transversales). |
| **TIPO DE PRODUCTO** | `5bd9072e-deae-4352-b35b-bdbaa3cc216d` | **drop_down (predefinido)** | 35 valores. |

> ⚠️ `clickup_filter_tasks` **NO devuelve campos personalizados** (solo nombre/estado/tags/fecha/asignados). Para leer PBI/Épica/Tipo hay que ir tarjeta a tarjeta con `clickup_get_task` + `include:["custom_fields"]`. El valor de un dropdown viene como **`value` = orderindex** (no el id). PBI (texto) viene como `value` directo.

### ÉPICA — orderindex → nombre → id de opción
```
0  00. BRAND AWARENESS              76a03f3b-a706-4e13-9069-7cb48605004f
1  01. DESCUBRIMIENTO               b30d21f9-6a42-4624-9b04-2edc01597793
2  02. INVESTIGACIÓN                69b75ed5-fcc4-4f88-b43a-3ee68d9928bc
3  03. CONSIDERACIÓN                0c3e943e-525b-4ef8-98fd-fcc643bf6bc6
4  04. CONVERSION                   41512e45-494a-4337-b41b-1138eb543fb2
5  05. ADOPTION                     70bb9189-873a-4481-b8bf-3cf0e99c399f
6  06. REPETITION                   db7f50ec-592b-4c05-9d75-7e662a3627d2
7  07. EXPANSION                    de9a38bb-03fe-4c0b-ba14-7c5f57d95578
8  08. ADVOCACY                     0ed66cff-e1ab-48ec-9402-d41a0b1c8e11
9  FORMACIÓN                        a25f454d-b805-4cda-9feb-482c6a912e5e
10 MEDIR ÉXITO DE LAS CAMPAÑAS      6c95410f-6153-415c-b75b-d845a7376b01
11 PLANIFICACIÓN                    574b22cf-6754-475f-af40-17ac9f03994b
```

### TIPO DE PRODUCTO — orderindex → nombre (los más usados con id de opción)
```
0  GESTIÓN CRM            4  CRM (814e9896-f224-458f-afef-3aaa1506ce5b)
1  ANALÍTICA WEB          5  DESARROLLO WEB (c0fd12ed-112f-4150-aa70-0268e8de3ac5)
8  EMAIL MARKETING (04dc1e6d-e865-45e2-b306-9d9dabe41e3d)
11 MARKETING AUTOMÁTICO   18 SEO    19 SEM    16 REDES SOCIALES
34 WHATSAPP CORPORATIVO (e297373f-6456-490b-aa34-8e9205dfd4ab)
```
(Lista completa de 35 valores en el payload de cualquier tarjeta de la lista.)

---

## 3. Regla determinista de volcado (ClickUp → Plan)

Por cada producto/fila del Plan:

1. `clickup_get_task` con `include:["custom_fields"]`.
2. **PBI**:
   - Si el campo `PBIs PRIMER NIVEL` **tiene valor** → volcar **ese texto** a la columna PBI del Sheet (col 5 en 40# y 41#).
   - Si está **vacío** → escribir la **etiqueta propia** de Claude (la que ya hay en el Sheet col 5 como punto de partida, **afinada** para los grupos demasiado anchos — ver §3.1) en el Sheet **y** hacer `clickup_update_task` con `custom_fields:[{id:"6758065a-…", value:"<PBI>"}]` (texto libre) para **escribirlo también en ClickUp**.
3. **TIPO DE PRODUCTO**: traducir orderindex→nombre y escribirlo en la **col 3 del Plan Interno (41#)**.
4. **ÉPICA**: para productos digitales (modelo B) **NO se vuelca ni se pisa** el campo de ClickUp; la Épica de negocio la propone Claude aparte.
5. **Nota al PO**: cada vez que se actualiza el Plan, dejar **un comentario-resumen al PO en el producto de Gestión del mes** (`Gestión [CLIENTE]`, lista `211763776` en LS) listando los **PBIs que Claude ha escrito** (los que estaban vacíos). **No** se deja nota tarjeta a tarjeta.

### 3.1 Afinado de los grupos de PBI demasiado anchos (validado con Néstor)
- **Procesos Zoho CRM** → partir por proceso: *Gestión de Leads y Conversión a Matrícula · Modelo de Datos y Módulos CRM · Automatizaciones y Flujos · Automatización Documental (Zoho Sign)*. (Cadencias ya es su propio PBI en ClickUp.)
- **Web** → *Web lidersystem.com — Mantenimiento / — Captación (landings) / — Analítica integrada*.
- **Email Marketing** → *Email Marketing — Nurturing de Leads / — Comunicación a Alumnos*.
- **Chatbot WhatsApp (Woztell)** → *Chatbot WhatsApp — Atención y Captación / — Notificaciones a Alumnos*.
- Principio: el PBI debe **ayudar a construir la Épica**, ser **reutilizable a futuro** y específico.

---

## 4. Columna Tipo de Producto en el Plan Interno

> ⚠️ **El mapa de columnas vigente es §4.0 / B.4** (plantilla v2, con la columna nueva `Fecha de petición` H → calendario 41# desde **col 13 = M**). Lo de abajo describe el **piloto LS anterior a la plantilla v2** (cuando el calendario del Interno empezaba en col 12) y se conserva solo como contexto histórico.

- El **Tipo de Producto** se registra en la **col C (3) del Plan Interno (41#)** — coincide con §4.0.
- **Normalización obligatoria: `GESTIÓN CRM` → `CRM`.** Toda entrada de TIPO DE PRODUCTO que venga como "GESTIÓN CRM" se simplifica a **"CRM"** en el Plan (corrección validada en el piloto LS).
- *(Contexto LS pre-v2)* Esa columna sustituyó a la antigua "Sprint" del Interno; en la plantilla v2 el mapa canónico ya incorpora Tipo de Producto en col C.
- Para futuros clientes, el mapa canónico de §4.0 es el que manda (no re-decidir por cliente).

---

## 5. Coste, contexto y arquitectura desatendida

- **Coste por tarjeta**: `clickup_get_task` con campos pesa **~15k tokens** irreductibles (arrastra descripción completa + definiciones de todos los dropdowns; el de `PROYECTO` solo tiene 140 opciones). El dato útil son 3 campos.
- **El contenedor NO puede llamar a la API de ClickUp** (red restringida: solo anthropic/github/pypi/npm). La única vía a ClickUp es el conector MCP.
- **Implicación**: el volcado fiel de N productos **no cabe en una sola sesión** (≈6–10 filas antes de tensar la ventana). Se hace **en tandas, idempotente y reanudable** (lo escrito persiste en Sheet + ClickUp; el punto de reanudación se deduce del contenido de la col PBI).
- **Modelo recomendado para el ETL**: el volcado es mecánico → en la Routine/sesión de volcado usar **Sonnet o Haiku con esfuerzo bajo**; reservar **Opus solo para criterio** (proponer Épicas de negocio, afinar PBIs dudosos). El modelo barato ahorra €, **no** tokens de contexto.

### 5.1 PALANCA DE COSTE — función Zoho Catalyst `clickup_plan_fields`
> ⚠️ **AÚN NO DESPLEGADA (a 2026-07-11).** Es la palanca objetivo; **hasta que exista, la fuente operativa por defecto sigue siendo `clickup_get_task` troceado** (tarjeta a tarjeta). No dar por hecho que la función responde.

Sacar la extracción pesada fuera del LLM:
- Función a crear en el proyecto Catalyst `Reinicia-Clickup-Audit` (patrón del `inactivity_calculator`) que llame a la API REST de ClickUp **server-side** y, por lista, devuelva solo `{id, name, status, pbi, epica, tipo, date_created, due_date, date_closed}`.
- La skill/Routine consumiría un JSON de N×~5–8 campos (**<2k tokens** frente a ~850k para 57 tarjetas).
- Es la palanca estructural para que **el volcado desatendido sea barato y quepa en una pasada**: **cuando esté desplegada**, la modo-desatendido la usará como fuente por defecto en lugar de arrastrar los ~15k tokens/tarjeta de `clickup_get_task`. En la **supervisada** se usa `clickup_get_task` tarjeta a tarjeta (hoy, y siempre que haga falta criterio fino).

---

## 6. ESTADO DEL PILOTO LÍDER SYSTEM — punto de reanudación

- **Fichero piloto v2**: `pnync16bccbe6727e428ba3ae89ffe6e95e07` · Plantilla canónica v2: `pnync351d56992b6d4026906a6fec5d56e682`.
- **Worksheets**: `40#` (cara cliente) · `41#` (interno). Col 5 = PBI · Col 3 (41#) = Tipo Producto.
- **Lista General LS**: `211763746` · **Gestión LS** (para nota al PO): `211763776`.

### Filas YA volcadas (9–14) — persistidas en Sheet + ClickUp
| Fila | task_id | PBI | Origen | Tipo |
|---|---|---|---|---|
| 9  | 869dru4ar | Cadencias Zoho CRM (Cadence Studio) | ClickUp | CRM |
| 10 | 869drt2c1 | Conector Zoho CRM ↔ App Formación | Claude→push | CRM |
| 11 | 869dq1c0r | Cadencias Zoho CRM (Cadence Studio) | ClickUp | CRM |
| 12 | 869dhxkuw | Captación de Leads y Publicidad | Claude→push | CRM |
| 13 | 869bv7va4 | Automatización Documental (Zoho Sign) | Claude→push (afinado) | CRM |
| 14 | 869bv7d3k | Gestión de Leads y Conversión a Matrícula | Claude→push (afinado) | CRM |

- **PBIs escritos por Claude (validar el PO en la nota)**: filas **10, 12, 13, 14**.
- **PUNTO DE REANUDACIÓN: fila 15 `8698c2k3x`.**

### Mapa fila → task_id pendiente
**IMPL (rows 15–31):** 8698c2k3x · 8699uk7tz · 869depu3k · 869ckja53 · 869br1grc · 869a00xwt · 869deb56h · 869deb398 · 869ckzyfw · 8699znw1n · 8699zng5v · 869cbupxk · 869c37k8f · 869bv7a2e · 869anfkhv · 8698p86yt · 8694qgz6z
**ACTIVO (rows 38–61):** 869d3p14r · 869cauycd · 869c18an3 · 869bq2gk5 · 869bpra19 · 869baqeyj · 869b9np2f · 869b2gu5c · 869axy0pz · 869axxz5u · 869aw6m40 · 869arg3yz · 869arfgz0 · 869aare9t · 8699679fz · 8699679er · 8699679cw · 86996798b · 86996797f · 869967964 · 86996791d · 8699678yq · 86996786p · 8698p8e4x
**CERRADO (40# rows 70–79 / 41# rows 68–77):** 869dhmfpk · 869dhetpb · 869dfregv · 869dd66vh · 869d2fpm5 · 869d0tgga · 869d0tbj1 · 869b8rxg6 · 869b8rxtq · 869c58nqe

> La etiqueta PBI de partida para las vacías es la que ya está en el Sheet col 5 (mis 10 grupos iniciales); afinar según §3.1 al volcar.

---

## 7. Recordatorios vigentes (de v2.1/v2.2, reconfirmados)
- **Sincronización bidireccional** de la *Fecha de validación esperada* (Sheet ↔ subtarea "Validación Cliente" de ClickUp). Las subtareas normalmente vienen **sin fecha**: el Cliente/PO la pone en el Sheet y se empuja a ClickUp, o al revés. **Ocurre en ambos sentidos.**
- **Colores de hito** (Gantt): entrega Reinicia `#70EED6` · validación Cliente `#EBE31B`. Swatches de leyenda canónica alineados (40# C4/C5).
- **Lavado base blanco** en Log de Cambios y Config (hasta col Z / fila 100, incluidas filas 2–4 del título).
- No usar `Create_New_File` para Zoho Sheet; crear por `ZohoSheet_copy`. Decimales con coma (es-ES). Vaciar celda con `" "` (espacio), nunca `""`.

---

## 8. Inserción de filas en las tablas del Plan (REGLA OBLIGATORIA)

Aplica a **Plan Proyecto (40#)** y **Plan Proyecto Interno (41#)**, en **General y Soporte**, para **productos y microcampañas**, en cada una de las **cuatro** secciones (IMPLANTACIÓN, SOPORTE ACTIVO, SOPORTE CERRADO, RESUMEN HISTÓRICO). En un proyecto con **soporte real, SOPORTE CERRADO puede necesitar ~18 inserciones** — insertarlas todas antes de pegar y **verificar el recuento con una lectura** (`insert_row` a veces deja una fila de menos: 17 en vez de 18).

**Regla:** cuando en una tabla quedan pocas filas libres dentro del cuerpo formateado y aún hay contenido por meter, **primero se insertan las filas necesarias ANTES de la penúltima fila del cuerpo de esa tabla; solo después se pega el contenido.** Nunca al revés, y nunca escribir más allá del cuerpo formateado sin insertar antes.

Razones y detalles:
- **Por qué antes de la penúltima**: la última fila del cuerpo suele llevar el borde de cierre de la tabla; la penúltima arrastra formato + desplegable (Estatus) + formato condicional (semáforo). Insertar **antes de la penúltima** hace que las filas nuevas hereden ese formato y la tabla conserve su fila de cierre.
- **Por qué insertar antes de pegar**: si se escribe primero y la región con formato es más corta que el nº de productos, las filas extra salen sin formato, sin desplegable de Estatus, sin semáforo y **fuera del rango de las fórmulas** (SUMIF/condicional silenciosamente a cero).
- `ZohoSheet_insert_row` inserta **una fila por llamada** (param `row` = índice). Para N filas, **N llamadas** al mismo índice.
- **Tras insertar, recalcular posiciones de TODAS las tablas inferiores**: se desplazan hacia abajo tantas filas como se hayan insertado (insertar en IMPLANTACIÓN baja SOPORTE ACTIVO, SOPORTE CERRADO y RESUMEN HISTÓRICO; insertar en ACTIVO baja CERRADO y RESUMEN…). Recalcular también las **filas-título de meses** (7/32/57/81) y, en la cara cliente (40#), revisar que la **rejilla del Gantt y los hitos** sigan alineados tras el desplazamiento; **repintar calendario/Gantt** si hizo falta.
- **El borrado de filas** (p. ej. Formación Interna, §PASO 3) es también estructura → hacerlo **al final de la fase de contenido** y **repintar** después.
- La región con formato de la plantilla es **más corta** (~19 filas) que el nº habitual de productos, por lo que esta regla aplica casi siempre que se puebla un Plan real.

---

## 9. Generación de Ideas — fuentes, límites y trazabilidad

### 9.1 Fuentes de ideas
Claude propone ideas para la pestaña **Ideas (42#)** a partir de CINCO fuentes:
1. **Actas de reunión** del cliente.
2. **Notas en la Gestión del cliente** (comentarios/observaciones en los productos `Gestión [CLIENTE]`).
3. **Histórico de productos y microcampañas** ya realizados o planificados del proyecto (General y Soporte) — para detectar continuaciones, evoluciones, mejoras o piezas que falten.
4. **Referencias de Internet** que Claude consulte en cada caso: **novedades de Zoho**, **recursos oficiales de Zoho**, **YouTube** y **webs de terceros** que publiquen sobre Zoho.
5. **Otros proyectos de Reinicia similares** (actuales y pasados) en ClickUp — clientes del mismo sector o con el mismo tipo de trabajo Zoho/Web/WABA — para reutilizar productos o microcampañas que ya funcionaron y adaptarlos a este cliente. Coherente con el principio general de reutilizar conocimiento previo de ClickUp.

> ⚠️ **Objetivos del Cliente (pestaña 45#) NO es una fuente de ideas.** Contiene los **objetivos** que el PO ha documentado y que **guían y priorizan** la selección de ideas. Las skills **no la generan ni la modifican**; la **leen** como criterio de filtrado: una idea encaja mejor cuanto más sirve a un objetivo declarado del cliente.

### 9.2 Límites (con base en evidencia)
- **Máximo ~7 ideas nuevas por ronda.** Una "ronda" = cada ejecución de la **Routine semanal de los domingos** que actualiza el Plan del proyecto.
- **Tope por fuente: 2–3 ideas por origen y ronda** (acta · notas de Gestión · histórico de productos · referencias de internet · proyectos similares de Reinicia), para forzar variedad y que no domine una sola fuente.
- **Diversidad > cantidad**: las ~7 deben cubrir ángulos distintos; mejor pocas y variadas que muchas redundantes.
- **Excedentes a reserva**: si se detectan más de 7, las que no entran se registran con **Estatus Plan = "Pendiente Incluir"** (col K) en vez de empujarlas todas a la vista. La pestaña **acumula histórico**; el tope de 7 es de **altas nuevas por ronda**, no de ideas vivas totales.
- **Fundamento**: sobrecarga de elección (Iyengar & Lepper — el experimento de las mermeladas: más interés con 24, muchas más decisiones con 6) y límite de ítems manejables de un vistazo (~7±2, Miller). Más ideas aumentan la carga de evaluación del PO y empeoran la decisión.

### 9.3 Trazabilidad obligatoria en la columna Notas (col I de Ideas)
Para cada idea, en **Notas** se indica:
- **Autoría**: si la idea la ha aportado **Claude** (marcarlo explícitamente).
- **Fuente/origen**: de cuál de las cuatro fuentes proviene (necesario para aplicar el tope por fuente).
- **Fuente/origen**: de cuál de las cinco fuentes proviene (necesario para aplicar el tope por fuente). Si procede de un **proyecto similar de Reinicia**, enlazar la tarea de ClickUp del producto de referencia.
- **Referencias con URL**: enlaces consultados — novedades de Zoho, recursos de Zoho, YouTube, webs de terceros sobre Zoho, o la tarea ClickUp del proyecto similar.
- Un **"porqué" de una línea**: para que el PO pueda aceptar/descartar rápido. Una idea sin justificación es ruido.

### 9.4 Cadencia
La actualización del Plan —incluida la generación de ideas— la ejecuta la **Routine de Claude Code, una vez por semana, los domingos**. Cada domingo = una ronda (≤7 ideas nuevas).

---

# ANEXO B — Addendum v2.7 — Aprendizajes del piloto Líder System (creación robusta)

> Alinea la supervisada con la desatendida v1.7. Estas reglas **prevalecen** sobre lo anterior donde entren en conflicto. El "Estado del piloto LS" de §6/§7 (filas 9–14, mapa fila→task_id pendiente) queda **SUPERADO**: el piloto está muy avanzado; ignorar ese estado congelado.

## B.1 Regla de oro de formato (el API no lee formato)
El API de Zoho Sheet **solo escribe formato, no lo lee**. Por tanto: al escribir/insertar CUALQUIER celda, aplicar SIEMPRE el estilo canónico que le corresponde (fondo, bordes, fuente Manrope, color de fuente, alineación, altura). **Nunca** dejar el formato "por defecto" ni intentar "igualar" leyendo. Si hace falta uniformar, reescribir el estilo de todo el rango de una vez.

## B.2 Portada — enlace a la web REAL del cliente
La celda D5 (Cliente/Proyecto) debe llevar como hyperlink la **web real del cliente** (la de la Pregunta 8), NUNCA la de la plantilla (residuo tipo `ackstorm`). Tras copiar la plantilla, corregir con `=HYPERLINK("<web cliente>";"<Nombre Cliente>")` (semicolon, es-ES). Usar `https`.

## B.3 Config — TRES columnas + estilo canónico
La pestaña Config lista cada referencia en **TRES columnas**: **Parámetro** (nombre del parámetro) · **Valor** (nombre legible) · **ID/Resource** (que lee la máquina, en la **col D**). Aplica a 7 campos: Lista ClickUp General, Soporte, Gestión; Carpeta ClickUp; Space ClickUp; Carpeta Workdrive (Plan); Resource ID (fichero). La skill **lee el ID de su columna (col D)**, nunca lo parsea de un texto "Nombre (ID)". **La Config viene VACÍA en la plantilla → construirla.**
Estilo: cabecera `fill #3812CF` / fuente blanca negrita; filas de datos `fill #EBEBEB` / fuente `#545454`; **bordes blancos `#FFFFFF`**; Manrope. No pintar celdas fuera de la tabla. Ancho de la columna ID (col D) ~**400**.

## B.4 Calendario — base gris
> ⚠️ **Corrección de mapa (v2.8):** con la **nueva columna `Fecha de petición` (H = col 8)**, la rejilla del calendario se desplaza **+1**. Ya **no** es "40# M–AJ / 41# L–AI".

La rejilla del calendario (**40# cols N–AK = 14–37; 41# cols M–AJ = 13–36**; **24 quincenas**) **ya viene formateada (gris) en la plantilla**, en las cuatro secciones y en ambas pestañas. **NO repintar la base** (las filas insertadas heredan el gris de la de arriba; fijarlo a mano arriesga descuadre si el gris real fuese distinto de `#F2F2F2`). Marcar por `quincena = (mes−1)·2 + (1 si día ≤ 15; 2 si >15)`; **col = 13 + quincena** (40#) / **12 + quincena** (41#). Pintar **solo los hitos** encima: entrega `#70EED6`, validación `#EBE31B`. **En ACTUALIZACIÓN**, para mover un hito hay que **restaurar la celda que se vacía al MISMO gris de la plantilla** (no a blanco) — ese gris es un dato de la plantilla, no se lee por API: fijarlo una vez tras confirmarlo a ojo. **Estatus = col M (40#) / col L (41#)** — resolver por cabecera leída.

## B.5 Épica — prefijo numérico y orden
- La Épica (objetivo de negocio, modelo B) lleva **prefijo numérico** ("1. …", "2. …") para que el orden sea **intrínseco al dato**.
- **Orden de filas dentro de cada tabla:** Épica (prefijo) → **`date_created`** (fecha de petición) → **fecha de entrega**.
- **Agrupación visual (col 2):** fondo alternando **`#70EED6` / `#BFBFBF`** cada vez que cambia la épica (grupos contiguos).
- Reorden + recoloreado de Épica + redibujado del calendario van **SIEMPRE juntos**.

## B.6 `task_id` en el Entregable
Cada Entregable (col 6) lleva incrustado el enlace a ClickUp (`=HYPERLINK("https://app.clickup.com/t/<task_id>";"<texto>")`). Es la fuente determinista de `date_created` (para el orden) y de identidad de fila (en vez de matching difuso por nombre). En la pestaña cara cliente puede ir en texto plano; en la Interna, con enlace.

## B.7 Reorden — es trabajo de SCRIPT, no manual
- Zoho Sheet **no tiene ordenar/mover fila nativo**: el reorden se hace leyendo → ordenando → reescribiendo la fila completa.
- Las marcas del calendario son solo fondo (no se mueven con el contenido) → tras reordenar hay que **repintar el calendario**.
- Las fórmulas `HYPERLINK` se escriben en **lotes pequeños**: un lote grande de fórmulas devuelve **error 400**.
- Por todo ello, el reorden lo ejecuta un **script de Claude Code** (o la Routine), no a mano. Mapear por Entregable entre pestañas que puedan estar **desfasadas** (p. ej. Soporte Cerrado a veces va una fila desplazado entre 40# y 41#).

## B.8 Novedades v2.8 (creación por plantilla v2 — piloto Carritech)
Estas reglas prevalecen y complementan §4.0 del cuerpo:
- **Plantilla canónica = `pnync351…`** (la `47q3o1a…` está OBSOLETA). Crear por `ZohoSheet_copy`, nunca `createNativeDocument`/`Create_New_File`/`create_workbook`.
- **Portada:** `C3` título · `D5`=HYPERLINK(web real) · limpiar residuo `ackstorm` en `E5:G5` · `C6`–`C10` = Idioma/País/Equipo/PO Cliente/PO Técnico (etiquetas traducidas en planes EN).
- **Config = 3 columnas** (Parámetro | Valor | ID/Resource; ID en col D, ancho ~400). **Log = 3 columnas** (Fecha | Autor | Cambio + bordes blancos perimetrales). Ambas vienen VACÍAS → construirlas.
- **Mapa de columnas:** columna nueva **`Fecha de petición` (H)**; Estatus 40#=M, 41#=L; calendario 40#=N–AK, 41#=M–AJ (24 quincenas). Ver §4.0 y B.4.
- **4ª sección RESUMEN HISTÓRICO** (fila 81, 2 filas Implementation/Support): agrega años previos; los productos de años anteriores van individuales con su fecha real y el calendario del año en blanco.
- **Meses repetidos por sección** (filas 7/32/57/81) → traducir por sección en planes EN.
- **Estatus = desplegable**: la API solo escribe el VALOR; el color (incl. PARKING/CANCELADO) lo pone la interfaz. **Nunca** pintar el color del Estatus a mano.
- **Sello de última actualización** en `C3` de ambas: `40#` solo fecha `DD/MM/YYYY`; `41#` fecha + hora `DD/MM/YYYY HH:MM` (24h). Reescrito al crear y en cada actualización.
- **Cerrados sin `due_date`** → **`date_closed` como proxy de entrega (B):** col 9 = `date_closed` (DD/MM/YYYY) + marca de calendario en su quincena; `date_closed` sigue atribuyendo el año. Solo Entrega `"-"` si tampoco hay `date_closed`.
- **Formación Interna** fuera del Plan (excluir/borrar fila al final de la fase de contenido). **Soporte Cerrado** con Descripción de 1 línea (Deliverable+Épica+PBI) por lotes.
- **Límites API:** `cells.content.set` ≤40 celdas (63→400); `HYPERLINK` en lotes pequeños; `insert_row` 1 fila/llamada → verificar recuento con lectura.

---

## Versiones
| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v2.11** | 2026-07-11 | Néstor + Claude | **Sello de última actualización en AMBAS pestañas, con formato distinto.** Verificado en vivo: tanto `40#` como `41#` traen "Fecha actualización:" en B3 y placeholder `DD/MM/AAAA` en C3 (la skill decía "solo 41#" — impreciso). Ahora: **`40#` (pública) = solo fecha `DD/MM/YYYY`**; **`41#` (Interno) = fecha + hora `DD/MM/YYYY HH:MM`** (24h). Actualizadas las 3 menciones (§4.0, §4.7, recordatorios). |
| **v2.10** | 2026-07-11 | Néstor + Claude | **Verificación EN VIVO de la plantilla `pnync351…` (antes de recrear LS).** Confirmado contra el fichero real: 7 pestañas (ids con `#` literal; Log = "Log Cambios"); 40# y 41# **difieren** exactamente como el mapa (col 8 `Fecha de petición` y col 10 `Fecha de validación` **ya están** en la plantilla; Estatus 40#=13/41#=12; calendario 40#=14–37/41#=13–36); cada tabla trae **19 filas placeholder** (títulos 7/32/57/81, datos 9–27 / 34–52 / 59–77; Resumen Histórico 2 filas fijas 83–84) → insertar solo si la tabla supera 19; Config y Log **vacíos**. Cambios aplicados: (1) **Calendario = heredar la base gris de la plantilla, NO repintar** (las filas insertadas heredan el gris); pintar solo hitos; en ACTUALIZACIÓN, al mover un hito restaurar la celda vaciada al gris de la plantilla (no a blanco) — ese gris no se lee por API. (2) **Portada:** aclarado que las etiquetas ya vienen en `C6`–`C10` y los **valores van en `D6`–`D10`** (sobrescribir placeholders `Español`/`España`/`Columbia o Proactive u otro`); el `D5`=HYPERLINK reemplaza el `ackstorm` y hay que limpiar `E5:G5`. (3) **Renombrar el header de la col 12 en 40#** (`Notas Nombre Cliente` → `Notas <Cliente>`) y el marcador `[NOMBRE CLIENTE]` del título C3. |
| **v2.9** | 2026-07-11 | Néstor + Claude | **Proxy `date_closed` (decisión B) + bump para push inequívoco.** (1) **Cerrados sin `due_date`** ahora usan **`date_closed` como fecha de entrega** (col 9 = fecha de cierre en DD/MM/YYYY) **y marcan el calendario** en esa quincena con el color de entrega — antes se dejaba Entrega `"-"`/calendario en blanco (supera esa regla de v2.8). Solo `"-"` si tampoco hay `date_closed`. (2) Subida de versión (v2.8→v2.9) para que el push al repo sea inequívoco y el script de sync no pueda saltarse esta versión por coincidir el número con una hipotética v2.8 paralela (rama 06/07). Consolida todo el cotejo de v2.8. (3) **Cotejo de las 5 DECISIONES PO** (rescatadas del proyecto): nº1 (mapa=plantilla), nº2 (columnas operativa vs. Cliente separadas), nº3 (reflejo completo), nº4 (semáforo=formato condicional/solo texto) y nº5a (Ideas) ya cubiertas; **corregido el hueco nº5b**: la **Fecha de validación esperada** sincroniza en **AMBOS sentidos** (Sheet ↔ ClickUp), no solo Sheet→ClickUp — alineadas las flechas del mapa 40#/41#. |
| **v2.8** | 2026-07-11 | Néstor + Claude | **Creación por plantilla v2 (piloto Carritech) + prevalencia del ANEXO B.** (1) Plantilla canónica pasa a `pnync351…` (la `47q3o1a…` marcada OBSOLETA en todas sus apariciones). (2) Cabecera de prevalencia del ANEXO B bajo el título + checklist obligatoria en Paso 2 (ANEXO A+B+§6/§7/§8/§9) + convención de volcado en dos fases. (3) Nueva §4.0 ESTRUCTURA CANÓNICA en el cuerpo: pestañas (36/40/41/42/45/43/44), 4 tablas (IMPLANTACIÓN/SOPORTE ACTIVO/SOPORTE CERRADO/**RESUMEN HISTÓRICO**), mapa de columnas corregido con la columna nueva **Fecha de petición (H)** (Estatus 40#=M / 41#=L; calendario 40#=N–AK / 41#=M–AJ; quincena=(mes−1)·2+(1 si día≤15;2 si>15)), portada real (C3/D5 HYPERLINK/limpiar `ackstorm` E5:G5/C6–C10), **Config 3 columnas** (Parámetro|Valor|ID/Resource, ID col D), **Log 3 columnas** (Fecha|Autor|Cambio), sello de fecha en 41# C3, meses repetidos por sección (7/32/57/81) con traducción EN, años previos individuales + calendario en blanco. (4) Pasos 3.2–3.7 reescritos como §4.2–4.8 (crear por `ZohoSheet_copy`, nunca `createNativeDocument`); **eliminado** el paso de "colores de estatus" (§3.5 Paso 6): Estatus es desplegable, la API solo escribe el valor y el color es automático. (5) Formación Interna fuera del Plan; Soporte Cerrado ligero por lotes; cerrados sin due_date → Entrega "-". (6) Límites API validados (≤40 celdas, HYPERLINK en lotes, insert_row 1 fila/llamada con verificación); §8 ampliada a 4 secciones (~18 inserciones en soporte real). (7) B.3 (Config 3 col), B.4 (mapa corregido) y B.8 (novedades) en el ANEXO B; §5.1 `clickup_plan_fields` reencuadrada como palanca de coste del volcado desatendido — **aún sin desplegar; hasta entonces el default operativo es `clickup_get_task` troceado**. (8) **Cotejo con el proyecto Asesor PO (49 ítems):** Descripción = **ambos formatos combinados** por defecto (Historia + Resumen); en planes EN **SÍ se traducen los nombres de Entregables** (trazabilidad vía HYPERLINK); tabla de estatus ampliada con **PARKING/CANCELADO** y validación→EN PROCESO; normalización **`GESTIÓN CRM`→`CRM`**; Plan **nunca en `01. Seguimiento`**; Log con los **7 atributos** de estilo; validación de cabecera cruzando contra fila de datos (error K/L). |
| v2.3 | 2026-06-28 | Néstor + Claude | Modelo de Épica híbrido (A microcampañas / B digitales) con frontera por TIPO DE PRODUCTO. Campos reales de ClickUp (PBI texto libre, ÉPICA y TIPO dropdowns) con IDs. Regla determinista de volcado + push de PBI vacío a ClickUp + nota-resumen al PO en Gestión. Tipo de Producto en col 3 del Interno. Coste ~15k/tarjeta, filter sin custom fields, tandas reanudables, modelo Sonnet para ETL, Catalyst `clickup_plan_fields` como mejora futura. Estado del piloto LS (filas 9–14 hechas) y punto de reanudación (fila 15 `8698c2k3x`) con mapa fila→task_id. |
| v2.4 | 2026-06-28 | Néstor + Claude | Añadida §8: regla obligatoria de inserción de filas en las tablas del Plan (40# y 41#, General y Soporte, productos y microcampañas) — insertar las filas necesarias ANTES de la penúltima fila del cuerpo de la tabla y solo después pegar el contenido; una fila por llamada a `ZohoSheet_insert_row`; recalcular índices de las tablas inferiores y revisar Gantt/hitos tras el desplazamiento. |
| v2.5 | 2026-06-28 | Néstor + Claude | Añadida §9: generación de Ideas. Cuatro fuentes (actas, notas de Gestión, histórico de productos/microcampañas, referencias de internet sobre Zoho); Objetivos del Cliente (45#) NO es fuente sino criterio de priorización (solo lectura). Límite ~7 ideas nuevas por ronda (= ejecución dominical de la Routine), tope 2–3 por fuente, diversidad, excedentes a "Pendiente Incluir". Trazabilidad obligatoria en col I Notas: autoría Claude + fuente + URLs + porqué de una línea. Fundamento: sobrecarga de elección y 7±2. |
| v2.7 | 2026-07-05 | Néstor + Claude | **ANEXO B — aprendizajes del piloto LS (creación robusta), alinea con desatendida v1.7.** Bloque de versión añadido. Regla de oro de formato (el API no lee formato). Portada con web real del cliente (no la plantilla). Config a dos columnas (Nombre \| ID) + estilo canónico (cabecera azul/blanca, datos gris `#EBEBEB`, bordes blancos). Calendario base gris `#F2F2F2` en las tres tablas y ambas pestañas, hitos encima. Épica con prefijo numérico; orden Épica → `date_created` → fecha de entrega; agrupación de color `#70EED6`/`#BFBFBF`. `task_id` en el Entregable (hyperlink) como fuente de `date_created` e identidad de fila. Reorden = script (no manual): sin sort nativo, `HYPERLINK` en lotes pequeños (400 si grande), mapear por Entregable entre pestañas desfasadas. Estado del piloto LS de §6/§7 marcado como SUPERADO. |
| v2.6 | 2026-06-28 | Néstor + Claude | §9: añadida **quinta fuente** de ideas — otros proyectos de Reinicia similares (actuales y pasados) en ClickUp, para reutilizar productos/microcampañas que ya funcionaron. Tope por fuente y trazabilidad (enlace a la tarea ClickUp de referencia) actualizados en consecuencia. |

