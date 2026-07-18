---
name: sprint-planning-reinicia-modo-desatendido
description: >
  Versión desatendida (cloud) de sprint-planning-reinicia para ejecución en Claude Code Routines los viernes de madrugada. NO procesa transcripciones de Sprint Planning ni escribe estatus en las tarjetas de ClickUp: es de SOLO LECTURA sobre ClickUp salvo el comentario y el adjunto finales. Sincroniza el documento "Objetivos Sprint Planning" en Zoho Sheet (vuelca el estatus de la semana vigente por task-ID enlazado y da de alta los productos/microcampañas nuevos del sprint), genera el PDF "Resumen de estatus" con marca Reinicia, lo guarda en Workdrive, comenta el resumen con enlace en el producto "Reunión de POs 2026 [METODOLOGÍA REINICIA]" (asignado a Pablo y Óscar) y avisa en el Canal de POs de Cliq.
  Actívala SOLO cuando se ejecute la Routine programada o cuando un humano pida explícitamente "ejecuta el resumen de estatus desatendido". Para el planning supervisado interactivo, usa la skill hermana sprint-planning-reinicia.
---

# SKILL: Sprint Planning — MODO DESATENDIDO (Resumen de estatus) — Reinicia

> **Versión vigente: v0.4 — 07/07/2026** · ver changelog al final (`## Versiones`)

> ⚠️ **Modo desatendido.** Esta skill se ejecuta sin humano delante. Donde la skill
> supervisada pediría confirmación al PO, aquí se aplica una **regla determinista** (sección 5).
> Nunca pide input. Cualquier bloqueo se reporta en el aviso final de Cliq y se continúa con el
> resto en la medida de lo posible.

---

## ⚙️ CONFIGURACIÓN DEL AUTOMATISMO EN CLAUDE CODE (ROUTINE)

> ⚠️ **Sección de setup — no forma parte del runtime.** Documenta cómo queda configurada la
> Routine de Claude Code que dispara esta skill. El runtime empieza en la sección 0.

### Repositorio y ubicación de la skill
- Repo: `agencia-reinicia/claude-skills` (rama `main`).
- Ruta de esta skill: `sprint-planning-reinicia-modo-desatendido/SKILL.md`.
- La supervisada hermana (`sprint-planning-reinicia/SKILL.md`) vive en el mismo repo. Toda mejora
  de criterio (normalización de estatus, reglas de barrido, estructura del Sheet) se hace primero
  en la supervisada y se sincroniza después aquí.
- Claude Code lee las skills desde los symlinks de `~/.claude/skills/`. Tras commit en el repo,
  asegurar que el symlink de esta skill apunta a la versión actualizada.

### Programación (cron)
- Expresión recomendada: `7 6 * * 5` (**viernes a las 06:07**). Detalle y aviso DST en la sección 7.
- El minuto `:07` es a propósito (evitar el minuto de máxima cola de la plataforma).
- Zona horaria: si la plataforma de Routines permite fijar **Europe/Madrid**, usarla y olvidarse
  del DST (entonces el cron objetivo de ~04:00 Madrid sería `7 4 * * 5`). Ver sección 7.
- Pilotaje: **Run manual** ("ejecuta el resumen de estatus desatendido") antes de activar el cron.
- Registrar aquí el `routine_id` tras crear la Routine: `routine_id = <pendiente>`.

### Prompt de la Routine (sugerido)
```
Ejecuta el resumen de estatus desatendido (skill sprint-planning-reinicia-modo-desatendido).
Sprint vigente, semana vigente. Sincroniza el Sheet "Objetivos Sprint Planning", genera el PDF
"Resumen de estatus" con marca Reinicia, súbelo a Workdrive (Sprint NN-AA › Informes Ejecutivos),
comenta el resumen + enlace en TASK_REUNION_POS asignado a Pablo y Óscar, y avisa en el Canal de
POs de Cliq. Reporta cualquier bloqueo en el aviso de Cliq sin abortar el resto.
```

### Herramientas requeridas en el entorno de la Routine
- **Zoho Workdrive Sheet** (lectura/escritura de "Objetivos Sprint Planning"): `ZohoSheet_*`.
- **ClickUp** (solo lectura + comentario/adjunto finales): `clickup_filter_tasks`,
  `clickup_get_task`, `clickup_create_task_comment`, `clickup_attach_task_file`.
