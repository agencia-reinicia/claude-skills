---
name: plan-proyecto-zoho-sheet-reinicia
description: >
  Skill para crear y mantener el Plan de Proyecto de un cliente de Reinicia en Zoho Sheet,
  sincronizando los productos de la lista General [CLIENTE] en ClickUp con el documento
  de seguimiento en Workdrive. Cubre dos modos: CREACIÓN (inicio de proyecto) y
  ACTUALIZACIÓN (sprint a sprint). El Plan de Proyecto es la fuente de verdad compartida
  entre el PO y el cliente sobre entregas comprometidas, fechas, estatus y progreso.

  Actívala siempre que el PO pida:
  - "crea el plan de proyecto de [CLIENTE]"
  - "actualiza el plan de proyecto de [CLIENTE]"
  - "sincroniza el plan con ClickUp"
  - "nuevo plan de proyecto para [CLIENTE]"
  - "actualiza el calendario de entregas de [CLIENTE]"
  - "rellena el plan de proyecto con lo que hay en ClickUp"
  - cualquier combinación de "plan", "proyecto", "calendario de entregas" con un cliente

  No usar para crear productos en ClickUp (skill productos-digitales-*-clickup-reinicia)
  ni para crear actas de reunión (skill actas-reinicia).
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
