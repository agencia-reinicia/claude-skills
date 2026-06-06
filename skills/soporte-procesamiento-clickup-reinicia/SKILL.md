---
name: soporte-procesamiento-clickup-reinicia
description: Procesa tareas brutas de soporte llegadas por formulario ClickUp en las listas Soporte [CLIENTE] de los clientes activos configurados en la sección 2 de la skill (15 clientes en v1.11 — Equipo Proactive y Columbia). Aplica el patrón canónico de tarjeta editando SIEMPRE el form_response original (jamás creando canónicas paralelas), clasifica dominio (Zoho/Web/WABA), asigna PO Técnico y PO Cliente, publica comentario con propuesta de nivel de servicio, detecta duplicados, mueve a Product Backlog y publica resumen diario en la tarea mensual del cliente. Activación manual ("procesa el soporte", "refina el soporte") o desde tarea programada de Cowork (Lun–Vie 08:00/11:00/14:00/17:00/22:00 Europe/Madrid). No usar para productos en General ni para microcampañas.
triggers:
  - procesa el soporte
  - procesa las tareas de soporte
  - revisa el soporte de los clientes piloto
  - revisa el soporte de los clientes
  - procesa las tareas brutas de soporte
  - refina el soporte
---

# SKILL: Procesamiento Automático de Soporte ClickUp — Reinicia

## Propósito

Cuando un cliente rellena un formulario de ClickUp asociado a su lista `Soporte [CLIENTE]`, ClickUp crea automáticamente una tarea en estado `Open` con `taskType: "form_response"`. La descripción se rellena con los pares pregunta/respuesta del formulario tal como los escribió el cliente, sin estructura adicional. El nombre suele incluir un identificador automático del formulario y un timestamp, no el nombre operativo del trabajo.

Esta skill convierte esa tarea bruta en una tarjeta lista para sprint:

1. Detecta tareas brutas pendientes en las listas `Soporte [CLIENTE]` de los clientes activos configurados en la sección 2.
2. Clasifica el dominio del trabajo (Zoho CRM / Web / WABA / mixto).
3. Aplica el patrón canónico de `formato-tarjeta-clickup-reinicia` (sección 2.4) **editando el propio form_response** (sección 5.0) y preservando la descripción original literalmente en el bloque "📥 Requerimientos Cliente".
4. Renombra siguiendo la convención `[TIPO] [Descripción] [CLIENTE]`.
5. Rellena los campos personalizados estándar.
6. Asigna a las personas correctas según el equipo del cliente (Proactive o Columbia).
7. Publica un comentario al PO Técnico con preguntas pendientes y propuesta de nivel de servicio.
8. Detecta posibles duplicados informativamente.
9. Cambia el estado a `Product Backlog`.
10. Una vez al día, publica un resumen consolidado en la tarea mensual del cliente.

Las skills madre (`productos-digitales-zoho-clickup-reinicia`, `productos-digitales-web-clickup-reinicia`, `productos-digitales-waba-clickup-reinicia` y `formato-tarjeta-clickup-reinicia`) son la **fuente de verdad** sobre cómo se redacta el contenido. Esta skill las orquesta — no replica su lógica.

---

## 1. Cuándo se ejecuta

### 1.1 Disparo manual

El PO escribe en una conversación de Claude alguno de los triggers (`procesa el soporte`, `refina el soporte`, etc.). Claude ejecuta el flujo completo sobre las listas configuradas y reporta el resultado en chat.

### 1.2 Disparo programado (Claude Cowork)

La skill se registra como **tarea programada de Claude Cowork** con cadencia **de lunes a viernes a las 08:00, 11:00, 14:00, 17:00 y 22:00 (Europe/Madrid)**. La tarea programada usa exactamente el siguiente prompt como instrucciones:

```
Aplica la skill soporte-procesamiento-clickup-reinicia.

Procesa todas las tareas brutas de soporte pendientes (form_response en estado Open
en cuya conversación de comentarios NO aparezca el comentario-marker "Primer
Refinamiento Individual Realizado") en las listas Soporte [CLIENTE] de TODOS los
clientes configurados en la sección 2 de la skill. No enumeres clientes en este
prompt: la sección 2 de la skill es la única fuente de verdad. Si un cliente tiene
lista Soporte en ClickUp pero NO está en la sección 2, no lo proceses y regístralo
como pista (no se puede asignar PO sin su fila en la sección 2).

Cadencia: esta tarea se ejecuta de lunes a viernes a las 08:00, 11:00, 14:00, 17:00
y 22:00 (Europe/Madrid). Cada ejecución arranca sin memoria de las anteriores:
reconstruye el contexto leyendo ClickUp. La marca de "ya procesada" vive en la propia
tarea como comentario — respeta la idempotencia de todos los markers (sección 1.3).

Resumen consolidado diario (identifica la pasada por su posición en el calendario
del cron, NO por la hora de reloj — ver sección 12.1):
- En la ÚLTIMA pasada programada del día (hoy, la de las 22:00) publica el resumen
  consolidado en la tarea mensual de cada cliente con actividad sin resumir. La
  ventana es "desde el último resumen publicado hasta ahora" (sección 12.1): en
  lunes abarca automáticamente viernes-noche, fin de semana y lunes. Respeta el
  marker de resumen (sección 12.5) para no duplicarlo.
- En las pasadas intermedias (11:00/14:00/17:00) NO publiques resumen. En la PRIMERA
  pasada del día (08:00) tampoco, salvo recuperación: si la última pasada del día
  hábil anterior no publicó, publicálo entonces.

Modelo: Opus 4.8.
```

**Nota:** se evita listar los clientes en el prompt para no obligar a actualizarlo cada vez que cambia la tabla. La fuente de verdad es siempre la sección 2. El `Primer Refinamiento Individual Realizado` es un **comentario** en la form_response (no un tag de ClickUp; ver sección 1.3) y se comprueba leyendo comentarios con `clickup_get_task_comments` + `clickup_get_threaded_comments`, nunca por etiquetas.

**Expresión cron equivalente** (Europe/Madrid): `0 8,11,14,17,22 * * 1-5`.

**Cuando la sesión empieza nueva cada vez (sin memoria entre ejecuciones):** la skill reconstruye todo el contexto leyendo ClickUp en cada ejecución. La marca de "ya procesada" vive en la propia tarea (comentario "Primer Refinamiento Individual Realizado" + estado de backlog), no en memoria local.

### 1.3 Glosario de markers (v1.9)

La skill deja marcas de texto exacto en comentarios y descripciones para coordinar su propio comportamiento entre ejecuciones (recordar que no hay memoria local — la única persistencia es lo que queda escrito en ClickUp). Esta tabla es la **fuente de verdad única** de todos los markers. Cualquier cambio de literal se hace aquí primero y luego en la sección correspondiente.

| Marker (literal exacto) | Dónde vive | Propósito | Sección |
|---|---|---|---|
| `Primer Refinamiento Individual Realizado` | Comentario en la form_response | Flag de "ya procesada" (gate de último paso) | 8.6 |
| `Primer Refinamiento Realizado por Soporte — resumen` | Comentario en la tarea mensual | Identificar el resumen diario previo y no duplicarlo | 12.5 |
| `[Refinamiento Automático]` (sufijo) | `description` del time entry | Filtro de tiempo del cron en informes | 10.5 |
| `Requerimientos Cliente preservados por skill` | Comentario en form_response con diálogo de equipo | Preservación literal opción (c) sin pisar al equipo | 3.8 |
| `Pista 14.6 — Procesamiento Soporte Skill` | Comentario en tarea no-form_response | Anti-repetición de pistas entre ejecuciones | 14.6 / 13.3 |
| `Pista 14.7 — Procesamiento Soporte Skill` | Comentario en form_response antigua | Anti-repetición de pistas entre ejecuciones | 14.7 / 13.3 |

**Regla transversal:** antes de publicar cualquiera de estos markers, la skill comprueba si ya existe en la tarea (vía `clickup_get_task_comments` + `clickup_get_threaded_comments`). Si ya está, no lo duplica. Esto vale tanto para idempotencia del procesamiento como para la anti-repetición de pistas.

---

## 2. Configuración de clientes

Tabla canónica que la skill debe respetar. Cualquier cambio (nuevos clientes, nuevos equipos, activación de Cliq) se hace aquí.

> **Nota terminológica.** En v1.0 esta tabla se llamaba "clientes piloto" y contenía 4 clientes (HomeEspaña, Carritech, Gonher, Avaderm). Desde v1.6 la skill cubre todos los clientes activos con lista `Soporte [CLIENTE]` en ClickUp. El concepto de "piloto" se mantiene únicamente en lo que respecta al flag `cliq_publish` (todos los clientes arrancan con publicación en Cliq desactivada y se activa cliente a cliente tras validar el procesamiento — ver sección 15).

