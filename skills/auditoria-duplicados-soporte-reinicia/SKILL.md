---
name: auditoria-duplicados-soporte-reinicia
description: >
  Skill auxiliar de auditoría (no de creación, 100% read-only sobre las tareas auditadas) sobre las
  listas Soporte [CLIENTE] de Reinicia. Detecta y presenta, sin borrar ni modificar nada en las
  tareas auditadas, tres residuos de versiones antiguas del cron de soporte: (A) duplicados tarjeta
  canónica ↔ form_response de v1.0–v1.6; (B) time entries duplicadas del Refinamiento Automático
  (bug resuelto en v1.8); (C) catálogo de tareas con Pista 14.6/14.7 (sección 14.9 de la skill madre).
  Entrega el informe como comentarios separados, uno por Product Owner y asignado a él, en la tarea de
  seguimiento configurada (869bt8w6w), citando cada PO solo sus clientes, y deja al PO el click de
  borrado/fusión. Activación manual ("audita los duplicados de soporte") o como tarea programada
  semanal. No procesa tareas brutas (soporte-procesamiento-clickup-reinicia) ni crea productos.
triggers:
  - audita los duplicados de soporte
  - pasa la auditoria de soporte
  - revisa duplicados en las listas de soporte
  - limpia duplicados de soporte
  - auditoria de soporte
---

# SKILL: Auditoría de Duplicados de Soporte — Reinicia

> ✅ **VERSIÓN v1.1 — Calibrada + refinada.** Diseño cerrado y calibrado en pasada supervisada read-only sobre Carritech y Gonher (31/05). Confirmados los dos TODOs que bloqueaban lo desatendido (asignación de comentario y tarea destino). v1.1 añade la categoría "submisiones solapadas" (dos `form_response`, nunca borrar) y la detección del Módulo B por prefijo estable. Pendiente la **primera publicación real** validada antes de programar la rutina. Hereda convenciones de `soporte-procesamiento-clickup-reinicia` y `formato-tarjeta-clickup-reinicia`.

---

## Propósito

El cron de procesamiento de soporte (`soporte-procesamiento-clickup-reinicia`) ha pasado por varias versiones. Algunas anteriores a v1.7 dejaron residuos en las listas `Soporte [CLIENTE]`:

- **Duplicados de tarjeta**: versiones v1.0–v1.6 a veces creaban una tarjeta canónica paralela en lugar de editar el `form_response` original (bug cerrado por la regla 5.0 en v1.7). Resultado: pares `form_response` (fuente de verdad, con los adjuntos del formulario) ↔ canónica `[TIPO] ... [CLIENTE]` (duplicado a eliminar).
- **Time entries fantasma**: el fallback de `tags` de v1.7 generaba 2 entries idénticas de Refinamiento Automático en algunos casos (bug cerrado en v1.8). Inflan los AUTOIAs.
- **Ruido de pistas dormidas**: tareas marcadas con `Pista 14.6/14.7` que el PO líder debe revisar periódicamente (sección 14.9 de la skill madre).

Esta skill **audita** estos tres frentes y produce un informe accionable. **No es una skill de creación ni de borrado**: detecta, clasifica por confianza y presenta. El borrado o la fusión los ejecuta siempre una persona.

---

## Principio rector — DETECTAR, NUNCA BORRAR

**La skill no llama jamás a `clickup_delete_task`, no elimina time entries y no escribe nada en las tareas auditadas (100% read-only sobre el ámbito auditado).** La única escritura que realiza es publicar el informe como comentarios en la tarea de seguimiento configurada (sección "Entrega del informe"). La decisión destructiva es siempre humana. La skill:

1. Detecta el residuo.
2. Lo clasifica por nivel de confianza (alta / media / baja).
3. Comprueba si el candidato a borrado tiene **trabajo único** que se perdería (ver módulo A.4).
4. Lo presenta en el informe con la recomendación y el enlace directo, dejando al PO el click.
5. **No marca las candidatas** (decisión 31/05: read-only). Para no repetir hallazgos cada semana, la anti-repetición se hace **leyendo los comentarios previos de la propia tarea destino**, no escribiendo en las tareas auditadas (ver "Entrega del informe").