- **Workdrive** (subir el PDF y validarlo): `ZohoSheet_create_workbook` no aplica aquí; subida de
  binario PDF + `ZohoWorkdrive_getFileOrFolderDetails`.
- **Cliq** (aviso al Canal de POs): `ZohoCliq_send_message_to_chat` (`chat_id = CT_1214384547891975984_20068152370`).
- Si falta alguna herramienta en el entorno del Routine, el paso correspondiente se reporta como
  bloqueo en Cliq y se continúa con el resto (sección 6).

---

## 0. PROPÓSITO Y ALCANCE

Mantener actualizado, de forma automática y semanal, el estado del sprint para Dirección y POs:

**SÍ hace:**
1. Detecta el **sprint vigente** y su pestaña en el documento "Objetivos Sprint Planning".
2. Calcula la **semana de sprint** vigente (S0/S1/S2/...) a partir de las fechas.
3. **Vuelca el estatus** de cada producto en la columna de la semana, leyendo el **task-ID enlazado**
   en la celda Entregable (determinista, no por nombre).
4. **Da de alta** en el Sheet los productos/microcampañas nuevos del sprint detectados por
   **barrido lista-a-lista** por tag.
5. Genera el **PDF "Resumen de estatus"** con marca Reinicia (resumen global, distribución kanban,
   puntos clave, avance por proyecto y **distribución por persona**).
6. **Guarda** el PDF en Workdrive (`Sprint NN-AA › Informes Ejecutivos`).
7. **Comenta** el resumen + enlace en el producto *Reunión de POs 2026 [METODOLOGÍA REINICIA]*,
   asignado a Pablo Losada y Óscar Díez.
8. **Avisa** en el Canal de POs de Cliq con el resumen y los enlaces.

**NO hace:**
- No procesa transcripciones de Sprint Planning (.vtt) — eso es de la supervisada.
- No crea productos ni escribe estatus/etiquetas en las tarjetas de ClickUp.
- No toca los Sprint Backlogs individuales (AUTOIA) ni el Informe Ejecutivo por equipo (skills aparte).
- No procesa las listas de **Gestión** (quedan fuera de alcance, salvo lo que ya estuviera enlazado
  en el Sheet).

---

## 1. ACTIVACIÓN

- **Disparador principal:** Routine programada (sección 7).
- **Disparador manual:** un humano dice explícitamente "ejecuta el resumen de estatus desatendido".
- En cualquier otro caso (planning interactivo, subir transcripción), **derivar a `sprint-planning-reinicia`**.

---

## 2. CONSTANTES Y RECURSOS

### Documento "Objetivos Sprint Planning" (Zoho Sheet)
- `resource_id`: `ggxmpfd47bf128f954108b2474f7d69af40c8`
- Carpeta Workdrive Sprint Planning: `db7hy01bbf926e9ac4261826a06f22aca92c6`
- Pestaña por sprint: `Objetivos Sprint NN-AA` (la vigente). Resolver `worksheet_id`/`worksheet_name`
  listando siempre las pestañas primero — **no hardcodear** (la vigente del 07-26 fue `30#`, pero
  cambia cada sprint).

### Estructura de la pestaña (cabecera en fila 6, datos desde fila 7)
| Col | Campo |
|-----|-------|
| 1 | Orden |
| 2 | Cliente `[CLIENTE]` |
| 3 | Proyecto |
| 4 | **Entregable** (HYPERLINK al task de ClickUp → fuente del task-ID) |
| 5 | Tipo |
| 6 | **Estatus S0** (baseline) |
| 7 | **Estatus S1** · 8 Objetivos S1 · 9 Notas S1 |
| 10 | **Estatus S2** · 11 Objetivos S2 · 12 Notas S2 |
| 13 | **Estatus S3** · 14 Objetivos S3 · 15 Notas S3 |
| 16 | Origen |

### Columnas de estatus — auto-detectadas
No hardcodear. Las columnas de estatus se resuelven leyendo la **cabecera (fila 6)**: cada celda
cuyo encabezado sea "Estatus" (o "Estatus S0/S1/…") define, en orden de aparición, S0, S1, S2, …
La 1.ª es S0 (baseline). El layout estándar de 3 semanas da `{S0:6, S1:7, S2:10, S3:13}`, pero el
valor real se toma siempre de la cabecera (soporta sprints de 4-5 semanas de verano/Navidad).

