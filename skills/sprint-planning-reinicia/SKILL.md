---
name: sprint-planning-reinicia
description: >
  Skill para procesar las transcripciones de Sprint Planning semanales de los Product Owners
  de Reinicia y actualizar el backlog de ClickUp proyecto a proyecto. Cubre el flujo completo:
  análisis de transcripciones VTT, cruce con el Zoho Sheet de Sprint Planning y con ClickUp,
  propuesta de cambios validada por el PO, ejecución de escrituras en ClickUp (comentarios,
  estatus, etiquetas) y gestión de oportunidades e impedimentos.

  Actívala siempre que el PO suba una transcripción de Sprint Planning y pida:
  - "analiza el sprint planning"
  - "actualiza ClickUp con el sprint planning"
  - "procesa la transcripción del planning"
  - "actualiza los productos del sprint"
  - o cuando se adjunten ficheros .vtt con nomenclatura Sprint-Planning-SprintX-SemanaX-EquipoX

  Skills complementarias:
  - plan-proyecto-zoho-sheet-reinicia: actualización del Plan de Proyecto en Zoho Sheet
  - propuesta-comercial-zoho-crm-reinicia: creación de propuestas en Zoho CRM para oportunidades
---

# SKILL: Sprint Planning — Reinicia

## Propósito

Procesar las narraciones semanales de Sprint Planning de los Product Owners de Reinicia,
cruzarlas con el Zoho Sheet de Sprint Planning y con ClickUp, y actualizar el backlog de
forma sistemática y trazable, proyecto a proyecto, con validación explícita del PO antes
de cada escritura.

---

## RECURSOS CLAVE

| Recurso | ID / URL |
|---|---|
| Zoho Sheet Sprint Planning 2026 | `ggxmpfd47bf128f954108b2474f7d69af40c8` |
| Carpeta Workdrive Sprint Planning | `db7hy01bbf926e9ac4261826a06f22aca92c6` |
| URL Sheet | https://sheet.zoho.eu/sheet/open/ggxmpfd47bf128f954108b2474f7d69af40c8 |

**Estructura del Zoho Sheet:**
- Una pestaña por sprint: `Objetivos Sprint 05-26` (formato `Objetivos Sprint XX-AA`)
- **Col D:** todos los productos comprometidos para el sprint completo (3 semanas)
- **Col G:** productos activos en Semana 1
- **Col H:** productos activos en Semana 2
- **Col I:** productos activos en Semana 3

El sprint planning semanal narra el avance de los productos de la **columna de esa semana**,
no necesariamente todos los de Col D. Es normal que no se mencionen productos de otras semanas.

**Formato etiqueta de sprint:** `sprint - XX - AA` (ej. `sprint - 05 - 26`)

---

## PRINCIPIO FUNDAMENTAL — VALIDACIÓN ANTES DE ESCRIBIR

**Nunca escribir en ClickUp sin validación explícita del PO.**

- Presentar cambios **proyecto a proyecto**, uno a uno
- Esperar confirmación explícita antes de ejecutar y antes de pasar al siguiente proyecto
- El PO puede aprobar, modificar o descartar cada cambio individualmente
- Solo después de la validación se ejecutan las escrituras

---

## PASO 1 — LECTURA DE TRANSCRIPCIONES

### 1.1 Nomenclatura de ficheros
Los ficheros .vtt siguen el patrón:
`Sprint-Planning-Sprint[N]-Semana[N]-Equipo[NOMBRE]-[APELLIDO]-REINICIA.vtt`

Extraer de la nomenclatura:
- Número de sprint (ej. 5)
- Número de semana del sprint (ej. 1)
- Equipo y PO narrador

### 1.2 Leer el Zoho Sheet
Antes de analizar las transcripciones, leer la pestaña del sprint actual con
`ZohoSheet_get_content_of_worksheet` para conocer:
- Los productos de Col G (Semana 1), H (Semana 2) o I (Semana 3) según corresponda
- El orden de los clientes (es el orden de narración del PO)
- Los 3 primeros clientes tienen fondo verde = mayor importancia estratégica