Esto es coherente con la regla de la skill madre: "la decisión final de eliminar el duplicado es siempre humana — la skill nunca borra tarjetas".

---

## Relación con otras skills

```
soporte-procesamiento-clickup-reinicia (cron cada 2h — crea/refina)
  ↓ (deja residuos históricos + markers de pista 14.6/14.7)
auditoria-duplicados-soporte-reinicia (esta skill — auditoría periódica)
  ↓ (informe accionable)
PO líder (ejecuta borrado/fusión con un click)
```

- **Fuente de verdad de clientes/listas**: la **sección 2 de `soporte-procesamiento-clickup-reinicia`**. Esta skill NO mantiene su propia tabla de clientes — la lee de la madre para no desincronizarse.
- **Convenciones de tarjeta y markers**: `formato-tarjeta-clickup-reinicia` + sección 1.3 (glosario de markers) de la skill madre.

---

## Cuándo activar

- **Manual**: el PO escribe alguno de los triggers.
- **Programada (semanal)**: tarea de Cowork/Routine que pasa la auditoría completa sobre las 15 listas y publica el informe en la tarea de seguimiento. Cadencia semanal alineada con el ritmo de sprint; el residuo es lento, no necesita cada 2h.

NO usar para: procesar tareas brutas (skill madre), crear productos (skills de creación), ni para borrar automáticamente (prohibido por el principio rector).

---

## Ámbito y configuración

1. La skill lee la **sección 2 de la skill madre** para obtener la lista canónica de clientes activos y sus IDs de lista `Soporte [CLIENTE]`.
2. Si el PO acota a un subconjunto ("audita solo Carritech y Gonher"), respeta el filtro. Por defecto, las 15 listas.
3. Confirma al inicio (Paso 0): clientes a auditar (por defecto las 15), módulos a ejecutar (A / B / C — por defecto los tres) y los flags `soporte_lista_de_trabajo` por cliente (ver C.1). El destino del informe está fijado (tarea `869bt8w6w`); solo se pregunta si el PO quiere otro.

---

## Módulo A — Duplicados tarjeta canónica ↔ form_response (pendiente 10, v1.7)

### A.1 Qué busca

Dos subtipos distintos:

**Subtipo 1 — form_response ↔ canónica `create_task` (el bug v1.0–v1.6).** Pares en la **misma lista de Soporte** donde coexisten:

- una **form_response** (`task_type = form_response`) — la fuente de verdad, conserva adjuntos del formulario; y
- una **canónica** (`task_type != form_response`, normalmente creada con `clickup_create_task`) con nombre que casa el patrón `[TIPO] ... [CLIENTE]` (TIPO ∈ BUG / MEJORA / DUDA / PETICIÓN / SOPORTE-SERVIDOR).

**Subtipo 2 — submisiones de cliente solapadas (dos `form_response`) (añadido v1.1).** Dos tareas **ambas `task_type = form_response`** en la misma lista sobre el mismo asunto (típicamente una en inglés y otra en español, o enviadas con días de diferencia). NO es el bug de canónica paralela: son dos envíos del cliente que se solapan. A menudo **ya enlazadas entre sí por una persona** (`linked_tasks` con `userid` humano). Caso real detectado en Carritech: `869d3ph4d` (EN) ↔ `869d5qxja` (ES), enlazadas por Néstor. Este subtipo **nunca se borra** — ver A.4.

### A.2 Heurística de emparejamiento (señales combinables)

Calibrada en la pasada del 31/05 (Carritech + Gonher). **Importante:** `clickup_filter_tasks` NO devuelve `task_type`, `linked_tasks` ni `date_created` — solo nombre, estado, tags y asignados. Por eso el emparejamiento se hace en dos fases (ver Flujo): triaje barato por nombre y, solo sobre candidatos, `clickup_get_task` para leer `task_type` / `linked_tasks` / contenido.

