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

## Propósito
Crear y mantener el Plan de Proyecto de un cliente como documento vivo en Zoho Sheet,
alineado con el backlog de `General [CLIENTE]` en ClickUp. Sirve tanto al PO (seguimiento
interno) como al cliente (visibilidad sobre entregas comprometidas y su estado real).

**Recursos de referencia en Workdrive:**
- Plantilla base: `47q3o1a477a21d2f848d28c957304f083b0b6` (Recursos Comunes Reinicia)
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
→ Dentro de la carpeta raíz del cliente, localizar la subcarpeta `Plan de Proyecto`.
  Si no existe, avisar al PO — debe crearla manualmente o confirmar en qué carpeta guardarlo.

### Pregunta 3: Lista en ClickUp
"¿Cuál es el ID de la lista `General [CLIENTE]` en ClickUp? Si no lo tienes, lo busco."
→ Buscar con `clickup_search` usando el nombre del cliente.

### Pregunta 4: Idioma
"¿El plan de proyecto va en **español** o en **inglés**?"
→ Condiciona todos los textos: cabeceras, estatus, etiquetas del calendario.

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
"Para la columna Descripción del plan, ¿qué formato prefieres?"
- **Historia de usuario** ("Como [rol], QUIERO..., PARA...") — recomendado si el cliente tiene conocimientos de Scrum o metodologías ágiles
- **Resumen ejecutivo** — descripción breve en lenguaje natural del objetivo del producto, sin jerga técnica ni de Scrum — recomendado para clientes con menor madurez digital

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

Según la preferencia del PO (Pregunta 6 de elicitación):

**Opción A — Historia de usuario:**
Extraer de la descripción de la tarea el bloque que empieza por "Como" / "As a".
Si no existe explícitamente, construirla a partir del campo `description` de ClickUp.
Formato: "Como [rol], quiero [qué], para [para qué]." Máx. 2 líneas.

**Opción B — Resumen ejecutivo:**
Extraer el objetivo principal del producto desde el campo `description` de ClickUp
(sección de descripción, no comentarios). Redactar en lenguaje natural, sin términos
de Scrum. Máx. 2 líneas. Si la descripción es muy técnica, simplificar para que
sea comprensible por un interlocutor no técnico del lado del cliente.

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
| to do / open / backlog | PENDIENTE | PENDING |
| in progress / en curso | EN PROCESO | IN PROGRESS |
| complete / done / closed | TERMINADO | COMPLETED |
| on hold / blocked / pospuesto | POSPUESTO | ON HOLD |

### Composición del tipo de proyecto (para nomenclatura del fichero)
Inspeccionar el campo TIPO DE PRODUCTO de todas las tareas y componer el tipo combinado:
- CRM → `Zoho`
- DESARROLLO WEB (WordPress/Drupal) → `Web`
- DESARROLLO WEB (framework JS) → `WebApp`
- WhatsApp / WABA → `WABA`
- EMAIL MARKETING / MARKETING AUTOMÁTICO / ESTRATEGIA → `MKT`

Si hay más de un tipo, combinarlos por orden de volumen: ej. `Zoho-Web`, `Zoho-WABA-MKT`.

---

## PASO 4 — MODO CREACIÓN: CONSTRUIR EL DOCUMENTO

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

### 3.2 Crear el fichero en Workdrive
Usar `ZohoWorkdrive_createNativeDocument`:
```json
{
  "service_type": "zohosheet",
  "parent_id": "[ID carpeta Plan de Proyecto del cliente]",
  "name": "[nombre confirmado]"
}
```

Guardar el resource_id del fichero creado para todas las operaciones siguientes.

⚠️ **Inmediatamente después de crear el fichero**, verificar su estado con `ZohoWorkdrive_searchTeamFoldersFiles` buscando por nombre. Si el campo `status` devuelve `4` (papelera), restaurarlo con `ZohoSheet_restore` antes de continuar. Esto puede ocurrir cuando el fichero se crea desde una sesión MCP cuyo propietario no coincide con el workspace principal.

### 3.3 Rellenar la pestaña Portada

Nombre de pestaña: `Portada` (ES) / `Cover` (EN)

