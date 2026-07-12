---
name: deteccion-productos-estancados-clickup-reinicia
description: >
  Detecta a diario los productos y microcampañas de ClickUp parados (sin actividad humana real)
  en estados vigilados, avisa al PO correspondiente y, si el parón persiste, mueve la tarjeta a
  Parking. En v0.2 consume la columna inactivity_days_business precalculada por la función Cron
  de Zoho Catalyst (proyecto Reinicia-Clickup-Audit) y solo lee el hilo de ClickUp de los
  candidatos con >=5 días laborables, para podar falsos positivos, extraer compromisos vencidos y
  enrutar el aviso; si Catalyst no responde o el dato está obsoleto, cae al cálculo propio vía
  ClickUp MCP. Inactividad en días laborables (calendario de Madrid); ignora ClickBot, fórmulas y
  comentarios de mera intención. Actívala cuando el PO pida "detecta los productos parados de
  [Equipo]", "revisa los productos estancados", "qué tarjetas llevan paradas" o "avisa de los
  parones de ClickUp", o cuando se ejecute la Routine diaria. En tarjetas de Gestión avisa pero NUNCA las mueve
  a Parking. No usar para Sprint Backlogs.
---

# SKILL: Detección de Productos Estancados en ClickUp — Reinicia

> **Versión vigente: v0.3 — 12/07/2026** · ver changelog al final (`## Versiones`)

## Propósito

Detectar a diario las tarjetas de ClickUp (productos y microcampañas) que están en un estado
"activo" pero llevan **5 o más días laborables sin actividad humana real**, avisar al PO
correspondiente con un comentario informado por el histórico de la tarjeta, y —si el parón
alcanza **7 días laborables** sin progreso— moverlas automáticamente a Parking. Al cierre,
publicar un resumen en Zoho Cliq. **Excepción:** las tarjetas de **Gestión** se avisan como
recordatorio de seguimiento con el cliente, pero **nunca** se mueven a Parking (ver 0.9).

El objetivo no es generar comentarios, sino **provocar una acción del Equipo**: o se retoma el
trabajo, o la tarjeta sale del flujo activo a Parking.

> **Origen del dato (v0.2).** Un pipeline en Zoho Catalyst (proyecto `Reinicia-Clickup-Audit`)
> captura los eventos de ClickUp vía webhook, los normaliza por tarea y una **función Cron**
> (`inactivity_calculator`, diaria a las 05:30 Madrid) precalcula la columna
> `inactivity_days_business` de la tabla `clickup_task_activity`. Esta skill **consume esa columna**
> como fuente primaria (PASO 2) y solo lee el hilo de ClickUp de los candidatos ≥5 para podar y
> redactar (PASO 3). Si Catalyst no responde o el dato no es de hoy, **cae al cálculo propio**
> vía ClickUp MCP (camino de respaldo, idéntico a la v0.1). Ver 0.8 y PASO 3-FALLBACK.

---

## PASO 0 — CONFIGURACIÓN

Toda la configuración volátil vive aquí. No hardcodear asignaciones en el cuerpo.

### 0.1 Alcance del piloto

- **Equipo:** Columbia (PO líder: Pablo Losada, ClickUp `87715920`).
- **Clientes Columbia** (validar en cada pase; pueden cambiar sprint a sprint): Gonher, Avaderm,
  Líder System, Aicrov, Tee Travel, Moradillo, Exeltis, Ecophon, Kasblan.
- **Nombres canónicos en Catalyst** (`project_name` exacto de `clickup_task_activity`, ojo a los
  que no son obvios):

  ```
  Gonher · Avaderm · Líder System Grupo · Aicrov · Tee Travel ·
  Moradillo · Exeltis · Ecophon España · Kasblan
  ```

  > "Líder System Grupo" y "Ecophon España" llevan sufijo en la tabla; un match exacto por
  > `'Líder System'`/`'Ecophon'` los dejaría fuera (falso negativo). Usar los nombres completos.