**Este cruce es obligatorio antes de analizar la transcripción.** Los nombres exactos de
los productos en el sheet son la referencia canónica para identificarlos en ClickUp.

### 1.3 Inferencia de estatus
Nunca pedir el estatus explícitamente al PO durante el análisis — inferirlo del lenguaje:

| Expresión | Estatus inferido |
|---|---|
| "estamos trabajando", "seguimos", "en ello", "avanzando" | EN PROCESO |
| "ya está", "ya realizado", "terminado", "hecho" | TERMINADO |
| "bloqueado", "parado", "no podemos avanzar" | PARKING |
| "pendiente", "no hemos empezado", "próximamente" | PENDIENTE |
| "retrasado", "se ha atrasado", "no llegamos" | POSPUESTO |

Siempre confirmar el estatus inferido con el PO al presentar los cambios proyecto a proyecto.

### 1.4 Correcciones de nombres conocidas
El reconocimiento de voz deforma nombres propios. Aplicar siempre estas correcciones:

| Transcripción | Nombre correcto | Rol |
|---|---|---|
| Navadai, Navadaí | Nabaday | Amigo Reinicia |
| Manly, Manis, Manny | Manish | Amigo Reinicia |
| Xisco | Chisco | Amigo Reinicia |
| Syntax | Sintaris | Empresa Amiga Reinicia (Óscar Seuba + David Marco) |
| Google Goat | Worldwide Boat | Cliente |
| Katia | Katja | Contacto Worldwide Boat |

---

## PASO 2 — ANÁLISIS Y PRESENTACIÓN AL PO

### 2.1 Formato de análisis por equipo
Presentar el análisis completo antes de iniciar las actualizaciones, en el orden del Zoho Sheet:

```
## 🔵 EQUIPO [NOMBRE] — [PO]

### [CLIENTE]
**Objetivos Semana X:**
- [Nombre producto ClickUp] — [ESTATUS INFERIDO] · [detalle si lo hay]

**Impedimentos:** [descripción] / Ninguno mencionado
**Oportunidades:** [descripción] / Ninguna mencionada
```

### 2.2 Feedback de narración
Al final del análisis, incluir un bloque de mejoras para cada PO basado en la
Guía de Narración del Sprint Planning. Presentarlo separado de los cambios de ClickUp.

**No pedir estatus explícitos todavía** (mejora gradual — introducir cuando el PO mejore
el resto de puntos). Recordar la semana siguiente cuando proceda.

### 2.3 Productos no mencionados en la narración
Si un producto de la columna de esa semana no aparece en la narración, **no notificarlo
como ausencia** — puede no haber novedades. Solo notificar si es un bloqueo conocido
o si el PO ha mencionado ese cliente sin mencionar ese producto específico.

---

## PASO 3 — ACTUALIZACIÓN EN CLICKUP (proyecto a proyecto)

### 3.1 Orden de trabajo
Seguir el mismo orden que el Zoho Sheet (= orden de narración del PO).
Los 3 primeros proyectos tienen mayor importancia estratégica.
Procesar **un cliente a la vez** — no pasar al siguiente sin validación del PO.

### 3.2 Preparación por proyecto
Para cada proyecto, antes de presentar cambios al PO:

1. **Leer los productos de la semana** en Col G/H/I del Zoho Sheet
2. **Localizar cada producto en ClickUp** con `clickup_get_task` (no `clickup_search` para
   verificar etiquetas — search no devuelve tags)
3. **Buscar en TODAS las listas del cliente** (General, Soporte y Gestión), no solo General
4. **Verificar etiqueta de sprint** `sprint - XX - AA` en cada producto
5. **Leer comentarios** con `clickup_get_task_comments` + `clickup_get_threaded_comments`
   para comentarios con `reply_count > 0`

### 3.3 Propuesta de cambios — formato tabla
Presentar siempre en formato tabla antes de ejecutar:

```
## [CLIENTE] — Propuesta de actualización ClickUp · Sprint X Semana X

| Producto | ID | Cambio propuesto |
|---|---|---|
| [Nombre] | `ID` | 💬 Comentario → [Persona] |
| [Nombre] | `ID` | 🔄 Estatus → doing · 💬 Comentario → [Persona] |
| [Nombre] | `ID` | 🏷️ Etiqueta sprint-XX-AA · 💬 Comentario → [Persona] |
| Gestión [Mes] [CLIENTE] | `ID` | 💬 Impedimentos → [Persona] · 💬 Oportunidades → [Persona] |
| Gestión Semana X | `ID` | ✔️ Marcar como Done |

⚠️ Pendientes / preguntas:
- [Pregunta sobre bloqueo, fecha ambigua, asignación, etc.]

¿Confirmas y ejecuto?
```

### 3.4 Reglas de ejecución

**Comentarios de sprint planning:**
- Texto: `Sprint X Semana X — [ESTATUS] · [detalle]`
- Preguntar siempre a quién asignar — no asumir
- Varias personas = varios comentarios, anidados en un hilo con `clickup_get_threaded_comments`
- **Si una llamada falla y hay que reintentar: incluir SIEMPRE todos los parámetros
  del intento original, sin excepción**

**Etiquetas de sprint:**
- Verificar con `clickup_get_task` (no search)
- Si falta `sprint - XX - AA`: incluirla en la propuesta y ejecutar con `clickup_add_tag_to_task`
- La etiqueta debe existir ya en el espacio (está presente en otros productos del mismo cliente)

**Estatus:**
- Solo cambiar si hay discrepancia clara entre lo narrado y lo que hay en ClickUp
- Siempre proponer el cambio al PO antes de ejecutar
- Productos en sprint backlog narrados como EN PROCESO → proponer cambio a `doing`

**Productos bloqueados (PARKING):**
- Si está en el sprint backlog actual → preguntar al PO si moverlo a `parking e incidencias`
- Siempre pedir el motivo del bloqueo si no se especificó en la narración
- Dejar comentario con el motivo una vez confirmado

**Fechas ambiguas:**
- "Esta semana", "en unos días", "próximamente" → preguntar al PO si quiere concretar fecha
- Proponer añadir fecha en ClickUp si confirma

**Productos no localizados:**
- Si no se encuentra con búsqueda por nombre, preguntar al PO el ID exacto
- Buscar en TODAS las listas del cliente (General, Soporte, Gestión)
- Documentar el motivo por el que no se encontró (lista equivocada, nombre diferente, etc.)

### 3.5 Impedimentos y oportunidades
Van siempre al producto **Gestión [Mes] [AÑO] [CLIENTE]** en la lista Gestión del cliente.

**Impedimentos:** comentario asignado según indique el PO.

**Oportunidades:**
1. Añadir comentario en Gestión
2. Preguntar al PO si quiere crear Propuesta Comercial en Zoho CRM
3. **Verificar primero** si ya existe una propuesta para esa oportunidad en Zoho CRM
   (buscar en los últimos 365 días en el módulo Deals filtrando por cuenta del cliente)
4. **Si NO existe propuesta** → activar skill `propuesta-comercial-zoho-crm-reinicia`
   para crearla, luego añadir comentario en Gestión con enlace, preguntando a quién asignarlo
5. **Si YA existe propuesta** → preguntar al PO si quiere dejar una actualización mediante nota:
   - Si sí → preguntar qué información quiere añadir
   - Crear la nota en Zoho CRM asociada a la propuesta (`ZohoCRM_createNotes`):
     - Título: seguir el patrón de notas anteriores en propuestas similares
       (consultar notas existentes con `ZohoCRM_getNoteById` o revisando la propuesta)
     - Contenido: información indicada por el PO + mención a Néstor en el texto de la nota
   - Añadir comentario en el producto Gestión [Mes] [CLIENTE] en ClickUp informando
     de la nota creada, con enlace a la propuesta en Zoho CRM
     → asignado a Néstor por defecto

**Asignación de comentarios en Gestión:** preguntar siempre — no asumir ningún responsable.