| Cliente | Equipo | Lista Soporte | Lista Gestión | PO Técnico | PO Cliente | Canal Cliq | Cliq publish |
|---|---|---|---|---|---|---|---|
| HomeEspaña | Proactive | `901216563068` | `900501350944` | Paolo Bergamelli | Óscar Díez | `O45816000002429005` (#HomeEspaña) | `false` |
| Carritech | Proactive | `901215748066` | `901207893946` | Fabián Vargas | Óscar Díez | `carritech` (no joined — pendiente añadir a Álvaro) | `false` |
| Gonher | Columbia | `901209826214` | `901205582846` | Paolo Bergamelli | Pablo Losada | `O45816000003006001` (#Gonher) | `false` |
| Avaderm | Columbia | `901210493032` | `901202330083` | Paolo Bergamelli | Pablo Losada | `O45816000002403009` (#Avaderm) | `false` |
| Aicrov | Columbia | `901211019222` | `901208017268` | Fabián Vargas | Pablo Losada | `Aicrov` (pendiente validar acceso) | `false` |
| Aunna | Proactive | `900502439069` | `900502395956` | Fabián Vargas | Óscar Díez | `Aunna` (pendiente validar acceso) | `false` |
| Breezom | Proactive | `901208402881` | `162734856` | Fabián Vargas | Óscar Díez | `Breezom` (pendiente validar acceso) | `false` |
| Estarima | Columbia | `901201751766` | `901201375273` | Paolo Bergamelli | Pablo Losada | `Estarima` (pendiente validar acceso) | `false` |
| Inefso - Dinam | Proactive | `901214051309` | `901212796422` | Fabián Vargas | Óscar Díez | `Inefso - Dinam` (pendiente validar acceso) | `false` |
| ISL Agency | Proactive | `901210160571` | `901202035644` | Paolo Bergamelli | Óscar Díez | `ISL Agency` (pendiente validar acceso) | `false` |
| Kasblan | Columbia | `901210063464` | `901201259611` | Paolo Bergamelli | Pablo Losada | `Kasblan` (pendiente validar acceso) | `false` |
| Líder System Grupo | Columbia | `211763780` | `211763776` | Paolo Bergamelli | Pablo Losada | `LiderSystemGrupo` (pendiente validar acceso) | `false` |
| Synuptic | Proactive | `901211050939` | `901209493933` | Rolf Pinto | Óscar Díez | `Synuptic` (pendiente validar acceso) | `false` |
| Timedi | Proactive | `901212583005` | `900800044927` | Paolo Bergamelli | Óscar Díez | `Ti Medi` (pendiente validar acceso) | `false` |
| Worldwide Boat | Proactive | `901208726321` | `3609221` | Paolo Bergamelli | Óscar Díez | `Worldwideboat` (pendiente validar acceso) | `false` |

**IDs de personas en ClickUp:**

| Persona | ClickUp ID | Rol habitual |
|---|---|---|
| Paolo Bergamelli | `2447443` | PO Técnico (Lead Tech / Web / Zoho) |
| Fabián Vargas | `93744950` | PO Técnico (Zoho) |
| Rolf Pinto | `99603566` | PO Técnico (Zoho / Web — Synuptic) |
| Óscar Díez | `93631901` | PO Cliente Equipo Proactive |
| Pablo Losada | `87715920` | PO Cliente Equipo Columbia |
| Néstor Tejero | `766716` | Director / referente para warnings |

**Nota sobre Cliq durante el piloto:** Todos los clientes arrancan con `cliq_publish: false`. La skill **no publica nada en Cliq durante esta fase**. Cuando se valide el procesamiento, se activará cliente a cliente cambiando el flag a `true`. Ver sección 15.

**Nota sobre canales pendientes de validar acceso:** Para los clientes incorporados en v1.6, el `unique_name` del canal Cliq se ha registrado tal como lo proporcionó el PO líder, pero **no se ha verificado que el usuario autenticado tenga acceso (joined)** al canal. Antes de activar `cliq_publish: true` en cualquiera de estos clientes, hay que comprobar con `ZohoCliq_List_all_channels` que el canal aparece en la lista. Si no aparece, hay que añadir a Álvaro al canal. Mientras `cliq_publish` sea `false`, esto no bloquea el procesamiento.

**Nota sobre canales no listados:** Si al buscar un canal por nombre o por unique_name en `ZohoCliq_List_all_channels` la API devuelve un canal que el usuario autenticado no tiene joined, no aparecerá en los resultados. En ese caso, la skill avisa al PO indicando que **debe añadir a Álvaro al canal** para que el procesamiento pueda detectarlo y, eventualmente, publicar.

---

## 3. Detección de tareas brutas

La skill busca en cada lista de Soporte de la tabla las tareas que cumplan **todos** estos criterios:

### 3.1 Filtro principal (señal infalible)

- `taskType` = `"form_response"`. Esta es la marca que ClickUp pone automáticamente a cualquier tarea creada vía formulario. Es el filtro definitivo para distinguir tareas brutas de tareas creadas a mano.

### 3.2 Filtros corroborantes (orden, todos deben cumplirse)

- **Estado actual = `Open`**. El estado inicial al crearse desde formulario. Si la tarea ya está en `Product Backlog` o cualquier otro estado posterior, se ignora — significa que ya fue procesada o que el PO la promovió manualmente.
- **Sin comentario "Primer Refinamiento Individual Realizado"**. Si lo tiene, ya fue procesada por la skill y no hay que tocarla.
- **Sin bloque `## 📥 Requerimientos Cliente` en la descripción**. Si lo tiene, la descripción ya está en formato canónico. Skip.
- **Sin comentarios sustantivos del equipo Reinicia** (filtro v1.1). Si la tarea ya tiene comentarios de cualquier miembro del equipo Reinicia (excluyendo ClickBot y excluyendo comentarios autogenerados del formulario), la skill **NO la procesa**: pisaría trabajo en curso. La salta con un warning en el reporte final tipo "Tarea X saltada: ya tiene diálogo del equipo vivo (N comentarios)." La decisión de aplicar el patrón canónico retroactivamente queda para el PO manualmente. Esto cubre tres casos prácticos: (a) tareas que el equipo ha empezado a refinar conversacionalmente sin formalizar, (b) tareas en las que el cliente ha aclarado por comentarios la petición original, (c) tareas con diagnóstico previo donde la conversación ya es más útil que el patrón canónico. **Acción aditiva (v1.9):** aunque la skill no procese estas tareas, sí preserva la petición original literal en un comentario — ver sección 3.8.

### 3.3 Señales débiles corroborantes (no bloqueantes pero indicativas)

- **`time_spent > 5 minutos` sin patrón canónico**. Indicador de que alguien del equipo ha tocado la tarea. Combinado con la regla 3.2 sobre comentarios del equipo, refuerza la decisión de no procesar. Si solo aparece esta señal (tiempo registrado pero ningún comentario), la skill procesa pero **añade un aviso en el comentario al PO Técnico** (sección 8.2 v1.1) reconociendo el tiempo registrado.
- **`REFINADO = true` sin patrón canónico aplicado**. Caso ambiguo: el PO Técnico marcó la tarea como refinada pero no documentó el refinamiento en la descripción canónica. La skill procesa igualmente devolviendo REFINADO a `false`, pero **añade un párrafo explícito en el comentario al PO Técnico**: "He detectado que la tarea estaba marcada como REFINADO=true sin patrón canónico aplicado. He aplicado el procesamiento estándar y devuelto REFINADO=false. Si ya la tenías validada, márcala de nuevo como REFINADO=true tras revisar la estructura." Respeta el criterio del PO en lugar de pisarlo silenciosamente.

### 3.4 form_response con duplicado canónico ya creado por error (v1.7)

Si una tarea cumple los criterios de form_response (sección 3.1 + 3.2) pero tiene `linked_tasks` no vacío apuntando a una tarjeta canónica con nombre `[TIPO] ... [CLIENTE]` en la misma lista de Soporte, **la skill procesa el form_response normalmente** (no la salta) y, adicionalmente, en el comentario al PO Técnico (sección 8.2) añade un párrafo:

> "Posible duplicado canónico erróneo detectado: la tarjeta linkada [URL] tiene nombre canónico y parece haber sido creada por una ejecución anterior de la skill que no respetaba la regla 5.0 (editar siempre el original). Recomiendo cerrar/eliminar la canónica linkada manualmente, ya que esta form_response es la fuente de verdad y queda procesada aquí."

La decisión final de eliminar el duplicado es siempre humana — la skill nunca borra tarjetas. Esta sección sustituye a la antigua 3.4 de v1.6 ("Excepción: tarea ya procesada que sigue en Open"), que pasa a 3.5.

### 3.5 Excepción: tarea ya procesada que sigue en Open

Si una tarea está en `Open` pero ya tiene el comentario "Primer Refinamiento Individual Realizado", la skill la ignora — el PO la mantiene en `Open` por algún motivo y no debe re-procesarse.

### 3.6 Fallback de seguridad — tarea rara

Si una tarea está en `Open` con `taskType: "form_response"` pero no encaja en ninguno de los patrones esperados (descripción vacía, contenido inesperado, etc.), la skill no la salta: aplica el procesamiento estándar **preservando la descripción original íntegra** en el bloque "📥 Requerimientos Cliente". Cero pérdida de trazabilidad. Caso especial de descripción vacía o solo plantilla genérica — ver sección 14.8.

### 3.7 Herramientas

- `clickup_filter_tasks` con `statuses=["Open"]`, **iterando lista por lista** (un solo `list_ids=[<una lista>]` por llamada), recorriendo en bucle las listas Soporte de todos los clientes de la sección 2. **No** consultar varias listas en una sola llamada: el filtro multi-lista falla de forma intermitente, mientras que la consulta de una sola lista responde con fiabilidad (validado 01/06). Ante un error de conector en una lista, reintentar esa lista 2-3 veces con una espera breve antes de marcarla como no consultada en este ciclo (y reportarla como pista si sigue fallando).
- Para cada tarea retornada, verificar `taskType` en el campo `task_type` de la respuesta y, si es `form_response`, llamar `clickup_get_task` con `subtasks=true` para tener el detalle completo.
- `clickup_get_task_comments` y `clickup_get_threaded_comments` para verificar la marca de procesamiento, comentarios sustantivos del equipo, y otros comentarios existentes. Filtrar por `user.id` distinto de `-1` (ClickBot) para identificar comentarios humanos.

### 3.8 Preservación literal en tareas con diálogo de equipo — opción híbrida (v1.9)

Cuando una tarea se salta por el cuarto filtro corroborante de la sección 3.2 (**ya tiene comentarios sustantivos del equipo Reinicia**), la skill **no aplica el patrón canónico** — respeta el diálogo vivo del equipo y no pisa nada. Pero, para no perder la submisión original del cliente si el equipo empezó a conversar antes de formalizarla, la skill ejecuta una única acción aditiva:

1. Comprueba si la tarea ya tiene un comentario con el marker `Requerimientos Cliente preservados por skill`. **Si lo tiene, no hace nada** (idempotencia — ya se preservó en una ejecución anterior).
2. **Si no lo tiene**, publica un comentario con la petición original **literal** del formulario:

```
Requerimientos Cliente preservados por skill

Petición original del cliente — formulario ClickUp — [fecha de creación de la tarea bruta]

[CONTENIDO LITERAL DE LA DESCRIPCIÓN AUTO-GENERADA POR EL FORMULARIO,
sin resumir, reformular ni omitir campos.]

[Nombre original de la tarjeta tal como llegó del formulario]
```

**La skill no toca nada más:** ni el nombre, ni los campos personalizados, ni el estado, ni crea subtareas, ni imputa tiempo. Solo añade ese comentario.

**Por qué:** la convención v1.1 ("no pisar al equipo") sigue intacta — la skill sigue sin aplicar el patrón canónico sobre estas tareas. La única diferencia es que la submisión original del cliente queda capturada como comentario aunque el equipo ya esté trabajando encima, evitando que se pierda si la descripción se reescribe en la conversación. Es una acción mínima, aditiva y reversible.

**Registro de pista:** la skill sigue dejando el warning en el reporte ("Tarea X saltada: ya tiene diálogo del equipo vivo") como hasta ahora, añadiendo "(petición original preservada)" si publicó el comentario en esta ejecución.

---

## 4. Clasificación de dominio

Para cada tarea bruta detectada, la skill clasifica el dominio del trabajo. Esto determina **qué skill madre aplicar** para construir el contenido enriquecido.

### 4.1 Dominios posibles

| Dominio | Skill madre asociada | Tipo de Producto en ClickUp |
|---|---|---|
| Zoho CRM | `productos-digitales-zoho-clickup-reinicia` | CRM |
| Web | `productos-digitales-web-clickup-reinicia` | DESARROLLO WEB |
| WABA | `productos-digitales-waba-clickup-reinicia` | (a definir — habitualmente WHATSAPP CORPORATIVO) |
| Mixto | la dominante + nota en comentario | El de la dominante |

### 4.2 Cómo clasifica

Claude lee:
- El bloque "📥 Requerimientos Cliente" (descripción auto-generada del formulario).
- El nombre original de la tarea (puede contener pistas como "WordPress", "Zoho Forms", "WhatsApp"…).
- El contexto del cliente: Carritech es CRM puro, HomeEspaña es Web+CRM, Gonher es CRM+App+Web, Avaderm es CRM+integraciones.

Con esa información decide el dominio dominante. Si hay duda razonable entre dos dominios (ej. "fallo en formulario que envía leads a Zoho CRM" — ¿Web o CRM?), elige el que mejor representa **dónde está el trabajo de resolución**, no dónde se manifiesta el síntoma. En el ejemplo: si el formulario es Zoho Forms, dominio = CRM; si es Gravity Forms en WordPress, dominio = Web.

### 4.3 Si no es clasificable con confianza

Si Claude no puede clasificar con confianza ≥ 70%, **no clasifica como Mixto** — deja el dominio como **"Por confirmar"** y lo refleja explícitamente en el comentario al PO Técnico (sección 8.2): "No he podido determinar el dominio con confianza. Hipótesis: [A] o [B]. ¿Cuál aplica?"

---

## 5. Aplicación del patrón canónico

### 5.0 Regla absoluta — la skill SIEMPRE edita el form_response original (v1.7)

La skill aplica el patrón canónico **modificando la tarjeta form_response detectada en la sección 3** mediante llamadas `clickup_update_task` (nombre, descripción, campos personalizados, asignados, estado).

**Está terminantemente prohibido** que la skill llame `clickup_create_task` para crear una versión canónica paralela del form_response. La única `clickup_create_task` permitida en todo el flujo es la de las 4 subtareas hijas de la sección 9, que se crean con `parent` apuntando al propio form_response.

Si la skill detecta una situación donde "tendría sentido" crear una tarjeta nueva (ej. el form_response viene con campos que no se pueden modificar, contenido roto, etc.), la respuesta correcta es **aplicar el fallback de seguridad de la sección 3.6** preservando la descripción literal y avisando al PO Técnico — nunca crear una tarjeta paralela.

Esta regla existe porque (a) el form_response es la fuente de verdad del cliente y romper la trazabilidad con la submisión original deja huérfanos en producción, (b) crear tarjeta nueva genera duplicados que el PO tiene que limpiar a mano, y (c) las versiones paralelas pierden los adjuntos del formulario original que ClickUp guarda solo en la form_response.

Esta regla se introduce en v1.7 tras detectar en la ejecución del 2026-05-06 cuatro tarjetas canónicas erróneas en Soporte Carritech (`869d5zpe6`, `869d5zpyb`, `869d5zq6u`, `869d5zqv7`) creadas por una ejecución previa del cron que no respetaba este principio. Limpieza retroactiva: ver sección 14.6 + auditoría one-shot recomendada al deployar v1.7.

### 5.1 Bloques fijos

La skill construye la nueva descripción siguiendo la sección 2 de `formato-tarjeta-clickup-reinicia`. Bloques fijos siempre presentes; los opcionales se incluyen solo si aplican.

```markdown
> 🎯 **RESUMEN**
> [Resumen de qué hace el producto en 1-3 líneas]
> **Entrega:** [qué se entrega al cierre]

## 📌 Historia de usuario
Como **[rol cliente o usuario afectado]**, **QUIERO** [necesidad], **PARA** [beneficio].

## 📋 Descripción
- **Web:** [URL del cliente]
- **Idiomas:** [si aplica]
- **Objetivo Cliente:** [una frase que resume qué quiere conseguir]
- **Objetivo del Producto:** [una frase que resume qué entregamos]
- **Público objetivo:** [si aplica — clientes finales, equipo interno, etc.]

## 📥 Requerimientos Cliente
> Petición original del cliente — formulario ClickUp — [fecha de creación de la tarea bruta]

[CONTENIDO LITERAL DE LA DESCRIPCIÓN AUTO-GENERADA POR EL FORMULARIO,
SIN RESUMIR, REFORMULAR NI OMITIR CAMPOS. Mantener las preguntas originales
del formulario y las respuestas del cliente exactamente como las escribió.]

[Nombre original de la tarjeta tal como llegó del formulario]

## ✅ Ready to Backlog
- [Condiciones específicas — accesos, credenciales, datos confirmados]

## 🌍 Contexto
[Si hay contexto operativo claro: histórico, sistemas afectados, urgencia.
Si no: "No definida."]

## 📦 Entregables

**Reinicia (interno):**
- [Entregable interno si aplica]

**Cliente:**
- [Lo que se entrega al cliente — corrección, mejora, formación, etc.]

## 📚 Documentación de referencia
- [Sprint Cero del cliente, propuesta comercial, actas relevantes — buscar en Workdrive]

---

## 🏁 Resultado y cierre
> ⚠️ Bloque diferido — se completa al cierre del producto siguiendo el flujo formal de cierre (skill `formato-tarjeta-clickup-reinicia`, sección 11).

[Placeholder estándar con los 6 sub-bloques de cierre — ver sección 2.12 de formato-tarjeta-clickup-reinicia]
```

### 5.2 Regla de preservación literal — sección 2.4 de `formato-tarjeta-clickup-reinicia`

Esta es la regla más crítica. Antes de construir cualquier otro bloque, la skill:

1. Lee la descripción auto-generada por el formulario tal como está, sin alterarla.
2. Copia ese contenido íntegro y literal al bloque "📥 Requerimientos Cliente". Mantiene preguntas originales del formulario, respuestas del cliente, nombre original de la tarjeta tal como llegó, y cualquier metadato (timestamp del formulario, identificador de submisión).
3. Construye el resto del patrón canónico **alrededor** como capa de interpretación profesional.

**Si la descripción contiene información sensible** (correos largos, datos personales no relevantes), la skill la incluye igualmente — la decisión de editar la toma el PO, no la skill. Comentario opcional al PO Técnico avisando: "He detectado posible información sensible en la petición original. Revisa si conviene editarla antes de continuar."

### 5.3 Bloques opcionales

- **`## 🎯 Alcance`** — incluir solo si la incidencia tiene riesgo claro de scope creep (cliente exigente, petición ambigua, varias funcionalidades implícitas). En soporte habitual se omite.
- **`## 🧩 Hipótesis de solución a validar`** y **`## ❓ Preguntas a responder durante el SPIKE`** — solo si la incidencia se reclasifica como SPIKE (caso raro pero posible: cliente reporta algo que requiere investigación previa). Si ocurre, la skill lo nota en el comentario al PO Técnico y delega a `spike-clickup-reinicia` para esos bloques.

---

## 6. Renombrado de la tarea

Patrón canónico:

```
[TIPO] [Descripción corta operativa] [CLIENTE]
```

### 6.1 Tipos canónicos

| Tipo | Cuándo aplicarlo |
|---|---|
| `[BUG]` | Algo que funcionaba ha dejado de funcionar; comportamiento erróneo de un sistema en producción |
| `[MEJORA]` | Funcionalidad existente que el cliente quiere optimizar o ampliar puntualmente |
| `[DUDA]` | Pregunta del cliente sobre cómo usar el sistema o por qué hace algo |
| `[PETICIÓN]` | Solicitud nueva — pequeño desarrollo, ajuste de configuración, cambio de copy, alta de usuario |
| `[SOPORTE-SERVIDOR]` | Operativa de servidores, hosting, despliegues, logs, monitorización, copias |

### 6.2 Reglas de redacción

**Convención del nombre — fuente de verdad:** sigue la sección **2.13 "Convención del nombre de la tarjeta"** de `formato-tarjeta-clickup-reinicia`. Resumen aplicable aquí:

- **Principio rector**: el nombre describe el entregable en estado final, no la acción. Sustantivo o participio, nunca verbo en infinitivo.
- **Test rápido**: si el nombre puede ir precedido de *"Tarea: ___"* sin sonar raro, está en modo acción y hay que reformularlo. Si va precedido de *"Entregable: ___"* con naturalidad, está bien.
- **Hard cap de longitud**: la **descripción corta entre el `[TIPO]` y el `[CLIENTE]` debe ser ≤ 60 caracteres**. Si la descripción que se está generando supera los 60 caracteres, la skill debe abreviar **antes** de escribir, no después. Patrones útiles:
  - sustituir "Sales Quotes" por "SQs" cuando ya está claro por contexto
  - sustituir "Opportunities" por "Opps"
  - usar flechas `→` en lugar de "desde X a Y"
  - eliminar artículos (`de las`, `del`)
  - sustituir "automáticamente" por adjetivos equivalentes ("automatizado")
  - Si tras abreviar sigue por encima de 60 caracteres, partir el producto en dos productos hijos en lugar de tener un nombre largo.
- **CLIENTE** entre corchetes con la convención del cliente (`[GONHER]`, `[CARRITECH]`, `[HOMEESPAÑA]`, `[AVADERM]`).
- Si el formulario ya traía un patrón con timestamp tipo `Contact asocciation [CARRITECH] - #2026-03-24T16:55:54+01:00`, **se sustituye completamente** por el patrón canónico — el nombre original queda preservado en el bloque "📥 Requerimientos Cliente".

### 6.3 Ejemplos aplicados a soporte

Para incidencias de soporte concretamente — el matiz es el prefijo `[TIPO]` antes del entregable:

| Nombre original (formulario) | Nombre canónico tras procesamiento |
|---|---|
| `Contact asocciation [CARRITECH] - #2026-03-24T16:55:54+01:00` | `[BUG] Asociación de contactos en módulo Cuentas corregida [CARRITECH]` |
| `enhanced_conversions_form_2026_04_25` | `[PETICIÓN] Enhanced Conversions Google Ads configuradas desde Zoho Forms [HOMEESPAÑA]` |
| `Lupa de zoom solapa botón Guardar Pedido` | `[BUG][APP] Solape de lupa de zoom con botón Guardar Pedido resuelto [GONHER]` |
| `Agendas delegados[AVADERM]` | `[PETICIÓN] Campos obligatorios simplificados en módulo Visitas para delegados [AVADERM]` |

### 6.4 Herramienta

`clickup_update_task` con `name=[nuevo nombre]`. **Importante (regla 5.0)**: la skill NUNCA usa `clickup_create_task` para crear una tarjeta canónica nueva — siempre `update` sobre la form_response original.

---

## 7. Campos personalizados

La skill rellena los campos personalizados estándar. IDs documentados en las skills madre (`productos-digitales-zoho-clickup-reinicia`, `productos-digitales-web-clickup-reinicia`, `productos-digitales-waba-clickup-reinicia`).

### 7.1 Campos siempre rellenados

| Campo | Valor |
|---|---|
| `PROYECTO` | Cliente correspondiente (HOMEESPAÑA, CARRITECH, GONHER, AVADERM) |
| `TIPO DE PRODUCTO` | Según dominio clasificado: CRM / DESARROLLO WEB / WHATSAPP CORPORATIVO |
| `PO` | PO Cliente del equipo (`OSCAR` para Proactive, `PABLO` para Columbia) |
| `ÉPICA` | Habitualmente `05. ADOPTION` o `06. REPETITION` para soporte. Si la incidencia es de descubrimiento de bug grave que afecta a propuesta de valor, `04. CONVERSION`. Si es duda del usuario en uso normal, `05. ADOPTION` |
| `REFINADO` | `false` siempre |

### 7.2 Campos no rellenados

| Campo | Motivo |
|---|---|
| `ORDEN` | Lo asigna el PO en Sprint Planning. La skill nunca lo toca |
| `Tiempo estimado` | El PO lo asigna tras refinamiento técnico con el equipo |
| `AMIGOS REINICIA` | Solo si el dominio claramente involucra a un colaborador externo (ej. Síntaris para Carritech). Si hay duda, no se rellena |
| `PBIs PRIMER NIVEL` | Lo decide el PO. La skill no lo rellena |

### 7.3 Herramienta

`clickup_update_task` con `custom_fields=[{id, value}, ...]`. Los IDs y opciones de cada campo están en las skills madre — la skill de procesamiento las consulta antes de escribir.

---

## 8. Asignaciones y comentarios

### 8.0 Serialización de escrituras sobre una misma tarea (v1.9)

**Regla absoluta:** todas las escrituras de la skill sobre una misma tarjeta se ejecutan **en estricta secuencia, nunca en paralelo**. Esto aplica a los tres comentarios (8.2 comentario al PO Técnico → 8.4 criterios de aceptación → 8.6 marker de procesamiento) y a la creación de las subtareas (sección 9).

**Por qué:** el MCP de ClickUp tiene un límite de concurrencia. Al lanzar 3+ `clickup_create_task_comment` (o `create_task`) simultáneos sobre la misma tarea, las llamadas fallan con `"The connector's server isn't responding"`. Al reintentarse, además, el orden de respuesta del MCP puede alterar el orden cronológico de los comentarios (el marker quedaba publicado antes que el comentario al PO Técnico). Serializar elimina ambos problemas de raíz.

**Orden canónico de publicación de comentarios:**

1. Comentario al PO Técnico (8.2) — esperar confirmación de éxito.
2. Comentario de criterios de aceptación (8.4) — esperar confirmación de éxito.
3. Marker `Primer Refinamiento Individual Realizado` (8.6) — **solo si los pasos 1 y 2 confirmaron éxito** (ver gate en 8.6).

Si cualquiera de los pasos 1 o 2 falla tras un reintento serializado, **no se publica el marker** y la tarea se deja sin la marca de procesamiento: la siguiente ejecución del cron la volverá a tomar como bruta (sigue en `Open`, sin marker) y reintentará desde donde se quedó (sección 14.4). Mejor reprocesar que dejar la tarjeta marcada como completa con comentarios a medias.

**Subtareas (sección 9):** se crean también de una en una, en secuencia. Si se observa de nuevo el error de concurrencia en la creación de subtareas, esta misma regla ya las cubre.

### 8.1 Asignación de la tarea

Doble asignación según equipo:

- **HomeEspaña (Proactive, caso especial):** Paolo Bergamelli (`2447443`) + Óscar Díez (`93631901`)
- **Carritech (Proactive):** Fabián Vargas (`93744950`) + Óscar Díez (`93631901`)
- **Gonher (Columbia):** Paolo Bergamelli (`2447443`) + Pablo Losada (`87715920`)
- **Avaderm (Columbia):** Paolo Bergamelli (`2447443`) + Pablo Losada (`87715920`)

`clickup_update_task` con `assignees=[id1, id2]`. Reemplaza la lista de asignados que pudiera tener la tarea bruta.

### 8.2 Comentario al PO Técnico (Caso C de comentarios — texto plano)

Después de aplicar la descripción canónica, la skill publica un comentario en la tarea con:

```
[Si la tarea tiene un comentario previo con texto "Saltada por skill" del propio bot/usuario (caso v1.7):]
Corrección a comentario anterior:

El comentario previo "Saltada por skill ..." queda sin efecto. Se aplica el patrón
canónico estándar sobre esta form_response a partir de aquí.

@[PO Técnico]

Refinamiento inicial del producto basado en la petición del formulario.

Dominio clasificado: [CRM / Web / WABA / Por confirmar]

Nivel de servicio propuesto: [Soporte Operativo Continuo / Mejoras Evolutivas / Proyectos Nuevos]
Razonamiento: [1-2 líneas explicando por qué]

Preguntas pendientes a responder antes de Ready to Backlog:
- [Pregunta 1 — accesos, datos, alcance, prioridad]
- [Pregunta 2]
- [Pregunta N]

[Si el formulario no recoge solicitante (campo email/nombre del cliente):]
Solicitante en cliente: pendiente de identificar — la persona que rellenó el formulario no está en el bloque "Requerimientos Cliente" porque la descripción original no lo recoge. Se recomienda confirmar con [PO Cliente] quién hizo la petición desde [CLIENTE].

[Si REFINADO estaba en true al recibir la tarea (caso v1.1, sección 3.3):]
He detectado que la tarea estaba marcada como REFINADO=true sin patrón canónico aplicado. He aplicado el procesamiento estándar y devuelto REFINADO=false. Si ya la tenías validada, márcala de nuevo como REFINADO=true tras revisar la estructura.

[Si time_spent > 5 minutos al recibir la tarea (caso v1.1, sección 3.3):]
La tarea tenía [X] minutos de tiempo registrado al procesarla. Si ya habías investigado/diagnosticado, complementa la estructura con tus notas en un comentario adicional.

Acceso a referencias:
[URL Sprint Cero pública del cliente si está localizada]
[URL acta relevante si la hay]

[Si aplica — duplicado canónico erróneo de ejecución previa de la skill (v1.7, sección 3.4):]
Posible duplicado canónico erróneo detectado: la tarjeta linkada [URL] tiene nombre canónico [TIPO] [...] [CLIENTE] y parece haber sido creada por una ejecución anterior de la skill que no respetaba la regla 5.0 (editar siempre el original). Recomiendo cerrar/eliminar la canónica linkada manualmente — esta form_response es la fuente de verdad y queda procesada aquí.

[Si aplica — duplicado funcional ordinario:]
Posible duplicado de:
[Nombre y URL de la tarea sospechosa]

[Si no se han detectado duplicados:]
Posibles duplicados detectados: ninguno en lista Soporte [CLIENTE].
```

**Limitaciones de markdown en comentarios** (sección 6.1 de `formato-tarjeta-clickup-reinicia`): ningún formato. URLs en línea separada del texto descriptivo. Sin negrita, sin headers, sin listas formateadas.

**Mención al PO Técnico:** ClickUp permite mencionar usuarios en comentarios con `@[username]`. Verificar que el username funcione; si no, dejar el nombre en texto plano y la asignación en el campo `assignees` ya garantiza la notificación.

### 8.3 Niveles de servicio — definición canónica

Tres niveles, basados en la conversación HomeEspaña 23/03/2026 (Paolo + Kieran):

- **Soporte Operativo Continuo:** mantenimiento de servidores, entornos, actualizaciones, gestión de incidencias recurrentes en sistemas en producción. Bolsa de horas mensual fija (~6h/mes). Plantilla referencia: `Soporte Operativo Continuo 1.01` (Workdrive `o16et26cabb411f5a49e98c4eaa28ee2288a5`).
- **Mejoras Evolutivas:** crédito de horas operativas para incidencias, dudas, pequeños arreglos, ayudas puntuales. Contratación flexible. Plantilla: `Crédito Mejoras Evolutivas 1.00` (`nx8q7144b1fc0de214c649bfd122aa25ffdd0`).
- **Proyectos Nuevos:** funcionalidades nuevas que requieren diseño funcional + presupuesto cerrado. Si la incidencia escala a esto, la tarea de Soporte se mantiene como traza pero se crea un producto en `General [CLIENTE]` que sustituye al flujo de soporte.

La skill propone uno con razonamiento. La decisión final es del PO Técnico — la skill nunca rellena campos relacionados con el nivel de servicio automáticamente.

### 8.4 Comentario con criterios de aceptación (Caso A)

Tras el comentario al PO Técnico, la skill publica un segundo comentario con los criterios de aceptación listos para que el PO los copie al checklist (ClickUp no permite crear checklists vía MCP — limitación documentada en sección 7 de `formato-tarjeta-clickup-reinicia`).

```
CRITERIOS DE ACEPTACIÓN — para copiar manualmente al checklist

[Técnicos] Acceso a [sistema afectado] verificado
[Técnicos] Reproducción del bug en entorno controlado [si aplica]
[Funcionales] [Comportamiento esperado tras la intervención]
[De proceso] Validación interna por Reinicia
[De proceso] Validación cliente
[De proceso] Comunicación de cierre al solicitante
```

Una línea por criterio. Categoría en corchetes como prefijo. Sin headers, sin negrita.

### 8.5 Detección de duplicados (informativo)

Antes de finalizar, la skill busca en la misma lista de Soporte tareas con título similar, cuerpo similar o que mencionen los mismos sistemas. Usa `clickup_search` con keywords del bloque "📥 Requerimientos Cliente".

Si encuentra una candidata con similitud razonable:

1. **No bloquea** el procesamiento de la nueva tarea.
2. **Añade un párrafo** al comentario al PO Técnico (sección 8.2): "Posible duplicado de [nombre y URL]".
3. **Crea enlace bidireccional** vía `clickup_add_task_link` entre la nueva tarea y la sospechosa.

La decisión de fusionar/cerrar/marcar la duplicada es siempre humana.

### 8.6 Comentario de marca de procesamiento (gate de último paso)

Como **último paso antes de mover el estado**, y **solo tras confirmar el éxito de los comentarios 8.2 y 8.4** (ver regla de serialización 8.0), la skill publica un comentario corto:

```
Primer Refinamiento Individual Realizado
```

Sin formato. Sin firma adicional. Solo ese texto. Cumple dos funciones:

1. **Trazabilidad operativa** — el equipo y el cliente (que tiene acceso a algunas listas) ven que la tarjeta ha pasado por una primera revisión.
2. **Flag técnico para la skill** — al re-ejecutarse, la skill busca este comentario para confirmar que la tarea ya fue procesada (sección 3.2).

**Por qué es un gate:** este marker es la señal de "tarea completa". Si se publicara antes de confirmar que el comentario al PO Técnico y los criterios se escribieron bien, una tarea con comentarios a medias quedaría marcada como procesada y nunca se reintentaría. Publicándolo en último lugar y condicionado al éxito de los anteriores, una interrupción a media ejecución deja la tarea sin marker → la siguiente ejecución la retoma (sección 14.4).

Antes de publicarlo, la skill comprueba que el marker no exista ya (idempotencia — sección 1.3). La hora del procesamiento queda registrada nativamente por ClickUp en el comentario; no hace falta añadir timestamp manualmente.

---

## 9. Creación de subtareas

Tras aplicar la descripción canónica, los campos personalizados, las asignaciones y los comentarios, la skill **crea las subtareas estándar** que descomponen el trabajo de soporte en pasos concretos.

### 9.1 Patrón mínimo (a) — vigente en v1.4+

Cuatro subtareas siempre, en este orden:

| # | Nombre subtarea | Asignado por defecto |
|---|---|---|
| 1 | Investigación / Reproducción del caso | PO Técnico |
| 2 | Implementación | PO Técnico |
| 3 | Validación Reinicia | PO Técnico |
| 4 | Validación Cliente | PO Cliente |

**Razonamiento de la asignación por defecto:** las tres primeras subtareas son trabajo del equipo técnico; la cuarta es validación desde el lado del cliente y se asigna directamente al PO Cliente para darle visibilidad anticipada de que cuando llegue el momento es suya, sin reasignaciones manuales posteriores.

### 9.2 Cómo se crean

Cada subtarea es una tarea independiente en la **misma lista de Soporte** del cliente, con `parent` apuntando a la tarjeta principal (que es la propia form_response — ver regla 5.0). Sin descripción, sin tiempo estimado, sin fecha — esos campos los completa el PO Técnico al refinar.

```
clickup_create_task
  list_id: [Soporte CLIENTE]
  parent: [task_id de la form_response procesada]
  name: [nombre de la subtarea]
  assignees: [user_id según tabla 9.1]
```

Las subtareas heredan el contexto de la tarjeta padre por estar anidadas, no hace falta duplicar custom fields, etiquetas ni descripción.

**Aclaración importante (v1.7):** estas son las **únicas** llamadas `clickup_create_task` permitidas en todo el flujo. Cualquier otra llamada `clickup_create_task` (por ejemplo, para "crear una versión canónica del form_response") está prohibida por la regla 5.0.

### 9.3 Limitación conocida — patrón único, no adaptado al tipo

En v1.4+ el patrón es **único** independientemente del tipo de incidencia (BUG, MEJORA, DUDA, PETICIÓN, SOPORTE-SERVIDOR). Es deliberadamente simple para arrancar el piloto. Una iteración futura (v2.x) puede introducir patrones adaptados por tipo:

- BUG: Reproducir → Diagnosticar causa → Resolver → Validación Reinicia → Validación Cliente.
- DUDA: Investigar → Responder al cliente → Validación Cliente (sin Reinicia).
- PETICIÓN: Diseñar solución → Implementar → Validación Reinicia → Validación Cliente.
- MEJORA: similar a PETICIÓN, posiblemente con Documentación interna.
- SOPORTE-SERVIDOR: Investigar logs → Aplicar acción → Verificar resolución → Validación Reinicia.

Esa evolución se hará cuando haya datos reales del piloto que justifiquen cada patrón. Mientras, el patrón mínimo es el contrato.

### 9.4 Excepciones donde NO crear subtareas

Si la tarea bruta procesada cumple alguno de estos criterios, la skill **omite la creación de subtareas** y deja un aviso en el comentario al PO Técnico explicándolo:

- La tarea procesada ya tiene subtareas creadas (caso de tarjetas semi-procesadas a mano antes de pasar la skill).
- La tarea está marcada como duplicado de otra (sección 8.5) — el trabajo se hará en la otra tarjeta.
- Dominio clasificado como "Por confirmar" con confianza < 70% — esperar a que el PO Técnico decida el dominio antes de descomponer.
- Form_response con descripción vacía o solo plantilla genérica (sección 14.8) — solo se renombra y se deja un comentario.

---

## 10. Imputación de tiempo automático

La skill imputa **15 minutos de tiempo** a cada tarea procesada, reflejando el valor del análisis y refinamiento que el cron ejecuta sobre la tarea bruta.

### 10.1 Lógica de imputación

Tras crear las subtareas (sección 9) y antes de mover el estado a `Product Backlog` (sección 11), la skill registra un time entry en la tarea principal con:

- **Duración**: 15 minutos (900 000 milisegundos en la API de ClickUp).
- **Usuario**: Néstor Tejero (`766716`) — usuario autenticado en la integración del cron.
- **Tag**: `Refinamiento Automático`.
- **Descripción**: `Refinamiento automático de soporte por skill soporte-procesamiento-clickup-reinicia v1.11`.
- **Fecha**: timestamp del momento de procesamiento.

### 10.2 Justificación del valor

15 minutos por tarea es **deliberadamente conservador** durante el piloto, considerando que:

- El cron ejecuta análisis real (clasificación de dominio, búsqueda de duplicados, generación de comentario al PO Técnico, criterios de aceptación, propuesta de nivel de servicio).
- El resultado entregado al equipo técnico es comparable al de un PO refinando manualmente.
- Un valor más alto (30 min) podría inflar reportes de tiempo durante el piloto antes de validar la calidad real del refinamiento automático.

Tras observar el comportamiento real durante el piloto, este valor puede ajustarse en futuras versiones (v1.8+) si la calidad del refinamiento lo justifica.

### 10.3 Atribución durante el piloto

Todos los time entries van **a nombre de Néstor** porque la integración de ClickUp del cron está autenticada con sus credenciales. Esto significa:

- En reportes de tiempo del cliente, las 15 min × N tareas/día aparecerán como tiempo de Néstor.
- El equipo Proactive (Óscar/Fabián) o Columbia (Pablo) seguirá registrando su tiempo manual cuando trabajen sobre la tarea — esos time entries son adicionales y a su nombre.
- El tag `Refinamiento Automático` permite filtrar el tiempo del cron del tiempo humano en cualquier informe.

Cuando v1.x permita tokens multi-usuario, los time entries del cron podrán atribuirse al PO Cliente del equipo correspondiente (Óscar para Proactive, Pablo para Columbia) en lugar de a Néstor — pero por ahora, **a Néstor durante el piloto** es la decisión consciente.

### 10.4 Casos donde NO se imputa tiempo

La skill **omite la imputación de tiempo** y lo registra como pista (sección 13.3 de captura de pistas) en estos casos:

- La tarea procesada se saltó por filtros corroborantes (sección 3.2 — comentarios sustantivos del equipo, ya tiene patrón canónico, etc.). No se imputó análisis porque no hubo procesamiento real.
- La creación de la tarea principal falló y la skill abortó. No tiene sentido imputar tiempo a una tarea que no quedó procesada.
- La tarea se identificó como duplicado de otra (no se procesa contenido nuevo, solo se enlaza).
- La form_response trae solo plantilla genérica vacía (sección 14.8) — no hay procesamiento real, solo renombrado y aviso.

### 10.5 Herramientas

ClickUp API endpoint para time entries:

```
POST /v2/team/{team_id}/time_entries
Body:
  tid: [task_id de la tarea procesada]
  duration: 900000  (15 min en ms)
  description: "Refinamiento automático de soporte por skill soporte-procesamiento-clickup-reinicia v1.11 [Refinamiento Automático]"
  start: [timestamp actual]
  billable: true (opcional, según configuración del cliente)
```

⚠️ **Regla canónica v1.8 — Idempotencia obligatoria del time entry**

**No usar el parámetro `tags`.** Aunque el endpoint `add_time_entry` del MCP de ClickUp lo acepta sintácticamente, su validación del tag tiene un comportamiento intermitente que genera duplicación silenciosa: en algunos casos la API rechaza la respuesta con error "Name value is required" cuando el tag no existe pre-creado, **pero el time entry ya se ha persistido en ClickUp antes del rechazo**. Si el código reintenta tras el error de tag, se crea una segunda entry duplicada con `start`/`end`/`description` idénticos a la primera.

Este bug se confirmó en Sprint 6-26 con 6 tareas afectadas y 6 entries fantasma generadas (Avaderm D2, Carritech D5+D6, HomeEspaña D6, Breezom D8 ×2), inflando AUTOIAs del Equipo Operativo en +1,5h.

**Solución canónica v1.8** (NO depende de que el tag exista en el workspace):

1. **NUNCA llamar `add_time_entry` con `tags`**. El campo `tags` no se usa.
2. **Identificación del refinamiento automático va en `description`**: incluir literalmente `[Refinamiento Automático]` al final de la cadena (formato fijo, búsqueda por filtro de texto en cualquier informe).
3. **Una sola llamada `add_time_entry`** por tarea procesada. Sin reintentos, sin loops, sin fallback que vuelva a crear entry.
4. **Si la llamada falla** (error HTTP 4xx/5xx, timeout, o cualquier excepción), **NO reintentar**. Registrar la falla como pista (sección 13.3) con `task_id`, `error`, `timestamp` y dejar al PO líder decidir si imputar manualmente. Mejor perder una imputación que duplicar todas.

**Protección defensiva adicional — verificación pre-creación**

Antes de llamar `add_time_entry`, la skill realiza una verificación opcional para detectar entries existentes y abortar si ya hay una válida:

1. Consultar `clickup_get_task_time_entries` con `task_id` y filtro `start_date = hoy 00:00`.
2. Filtrar entries con `user.id = 766716` (Néstor) y `description` que contenga `[Refinamiento Automático]`.
3. **Si encuentra al menos 1 entry coincidente** (creada hoy, mismo usuario, descripción del cron): **abortar imputación** y registrar pista informativa "tarea ya tiene refinamiento automático imputado hoy — no duplicar".
4. **Si no encuentra ninguna**: proceder con `add_time_entry` (única llamada, sin tags).

Esto cubre dos escenarios:
- **El cron se ejecuta dos veces sobre la misma tarea por bug de detección**: la verificación pre-creación intercepta el segundo intento.
- **Una ejecución previa creó la entry pero la skill abortó después por otro error y volvió a procesar la tarea**: misma protección.

**Limpieza retroactiva de entries fantasma generadas por v1.7**

Tras desplegar v1.8, el PO líder ejecuta una limpieza manual one-shot sobre las 6 tareas afectadas conocidas del Sprint 6-26:

| Día | Cliente | Task ID |
|---|---|---|
| D2 08/05 | Avaderm | `869d6yc31` |
| D5 11/05 | Carritech | `869d7cx7p` |
| D6 12/05 | Carritech | `869d8hzn1` |
| D6 12/05 | HomeEspaña | `869d8aah5` |
| D8 14/05 | Breezom | `869d9dg5b` |
| D8 14/05 | Breezom | `869d9dh4z` |

Para cada una: identificar las 2 entries con `start`/`end` idénticos, conservar la primera, eliminar la segunda. Los AUTOIAs del Equipo Operativo se recalcularán solos vía SUMAR.SI tras la limpieza.

Si tras los próximos sprints aparecen más tareas con entries duplicadas que escaparon a la lista conocida, aplicar el mismo patrón de limpieza (filtrar por `description` con `[Refinamiento Automático]` y agrupar por `task_id` + `start`).

---

## 11. Cambio de estado y cierre del procesamiento individual

Una vez completados todos los pasos anteriores (descripción, campos, asignaciones, comentarios, subtareas e imputación de tiempo), la skill mueve la tarea al estado "listo para backlog".

**⚠️ El nombre del status varía entre listas (v1.9).** No todas las listas de Soporte usan el mismo literal. En la mayoría es `Product Backlog`, pero algunas listas usan variantes como `sprint backlog` (minúsculas) — detectado en la lista Soporte INEFSO-Dinam en la ejecución del 06/05. Si la skill intenta mover a un literal que no existe en la lista, **el cambio falla en silencio**: la tarea se queda en `Open`, la siguiente ejecución la vuelve a tomar como bruta y se entra en un bucle de reprocesamiento en cada ejecución del cron.

**Procedimiento robusto:**

1. Leer los estados disponibles de la lista (de la respuesta de `clickup_get_task`, campo de statuses de la lista, o `clickup_get_list`).
2. Buscar, sin distinguir mayúsculas/minúsculas, el status destino con esta prioridad: `product backlog` → `sprint backlog` → `backlog` → cualquier status de tipo "backlog/to-do" posterior a `open`.
3. Mover con el literal **exacto** tal como aparece en la lista:

```
clickup_update_task con status="[literal exacto del status de backlog de la lista]"
```

4. **Si ningún status de backlog casa**, no forzar el move: dejar la tarea en `Open`, registrar pista (sección 13.3, categoría `bloqueador-mcp`) con el `list_id`, los statuses disponibles y el `task_id`, y avisar de que el procesamiento quedó completo salvo el cambio de estado.

Esto cumple tres funciones:

1. **Marca visual** — el equipo ve que la tarea ha sido procesada y está lista para refinamiento técnico.
2. **Filtro técnico** — la siguiente ejecución del cron no la considera bruta (sección 3.2: ya tiene marker + descripción canónica, aunque el status no cuadre).
3. **Punto de control** — el PO Técnico verá la tarea en su backlog con la información ya estructurada y podrá pasarla a sprint cuando proceda.

---

## 12. Resumen diario consolidado

### 12.1 Lógica de cuándo publicar

La skill **acumula** las tareas procesadas y publica un resumen consolidado **una vez al día**, no en cada ejecución del cron. El resumen se publica en la **última pasada programada del día** y su ventana es siempre **«tareas procesadas desde el último resumen publicado (exclusive) hasta ahora»**, determinada por cliente leyendo el *timestamp de creación* del comentario-resumen más reciente (marker de la sección 12.5). Esto hace la lógica robusta frente a ejecuciones omitidas, fines de semana y husos horarios: nada se queda sin resumir aunque se procese fuera de la franja monitorizada.

> ⚠️ **El disparo del resumen NO depende de la hora de reloj (v1.11).** Versiones anteriores publicaban "si la hora local ≥ 22:00"; eso fallaba si la pasada caía a una hora inesperada (p. ej. una routine configurada en UTC en lugar de Europe/Madrid hacía que la pasada de las 22:00 se ejecutara a las 00:07 de Madrid, fuera de todo umbral horario — detectado 01/06). Ahora la skill identifica la pasada por su **posición en el calendario del cron** (sección 1.2), no por el reloj.

**Algoritmo:**

1. La skill obtiene el **calendario de pasadas del día** desde el cron documentado en la sección 1.2 (actualmente {08:00, 11:00, 14:00, 17:00, 22:00} Lun–Vie) e identifica a qué pasada corresponde la ejecución actual: usa la hora programada/trigger que aporte la routine si está disponible; si no, mapea la hora real de ejecución a la pasada programada más cercana. Así el rol de la pasada (primera / intermedia / última) no depende de la hora de reloj exacta.
2. Para cada cliente con actividad, calcula la **cota inferior** de la ventana = timestamp del último comentario-resumen publicado (sección 12.5). Si no hay ninguno previo, usa hoy 00:00. La **cota superior** es el momento actual.
3. **Si la ejecución actual es la ÚLTIMA pasada programada del día** (hoy, la de las 22:00): tras procesar las tareas brutas, publica el resumen de todas las tareas con el comentario-marker "Primer Refinamiento Individual Realizado" cuyo timestamp caiga en esa ventana. Antes de publicar, comprueba que no exista ya un comentario-resumen con timestamp posterior a la cota inferior (idempotencia ante re-ejecución de la última pasada).
4. **Cobertura del fin de semana (lunes):** como el cron no corre sábado ni domingo, el lunes la cota inferior es el resumen del **viernes** (su última pasada), de modo que el resumen del lunes abarca automáticamente **viernes noche → fin de semana → lunes**. Recoge así cualquier tarea procesada tras el corte del viernes (incluida actividad manual o de personas en otro huso horario). No requiere tratamiento especial: es consecuencia directa de la ventana «desde el último resumen».
5. **Si la ejecución actual es una pasada INTERMEDIA del día** (hoy, 11:00/14:00/17:00): no publica resumen.
6. **Si la ejecución actual es la PRIMERA pasada programada del día** (hoy, la de las 08:00): por defecto no publica, salvo recuperación: si detecta que la última pasada del día hábil anterior **no** publicó resumen (no hay comentario-resumen con timestamp en esa fecha) y existen tareas procesadas sin resumir en la ventana, publica entonces el resumen de recuperación con la misma lógica de ventana de los pasos 2–3.

### 12.2 Cómo construye el resumen

Para cada cliente:

1. Busca en su lista de Soporte las tareas con el comentario-marker "Primer Refinamiento Individual Realizado" cuyo timestamp caiga en la **ventana de resumen** definida en la sección 12.1 (desde el último resumen publicado hasta ahora; en lunes, desde el viernes 22:00).
2. Si hay 0 tareas → omite el resumen para ese cliente. Sin actividad, sin comentario.
3. Si hay ≥ 1 tarea → construye el resumen.

### 12.3 Destino del resumen

**Estrategia (b)** — preferencia con fallback dinámico:

1. Buscar en la lista de Gestión del cliente una tarea con nombre `Soporte [Mes Año actual] [CLIENTE]` (ej. `Soporte Abril 2026 [GONHER]`). Si existe → ahí va el resumen.
2. Si no existe, buscar `Gestión [Mes Año actual] [CLIENTE]` (ej. `Gestión abril 2026 [CARRITECH]`). Si existe → ahí va el resumen.
3. Si tampoco existe → la skill **no publica el resumen** y deja un warning en la propia última tarea procesada del día: "No he encontrado tarea mensual de Gestión ni de Soporte para [CLIENTE] correspondiente a [Mes Año]. Resumen del día no publicado. Esperando creación de la tarea mensual."

**Búsqueda dinámica** vía `clickup_search` con `keywords` y filtro de lista. Sin IDs hardcodeados.

### 12.4 Formato del comentario de resumen

```
Primer Refinamiento Realizado por Soporte — resumen [rango cubierto: YYYY-MM-DD si es un solo día, o YYYY-MM-DD → YYYY-MM-DD si abarca varios (p. ej. lunes con fin de semana)]

Tareas refinadas: [N]

[Por cada tarea procesada:]
- [TIPO] [Descripción corta] [CLIENTE]
URL: [https://app.clickup.com/t/...]
Dominio: [CRM / Web / WABA]
Nivel propuesto: [Soporte Operativo / Mejoras Evolutivas / Proyectos Nuevos]
[Si hay duplicado detectado:] Posible duplicado: [URL]

[Si hay incidencias notables:]
Notas:
- [Tarea X: dominio por confirmar — pendiente decisión PO Técnico]
- [Tarea Y: información sensible detectada — revisar]
```

Texto plano. URLs en línea separada del texto descriptivo (limitación de comentarios sección 6.1 de `formato-tarjeta-clickup-reinicia`).

### 12.5 Marca de identificación del resumen

Para que la skill pueda detectar el último resumen publicado y no duplicarlo, el comentario empieza siempre con la línea exacta:

```
Primer Refinamiento Realizado por Soporte — resumen
```

Esa cadena es el "marker" que la skill busca en `clickup_get_task_comments` para identificar resúmenes previos. El **timestamp de creación** de ese comentario (no la fecha escrita en el texto) es la cota inferior de la ventana de resumen de la sección 12.1.

### 12.6 Cliente sin tarea mensual — escalado tras 3 días (v1.9)

Aplica la opción (a) decidida con el PO: la skill **no autocrea tareas mensuales** — eso es responsabilidad del sistema mensual de gestión que ya está en marcha. Si no encuentra ni `Soporte [Mes Año] [CLIENTE]` ni `Gestión [Mes Año] [CLIENTE]` (sección 12.3, paso 3), salta el resumen de ese cliente con un warning como comentario en la última tarea procesada del día.

**Problema detectado:** si una tarea mensual no se crea durante varios días, la skill repite el mismo warning silencioso indefinidamente y nadie se entera de que se están perdiendo resúmenes diarios. Caso típico: HomeEspaña al arrancar el piloto.

**Escalado (v1.9):** la skill lleva la cuenta de cuántos días consecutivos lleva sin poder publicar el resumen de un cliente, usando como traza los warnings previos en las tareas procesadas (no hay memoria local). Cuando detecta que un cliente lleva **≥ 3 días** sin tarea mensual localizable:

1. Publica una pista en el reporte de Cowork (sección 13.3, categoría `otro - configuración pendiente`) con el literal:
   > "Cliente [CLIENTE] lleva [N] días sin tarea mensual de Gestión/Soporte localizable. Se han perdido [N] resúmenes diarios. El PO líder debe crear la tarea mensual o confirmar que este cliente no la usa."
2. Menciona a Néstor (`766716`) como PO líder en esa pista para darle visibilidad real.

No bloquea nada — el procesamiento individual de tareas sigue igual; solo escala la falta de destino del resumen para que deje de ser ruido invisible.

---

## 13. Principio de prudencia en automático

**Al ejecutarse en automático (sin supervisión humana en tiempo real), la skill debe optar siempre por el camino prudente.** Cuando aparezca cualquier ambigüedad o duda razonable, la skill **no toma la decisión más asertiva** — opta por el warning y delega la decisión al PO.

### 13.1 Casos donde aplica el principio

- **Clasificación de dominio con confianza < 70%** → marcar como "Por confirmar" en lugar de elegir el más probable. Reflejar en el comentario al PO Técnico.
- **Tipo de incidencia ambiguo** (ej. ¿es BUG o MEJORA? ¿es DUDA o PETICIÓN?) → elegir el tipo más conservador (PETICIÓN sobre MEJORA, DUDA sobre BUG) y mencionar la duda en el comentario al PO Técnico.
- **Asignación dudosa** (ej. cliente nuevo no listado, equipo no claro) → no asignar y avisar al PO Cliente y al PO Director (Néstor `766716`).
- **Campos personalizados con opciones inciertas** (ej. ÉPICA en un caso límite) → usar la opción más neutra (`05. ADOPTION` para soporte habitual) y mencionar la duda en el comentario al PO Técnico.
- **Detección de duplicado con similitud baja** (≥ 50% pero < 75%) → mencionarlo como posible pero NO crear el `clickup_add_task_link` automáticamente. La decisión final del enlace queda para el PO.
- **Información sensible o personal en la petición original** → procesar igual (regla de preservación literal), pero añadir aviso explícito al PO Técnico para que valore si conviene editarla.
- **Formato de fechas, idiomas o monedas inconsistentes en el formulario** → preservar el original y añadir nota.
- **Tarea que parece importante pero no encaja claramente en los criterios de la sección 3** → no procesar. Avisar en el reporte final.

### 13.2 Cómo se materializa el principio

En la práctica, la prudencia se traduce en **más warnings y menos acciones automáticas** en casos límite. Es preferible que la skill deje 5 dudas para que el PO resuelva, a que tome 5 decisiones que el PO tendría que revertir manualmente.

Los warnings se acumulan en una sección específica del comentario al PO Técnico (sección 8.2):

```
[Si hay dudas o cosas raras detectadas:]
⚠️ Dudas y observaciones para revisión:
- [Duda 1: descripción + qué hizo la skill por defecto + qué confirmar]
- [Duda 2: ...]
```

### 13.3 Captura de pistas para optimización iterativa

La skill **registra explícitamente** las dudas y casuísticas raras encontradas durante cada ejecución. Estas notas son la materia prima para iterar la skill en futuras versiones.

**Mecanismo:** al final de cada ejecución (no en cada tarea procesada — al final del lote completo), si hubo cualquier duda, casuística rara o decisión no trivial, la skill incluye en el reporte de la conversación de Cowork (sección 16) un bloque adicional. **Las pistas se agrupan por categoría** (v1.9) para que el PO escanee el reporte en segundos en lugar de leer línea a línea:

```
🔍 PISTAS PARA ITERACIÓN DE LA SKILL

Durante esta ejecución han surgido los siguientes casos que merecen consideración para futuras versiones:

[bug-cron] (N pistas)
  - Tarea: [URL si aplica]
    Síntoma: [qué se ha visto]
    Hipótesis: [por qué pasa]
    Propuesta v1.X: [qué cambio en la skill resolvería]

[falso-positivo-skip] (N pistas)
  - ...

[calidad-baja] (N pistas)
  - ...

[bloqueador-mcp] (N pistas)
  - ...

[otro - configuración pendiente] (N pistas)
  - ...

[otro - limpieza retroactiva] (N pistas)
  - ...

[Solo se incluyen las categorías con al menos una pista. Si no hay nada que reportar, omitir este bloque enteramente.]
```

**Categorías estables** (cerradas — no inventar nuevas sin validación del diseñador): `bug-cron`, `falso-positivo-skip`, `calidad-baja`, `bloqueador-mcp`, `otro - configuración pendiente`, `otro - limpieza retroactiva`.

**Anti-repetición de pistas recurrentes (v1.9):** las pistas de las secciones 14.6 (tarea no-form_response) y 14.7 (form_response antigua dormida) se disparan en cada ejecución del cron sobre las mismas tareas, inundando el reporte con ruido que nadie revisa. Para evitarlo:

1. Antes de añadir una pista 14.6 o 14.7 al reporte, la skill comprueba si la **misma tarea** ya tiene un comentario con el marker `Pista 14.6 — Procesamiento Soporte Skill` o `Pista 14.7 — Procesamiento Soporte Skill` (puesto por la propia skill en una ejecución anterior). **Si lo tiene, la salta sin reportar.**
2. La **primera vez** que detecta una tarea en estos casos, deja un comentario corto en la propia tarea con el marker correspondiente seguido del mensaje de la sección 14.6 / 14.7. Y la incluye en el reporte de esa ejecución (es nueva).
3. El reporte de Cowork solo incluye, por tanto, **pistas nuevas** del día — nunca las ya registradas en ejecuciones previas.

Esto convierte el ruido recurrente en un catálogo navegable (ver auditoría dirigida, sección 14.9).

**Qué se considera "pista" digna de reportar:**
- Patrones de tarea bruta no contemplados en la skill.
- Casos donde la clasificación de dominio fue ambigua y la skill tomó una decisión por defecto.
- Errores de herramientas MCP recurrentes que sugieren cambio de aproximación.
- Tareas que se saltaron por filtros corroborantes y que el PO probablemente sí querría haber procesado.
- Tareas procesadas donde la calidad del resultado fue baja (campos sin opción clara, comentario al PO Técnico poco útil, etc.).
- Cualquier observación sobre el formulario de cliente que sugiera mejorar el formulario en sí.

**Qué NO se considera pista (no reportar):**
- Procesamientos rutinarios sin incidencia.
- Errores transitorios de red o MCPs (se reintentan en la siguiente ejecución).
- Casos ya documentados en el versionado actual de la skill como "comportamiento conocido".

El PO recopila estas pistas a lo largo de la semana y las pasa al diseñador de la skill (Néstor + Claude) para iteraciones de versión. Cuando una pista se materializa en cambio de skill, queda anotada en la sección 18 (Versionado).

---

## 14. Errores y casos límite

### 14.1 Lista de Soporte vacía

Si en una ejecución no hay tareas brutas pendientes en ninguna lista, la skill termina silenciosamente. No publica nada en ningún sitio. No deja warnings.

### 14.2 Tarea bruta corrupta o ilegible

Si el contenido de la descripción no es interpretable (formato roto, vacía, error de codificación), la skill aplica el fallback de seguridad (sección 3.6): preserva lo que haya en "📥 Requerimientos Cliente", pone "No interpretable — revisar manualmente" en los demás bloques y lo refleja en el comentario al PO Técnico como prioridad alta.

### 14.3 Error en una herramienta MCP

Si una llamada falla (ClickUp caído, MCP de Workdrive no disponible, etc.), la skill registra el error y continúa con la siguiente tarea — no aborta toda la ejecución por un fallo puntual. La tarea que falló se reintenta en la siguiente ejecución del cron (2 horas después) ya que seguirá siendo "bruta" según los criterios de la sección 3.

### 14.4 Tarea procesada parcialmente

Si una tarea se llegó a procesar parcialmente (ej. se renombró pero se cayó la conexión antes de cambiar el estado), la siguiente ejecución la verá como "bruta" por seguir en `Open` sin marca de procesamiento. La skill detecta entonces que la descripción ya tiene "📥 Requerimientos Cliente" (señal corroborante 3.2) y aplica solo los pasos faltantes — no rehace lo ya hecho.

### 14.5 Cliente desconocido

Si aparece una tarea bruta en una lista que **no está en la tabla de clientes configurados** (sección 2), la skill la ignora. La tabla es la fuente de verdad de "qué procesa" — no se descubre clientes nuevos al vuelo.

### 14.6 Tarea no-form_response en lista de Soporte (v1.7, anti-repetición v1.9)

Si la skill encuentra en una lista de Soporte una tarea en `Open` con `task_type` distinto de `form_response` (ej. `Producto Digital`, `null`, `Bug`, etc.), la skill **no la procesa**. La primera vez deja un comentario en la propia tarea con el marker y el mensaje, y la incluye como pista en el reporte. En ejecuciones posteriores, si el marker ya existe, la salta sin reportar (anti-repetición, sección 13.3).

Marker + mensaje:

> `Pista 14.6 — Procesamiento Soporte Skill`
> "Tarea [URL] está en lista Soporte [CLIENTE] con `task_type=[X]` (no es form_response). La lista de Soporte se está usando para tareas que no proceden del formulario; el PO líder debe decidir si moverlas a la lista General [CLIENTE] o gestionarlas aparte."

Casos típicos detectados en producción: tareas creadas a mano por POs con plantilla genérica, tareas de tipo "Producto Digital" arrastradas desde otras listas, tareas creadas por workflows de ClickUp internos.

### 14.7 form_response antigua sin actividad reciente (v1.7, anti-repetición v1.9)

Si una form_response cumple los criterios de procesamiento (sección 3) pero `date_created` es anterior a 30 días respecto al momento de ejecución, **la skill no la procesa**. La primera vez deja un comentario en la propia tarea con el marker y el mensaje, y la incluye como pista en el reporte. En ejecuciones posteriores, si el marker ya existe, la salta sin reportar (anti-repetición, sección 13.3).

Marker + mensaje:

> `Pista 14.7 — Procesamiento Soporte Skill`
> "form_response [URL] de [fecha] lleva [N días] en Open sin procesar. La skill no la procesa para no generar actividad artificial sobre tarjetas que el equipo ha dejado dormir. El PO líder debe decidir si procesarla, cerrarla por obsolescencia, o si requiere intervención manual."

La razón: procesar una tarjeta dormida hace 6 meses generaría notificaciones al PO Técnico, time entry de 15 min, y subtareas nuevas — todo ruido sobre algo que el equipo ha decidido tácitamente no atender. Mejor que el PO decida manualmente.

### 14.8 form_response con descripción vacía o solo plantilla genérica (v1.7)

Si la descripción del form_response no contiene contenido real del cliente y solo tiene la plantilla genérica de Reinicia (cabeceras `Historia de usuario: Como...QUIERO...PARA...`, `Descripción:`, `Ready to Backlog`, `Contexto`, etc., sin texto rellenado por el cliente), **la skill no aplica el patrón canónico completo**. En su lugar:

1. Aplica solo el renombrado a `[PETICIÓN] [Asunto del título original] — pendiente contenido [CLIENTE]`.
2. Asigna a PO Técnico + PO Cliente.
3. Publica un único comentario al PO Técnico (sin marker, sin criterios, sin subtareas, sin time entry):

> "@[PO Técnico] La form_response llegó sin contenido real del cliente — solo trae la plantilla genérica. La skill no la procesa completamente. Hay dos opciones: (a) cerrar como inválida y pedir al cliente que rellene el formulario completo, o (b) recuperar el contenido de fuera de banda (email, llamada) y pegarlo en la descripción para que el siguiente cron la procese."

4. Mantiene el estado en `Open` (no la mueve a Product Backlog).

Esto cubre form_response como `869bxtw5z` y `869arfgz0` detectadas en la ejecución del 2026-05-06.

### 14.9 Auditoría dirigida (manual o skill auxiliar) (v1.9)

Los markers `Pista 14.6 — Procesamiento Soporte Skill` y `Pista 14.7 — Procesamiento Soporte Skill` (sección 13.3, anti-repetición) convierten el ruido recurrente en un **catálogo navegable**. Esto habilita una pasada de limpieza periódica (mensual sugerida) en la que el PO líder filtra todas las tareas en lista de Soporte con esos comentarios y decide caso por caso: mover a `General [CLIENTE]`, cerrar por obsolescencia, o procesar manualmente.

Esta auditoría es la extensión natural de la futura skill auxiliar `auditoria-duplicados-soporte-reinicia` (ya nombrada en v1.7), que automatizaría tanto la detección de duplicados form_response ↔ canónica como la recolección de tareas marcadas con `Pista 14.6/14.7`, dejando al PO solo la decisión final. Mientras esa skill no exista, la auditoría se hace a mano filtrando por el texto del marker.

---

## 15. Activación de Cliq

Cuando se valide el procesamiento (típicamente tras 2-4 semanas de piloto exitoso), Cliq se puede activar **cliente a cliente** cambiando el flag `cliq_publish` de `false` a `true` en la tabla de la sección 2.

**Cuando esté activado**, la skill publica al final de cada procesamiento individual un mensaje en el canal del cliente:

```
[Tipo] [Descripción corta]
@[PO Técnico] @[PO Cliente]
Nueva tarea de soporte refinada y lista para revisión técnica.
URL: [URL ClickUp de la tarea]
```

Vía `ZohoCliq_Post_message_in_a_channel` con el `unique_name` del canal documentado.

**Si un canal no está accesible** (no joined, no encontrado), la skill avisa al PO con un warning: "Canal Cliq de [CLIENTE] no accesible. Añadir a Álvaro al canal y reintentar." No bloquea el procesamiento — solo omite la publicación en Cliq.

**Durante el piloto, esta sección está desactivada en todos los clientes.**

---

## 16. Salida y reporte

### 16.1 Disparo manual

Cuando el PO ejecuta la skill manualmente desde una conversación, Claude reporta al final:

```
Procesamiento completado.

Tareas procesadas: [N]

[Por cada tarea:]
✅ [TIPO] [Descripción] [CLIENTE]
   URL: [URL]
   Dominio: [CRM/Web/WABA]
   Asignados: [PO Técnico] + [PO Cliente]
   Nivel propuesto: [...]

[Si hay tareas con warnings:]
⚠️ [N] tareas con notas para revisar — ver comentarios en cada tarjeta.

[Si tocaba publicar resumen diario y se publicó:]
📊 Resumen diario publicado en:
- Tarea mensual [CLIENTE 1]: [URL]
- Tarea mensual [CLIENTE 2]: [URL]

[Si tocaba publicar y no se pudo (caso HomeEspaña sin tarea mensual):]
⚠️ Resumen diario no publicado para [CLIENTE]: tarea mensual no localizada.
```

### 16.2 Disparo programado (Cowork)

La salida es la misma — Cowork la guarda en el historial de la tarea programada. El PO la consulta cuando quiera entrando a la tarea programada en la app de Claude.

---

## 17. Limitaciones conocidas

| Limitación | Impacto | Mitigación |
|---|---|---|
| Tareas programadas de Cowork solo corren con app abierta | Si el portátil está cerrado, las tareas brutas se acumulan | Se procesan todas juntas al abrir la app. El cron sigue su cadencia habitual (Lun–Vie 08:00/11:00/14:00/17:00/22:00, Europe/Madrid) cuando el equipo está activo |
| Markdown no soportado en comentarios ClickUp | URLs y formato pierden estructura | Texto plano, URLs en línea separada |
| Checklists no creables vía MCP | El PO debe copiar criterios manualmente | Comentario "Caso A" con criterios listos |
| Tags de time entry causaban duplicación silenciosa (bug v1.7) | Cada par de entries duplicadas inflaba AUTOIAs +0,25h | Resuelto en v1.8: el campo `tags` ya no se usa. El marcador `[Refinamiento Automático]` va siempre en `description`. Verificación pre-creación con `clickup_get_task_time_entries` previene reintentos accidentales |
| ClickUp API solo devuelve tiempos del usuario autenticado | El log diario no puede incluir métricas de tiempo del equipo | Aceptarlo — el log es de actividad de procesamiento, no de tracking |
| Canales Cliq no joined no aparecen en la lista | No se puede publicar en ellos | Avisar al PO para que añada a Álvaro |
| Detección de duplicados por similitud de texto | Falsos positivos posibles | Detección informativa, nunca bloqueante. Decisión humana |
| Clasificación de dominio en casos límite | Errores de clasificación posibles | Caso "Por confirmar" + comentario al PO Técnico para resolver |
| MCP no expone delete de comentarios | Comentarios "Saltada por skill..." de ejecuciones erróneas previas no se pueden borrar | La skill deja un nuevo comentario "Corrección a comentario anterior" que retracta el anterior (sección 8.2) |
| Límite de concurrencia del MCP de ClickUp | 3+ `create_task_comment`/`create_task` en paralelo sobre la misma tarea fallan con "The connector's server isn't responding" y el reintento altera el orden cronológico | v1.9: escrituras serializadas sobre una misma tarea (sección 8.0) + marker publicado como gate de último paso (8.6) |
| Nombre del status de backlog varía entre listas | Mover a `Product Backlog` falla en silencio en listas que usan otro literal (ej. `sprint backlog` en INEFSO-Dinam) → bucle de reprocesamiento | v1.9: leer statuses de la lista y mapear al de backlog disponible; si ninguno casa, warning (sección 11) |

---

## 18. Versionado

| Versión | Fecha | Cambio |
|---|---|---|
| v1.0 | 2026-04-27 | Versión inicial. Procesamiento de tareas brutas de soporte para clientes piloto HomeEspaña, Carritech, Gonher, Avaderm. Cliq desactivado durante piloto. Log diario consolidado en tarea mensual con estrategia (b) de fallback. Marca de procesamiento "Primer Refinamiento Individual Realizado" para preservar lenguaje natural visible al cliente. |
| v1.1 | 2026-04-27 | Aprendizajes de la prueba manual sobre Avaderm 869ctbft1 y candidata descartada Carritech 869cteytn. Cambios: (a) sección 3.2 — añadido cuarto filtro corroborante "sin comentarios sustantivos del equipo Reinicia"; (b) sección 3.3 nueva — señales débiles corroborantes (time_spent > 5 min, REFINADO=true sin patrón canónico) con comportamiento documentado; (c) renumeradas las antiguas 3.3-3.5 a 3.4-3.6; (d) sección 8.2 — patrón canónico de aviso de solicitante no identificado, aviso de REFINADO=true previo, aviso de time_spent significativo previo; formato negativo de duplicados ("ninguno detectado") explícito. |
| v1.2 | 2026-04-27 | Tres mejoras antes del despliegue en automático: (a) sección 6.2 — regla de naming corregida: el nombre del producto describe el **estado entregado**, no la actividad ("Campos obligatorios simplificados" sí, "Simplificar campos obligatorios" no). Verbo en participio o sustantivo resultante. Ejemplos actualizados; (b) sección 11 nueva — principio de prudencia: ante cualquier duda razonable, la skill opta por warning en lugar de decisión asertiva. Documenta 8 casos donde aplica y mecanismo de delegación al PO; (c) sección 11.3 — captura explícita de pistas para iteración: la skill registra al final de cada ejecución casuísticas raras y decisiones ambiguas en un bloque "🔍 PISTAS PARA ITERACIÓN DE LA SKILL" del reporte. Renumeradas secciones 11→12, 12→13, 13→14, 14→15, 15→16, 16→17, y referencias internas actualizadas. |
| v1.3 | 2026-04-27 | Refactor de la regla de naming para vivir en su sitio canónico. La regla de "nombre = entregable en estado final, no acción" pasa a la sección 2.13 nueva de `formato-tarjeta-clickup-reinicia` (fuente de verdad transversal aplicable a todas las skills de creación de productos). Las secciones 6.2 y 6.3 de esta skill se simplifican para **referenciar** esa sección 2.13 en lugar de duplicarla, manteniendo solo el resumen aplicable, el test rápido ("Tarea:" vs "Entregable:") y los ejemplos específicos de soporte (con prefijo `[TIPO]`). Cambio coordinado: las skills madre (Zoho, Web, WABA) y SPIKE deben actualizarse equivalentemente para referenciar 2.13. Ver patch en `PATCH-formato-tarjeta-clickup-reinicia-v1.3.md`. |
| v1.4 | 2026-04-28 | Detectada en revisión de Avaderm 869ctbft1 (refinada el 27/04 por v1.0): faltaba creación de subtareas. Añadida sección 9 nueva "Creación de subtareas" con patrón mínimo (a) de 4 subtareas: Investigación/Reproducción, Implementación, Validación Reinicia, Validación Cliente. Las tres primeras asignadas al PO Técnico, la cuarta al PO Cliente para visibilidad anticipada. Patrón único en v1.4 — futura iteración v2.x introducirá patrones adaptados al tipo de incidencia. Documentadas excepciones donde NO crear subtareas (tarjeta ya con subtareas, duplicados, dominio sin confianza). Renumeradas secciones 9→10, 10→11, 11→12, 12→13, 13→14, 14→15, 15→16, 16→17, 17→18, y referencias internas actualizadas. |
| v1.5 | 2026-04-28 | Imputación automática de tiempo. Añadida sección 10 nueva "Imputación de tiempo automático": el cron imputa **15 minutos** por cada tarea procesada, a nombre de Néstor (`766716`, usuario autenticado de la integración), con tag `Refinamiento Automático` y descripción identificativa de la skill. Justificación: refleja el valor del análisis y refinamiento que el cron entrega al equipo (clasificación de dominio, búsqueda de duplicados, generación de comentarios al PO Técnico, propuesta de nivel de servicio, criterios de aceptación). Valor 15 min deliberadamente conservador durante el piloto — ajustable al alza en futuras versiones tras validar calidad real. Atribución a Néstor durante el piloto, migrable a tokens multi-usuario en v1.x. Casos donde NO se imputa: tareas saltadas por filtros corroborantes, fallos de creación, duplicados. Renumeradas secciones 10→11, 11→12, 12→13, 13→14, 14→15, 15→16, 16→17, 17→18, 18→19, y referencias internas actualizadas. Coherente con la imputación manual de tiempo de la skill `soporte-correo-clickup-reinicia` v1.1. |
| v1.6 | 2026-05-04 | **Ampliación de alcance: de 4 clientes piloto a 15 clientes activos. Y cambio de cadencia del cron de 30 min a 2 horas.** Cambios: (a) sección 2 — añadidos 11 clientes nuevos (Aicrov, Aunna, Breezom, Estarima, Inefso - Dinam, ISL Agency, Kasblan, Líder System Grupo, Synuptic, Timedi, Worldwide Boat) con su Equipo, listas Soporte/Gestión, POs Técnico y Cliente, y `unique_name` de canal Cliq. Localizada también la lista Gestión de HomeEspaña que estaba pendiente: `900501350944`; (b) sección 2 — añadida nota terminológica: "piloto" pasa a referirse solo al estado del flag `cliq_publish` (todos arrancan en `false`), no al alcance de clientes; (c) sección 2 — añadida fila para Rolf Pinto (`99603566`) en la tabla de personas como PO Técnico de Synuptic, y eliminado el matiz "Zoho Carritech" del rol de Fabián porque ahora cubre múltiples clientes (Carritech, Aicrov, Aunna, Breezom, Inefso - Dinam, Synuptic — aunque el técnico real de Synuptic es Rolf); (d) sección 2 — añadida nota explícita: para los 11 clientes nuevos, el `unique_name` del canal Cliq se ha registrado tal como lo dio el PO líder pero **no se ha verificado el acceso (joined)**; antes de activar `cliq_publish: true` hay que comprobarlo con `ZohoCliq_List_all_channels`; (e) sección 1.2 — el prompt del cron ya no enumera clientes; remite a la sección 2 como fuente de verdad para no obligar a actualizar el prompt cada vez que cambia la tabla; (f) frontmatter `description` actualizada coherentemente; (g) **cadencia del cron cambiada de 30 min a 2 horas** en sección 1.2, sección 19 (puntos 3 y 5), cuadro de limitaciones y sección de manejo de errores. La cadencia más conservadora es prudente al pasar de 4 a 15 listas a chequear por ejecución y reduce el ruido de imputación de tiempo (15 min × N tareas × 12 ejecuciones/día → × 4 ejecuciones/día). **No hay cambios de lógica de procesamiento** — solo de configuración. La lógica v1.5 sigue intacta. **Pendiente operativo antes de la próxima ejecución del cron**: actualizar el prompt y la cadencia en la tarea programada de Cowork; validar acceso a los 11 canales Cliq nuevos cuando se decida activar `cliq_publish` por cliente; mientras `cliq_publish=false` esto no bloquea nada. |
| v1.7 | 2026-05-06 | **Aprendizajes de la ejecución 2026-05-06 sobre Carritech (4 duplicadas erróneas detectadas) y Gonher/Lider (casuísticas de tareas no procesables).** Cambios: (a) **sección 5.0 nueva** — regla rotunda "la skill SIEMPRE edita el form_response original con `clickup_update_task`; JAMÁS crea canónicas paralelas; única `clickup_create_task` permitida son las 4 subtareas hijas". Esta regla cierra el bug que generó las 4 duplicadas erróneas en Soporte Carritech (`869d5zpe6`, `869d5zpyb`, `869d5zq6u`, `869d5zqv7`); (b) **sección 3.4 reescrita** — form_response con `linked_tasks` apuntando a canónica errónea: procesar normalmente (no saltar) y avisar al PO en el comentario al PO Técnico. La antigua 3.4 ("Excepción tarea ya procesada") pasa a 3.5; antiguas 3.5/3.6 a 3.6/3.7; (c) **sección 6.2 reforzada** — hard cap 60 caracteres en descripción del nombre con patrones explícitos de abreviación (SQs, Opps, flechas, eliminar artículos); (d) **sección 8.2 ampliada** — bloque condicional "Corrección a comentario anterior" para retractar comentarios "Saltada por skill" de ejecuciones previas erróneas + bloque "duplicado canónico erróneo de ejecución previa" en plantilla del comentario al PO Técnico; (e) **sección 10.5 ampliada** — manejo del fallo del tag `Refinamiento Automático` (fallback a sufijo en descripción cuando el tag no existe pre-creado en workspace); (f) **sección 14.6 nueva** — tarea no-form_response en lista de Soporte: no procesar, registrar pista. Cubre casos como `869arfgz0` (task_type=Producto Digital) y `869axy0pz`/`869axxz5u` (task_type=null) detectados en Lider System Grupo; (g) **sección 14.7 nueva** — form_response antigua >30 días sin actividad: no procesar, registrar pista. Cubre las 7+ "(Comentarios Sesión)" de Gonher de noviembre 2025; (h) **sección 14.8 nueva** — form_response con descripción vacía/plantilla genérica: solo renombrar + comentario explicativo, mantener en Open. Cubre `869bxtw5z` y `869arfgz0`; (i) **sección 13.3 estructurada** — formato fijo para pistas (Categoría, Tarea, Síntoma, Hipótesis, Propuesta) para facilitar priorización por el diseñador; (j) **sección 17 ampliada** — añadidas dos limitaciones nuevas: tags de time entry rechazados sin preexistencia, y MCP no expone delete de comentarios; (k) frontmatter `description` actualizada para reflejar la regla 5.0. **Pendiente operativo tras deploy v1.7**: pasada de auditoría manual one-shot sobre las 15 listas de Soporte para detectar y eliminar duplicados form_response ↔ canónica generados por v1.0-v1.6 (preservando form_response). Opcional: skill auxiliar `auditoria-duplicados-soporte-reinicia` que automatice la detección y deje al PO solo el click de eliminación. |
| v1.8 | 2026-05-14 | **Bug crítico de duplicación silenciosa de time entries del Refinamiento Automático corregido.** Diagnóstico (descubierto durante el cierre de AUTOIAs Sprint 6-26 Día 8): el fallback de `tags` documentado en v1.7 sección 10.5 (intentar con `tags`, si falla repetir sin `tags` añadiendo sufijo en `description`) generaba 2 time entries idénticas en algunos casos. Hipótesis técnica: la API del MCP de ClickUp valida el tag **después** de persistir la entry — cuando el tag no existe en el workspace, devuelve error "Name value is required" pero la entry ya está creada. El paso 2 del fallback creaba entonces una segunda entry. Bug intermitente: solo se disparaba cuando el flujo de validación de tag fallaba con persistencia previa. Casos confirmados Sprint 6-26 (6 tareas, 6 entries fantasma, +1,5h hinchadas en AUTOIAs Equipo Operativo): Avaderm `869d6yc31` (D2), Carritech `869d7cx7p` (D5), Carritech `869d8hzn1` (D6), HomeEspaña `869d8aah5` (D6), Breezom `869d9dg5b` (D8), Breezom `869d9dh4z` (D8). **Cambios v1.8**: (a) **sección 10.5 reescrita completamente** — eliminado el patrón de fallback con dos llamadas. Regla canónica nueva: NUNCA usar el parámetro `tags`. El marcador `[Refinamiento Automático]` va siempre en `description` como sufijo literal (búsqueda por filtro de texto). UNA sola llamada `add_time_entry` por tarea. Si falla: NO reintentar, registrar como pista. Mejor perder una imputación que duplicar todas; (b) **sección 10.5 — protección defensiva**: añadida verificación pre-creación opcional con `clickup_get_task_time_entries` filtrando por `start_date=hoy 00:00`, `user.id=766716`, `description contiene [Refinamiento Automático]`. Si encuentra al menos 1 entry coincidente: abortar imputación y registrar pista informativa. Cubre escenarios de re-ejecución del cron sobre la misma tarea; (c) **sección 10.5 — limpieza retroactiva**: documentadas las 6 tareas conocidas con entries duplicadas del Sprint 6-26 para que el PO líder ejecute limpieza manual one-shot (eliminar la segunda entry de cada par, conservar la primera); (d) **sección 17 limitaciones — entrada actualizada**: "Tags de time entry rechazados si no preexisten" → "Tags de time entry causaban duplicación silenciosa (bug v1.7) — resuelto en v1.8"; (e) **frontmatter `description`** — actualizada referencia v1.7 → v1.8; (f) **description del time entry** — actualizada referencia v1.7 → v1.8 en sección 10.1. **Validación esperada tras deploy v1.8**: 0 duplicaciones nuevas. La verificación es trivial — buscar entries con `start`/`end`/`task_id` idénticos generadas por la skill. **Pendiente operativo tras deploy**: ejecutar limpieza retroactiva de las 6 entries fantasma documentadas. Tras limpieza, los AUTOIAs Fabián, Paolo y Alejandro deberían reflejar el cuadre correcto automáticamente vía SUMAR.SI. |
| v1.9 | 2026-05-31 | **Robustez de escrituras MCP, corrección de status hardcodeado y merge del backlog de diseño del 12/05 (nunca fusionado).** Cambios: (a) **sección 8.0 nueva** — serialización de escrituras sobre una misma tarea: los 3 comentarios (8.2 → 8.4 → 8.6) y las subtareas se publican en estricta secuencia, nunca en paralelo. Resuelve el bloqueador-mcp "The connector's server isn't responding" al lanzar 3+ comment_create simultáneos (detectado en tarea `869dg2n6p`); (b) **sección 8.6 reescrita como gate de último paso** — el marker "Primer Refinamiento Individual Realizado" solo se publica tras confirmar éxito de 8.2 y 8.4. Elimina la alteración del orden cronológico tras reintentos (también `869dg2n6p`); si los previos fallan, no se marca y la tarea se reprocesa (14.4); (c) **sección 11 reescrita** — corregido el status hardcodeado `Product Backlog`: ahora la skill lee los statuses de la lista y mapea (`product backlog` → `sprint backlog` → `backlog` → primer to-do tras open); si ninguno casa, warning. Cierra el bucle de reprocesamiento detectado en INEFSO-Dinam (status real `sprint backlog`, ejecución 06/05); (d) **sección 3.8 nueva (opción híbrida c)** — en tareas saltadas por diálogo de equipo (3.2), la skill preserva la petición original literal en un comentario con marker `Requerimientos Cliente preservados por skill`, sin tocar nombre/campos/estado; idempotente. Decisión de Néstor 31/05; (e) **sección 12.6 ampliada** — escalado tras 3 días sin tarea mensual de Gestión/Soporte localizable: pista al reporte mencionando a Néstor para dar visibilidad real (antes el warning era silencioso e indefinido); (f) **sección 13.3 ampliada** — anti-repetición de pistas 14.6/14.7 vía marker en la propia tarea (solo se reporta la primera vez; las recurrentes se silencian) + agrupación del bloque 🔍 por categoría (categorías cerradas estables); (g) **secciones 14.6 y 14.7 actualizadas** — dejan marker `Pista 14.6/14.7 — Procesamiento Soporte Skill` la primera vez; (h) **sección 14.9 nueva** — auditoría dirigida sobre el catálogo de markers de pistas, antesala de la futura skill `auditoria-duplicados-soporte-reinicia`; (i) **sección 1.3 nueva** — glosario de markers como fuente de verdad única de todos los literales; (j) **sección 17** — añadidas dos limitaciones: límite de concurrencia del MCP (mitigado por 8.0 + 8.6) y status de backlog variable entre listas (mitigado por sección 11); (k) **frontmatter `description` y description del time entry** — referencia v1.8 → v1.9. **Decisión de diseño registrada**: el tag `error tiempo` que algunas tareas brutas traen del workflow del workspace NO se gestiona ni se retira ni se avisa de él (decisión Néstor 31/05) — la skill lo ignora. **Sin pendientes operativos nuevos**; siguen abiertos los heredados (auditoría one-shot de duplicados v1.7, limpieza de 6 entries fantasma v1.8, config de la tarea Cowork y validación de canales Cliq v1.6). |
| v1.10 | 2026-05-31 | **Cambio de cadencia del cron y rediseño de la ventana del resumen diario; sin cambios en la lógica de procesamiento individual.** Cambios: (a) **sección 1.2 y frontmatter** — cadencia "cada 2 horas" → "Lun–Vie 08:00/11:00/14:00/17:00/22:00 (Europe/Madrid)"; cron `0 8,11,14,17,22 * * 1-5`. Prompt reescrito: alcance explícito a TODOS los clientes de la sección 2 (ya no "piloto"), guardarraíl para clientes con Soporte fuera de la sección 2, el marker de procesado se describe como **comentario** (no tag, para no confundir con los tags de ClickUp), modelo Opus 4.7 → 4.8; (b) **sección 12.1 rediseñada** — la ventana del resumen pasa de "día en curso / día anterior" a **«desde el último resumen publicado (timestamp del comentario 12.5) hasta ahora»**. El resumen se publica en la pasada de las 22:00; en lunes la ventana arranca en el resumen del viernes 22:00, por lo que cubre automáticamente viernes-noche + fin de semana + lunes (robusto ante actividad manual, husos horarios y ejecuciones omitidas, ya que el cron no corre sáb/dom). Recuperación en la pasada de las 08:00 solo si la de las 22:00 del día hábil anterior no publicó; (c) **sección 12.2** — la ventana de selección de tareas se remite a 12.1 en lugar de "últimas 24h"; (d) **sección 12.4** — cabecera del resumen: fecha única o rango "YYYY-MM-DD → YYYY-MM-DD" cuando abarca varios días; (e) **sección 12.5** — aclarado que el *timestamp de creación* del comentario-resumen es la cota inferior de la ventana; (f) **sección 19** — descripción, cadencia (con cron) y modelo (4.8); (g) **frontmatter `description` y description del time entry** — referencia v1.9 → v1.10. **Motivación:** la franja vespertina quedaba sin resumir hasta el día siguiente y el patrón "día anterior" dejaba huecos en fin de semana / actividad en otros husos. **Sin pendientes operativos nuevos** salvo reconfigurar cadencia y prompt en la tarea Cowork; siguen abiertos los heredados (auditoría one-shot de duplicados v1.7, limpieza de entries fantasma v1.8, validación de canales Cliq v1.6). |
| v1.11 | 2026-06-02 | **Robustez del disparo del resumen y de la detección; sin cambios en el patrón de tarjeta ni en el alcance de clientes.** Cambios: (a) **sección 12.1** — el disparo del resumen deja de depender de la hora de reloj ("hora ≥ 22:00") y pasa a identificarse por la **posición en el calendario del cron** (primera / intermedia / última pasada del día). Motivo: el 01/06 la routine corría en UTC en vez de Europe/Madrid, de modo que la pasada de las 22:00 se ejecutó a las 00:07 de Madrid y caía fuera de todo umbral horario; con la lógica anterior el resumen podría no publicarse en días con actividad. La ventana «desde el último resumen hasta ahora» y la cobertura de fin de semana (lunes) se mantienen; (b) **sección 1.2** — bullets del resumen del prompt reescritos en términos de "última/intermedia/primera pasada del día" (requiere re-pegar el prompt en la routine); (c) **sección 3.7** — la detección pasa a consultar **lista por lista** (un `list_ids` por llamada, en bucle) con reintento por lista, en vez de multi-lista; el filtro multi-lista falla de forma intermitente mientras que la consulta individual es fiable (validado 01/06); (d) **sección 19** — nota obligatoria de TZ `Europe/Madrid` con la lección del desfase UTC y por qué no compensarlo con un offset fijo en el cron; (e) **frontmatter `description` y description del time entry** — referencia v1.10 → v1.11. **Acción pendiente del PO líder (no es cambio de skill):** (1) fijar la TZ de la routine a `Europe/Madrid`; (2) re-pegar el prompt de la sección 1.2 en la routine; (3) reconciliar **Tee Travel** (lista Soporte `901217991748` fuera de la sección 2, con tareas ya refinadas a nombre de Néstor): añadirlo a la sección 2 o confirmar su exclusión, y auditar el resto de listas `Soporte *` del workspace. Siguen abiertos los heredados (auditoría one-shot de duplicados v1.7, limpieza de entries fantasma v1.8, validación de canales Cliq v1.6). |

---

## 19. Notas operativas para registrar la tarea programada en Cowork

Cuando el PO registre la tarea programada de Cowork:

1. Comando: abrir Cowork → `/schedule`.
2. Nombre: `Procesamiento Soporte Reinicia`.
3. Descripción: `Procesa de lunes a viernes (08:00/11:00/14:00/17:00/22:00, Europe/Madrid) las tareas brutas de soporte de los clientes activos configurados en la skill y publica el resumen diario consolidado en la pasada de las 22:00.`
4. Prompt: el documentado en sección 1.2.
5. Cadencia: **lunes a viernes a las 08:00, 11:00, 14:00, 17:00 y 22:00**. Cron equivalente: `0 8,11,14,17,22 * * 1-5`. **Zona horaria: `Europe/Madrid` (obligatorio).** ⚠️ Si el scheduler corre en UTC o sin TZ definida, en horario de verano (CEST = UTC+2) las pasadas se desplazan +2h y la de las 22:00 cae a las 00:07 de Madrid (detectado 01/06). No lo compenses moviendo el cron a `20:00 UTC`: cuadraría en verano pero se rompería en invierno (CET = UTC+1). La solución correcta es fijar la TZ a `Europe/Madrid`. (Desde v1.11 el disparo del resumen ya no depende de la hora de reloj, pero la TZ debe estar bien igualmente, porque afecta a la hora real de todas las pasadas.) Si el planificador no admite cron, registrar las cinco horas como disparos diarios restringidos a Lun–Vie.
6. Modelo: **Opus 4.8**.
7. Carpeta: la del proyecto `Asesor Product Owners Reinicia`, para que la tarea programada herede las skills y MCPs disponibles.

Si en algún momento se migra a Routines de Claude Code (background 24/7 sin necesidad de app abierta), la skill funciona idéntica — solo cambia el disparador. Skill agnóstica del mecanismo de scheduling.
