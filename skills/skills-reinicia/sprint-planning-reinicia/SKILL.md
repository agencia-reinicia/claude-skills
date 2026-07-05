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

> **Versión vigente: v1.0 — 21/06/2026** · ver changelog al final (`## Versiones`)

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

**Personas y empresas amigas:**

| Transcripción | Nombre correcto | Rol |
|---|---|---|
| Navadai, Navadaí, Anabada, Nabaday | Nabaday | Amigo Reinicia |
| Manly, Manis, Manny | Manish | Amigo Reinicia |
| Xisco | Chisco | Amigo Reinicia |
| Syntax, Synaptic | Síntaris | Empresa Amiga Reinicia (Óscar Seuba + David Marco) — siempre con tilde |
| ROC | Rolf | Persona Reinicia |
| Lon en la 10 | Lorena Díaz | Contacto Kubex |
| 247 (dicho como número) | Dos4Siete | Empresa |

**Clientes:**

| Transcripción | Nombre correcto |
|---|---|
| Exelties | Exeltis |
| Aycroft | Aicrov |
| Cash blank | Kasblan |
| Abader | Avaderm |
| Western T Travel | Tee Travel |
| Y NEPSO, INEPSO | INEFSO |
| Carritage | Carritech |
| Brezome | Breezom |
| Ingelit | Ingelyt |
| Kubex Pharma Forum | Kubex Farmaforum |
| Saint-Gobain Pump | Saint-Gobain PAM |
| Synaptic | Synuptic |
| A una | AUNNA |
| Timedi | TI-MEDI |
| Cross of Rail | Lacroix Environment |
| Birdis | BirdEase |
| Paixico-Magister | Psicomagister |
| Google Goat | Worldwide Boat |

**Contactos cliente:**

| Transcripción | Nombre correcto | Rol |
|---|---|---|
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

**🔒 Solo comentar deltas reales (anti-ruido):**
Antes de insertar cualquier comentario, leer **todos los comentarios existentes** del producto
con `clickup_get_task_comments` (incluidos los hilos con `clickup_get_threaded_comments`
si `reply_count > 0`). Si la narración del PO repite información ya registrada en comentarios
previos sin aportar avance nuevo, **NO insertar comentario** y reportar al PO como
"sin novedades vs Semana X anterior".

Solo se inserta comentario cuando hay un delta real:
- Cambio de estatus
- Avance de hito o entrega
- Bloqueo nuevo, resolución de bloqueo, o cambio de fase
- Decisión, validación o información que no estuviera ya documentada

Esta regla aplica también a productos en `validación cliente` que llevan semanas sin movimiento:
si la situación no ha cambiado, no se vuelve a comentar lo mismo.

**Etiquetas de sprint:**
- Verificar con `clickup_get_task` (no search)
- Si falta `sprint - XX - AA`: incluirla en la propuesta y ejecutar con `clickup_add_tag_to_task`
- La etiqueta debe existir ya en el espacio (está presente en otros productos del mismo cliente)

**Estatus:**
- Solo cambiar si hay discrepancia clara entre lo narrado y lo que hay en ClickUp
- Siempre proponer el cambio al PO antes de ejecutar
- Productos en sprint backlog narrados como EN PROCESO → proponer cambio a `doing`

**Productos bloqueados (PARKING):**
Cuando un producto está bloqueado por una dependencia externa, el comentario de Sprint Planning
debe seguir esta lógica:

1. **Bloqueo por tercero externo** (proveedor del cliente, partner, conector externo no operativo,
   integración con sistema ajeno):
   - Comentario describe el bloqueo
   - Doble salto de línea + `**Sugerencia:**` Mover a `parking e incidencias`
   - Asignar al **PO técnico del proyecto** (no a Néstor) para que decida

2. **Bloqueo por respuesta del cliente** (validación pendiente, decisión pendiente,
   información que tiene que enviar el cliente):
   - Comentario describe el bloqueo y desde cuándo se espera respuesta
   - Doble salto de línea + `**Sugerencia:**` Mover a `parking e incidencias` + seguimiento
     explícito con el cliente
   - Asignar al **PO técnico del proyecto**

3. **Productos inactivos (futuro — requiere Catalyst)**: cuando esté disponible,
   detectar productos sin actividad real >7 días laborables y sugerir parking si
   hay bloqueo, o sprint backlog si retomable. Mientras tanto, verificación manual
   con `clickup_get_bulk_tasks_time_in_status`.