| Señal | Peso | Notas |
|---|---|---|
| `linked_tasks` entre ambas | Fuerte | El cron antiguo solía enlazarlas; señal casi definitiva (verificar con `get_task`) |
| Misma lista + ambas con patrón canónico `[TIPO]...[CLIENTE]` y `task_type` distinto | Fuerte | Una form_response y una canónica creada aparte sobre el mismo asunto |
| **Mismo asunto en dos idiomas** (EN ↔ ES) en la misma lista | Media | Detectado en Carritech: `869d3ph4d` "Updated prices… Zoho widget" (EN) vs `869d5qxja` "Precios… widget Zoho" (ES). Puede ser submisión del cliente (EN) + ticket interno (ES). Confirmar con `get_task` que una es form_response |
| Similitud de texto: descripción del form_response ≈ bloque "📥 Requerimientos Cliente" de la canónica | Media | La canónica preservó el literal del original |
| Proximidad temporal (canónica creada poco después del form_response) | Media | |
| Marker explícito `[DUPLICATED]` o `[TEST]` en el nombre | Fuerte (housekeeping) | Carritech ya tiene tareas autoetiquetadas así; se listan aparte como limpieza menor, no como par A |

**Aprendizaje de calibración:** el rendimiento del Módulo A es **bajo** en la práctica. El bug de canónica paralela de v1.0–v1.6 dejó pocos residuos visibles (los clientes form-driven recientes ya entraron con v1.6+, y los hand-driven apenas usan formulario). No esperar muchos pares; priorizar precisión sobre exhaustividad.

### A.3 Clasificación de confianza

- **Alta**: `linked_tasks` + nombre canónico + misma lista, **con una de las dos `task_type != form_response`** (subtipo 1, el bug real).
- **Media**: similitud de texto alta + proximidad temporal, sin enlace explícito (subtipo 1 probable).
- **Submisiones solapadas (subtipo 2)**: ambas `form_response`. Confianza media como *solapamiento*, pero categoría propia con recomendación REVISAR (nunca borrar — A.4). Si **ya están enlazadas por una persona**, se marca como **informativo** ("ya enlazadas por [usuario] el [fecha]") — un humano ya las trió; la skill solo lo recuerda, no propone acción destructiva.
- **Baja**: solo nombre canónico en la misma lista (puede ser una tarjeta legítima creada a mano — caso 14.6 de la madre). Las de confianza baja se reportan como "posibles", nunca como recomendación de borrado.

### A.4 Qué hace con cada par — comprobación de trabajo único antes de recomendar

Para cada par detectado, **antes** de recomendar nada, la skill inspecciona la canónica buscando contenido que NO esté en el form_response y que se perdería al borrar:

- Subtareas con trabajo/comentarios.
- Time entries imputadas (¡trabajo real del equipo!).
- Comentarios sustantivos del equipo (excluyendo ClickBot y el propio marker).
- Campos personalizados rellenos que el form_response no tenga.

Según el resultado:

- **Subtipo 1, sin trabajo único** → recomendación: **"Borrar canónica, conservar form_response"**. La form_response es la fuente de verdad.
- **Subtipo 1, con trabajo único** → recomendación: **"Requiere fusión manual"** — listar qué se perdería (subtareas X, N time entries de [persona], etc.) para que el PO migre lo aprovechable al form_response antes de borrar. La skill nunca fusiona automáticamente.
- **Subtipo 2 (dos `form_response` solapadas)** → recomendación: **"REVISAR solapamiento, no borrar"**. Ambas son submisiones legítimas del cliente y suelen tener contenido propio. Presentar las dos con su idioma/fecha y señalar cuál tiene el trabajo activo (subtareas/horas). Si ya están enlazadas por una persona, marcar **informativo**. El PO decide si consolidar el alcance o mantenerlas separadas. La skill nunca borra ni fusiona.

En ambos casos, la skill **no escribe nada en la canónica** (read-only). El hallazgo se incluye únicamente en el informe de la tarea destino. La anti-repetición entre auditorías semanales se resuelve cotejando los comentarios previos de la tarea destino (ver "Entrega del informe"), no marcando la canónica.

---

## Módulo B — Time entries duplicadas del Refinamiento Automático (pendiente 11, v1.8)

> Mismo patrón "detectar duplicados, humano borra". Módulo estándar (confirmado 31/05).