- Para el **fallback** vía ClickUp MCP, el alcance se filtra por las listas `General [CLIENTE]`,
  `Soporte [CLIENTE]` y `Gestión [CLIENTE]` de esos clientes (microcampañas incluidas).

### 0.2 Estatus vigilados (lista blanca)

Solo se vigilan estos cuatro estados. Cualquier otro se ignora (incluidos `sprint backlog`,
`product backlog`, `open`, `parking e incidencias`, `done`, `closed`).

| Estado (etiqueta ClickUp) | Match normalizado | `current_status` en Catalyst |
|---|---|---|
| Doing | `doing` | `doing` |
| Doing Amigos | `doing amigos` | `doing amigos` |
| Validación Cliente | `validacion cliente` | `validación cliente` |
| Validación Reinicia | `validacion reinicia` | `validación reinicia` |

> **Match normalizado**: comparar en minúsculas y **sin acentos**. En la consulta ZCQL del PASO 2
> se filtra por el valor **exacto** (con acentos) tal como está en la tabla.

### 0.3 Umbrales (días laborables sin actividad real)

- **≥ 5 días laborables** → AVISO (una sola vez por racha; ver idempotencia).
- **≥ 7 días laborables** sin progreso real y con aviso ya dado → **mover a Parking** + comentario.

### 0.4 Calendario laboral — Madrid capital 2026

Días laborables = lunes a viernes, excluyendo estos festivos (validar los dos **locales** contra
el decreto del Ayuntamiento; el resto son nacionales/CAM). **Coincide con el calendario embebido
en la función de Catalyst** — mantener ambos sincronizados:

```
2026-01-01  Año Nuevo
2026-01-06  Epifanía
2026-04-02  Jueves Santo
2026-04-03  Viernes Santo
2026-05-01  Fiesta del Trabajo
2026-05-02  Comunidad de Madrid (sábado)
2026-05-15  San Isidro (LOCAL Madrid ciudad)
2026-08-15  Asunción (sábado)
2026-10-12  Fiesta Nacional
2026-11-02  Todos los Santos (trasladado)
2026-11-09  La Almudena (LOCAL Madrid ciudad)
2026-12-07  Día de la Constitución (trasladado)
2026-12-08  Inmaculada
2026-12-25  Navidad
```

### 0.5 Enrutado del aviso por estado

| Estado | A quién se avisa | Razón |
|---|---|---|
| `doing`, `doing amigos` | Asignados de la tarjeta + PO Técnico | El ejecutor está atascado |
| `validacion cliente` | PO Cliente | Se espera respuesta del cliente; el PO debe perseguir |
| `validacion reinicia` | PO Técnico / Reinicia | Validación interna pendiente |

Defaults Columbia (ajustar si procede): **PO Cliente = Pablo Losada `87715920`**;
**PO Técnico = Paolo Bergamelli `2447443`** salvo que la tarjeta indique otro. Siempre que un
nombre no esté en el workspace (p. ej. Amigos Reinicia), no asignar como assignee: mencionar en
el comentario.

### 0.6 Idempotencia

- Tag **`parado-avisado`**: se añade al dar el AVISO, se retira cuando se detecta progreso real.
- Firma de comentario: toda nota escrita por la skill termina con la línea
  `— Detección automática de estancamiento (Reinicia)` para reconocer comentarios propios y no
  contarlos como actividad.

### 0.7 Reporte

- Canal Zoho Cliq **#Canal de POs**: `unique_name = canaldepos`, id `T45816000000085071`.
- Herramienta: `ZohoCliq_Post_message_in_a_channel`.

### 0.8 Fuente de datos Catalyst (PASO 2 primario)

| Recurso | Valor |
|---|---|
| Org | `20114286252` |
| Proyecto | `Reinicia-Clickup-Audit` → `14075000000013090` |
| Entorno | **Development** |
| Tabla normalizada | `clickup_task_activity` → `14075000000018201` |
| Columna de inactividad | `inactivity_days_business` (se devuelve como **texto**: `parseInt`) |
| Función que la rellena | `inactivity_calculator` → `14075000000093007` (cron diario 05:30 Madrid) |
| Tabla cruda (histórico) | `clickup_events` → `14075000000013152` (la usa la función, no la skill) |