Siempre pedir el motivo del bloqueo si no se especificó en la narración.
Dejar comentario con el motivo una vez confirmado.

Decisión final de mover o no: siempre del PO. La sugerencia es solo recomendación.

**Fechas ambiguas:**
- "Esta semana", "en unos días", "próximamente" → preguntar al PO si quiere concretar fecha
- Proponer añadir fecha en ClickUp si confirma

**Productos no localizados:**
- Si no se encuentra con búsqueda por nombre, preguntar al PO el ID exacto
- Buscar en TODAS las listas del cliente (General, Soporte, Gestión)
- Documentar el motivo por el que no se encontró (lista equivocada, nombre diferente, etc.)

### 3.5 Impedimentos y oportunidades
Van siempre al producto **Gestión [Mes] [AÑO] [CLIENTE]** en la lista Gestión del cliente.

**🔒 Excepción — clientes que han terminado relación con Reinicia:**
Si durante la sesión de Sprint Planning se detecta que un cliente ha cerrado o va a cerrar
formalmente la relación (rescisión de contrato, baja del proyecto, comunicación formal de
fin de relación), **no documentar riesgo de salida** (la salida es hecho consumado, no
riesgo a vigilar) **ni oportunidades comerciales** (no procede plantear nuevos servicios
en ese contexto).

En esos clientes, el cierre de la sesión consiste en:
1. Marcar como Done lo que esté pendiente del sprint actual
2. Anotar la fecha efectiva de cierre como referencia
3. No publicar comentario de impedimentos ni de oportunidades en Gestión

**📝 Formato visual de comentarios con Sugerencia / Acción / Oportunidad:**
Cuando un comentario incluye una sugerencia, una acción o una oportunidad después de un
bloque descriptivo, usar el siguiente patrón en plain text:

```
[Texto descriptivo del estado o contexto del producto.]


**Sugerencia:** [Texto de la sugerencia]
```

Reglas:
- **Doble salto de línea** (= UNA línea en blanco visual entre los bloques) antes del
  prefijo de Sugerencia/Acción/Oportunidad. En la API ClickUp, esto se traduce en `\n\n\n`
  porque el primer `\n` cierra la línea anterior, los siguientes dos producen el párrafo
  en blanco intermedio.
- Prefijo siempre **en negrita** con `**Sugerencia:**`, `**Acción:**`, `**Oportunidad:**`
  según corresponda.
- Si hay más de un bloque (ej. impedimento + oportunidad), repetir el patrón:
  ```
  [bloque impedimento]


  **Sugerencia:** [...]


  **Oportunidad:** [...]
  ```
- Si el comentario solo tiene texto descriptivo sin sugerencia/acción/oportunidad,
  se redacta plano sin este patrón.

Este formato facilita la lectura del PO en ClickUp y resalta visualmente los puntos
accionables del comentario.

**Impedimentos:** comentario asignado según indique el PO (con respeto a las reglas
operativas adicionales descritas más abajo).

**Oportunidades:**
1. Añadir comentario en Gestión [Mes] [CLIENTE] con la descripción de la oportunidad
   (siguiendo el formato visual con `**Oportunidad:**` en negrita y doble salto)
2. Asignar según indique el PO (con respeto a las reglas operativas adicionales)

**La decisión de crear propuesta comercial en Zoho CRM se difiere al cierre del Equipo
(Paso 3.8.2)**, donde se hace la consolidación de todas las oportunidades del Equipo
con verificación automatizada de duplicados en Zoho CRM. No interrumpir el procesado
cliente a cliente para preguntar por cada propuesta — eso se hace en bloque al cerrar
el Equipo.

**Asignación de comentarios en Gestión:** preguntar siempre — no asumir ningún responsable.

**🔒 Reglas operativas adicionales:**

1. **Destino exclusivo de impedimentos y oportunidades — Gestión del cliente:**
   Los comentarios de impedimentos y oportunidades van **siempre y solo** al producto
   `Gestión [Mes] [AÑO] [CLIENTE]` en la lista Gestión del cliente afectado.
   **Nunca** al producto `Gestión [Mes] [AÑO] Marketing [REINICIA]` ni a ningún otro
   producto de gestión interna de Reinicia. La Gestión Marketing Reinicia es para actas
   y acuerdos internos, no para impedimentos/oportunidades de cliente.

2. **Validación previa obligatoria antes de publicar:**
   Antes de ejecutar `clickup_create_task_comment` para cualquier comentario, mostrar al
   PO el **texto exacto** del comentario y la **asignación propuesta** (o "sin asignar"
   si aplica regla 3), y esperar **confirmación explícita** del PO. No hay excepciones a
   esta regla, ni siquiera para comentarios "obvios" o repetitivos.