### B.1 Qué busca

Time entries del Refinamiento Automático agrupadas por `task_id`, donde existan **dos o más con `start`/`end` idénticos** → la segunda (y siguientes) son fantasma del bug de tags v1.7.

**Detección por prefijo estable (v1.1):** identificar las entries del cron por el prefijo `"Refinamiento automático de soporte por skill"` en `description`, **no** solo por el sufijo `[Refinamiento Automático]`. Motivo: las entries de v1.7 antiguas (p. ej. en `869d8hzn1`) traen el texto "…por skill … v1.7" **sin** el sufijo; filtrar solo por el sufijo las dejaría fuera. El prefijo cubre todas las versiones.

### B.2 Semilla conocida — solo punto de partida, NO verdad

Las 6 tareas documentadas en v1.8 (Sprint 6-26) son el punto de partida: Avaderm `869d6yc31`, Carritech `869d7cx7p` y `869d8hzn1`, HomeEspaña `869d8aah5`, Breezom `869d9dg5b` y `869d9dh4z`.

**Aprendizaje de calibración (31/05):** la semilla NO es la verdad. El Módulo B debe evaluar el **estado actual** de cada tarea, no asumir que los seeds siguen sucios. En la pasada, `869d7cx7p` ya tenía **una sola** entry (limpio) → parte del pendiente 11 ya se resolvió manualmente. La auditoría parte de los seeds pero confirma vía `clickup_get_task_time_entries` y, sobre todo, **descubre duplicados nuevos** recorriendo las tareas de cada lista que tengan entries con `[Refinamiento Automático]`.

### B.3 Qué hace

Presenta cada grupo duplicado: task, las N entries idénticas, cuál conservar (la primera) y cuáles son candidatas a borrado. **No borra** — el PO ejecuta la limpieza. Tras limpieza, los AUTOIAs recalculan solos vía SUMAR.SI.

**Confirmado (31/05):** el MCP de ClickUp no expone tool de borrado de time entry (solo `get`/`add`/`start`). El Módulo B es por tanto **solo informe**: da la ruta exacta (task + timestamp de la entry a borrar) y el PO la elimina desde la UI.

---

## Módulo C — Catálogo de pistas 14.6/14.7 (sección 14.9 de la skill madre)

Recolecta todas las tareas en listas de Soporte con comentario marker `Pista 14.6 — Procesamiento Soporte Skill` o `Pista 14.7 — Procesamiento Soporte Skill` y las presenta como catálogo navegable para que el PO decida caso por caso: mover a `General [CLIENTE]`, cerrar por obsolescencia, o procesar manualmente. Esto materializa la auditoría dirigida que la skill madre habilitó en v1.9.

### C.1 Toggle por cliente — listas *hand-driven* (aprendizaje 31/05)

**Problema detectado en la pasada:** hay clientes cuya lista de Soporte se usa intencionalmente como **lista de trabajo del proyecto**, llena de tareas creadas a mano (no `form_response`). Caso claro: **Gonher** — la mayoría de sus tareas son títulos libres creados por el equipo, no submisiones de formulario. Marcar todas esas tareas como Pista 14.6 ("no-form_response en Soporte") generaría decenas de falsos positivos e inundaría el comentario al PO.

**Regla:** cada cliente lleva un flag `soporte_lista_de_trabajo` (true / false):

- **`true`** (lista hand-driven, p. ej. Gonher): el Módulo C **se suprime** para ese cliente — no se reportan tareas no-`form_response` como pistas 14.6. Sí se siguen reportando las pistas 14.7 (form_response dormida) y los Módulos A/B.
- **`false`** (lista puramente de soporte por formulario, p. ej. Carritech): Módulo C activo normal.

El flag se define junto al cliente (sección 2 de la madre, o configuración propia de esta skill si la madre no lo incorpora). Por defecto `false`; el PO líder marca `true` los clientes cuya lista de Soporte es lista de trabajo. **Pendiente de validación**: confirmar con Pablo/Óscar qué clientes son hand-driven antes de la primera publicación real.

---

## Flujo de ejecución