### 3.6 Subtarea "Gestión Semana X"
Al terminar la revisión de cada proyecto:
- Localizar las subtareas del producto Gestión [Mes] del proyecto
- Identificar la **semana natural del mes** en que cae el lunes del sprint planning
  (NO la semana del sprint — son cosas distintas)
  - Semana 1: días 1-7 del mes
  - Semana 2: días 8-14 del mes
  - Semana 3: días 15-21 del mes
  - Semana 4: días 22-28 del mes
  - Semana 5: días 29-31 del mes (si los hay)
- Marcar como `done` la subtarea correspondiente con `clickup_update_task`

### 3.7 Resumen de ejecución — formato tabla
Al terminar cada proyecto, presentar resumen de lo ejecutado:

```
## ✅ [CLIENTE] — Sprint X Semana X

| Producto | ID | Acción ejecutada |
|---|---|---|
| [Nombre] | `ID` | 💬 Comentario → [Persona] |
| Gestión Semana X | `ID` | ✔️ Marcada como Done |

⚠️ Pendientes manuales: [si los hay]
🔗 Zoho CRM: [propuesta creada si aplica]
```

---

## PASO 3.8 — AL TERMINAR CADA EQUIPO (antes de pasar al siguiente)

Una vez completada la revisión de todos los proyectos de un equipo, y antes de pasar
al equipo siguiente, preguntar al PO:

```
Hemos terminado con el Equipo [NOMBRE].

Antes de continuar, ¿hay algún impedimento u oportunidad que no hayas mencionado
en la narración y quieras añadir en algún proyecto?

Puedo ayudarte a registrarlo ahora.
```

Si el PO indica algo → ejecutar el comentario correspondiente en el producto Gestión
del cliente afectado siguiendo las mismas reglas de asignación del Paso 3.5.

Si no hay nada que añadir → continuar con el siguiente equipo o con el Paso 4.

---

## PASO 4 — AL FINALIZAR TODOS LOS EQUIPOS

### 4.1 Impedimentos u oportunidades olvidados
Este paso ya se habrá cubierto al terminar cada equipo en el Paso 3.8. Si quedan
varios equipos pendientes, retomar solo si el PO lo solicita explícitamente.

### 4.2 Sugerencias para abordar impedimentos
Una vez terminada la revisión de todos los proyectos, ofrecer al PO ayuda para trabajar
los impedimentos detectados. El flujo es iterativo:

**Paso 1 — Presentar el listado completo de impedimentos:**
```
Durante el sprint planning se han identificado los siguientes impedimentos:

1. [CLIENTE] — [descripción del impedimento]
2. [CLIENTE] — [descripción del impedimento]
3. [CLIENTE] — [descripción del impedimento]
...
N. Ninguno, no quiero trabajar ningún impedimento

¿Sobre cuál quieres que te sugiera cómo abordarlo?
```

**Paso 2 — El PO elige uno:**
- Analizar el impedimento en el contexto del proyecto y del cliente
- Proponer 2-3 sugerencias concretas y accionables para abordarlo
- Las sugerencias deben tener en cuenta el contexto de Reinicia: tipo de proyecto,
  herramientas disponibles (Zoho CRM, ClickUp, WhatsApp), relación con el cliente,
  recursos del equipo

**Paso 3 — Volver a mostrar el listado sin el impedimento tratado:**
```
¿Quieres trabajar algún otro impedimento?

1. [CLIENTE] — [impedimento]
2. [CLIENTE] — [impedimento]
...
N. No, hemos terminado

```

**Paso 4 — Iterar** hasta que el PO elija la opción de no trabajar más impedimentos.

**Notas:**
- No preguntar impedimento a impedimento desde el principio — siempre mostrar el listado
  completo primero y dejar que el PO elija
- Si el PO elige "ninguno" directamente, no insistir
- Las sugerencias son orientativas — el PO decide si las aplica o no
- No registrar las sugerencias en ClickUp salvo que el PO lo pida explícitamente

### 4.3 Plan de Proyecto
Una vez terminada la revisión de todos los proyectos y el trabajo con impedimentos,
preguntar al PO si quiere actualizar o crear algún Plan de Proyecto:

```
¿Quieres actualizar o crear el Plan de Proyecto de algún cliente?
Puedo ayudarte a:
- Actualizar un Plan de Proyecto existente con los cambios de este sprint
- Crear un Plan de Proyecto nuevo para un cliente que aún no lo tiene

¿De qué cliente quieres trabajar el Plan de Proyecto?
(O dime "no" si no quieres hacerlo ahora)
```

→ Si el PO confirma: activar skill `plan-proyecto-zoho-sheet-reinicia`
  - Modo ACTUALIZACIÓN: si ya existe el Plan de Proyecto del cliente
  - Modo CREACIÓN: si el cliente no tiene Plan de Proyecto todavía
→ Se puede iterar con varios clientes en la misma sesión
→ Si el PO responde "no", continuar con el paso 4.4

### 4.4 Mejora de narración
Recordar (si aplica y es el momento adecuado según la estrategia gradual) que el siguiente
paso de mejora de narración es usar estatus explícitos por producto.

---

## INFORMACIÓN OPERATIVA

### Sprints y semanas
- Sprint = 3 semanas (puede variar en verano/Navidad)
- Revisión semanal los lunes
- El Zoho Sheet tiene una pestaña por sprint

### Equipos y POs
| Equipo | Product Owner | ID ClickUp |
|---|---|---|
| Columbia | Pablo Losada | `87715920` |
| Proactive | Óscar Díez | `93631901` |

### IDs de personas clave
| Persona | Rol | ID ClickUp |
|---|---|---|
| Néstor Tejero Bermejo | Director General / Responsable Comercial | `766716` |
| Pablo Losada | PO Equipo Columbia | `87715920` |
| Óscar Díez | PO Equipo Proactive | `93631901` |
| José Barreiro | Consultor | `87739095` |
| Fabián Vargas | Consultor técnico | `93744950` |
| Alejandro Pont | Consultor | `93805276` |
| Paolo Bergamelli | PO Técnico / Líder Tecnología | `2447443` |
| Ronald Urquidi | Ingeniero sistemas | `43739458` |
| Johanna Brizuela | Consultora | `56699411` |

### Listas ClickUp por cliente (referencia)
| Cliente | General | Soporte | Gestión |
|---|---|---|---|
| Gonher | `901205582810` | `901205582846` | `901209826214` |
| Avaderm | `901202330051` | `901210493032` | `901202330083` |
| BirdEase | `901215730601` | — | — |
| Carritech | `901207893908` | — | `901207893946` |

> Completar con nuevos clientes a medida que se trabajen.

### Limitaciones técnicas conocidas
- `clickup_search` no devuelve tags → usar siempre `clickup_get_task` para verificar etiquetas
- Buscar siempre en TODAS las listas del cliente, no solo General
- Comentarios con `reply_count > 0` requieren `clickup_get_threaded_comments` adicional
- La creación de propuestas en Zoho CRM requiere el MCP de Zoho CRM con permisos de escritura
  en el módulo Deals (`ZohoCRM_createDealsRecords`)

---

## ORDEN DE CLIENTES EN CADA SPRINT

El orden de clientes **no es fijo** — varía sprint a sprint según entren y salgan proyectos.

El orden correcto para cada sesión viene dado por:
1. **El Zoho Sheet** de la pestaña del sprint en curso — es la fuente de verdad
2. **La narración del PO** — que siempre sigue el orden del sheet

**Al inicio de cada sesión**, cruzar los clientes mencionados en la transcripción con los
que aparecen en el Zoho Sheet para:
- Confirmar que los nombres se han entendido correctamente (el reconocimiento de voz deforma
  nombres de clientes igual que deforma nombres de personas)
- Identificar el orden correcto de procesamiento
- Detectar si algún cliente del sheet no fue mencionado en la narración (puede ser normal
  si no tiene productos en esa semana)

Los 3 primeros clientes del sheet tienen fondo verde = mayor importancia estratégica.
Procesarlos siempre primero, respetando el orden del documento.