3. **No autoasignación a Néstor cuando el comentario es para conocimiento propio:**
   Cuando el riesgo, oportunidad o información de Gestión Cliente sea para conocimiento
   del propio Néstor (porque él mismo es el PO de la gestión y va a leer el producto
   como parte de su revisión normal), **NO asignar** el comentario a Néstor.
   El comentario se publica sin asignación. Néstor lo lee como parte normal de su
   revisión periódica de los productos de Gestión.

   Esto aplica cuando Néstor está conduciendo la sesión de Sprint Planning y procesa
   personalmente los comentarios. Si la sesión la conduce otra persona y necesita que
   Néstor reciba notificación expresa, sí se asigna.

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

**🔒 Caso especial — última semana natural del mes:**
Si el lunes del sprint planning cae en la **última semana natural** del mes (típicamente
Semana 4 o Semana 5 según calendario), marcar también como `done` las subtareas de
**semanas posteriores que no existan en el calendario real del mes**.

Ejemplo: si el sprint planning es lunes 27/04/2026, ese lunes cae en Semana 4 (22-28 abril).
No hay Semana 5 en abril 2026 (el mes acaba el día 30, sin lunes posterior). Por tanto,
marcar como `done` tanto Semana 4 como Semana 5 si esta última subtarea existe.

Esto evita que queden subtareas "abandonadas" en el producto de Gestión del mes que
luego confunden el cierre formal del producto al final del mes.

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

## PASO 3.8 — CIERRE POR EQUIPO (consolidación de Oportunidades e Impedimentos)

Una vez completada la revisión de **todos los proyectos de un Equipo**, y antes de pasar
al siguiente Equipo o cerrar la sesión, ejecutar este cierre estructurado en 3 fases.

**Esta sección es OBLIGATORIA y se ejecuta una vez por Equipo, no por cliente.**

### 3.8.1 Pregunta de cierre al PO

```
Hemos terminado con el Equipo [NOMBRE].

Antes de la consolidación final, ¿hay algún impedimento u oportunidad que no hayas mencionado
en la narración y quieras añadir en algún proyecto?

Puedo ayudarte a registrarlo ahora.
```

Si el PO indica algo nuevo → ejecutar el comentario correspondiente en el producto Gestión
del cliente afectado, siguiendo todas las reglas del Paso 3.5 (validación previa, formato
visual, asignación, etc.).

Si no hay nada que añadir → continuar con 3.8.2.

### 3.8.2 Consolidación de Oportunidades del Equipo

Recopilar **todas las oportunidades** detectadas en los comentarios de Gestión publicados
en este Equipo durante la sesión, y presentarlas al PO en formato tabla:

```
## 🔵 EQUIPO [NOMBRE] — Oportunidades detectadas

| # | Cliente | Oportunidad | Producto Gestión |
|---|---|---|---|
| 1 | [Cliente] | [Descripción breve] | `[ID Gestión]` |
| 2 | ... | ... | ... |
```

**Verificación obligatoria en Zoho CRM** antes de preguntar al PO:
Para cada oportunidad detectada, comprobar si ya existe Deal abierto relacionado en Zoho CRM:
1. Llamar a `ZohoCRM_getDealsRecords` (módulo Deals) ordenando por `Modified_Time desc`
   con suficiente paginación para cubrir el cliente
2. Filtrar mentalmente por `Account_Name` que corresponda al cliente
3. Descartar Deals con `Stage` en `Cerrada Ganada`, `Cerrada Perdida` o `Cerrada Perdida Competidor`
4. Si hay Deal abierto existente cuyo nombre/contenido encaje con la oportunidad detectada,
   marcar la fila como ⚠️ "Ya existe Deal abierto: [Deal_Name]"
5. Si no hay Deal abierto que encaje, marcar la fila como ❌ "NO — Crear nueva propuesta"

Presentar el resultado de la verificación al PO en una tabla extendida:

```
| # | Cliente | Oportunidad | Deal abierto en Zoho CRM | Acción sugerida |
|---|---|---|---|---|
| 1 | [Cliente] | [...] | ❌ NO | Crear nueva propuesta |
| 2 | [Cliente] | [...] | ⚠️ Sí — [Deal_Name] | Actualizar nota en Deal existente |
```

Después preguntar:

```
¿Para cuáles quieres que cree propuesta comercial usando la skill
`propuesta-comercial-zoho-crm-reinicia`? Y si son varias, ¿en qué orden?

(Puedes decir "ninguna de momento" si prefieres esperar)
```

→ Si el PO confirma una o varias → activar la skill `propuesta-comercial-zoho-crm-reinicia`
   por cada una, en el orden indicado.
→ Si el PO dice "ninguna de momento" → anotar como pendiente para próxima sesión y
   continuar con 3.8.3.

### 3.8.3 Consolidación de Impedimentos del Equipo

Recopilar **todos los impedimentos** detectados en los comentarios de Gestión publicados
en este Equipo durante la sesión, y presentarlos clasificados por accionabilidad:

```
## 🔵 EQUIPO [NOMBRE] — Impedimentos detectados

| # | Cliente | Impedimento | Producto Gestión |
|---|---|---|---|
| 1 | [Cliente] | [Descripción breve] | `[ID Gestión]` |
| ...
```

**Clasificación obligatoria por accionabilidad**, presentada al PO como secciones separadas:

- **🔴 Accionables individuales** — impedimentos con acción específica para un cliente concreto
  (guion para llamada con stakeholder, plan de escalado a un soporte de Zoho, plan de migración
  de un proveedor, etc.). Listar cada uno.

- **🟡 Accionables transversales** — impedimentos que afectan a varios clientes y conviene
  trabajar en bloque (típicamente cargas de personas del equipo Reinicia o Amigos Reinicia
  que se repiten en varios proyectos). Agrupar por persona/equipo afectado.

- **🟢 Vigilancia sin acción inmediata** — riesgos a monitorizar pero sin acción concreta
  hoy (ej. dependencia de un proveedor estable, decisión de cliente que aún no urge).

- **✅ Ya resueltos en los comentarios** — impedimentos para los que el comentario publicado
  ya incluye sugerencia explícita (ej. "Sugerencia: mover a parking"), y no requieren
  propuesta adicional.

Después preguntar:

```
¿Quieres que prepare propuesta concreta para abordar alguno de estos impedimentos?

1. [Impedimento accionable 1]
2. [Impedimento accionable 2]
...
N. Ninguno, no quiero trabajar ningún impedimento ahora

¿Sobre cuál quieres que te sugiera cómo abordarlo?
```

**Iterar** según el flujo:
- El PO elige uno → analizar en contexto y proponer 2-3 sugerencias concretas y accionables
  (que tengan en cuenta tipo de proyecto, herramientas Reinicia, relación cliente, recursos)
- Volver a mostrar el listado sin el impedimento tratado → preguntar si quiere otro
- Iterar hasta que el PO elija "ninguno más"

**Notas:**
- No registrar las sugerencias en ClickUp salvo que el PO lo pida explícitamente
- Si el PO elige "ninguno" desde el principio, no insistir
- Las sugerencias son orientativas — el PO decide si las aplica o no

### 3.8.4 Cierre formal del Equipo

Al terminar 3.8.1 + 3.8.2 + 3.8.3, cerrar formalmente el Equipo:

```
✅ EQUIPO [NOMBRE] cerrado.

- Oportunidades consolidadas: [N] · Propuestas creadas: [M] · En monitorización: [N-M]
- Impedimentos consolidados: [N] · Propuestas trabajadas: [M] · Sin acción: [N-M]

¿Continuamos con el siguiente Equipo o cerramos la sesión?
```

→ Pasar al siguiente Equipo (volver a Paso 2) o al Paso 4 si no quedan más Equipos.

---

## PASO 4 — AL FINALIZAR TODOS LOS EQUIPOS

### 4.1 Estado de Oportunidades e Impedimentos
Este punto **ya se ha cubierto al cerrar cada Equipo en el Paso 3.8** (consolidación
estructurada). No se vuelve a preguntar al final de la sesión global salvo que el PO
lo solicite explícitamente o haya quedado algún Equipo pendiente.

### 4.2 Plan de Proyecto
Una vez terminada la revisión de todos los Equipos y el trabajo con impedimentos/oportunidades,
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
→ Si el PO responde "no", continuar con el paso 4.3

### 4.3 Mejora de narración
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

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0 | 21/06/2026 | Néstor + Claude | Estado previo sin versionar, tabulado por primera vez al incorporar el estándar de versionado de Reinicia (21/06/2026). Procesamiento de transcripciones de Sprint Planning y actualización del backlog de ClickUp proyecto a proyecto. |