Calibrado en dos fases para no disparar el coste (lección 31/05: `filter_tasks` da inventario barato pero sin `task_type`/`linked_tasks`/`date_created`; estos solo llegan con `get_task`, que se reserva para candidatos).

- **PASO 0 — Confirmación**: clientes a auditar, módulos (A/B/C), flags `soporte_lista_de_trabajo`. Destino fijo (`869bt8w6w`).
- **PASO 1 — Carga de configuración**: leer sección 2 de la skill madre → listas de Soporte + PO Cliente + flag hand-driven.
- **PASO 2 — FASE 1: inventario barato + triaje**: `clickup_filter_tasks` por lista (`include_closed=true`, `subtasks=false`, paginando — la API tope ~50-100 por página). Triar por patrón de nombre: form_responses ("Form Submission"/`#fecha`), canónicas `[TIPO]...[CLIENTE]`, housekeeping (`[DUPLICATED]`/`[TEST]`), pares cross-language, y tareas a mano (candidatas 14.6).
- **PASO 3 — FASE 2: confirmación de candidatos**: `clickup_get_task` SOLO sobre los candidatos del triaje (no sobre toda la lista) para leer `task_type`, `linked_tasks`, `date_created` y contenido.
- **PASO 4 — Módulo A**: emparejar (A.2), clasificar (A.3), comprobar trabajo único (A.4).
- **PASO 5 — Módulo B**: `clickup_get_task_time_entries` sobre seeds + tareas con `[Refinamiento Automático]`; agrupar por `start/end`; detectar duplicados sobre **estado actual**.
- **PASO 6 — Módulo C**: recolectar markers de pista, **respetando el flag `soporte_lista_de_trabajo`** (suprime 14.6 en listas hand-driven).
- **PASO 7 — Resolución de PO**: mapear cada cliente con hallazgos a su PO Cliente (dinámico, sección 8.1 madre).
- **PASO 8 — Cotejo anti-repetición**: leer comentarios previos de la tarea destino para clasificar nuevos / ya reportados / resueltos.
- **PASO 9 — Entrega**: publicar un comentario por PO, asignado (`assignee`), serializado, en `869bt8w6w`.

---

## Entrega del informe

### Destino
La tarea de seguimiento configurada: **`869bt8w6w`** = "Reunión de POs 2026 [METODOLOGÍA REINICIA]" (carpeta Metodología, lista Sprint actual), asignada a Néstor, Pablo y Óscar.

**Confirmado (31/05):** es la tarea **anual** de la reunión de POs — destino **fijo para todo 2026**, no rota mensualmente. Encaja con la cadencia semanal: la auditoría aterriza donde los POs se reúnen. Cuando se cree la equivalente de 2027, repuntar el destino. Parametrizable en el Paso 0 por si el PO quiere otro.

### Un comentario por Product Owner, asignado, con sus clientes únicamente
El informe **no se publica como un único comentario**. La skill agrupa los hallazgos por **Product Owner propietario** y publica **un comentario por PO, asignado a ese PO**, que cita **solo sus clientes**:

- **Equipo Columbia → Pablo Losada (`87715920`)**: Gonher, Avaderm, Líder System, Aicrov, Tee Travel, Moradillo, Exeltis, Ecophon, Kasblan.
- **Equipo Proactive → Óscar Díez (`93631901`)**: INEFSO, Mazarea, Carritech, Ti-Medi, Synuptic, Breezom, BirdEase, Ingelyt, Lacroix, Aunna, HomeEspaña, ISL Agency, Niuvo.

La asignación cliente → PO se resuelve **dinámicamente** desde la estructura de equipos / el PO Cliente de la sección 8.1 de la skill madre, no se hardcodea (los rosters cambian). Si un cliente no resuelve a ningún PO, va a un comentario "Sin PO asignado" para Néstor (`766716`).

`clickup_create_task_comment` sobre `869bt8w6w` con el PO como **asignado del comentario** vía el parámetro `assignee` (User ID). Comentarios **serializados** (uno tras otro, nunca en paralelo — misma regla 8.0 de la madre).