- Lectura vía MCP: `CatalystbyZoho_Execute_Query` con `headers {Catalyst-org, Environment}` y
  `path_variables {projectId}`.
- **Alcance del dato hoy:** la función calcula con `RESTRICT_TO_COLUMBIA = true`, así que la tabla
  solo trae inactividad de Columbia. Cuando se amplíe a todos los equipos, esta skill seguirá
  filtrando por su propio alcance (0.1).

### 0.9 Tratamiento especial de Gestión (avisar, nunca Parking)

Las tarjetas de **Gestión** se identifican por la **lista**: `list_name` que empieza por `"Gestión "`
(p. ej. "Gestión Avaderm", "Gestión Gonher"). Incluye las mensuales `Gestión [Mes] [CLIENTE]` y las
recurrentes de gestión que vivan en esas listas (p. ej. "Daily 2026"). **El discriminador es la
lista, no el nombre:** un producto real llamado "Gestión y actualización Middleware-SAP" que esté en
`General [CLIENTE]` NO es Gestión y se trata como cualquier producto.

Reglas para Gestión:
- **Nunca se mueven a Parking**, ni a ≥7 días laborables. La acción máxima es el AVISO (re-aviso si persiste).
- El aviso es un **recordatorio de seguimiento con el cliente** (plantilla propia en PASO 4): que el
  PO hable con el cliente sobre el estatus del proyecto **y del cliente en sí**, y deje en la tarjeta
  un comentario con el **resumen** de esa conversación.
- **Regla de progreso más estricta (PASO 1):** en Gestión, un comentario de mera constancia — "hablé
  con el cliente", "reunión con el cliente" — **NO cuenta como progreso**. Solo cuenta un comentario
  con **resumen real** de la conversación o un **enlace al acta**.

---

## PASO 1 — REGLA DE "ACTIVIDAD REAL" (clave de toda la skill)

Una tarjeta está parada cuando no ha tenido **actividad humana de progreso** dentro del umbral.
La función de Catalyst aplica ya esta regla para `status`, `time_spent` y asignación; la skill la
usa para (a) **podar** lo único que la función no mira —los comentarios de avance— y (b) como
**cálculo de respaldo** completo si Catalyst no está disponible.

**Cuenta como progreso (reinicia el contador):**
- Cambio de estado (`field: status`).
- Registro de tiempo / time entry (`field: time_spent`).
- (Re)asignación de la tarjeta.
- Comentario humano que **demuestre avance** (p. ej. "subido a producción", "resuelto",
  "entregado el documento", "configurado el flujo"). **⚠️ La función de Catalyst NO cuenta esto**
  (es conservadora con los comentarios), así que es justo lo que la skill debe podar en el PASO 3.

**NO cuenta como progreso (NO reinicia el contador):**
- Cualquier evento cuyo autor sea **ClickBot** (recálculos de fórmula, automatizaciones de tag).
- Cambios de campo de fórmula ("Sobrepasado", "Tiempo restante", etc.).
- Tags, follower add/remove.
- Comentarios de **mera intención o espera**: "voy a preguntar al cliente", "a la espera de
  respuesta", "lo reviso este puente", "lo miro mañana". Estos NO son progreso.
- Comentarios escritos por **esta misma skill** (reconocibles por la firma 0.6).

> **Regla estricta en tarjetas de Gestión (0.9):** un comentario de mera constancia de contacto
> ("hablé con el cliente", "reunión con el cliente", "llamada con [persona]") **NO cuenta como
> progreso**. Solo reinicia el contador un comentario con **resumen** de la conversación (estatus del
> proyecto y del cliente) o un **enlace al acta**.