### ClickUp
- Workspace: `762713`
- Listas internas en alcance: General Reinicia `3350802`, Reinnova `48885324`
- Producto destino del comentario: *Reunión de POs 2026 [METODOLOGÍA REINICIA]* →
  `TASK_REUNION_POS = 869bt8w6w` (https://app.clickup.com/t/869bt8w6w). Asignados: Pablo Losada
  `87715920`, Óscar Díez `93631901`.

### Workdrive (destino del PDF)
- Carpeta del sprint vigente → subcarpeta **`Informes Ejecutivos`**. Sprint 07-26:
  `kl62t6524c6834c8c4a769c7fa2b5eaa44eac`. Resolver la del sprint detectado por nombre.

### Cliq
- **Canal de POs** (aviso): `chat_id = CT_1214384547891975984_20068152370` (este, NO Metodología). IDs antiguos obsoletos: POs `T45816000000085071`, Metodología `T45816000000085077`.

### Marca Reinicia (PDF)
- Logo real: Workdrive resource `okcqm65a2ea3684c2473583559fb91f0c3a59` → extraer
  `word/media/image3.png` (741×138 px).
- Fuente Manrope **embebida vía estáticos del ZIP de Workdrive** (resource_id
  `a2xhx44f0cbde39da4b6ba1186a213b92ebfd`): descargar con `ZohoWorkdrive_downloadWorkDriveFile`,
  decodificar base64, descomprimir en `/home/claude/manrope/` y registrar en reportlab los estáticos
  por peso — `static/Manrope-Regular.ttf`, `static/Manrope-Bold.ttf`, `static/Manrope-Light.ttf`.
  **NO instanciar la variable con fontTools** (paso innecesario y frágil en desatendido): los estáticos
  ya vienen por peso y reportlab los embebe (subset) en el PDF. Registro:

  ```python
  from reportlab.pdfbase import pdfmetrics
  from reportlab.pdfbase.ttfonts import TTFont
  pdfmetrics.registerFont(TTFont("Manrope",       "/home/claude/manrope/static/Manrope-Regular.ttf"))
  pdfmetrics.registerFont(TTFont("Manrope-Bold",  "/home/claude/manrope/static/Manrope-Bold.ttf"))
  pdfmetrics.registerFont(TTFont("Manrope-Light", "/home/claude/manrope/static/Manrope-Light.ttf"))
  pdfmetrics.registerFontFamily("Manrope", normal="Manrope", bold="Manrope-Bold")  # si se usan <b> en Paragraph
  ```

  Mismo ZIP de origen que actas/marca, pero el motor aquí es **reportlab**, no docx-js: no mezclar con
  la receta de embebido de `marca-reinicia` (esa es para `.docx` con `patch_fonts.py`).
- Colores: azul `#3812CF`, lila `#D9D0FB`, gris fila `#EBEBEB`, gris texto `#545454`, coral
  `#D14351`, verde delta `#1f8a5b`. Bordes blancos gruesos, alternancia blanco/gris, sin zebra adicional.

---

## 3. REGLA DE SEMANA (determinista, desde fechas + cabecera)

- Semanas de **jueves a miércoles**. S0 = primera semana (baseline); S1, S2, … las siguientes. El
  sprint suele tener **3 semanas**, pero en verano y Navidad se amplía a **4 o 5**.
- `inicio_sprint` = jueves de arranque. `semana_idx = floor((hoy - inicio_sprint).days / 7)`.
- **Columnas de estatus auto-detectadas** desde la cabecera (sección 2) → lista ordenada
  `COLS_ESTATUS = [colS0, colS1, …]`. La columna a escribir = `COLS_ESTATUS[semana_idx]`.
- **Guardas (sin fallo silencioso):**
  - Si `semana_idx >= len(COLS_ESTATUS)` (el sprint tiene más semanas que columnas de estatus en
    la pestaña): **no escribir**, reportar en Cliq "faltan columnas Sx en la pestaña" y continuar
    con el resto (PDF, etc.) usando la última columna disponible como vigente.
  - Si `semana_idx` es 0: solo baseline, sin comparativa.
- La ejecución es **viernes** → `hoy` cae el día 2 de la semana de sprint; el run reporta el
  arranque de la semana vigente, ya consolidado tras el planning del jueves.
- Comparativa del PDF: `S{idx-1}` vs `S{idx}`.
- El sprint cierra en **miércoles**; el run del viernes no captura el cierre fino (eso es del
  Informe Ejecutivo).

---

## 4. FLUJO DE EJECUCIÓN

### PASO 1 — Sprint y pestaña vigentes
- Resolver el sprint activo (fechas) y localizar la pestaña `Objetivos Sprint NN-AA`. Listar
  pestañas y fijar `worksheet_id`/`worksheet_name`.
- Auto-detectar `COLS_ESTATUS` desde la cabecera (fila 6). Calcular `semana_idx` y la columna de
  estatus destino.
- Normalizar el tag de barrido a **4 dígitos de año**: `sprint - NN - AAAA` (p. ej.
  `sprint - 07 - 2026`), respetando los espacios alrededor de los guiones (formato real de ClickUp).

### PASO 2 — Estatus por task-ID enlazado (determinista)
- Leer el rango de datos (fila 7 → última fila con contenido).
- Para cada fila, leer la **celda Entregable (col 4)** con `cell.content.get`; del campo `url`
  extraer el **task-ID** de ClickUp (`/t/<id>`).
- Tomar el estatus de ese task del barrido del PASO 3 (que ya trae estatus por id; evita N× get_task).
- Escribir el estatus en la columna de la semana (PASO 4). Filas **sin enlace** → estatus vacío +
  nota (web aún sin vincular, links fuera de sprint tipo NIUVO).

### PASO 3 — Altas por barrido lista-a-lista
- `clickup_filter_tasks` con `tags=[tag_normalizado]`, `workspace_id=762713`,
  `include_closed=true`, paginando (`page` 0,1,…) hasta agotar. Capturar por tarea: `id`, `status`,
  `list`, `name`, `assignees`.
- **Alcance de altas:** listas `General [CLIENTE]` + `Soporte [CLIENTE]` + internas
  (`General Reinicia`, `Reinnova`). **Excluir** listas `Gestión [CLIENTE]`.
- **Alta** = task en alcance cuyo **id no aparece** entre los task-IDs ya enlazados en el Sheet (PASO 2).
- Métodos **complementarios**: estatus por id enlazado (PASO 2) + altas por barrido (PASO 3).

### PASO 4 — Escritura en el Sheet
- **Estatus de la semana:** `cells.content.set` en lotes <=40 (singular `cell.content.set` como
  fallback ante error 2878). La hoja fuerza MAYÚSCULAS en la columna de estatus.
- **Altas:** añadir filas nuevas al final con:
  - col 2 = `[CLIENTE]`
  - col 4 = `=HYPERLINK("<url>";"<nombre>")` (separador `;` locale es-ES; sanear comillas internas
    del nombre a `'`)
  - col de la semana = estatus
  - col 16 = `Añadido en sprint`
- Nunca usar `worksheet.csvdata.set` con decimales/`+`. Nunca `""` (usar `" "`). `recalculate` tras
  escribir HYPERLINK.

### PASO 5 — Métricas
Construir desde el cruce filas-ClickUp:
- **Equipo** por cliente: Columbia {Gonher, Avaderm, Líder System, Aicrov, Tee Travel, Moradillo,
  Exeltis, Ecophon, Kasblan}; Proactive {INEFSO, Mazarea, Carritech, Ti-Medi, Synuptic, Breezom,
  BirdEase, Ingelyt, Lacroix, Aunna, HomeEspaña, ISL Agency, Niuvo}; resto Reinicia.
- **Normalización de estatus** a etiquetas canónicas y **orden kanban**:
  `['Sprint backlog','Doing','Doing amigos','Val. Reinicia','Val. cliente','Done/Closed','Parking','Product backlog','Open','(sin estatus)']`
- **Conjuntos:** `ACTIVOS = {Doing, Doing amigos, Val. Reinicia, Val. cliente, Done/Closed}`;
  `VALDONE = {Val. Reinicia, Val. cliente, Done/Closed}`.
- **Tendencia:** `ORD = {Done/Closed:5, Val.*:4, Doing/Doing amigos:3, Sprint backlog:1, Product backlog/Parking/Open:0}`;
  `Δ = Σ ORD(s_cur) − Σ ORD(s_prev)` **excluyendo filas sin estatus** en cualquiera de las dos
  semanas. Signo → `+ Avanza / = Estable / − Retrocede`.
- **KPIs:** productos en arranque (S0) vs ahora (total con altas, "+N altas"); En valid./done;
  Activos; En parking.
- **Por proyecto:** nº productos, estatus mayoritario S_prev/S_cur, tendencia, % activos.
- **Por persona (por equipo):** **cada producto cuenta para CADA asignado**; responsables directos
  de los `assignees` de ClickUp. Por persona: nº productos, % activos, en valid./done, tendencia.
  `(sin responsable)` → **Sin asignar**. Nota obligatoria: los totales por persona suman más que el
  nº de productos por co-asignación.
- **Anomalías:** productos con el tag del sprint en **Product Backlog / Open** (solo válido para
  soporte). Listar cliente + producto.

### PASO 6 — PDF "Resumen de estatus"
- reportlab + Manrope + logo real. Nombre: `Sprint-NN-AA-Resumen-Estatus-S{prev}-vs-S{cur}.pdf`
  (solo guiones).
- Orden: cabecera de marca → **Resumen global** (KPIs con leyenda; arranque vs ahora explícito) →
  **Distribución de estatus** (orden kanban; S_prev/S_cur/Dif con deltas coloreados) → **Puntos
  clave** → **Avance por equipo** (por cada equipo: *Distribución por persona* primero, *Avance por
  proyecto* después) → notas al pie.
- Barras de % dentro de su celda (ancho de barra = ancho de su columna). Glifos ASCII para
  `+ = −` (los triángulos fallan en Manrope).

### PASO 7 — Guardado en Workdrive
- Subir el PDF a `Sprint NN-AA › Informes Ejecutivos`. Validar tras subir (status, nombre exacto,
  sin `%3A`).
- Obtener la URL del archivo para los enlaces de los pasos 8 y 9.

### PASO 8 — Comentario en ClickUp (Reunión de POs)
- Publicar **un comentario** en `TASK_REUNION_POS` (texto plano, sin markdown/HTML/hipervínculos;
  enlace en línea aparte) **asignado a Pablo Losada y Óscar Díez**, con el resumen ejecutivo
  (cifras clave + carga por persona top + anomalías + enlace Workdrive). Plantilla en sección 8.
- Adjuntar además el PDF a la tarjeta (`clickup_attach_task_file`) como respaldo.

### PASO 9 — Aviso en Cliq (Canal de POs)
- Mensaje al canal (`chat_id = CT_1214384547891975984_20068152370`) con: sprint, semana, KPIs, top de carga por persona, nº de
  altas, anomalías y los dos enlaces (Workdrive + tarjeta de POs).

---

## 5. REGLAS DETERMINISTAS (overrides del modo desatendido)

| Situación | Supervisada | Desatendida (determinista) |
|---|---|---|
| Estatus de un producto | confirma con el PO | toma el estatus actual del task enlazado, sin preguntar |
| Producto sin enlace en col 4 | pregunta | deja estatus vacío + nota; lo reporta en Cliq |
| Concepto del plan != nombre exacto de la tarea | el PO decide | usa **task-ID** (no nombre); si no hay id, no fuerza match → reporta |
| Alta detectada | el PO valida | la inserta automáticamente (col 16 = "Añadido en sprint") |
| Producto en Product Backlog/Open con tag del sprint | el PO revisa | lo escribe igual + lo marca como **anomalía** en el informe/aviso |
| Tag "sucio" (variantes mal escritas) | el PO limpia | usa solo el tag normalizado de 4 dígitos; reporta variantes vistas |

---

## 6. RESILIENCIA E IDEMPOTENCIA

- **Idempotente:** reejecutar el mismo viernes reescribe la misma columna de la semana y no duplica
  altas (compara por task-ID). El PDF se regenera y se sobrescribe; el comentario se publica una
  vez por ejecución (si se repite, indicar "(re-ejecución)").
- **502 / timeouts ClickUp:** reintentar con backoff; preferir barridos en lote a llamadas unitarias.
- **Zoho Sheet:** `cells.content.set` plural; `cell.content.set` singular como fallback;
  `recalculate` tras escrituras de fórmulas.
- **Workdrive:** validar el archivo subido antes de enlazarlo.
- Si un paso falla, continuar con los demás y **detallar el fallo en el aviso de Cliq** (no abortar todo).

---

## 7. ROUTINE / CRON

- **Frecuencia:** semanal, **viernes**. Valor a introducir en la Routine: **06:07** → cron `7 6 * * 5`.
- **Zona:** la plataforma de Routines va ~2 h por delante de Madrid en horario de verano (CEST),
  por lo que 06:07 ~= **04:07 Madrid** ahora mismo. Minuto :07 a propósito (evitar el minuto de
  máxima cola).
- ⚠️ **Aviso DST:** ese desfase de 2 h corresponde al horario de verano. Al pasar a horario de
  invierno (CET, último domingo de octubre) el desfase será de 1 h y 06:07 caería ~05:07 Madrid.
  Para mantener ~04:00 en invierno, bajar el cron a `7 5 * * 5`. **Si la plataforma permite fijar
  timezone Europe/Madrid, usarlo y olvidarse del DST** (entonces sería `7 4 * * 5`).
- Registrar `routine_id` en la sección ⚙️ tras crearla. Pilotaje: Run manual antes de activar el cron.
- (Opcional futuro) segundo cron de cierre el jueves posterior al miércoles de cierre, si Dirección
  lo pide.

---

## 8. PLANTILLA DEL COMENTARIO / AVISO

```
Resumen de estatus Sprint NN-AA (Semana {prev} vs Semana {cur}) — para revisión con POs.

Cifras clave:
- Productos: {N0} en arranque (S0) -> {N} ahora; +{altas} altas en el sprint.
- En validacion/done: {vd} ({vd%}). Activos: {act} ({act%}). En parking: {park} ({park%}).
- Mayor movimiento: {bucket_max} {dif_max}.

Carga por persona (cada producto cuenta para cada asignado):
- Columbia: {top Columbia}
- Proactive: {top Proactive}

Anomalia a revisar (tag {tag} en Product Backlog/Open; solo tendria sentido en soporte):
{lista cliente - producto}

Informe de estatus Sprint NN-AA (PDF) en Workdrive:
{url_workdrive}
```

---

## 9. LIMITACIONES Y PENDIENTES

- **Filas sin enlace**: web pendiente de crear/vincular (p. ej. Arquitectura WEB, Optimización WEB)
  y links a tasks fuera del sprint (caso NIUVO) → quedan sin estatus + nota.
- **Match tolerante** concepto-plan ↔ nombre-tarea: hoy se confía en el task-ID; cuando no hay id,
  no se fuerza. Pendiente heurística tolerante para sugerir vínculo.
- **Tags sucios**: variantes (`sprint - 04 -26`, `sprint -06 -2026`, `sprint - 5 - 26`, typo
  `2027`, etc.) — se ignoran al usar el tag normalizado; reportar las vistas para limpieza manual.
- **Subida de binario / comentarios**: requieren las herramientas correspondientes activas en el
  entorno del Routine (Workdrive upload + comentarios ClickUp).

---

## 10. VERSIONES

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v0.1** | 2026-06-07 | Néstor + Claude | Esqueleto inicial. Método task-ID + altas por barrido, regla de semana jue→mié, orden kanban, tendencia sin sin-estatus, vista por persona, guardado en Workdrive + comentario + aviso Cliq. |
| **v0.2** | 2026-06-07 | Néstor + Claude | TASK_REUNION_POS fijado (869bt8w6w). Cron viernes 06:07 (~04:07 Madrid en verano) con aviso DST. Columnas de estatus auto-detectadas desde la cabecera → soporta sprints de 3/4/5 semanas sin tocar la skill, con guarda anti-fallo-silencioso. |
| **v0.3** | 2026-06-07 | Néstor + Claude | Añadida la cabecera ⚙️ "Configuración del Automatismo en Claude Code (Routine)" (repo, ruta, prompt sugerido, herramientas requeridas, pilotaje, routine_id), al estilo de la skill de revisión desatendida. Runtime (secciones 0–9) sin cambios respecto a v0.2. |
| **v0.4** | 2026-07-07 | Néstor + Claude | **Fuente Manrope del PDF vía estáticos del ZIP de Workdrive** (resource_id `a2xhx44f0cbde39da4b6ba1186a213b92ebfd`) en lugar de instanciar la variable de Google Fonts con fontTools: se registran en reportlab los estáticos por peso (`Manrope-Regular/Bold/Light.ttf`), que reportlab embebe (subset) en el PDF. Elimina la dependencia de Google Fonts en runtime y el paso de instanciado (frágil en desatendido). Mismo ZIP de origen que actas/marca; motor reportlab (no docx-js), sin `patch_fonts.py`. La nota de glifos ASCII para `+ = −` no cambia. |

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v0.3 | 21/06/2026 | Néstor + Claude | Versión vigente registrada al incorporar el estándar de versionado de Reinicia. El histórico previo de cambios está descrito en prosa en el cuerpo de la skill y queda pendiente de tabular. |