**Confirmado (31/05):** `clickup_create_task_comment` acepta `assignee` (User ID) y `notify_all`. El comentario asignado por PO funciona de forma nativa, sin necesidad del fallback de @mención. Usar `notify_all=false` y dejar que la asignación notifique solo al PO correspondiente.

### Anti-repetición read-only (cotejo con comentarios previos)
Como no se marcan las candidatas (read-only), antes de publicar la skill **lee los comentarios previos de la propia tarea destino** (`clickup_get_task_comments` + `clickup_get_threaded_comments`, filtrando los suyos por el encabezado del informe) y estructura cada comentario de PO en tres bloques:

- **Nuevos esta semana**: hallazgos no presentes en la última auditoría.
- **Ya reportados**: recordatorio compacto (recuento + enlaces, sin volver a detallar).
- **Resueltos desde la última auditoría**: candidatos que ya no aparecen (el PO actuó o se borraron) — refuerzo positivo y cierre de bucle.

Así la cadencia semanal no spamea: cada semana el PO ve qué cambió, no la lista entera repetida.

### Formato del comentario (texto plano — sin markdown, sin hipervínculos)
Comentarios en **texto plano** (limitación de comentarios ClickUp de la madre): texto descriptivo y la URL en la línea siguiente.

```
Auditoría de Duplicados de Soporte — [fecha] — PO: [Nombre]
(Solo tus clientes. Ninguna acción destructiva ejecutada; el borrado/fusión lo haces tú.)

NUEVOS ESTA SEMANA

[CLIENTE]
A) Duplicado tarjeta (confianza ALTA) — recomendación: BORRAR canónica
   Canónica:
   https://app.clickup.com/t/...
   Duplica a form_response:
   https://app.clickup.com/t/...

A) Duplicado tarjeta (confianza MEDIA) — recomendación: FUSIÓN MANUAL
   Se perdería: 3 subtareas, 2 time entries de Fabián
   Canónica:
   https://app.clickup.com/t/...
   form_response:
   https://app.clickup.com/t/...

B) Time entries duplicadas Refinamiento Automático
   Tarea (conservar la 1ª, borrar la 2ª, start [ts]):
   https://app.clickup.com/t/...

C) Pista dormida [14.6 / 14.7]
   https://app.clickup.com/t/...

YA REPORTADOS (sin cambios): [N] — ver auditoría anterior
RESUELTOS DESDE LA ÚLTIMA AUDITORÍA: [N]

RESUMEN PARA TI
Candidatas a borrado (sin trabajo único): [N]
Requieren fusión manual: [N]
Time entries fantasma: [N]
Pistas dormidas: [N]
```

---

## Herramientas MCP

Confirmadas en la pasada del 31/05.
- `clickup_filter_tasks` (`include_closed=true`, `subtasks=false`, paginar) — FASE 1, inventario barato. No devuelve `task_type`/`linked_tasks`/`date_created`.
- `clickup_get_task` (`detail_level=detailed`, `subtasks=true`) — FASE 2, solo candidatos: `task_type`, `linked_tasks`, `date_created`, contenido, trabajo único.
- `clickup_get_task_comments` + `clickup_get_threaded_comments` — markers de pista, comentarios sustantivos, y cotejo anti-repetición sobre la tarea destino.
- `clickup_get_task_time_entries` — módulo B (por tarea; evita la limitación de `get_time_entries`).
- `clickup_resolve_assignees` / `clickup_get_workspace_members` — resolver IDs de PO.
- `clickup_create_task_comment` (`assignee`, `notify_all=false`) sobre `869bt8w6w` — **única escritura de la skill**; un comentario por PO, serializado (regla 8.0 de la madre).
- **NUNCA**: `clickup_delete_task`, borrado de time entries, ni escritura alguna sobre las tareas auditadas (read-only).

---

## Limitaciones conocidas