> El criterio fino "¿este comentario demuestra avance?" lo decide Claude leyendo el texto. Ante
> la duda, tratar el comentario como **no-progreso** (es la dirección segura: como mucho se
> revisa una tarjeta de más).

---

## PASO 2 — DETECCIÓN DE CANDIDATOS (desde Catalyst)

Fuente primaria: la columna `inactivity_days_business` ya calculada. **No** se recorren todas las
listas de ClickUp; se hace una sola lectura a Catalyst.

1. **Consulta ZCQL** (`CatalystbyZoho_Execute_Query`, entorno Development, 0.8):

   ```sql
   SELECT task_id, current_status, project_name, list_name, inactivity_days_business, last_activity_datetime, MODIFIEDTIME
   FROM clickup_task_activity
   WHERE project_name IN ('Gonher','Avaderm','Líder System Grupo','Aicrov','Tee Travel',
                          'Moradillo','Exeltis','Ecophon España','Kasblan')
     AND current_status IN ('doing','doing amigos','validación cliente','validación reinicia')
   ```

   > Filtra `project_name` y `current_status` por valor **exacto** (igualdad, segura con acentos).
   > **No** poner `inactivity_days_business >= 5` en ZCQL: la columna es texto y la comparación
   > sería lexicográfica (`"9" > "22"`). El umbral se aplica en código tras `parseInt`.

2. **Guarda de frescura — DOS comprobaciones.**
   - **(a) ¿Corrió el cron?** El `MODIFIEDTIME` de las filas debe ser de hoy (Madrid). Si **ninguna**
     fila se actualizó hoy → el cron de las 05:30 no corrió.
   - **(b) Heartbeat de eventos (CRÍTICO).** El `last_activity_datetime` **más reciente** de la tabla
     (o el evento más nuevo de `clickup_events`) no puede tener más de **2 días laborables** de
     antigüedad. Si lo tiene, el webhook ClickUp→Catalyst está caído aunque el cron siga sellando
     `MODIFIEDTIME` de hoy: la inactividad está **inflada artificialmente** y NO es fiable.
   - Si falla (a) **o** (b) → **ir al PASO 3-FALLBACK** (cálculo propio en vivo, fiable con el
     pipeline caído) y avisar de la anomalía en el reporte. **Nunca** mover a Parking con dato de
     Catalyst no fiable.

   > Por qué (b) es imprescindible: el cron de las 05:30 recalcula la inactividad **cada día aunque no
   > lleguen eventos nuevos**, así que sella `MODIFIEDTIME` de hoy sobre datos congelados. La
   > comprobación (a) sola se deja engañar; el heartbeat (b) es lo que detecta el pipeline muerto
   > (junio 2026: el webhook estuvo 5 semanas caído y la skill parkeó tarjetas vivas por no tenerlo).

3. **Clasificar en código** (parsear cada `inactivity_days_business` con `parseInt`):
   - **`dias >= 5`** → candidato a aviso/Parking (pasa al PASO 3 para poda + redacción).
   - **`dias < 5`** → solo interesa para **reactivaciones**: si la tarjeta tiene el tag
     `parado-avisado`, hay que retirarlo (PASO 4-A). No requiere leer el hilo.

> Resultado del PASO 2: lista corta de candidatos ≥5 (solo de esos se lee el hilo) + lista de
> `<5 con tag` para limpiar.

---

## PASO 3 — LECTURA Y PODA POR CANDIDATO (solo los ≥5)

El número base (`dias`) ya viene de Catalyst. Para **cada candidato ≥5** (no para los 50):

1. **Re-verificar el estado en vivo** con `clickup_get_task` (ClickUp = fuente de verdad del
   estatus; la columna puede tener hasta ~1 h de desfase). Si el estado actual **ya no** es uno de
   los cuatro vigilados, **omitir** la tarjeta (cambió desde la última normalización).
2. **Leer el hilo**: `clickup_get_task_comments` **y**, para cada comentario con `reply_count > 0`,
   `clickup_get_threaded_comments` (las respuestas anidadas contienen información crítica).