| Celda | Contenido |
|---|---|
| B7 | "Calendario de entregas [CLIENTE]" (ES) / "[CLIENTE] Project Calendar" (EN) |
| D9 | Nombre del cliente |
| E9 | URL del cliente |
| D10 | Idioma/s del proyecto |
| D11 | País/es donde opera |

Usar `ZohoSheet_set_content_to_multiple_cells` para rellenar todo en una llamada.

### 3.4 Crear y rellenar la pestaña Plan de Proyecto

Nombre de pestaña: `Plan de Proyecto` (ES) / `Project Plan` (EN)

**Estructura de columnas (fila 1 = cabecera):**

| Col | ES | EN |
|---|---|---|
| A | Épica | Epic |
| B | PBI | PBI |
| C | Tipo de producto | Product Type |
| D | Entregable | Deliverable |
| E | URL ClickUp | ClickUp URL |
| F | Descripción | Description |
| G | Fecha estimada de entrega | Expected Delivery Date |
| H | Notas | Notes |
| I | Estatus | Status |
| J en adelante | Grid calendario por semana/quincena/mes | |

**Cabeceras del calendario (fila 1, desde col J):**
Formato compacto `Mes S#` — ej. `Ene S1`, `Ene S2`, `Feb S5`... hasta cubrir el año completo.
No usar filas separadas para meses y semanas — todo en una sola fila.

**Filas de datos (desde fila 2):**
Una fila por producto de ClickUp. La estructura de Épicas, PBIs y orden
**no se propone ni modifica** — se toma fielmente de ClickUp.
Ordenar por campo ORDEN (si asignado) o por ÉPICA + TIPO DE PRODUCTO si ORDEN es null.

Marcar con `●` la celda del calendario correspondiente al `due_date` del producto.
- Si `due_date` tiene valor → convertir de epoch ms a formato `DD/MM/AAAA` y escribir en col G.
- Si `due_date` es null → escribir "A definir" en col G, calendario en blanco.

Usar `ZohoSheet_set_content_to_multiple_cells` en bloques de máx. 40 celdas.

**Formato col G (fecha):** `horizontal_alignment: center`, `vertical_alignment: middle` en todo el rango G2:G[N].

### 3.5 Aplicar formato a la pestaña Plan de Proyecto

Aplicar en este orden con `ZohoSheet_format_ranges`:

**Paso 1 — Cabecera (fila 1):**
```json
{
  "range": "A1:[ÚLTIMA COL]1",
  "bold": true, "fill_color": "#3812CF", "font_color": "#FFFFFF",
  "font_size": 11, "horizontal_alignment": "center",
  "vertical_alignment": "middle", "row_height": 36, "wrap_text": true
}
```

**Paso 2 — Anchos de columnas de datos:**
```
A: 120px  B: 150px  C: 110px  D: 280px  E: 180px
F: 300px  G: 130px  H: 260px  I: 100px  J en adelante: 36px
```

**Paso 3 — Filas alternas (cols A–I):**
Filas pares → `fill_color: #FFFFFF`, filas impares → `fill_color: #EBEBEB`
`row_height: 60`, `vertical_alignment: top` en todas las filas de datos.

**Paso 4 — Zona calendario (cols J en adelante, filas 2–N):**
```json
{
  "range": "J2:[ÚLTIMA COL][ÚLTIMA FILA]",
  "fill_color": "#EBEBEB",
  "bold": true, "font_color": "#3812CF",
  "horizontal_alignment": "center", "vertical_alignment": "middle"
}
```

**Paso 5 — Wrap text en columnas de contenido:**
```
D2:D[N], F2:F[N], H2:H[N] → wrap_text: true
```

**Paso 6 — Colores de estatus (col I, fila a fila según valor):**
| Estatus | fill_color | font_color |
|---|---|---|
| TERMINADO / COMPLETED | `#a5f39d` | `#1a6b15` |
| EN PROCESO / IN PROGRESS | `#FFDD57` | `#7a5c00` |
| PENDIENTE / PENDING | `#D9D0FB` | `#3812CF` |
| POSPUESTO / ON HOLD | `#CCCCCC` | `#555555` |