- **`clickup_filter_tasks` no devuelve `task_type`, `linked_tasks` ni `date_created`** → obliga al flujo en dos fases (triaje por nombre + `get_task` solo en candidatos). Confirmado 31/05.
- **Paginación**: `filter_tasks` devuelve un tope por página (~50-100). El run real debe paginar hasta agotar cada lista; la pasada de calibración se quedó en la primera página.
- Detección por similitud de texto e idioma cruzado: falsos positivos posibles → confianza media/baja nunca recomienda borrado directo, solo señala.
- `clickup_get_time_entries` solo devuelve tiempos del usuario autenticado salvo pasando `assignee_id` — para módulo B usar `clickup_get_task_time_entries` por tarea.
- Borrado de time entry: el MCP no expone un tool de borrado de entry → módulo B es **solo informe** (la limpieza la hace el PO desde la UI con la ruta exacta task + timestamp).
- Listas *hand-driven* (Gonher): sin el flag `soporte_lista_de_trabajo`, el Módulo C produciría decenas de falsos positivos 14.6 — ver C.1.

---

## Versionado

| Versión | Fecha | Cambios |
|---|---|---|
| v0.1 (esqueleto) | 2026-05-31 | Esqueleto inicial. Propósito, principio "detectar nunca borrar", 3 módulos (A duplicados tarjeta / B time entries fantasma / C catálogo pistas), flujo macro, formato de informe y marker `Candidata duplicado`. Hereda sección 2 y glosario de markers de la skill madre. |
| v0.2 (decisiones cerradas) | 2026-05-31 | Cerradas las 4 decisiones de diseño con Néstor: (1) **módulo B entra** como estándar (no opcional); (2) **cadencia semanal** (antes mensual); (3) **100% read-only** sobre las tareas auditadas — se elimina el marker `Candidata duplicado` en las canónicas; la anti-repetición pasa a cotejar los comentarios previos de la tarea destino (bloques nuevos / ya reportados / resueltos); (4) **entrega del informe** en la tarea `869bt8w6w` como **un comentario por PO, asignado a cada uno, citando solo sus clientes** (resolución cliente→PO dinámica vía sección 8.1 madre; Columbia→Pablo `87715920`, Proactive→Óscar `93631901`). Añadido PASO 6-8 (resolución PO, cotejo, entrega). Pendiente calibración técnica en primera ejecución real para promover a v1.0. |
| **v1.1 (refinada)** | 2026-05-31 | Refinamientos destapados por la pasada de prueba v1.0 sobre Carritech+Gonher: (1) **categoría "submisiones solapadas"** en el Módulo A — cuando ambas tareas son `form_response` (no hay canónica `create_task`), es un solapamiento de envíos del cliente, no el bug v1.0–v1.6; recomendación **REVISAR, nunca borrar**; si ya están enlazadas por una persona se marca informativo (caso real Carritech `869d3ph4d` EN ↔ `869d5qxja` ES, enlazadas por Néstor, una con 4 subtareas y 2h15). Actualizadas A.1 (dos subtipos), A.3 y A.4; (2) **Módulo B detecta por prefijo estable** `"Refinamiento automático de soporte por skill"` en vez de solo el sufijo `[Refinamiento Automático]`, porque las entries v1.7 antiguas no llevan el sufijo (visto en `869d8hzn1`). **Validación de la pasada v1.0**: el flujo en dos fases evitó recomendar borrar una tarjeta con trabajo; el flag de Gonher dejó el comentario de Pablo en "nada accionable" (vs ~60 falsos positivos); ambos seeds de Carritech (`869d7cx7p`, `869d8hzn1`) ya limpios. **Pendiente**: primera publicación real validada. |

---

## Pendientes antes de la primera publicación real

Diseño cerrado, calibrado y refinado. Quedan dos confirmaciones operativas, ninguna de diseño:

1. **Flags `soporte_lista_de_trabajo`**: confirmar con Pablo/Óscar qué clientes usan su lista de Soporte como lista de trabajo (seguro Gonher; revisar el resto).
2. **Primera publicación**: ejecutar sobre Carritech+Gonher paginando completo y publicar los comentarios por PO en `869bt8w6w`, revisando que el de Pablo (Gonher) salga limpio tras aplicar el flag.

> El par cross-language de Carritech (`869d3ph4d` / `869d5qxja`) quedó resuelto en la pasada v1.0: son dos `form_response` solapadas y ya enlazadas → categoría "submisiones solapadas", REVISAR (no borrar). Incorporado a la lógica en v1.1.