3. **Poda (lo que la función no ve):** aplicar el PASO 1 a los comentarios posteriores a la fecha
   base implícita (≈ hoy − `dias` laborables). Si hay un **comentario humano que demuestra avance**
   en ese tramo, la tarjeta **no está realmente parada** → recalcular el progreso desde ese
   comentario; si con ello cae por debajo de 5, tratarla como reactivada (PASO 4-A) y **no avisar**.
4. **Enriquecer el aviso:** extraer el **compromiso vencido** si lo hay (fecha prometida ya pasada,
   p. ej. "lo entrego el viernes") y el contexto del bloqueo (p. ej. "a la espera del cliente").

Resultado por tarjeta: `dias_inactividad` (de Catalyst, podado si procede), `ultima_actividad_real`,
`tipo_ultima_actividad`, `compromiso_vencido` (si lo hay), `estado_en_vivo`, `asignados`.

### PASO 3-FALLBACK — Cálculo propio (si Catalyst no está disponible)

Se activa si: la lectura ZCQL falla, la tabla viene vacía, o la guarda de frescura (PASO 2.2)
indica que el dato no es de hoy. En ese caso la skill **calcula ella misma** la inactividad, como
en la v0.1:

1. Resolver los `list_id` de las listas en alcance (0.1) y `clickup_filter_tasks` por los cuatro
   estatus vigilados (`include_closed: false`). Parsing: `json.loads(raw[0]['text'])`.
2. Para cada candidato, leer hilo (comments + threaded) + estado/time entries y determinar la
   última actividad de progreso real aplicando el PASO 1 íntegro.
3. Calcular días laborables con el calendario 0.4.
4. Continuar en el PASO 4 igual que en el camino primario. **Marcar en el reporte** que se usó el
   fallback (para que Dirección sepa que el pipeline de Catalyst necesita revisión).

---

## PASO 4 — ACCIÓN POR TARJETA

Aplicar sobre el **estado en vivo** (re-verificado en 3.1) y con `dias_inactividad` ya podado:

**A) Progreso real / por debajo del umbral (`dias_inactividad < 5`):**
- Si la tarjeta tiene el tag `parado-avisado`, **retirarlo** (se reactivó). Sin más acción.

**B) AVISO (`5 ≤ dias_inactividad < 7`):**
- Si **no** tiene `parado-avisado`:
  1. Publicar comentario (texto plano, 0.6) informado por el histórico: última actividad real,
     compromiso vencido si lo hay, y el siguiente paso que se pide. Enrutar la mención al PO según
     0.5.
  2. Añadir el tag `parado-avisado` con `clickup_add_tag_to_task`.
- Si **ya** tiene `parado-avisado`: no reavisar (la siguiente acción es el día 7).

**C) MOVER A PARKING (`dias_inactividad ≥ 7`):**

> **Tarjetas de Gestión (0.9): NUNCA se mueven a Parking.** Si una Gestión llega a ≥7, la acción es
> **re-aviso** con la plantilla de Gestión (recordatorio de seguimiento con el cliente), nunca Parking.

> **Red de seguridad anti-parkeo (obligatoria).** Antes de mover, comprobar si hay **algún comentario
> humano** (no ClickBot, no de esta skill por su firma 0.6) con fecha **posterior** al aviso
> `parado-avisado`. Si lo hay → **NO mover**: es señal de actividad reciente que la poda pudo no
> captar. Dejar re-aviso y marcar la tarjeta para revisión humana en el reporte. Un solo fallo de
> poda no debe poder parkear una tarjeta viva.

- Solo mover si: es un **producto** (no Gestión), ya se dio el AVISO (`parado-avisado`), **no** hay
  comentario humano posterior al aviso, y sigue sin progreso real:
  1. `clickup_update_task` → estado `parking e incidencias`.
  2. Comentario explicando el motivo del movimiento y a quién corresponde retomarlo.
  3. Al cambiar de estado, la tarjeta **sale de la lista blanca** y deja de generar avisos.