Aplicar `bold: true`, `horizontal_alignment: center`, `vertical_alignment: middle` en col I.

**Paso 7 — Bordes blancos en todo el documento:**
```json
{ "range": "A1:[ÚLTIMA COL]200", "border": { "border_color": "#FFFFFF", "border_style": "solid", "border_type": "all_border" } }
```
Aplicar en las tres pestañas (Plan de Proyecto, Portada, Log de Cambios).

### 3.6 Crear la pestaña Log de Cambios

Nombre: `Log de Cambios` (ES) / `Change Log` (EN)

Cabeceras en fila 1:

| Col | ES | EN |
|---|---|---|
| A | Fecha | Date |
| B | Producto | Deliverable |
| C | Tipo de cambio | Change Type |
| D | Detalle | Detail |
| E | Responsable | Owner |

Fila 2: nota de referencia en itálica con los tipos de cambio estándar:
`Retraso en entrega | Adelanto en entrega | Cambio de alcance | Producto añadido | Producto eliminado | Reactivación | Otro`

**Formato del Log de Cambios:**
- Fila 1: `fill_color: #3812CF`, `font_color: #FFFFFF`, `bold: true`, `row_height: 36`
- Fila 2: `fill_color: #D9D0FB`, `font_color: #555555`, `italic: true`, `row_height: 30`, `wrap_text: true`
- Anchos: A=100px, B=250px, C=160px, D=300px, E=130px
- Bordes blancos en todo el rango

### 3.7 Ajustes manuales post-creación (no automatizables vía MCP)

Informar al PO de estos cuatro pasos que debe hacer al abrir el fichero por primera vez:

1. **3 filas libres superiores:** seleccionar fila 1 → clic derecho → Insertar 3 filas encima
2. **Logotipo Reinicia:** Insertar → Imagen → buscar en Recursos Comunes > Identidad Marca Reinicia. Ajustar a 120×22px proporcional.
3. **Lista de selección en columna Estatus:** seleccionar rango `I2:I200` (rango amplio para cubrir futuras filas) → Insertar → Lista de selección → añadir los valores:
   - ES: `PENDIENTE`, `EN PROCESO`, `TERMINADO`, `POSPUESTO`, `PARKING`, `CANCELADO`
   - EN: `PENDING`, `IN PROGRESS`, `COMPLETED`, `ON HOLD`, `PARKING`, `CANCELLED`

   ⚠️ Usar siempre el rango `I2:I200` — no limitarlo al número actual de productos. Así las filas que añada la skill en futuras actualizaciones ya tendrán la lista aplicada y no habrá que repetir este paso.
   ⚠️ Los valores deben escribirse exactamente igual que los que usa la skill al actualizar el plan — de lo contrario Zoho Sheet los marcará como inválidos visualmente. La API escribe texto directamente y no bloquea la escritura, pero sí señala la discrepancia.
4. **Renombrado con INTERNOIA:** el MCP no puede renombrar ficheros Zoho Sheet. Hacerlo manualmente desde Workdrive (clic derecho → Renombrar). El nombre siempre termina en `-INTERNOIA`: ej. `2026-Plan-Proyecto-Zoho-GONHER-INTERNOIA`.

---

## PASO 5 — MODO ACTUALIZACIÓN: DETECTAR Y APLICAR CAMBIOS

### 4.1 Leer el estado actual del Plan de Proyecto

```
ZohoSheet_get_content_of_worksheet(resource_id=..., worksheet_name="General",
  response_type="array", major_dimension="rows")
```

Construir un mapa interno: `nombre_entregable → {fila, estatus_actual, fecha_actual}`

### 4.2 Comparar con ClickUp

Para cada producto de ClickUp, comparar contra el mapa del sheet y detectar:

| Tipo de diferencia | Acción propuesta |
|---|---|
| Producto en ClickUp no existe en el sheet | Añadir nueva fila |
| Estatus cambió | Actualizar celda de estatus |
| Due_date cambió | Actualizar fecha + recalcular marca en calendario |
| Producto en sheet no existe en ClickUp | Alertar al PO (¿eliminado del backlog?) |