> **Comentarios en ClickUp = solo texto plano.** La API no acepta markdown, HTML ni hipervínculos
> con texto personalizado. Formato: línea descriptiva + URL en la línea siguiente. Patrón de
> enlace: `Privado - [Descripción] - [PRODUCTO] [CLIENTE]` y debajo la URL. **Sin acrónimos**:
> escribir "días laborables", nunca "d.l." (también en la línea `Privado - ...`). Terminar siempre
> con la firma 0.6. Los tags se añaden/retiran con `clickup_add_tag_to_task` (no vía `update_task`).

### Redacción del comentario de aviso (formato canónico)

Estructura: (1) detección con **días laborables** (escrito completo) + última actividad de progreso
+ estado actual; (2) contexto del hilo (bloqueo/coordinación, por qué no es progreso); (3) acción
pedida al responsable según 0.5; (4) si la pelota está en el tejado del cliente, **perseguir la
respuesta y dejar constancia de ello en el producto con un comentario**, y valorar Parking; (5)
línea `Privado - ...` + URL; (6) firma. El comentario se **asigna** al PO/responsable (la
notificación va por la asignación, no por una mención en el texto).

**Plantilla — estado `Doing` / `Doing Amigos`** (asignados + PO Técnico):

```
Producto detectado parado: [N] días laborables sin progreso real.
Última actividad de progreso: [DD/MM/AAAA] ([tipo]). Estado actual: [Estado].
[Contexto del hilo: qué ha pasado desde entonces y por qué no cuenta como progreso.]

[Responsable(s)]: [acción concreta]. Si la pelota está en el tejado del cliente, hay que
perseguir la respuesta y dejar constancia de ello en el producto con un comentario. También
valorar mover la tarjeta a Parking. Sin movimiento, en la próxima revisión pasará a Parking.

Privado - Producto parado [N] días laborables - [PRODUCTO] [CLIENTE]
[URL]

— Detección automática de estancamiento (Reinicia)
```

**Plantilla — estado `Validación Cliente`** (PO Cliente):

```
Producto detectado parado: [N] días laborables en Validación Cliente sin respuesta.
Última actividad de progreso: [DD/MM/AAAA].

[PO Cliente]: esta tarjeta lleva [N] días laborables esperando validación del cliente. Conviene
perseguir la respuesta de [Cliente] y decidir si se cierra o si en su caso se mueve a Parking.

Privado - Producto parado [N] días laborables - [PRODUCTO] [CLIENTE]
[URL]

— Detección automática de estancamiento (Reinicia)
```

**Plantilla — estado `Validación Reinicia`** (PO Técnico / Reinicia): igual que la de Validación
Cliente, pero la validación pendiente es interna de Reinicia; la acción pedida es completar o
reasignar la validación.

**Plantilla — tarjeta de Gestión** (0.9; recordatorio al PO, **nunca** Parking):

```
Recordatorio de seguimiento: esta tarjeta de Gestión lleva [N] días laborables sin un registro real
de seguimiento con el cliente.

[PO]: conviene hablar con el cliente sobre el estatus del proyecto y del propio cliente, y dejar aquí
un comentario con el RESUMEN de esa conversación (o el enlace al acta). Una nota del tipo "hablé con
el cliente" o "reunión con el cliente", sin resumen ni acta, no vale como seguimiento.

Privado - Gestión sin seguimiento registrado [N] días laborables - [PRODUCTO] [CLIENTE]
[URL]

— Detección automática de estancamiento (Reinicia)
```

Si hay **compromiso vencido** en el hilo, añadir una línea: `Compromiso vencido: se prometió para
el [fecha] y no consta entrega/avance.`

---

## PASO 5 — REPORTE A ZOHO CLIQ

Postear un único mensaje al **#Canal de POs** (`canaldepos`, `T45816000000085071`) con:

```
🕳️ Detección de productos estancados — Equipo Columbia — [DD/MM/AAAA] Madrid
Fuente: Catalyst (inactivity_days_business) | [o] Fallback cálculo propio ⚠️

Umbral: 5 días laborables (aviso) · 7 (mover a Parking)
Tarjetas vigiladas: [N]  ·  Paradas detectadas: [N]

═══ AVISOS (5–6 días) ═══
  • [Cliente] [Producto] — [N] días laborables parada — @[PO] — [estado]
    [URL]

═══ MOVIDAS A PARKING (≥7 días · solo productos) ═══
  • [Cliente] [Producto] — [N] días laborables — @[PO]
    Último comentario humano: [fecha] "[extracto]" — por qué no contó: [motivo]
    [URL]

═══ RECORDATORIOS GESTIÓN (avisadas · nunca Parking) ═══
  • [Cliente] [Gestión …] — [N] días laborables sin seguimiento registrado — @[PO]
    [URL]

═══ NO MOVIDAS POR RED DE SEGURIDAD (comentario humano tras el aviso) ═══
  • [Cliente] [Producto] — revisar a mano — @[PO]
    [URL]

═══ REACTIVADAS (progreso detectado) ═══
  • [Cliente] [Producto] — retomada por [quién/qué]

[Si hubo anomalías de lectura o se usó fallback: listarlas]
```

Si un canal/post falla, no abortar el pase: registrar la anomalía y continuar.

---

## PASO 6 — ROBUSTEZ (modo desatendido / Routine)

- **Catalyst caído o dato obsoleto** → no abortar: ir al PASO 3-FALLBACK (cálculo propio) y marcar
  en el reporte que se usó el respaldo.
- **Abortar** todo el pase solo ante fallo estructural total: ClickUp MCP no responde (sin
  fallback posible), o Cliq no accesible y no hay forma de reportar. Postear el error si se puede.
- **Errores por tarjeta** (lectura de hilo falla, anomalía de API): registrar y continuar con la
  siguiente; reportar en la sección de anomalías del PASO 5.
- **No mover a Parking** una tarjeta sobre la que no se haya podido leer el histórico con
  fiabilidad (sin certeza de no-progreso, no se mueve: solo se reavisa o se deja como anomalía).
- **Casos `SIN_EVENTO_PROGRESO`** (la función no halló evento de progreso y usó baseline
  conservador): tratarlos como candidatos normales — leer el hilo en el PASO 3 decide.

---

## FASE 2 (futuro) — Resumen ejecutivo y ampliación

- Una vez estable, alimentar una sección de "productos estancados" en el Informe Ejecutivo Semanal
  de los POs y un resumen para el Director de Operaciones (encaja con
  `informes-ejecutivos-sprint-backlog-equipos-reinicia`).
- Ampliar el alcance del **dato** a todos los equipos (`RESTRICT_TO_COLUMBIA = false` en la función
  + revisar Max Execution Time / optimizar lecturas en lote); la **acción** (aviso/Parking) se
  amplía a otros equipos de forma independiente cuando Dirección lo decida.

---

## NOTAS IMPORTANTES (resumen operativo)

- **v0.2: la inactividad la trae Catalyst** (`inactivity_days_business`, texto → `parseInt`); la
  skill solo lee el hilo de los candidatos ≥5 para podar y redactar. Fallback a cálculo propio si
  Catalyst falla o el dato no es de hoy.
- Filtro `>=5` siempre en código, **nunca** en ZCQL (columna de texto, comparación lexicográfica).
- Nombres Catalyst con sufijo: **"Líder System Grupo"** y **"Ecophon España"**.
- Re-verificar el estado en vivo (`clickup_get_task`) antes de avisar o mover a Parking.
- Lista blanca de 4 estados; todo lo demás se ignora. Match normalizado sin acentos en código.
- ClickBot nunca cuenta. Comentarios de intención/espera tampoco. El comentario que **demuestra
  avance** sí cuenta y es justo lo que la skill poda (la función no lo mira).
- Comentarios ClickUp en **texto plano y sin acrónimos** (escribir "días laborables", no "d.l.");
  tags vía `clickup_add_tag_to_task`. El comentario se asigna al PO/responsable.
- Hilos: `clickup_get_task_comments` + `clickup_get_threaded_comments` siempre.
- Parsing crudo ClickUp (fallback): `json.loads(raw[0]['text'])`.
- Idempotencia por tag `parado-avisado` + firma de comentario.
- Mover a Parking solo desde el día 7, solo productos (no Gestión), con aviso previo y sin comentario
  humano posterior al aviso; al moverse, sale de la vigilancia.
- **Heartbeat de eventos (2.2):** si el evento más nuevo tiene >2 días laborables, el webhook está
  caído aunque el cron selle hoy → fallback; nunca fiarse de Catalyst para Parking.
- **Gestión (0.9):** se avisa (recordatorio de seguimiento con el cliente, con resumen o acta) pero
  **nunca** se mueve a Parking. Discriminar por `list_name` que empieza por "Gestión ".
- **Red de seguridad:** no mover a Parking si hay comentario humano posterior al aviso → re-aviso + revisión humana.
- Auto-move ACTIVO desde el primer día del piloto (decisión de Dirección: sin acción real no hay
  feedback real).
- Reporte al **#Canal de POs** (`canaldepos`). Indicar si se usó fallback.
- La Routine de esta skill debe correr **después** del cron de Catalyst (05:30 Madrid) — p. ej.
  06:00+ — para leer la columna fresca.

---

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v0.3** | 2026-07-12 | Néstor + Claude | **Gestión** (identificada por `list_name` que empieza por "Gestión "): se avisa como recordatorio de seguimiento con el cliente (plantilla propia; un "hablé con el cliente" pelado no cuenta como progreso, hace falta resumen o enlace al acta) pero **nunca** se mueve a Parking (0.9, PASO 1, PASO 4-C). **Heartbeat de eventos** en la guarda de frescura (2.2): además de comprobar que el cron corrió, verifica que el evento más nuevo no supere 2 días laborables; si no, el webhook está caído aunque el cron selle hoy → fallback (raíz del incidente de junio 2026, webhook 5 semanas suspendido). **Red de seguridad anti-parkeo** (PASO 4-C): no mover a Parking si hay comentario humano posterior al aviso. `list_name`/`last_activity_datetime` añadidos al SELECT del PASO 2. Trazabilidad en el reporte (último comentario humano por cada Parking). |
| **v0.2** | 2026-06-06 | Néstor + Claude | Consume `inactivity_days_business` de Catalyst como fuente primaria (PASO 2 = lectura ZCQL en vez de recorrer listas). PASO 3 pasa a "lectura + poda": solo lee el hilo de los candidatos ≥5, poda con la regla de comentario-que-demuestra-avance (lo único que la función no mira) y re-verifica el estado en vivo antes de actuar. Filtro ≥5 en código (columna de texto). Guarda de frescura por `MODIFIEDTIME` y **fallback** al cálculo propio v0.1 si Catalyst falla o el dato no es de hoy. Nombres canónicos Catalyst ("Líder System Grupo", "Ecophon España"). Config Catalyst en 0.8. Formato canónico del comentario de aviso por estado (texto plano sin acrónimos, plantillas en PASO 4, comentario asignado al responsable). |
| **v0.1** | 2026-06-01 | Néstor + Claude | Versión inicial autónoma. Piloto Equipo Columbia, una pasada diaria. Detección por lista blanca de 4 estados; inactividad en días laborables (calendario Madrid capital 2026); regla de actividad real (excluye ClickBot, fórmulas y comentarios de intención); lectura de hilos para compromisos vencidos; aviso con enrutado por estado; auto-move a Parking en día 7; idempotencia por tag `parado-avisado`; reporte a #Canal de POs. Cálculo propio vía ClickUp MCP (consumo de columna Catalyst diferido a v0.2). |