### 4.3 Presentar las diferencias al PO

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

### 4.4 Aplicar cambios confirmados

Una vez el PO confirma:
1. Actualizar celdas de estatus y fecha con `ZohoSheet_set_content_to_multiple_cells`
2. Añadir nuevas filas con `ZohoSheet_addrecords` o `ZohoSheet_set_content_to_multiple_cells`
3. Recalcular marcas del calendario para las filas modificadas

### 4.5 Proponer entradas para el Log de Cambios

Para cada cambio relevante (retrasos, adelantos, productos añadidos/eliminados),
proponer la fila correspondiente en el Log:

```
📝 ENTRADAS SUGERIDAS PARA EL LOG DE CAMBIOS:

| Fecha | Producto | Tipo de cambio | Detalle | Responsable |
|---|---|---|---|---|
| [hoy] | [producto] | Retraso en entrega | [fecha ant.] → [fecha nueva] | [PO] |
| [hoy] | [producto] | Producto añadido | Incorporado al alcance en Sprint [N] | [PO] |

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

- **Limitaciones técnicas Zoho Sheet API:**
  - `set_content_to_multiple_cells`: máximo 50 celdas por llamada — usar bloques de 30-40 por seguridad.
  - Tamaño de petición HTTP también limitado: mantener descripciones y notas bajo ~200 caracteres por celda.
  - La hoja por defecto de un fichero nuevo se llama `Hoja1` (ES) — renombrarla antes de escribir contenido.
  - Tras crear el fichero, verificar su `status` inmediatamente: si devuelve `4` está en papelera (ocurre cuando el MCP crea el fichero con una cuenta diferente al propietario del workspace). Usar `ZohoSheet_restore` para recuperarlo antes de continuar.
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
- **Columna Descripción:** el formato (historia de usuario vs. resumen ejecutivo) se elige
  en la elicitación según la madurez digital del cliente y se aplica de forma consistente
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
| Plantilla Plan de Proyecto (Recursos Comunes) | `47q3o1a477a21d2f848d28c957304f083b0b6` |
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

- El **Tipo de Producto** se registra en la **col 3 del Plan Interno (41#)**.
- En el piloto LS, esa columna **sustituyó a la antigua "Sprint"** (el Gantt NO se desplazó: sigue empezando en col 12). Consecuencia: el Interno deja de mostrar Sprint.
- En la cara cliente (40#) **no** hay columna de Tipo (col 3 sigue siendo Sprint).
- Para futuros clientes, decidir si se replica esta sustitución o se inserta columna nueva (implicaría correr el Gantt y repintar hitos).

---

## 5. Coste, contexto y arquitectura desatendida

- **Coste por tarjeta**: `clickup_get_task` con campos pesa **~15k tokens** irreductibles (arrastra descripción completa + definiciones de todos los dropdowns; el de `PROYECTO` solo tiene 140 opciones). El dato útil son 3 campos.
- **El contenedor NO puede llamar a la API de ClickUp** (red restringida: solo anthropic/github/pypi/npm). La única vía a ClickUp es el conector MCP.
- **Implicación**: el volcado fiel de N productos **no cabe en una sola sesión** (≈6–10 filas antes de tensar la ventana). Se hace **en tandas, idempotente y reanudable** (lo escrito persiste en Sheet + ClickUp; el punto de reanudación se deduce del contenido de la col PBI).
- **Modelo recomendado para el ETL**: el volcado es mecánico → en la Routine/sesión de volcado usar **Sonnet o Haiku con esfuerzo bajo**; reservar **Opus solo para criterio** (proponer Épicas de negocio, afinar PBIs dudosos). El modelo barato ahorra €, **no** tokens de contexto.

### 5.1 MEJORA FUTURA (post-piloto) — función Zoho Catalyst `clickup_plan_fields`
Sacar la extracción pesada fuera del LLM:
- Función en el proyecto Catalyst `Reinicia-Clickup-Audit` (patrón del `inactivity_calculator`) que llama a la API REST de ClickUp **server-side** y, por lista, devuelve solo `{id, name, status, pbi, epica, tipo}`.
- La skill/Routine consume un JSON de N×~5 campos (**<2k tokens** frente a ~850k para 57 tarjetas).
- Es la palanca estructural para correr el volcado **desatendido** y barato. Queda **pendiente para después del primer piloto**.

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

Aplica a **Plan Proyecto (40#)** y **Plan Proyecto Interno (41#)**, en **General y Soporte**, para **productos y microcampañas**, en cada una de las tres tablas (IMPLANTACIÓN, ACTIVO, CERRADO).

**Regla:** cuando en una tabla quedan pocas filas libres dentro del cuerpo formateado y aún hay contenido por meter, **primero se insertan las filas necesarias ANTES de la penúltima fila del cuerpo de esa tabla; solo después se pega el contenido.** Nunca al revés, y nunca escribir más allá del cuerpo formateado sin insertar antes.

Razones y detalles:
- **Por qué antes de la penúltima**: la última fila del cuerpo suele llevar el borde de cierre de la tabla; la penúltima arrastra formato + desplegable (Estatus) + formato condicional (semáforo). Insertar **antes de la penúltima** hace que las filas nuevas hereden ese formato y la tabla conserve su fila de cierre.
- **Por qué insertar antes de pegar**: si se escribe primero y la región con formato es más corta que el nº de productos, las filas extra salen sin formato, sin desplegable de Estatus, sin semáforo y **fuera del rango de las fórmulas** (SUMIF/condicional silenciosamente a cero).
- `ZohoSheet_insert_row` inserta **una fila por llamada** (param `row` = índice). Para N filas, **N llamadas** al mismo índice.
- **Tras insertar, recalcular índices**: las tablas que quedan por debajo se desplazan hacia abajo tantas filas como se hayan insertado (insertar en IMPLANTACIÓN baja ACTIVO y CERRADO; insertar en ACTIVO baja CERRADO). En la cara cliente (40#), revisar que la **rejilla del Gantt y los hitos** sigan alineados tras el desplazamiento.
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

## Versiones
| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v2.3 | 2026-06-28 | Néstor + Claude | Modelo de Épica híbrido (A microcampañas / B digitales) con frontera por TIPO DE PRODUCTO. Campos reales de ClickUp (PBI texto libre, ÉPICA y TIPO dropdowns) con IDs. Regla determinista de volcado + push de PBI vacío a ClickUp + nota-resumen al PO en Gestión. Tipo de Producto en col 3 del Interno. Coste ~15k/tarjeta, filter sin custom fields, tandas reanudables, modelo Sonnet para ETL, Catalyst `clickup_plan_fields` como mejora futura. Estado del piloto LS (filas 9–14 hechas) y punto de reanudación (fila 15 `8698c2k3x`) con mapa fila→task_id. |
| v2.4 | 2026-06-28 | Néstor + Claude | Añadida §8: regla obligatoria de inserción de filas en las tablas del Plan (40# y 41#, General y Soporte, productos y microcampañas) — insertar las filas necesarias ANTES de la penúltima fila del cuerpo de la tabla y solo después pegar el contenido; una fila por llamada a `ZohoSheet_insert_row`; recalcular índices de las tablas inferiores y revisar Gantt/hitos tras el desplazamiento. |
| v2.5 | 2026-06-28 | Néstor + Claude | Añadida §9: generación de Ideas. Cuatro fuentes (actas, notas de Gestión, histórico de productos/microcampañas, referencias de internet sobre Zoho); Objetivos del Cliente (45#) NO es fuente sino criterio de priorización (solo lectura). Límite ~7 ideas nuevas por ronda (= ejecución dominical de la Routine), tope 2–3 por fuente, diversidad, excedentes a "Pendiente Incluir". Trazabilidad obligatoria en col I Notas: autoría Claude + fuente + URLs + porqué de una línea. Fundamento: sobrecarga de elección y 7±2. |
| v2.6 | 2026-06-28 | Néstor + Claude | §9: añadida **quinta fuente** de ideas — otros proyectos de Reinicia similares (actuales y pasados) en ClickUp, para reutilizar productos/microcampañas que ya funcionaron. Tope por fuente y trazabilidad (enlace a la tarea ClickUp de referencia) actualizados en consecuencia. |

