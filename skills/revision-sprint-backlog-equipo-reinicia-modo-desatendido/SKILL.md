---
name: revision-sprint-backlog-equipo-reinicia-modo-desatendido
description: >
  Versión desatendida (cloud) de revision-sprint-backlog-equipo-reinicia para ejecución en Claude Code Routines a las 06:00 los días laborables (lun–vie, Europe/Madrid). Procesa los Sprint Backlogs del sprint vigente sin intervención humana aplicando reglas deterministas donde la supervisada pediría confirmación al PO. Al terminar, postea un reporte en Zoho Cliq (canal Metodología, ID T45816000000085077).

  Actívala SOLO cuando se ejecute la Routine programada o cuando un humano pida explícitamente "ejecuta la revisión desatendida". Para procesamiento supervisado interactivo, usa la skill hermana revision-sprint-backlog-equipo-reinicia.

  v1.7 (07/06/2026): antes de marcar un rename, normaliza la fórmula K canónica y el carácter invisible y detecta renames de forma simétrica (prefijo o sufijo, no solo sufijo). El reporte a Cliq usa el nombre EXACTO del fichero (sin apellidos inventados) y describe los flags solo verbatim. Sincronizada con la supervisada v3.10.
---

# SKILL: Revisión de Sprint Backlog — MODO DESATENDIDO (cloud Routine)

## Propósito

Mantener al día los **Sprint Backlogs individuales** de cada miembro del Equipo Operativo durante el sprint, sincronizándolos con las horas reales trabajadas en ClickUp **sin intervención humana**. Esto permite que cada mañana laborable a las 06:00 el Equipo encuentre su AUTOIA actualizado con el trabajo del día anterior listo para consultar.

- **Visibilidad temprana de desvíos** entre lo planificado y lo ejecutado.
- **Captura sistemática del trabajo no planificado** (productos fuera de plan, soporte, microcampañas, ceremonias).
- **Insumo para los Informes Ejecutivos** semanales y de cierre de sprint por Equipo.
- **Detección de problemas operativos**: productos de Soporte sin estimación, sobrecarga estructural, dependencias entre miembros del equipo, motivos de desvío reincidentes.

La skill **NO planifica** (eso lo hace `sprint-planning-reinicia` al inicio del sprint) ni **crea productos en ClickUp**. Solo lee de ClickUp y escribe en el Sprint Backlog del Zoho Sheet.

---

## ⚙️ CONFIGURACIÓN DEL AUTOMATISMO EN CLAUDE CODE (ROUTINE)

> ⚠️ **Sección de setup — no forma parte del runtime.** Documenta cómo queda configurada la Routine de Claude Code que dispara esta skill. El runtime empieza en el PASO 0 BIS.

### Repositorio y ubicación de la skill
- Repo: `agencia-reinicia/claude-skills`.
- Ruta de esta skill: `revision-sprint-backlog-equipo-reinicia-modo-desatendido/SKILL.md`.
- La supervisada hermana (`revision-sprint-backlog-equipo-reinicia/SKILL.md`) vive en el mismo repo. Toda mejora de correctitud se hace primero en la supervisada y se sincroniza después aquí.

### Programación (cron)
- Expresión: `0 6 * * 1-5` (lunes a viernes a las **06:00 hora de Madrid**).
- Zona horaria: **Europe/Madrid**.
- Arranque del piloto: **automático desde el día 1** (lunes 01/06/2026). No requiere disparo manual.
- 🔁 **Run de respaldo (v1.5, recomendado, a crear):** una **segunda Routine** más tarde por la mañana (sugerido `0 9 * * 1-5` → 09:00) con el **mismo prompt**, que actúa como red ante un aborto transitorio del pase de las 06:00 (conector "conectando"/502 al arrancar). Es **idempotente**: relee el sprint y, si los AUTOIA del día ya están sellados correctamente, no reescribe nada; solo "rescata" a quien quedó sin procesar/sellar por un fallo estructural del primer pase. Ver Override 7 (resiliencia). Anotar su `routine_id` junto al principal cuando se cree.

### Alcance
- Sprint objetivo: **el sprint vigente**, detectado de forma **determinista** en cada ejecución (Override 1.0; raíz `i6aloc646e871a46d46cab983dd7a6704ef9b`) con cross-check contra el sprint activo en ClickUp. **No se fija ningún sprint ni ID de carpeta concretos** — se resuelve dinámicamente en cada pase.
- Equipos / miembros: **abierto al Equipo** — se procesan todos los AUTOIA detectados por el patrón `Excel-Clickup-Sprint-…` (Override 1.1): Equipo Operativo completo + POs con AUTOIA propio (Pablo Losada, Óscar Díez), **excepto** `EXCLUIDOS = ["Síntaris"]` (Override 1.2). Las altas nuevas se auto-incluyen; sin allowlist de inclusión permanente.

### Conectores MCP requeridos y permisos
| Conector | Permiso | Uso |
|---|---|---|
| ClickUp | Lectura (time entries + tareas, workspace `762713`) | Horas reales, estatus (Col D), nombres de tarea e IDs para los enlaces HYPERLINK |
| Zoho Workdrive (Sheet) | Lectura + escritura | Repoblar Data, escribir Tiempos / Tabla2 / Tabla21 / Log y sellos |
| Zoho Cliq | Publicación en canal | Reporte de ejecución del PASO 9, canal Metodología (unique_name `reiniciametodologa`; channel ID `T45816000000085077` solo de referencia) |

No se requiere ningún otro conector. Verificar que el token de integración de ClickUp (Néstor) tiene acceso a las tareas del periodo: las tareas privadas sin acceso provocan la anomalía API documentada en la Mejora 13.

### Prompt de disparo de la Routine
Texto exacto que ejecuta la Routine programada:
```
Ejecuta la revisión desatendida de Sprint Backlogs del Equipo Operativo para el sprint vigente (la carpeta se detecta de forma determinista, Override 1.0, con cross-check contra ClickUp). Sigue íntegramente la skill revision-sprint-backlog-equipo-reinicia-modo-desatendido: detección dinámica de Equipos y miembros (patrón Excel-Clickup-Sprint), lista de exclusión (Override 1.2), reglas deterministas del PASO 0 BIS, y al terminar postea el reporte de ejecución en el canal Metodología de Zoho Cliq (T45816000000085077).
```

### Identificador de la Routine
- Al crear la Routine en Claude Code se genera un `routine_id`. El runtime sustituye el placeholder `[routine_id]` del PASO 9 por este valor real, para trazabilidad del reporte en Cliq.
- `routine_id` (pase principal 06:00): **`trig_011nrUo4Fx9ugWtZUJTB7rbq`** (URL: `https://claude.ai/code/routines/trig_011nrUo4Fx9ugWtZUJTB7rbq`).
- `routine_id` (run de respaldo 09:00): **[pendiente de crear la 2ª Routine]**.

### Checklist pre-piloto
- [ ] Skill subida al repo `agencia-reinicia/claude-skills` (esta + la supervisada).
- [ ] Conectores MCP ClickUp / Workdrive / Cliq verificados en Claude Code.
- [ ] Carpeta del sprint vigente localizada en Workdrive y AUTOIA de cada miembro presentes.
- [ ] Routine creada con cron `0 6 * * 1-5` (Europe/Madrid) y el prompt de disparo de arriba.
- [ ] `routine_id` anotado y placeholder del PASO 9 sustituido.
- [ ] Primera ejecución (01/06, 06:00) revisada en el canal Metodología de Cliq.

---

## 🤖 PASO 0 BIS — MODO DE OPERACIÓN: DESATENDIDO

⚠️ **LEER PRIMERO. ESTE BLOQUE SUSTITUYE TODAS LAS PREGUNTAS HUMANAS DE LA SKILL SUPERVISADA.**

Esta skill se ejecuta sin PO delante. Cada vez que el contenido del documento más abajo diga "preguntar al PO", "validación del PO", "confirmar con el PO", "presentar al PO", aplicar las reglas deterministas que siguen. Si encuentras una decisión que NO esté cubierta aquí, escalar al reporte final como anomalía y NO tomar la decisión por defecto.

### Override 1 — Detección dinámica de Equipos y miembros (sustituye PASO 0)

**No preguntar al PO qué Equipos ni qué miembros procesar.** Aplicar la siguiente regla determinista:

**1.0 — Detección determinista de la carpeta del sprint vigente** (v1.3):
- Listar las subcarpetas de la raíz de Sprint Backlogs individuales: `i6aloc646e871a46d46cab983dd7a6704ef9b`.
- Filtrar por regex `^Sprint\s+0?(\d+)\s*-\s*0?(\d+)$` (tolera ceros a la izquierda y espacios alrededor del guion).
- Carpeta vigente = la de mayor `(año, N)` entre las que casen. Guardar su `folder_id`.
- **Cross-check** contra el sprint activo en ClickUp: si no coincide → **ABORTAR** y postear en Cliq un aviso de discrepancia. Empate entre dos carpetas o **0 coincidencias** → **ABORTAR**.
- ⛔ **ELIMINADO el ID hardcodeado del Sprint 6-26** (`8zevxe...`). Ya no se usa en ningún punto.
- Ejemplo ilustrativo (no fijar): al 31/05/2026 el sprint vigente resolvía a `Sprint 07-26`; en cada pase se recalcula dinámicamente.

**1.1 — Patrón de ficheros de miembro** (CORRIGE v1.3 — los ficheros ya NO contienen "AUTOIA" en el nombre):
- Patrón: `^Excel-Clickup-Sprint-\d+-\d+-(.+)$` → el grupo capturado es el **nombre de la persona**.
- Normalizar acentos a **NFC** al comparar y al capturar el nombre.
- **Excluir**: subcarpetas (p.ej. `Informes Ejecutivos...`), el fichero `(eliminar)` y cualquier zsheet que no case el patrón.
- El nombre del fichero sigue siendo la fuente de verdad estable: si una persona tiene fichero que casa el patrón, se procesa; si no, no.

**1.2 — Lista de exclusión** (v1.6 — ABIERTO AL EQUIPO; deroga la allowlist de piloto):
- **Procesar todos** los AUTOIA detectados por el patrón 1.1 — Equipo Operativo completo (Fabián, Paolo, José, Alejandro, Johanna, Camila) **+ los POs con AUTOIA propio en la carpeta** (Pablo Losada, Óscar Díez) — **EXCEPTO** los de la lista de exclusión.
- `EXCLUIDOS = ["Síntaris"]`. No procesar el AUTOIA de Síntaris: fichero cuyo nombre de persona (grupo capturado en 1.1) contiene `"Sintaris"`/`"Síntaris"` (comparar **case- y acento-insensible**; p. ej. `Excel-Clickup-Sprint-NN-AA-Óscar-Sintaris`). **Motivo**: ese AUTOIA lleva la columna **AK "Situación"** (resumen de producto por fila, columna 37, fuera de Tabla2) que esta skill **aún no sabe preservar ni actualizar**; procesarlo a ciegas arriesga descuadrarla. Síntaris se procesa **supervisado** hasta que se implemente el soporte de la columna AK (mejora pendiente). Al detectarlo, **saltarlo** y dejar una línea en el reporte Cliq: "Síntaris omitido (excluido por casuística columna AK)".
- **Altas nuevas**: cualquier fichero nuevo que case el patrón 1.1 se procesa **automáticamente** (no hay allowlist de inclusión que mantener). Para sacar puntualmente a alguien del automatismo, añadir su nombre a `EXCLUIDOS`.

**1.3 — Equipos activos** = espacios de ClickUp en el workspace `762713` cuyo nombre empiece literalmente por `"Equipo "` Y que tengan al menos un fichero de miembro (patrón 1.1) en la carpeta del sprint vigente (1.0).

**1.4 — Personas transversales**: si un miembro aparece físicamente en ficheros de varios Equipos, procesar TODOS los ficheros en los que aparezca y reportar en Cliq la duplicidad como hallazgo, sin actuar sobre ella.

**1.5 — Amigos Reinicia sin fichero de Sprint Backlog** (caso Síntaris, Chisco, etc.): **NO procesar, NO crear fichero, NO añadir nada al Informe Ejecutivo desde esta skill desatendida**. Solo registrar en el reporte Cliq como "personas con horas tracked pero sin Sprint Backlog — pendiente de tratamiento manual por PO líder".

### Override 2 — Decisión sobre la pestaña Data (sustituye Sub-paso 3b)

> 🚨 **ACTUALIZADO EN v1.1 (sincronización v3.5): este override queda DEROGADO por la Mejora 12.** Desde v3.5, el modo desatendido **NO usa refresco incremental Opción D**: aplica **refresco retroactivo completo del periodo** (relee todo el sprint desde ClickUp y reconstruye Data por entero en cada ejecución). Decisión de Néstor (26/05/2026): prioriza no perder información sobre el coste de tool calls. Ver PASO 6c Mejora 12. El texto histórico de la Opción D se conserva debajo solo como referencia.

**~~No preguntar al PO entre las opciones A/B/C/D. Aplicar SIEMPRE la Opción D: refresco incremental quirúrgico~~** (DEROGADO — ahora retroactivo completo, ver Mejora 12):

- ~~Calcular `filas_a_añadir = entries_totales_del_periodo_ClickUp − filas_Data_ya_escritas_para_esa_task` para cada producto.~~
- ~~Escribir EXACTAMENTE las nuevas filas en Data, sin tocar las existentes.~~

**Comportamiento v1.1 (vigente)**: repoblar Data desde cero con TODO el periodo del sprint (Mejora 12) + verificación de integridad (cada fila con horas en Data debe tener K reflejándolas; si 0,00 con Data detrás → reparar fórmula + NFC). Esto elimina el riesgo de horas perdidas silenciosamente que tenía el incremental. La validación de cuadre se hace contra ClickUp API en vivo (Mejora 5, PASO 8).

### Override 3 — Renames en Tiempos (sustituye PASO 4 — renames)


**Política Opción B canónica del PO líder.** Aplicar sin preguntar:

**3.A — Renames TRIVIALES (aplicar automáticamente):**
Son los que cumplen TODOS estos criterios simultáneamente:
1. Mismo cliente (corchete `[CLIENTE]` idéntico en ambos lados).
2. Distancia textual ≤ 5 caracteres (Levenshtein) Y diferencia atribuible a: mayúsculas/minúsculas, espacios extra, NFC vs NFD, presencia/ausencia de tildes, presencia/ausencia de corchetes de cliente.
3. NO existe en Data un literal distinto al candidato que también podría ser otro producto del plan.
4. NO añade ni quita prefijos `[SUPPORT]`, `[BUG]`, `[DUDA]`, `[PETICIÓN]`, `[ASSUMED]`, ni sufijos numéricos `2`, `3`, etc.

Si los 4 criterios se cumplen → aplicar el rename, registrar en Log de Cambios como `TIEMPOS_RENAME_AUTO`, y añadir un comentario en Col N (Comentario) de la fila renombrada con el texto:
```
Rename automático modo desatendido [DD/MM/AAAA HH:MM]: "[antes]" → "[después]". Trivial (mismo cliente, distancia ≤5).
```

**3.B — Renames NO TRIVIALES (NO aplicar, dejar como pendientes):**
Cualquier candidato que no cumpla los 4 criterios anteriores → **NO tocar la celda Concepto del plan**. En su lugar:

1. Registrar en Log de Cambios como `TIEMPOS_RENAME_PENDIENTE` con todos los datos del candidato (concepto plan, concepto Data, horas que se recuperarían, razón por la que no es trivial).
2. Escribir un comentario en **Col N (Comentario)** de la fila del plan con el texto:
```
⚠️ RENAME PENDIENTE VALIDACIÓN PO [DD/MM/AAAA HH:MM]: posible match con "[concepto Data candidato]" ([X]h). Razón no aplicado automáticamente: [criterio fallido]. Decide manualmente si renombrar.
```
3. Acumular para el reporte final agregado al PO.

**3.C — Sin candidato detectado**: ni se aplica ni se anota — el plan queda como está y las horas reales quedan como huérfanas en PASO 5.

### Override 4 — Motivos de desvío Col M (sustituye PASO 7 — validación PO)

**No preguntar al PO motivo por motivo.** Aplicar sugerencia automática según heurísticas:

| Contexto detectado | Motivo automático Col M | Comentario Col N |
|---|---|---|
| Huérfana `🤖 Soporte/WIP` con G=0 | `NO ESTIMADO` | `Sugerencia automática modo desatendido [fecha]: huérfana entró sin estimación.` |
| Huérfana `🤖 Fuera de plan` con G=0 | `NO ESTIMADO` | Igual al anterior |
| Producto del plan en status `parking e incidencias` y J > G | `PARKING` | `Sugerencia automática modo desatendido [fecha]: status parking en ClickUp.` |
| Producto del plan en status `validación cliente` con J > G | `COORDINACIÓN CLIENTE` | `Sugerencia automática modo desatendido [fecha]: status validación cliente en ClickUp.` |
| Producto del plan en status `done` o `closed` con J/G ≥ 1,5 | `MALA ESTIMACIÓN` | `Sugerencia automática modo desatendido [fecha]: cerrado con desvío >50%.` |
| Producto del plan con J > G pero status `DOING` y no cierra | **NO escribir motivo** | (queda en blanco; PO revisará manualmente) |
| Cualquier otro caso ambiguo | **NO escribir motivo** | (queda en blanco; PO revisará manualmente) |

Todas las sugerencias automáticas se registran en Log de Cambios como `MOTIVO_DESVIO_AUTO` (no `MOTIVO_DESVIO` que se reserva para escritura humana). El PO puede sobreescribir manualmente cuando lo revise.

### Override 5 — Alertas de sobrecarga (sustituye Paso 5 — alerta proactiva)

**No emitir alerta interactiva.** Acumular en el reporte Cliq al final.

### Override 6 — Reporte de ejecución al cierre

Tras procesar todos los miembros, postear en Zoho Cliq canal Metodología (herramienta `ZohoCliq_Post_message_in_a_channel` con `unique_name` = `reiniciametodologa`; channel ID `T45816000000085077` solo de referencia) un mensaje con la estructura definida en el nuevo PASO 9 (al final de esta skill).

### Override 7 — Política de errores

**No detener la ejecución por errores aislados.** Si el procesamiento de un AUTOIA falla:
1. Registrar el error completo (stack/contexto) en el reporte Cliq como anomalía.
2. Pasar al siguiente AUTOIA del siguiente miembro.
3. NO intentar revertir cambios parciales del AUTOIA fallido (el Log de Cambios del propio AUTOIA es el rastro auditable).

**Excepciones que SÍ detienen toda la ejecución** (errores estructurales — postear en Cliq y abortar):
- Workdrive Sheet API no responde.
- ClickUp MCP no responde.
- Carpeta del sprint actual no encontrada en Workdrive.
- 0 AUTOIAs detectados (no hay nada que procesar).

🔁 **Resiliencia de conector antes de abortar (v1.5).** Un conector "conectando" o un 502 transitorio en el arranque NO debe tirar el pase del día. Antes de declarar "ClickUp/Workdrive MCP no responde" y abortar:
1. **Reintentar con backoff** la disponibilidad/llamada del conector: p. ej. 3 intentos con espera creciente (≈30s, 60s, 120s) re-sondeando vía `tool_search` o reintentando la primera llamada. Solo si tras los reintentos el conector sigue sin exponer herramientas / sigue dando error → abortar estructuralmente.
2. **Para los 502 intermitentes durante el pase** (no en el arranque): reintentar la llamada concreta; y preferir **`clickup_filter_tasks` por tag de sprint en lote** frente a N× `clickup_get_task` (menos llamadas = menos superficie de 502). Esto es resolución de errores aislados (no aborta el pase).
3. **2º run de respaldo.** El pase de las 06:00 es el principal; existe un **segundo disparo de respaldo** (Routine programada más tarde por la mañana, ver sección de configuración) que **solo actúa si el de las 06:00 abortó** por error estructural, para que un hipo transitorio del conector no deje al Equipo sin actualización ese día. Si el pase de las 06:00 cerró con normalidad, el de respaldo no hace nada (idempotente: relee y, si ya está sellado el día, no reescribe).

Esta política convierte un aborto en **último recurso**, no en la primera reacción ante un conector lento.

---

## ÁMBITO DE APLICACIÓN

### En esta primera fase (validación)
La skill se aplica sobre los **ficheros AUTOIA duplicados** que el PO líder crea en la carpeta del sprint para cada miembro del equipo.

### Objetivo final
A futuro, la skill se aplicará **directamente sobre los ficheros oficiales de Sprint Backlog** que se generan en cada Sprint Planning, sin duplicación. La estructura del fichero es la misma; el flujo no cambia.

---

## EQUIPOS Y MIEMBROS — PRINCIPIO DE BÚSQUEDA DINÁMICA

⚠️ **Esta skill NO mantiene una lista hardcoded de Equipos ni de miembros.** Equipos, miembros y clientes cambian sprint a sprint: aparecen Amigos Reinicia, salen miembros, se reorganizan.

### Cómo identifica Equipos y miembros

Al activarse, la skill **siempre confirma** con el PO líder:

1. **Si el PO ya menciona persona(s) concreta(s)**: confirma que son las correctas y procede.
2. **Si el PO pide "el Equipo X" o "todo el equipo"**: la skill consulta ClickUp para listar los miembros que pertenecen a ese Equipo (vía espacios y asignaciones de tareas) y los presenta al PO para confirmación antes de procesar.
3. **Si hay personas transversales** (ej. una persona que trabaja en dos Equipos a la vez): la skill las detecta y pide al PO que confirme en qué contexto procesarlas.

**Ejemplo de confirmación inicial:**
```
He detectado estos miembros activos en ClickUp del Equipo [X] durante el Sprint actual:

  - [Persona 1] — [N] tareas, [H]h tracked
  - [Persona 2] — [N] tareas, [H]h tracked
  - [Persona 3] — [N] tareas, [H]h tracked (también activa en Equipo [Y])

¿Procedo con todas? ¿Excluyo a alguna? ¿Falta alguien que no aparezca aún?
```

### Caso especial: persona en ClickUp sin Sprint Backlog Zoho

Hay personas que están en ClickUp imputando horas pero **no tienen un Sprint Backlog propio en Zoho** — típicamente Amigos Reinicia que ayudan en soporte de clientes (ejemplo histórico: Síntaris — Óscar Seuba `99694542` y David Marco `99694543`).

La skill debe:

1. **Detectarlo** comprobando si el PO ha aportado un fichero AUTOIA para esa persona o si existe en la carpeta del sprint.
2. **Proponer al PO** un flujo reducido: no se procesa Sprint Backlog (no existe), pero **se crea una pestaña con sus horas reales agregadas en el Informe Ejecutivo del Equipo correspondiente**.
3. **Confirmación explícita** antes de proceder: "He detectado a [persona] imputando horas en ClickUp pero sin Sprint Backlog Zoho. Te propongo añadirla al Informe Ejecutivo del Equipo [X] como pestaña aparte con sus horas. ¿Procedo así o prefieres otro tratamiento?"

---

## ESTRUCTURA CANÓNICA DEL SPRINT BACKLOG

### 🆕 Plantilla nueva Sprint 6-26 — estructura canónica (v3.3)

Desde el **Sprint 6-26 (07/05/2026)** se usa una plantilla nueva ya consolidada con todas las pestañas predefinidas, formato Reinicia heredado, fórmulas de fábrica y filas vacías formateadas listas para escribir directamente. **Esto cambia profundamente el flujo de trabajo**: muchas operaciones que la v3.0-v3.2 hacían manualmente (crear Log de Cambios, construir bloque Metodología, reescribir SUMAR.SI, aplicar bandeo) ya no son necesarias.

Resumen estructural de la plantilla nueva (validada con AUTOIAs Fabián, José, Paolo, Alejandro, Johanna del Sprint 6-26 Día 1):

| Pestaña | Estado | Contenido |
|---|---|---|
| `Tiempos` | Predefinida con 2 tablas formales | Tabla2 (Sprint Backlog principal, cabecera fila 3) + Tabla21 (Metodología, cabecera fila 78-80 según fichero) — ambas con filas vacías formateadas listas para escribir |
| `Data` | Predefinida con Tabla1 | 58 columnas canónicas, ~114 filas vacías formateadas heredadas. `Column20` = nombre de tarea (clave SUMAR.SI), `Column57` = Horas Traqueadas |
| `Log de Cambios` | Predefinida con tabla formal | 11 columnas (Fecha/Hora/Pestaña/Fila/Columna/Producto/ValAnterior/ValNuevo/Motivo/Operador/Fuente), ~55 filas vacías formateadas |
| `Leyenda` | Predefinida (v3.4) — solo lectura | Documento de referencia con 6 secciones: (1) Semáforos visuales con umbrales, (2) Celdas auxiliares (filas C/D), (3) Sub-marcas de huérfanas, (4) Atribución NÉSTOR-PO, (5) Catálogo cerrado de 5 Motivos de Desvío, (6) Convenciones importantes. Anterior pestaña `Motivos Desvío` (v3.0-v3.3) renombrada y enriquecida en v3.4. |

**Fórmulas que vienen de fábrica** (NO reescribir, ya están funcionando):

- Tabla2 col K (ClickUp Registro): `=SUMIF(Table1[#All;Column20]; Tabla2[@Concepto]; Table1[#All;Horas Traqueadas])`
- Tabla2 col L (Diferencia horas): `=Tabla2[@ Horas estimadas ]-Tabla2[@ ClickUp Registro ]`
- Tabla21 cols K y L: análogas con `Tabla21[@Concepto]`
- Calendario en cols O-AJ (filas O2:AJ[última] de Tabla2): `=IF(Tabla2[@ Fecha límite ]=O$2;"OK";" ")` — pinta filas según Col H. **NO TOCAR.**
- Capacidad disponible prepoblada en `Tiempos!G66` por persona (Fabián 78,4h, José 72h, Paolo 60,2h, Alejandro 78,4h, Johanna 58,8h en el Sprint 6-26). **No necesita Sheet de capacidades externo.**

**Mapeo Tabla2 — variante "+1 col Comprometido" (única en plantilla nueva)**:

| Col | Letra | Contenido |
|---|---|---|
| 1 | A | **Sub-marca** huérfanas (`🤖 Fuera de plan` / `🤖 Soporte/WIP`) |
| 2 | B | Orden |
| 3 | C | Comprometido |
| 4 | D | Status |
| 5 | E | **Concepto** (clave SUMAR.SI) |
| 6 | F | Cliente |
| 7 | G | Horas estimadas |
| 8 | H | Fecha límite |
| 9 | I | Fechas presentación |
| 10 | J | Facturable |
| 11 | K | **ClickUp Registro** (SUMAR.SI) |
| 12 | L | Diferencia horas |
| 13 | M | Motivo desvío (dropdown 5 valores) |
| 14 | N | Comentario |

⚠️ **Si encuentras un AUTOIA con otra variante** (mapeo "estándar" sin `Comprometido`, o cabecera en otra fila), mapéalo desde la cabecera real con `get_content_of_range` antes de operar — la lógica de v3.0-v3.2 sigue aplicando como salvaguarda. La tabla "4 variantes detectadas Sprint 5-26" más abajo se conserva como referencia histórica.

### Estructura genérica (compatible con AUTOIAs antiguos)

Todo Sprint Backlog (oficial o AUTOIA) debe tener al menos estas hojas:

| Hoja | Propósito | Formato |
|---|---|---|
| `Tiempos` | Plan vs ejecutado, fila por producto, totales y resumen | Plan + huérfanas + bloque metodología (Tabla21 en plantilla nueva) |
| `Data` ó `Data Entries` | Time entries crudos pegados desde ClickUp | Una fila por entry |
| `Leyenda` (v3.4+) ó `Motivos Desvío` (v3.0-v3.3) | Documento de referencia con 6 secciones: Semáforos visuales / Celdas auxiliares / Sub-marcas huérfanas / Atribución NÉSTOR-PO / Catálogo CERRADO de 5 motivos para Col M de Tiempos / Convenciones | Plantilla — no modificar; reescrita por PASO 6b Mejora 3 al cierre |
| `Log de Cambios` | Auditoría de modificaciones de la skill | Append-only |

⚠️ **Variante hoja Data vs Data Entries** (validada con AUTOIAs Fabián y Johanna Sprint 5-26): algunos AUTOIAs tienen la **tabla viva (`Tabla1` con time entries actuales)** en una hoja llamada `Data Entries` mientras la hoja `Data` queda vacía o como reserva. Otros la tienen en `Data` directamente. La skill **siempre debe localizar la hoja con la tabla viva** antes de operar:

1. Listar worksheets con `ZohoSheet_list_all_worksheets`.
2. Listar tablas con `ZohoSheet_list_all_tables`. Identificar dónde está `Tabla1` (la que contiene `Column20` = nombre de tarea y `Column11` = duración ms).
3. Anotar la hoja activa (`Data` o `Data Entries`) y usar ese nombre en todas las fórmulas posteriores: `'Data Entries'!$T$2:$T$N` o `Data!$T$2:$T$N` según corresponda.

Otras hojas pueden coexistir (Hoja1, Hoja2, Ideas) pero la skill solo opera sobre `Tiempos`, la hoja activa de time entries (`Data` o `Data Entries`) y `Log de Cambios`. La hoja `Leyenda` (v3.4+) / `Motivos Desvío` (v3.0-v3.3) se LEE como referencia del catálogo cerrado de motivos. La skill solo la modifica en el PASO 6b Mejora 3 al cierre del procesamiento (reescritura completa con 6 secciones documentales).

### Estructura de la hoja Tiempos

⚠️ **Las columnas de Tiempos pueden estar desplazadas entre ficheros.** Algunos ficheros tienen Concepto en `D` (col 4) y otros en `E` (col 5). **La skill SIEMPRE inspecciona la fila de cabeceras primero** (típicamente fila 3 en AUTOIAs y fila 4 en algunas variantes) para mapear:

- Columna **Marca** (A en plantilla, col 1) — texto identificativo de huérfanas (`🤖 Fuera de plan` / `🤖 Soporte/WIP`)
- Columna **Orden** (B en plantilla, col 2) — numeración asignada en Sprint Planning
- Columna **Status** (C en plantilla, col 3)
- Columna **Concepto** (D en plantilla, col 4) — clave del SUMAR.SI
- Columna **Cliente** (E en plantilla, col 5)
- Columna **Horas estimadas** (F en plantilla, col 6)
- Columna **Fecha límite** (G en plantilla, col 7)
- Columna **ClickUp Registro** (J en plantilla, col 10) — suma SUMAR.SI
- Columna **Diferencia horas** (K en plantilla, col 11)
- Columna **Motivo desvío** (L en plantilla, col 12, dropdown)
- Columna **Comentario** (M en plantilla, col 13, texto libre)

⚠️ La skill verifica este mapeo en cada fichero antes de operar. Si las columnas están desplazadas, recalcula los offsets desde la fila de cabeceras detectada.

#### Variantes detectadas en sesión real Sprint 5-26

Durante el procesamiento del Sprint 5-26 se detectaron **4 variantes** de mapeo entre AUTOIAs distintos. La skill **siempre inspecciona la cabecera primero** y nunca asume mapeo por la persona:

| AUTOIA | Cabecera | Cols B/C/D/E/F/G/H/I/J/K/L/M | Notas |
|---|---|---|---|
| **Alejandro Pont** | Fila 4 | B=Orden, C=Status, D=Concepto, E=Cliente, F=Estim, G=Fecha lím, H=Pres, I=Fact, J=Registro, K=Diferencia, L=Motivo, M=Comentario | Mapeo "estándar" del v3.0 |
| **Fabián Vargas** | Fila 3 | B=Orden, C=Comprometido, D=Status, E=Concepto, F=Cliente, G=Estim, H=Fecha lím, I=Pres, J=Fact, K=Registro, L=Diferencia, M=Motivo, N=Comentario | +1 col por columna `Comprometido` |
| **José Barreiro** | Fila 4 | Igual que Fabián (con `Comprometido`) | +1 col por columna `Comprometido`, cabecera fila 4 |
| **Johanna Brizuela** | Fila 4 | Igual que Alejandro (sin `Comprometido`) | Mapeo estándar |

**Impacto operativo**: cuando la skill busque la columna **Concepto** en Fabián o José, debe ser **col 5 (E)** y no col 4 (D). Cuando aplique fórmulas SUMAR.SI tipo `Tabla2[@Concepto]` no hay problema (es resolución por nombre de columna), pero al referenciar literalmente celdas (`D[fila]`) sí. **Siempre detectar la posición real desde la cabecera y usar la letra correcta**.

Bloques estándar (numeración variable según fichero):

1. **Sprint Backlog principal** — productos planificados con campo Orden numerado
2. **Buffer vacío** (1-3 filas) entre bloques distintos
3. **Productos Reinicia internos** — sin orden, status SPRINT BACKLOG (formación, marketing, etc.)
4. **Buffer vacío**
5. **Soportes mensuales por cliente** — sin orden, status SPRINT BACKLOG
6. **Buffer vacío** ← **importante: esta skill NO consume todos los huecos al insertar huérfanas; deja al menos 1 fila libre por bloque para futuras inserciones**
7. **TOTAL HORAS OPERATIVAS ESTIMADAS** — `=SUMA(F[ini]:F[fin])` del Sprint Backlog completo
8. **TOTAL HORAS OPERATIVAS DISPONIBLES** — capacidad del PO + suma SUMAR.SI de la columna I
9. **TOTAL BALANCE DE HORAS** — disponibles - estimadas
10. Bloque resumen (Horas totales sprint / Operativas / Facturable / No Facturable)

### Recomendación al Sprint Planning inicial

Cuando un Sprint Planning crea un nuevo Sprint Backlog (vía `sprint-planning-reinicia`), **debe dejar huecos entre bloques** (mínimo 2-3 filas vacías por bloque) para que esta skill pueda insertar huérfanas sin romper el formato heredado. Si el Sprint Backlog viene "comprimido" sin huecos, esta skill avisará al PO antes de continuar.

### Tabla de Metodología — pendiente de creación

A futuro, el bloque Metodología y Gestión que esta skill construye fuera de Tiempos pasará a ser una tabla canónica predefinida del Sprint Backlog (igual que las demás). De momento, la skill lo crea manualmente cada vez. Esto se gestionará externamente cuando se actualicen las plantillas oficiales.

---

## SUB-MARCAS COL A — REGLA CERRADA

⚠️ **Nomenclatura canónica con dos únicos valores admitidos**. NO inventar otros textos como `⚠️ HUÉRFANA`, `⚠️ FUERA DE PLAN`, `🆕 NUEVO`, etc. Esta regla es cerrada y aplica a todas las huérfanas.

| Sub-marca | Cuándo aplicar |
|---|---|
| `🤖 Fuera de plan` | Productos digitales nuevos no planificados, gestiones mensuales (cliente o Reinicia), SPIKEs de última hora, incidencias mayores, productos arrastrados de sprints anteriores con tracking en el sprint actual |
| `🤖 Soporte/WIP` | Microtareas reactivas en listas Soporte: `[BUG]`, `[DUDA]`, `[PETICIÓN]`, `[SUPPORT]`, `[ASSUMED]`, Form Submission, cargas de registros operativas |

**Disciplina de adherencia**: antes de añadir cualquier huérfana en Tabla2, releer **esta sección** y **el bloque de la plantilla nueva**. Si dudas entre las dos sub-marcas, comprueba en qué lista de ClickUp está la tarea: lista `Soporte [CLIENTE]` → `🤖 Soporte/WIP`. Lista `General [CLIENTE]` o `Gestión [CLIENTE]` → `🤖 Fuera de plan`.

---

## HUÉRFANAS — DATOS OBLIGATORIOS DESDE CLICKUP

Para cada huérfana añadida en Tabla2, llamar a `clickup_get_task` con el `task_id` del time entry y rellenar:

| Col | Contenido | Formato |
|---|---|---|
| A | Sub-marca canónica | `🤖 Fuera de plan` o `🤖 Soporte/WIP` |
| D | Status | Mapear status ClickUp a status Reinicia (`DOING`, `DONE`, `VALIDACIÓN REINICIA`, etc.) |
| E | Concepto | Nombre exacto de la tarea ClickUp (con cuidado del bug Unicode — ver sección siguiente) |
| F | Cliente | Cliente extraído del `[CLIENTE]` final del nombre |
| G | Horas estimadas | **Siempre `0,00`** (la huérfana no estaba estimada en el Sprint Planning) |
| H | Fecha límite | `due_date` de ClickUp en formato `MM/DD/YY`. Si null, dejar vacío |
| M | Motivo desvío | **`NO ESTIMADO`** siempre (huérfana = entró sin estimación) |
| N | Comentario | `Huérfana Día N — [contexto]. Tiempo estimado en ClickUp: Xh.` Si `time_estimate` es null en ClickUp, escribir `sin estimación` |

⚠️ **Col G siempre `0,00` numérico** (no `0`, no `"0"`, no vacío). Esto preserva la fórmula de cuadre y reporta correctamente la diferencia en Col L. **Col M=`NO ESTIMADO`** porque la regla del Paso 7 obliga a documentar motivo cuando J>G — y como G=0, J>0 siempre que la huérfana se haya trabajado.

### ⚠️ Excepción crítica — Gestiones Cliente NUNCA van a Tabla2

**Las tareas tipo `Gestión [Mes] [CLIENTE]`** (lista `Gestión [CLIENTE]` en ClickUp, task_type `Gestión`, parent null) **NO se tratan como huérfanas de Tabla2**. Aunque cumplan formalmente la definición de huérfana (no están en plan), conceptualmente son **trabajo recurrente esperado** de gestión mensual del cliente, no algo nuevo que sorprenda.

**Procedimiento correcto**: las Gestiones Cliente **van a Tabla21 Bloque B** ("Gestiones Cliente"), no a Tabla2. Detalles del procedimiento en la sección PASO 6 (Tabla21 canónica).

**Por qué esta excepción**:
1. El plan Tabla2 representa producto facturable comprometido en Sprint Planning.
2. Las Gestiones Cliente son trabajo recurrente que **ya está descontado de la capacidad disponible** (fila 71 "Operativas" en G — la diferencia entre G70 "Horas totales sprint" y G71 "Operativas" representa el ~20-30% de la capacidad reservado para Gestiones + Metodología).
3. Meterlas en Tabla2 las trata como sobrecarga del plan cuando en realidad son carga prevista en otra dimensión.
4. La Col J de Gestiones Cliente sigue siendo `"Sí"` (facturable), por lo que en el Informe Ejecutivo aparecen correctamente como horas facturables aunque no estén en Tabla2.

**Validado piloto Sprint 6-26 Día 2**: José (Gestión Mayo Lider System) y Alejandro (Gestión Mayo Exeltis) — ambas se mueven de Tabla2 huérfana a Tabla21 Bloque B.

⚠️ **NOTA TRANSITORIA**: en sprints futuros, durante Sprint Planning, **NO se incluirá Gestión Cliente como producto del plan Tabla2**. La regla "todo trabajo facturable va a Tabla2" tiene esta excepción explícita por la razón del punto (2): la capacidad disponible en G71 ya descuenta Gestión Cliente + Metodología. Las Gestiones Cliente quedan siempre en Tabla21 Bloque B.

---


## ATRIBUCIÓN DE SUBTAREAS — REGLA CANÓNICA

⚠️ **Cuando un time entry corresponde a una subtarea ClickUp** (no a una tarea raíz), las horas se atribuyen al producto **padre** del plan, no a la subtarea. Esta regla preserva la lógica de "el producto del plan es el agregado" y mantiene la SUMAR.SI cuadrando contra Tabla2 sin necesidad de duplicar filas para cada subtarea.

### Procedimiento

Para cada time entry recibido de `clickup_get_time_entries`:

1. **Detectar si es subtarea**: el nombre típicamente NO termina en `[CLIENTE]` y/o el campo `task.parent` no es null. Si dudas, llamar `clickup_get_task` con el `task_id` y comprobar `parent`.
2. **Si `parent` es null** (tarea raíz): atribuir directamente. Su nombre es el `Concepto` que va en Data!Column20.
3. **Si `parent` no es null** (es subtarea): llamar `clickup_get_task` sobre el `task.parent` para obtener el nombre del producto padre. Atribuir las horas al **padre** y escribir el nombre del **padre** en Data!Column20.
4. **Verificar que el padre está en el plan** (Tabla2!E[fila]) por match exacto del nombre. Si está → match SUMAR.SI funciona, K[fila del padre] suma las horas correctamente.
5. **Si el padre NO está en el plan**: el padre es la huérfana, no la subtarea. Tratar al padre como huérfana (sub-marca canónica `🤖 Fuera de plan` o `🤖 Soporte/WIP` según corresponda) y atribuir todas sus subtareas trackeadas al padre.

### Ejemplo validado (Sprint 6-26 Día 2 — Johanna)

ClickUp devuelve 4 entries de 4 subtareas distintas, todas con `parent = "869ckja53"` (`Ajustes  Conector Zoho CRM y App Formación [LIDER SYSTEM]`):

| Entry subtarea | Duración | Atribución |
|---|---|---|
| Actualizar/Cumplimentar diseño funcional (parte 1) | 0,70h | Padre fila 8 plan |
| Actualizar/Cumplimentar diseño funcional (parte 2) | 0,50h | Padre fila 8 plan |
| Proponer informes por cada Flow para integridad de datos | 0,82h | Padre fila 8 plan |
| Preparar diseño funcional nuevas peticiones | 1,69h | Padre fila 8 plan |

**Resultado**: 4 filas en Data con el mismo `Concepto` (nombre del padre) y horas distintas. SUMAR.SI agrega las 4 → K[fila 8] = 3,71h. Cuadre limpio sin huérfanas falsas.

### Pérdida de granularidad y cómo gestionarla

Atribuir al padre **pierde granularidad en Data**: ya no se ve qué subtarea concreta consumió cada hora. Esto es aceptable porque:

- La fuente de verdad operativa es **ClickUp**, no Data. Para análisis de detalle, consultar ClickUp directamente.
- El AUTOIA es un **agregador de cuadre**, no un sistema de timetracking detallado.
- El bloque "Comentario" (Col N de Tabla2) puede usarse para anotaciones cualitativas si una subtarea concreta merece destacarse.

Si en algún caso particular el PO necesita ver el desglose por subtarea en Data (caso especial), escalar a un análisis ad-hoc fuera del flujo estándar — no romper la regla canónica para el caso general.

### Excepciones documentadas

- **Subtareas de productos NO planificados**: si el padre no está en Tabla2, es huérfana (no la subtarea). Patrón Opción A se mantiene: subtareas tributan al padre, padre como huérfana en Tabla2.
- **Subtareas de Soporte (form_response sin padre)**: las tareas tipo `form_response` en listas Soporte suelen ser tareas raíz (`parent=null`) aunque visualmente parezcan subtareas dentro de un producto agregado de Soporte. Tratarlas como huérfanas independientes `🤖 Soporte/WIP` (no como subtareas) salvo que haya un padre real explícito.

---

## COLUMNA J FACTURABLE — REGLA CANÓNICA

⚠️ **Regla añadida en Sprint 6-26 Día 2**. Aplica retroactivamente a todas las filas de Tabla2 y Tabla21. Si el AUTOIA antiguo tiene Col J vacía, rellenar siguiendo la matriz. Si ya está rellena con valores correctos, **NO modificar**.

### Valores admitidos

Solo dos: `"Sí"` y `"No"`. La plantilla maestra del Sprint 6-26 trae la lista desplegable Col J pre-configurada con estos dos valores. Cualquier otro valor (`"F"`, `"nF"`, `"Y"`, `"N"`, etc.) es **histórico/obsoleto** y debe migrarse.

### Matriz de decisión

| Concepto | Tabla | Col J | Razón |
|---|---|---|---|
| Producto del plan con cliente externo (`[GONHER]`, `[INEFSO]`, `[AVADERM]`, etc.) | Tabla2 | **Sí** | Trabajo facturable de cliente |
| Producto del plan con `[REINICIA]` o `[REINNOVA]` (formación interna, contenidos SEO, web Reinicia, talleres internos) | Tabla2 | **No** | Trabajo interno, no facturable |
| Bolsa de Soporte cliente externo (`Soporte Mayo 2026 [CLIENTE]`) | Tabla2 | **Sí** | Trabajo facturable de cliente |
| Huérfana cliente externo (microtareas reactivas BUG/DUDA/PETICIÓN/SUPPORT/ASSUMED, productos arrastrados, etc.) | Tabla2 | **Sí** | Trabajo facturable de cliente aunque no estuviera en plan |
| Huérfana Reinicia/Reinnova (Asesor PO Claude, Taller IA, etc.) | Tabla2 | **No** | Trabajo interno |
| Sprint Planning, Daily, Sprint Review, Retrospective (Reinicia o Cliente) | Tabla21 Bloque A | **No** | Ceremonia metodológica, nunca facturable |
| Refinamiento (Reinicia o Cliente) | Tabla21 Bloque A | **Sí** | Excepción a la regla de ceremonias — el refinamiento sí es facturable |
| Gestión Reinicia interna (`Gestión Reinicia TODOS [Mes] [REINICIA]`) | Tabla21 Bloque A | **No** | Trabajo interno |
| Gestión Cliente (`Gestión [Mes] [CLIENTE]`) | Tabla21 Bloque B | **Sí** | Trabajo facturable de cliente |

### Reglas operativas derivadas

1. **Toda Tabla2 lleva Col J obligatoria**: cuando se añade un producto al plan o una huérfana, asignar Col J en la misma escritura. NO dejar vacío.
2. **Toda Tabla21 lleva Col J obligatoria**: cuando se añade ceremonia o gestión, asignar Col J en la misma escritura.
3. **La fila vacía separadora del bloque Tabla21 lleva Col J vacía** (no `"No"`).
4. **El sufijo `[CLIENTE]` del Concepto define Col J en la mayoría de casos**: si es `[REINICIA]` o `[REINNOVA]` → No; si es `[METODOLOGÍA REINICIA]` → No (es ceremonia); cualquier otro cliente externo → Sí. La excepción son los refinamientos (Sí incluso si son Reinicia metodología).

### Migración de fórmulas D72/D73 a `"Sí"`/`"No"`

⚠️ **AUTOIAs anteriores al Sprint 6-26 Día 2** tienen las fórmulas SUMIF de "Total Facturable" / "Total No Facturable" cableadas a criterios `"F"` y `"nF"` (siglas históricas Reinicia). Para que el cuadro de mando del AUTOIA funcione con los valores actuales `"Sí"`/`"No"`, hay que reescribir esas fórmulas.

**Cómo localizar las fórmulas (CRÍTICO — la posición varía por AUTOIA)**:

La fila exacta donde están las fórmulas D72/D73 **NO es fija**. Depende del número de productos en el plan Tabla2. Validado en piloto Sprint 6-26 Día 2:

| AUTOIA | Filas de fórmulas |
|---|---|
| Fabián | 72, 73 |
| Paolo | 73, 74 |
| Alejandro | 73, 74 |
| Johanna | 72, 73 |
| **José** | **51, 52** |

**Procedimiento obligatorio** antes de reescribir:

1. Llamar `ZohoSheet_get_content_of_range` con `start_row=45, end_row=80, start_column=3, end_column=4` para localizar las etiquetas `"Facturable"` y `"No Facturable"` en Col C.
2. Las celdas D inmediatamente a la derecha de esas etiquetas son las fórmulas a reescribir.
3. Reescribir con:
   - Facturable: `=SUMIF(Tabla2[ Facturable ];"Sí";Tabla2[ Horas estimadas ])`
   - No Facturable: `=SUMIF(Tabla2[ Facturable ];"No";Tabla2[ Horas estimadas ])`
4. Mantener los espacios alrededor de `Facturable` y `Horas estimadas` exactamente como aparecen en la cabecera de Tabla2 (la API es sensible al match exacto del nombre de columna).

⚠️ **Plantilla maestra**: la plantilla maestra ya ha sido actualizada por el PO líder a `"Sí"`/`"No"` a partir del Sprint 6-26 Día 2. Todos los AUTOIAs nuevos generados desde la plantilla nueva ya vienen con las fórmulas correctas. La migración manual solo aplica a AUTOIAs anteriores que se sigan usando.

---

## BUG UNICODE EN SUMAR.SI

⚠️ **SUMAR.SI de Zoho Sheet falla silenciosamente** con ciertos caracteres Unicode incluso cuando los strings parecen idénticos visualmente. El motor compara byte a byte y trata como distintos algunos caracteres compuestos. Validado piloto Sprint 6-26 Día 1 con Fabián.

### Caracteres prohibidos confirmados

Los siguientes caracteres rompen el match SUMAR.SI cuando aparecen en `Tabla2[@Concepto]` o `Data!Column20`:

| Carácter | Unicode | Sustitución ASCII |
|---|---|---|
| `↔` | U+2194 | `<->` |
| `⟷` | U+27F7 | `<-->` |
| `→` | U+2192 | `->` |
| `←` | U+2190 | `<-` |

**Procedimiento**: si el nombre de la tarea en ClickUp contiene alguno de estos caracteres (típico en tareas de sincronización, ej. `firma WP↔CRM`), sustituir por el ASCII en **AMBOS extremos**: `Tabla2!E[fila]` y `Data!Column20[fila]`. Si solo se sustituye en uno, el match sigue roto.

### Combinaciones de tildes en strings largos

Detectado también en **strings largos con múltiples acentos** (sobre todo terminaciones `-ción + acento posterior`):

- `Sincronización + matrícula` → match falla
- `Facturación + Estimación` → match falla
- `Configuración DataPrep` → match falla en algunos contextos

**Política de tildes**:

1. Pegar primero con tildes (caso normal). Verificar K[fila] con `get_content`.
2. Si K=0,00 cuando debería tener tracking → re-pegar **sin tildes** en ambos extremos (Tabla2!E y Data!Column20).
3. Si dudas, sustituir preventivamente las tildes en el momento de escribir el plan o la huérfana — la lectura humana no se ve afectada.

⚠️ **API Zoho `cell.content.get` y `range.content.get` devuelven solo valores evaluados, NO fórmulas**. Las fórmulas dependientes solo aparecen en la respuesta de `set_content_to_*` cuando se modifica una celda dependiente. Por eso el bug Unicode debe diagnosticarse por valor 0,00 inesperado en K[fila], no por inspección de fórmula.

⚠️ **`recalculate` no resuelve el bug**. La única solución es reescribir las celdas afectadas con caracteres compatibles.

### Trocear `set_content_to_multiple_cells` ≤ 40 celdas

La API devuelve `HTTP 414 Request-URI Too Large` cuando el payload excede ~40 celdas con strings largos (>50 caracteres por celda). **Regla operativa**: nunca enviar más de 40 celdas en una sola llamada. Si necesitas escribir 80 celdas, parte en 2 llamadas. Validado Sprint 6-26 Día 1.

---



### PASO 0 — Confirmación inicial dinámica

La skill **siempre confirma antes de tocar ningún fichero** lo siguiente:

1. **Equipo o persona(s) a procesar.** Si el PO no lo dice explícitamente, la skill consulta ClickUp y propone una lista para confirmar.
2. **Clientes activos en el sprint** para ese Equipo/persona (extraídos de las imputaciones reales).
3. **Personas transversales** detectadas (aparecen en varios Equipos): pedir al PO que indique en qué contexto procesarlas.
4. **Personas sin Sprint Backlog Zoho** (caso Amigos Reinicia): proponer flujo reducido.
5. **Modo de ejecución**: ¿pregunto antes de cada miembro o proceso todos seguidos?
   - Por defecto: preguntar antes de cada uno.
   - Si el PO dice explícitamente "procesa todos sin parar", omitir confirmaciones intermedias y reportar resumen al final.

### PASO 1 — Inspección inicial del fichero

1. **Listar worksheets** con `ZohoSheet_list_all_worksheets`. Identificar `worksheet_id` de Tiempos, Data y Log de Cambios.
2. **Si no existe Log de Cambios**, crearla (sub-paso 1a).
3. **Inspeccionar fila de cabeceras de Tiempos** (típicamente fila 4) para mapear columnas Concepto, Status, Cliente, Horas estimadas, ClickUp Registro, Diferencia horas, **Motivo desvío** y **Comentario**.
4. **Identificar la fila TOTAL HORAS OPERATIVAS ESTIMADAS** y guardar su número.
5. **Identificar el rango del Sprint Backlog principal** (de fila 5 hasta antes del TOTAL).
6. **Capturar estado pre-cambio** en Log de Cambios: total horas plan, total tracked actual, total filas Sprint Backlog, fecha y hora de la ejecución, número de huecos vacíos detectados entre bloques.

#### Sub-paso 1a — Asegurar hoja `Log de Cambios` con TablaLog y formato Reinicia

⚠️ **Deprecado para Sprint 6-26 y posteriores**: la plantilla nueva ya trae la hoja `Log de Cambios` predefinida con tabla formal (`Tabla Log de Cambios`), 11 columnas canónicas y ~55 filas vacías formateadas. **Saltar este sub-paso si el AUTOIA es Sprint 6-26+ y la hoja existe**.

Solo aplicar este sub-paso si el AUTOIA es de Sprint 5-26 o anterior y/o no tiene hoja `Log de Cambios`. La lógica original se conserva como salvaguarda:

La hoja `Log de Cambios` debe estar estandarizada en todos los Sprint Backlogs **como tabla formal** (`TablaLog` o equivalente, ver nota más abajo) con formato Reinicia heredable. Esto garantiza que cada nueva entrada herede automáticamente Manrope, alto de fila y el estilo uniforme gris/blanco del Log — lo que evita el bug histórico de inserciones sin formato.

##### Si el fichero no tiene la hoja `Log de Cambios`

1. **Crear la hoja** con `ZohoSheet_create_worksheet`.
2. **Escribir cabeceras canónicas en fila 1** (11 columnas):

   ```
   Fecha | Hora | Pestaña | Fila | Columna | Producto | Valor anterior | Valor nuevo | Motivo | Operador | Fuente
   ```

3. **Crear tabla con estilo Reinicia** vía `ZohoSheet_create_table`:

   ```
   start_row = 1, start_column = 1, end_row = 2, end_column = 11
   table_style = {
     template: "MEDIUM2",
     color: "#3812CF",
     properties: { banded_rows: true, first_column: false, last_column: false }
   }
   ```

   ⚠️ **Limitación conocida**: Zoho asignará automáticamente un nombre tipo `Table2` o `Table3` (numeración global secuencial). NO existe método `rename_table` en el MCP de Zoho — solo `rename_headers_of_table`. La skill no puede forzar el nombre `TablaLog`; convive con el nombre asignado.

4. **Aplicar formato celda Manrope a A2:K(última)** vía `ZohoSheet_format_ranges`:

   ```
   {
     range: "A2:K2",
     font_name: "Manrope",
     font_size: 10,
     row_height: 22,
     vertical_alignment: "middle",
     wrap_text: true
   }
   ```

5. **Aplicar formato cabecera A1:K1** (negrita azul Reinicia):

   ```
   {
     range: "A1:K1",
     bold: true,
     fill_color: "#D9D0FB",
     font_color: "#3812CF",
     font_name: "Manrope",
     font_size: 10,
     row_height: 28,
     vertical_alignment: "middle"
   }
   ```

6. **Registrar primera entrada** en fila 2: `[fecha] | [hora] | Log de Cambios | 1 | - | - | - | - | INICIALIZACIÓN | Skill | Hoja Log de Cambios creada por revision-sprint-backlog-equipo-reinicia`.

##### Si el fichero ya tiene la hoja `Log de Cambios` pero NO tiene tabla formal sobre ella

Detectado vía `ZohoSheet_list_all_tables` (ninguna tabla en la hoja `Log de Cambios`). Esto es típico en AUTOIAs procesados con versiones anteriores de la skill.

1. **Verificar el rango actual usado** con `ZohoSheet_get_used_area` para conocer `last_row`.
2. **Crear tabla formal sobre todo el rango actual** A1:K[last_row] con `table_style` y limitaciones idénticas al caso anterior (paso 3).
3. **Aplicar formato a A2:K[last_row]** (Manrope 10, alto 22pt, alineación middle, wrap_text true) vía `format_ranges`.
4. **Aplicar formato cabecera A1:K1** (idéntico al caso anterior).
5. **Aplicar estilo uniforme** del Log a las filas existentes (ver sub-paso 1b siguiente).
6. **Registrar entrada de migración**: `[fecha] | [hora] | Log de Cambios | - | - | - | - | - | TABLA_LOG_CREADA | Skill | TablaLog creada sobre Log de Cambios existente para garantizar formato Reinicia consistente`.

##### Si el fichero ya tiene tabla formal sobre Log de Cambios

Saltar a sub-paso 1b para asegurar el estilo uniforme del Log en filas existentes.

#### Sub-paso 1b — Estilo visual uniforme del Log

⚠️ **Deprecado para Sprint 6-26 y posteriores**: la plantilla nueva trae el Log de Cambios con estilo Reinicia ya aplicado en las ~55 filas vacías formateadas. **No aplicar bandeo manual ni format_ranges masivos**. Solo escribir contenido en las filas vacías; el formato se hereda automáticamente.

Solo aplicar este sub-paso si el AUTOIA es Sprint 5-26 o anterior. La lógica original se conserva como salvaguarda:

⚠️ **Limitación crítica**: el `template MEDIUM2` + `banded_rows: true` de `create_table` **no garantiza estilo visible** cuando ya hay celdas con formato de fondo previo (típico en filas pegadas con `csvdata.set` que llevan fill blanco implícito). El estilo de la tabla queda "tapado" por el fill explícito de las celdas.

**Estilo canónico del Log (validado piloto Fabián 06/05/2026)**: TODAS las filas de datos con **mismo fondo gris Reinicia `#EBEBEB` y borde blanco `#FFFFFF` solid**. NO usar bandeo intercalado gris/blanco — simplificación visual decidida por el PO. La cabecera (fila 1) conserva su estilo de tabla por defecto.

**Solución**: tras crear/asegurar la tabla, aplicar estilo uniforme al rango de datos vía `format_ranges`:

```
format_ranges(
    range="A2:K[last_row]",
    fill_color="#EBEBEB",
    border={
        border_color="#FFFFFF",
        border_style="solid",
        border_type="all_border"
    },
    font_name="Manrope",
    font_size=10,
    vertical_alignment="top",
    wrap_text=true
)
```

Aplicar este estilo:
- Tras la creación inicial de la hoja (sub-paso 1a, caso "no existe").
- Tras la migración a TablaLog (sub-paso 1a, caso "existe sin tabla formal").
- Tras cada inserción de nuevas filas durante la ejecución (al final del proceso, recalculando `last_row`).
- La última fila de la tabla queda **vacía como buffer** con el mismo estilo aplicado.

#### Sub-paso 1c — Sello de actualización en cabecera

La skill estampa la fecha y hora de la última ejecución como **sello de versión visible** del fichero:

- **Pestaña Tiempos, celda E1** (`column_index = 5`): `Última actualización: DD/MM/AAAA HH:MM:SS — Sprint X-YY`. Formato canónico Reinicia:
  - Fuente: **Manrope**, **bold**
  - Tamaño: **14 pt**
  - Color de fuente: **#3812CF** (azul/lila Reinicia)
  - Alineación vertical: middle
  - Hora en formato `hh:mm:ss` (no solo fecha) para precisar versión cuando se cuadra varias veces el mismo día
- **Pestaña Log de Cambios, celda M1**: mismo texto, posición fuera del rango de TablaLog (que cubre A:K) para que actúe como metadato suelto sin entrar en la tabla.

Estos sellos se actualizan al final de cada ejecución (no al inicio). Si el sello previo existe, se sobreescribe con el timestamp actual.

Registrar en Log de Cambios: `[fecha] | [hora] | Tiempos | 1 | E | - | [sello previo o vacío] | [sello nuevo] | SELLO_ACTUALIZACION | Skill | Sello de fin de ejecución`.

### PASO 2 — Recopilación de time entries de ClickUp

Usar `clickup_get_time_entries` con `assignee_id` del miembro y rango de fechas del sprint.

Si el endpoint falla con error de validación JSON (caso típico: time entries sin task asociada), **fragmentar el rango en bloques temporales más pequeños** (días u horas) hasta aislar la entrada problemática. Las entradas no recuperables se omiten y se reportan al final del proceso (timestamp, duración aproximada, usuario).

El resultado de este paso es el listado completo de entries en memoria, listo para pegar en la pestaña Data en el Paso 3.

### PASO 3 — Poblar la pestaña Data con los time entries del sprint

⚠️ **Operación potencialmente destructiva**. Registrar en Log de Cambios antes de tocar nada.

La skill trabaja siempre sobre la pestaña `Data` original del fichero. **NO se crean pestañas auxiliares**: una sola fuente de verdad de time entries por AUTOIA.

#### 🆕 Modo minimalista por defecto (v3.3) — solo Col20 + Col57

Para AUTOIAs con plantilla Sprint 6-26+ (Tabla1 ya predefinida con 58 columnas y filas vacías formateadas), el modo por defecto es **escribir solo dos columnas por entry**:

| Col | Letra | Contenido |
|---|---|---|
| 20 | T | `Concepto` = nombre exacto de la tarea ClickUp (clave SUMAR.SI) |
| 57 | BE | `Horas Traqueadas` = duración en horas decimales (ej. `1,25` no `1h 15m`) |

Con esto basta para que la SUMAR.SI cuadre. Las 56 columnas restantes (custom fields, fechas, status, tags, etc.) **NO son necesarias** para el flujo principal de revisión y se omiten para reducir tokens y tool calls.

**Procedimiento minimalista**:

1. Recopilar time entries del día/sprint con `clickup_get_time_entries` (ya hecho en Paso 2).
2. Para cada entry, calcular `horas = duration_ms / 3600000` con coma decimal es-ES (`1,25` no `1.25`).
3. Aplicar el bug Unicode preventivamente al `task.name` si contiene `↔ ⟷ → ←` o terminaciones `-ción + acento` problemáticas.
4. Escribir con `ZohoSheet_set_content_to_multiple_cells` directamente sobre filas vacías de Data (empezando en fila 2). **Trocear ≤ 40 celdas/llamada.**
5. La fórmula SUMAR.SI de fábrica de Tabla2 y Tabla21 propaga automáticamente.

**Validación final**: leer K[fila] de cada producto del plan y de cada huérfana; comprobar que coincide con la suma de entries de ese task.

**Cuándo NO usar modo minimalista**: si el PO solicita explícitamente auditoría de tags, custom fields, time_estimate por persona u otro análisis de las 58 columnas, escalar a las opciones A/B/C/D del flujo clásico (caso especial documentado más abajo).

---

#### 📜 Modo clásico (caso especial) — pegado completo de 58 columnas

⚠️ **Caso especial documentado**: solo aplicar cuando se necesita auditoría completa de las 58 columnas (custom fields, tags, time_estimate, status histórico, etc.). Para revisiones diarias y semanales del flujo normal, usar el modo minimalista de arriba.

#### Sub-paso 3a — Inspeccionar el estado actual de Data

Antes de tocar nada, inspeccionar la pestaña `Data` con `ZohoSheet_get_used_area` y `ZohoSheet_list_all_tables` para detectar:

- Cuántas filas tiene actualmente (excluida cabecera).
- Si tiene una tabla definida (típicamente `Tabla1`) y cuál es su rango.
- Si el contenido parece time entries del sprint actual, time entries de un sprint anterior, o datos de otro tipo (tasks, agregados, listados de referencia).

#### Sub-paso 3b — Confirmar con el PO cómo proceder

> 🤖 **OVERRIDE 2 DESATENDIDO (ver PASO 0 BIS): NO ejecutar este sub-paso de forma supervisada.** En modo desatendido, saltar directamente al Sub-paso 3d (Opción D — refresco incremental quirúrgico) sin presentar opciones al PO. Las cuatro opciones A/B/C/D y la lógica de "esperar elección del PO" que sigue documentadas aquí son contexto histórico de la skill supervisada. Aplican únicamente si esta skill se invoca manualmente con humano delante (caso degenerado, ver frontmatter).

Presentar el estado actual al PO y proponer una de cuatro acciones:

```
Pestaña Data — estado actual:
  - [N] filas pobladas
  - Tabla [Tabla1] con rango [start_row]:[end_row]
  - Muestra: [primera/última fila para que el PO identifique el contenido]

¿Cómo procedemos?

  (A) Borro yo el contenido actual de Data y pego los time entries del sprint (refresco completo).
  (B) Borras tú el contenido manualmente y luego me avisas para que pegue los nuevos.
  (C) Data ya tiene los time entries correctos del sprint actual y no hay que tocarla.
  (D) Refresco incremental quirúrgico: solo pego las entries nuevas posteriores al último timestamp registrado, sin tocar las filas existentes (preferido para revisiones diarias o semanales muy frecuentes con pocos entries nuevos).
```

- Si el PO elige **(C)**, la skill verifica con `=SUMA(BE2:BE[última])` que las horas trackeadas coinciden con `clickup_get_time_entries` del rango del sprint y, si cuadran, salta al Paso 4 sin tocar Data.
- Si el PO elige **(B)**, la skill espera la confirmación del PO antes de continuar.
- Si el PO elige **(A)**, la skill ejecuta el sub-paso 3c.
- Si el PO elige **(D)**, la skill ejecuta el sub-paso 3d (refresco incremental).

##### Cuándo elegir cada opción

| Opción | Caso típico | Tiempo aproximado |
|---|---|---|
| **(A)** Refresco completo | Primera revisión del sprint o si han pasado varios días sin actualización | ~30 min/AUTOIA |
| **(B)** PO borra manual | Si el PO prefiere validar el borrado a mano antes de que la skill pegue | Variable |
| **(C)** Data ya correcto | Re-ejecución muy reciente que solo quiere recalcular cuadre | <5 min/AUTOIA |
| **(D)** Refresco incremental | Hay 1-5 entries nuevas posteriores al último registro y la persona ha trabajado en pocos productos nuevos. Validado en sesión real con Alejandro Sprint 5-26 (1 entry nueva 1,5h) | ~5 min/AUTOIA |

#### Sub-paso 3c — Vaciar Data y pegar entries (acción automatizada)

1. **Anotar en Log de Cambios**: `[timestamp] | DATA_CLEAR | Vaciado de hoja Data antes de pegar registros sprint actual | [N] filas | 0 filas`.
2. **Vaciar** con `ZohoSheet_clear_contents_of_range` el rango `A2:BD[última fila]`. Esto preserva la cabecera (fila 1) y la estructura de Tabla1 si existe.
3. **Verificar el estado de Tabla1**: con `ZohoSheet_list_all_tables` comprobar si la tabla sigue existiendo y su rango. Si Tabla1 ha quedado con un rango antiguo inconsistente con los datos vacíos, se ajustará al pegar los nuevos entries (Zoho Sheet típicamente extiende la tabla automáticamente al pegar dentro de su rango).

   ⚠️ **Aviso crítico — encabezado de Tabla1**: la fila 1 de `Data` (encabezado) tiene formato definido por la plantilla maestra y validado con el PO en piloto 06/05/2026:
   - Fondo: `#FFFFFF` blanco
   - Fuente: Manrope **bold**
   - Color de fuente: `#3812CF` (azul/lila Reinicia)
   - Borde inferior: `solid` color `#3812CF`

   **NO sobrescribir este formato en ningún paso de la skill**. Si por necesidad operativa hay que recrear Tabla1 (eliminar y volver a crear, ej. para extender el rango tras refresco completo), capturar el formato del encabezado ANTES de eliminar y reaplicarlo DESPUÉS. Lo más prudente y eficiente es **no eliminar Tabla1 nunca** — extender el rango con `insert_row` o dejar que se autoextienda al pegar dentro.
4. **Pegar registros** en lotes de ~5-10 filas / ~3000 chars vía `worksheet.csvdata.set` empezando en fila 2 (la API soporta hasta ~5000 chars pero conviene mantenerlo conservador para evitar timeouts).
5. **Verificar Tabla1 post-pegado**: confirmar que el rango cubre todas las filas pegadas. Si no, reextender la tabla manualmente.
6. **Aplicar fórmula `Horas Traqueadas`** en col 57 fila 2 si no estaba ya (`=Tabla1[@Column11]/3600000`). La tabla la propaga automáticamente a las demás filas.
7. **Verificar suma**: `=SUMA(BE2:BE[última])` ≈ total ClickUp.
8. **Anotar en Log de Cambios**: `[timestamp] | DATA_PASTE | Pegado de N entries del sprint en Data | 0 filas | N filas | Total horas: [X]h`.

#### Cabeceras canónicas de Data (58 columnas)

```
Column1, Column2, Column3, Column4, Column5, Column6, Column7, Column8, Column9, Column10, Column11, Column12, Column13, Column14, Column15, Column16, Column17, Column18, Column19, Column20, Task Status, Due Date, Due Date Text, Start Date, Start Date Text, Task Time Estimated, Task Time Estimated Text, Task Time Spent, Task Time Spent Text, User Total Time Estimated, User Total Time Estimated Text, User Total Time Tracked, User Total Time Tracked Text, Tags, Checklists, User Period Time Spent, User Period Time Spent Text, Date Created, Date Created Text, Custom Task ID, Parent Task ID, AVANCE DE PRODUCTO, Sobrepasado, Tiempo Registrado Mayor que Estimado, Tiempo restante, CLIENTE, PO, REFINADO, TIPO DE PRODUCTO, OBJETIVO/NECESIDAD, PBIs PRIMER NIVEL, ÉPICA, ORDEN, Álvaro Estima, ID Propuesta, NOTAS PARA CLIENTE, Horas Traqueadas, Situación
```

Donde:
- `Column11` = Duration en ms (clave para fórmula `Horas Traqueadas`)
- `Column20` = Concepto = nombre de la tarea ClickUp (clave para SUMAR.SI)
- `Horas Traqueadas` (col 57) = `=Tabla1[@Column11]/3600000`

#### Estructura resumen de los datos pegados

| Col | Contenido |
|---|---|
| 1-19 | Datos del time entry (id, fechas, descripción, usuario, duración en ms, etc.) |
| 11 | Duration en ms (Column11) |
| 20 | **Concepto** = nombre de la tarea (Column20) ← **clave para SUMAR.SI** |
| 21+ | Status, Due Date, custom fields, tags, etc. |
| 57 (BE) | **Horas Traqueadas** = `=Tabla1[@Column11]/3600000` |

#### Caveats al pegar entries

- **Caracteres especiales en descripciones**: acentos, comillas, signos `+`. Al construir el CSV, escapar con comillas dobles. El motor de Zoho convierte `+` a espacio en algunos contextos (ej. timestamps Form Submission) — ver Bug 3 de la sección de bugs al final de la skill.
- **Timestamps**: vienen en ms epoch desde ClickUp. La columna `Horas Traqueadas` los convierte a horas decimales con fórmula.
- **Filas vacías intermedias**: si un lote falla a mitad, no continuar pegando hasta diagnosticar — reanudar con el lote completo desde el principio.

#### Registro en Log de Cambios

| Operación | Caso |
|---|---|
| `DATA_CLEAR` | Vaciado de Data (sub-paso 3c) |
| `DATA_PASTE` | Pegado de entries en Data (sub-paso 3c) |
| `DATA_PASTE_INCREMENTAL` | Pegado incremental de entries nuevas (sub-paso 3d) |

#### Sub-paso 3d — Refresco incremental quirúrgico (acción automatizada)

**Cuándo aplicar**: el PO ha elegido opción (D). Hay pocas entries nuevas y se quiere preservar el contenido existente (más rápido y menos invasivo). Validado con Alejandro Sprint 5-26: 1 entry nueva de 1,5h, refresco en ~5 minutos vs ~30 minutos del completo.

##### Procedimiento

1. **Identificar último timestamp en Data**: leer la columna fecha del time entry más reciente registrado (Column9 o Column10 según mapeo).
2. **Recopilar SOLO time entries posteriores** a ese timestamp con `clickup_get_time_entries` desde `last_timestamp + 1ms` hasta `now`.
3. **Si no hay entries nuevas**: aceptar (D) como equivalente a (C) y saltar al Paso 4.
4. **Si hay N entries nuevas**:
   - Calcular fila de inserción: `last_row + 1` (final actual de Tabla1).
   - Pegar las N nuevas filas vía `worksheet.csvdata.set` empezando en esa fila.
   - Verificar extensión de Tabla1 (Zoho propaga automáticamente al pegar dentro o justo después del rango).
   - Verificar suma global `=SUMA(BE2:BE[última])` ≈ total ClickUp.
5. **Anotar en Log de Cambios**: `[timestamp] | DATA_PASTE_INCREMENTAL | Pegado incremental N entries posteriores a [last_timestamp] | Total horas pegadas: [X]h | Total Data ahora: [Y]h`.

##### Cuándo NO usar el modo incremental

- Si el cuadre Data vs ClickUp YA estaba KO antes de la última inserción → ir a refresco completo (A).
- Si han ocurrido cambios en entries existentes (ej. PO ha modificado una entry pasada) → ir a refresco completo (A).
- Si la cabecera de Data ha cambiado de versión → ir a refresco completo (A).

### PASO 4 — Análisis de huérfanas y validación de emparejamientos

Se detectan los **conceptos en Data!Column20 que NO están en Tiempos!Concepto**.

#### Clasificación automática por keywords

| Grupo | Keywords / Heurística (mayúsculas) | Marca Col A | Destino |
|---|---|---|---|
| **A** Metodología y Gestión | `DAILY`, `SPRINT PLANNING`, `REFINAMIENTO`, `RETROSPECTIVE`, `GESTI` (matchea "Gestión", "Gestion"), `[REINICIA] FORMACIÓN`, `FORMACIÓN ZOHO` | (sin marca — se sitúa en bloque propio fuera de Tabla2) | Bloque "Metodología y Gestión" APARTE, después del TOTAL de Tabla2 |
| **B** Todo lo demás | Resto de conceptos no planificados | (ver sub-marcas abajo) | DENTRO de Tabla2, antes del TOTAL ESTIMADAS |

Sub-marcas dentro del Grupo B (columna A):

| Sub-marca | Heurística | Casos típicos |
|---|---|---|
| `🤖 Fuera de plan` | Producto digital nuevo no contemplado en planning, con corchete de cliente, estructura de producto reconocible | SPIKEs no planificados, productos cliente nuevos, gestiones cliente del mes (`Gestión abril 2026 [CLIENTE]`), gestiones internas Reinicia (`Gestión Reinicia TODOS [Mes]`), incidencias específicas (`Incidencia conector...`), productos en validación que entran fuera de plan |
| `🤖 Soporte/WIP` | Microtarea reactiva, prefijo `[SUPPORT]` o `[ASSUMED IN THE GUARANTEE]`, `[BUG]`, `Form Submission` en el nombre, o tarea de muy corta duración sin estructura de producto | Tickets de soporte vía formulario ClickUp, Form Submissions, BUGs reportados |

⚠️ Nota crítica sobre conceptos que empiezan por `Gestión` o `Refinamiento`: NO todos van al Grupo A. La regla operativa es:
- Ceremonias con sufijo `[METODOLOGÍA REINICIA]` (`Daily 2026`, `Sprint Planning 2026`, `Retrospective 2026`) → **Grupo A**
- Refinamientos del equipo (`Refinamiento 2026 [INEFSO]`, `Refinamiento 2026 [GONHER]`, etc. — donde el corchete identifica al equipo, no al cliente) → **Grupo A**
- `[REINICIA] Formación Zoho` y formaciones internas similares → **Grupo A**
- `Gestión [Mes] 2026 [CLIENTE]` (gestión mensual de un cliente concreto) → **Grupo B `🤖 Fuera de plan`**
- `Gestión Reinicia TODOS [Mes] 2026 [REINICIA]` (gestión interna del equipo Reinicia) → **Grupo B `🤖 Fuera de plan`**

La keyword `GESTI` del Grupo A se reserva a las ceremonias con sufijo `[METODOLOGÍA REINICIA]` o `[REINICIA]`. En caso de duda, preguntar al PO.

#### Caso ambiguo

Si la skill no encuentra match claro de keyword:

1. **Preguntar al PO líder**: "He encontrado el concepto huérfano `[X]` con `[Y]h` traqueadas. ¿Lo clasifico como A (Metodología/Gestión, va APARTE), B-Fuera de plan (producto digital, va DENTRO de Tabla2) o B-Soporte/WIP (microtarea reactiva, va DENTRO de Tabla2)?"
2. **Tras la respuesta, proponer mejorar la skill** con la nueva regla de clasificación: "Te propongo añadir keyword `[Z]` al Grupo `[X]` en la skill. ¿Lo hago?"
3. Si el PO acepta, **registrar el cambio propuesto** para incluirlo al final como entrada en "Mejoras Propuestas Skill Sprint Backlog: documentar en Reinnova ClickUp" del Informe Ejecutivo del Equipo correspondiente.

#### Renames de Tiempos (concepto del plan ≠ concepto de ClickUp)

> 🤖 **OVERRIDE 3 DESATENDIDO (ver PASO 0 BIS): aplicar política Opción B canónica del PO líder.** NO presentar candidatos al PO. Aplicar automáticamente renames TRIVIALES (mismo cliente + distancia textual ≤5 + sin ambigüedad) y NO aplicar nada con renames NO triviales — dejarlos como pendientes en Log de Cambios + Col N de la fila del plan + reporte Cliq final. Todo el contenido que sigue (presentación al PO, "valida uno a uno", "valida explícitamente") es contexto histórico de la skill supervisada. Mantenerlo como referencia algorítmica de los criterios pero saltarse la interacción.

A veces el plan inicial usa nombres "humanos" que no coinciden exactamente con el nombre canónico en ClickUp. Otras veces, en cambio, **un nombre similar corresponde a un producto distinto** y NO debe renombrarse. La skill propone emparejamientos pero **NO aplica nada hasta validación explícita del PO**.

#### Detección de candidatos a rename

Comparar cada concepto del Sprint Backlog principal con los conceptos de Data!Column20 buscando similitudes textuales: caracteres distintos en puntuación, espacios, corchetes, guiones, mayúsculas/minúsculas, acentos, prefijos/sufijos opcionales (`[SUPPORT]`, `[BUG]`, etc.).

> 🤖 **v1.7 — Robustez de match ANTES de marcar `TIEMPOS_RENAME_PENDIENTE`.** Antes de concluir que un concepto del plan y un nombre de Data son cosas distintas:
> 1. **Normaliza K a la canónica de la fila**: `=SUMIF(Table1[[#All];[Column20]];Tabla2[@Concepto];Table1[[#All];[Horas Traqueadas]])`. ⛔ Nunca dejes rangos A1 truncados (p.ej. `$Data.$T$2:$T$33`): dan **K=0 falso** cuando la entry cae fuera del rango clavado — eso NO es un rename. (Caso real Óscar Díez f15 Sprint 7-26: concepto idéntico a Data pero K=0 por rango `$T$2:$T$33`; las entries estaban en filas ~60/67.)
> 2. **Carácter invisible**: si el concepto de Tiempos y un nombre de Data se ven idénticos pero SUMAR.SI=0, normaliza a NFC/ASCII (espacios especiales, guiones no-ASCII) y reescribe el literal antes de concluir mismatch.
> 3. **Detección SIMÉTRICA**: tras normalizar espacios, marca candidato a rename cuando el concepto del plan sea substring **o** superstring del nombre de la tarea — cubre tanto el sufijo añadido (`Modelo de Datos` → `Modelo de Datos [AICROV]`) como el **prefijo/cualificador** (`Implementación Modelo de Datos` ⊃ `Modelo de Datos`). (Caso real José f21 Sprint 7-26: el detector v1.6 solo pillaba "ClickUp = Tiempos + sufijo" y se le escapó el prefijo → acabó `PRODUCTO_NO_RESUELTO` + huérfana duplicada.)
> 4. **Actuación (desatendido)**: solo flaggear `TIEMPOS_RENAME_PENDIENTE` y acumular para el reporte Cliq — **nunca auto-fusionar**. La fusión la propone la supervisada al PO.

#### Presentación al PO — propuesta y antipropuesta

Cada candidato se presenta con:

1. **Concepto del plan** (en Tiempos)
2. **Concepto candidato en Data** (que se propone como rename)
3. **Horas reales que se recuperarían si el rename se aplica**
4. **⚠️ Verificación previa**: la skill comprueba si en Data hay también **otra entrada distinta del candidato** que podría ser un producto independiente con el mismo cliente. Si la hay, se avisa explícitamente.

Formato de presentación:

```
He detectado posibles renames en Tiempos. Por favor, valida uno a uno:

✅ Caso 1 — Rename limpio (sin ambigüedad detectada):
  Fila 6 plan: "Despliegue Guadalajara y CDMX GONHER"
  Candidato Data: "Despliegue Guadalajara y CDMX [GONHER]"
  Diferencia: corchete de cliente.
  Recuperaría: 5,47h
  ¿Renombro?

⚠️ Caso 2 — Posible producto distinto:
  Fila 5 plan: "Despliegue Guadalajara y CDMX [GONHER]"
  Candidato Data: "Despliegue Guadalajara y CDMX 2 [GONHER]"
  Recuperaría: 4,12h
  PERO en Data también existe el literal exacto "Despliegue Guadalajara y CDMX [GONHER]"
  con 8,23h. Esto sugiere que son DOS productos distintos del mismo cliente.
  ¿Confirmas que son productos separados (no renombrar) o que son el mismo (renombrar)?
```

#### Criterios para NO renombrar

El PO debe rechazar el rename cuando:

1. **Existen ambos literales en Data**: el concepto del plan y el candidato aparecen simultáneamente como entradas independientes en Data!Column20. Esto indica dos productos distintos con nombres similares.
2. **El "rename" cambia el alcance del producto**: ej. añadir `[SUPPORT]` al inicio o `2` al final puede ser una microtarea relacionada pero no la misma. La skill **debe preguntar siempre** antes de añadir prefijos `[SUPPORT]` o sufijos numéricos.
3. **El cliente del corchete cambia**: nunca renombrar entre conceptos con corchetes de cliente distintos (`[GONHER]` vs `[CARRITECH]`).
4. **El PO así lo decide** por contexto que la skill no puede inferir (decisiones de producto, separación intencional de fases, etc.).

#### Casos validados de NO rename (sesión real Sprint 5-26)

- Johanna: `Despliegue Guadalajara y CDMX` (Row 5 plan) NO se renombra a la versión que aparece en Data — son tareas distintas según criterio del PO.
- Alejandro: casos 5 y 6 propuestos por la skill rechazados por el PO — productos distintos con nombres parecidos.

#### Conceptos cortados en plan vs nombre largo en ClickUp (lección Sprint 5-26)

A veces el PO escribe una **versión corta y orientativa** del nombre en el plan inicial, mientras ClickUp tiene el **nombre completo y descriptivo** (a veces de 100-200 caracteres). Caso real: en Johanna Sprint 5-26 una fila del plan ponía simplemente `Meter campo Oficina`, mientras la tarea en ClickUp se llamaba algo similar a `Meter campo "Oficina" en módulos de Posibles Clientes, Contactos y Cuentas para que se rellene automáticamente al asignar propietario y...` (152 caracteres).

**Procedimiento recomendado**:

1. **Renombrar al canon completo** de ClickUp en la celda Concepto del plan, copiando el literal exacto desde la hoja activa (Data o Data Entries). Esto facilita futuros matches y evita reincidencias.
2. **Si el literal es muy largo** (>100 caracteres) y romper el wrap visual del plan es un problema: en lugar de pegar el literal directamente, **referenciar la celda fuente** vía fórmula:
   ```
   ='Data Entries'!T9
   ```
   donde `T9` es la fila del entry concreto en Data Entries. Esto preserva visualmente la celda corta pero garantiza match exacto vía SUMAR.SI.
3. **Validar con `=COINCIDIR(D[fila];'Data Entries'!$T$2:$T$N;0)`** que el match se produce. Si devuelve `#N/A!`, hay diferencia textual no visible (NFC/NFD, espacios, etc.).
4. **Aplicar como rename normal** previa validación del PO.

#### Aplicación del rename

⚠️ **Nunca aplicar un rename sin validación explícita del PO emparejamiento por emparejamiento.** Cada rename aprobado se registra en Log de Cambios:

```
[timestamp] | TIEMPOS_RENAME | Tiempos!D[fila] | "[antes]" | "[después]"
```

Cada rename rechazado también se registra como referencia para futuras revisiones del mismo sprint:

```
[timestamp] | TIEMPOS_RENAME_RECHAZADO | Tiempos!D[fila] | "[antes propuesto]" | "[concepto Data candidato]" | Motivo: [productos distintos / decisión PO / etc.]
```

#### Bug operativo: timestamps con `+`

Cuando se renombra un concepto que contiene un timestamp tipo `#2026-03-26T06:09:13+01:00`, hay que escribir el literal **sin `+`** (`#2026-03-26T06:09:13 01:00`) porque el motor de Zoho Sheet pierde el `+` al procesar la entrada de la fórmula SUMAR.SI. Verificar con `=COINCIDIR` que el match se produce. Detectado en sesión real con Fabián Sprint 5-26.

### PASO 5 — Inserción de huérfanas Grupo B en Tabla2

⚠️ **Operación destructiva**. Registrar antes en Log de Cambios.

#### 🆕 Modo simplificado plantilla nueva (v3.3) — `set_content_to_cell` directo

Para AUTOIAs Sprint 6-26+, la plantilla nueva trae filas vacías formateadas en Tabla2 (típicamente filas 4 a 63, con cabecera fila 3). **No es necesario `insert_row`**: las huérfanas se escriben directamente en la primera fila vacía disponible.

**Procedimiento simplificado**:

1. Identificar la primera fila vacía de Tabla2 leyendo Col E (Concepto) desde el final del plan hacia abajo. Típicamente las huérfanas empiezan tras la última fila ocupada del plan + bolsas de Soporte.
2. Escribir cols A, D, E, F, G, H, M, N con `set_content_to_multiple_cells` (ver tabla de campos obligatorios en la sección **HUÉRFANAS — DATOS OBLIGATORIOS DESDE CLICKUP**).
3. La fórmula SUMAR.SI de Col K, la fórmula de Col L (Diferencia) y el calendario en O-AJ se propagan automáticamente desde el formato heredado.
4. Validar inmediatamente con `get_content` de Col K para confirmar que el match SUMAR.SI funciona. Si K=0,00 inesperado, aplicar el procedimiento del bug Unicode (ver sección correspondiente).

**Solo si se agotan las filas vacías**: escalar al procedimiento clásico (`insert_row` antes de la penúltima fila para heredar formato). Esto es muy raro en sprints normales — Tabla2 suele tener 60+ filas vacías.

**Validación post-inserción**: leer Col A para confirmar la sub-marca canónica (`🤖 Fuera de plan` o `🤖 Soporte/WIP`). NO inventar otros textos.

---

#### 📜 Modo clásico (caso especial) — `insert_row` con preservación de rango Tabla2

⚠️ **Caso especial documentado**: solo aplicar cuando la plantilla está saturada (sin filas vacías) o el AUTOIA es Sprint 5-26 o anterior con estructura sin pre-formato.

#### Posición de inserción

🚨 **Regla crítica**: las huérfanas Grupo B se insertan SIEMPRE DENTRO del rango actual de Tabla2, en una posición intermedia que respete los siguientes criterios:

**Posición permitida**:
- Entre `Tabla2.start_row + 2` (segunda fila después de la cabecera) y `Tabla2.end_row - 1` (penúltima fila rellena de la tabla).
- NUNCA en la primera fila de datos, NUNCA en la última fila rellena, NUNCA fuera del rango de Tabla2.

**Por qué importa**:
1. **Tabla2 se extiende automáticamente** y las nuevas filas quedan incluidas en SUMA, SUMAR.SI y demás fórmulas de totales.
2. Las nuevas filas **heredan formato y fórmulas** de las filas adyacentes (Col K diferencia, validaciones de fechas, colores alternos, bordes).
3. La fila TOTAL ESTIMADAS, TOTAL DISPONIBLES y TOTAL BALANCE recalculan correctamente.

**Separación visual mínima**:
- 1 fila vacía DENTRO de Tabla2 ANTES del bloque de huérfanas.
- 1 fila vacía DENTRO de Tabla2 DESPUÉS del bloque de huérfanas.
- Esto separa visualmente el bloque de huérfanas del resto del plan original.

#### Cómo elegir la posición — algoritmo

1. **Consultar el rango actual de Tabla2** con `ZohoSheet_list_all_tables` (`start_row`, `end_row`).

2. **Buscar hueco existente** dentro del rango permitido (`start_row+2` a `end_row-1`):
   - Recorrer las filas y detectar zonas con N filas vacías consecutivas, donde N = número de huérfanas a insertar + 2 filas vacías de separación (1 antes + 1 después).
   - Si existe un hueco así, usarlo: pegar las huérfanas dejando una fila vacía libre antes y otra después.

3. **Si no hay hueco suficiente, crear filas**:
   - Elegir una posición intermedia dentro del rango permitido (típicamente justo después del último bloque de productos Reinicia internos, o en cualquier zona que no rompa un bloque temático existente).
   - Llamar `ZohoSheet_insert_row` (N + 2) veces consecutivas en la misma posición — N filas para las huérfanas + 2 filas vacías de separación.
   - Cada llamada inserta una fila vacía empujando el resto +1, y `Tabla2.end_row` se incrementa automáticamente.

⚠️ NO insertar:
- En `Tabla2.start_row + 1` (primera fila de datos — rompe coherencia visual).
- En `Tabla2.end_row` (última fila — quedaría como nueva penúltima sin separación).
- Fuera de Tabla2 (después de `end_row` o antes de `start_row`): la fila no se sumaría y habría que aplicar formato y fórmulas a mano.

#### Verificación post-inserción

Tras insertar las N filas:

1. Volver a llamar `ZohoSheet_list_all_tables` y confirmar que `Tabla2.end_row` se ha incrementado en (N + 2) — o (N) si se aprovechó un hueco existente.
2. Si `end_row` no creció lo esperado, alguna fila quedó fuera. Identificar cuáles y reinsertarlas correctamente. Bug detectado en sesión real (Alejandro Sprint 5-26): 4 huérfanas quedaron fuera de Tabla2 por inserción después de `end_row`.
3. Confirmar que las fórmulas SUMAR.SI propagan a las nuevas filas (Col K diferencia ya no aparece como `#VALUE!` ni en blanco). Si aparece `#VALUE!`, la celda Col J está como texto en lugar de número — reescribir con valor numérico (`0`, no `"0,00 horas"`).

#### Procedimiento

1. **Calcular `M = N + 2`** filas totales a insertar (N huérfanas + 2 filas de separación), salvo si se reutiliza un hueco existente.
2. **Insertar M filas físicas** llamando `ZohoSheet_insert_row` M veces consecutivas en la misma posición intermedia de Tabla2 (cada llamada empuja al resto +1).
3. **Verificar inmediatamente** que `Tabla2.end_row` creció en M.
4. **Pegar contenido** de las N huérfanas con `worksheet.csvdata.set` empezando en la segunda fila del bloque insertado (la primera queda como separador vacío). La última fila también queda vacía como separador.
5. **Verificar fórmulas SUMAR.SI** en Col J. Si Col K muestra `#VALUE!`, reescribir Col J con valor numérico `0` (no `"0,00 horas"` como texto).

Columnas a poblar en cada huérfana:

| Col A (Marca) | Col B (Orden) | Col C (Status) | Col D (Concepto) | Col E (Cliente) | Col F (Estim) |
|---|---|---|---|---|---|
| `🤖 Fuera de plan` o `🤖 Soporte/WIP` | (vacío — Orden lo asigna Sprint Planning) | Status real ClickUp | Concepto exacto Data | Cliente extraído del corchete | Horas estimadas (regla abajo) |

⚠️ **Aviso crítico — column_index = 1 real**: la "Col A" en lenguaje de PO se refiere SIEMPRE a `column_index = 1` (la columna A real del worksheet), aunque esté oculta o aparezca vacía en plantillas donde la primera columna con datos visibles es B. NO confundir "primera columna con datos visibles" con "Col A": en la mayoría de Sprint Backlogs Reinicia, `column_index = 1` está reservada para esta etiqueta `🤖 ...` y es por eso que en plan original aparece vacía. Verificar siempre con `get_content_of_range` empezando en `start_column = 1` antes de escribir en una columna nominal. (Bug detectado en piloto Fabián 06/05/2026: etiquetas escritas erróneamente en `column_index = 2` desplazaron el contenido visualmente).

#### Regla para Col F (Horas estimadas) — Decisión pragmática

⚠️ **Nota crítica sobre `time_estimate` de ClickUp**: el `time_estimate` que figura en una tarjeta de ClickUp representa el **TOTAL del producto/microcampaña en TODAS las personas y en TODA su duración** (puede abarcar varios sprints). El estimado del Sprint Backlog Zoho es solo lo asignado **a esa persona en ese sprint concreto**. Por tanto, no se puede tomar `time_estimate` directamente como Col F sin matizar.

**Orden de prioridad para Col F en huérfanas:**

1. Si se puede obtener el **estimado-persona-sprint específico** (vía `User Total Time Estimated` de Data si está disponible, o desagregando custom fields por asignado y semana) → usar ese valor.
2. Si no, y el `time_estimate` general parece razonable para una sola persona en este sprint (ej. tarea pequeña asignada solo a esta persona) → usar `time_estimate`.
3. Si no, y los custom fields **Tiempo MIN** y **Tiempo MAX** están informados → usar `(MIN + MAX) / 2`.
4. Si nada de lo anterior → **Col F = horas reales traqueadas** (Col J), igualando estimado a lo ejecutado. Esto evita inflar el TOTAL ESTIMADAS con valores irreales.

#### 🚨 Alerta proactiva al PO sobre sobrecarga

Si una huérfana del **Grupo B con sub-marca `🤖 Fuera de plan`** (producto digital fuera de plan) trae una **estimación significativa** que supone una sobrecarga del Sprint, la skill emite alerta:

```
🚨 Alerta de sobrecarga detectada:

  El producto "[X]" (huérfano Grupo B) trae [N]h de estimación.
  Capacidad disponible del miembro: [Y]h
  Plan original: [Z]h
  Plan actualizado con huérfanas: [Z+N]h → sobrecarga de [(Z+N)-Y]h

  Recomendación: considera sacar productos del Sprint Backlog para abordar este nuevo esfuerzo,
  o reasignar a Amigos Reinicia.

  Esto se llevará al Informe Ejecutivo del Equipo [X].
```

Esta alerta se registra para que la consuma la skill de Informes Ejecutivos.

#### ⚠️ Aviso de productos sin estimación

Si una huérfana del **Grupo B con sub-marca `🤖 Soporte/WIP`** tiene `time_estimate = null` y `MIN/MAX = null`, **es una violación de la norma Reinicia**: no se debería empezar trabajo de Soporte sin estos campos. Listar todos al final del proceso para que el PO los revise:

```
⚠️ Productos sin estimación informada (norma Reinicia incumplida):
  - [task_id] | [lista] | [nombre]
  - ...
```

#### Patrón especial: producto plan agregado + desglose individual paralelo

Algunos productos del Sprint Backlog son **agregados intencionales**: el plan los crea como una bolsa de horas para englobar múltiples microtareas que se irán recibiendo a lo largo del sprint. Ejemplos típicos:

- `Soporte Carritech` (8h estim) — bolsa que engloba todos los SUPPORT/ASSUMED del sprint
- `Soporte INEFSO` (4h estim) — equivalente para INEFSO
- `Soporte Breezom`, `Soporte Mazarea`, etc.
- `Microcampañas [CLIENTE]` cuando se reservan horas para campañas no especificadas aún

Cuando llegan huérfanas individuales que claramente pertenecen a uno de estos agregados (por ejemplo, `[SUPPORT] Networking equipment [CARRITECH] - Form Submission - #...` pertenece a `Soporte Carritech`), hay dos opciones:

**Opción A — Mantener solo el agregado**: actualizar las horas reales del agregado (vía SUMAR.SI con criterio amplio o sumando manualmente) y NO insertar las individuales como huérfanas. Pros: menos filas. Contras: no hay trazabilidad de qué incidencias concretas se atendieron.

**Opción B — Agregado + desglose individual paralelo (PREFERIDA)**: mantener la fila agregada con sus horas estimadas originales, pero **vaciar Col J a `0` numérico** para evitar duplicación, y **insertar las N microtareas individuales como huérfanas Grupo B con sub-marca `🤖 Soporte/WIP`** dentro de Tabla2. Las individuales se cargan con sus horas reales vía SUMAR.SI canónica y `F = 0` (sin estimación porque son tareas que entraron sin estimar individualmente).

##### Por qué Opción B es preferida (validado con PO el 03/05/2026)

1. **Trazabilidad completa**: queda registrado en el Sprint Backlog cada incidencia concreta atendida, con sus horas reales. Útil para revisión con cliente y para informes ejecutivos.
2. **Comparación estimación vs realidad**: el agregado conserva su estimación inicial (ej. 8h), y las individuales muestran el consumo real desglosado (ej. 12,68h en 8 microtareas). La diferencia entre Col F del agregado y la suma de horas reales de las individuales es información valiosa para replantear la bolsa de horas en el próximo sprint.
3. **No se duplican horas**: la fila agregada tiene Col J = 0 (no suma horas reales), así que el TOTAL DISPONIBLES de Tabla2 no las cuenta dos veces. Las horas reales solo se contabilizan en las filas individuales.

##### Procedimiento

1. **Identificar el agregado**: detectar conceptos en el plan original que tienen formato `Soporte [CLIENTE]`, `Microcampañas [CLIENTE]` o equivalentes.
2. **Detectar huérfanas que pertenecen al agregado**: filtrar conceptos en Data!Column20 que coincidan con la heurística del agregado (ej. para `Soporte Carritech`: conceptos con prefijo `[SUPPORT]` o `[ASSUMED IN THE GUARANTEE]` y corchete `[CARRITECH]`).
3. **Confirmar con el PO** la opción a aplicar (A o B). Por defecto, proponer Opción B.
4. **Si Opción B**:
   - **Vaciar Col J del agregado**: escribir `0` numérico (no `"0,00 horas"` como texto, porque rompe la fórmula de Col K). Verificar que Col K recalcula correctamente (debe mostrar `[F] horas` sin `#VALUE!`).
   - **Col L (Motivo desvío) del agregado: VACÍA**. Razonamiento: con J=0 y G=8h, `Col K = G - J = +8h` (positivo, no hay desvío), así que la regla de "Motivo solo si J > G" del Paso 7 aplica y la celda queda vacía. NO escribir "NO SE TOCA" (no es motivo válido del catálogo).
   - **Col M (Comentario) del agregado**: "Producto agregado del soporte [CLIENTE]: estim [F]h. Las horas reales se desglosan en huérfanas B individuales (N microtareas) por trazabilidad."
   - **Insertar las N huérfanas individuales** siguiendo el procedimiento estándar del Paso 5 (sub-marca `🤖 Soporte/WIP`, `F = 0`, SUMAR.SI canónica en Col J).
   - **Col L de cada huérfana individual: VACÍA**. Las huérfanas Soporte/WIP tienen F=0 y J=horas reales, así que K = -J (negativo solo si J>0). Sin embargo, "NO ESTIMADO" sería el motivo del catálogo aplicable si J>0 — proponer al PO en el Paso 7 con sugerencia automática `NO ESTIMADO` para estas filas.
   - **Col M de cada huérfana individual** (opcional, comentario explicativo): "Huérfana B (Soporte [CLIENTE]). Desglose individual del producto agregado 'Soporte [CLIENTE]' (fila [N])."
5. **Registrar en Log de Cambios** ambas operaciones.

##### Reflejo en cuadre matemático

El Total Disponibles de Tabla2 sigue cuadrando con ClickUp porque:
- El agregado aporta `0h` reales (Col J vacía).
- Las N individuales aportan sus horas reales vía SUMAR.SI.
- La estimación del agregado (Col F) se sigue contando en TOTAL ESTIMADAS, lo cual es correcto: el plan inicial reservó esa bolsa de horas.

### PASO 6 — Bloque "Metodología y Gestión" (Grupo A) APARTE de Tabla2

#### 🆕 Plantilla nueva Sprint 6-26: usar Tabla21 canónica (v3.3)

Desde el Sprint 6-26, la plantilla nueva trae **`Tabla21` predefinida** como tabla formal en `Tiempos`, con cabecera en filas 78-80 (según fichero) y ~12 filas vacías formateadas listas para escribir. **Ya no se construye manualmente** el bloque Metodología.

#### 🆕 Estructura de Tabla21 — Bloque A + separador + Bloque B (v3.3 Día 2)

⚠️ **Regla añadida en Sprint 6-26 Día 2**. La Tabla21 se organiza en **dos bloques visualmente separados** dentro de la misma tabla formal:

```
Tabla21 (cabecera fila 78-79 según fichero)

  ┌─ BLOQUE A — METODOLOGÍA PURA ──────────────────────┐
  │ Sprint Planning 2026 [METODOLOGÍA REINICIA]        │  Col J = "No"
  │ Retrospective 2026 [METODOLOGÍA REINICIA]          │  Col J = "No"
  │ Daily 2026 [METODOLOGÍA REINICIA]                  │  Col J = "No"
  │ Daily 2026 [CLIENTE]                               │  Col J = "No"
  │ Refinamiento 2026 [METODOLOGÍA REINICIA] o [CTE]   │  Col J = "Sí" ← excepción
  │ Gestión Reinicia TODOS [Mes] [REINICIA]            │  Col J = "No"
  └────────────────────────────────────────────────────┘

  [FILA VACÍA SEPARADORA]  Todas las celdas vacías, incluida Col J

  ┌─ BLOQUE B — GESTIONES CLIENTE ─────────────────────┐
  │ Gestión [Mes] 2026 [CLIENTE 1]                     │  Col J = "Sí"
  │ Gestión [Mes] 2026 [CLIENTE 2]                     │  Col J = "Sí"
  │ ...                                                │
  └────────────────────────────────────────────────────┘
```

**Reglas operativas**:

1. **Bloque A primero, Bloque B después**, siempre en este orden.
2. **Una sola fila vacía separadora** entre ambos bloques. Todas las celdas de esa fila vacías, incluido Col J.
3. **Solo poblar filas con tracking real**. No prefilar ceremonias del sprint anticipadamente.
4. **Col G (Horas estimadas) SIEMPRE vacía** en ambos bloques (ni ceremonias ni gestiones se estiman fila a fila).
5. **Col J obligatoria** según la matriz canónica de la sección "COLUMNA J FACTURABLE":
   - Bloque A: todas `"No"` excepto Refinamientos (`"Sí"`).
   - Bloque B: todas `"Sí"` (Gestiones Cliente son facturables).

**Si se agotan las filas vacías de Tabla21 (raro)**, insertar nuevas filas **antes de la penúltima** para heredar formato. Mantener el orden Bloque A → separador → Bloque B.

**Procedimiento simplificado**:

1. Identificar la primera fila vacía de Tabla21 (típicamente fila 79 o 80).
2. Por cada ceremonia trackeada (Sprint Planning, Retrospective, Daily, Refinement, Gestión Reinicia interna), escribir cols C, D, E, F, H, **J** en Bloque A:
   - Col C: `Sprint X-YY` (ej. `Sprint 6-26`)
   - Col D: Status (`DOING` típicamente)
   - Col E: Concepto canónico (ej. `Sprint Planning 2026 [METODOLOGÍA REINICIA]`, `Retrospective 2026 [METODOLOGÍA REINICIA]`, `Daily 2026 [GONHER]`, `Gestión Reinicia TODOS Mayo 2026 [REINICIA]`)
   - Col F: Cliente (`Reinicia` o el cliente específico para Daily de cliente)
   - Col H: Fecha límite si aplica (típicamente vacío para ceremonias)
   - **Col J: `"No"`** (excepto Refinamientos → `"Sí"`)
3. Después del último item del Bloque A, **dejar una fila vacía** (todas las cols incluido J vacías).
4. A continuación, en Bloque B, por cada Gestión Cliente trackeada escribir cols C, D, E, F, **J**:
   - Col C, D, E, F: análogo al Bloque A
   - **Col J: `"Sí"`** (Gestiones Cliente son facturables)
5. **Col G (Horas estimadas) SIEMPRE vacía** en todas las filas Tabla21. Las ceremonias y gestiones **NO se estiman fila a fila**: el total agregado del bloque ya viene por convención del Sprint Planning en `Tiempos!G93` (o `G94`). Aceptar que Col L (Diferencia) muestre el negativo del tracked (ej. `-2,3h`, `-1,5h`) — eso es el comportamiento esperado.
6. La fórmula SUMAR.SI de Col K (`Tabla21[@Concepto]` vs `Data!Column20`) propaga automáticamente.

**Total agregado en G93/G94**: viene de fábrica como referencia de capacidad consumida en metodología. NO se modifica.

---

#### 📜 Modo clásico (caso especial) — construcción manual del bloque

⚠️ **Caso especial documentado**: solo aplicar cuando el AUTOIA es Sprint 5-26 o anterior y no tiene Tabla21 canónica predefinida. Esta lógica se conserva como salvaguarda histórica.

#### Posición

Tras la tabla resumen del fichero (Horas totales / Operativas / Facturable / No Facturable), dejar **2 filas vacías de separador** y empezar el bloque a continuación.

Ejemplo de posición típica en un AUTOIA:
- Filas 56-58: TOTAL ESTIMADAS / DISPONIBLES / BALANCE de Tabla2
- Fila 60: encabezado tabla resumen ("Horas totales sprint")
- Filas 61-64: filas de la tabla resumen
- Filas 65-66: vacías (separador)
- Fila 67 en adelante: bloque Metodología y Gestión

#### Estructura del bloque

| Fila | Contenido | Formato |
|---|---|---|
| N (cabecera de sección) | `METODOLOGÍA Y GESTIÓN` en col C; cabeceras "CONCEPTO" en col D, "Horas estim" en col F, "Reales" en col J | Negrita, fill `#D9D0FB`, font `#3812CF` |
| N+1 a N+M | Una fila por concepto Grupo A | Sin marca en Col A (el bloque mismo identifica el grupo); Col D = Concepto exacto literal de Data!Column20 (sin `+` si el original lo tiene); Col F = `0` numérico; Col J = fórmula SUMAR.SI; Col K opcional (diferencia, casi siempre negativa) |
| N+M+1 (TOTAL) | `TOTAL METODOLOGÍA Y GESTIÓN` en col D; `=SUMA(J[N+1]:J[N+M])` en col J | Negrita, fill `#D9D0FB`, font `#3812CF` |

⚠️ **Sin marca en Col A**: a diferencia de las huérfanas Grupo B, los conceptos del Grupo A no llevan emoji `🤖` en columna A. La separación visual del bloque (cabecera + ubicación fuera de Tabla2) basta para identificarlos.

#### Regla para Col F (Horas estimadas) — siempre `0` numérico

⚠️ **Cambio de criterio respecto a versiones anteriores**: ya NO se usa "estimación retroactiva = horas reales". La columna F del bloque Metodología se rellena siempre con `0` numérico (no `"0,00 horas"` como texto, no vacío) por dos razones:

1. **Las ceremonias no estiman**: Daily, Sprint Planning, Retrospective y Refinamiento no tienen estimación previa porque son tiempo de equipo no asignado a un producto. Lo mismo aplica a la formación interna.
2. **Cuadre matemático limpio**: Col F del bloque Metodología no entra en TOTAL ESTIMADAS de Tabla2 (está fuera), pero sí afecta la diferencia local del bloque. Con F=0 la diferencia K es siempre negativa y refleja el tiempo real invertido — información útil que se traslada al informe ejecutivo.

⚠️ **Coma decimal en es-ES**: Zoho Sheet espera coma decimal al escribir números vía API (`set_content`). Punto decimal se interpreta como texto y rompe SUMA. Usar siempre `0`, nunca `0.0` ni `0.00`.

#### Aplicar fórmulas manualmente

Al estar fuera del bloque heredado de Tabla2, hay que escribirlas explícitamente celda a celda:

- **Col J (ClickUp Registro)**:
  ```
  =SUMAR.SI(Tabla1[[#All];[Column20]];D[fila];Tabla1[[#All];[Horas Traqueadas]])
  ```
  Referencia directa a la celda Concepto del bloque (`D68`, `D69`, etc.) — NO `Tabla2[@Concepto]` (esto solo funciona dentro de Tabla2 y aquí no aplica).

- **Col K (Diferencia)**, opcional:
  ```
  =F[fila]-J[fila]
  ```

- **TOTAL fila**:
  ```
  =SUMA(J[N+1]:J[N+M])
  ```

Donde `D[fila]`, `F[fila]`, `J[fila]` son las celdas con la letra de columna correcta del fichero (puede ser D o E para Concepto según el mapeo del Paso 1).

#### Verificación post-construcción

1. Confirmar que cada celda Col J del bloque devuelve un valor numérico (no `#NAME?` ni `0` por bug NFC/NFD ni texto plano).
2. Si una celda devuelve `0` y la suma de horas reales esperada para ese concepto en ClickUp es mayor:
   - Verificar bug NFC/NFD: usar fórmula `=COINCIDIR(D[fila];Tabla1[Column20];0)` en una celda auxiliar. Si devuelve `#N/A!`, hay diferencia textual no visible.
   - Verificar bug del `+` perdido: si el concepto contiene un timestamp con `+01:00` o `+02:00`, comprobar que el valor en Tabla1 (Data) tiene espacio en su lugar (`01:00` sin `+`). Reescribir el concepto en el bloque sin `+`.
3. Confirmar que `=SUMA(J[N+1]:J[N+M])` del TOTAL coincide con la suma esperada del bloque.

### PASO 6b — Mejoras de cierre canónico (v3.4)

⚠️ **Cuatro mejoras visuales y analíticas obligatorias** aplicadas al cierre del procesamiento de cada AUTOIA desde el Sprint 6-26 Día 10 (16/05/2026). Estas mejoras NO existen en la plantilla maestra todavía — la skill las aplica manualmente. Pendiente: incorporarlas a la plantilla maestra para que vengan de fábrica.

#### Adaptación al layout no normalizado de cada AUTOIA

🚨 **Cada AUTOIA tiene un layout posicional ligeramente distinto** en la pestaña `Tiempos`. La fila exacta donde está "TOTAL HORAS OPERATIVAS DISPONIBLES" y la cabecera "ACTIVIDADES METODOLOGÍA Y GESTIÓN" varía por persona:

| AUTOIA Sprint 6-26 | Fila "DISPONIBLES" (G capacidad / K tracked) | Cabecera "METODOLOGÍA Y GESTIÓN" |
|---|---|---|
| Fabián | Fila 65 | Fila 79 (pre Mejora 2) → 83 (post Mejora 2) |
| Paolo | Fila 63 | Fila 73 → 77 |
| José | Fila 69 | Fila 79 → 83 |
| Alejandro | Fila 69 | Fila 79 → 83 |
| Johanna | Fila 70 | Fila 80 → 84 |

**La skill NO debe asumir posiciones fijas**. Antes de aplicar las Mejoras 1-4, **mapear las posiciones reales del AUTOIA actual** con `get_content_of_range` en la zona 60-90 de Tiempos, identificando por etiqueta:
- Fila "TOTAL HORAS OPERATIVAS DISPONIBLES" → `fila_cap` (G = capacidad, K = tracked acumulado)
- Cabecera "ACTIVIDADES METOLOGÍA Y GESTIÓN" → `fila_metod_header`
- Fila "TOTAL HORAS METODOLOGÍA ESTIMADAS" → `fila_metod_estim`
- Fila balance Metodología actual (típicamente "TOTAL BALANCE DE HORAS" duplicada) → `fila_metod_balance`

A futuro, cuando se normalice la plantilla maestra, todas las posiciones quedarán idénticas y este mapeo dinámico se podrá eliminar. Mientras tanto, **mapeo dinámico siempre**.

---

#### Mejora 1 — Balance de Metodología corregido + semáforo

**Problema histórico**: la celda balance de Metodología (típicamente `G_fila_metod_balance`) mostraba `-X,XX` (resta `0 - estimadas`) en lugar del balance real `estimadas - tracked`. Bug detectado en los 5 AUTOIAs del Sprint 6-26.

**Solución**:

1. **Etiqueta D**: escribir `"TOTAL BALANCE  HORAS METODOLOGÍA Y GESTIÓN"` (con **doble espacio** literal entre "BALANCE" y "HORAS" — convención del PO líder) en `D_fila_metod_balance`.

2. **Fórmula G (balance real)**:
   ```
   =G_fila_metod_estim - VALOR(SUSTITUIR(SUSTITUIR(K_fila_tracked_metod;" horas";"");".";","))
   ```
   donde `K_fila_tracked_metod` es la celda de tracked acumulado del bloque Metodología (típicamente justo encima del balance, con valor tipo `"11,48 horas"`).

   ⚠️ Ver **Bug 10** para entender por qué el doble SUSTITUIR es necesario.

3. **Fórmula H (semáforo)**:
   ```
   =SI(VALOR(SUSTITUIR(SUSTITUIR(K_fila_tracked_metod;" horas";"");".";","))/G_fila_metod_estim>=1;"🔴 Excedido";
       SI(VALOR(SUSTITUIR(SUSTITUIR(K_fila_tracked_metod;" horas";"");".";","))/G_fila_metod_estim>0,75;"🟠 Atención";"🟢 OK"))
   ```

**Umbrales semáforo Metodología**:
- 🟢 OK: < 75% consumido
- 🟠 Atención: 75-99% consumido
- 🔴 Excedido: ≥ 100% consumido

**Validado en 5 AUTOIAs Sprint 6-26**: Fabián G98=21,83 🟢 OK, Paolo G96=14,32 🟢 OK, José G102=10,07 🟢 OK, Alejandro G102=18,02 🟢 OK, Johanna G103=24,20 🟢 OK.

---

#### Mejora 2 — Celdas auxiliares de fechas + semáforo proyectivo K_capacidad+1

**Propósito**: añadir un semáforo proyectivo en `K_(fila_cap+1)` que indique si el ritmo actual de imputación va a sobrepasar la capacidad del sprint al final del periodo, ANTES de que el sprint termine.

**Paso 1 — Insertar 4 filas auxiliares** con `row.insert` en el número de fila `fila_metod_header` repetido 4 veces (cada inserción desplaza la cabecera +1, así que 4 inserciones consecutivas en el mismo número crean 4 filas vacías ANTES de la cabecera).

Tras las 4 inserciones, `fila_metod_header` queda desplazada en +4, y también `fila_metod_estim`, `fila_metod_balance` etc. **Las fórmulas internas se autoajustan** — verificar con `get_content_of_range` que G/H del balance siguen referenciando correctamente.

**Paso 2 — Rellenar las 4 filas auxiliares insertadas** (que ahora ocupan las posiciones `fila_metod_header_pre_inserción` a `+3`):

| Fila relativa | Col C (etiqueta) | Col D (fórmula) | Valor esperado Sprint 6-26 |
|---|---|---|---|
| n | `Fecha inicio Sprint` | `=FECHA(2026;5;7)` | 07/05/2026 |
| n+1 | `Fecha fin Sprint` | `=FECHA(2026;5;27)` | 27/05/2026 |
| n+2 | `Días laborables totales Sprint` | `=DIAS.LAB(D_n;D_n+1)` | 15 |
| n+3 | `Días laborables transcurridos` | `=DIAS.LAB(D_n;MIN(HOY();D_n+1))` | (dinámico según HOY()) |

⚠️ Las fechas de inicio/fin del sprint se actualizarán en cada sprint nuevo. Mantener `FECHA(YYYY;MM;DD)` con los valores reales del sprint actual.

**Paso 3 — Escribir el semáforo proyectivo en `K_(fila_cap+1)`**:

```
=SI(K_fila_cap="";"";
   SI(VALOR(SUSTITUIR(SUSTITUIR(K_fila_cap;" horas";"");".";","))/D_n+3*D_n+2>=G_fila_cap;"🔴 Sobrepaso previsto";
      SI(VALOR(SUSTITUIR(SUSTITUIR(K_fila_cap;" horas";"");".";","))/D_n+3*D_n+2>=G_fila_cap*0,9;"🟠 Cerca del límite";
         "🟢 OK al ritmo actual")))
```

Lectura: `tracked / días_transcurridos * días_totales` = proyección al final del sprint, comparada con la capacidad.

**Umbrales semáforo proyectivo**:
- 🟢 OK al ritmo actual: proyección < 90% capacidad
- 🟠 Cerca del límite: proyección 90-99% capacidad
- 🔴 Sobrepaso previsto: proyección ≥ 100% capacidad

**Validado en 5 AUTOIAs Sprint 6-26 Día 10**: todos 🟢 OK al ritmo actual (entre 27% y 68% de utilización proyectada).

---

#### Mejora 3 — Pestaña "Motivos desvío" renombrada a "Leyenda" con 6 secciones

**Cambio estructural**: la pestaña histórica `Motivos desvío` (4ª pestaña canónica desde v3.2) pasa a llamarse **`Leyenda`** y se enriquece con 6 secciones documentales. El catálogo de motivos sigue siendo fuente de verdad, ahora como sección 5 dentro de un documento más completo.

**Procedimiento**:

1. **Renombrar pestaña**: `worksheet.rename` `old_name="Motivos desvío"` → `new_name="Leyenda"`.

2. **Borrar contenido viejo**: `delete_rows` filas 1-9 (las que contienen el viejo título + tabla de 5 motivos).

3. **Escribir contenido nuevo en 2 llamadas `cells.content.set`** (el contenido completo en una sola llamada da 414 Request-URI Too Large; dividir en ~22-23 celdas por llamada):

**Estructura del documento Leyenda** (las referencias a celdas como `K_fila_cap+1`, `H_fila_metod_balance`, etc. se adaptan al AUTOIA concreto):

| Fila | Col A | Col B | Col C |
|---|---|---|---|
| 1 | Título: `Leyenda — Sprint Backlog Reinicia` (merge A1:C1) | | |
| 2 | Subtítulo descriptivo (merge A2:C2) | | |
| 3-4 | (separadores) | | |
| 5 | `1. Semáforos visuales` (cabecera sección) | | |
| 6 | `Ubicación` (cabecera tabla) | `Qué mide` | `Umbrales` |
| 7 | `K_fila_cap+1 (junto a TOTAL HORAS OPERATIVAS DISPONIBLES)` | Explicación proyección | Umbrales semáforo proyectivo |
| 8 | `H_fila_metod_balance (junto a TOTAL BALANCE HORAS METODOLOGÍA Y GESTIÓN)` | Explicación % consumido Metodología | Umbrales semáforo Metodología |
| 11 | `2. Celdas auxiliares (filas n-n+3)` (cabecera sección) | | |
| 12 | Intro a las 4 filas C/D que alimentan el semáforo K_fila_cap+1 (merge A:C) | | |
| 13-16 | Una fila por cada celda auxiliar (Fecha inicio / Fecha fin / Días totales / Días transcurridos) (merge A:C) | | |
| 17 | Nota recálculo HOY() automático, gris cursiva (merge A:C) | | |
| 20 | `3. Sub-marcas de huérfanas (Col A de Tabla2)` (cabecera sección) | | |
| 21 | `🤖 Fuera de plan` | Explicación productos digitales nuevos | |
| 22 | `🤖 Soporte/WIP` | Explicación microtarea reactiva | |
| 25 | `4. Atribución NÉSTOR-PO` (cabecera sección) | | |
| 26 | Explicación prefijo `[NÉSTOR-PO]` en Col E (merge A:C) | | |
| 27 | Aclaración Col K como número fijo no SUMAR.SI (merge A:C) | | |
| 30 | `5. Catálogo oficial de Motivos de Desvío` (cabecera sección) | | |
| 31 | Intro Col M / Col L sólo si negativa (merge A:C, gris cursiva) | | |
| 32 | `Motivo` (cabecera tabla) | `Definición` | |
| 33 | `MALA ESTIMACIÓN` | Definición | |
| 34 | `PARKING` | Definición | |
| 35 | `NO ESTIMADO` | Definición | |
| 36 | `COORDINACIÓN CLIENTE` | Definición | |
| 37 | `MALA COORDINACIÓN INTERNA` | Definición | |
| 40 | `6. Convenciones importantes` (cabecera sección) | | |
| 41 | Col C Tabla21 NO se rellena (merge A:C) | | |
| 42 | Separador decimal coma (merge A:C) | | |
| 43 | Gestiones Cliente en Tabla21 Bloque B (merge A:C) | | |
| 44 | REFINADO=false al crear; ORDEN se asigna en Sprint Planning (merge A:C) | | |

4. **Aplicar estilos canónicos en 3 llamadas `format_ranges`** (separar para evitar partial_success con `column_width` que requiere `worksheet_name` explícito):

**Llamada A — Anchos de columna**:
- A: 320px, B: 480px, C: 380px

**Llamada B — Cabeceras (título, subtítulo, sección, tabla)**:
- Título A1:C1: fondo `#3812CF`, blanco, Manrope Bold 16pt, alto 36px, merge
- Subtítulo A2:C2: gris `#666666`, Manrope 11pt, wrap, alto 50px, merge
- Cabeceras sección (A5, A11, A20, A25, A30, A40): fondo `#D9D0FB`, texto `#3812CF`, Manrope Bold 12pt, alto 28px, merge A:C
- Cabeceras tabla (A6:C6, A32:B32): fondo `#EBEBEB`, Manrope Bold 10pt, alto 24px

**Llamada C — Contenido**:
- Tabla semáforos (A7:C8): Manrope 10pt, wrap, bordes `#EBEBEB`, alto 70px, alineación top
- Tabla huérfanas (A21:B22): Manrope 10pt, wrap, bordes `#EBEBEB`, alto 40px, alineación top
- Tabla motivos (A33:B37): Manrope 10pt, wrap, bordes `#EBEBEB`, alto 50px, alineación top
- Narrativas merge A:C (A12, A13, A14, A15, A16, A26, A27, A41, A42, A43, A44): Manrope 10pt, wrap
- Nota cursiva (A17): gris cursiva 9pt
- Intro motivos cursiva (A31): gris cursiva 10pt

5. **Limpieza final con `delete_rows`** filas 4-9 (separadores residuales con `" "` que dejó la reescritura): el documento queda compacto desde la fila 1 sin huecos artificiales entre subtítulo y sección 1.

**Validado en 5 AUTOIAs Sprint 6-26 Día 10** (Fabián, Paolo, José, Alejandro, Johanna).

---

#### Mejora 4 — Col C Tabla21 NUNCA se rellena

**Regla añadida**: Col C de Tabla21 (Metodología y Gestión) es **campo libre, NO documenta el sprint**. Cualquier valor hardcoded tipo `"Sprint 6-26"` debe limpiarse al cierre del procesamiento.

**Procedimiento**: tras procesar Tabla21, recorrer las filas de Bloque A y Bloque B y vaciar Col C (escribir `" "` espacio, no `""` cadena vacía que da error en algunas rutas).

**Validado en 5 AUTOIAs Sprint 6-26 Día 10**: Fabián 6 celdas, Paolo 7, José 4, Alejandro 6, Johanna 1.

---

#### Orden recomendado de aplicación de las 4 Mejoras

Aplicar en este orden estricto para evitar conflictos con renumeración de filas:

1. **Mejora 1 PRIMERO** (sobre `fila_metod_balance` actual, antes de insertar nada).
2. **Mejora 4** (limpieza Col C Tabla21).
3. **Mejora 2** (insertar 4 filas + auxiliares + semáforo K_fila_cap+1). Las fórmulas de Mejora 1 se autoajustan a sus nuevas posiciones (Fabián G94→G98, etc.).
4. **Mejora 3** (renombrar pestaña, reescribir Leyenda con las referencias de celda YA reposicionadas tras Mejora 2).

---

### PASO 6c — Mejoras de integridad y trazabilidad (v3.5)

⚠️ **Diez mejoras adicionales** consolidadas en v3.5 (sincronizadas desde la supervisada). Refuerzan la integridad del cuadre, la trazabilidad y el orden estructural del AUTOIA.

> 🤖 **OVERRIDE DESATENDIDO global del PASO 6c**: en todas las mejoras donde la versión supervisada dice "reportar al PO" o "pedir validación", el modo desatendido **NO interrumpe ni pregunta**: aplica la regla determinista correspondiente y **acumula el hallazgo para el reporte Cliq final** (PASO 9). Nunca abortar el pase por un hallazgo aislado de estas mejoras (ver Override 7 del PASO 0 BIS).

#### Mejora 12 — Refresco retroactivo del periodo completo (SIEMPRE)

🚨 **El modo desatendido adopta el retroactivo completo** (igual que supervisado v3.5), derogando el refresco incremental Opción D del Override 2 para la reconstrucción de horas. Razón validada por Néstor: prioriza no perder información sobre el coste de tool calls del cron.

Cada pase **relee TODO el periodo del sprint desde ClickUp** y reconstruye/verifica la pestaña Data completa + todas las fórmulas SUMAR.SI. El modelo incremental dejaba horas perdidas silenciosamente (casos 22/05: Johanna 1,5h, Alejandro 3,28h).

**Verificación de integridad obligatoria tras repoblar Data**: por cada fila del plan/huérfana, si tiene horas en Data, su celda K (SUMAR.SI) debe reflejarlas. Si muestra `0,00` teniendo entries detrás → reparar la fórmula + normalizar NFC en AMBOS extremos (Col E de Tiempos + Data!Column20). Ver Bug 4 y Bug 6.

> 🤖 Este override deroga el Override 2 del PASO 0 BIS (refresco incremental Opción D). El PASO 0 BIS queda actualizado: la reconstrucción de Data es retroactiva completa, no incremental.

#### Mejora 13 — Anomalía API ClickUp: entries corruptas (fragmentación binaria)

`clickup_get_time_entries` devuelve a veces un **Output validation error** con `task.id`/`task.name` undefined en entries concretas. Una sola entry corrupta hace fallar TODA la llamada del rango.

**Procedimiento (disparo REACTIVO)**:
1. Intentar la llamada normal del periodo completo. Si devuelve el validation error → fragmentar.
2. **Fragmentación binaria por rango temporal** (mitades sucesivas hasta aislar la entry corrupta; las sanas alrededor se recuperan).
3. **Suelo: 1 hora**. Si un rango de 1h sigue fallando → `ENTRY_NO_RECUPERABLE`.
4. Registrar en Log: tipo `ANOMALIA_API` + horario + user_id.
5. 🤖 **OVERRIDE DESATENDIDO**: NO reportar al PO en chat → **acumular para el reporte Cliq** con la causa raíz. NO abortar el pase (la persona se procesa con las entries recuperables; las irrecuperables quedan para imputación manual).

⚠️ **Causa raíz más probable a señalar en el reporte Cliq**: el usuario afectado ha creado en ClickUp **tarea(s) privada(s)** sin acceso para el usuario de integración (Néstor). La entry existe pero su `task` no es visible para el token → `task.id`/`task.name` undefined. Incluir en Cliq: *"Anomalía API en N entries de [persona] ([horarios]). Causa probable: tarea(s) privada(s) en ClickUp sin acceso. Pedir a [persona] que revise la privacidad de sus tareas del periodo. Entries pendientes de imputación manual: N."*

#### Mejora 7 — Limpieza de prefijos `[BORRADO ClickUp]` huérfanos

Al **inicio** de cada revisión, detectar entries en Data con prefijo `[BORRADO ClickUp]` y verificar si la tarea aún existe en ClickUp:
- **Sigue existiendo** → quitar el prefijo automáticamente + Log. NO re-añadir el prefijo en el mismo pase.
- **Ya no existe** → dejar el prefijo + 🤖 **acumular para reporte Cliq** (trabajo imputado a tarea borrada).

#### Resolución producto→tarea (v1.4 — refunde y precede a las Mejoras 6 y 11)

Antes de aplicar las Mejoras 6 (Col D) y 11 (Col E), **resolver CADA fila de plan** a `{task_id, status_vivo, url}` por orden de prioridad de fuente:

1. **HYPERLINK ya guardado en Col E** → fuente preferente (el `task_id` viaja dentro del enlace).
2. **Lista del cliente** (`Cliente → list_id`) + **match EXACTO de nombre** (normalizado NFC).
3. **Asignado SOLO como desempate** — nunca como fuente principal.

Producir un artefacto de resolución reutilizable por ambas mejoras:
```
resolucion[] = { fila, concepto, task_id, status_vivo, url, resuelto }
```

**Desambiguación** (aprendizaje del piloto en seco de Paolo):
- Ante **homónimos** en la lista → desempatar por **tag de sprint** (`"sprint - 07 - 2026"`) + **asignado**.
- Aceptar **solo match EXACTO normalizado**. Ejemplo: `"Despliegue X"` ≠ `"PreDespliegue X"`.
- Sin match único → `MATCH_AMBIGUO`. 🤖 **OVERRIDE DESATENDIDO**: cuenta como **NO resuelta** y va al reporte Cliq. **Nunca adivinar.** (En la supervisada, este caso se pregunta al PO.)

**Producto no resuelto = bandera dura**: registrar `PRODUCTO_NO_RESUELTO` en el Log + 🤖 **acumular para reporte Cliq**. **NO inventar estatus** (Mejora 6) ni **dejar un enlace inventado** (Mejora 11): la fila queda explícitamente sin resolver.

🗓️ **Clasificación de ceremonias** (convención Néstor 31/05/2026): las **ceremonias de cierre** (Sprint Planning, Retrospective, Daily) se imputan al **SPRINT ENTRANTE** aunque se traqueen el día 1 del sprint.

🔁 **Ejecución OBLIGATORIA en cada pase (v1.4)**: la resolución `resolucion[]` y las **Mejoras 6 (Col D) y 11 (HYPERLINK) se ejecutan fila a fila en CADA pase**, leyendo ClickUp en vivo. ⛔ **PROHIBIDO "conservar los estatus/enlaces del pase previo"** como atajo: los conteos de la compuerta DoD miden lo ejecutado en **ESTE** pase, no estados heredados. En el **primer pase de un sprint nuevo NO existe pase previo**, así que Col D y los enlaces deben construirse necesariamente. Saltarse esto y sellar igual (aunque se reporte como "parcial") es exactamente el fallo del 29/05 que la compuerta existe para impedir.

#### Mejora 6 — Refresco de Col D (Status) desde ClickUp (ClickUp = fuente de verdad)

Para cada fila **resuelta** (artefacto `resolucion[]`), `D ← status_vivo` (el `status` leído en vivo de la tarea en ClickUp). 🚨 **PROHIBIDO escribir Col D desde el snapshot del time entry** — solo desde el status vivo de la tarea resuelta.

🚨 **Estatus NATIVOS de ClickUp, SIN unificaciones**. El AUTOIA es interno: estados tal cual (`Product Backlog`, `Sprint Backlog`, `DOING`, `Doing Amigos`, `Validación Reinicia`, `Validación Cliente`, `parking e incidencias`, `done`, `closed`). **NO** colapsar `done+closed` ni `doing+doing amigos` (esas unificaciones son de la skill de Plan de Proyecto cara cliente, NO de esta).

⚡ **Patrón eficiente y resiliente para leer estatus (v1.5):** refrescar Col D trayendo el estado de todo el sprint en **lote** con `clickup_filter_tasks` por el **tag del sprint vigente** (p. ej. `sprint - 07 - 2026`) y resolver contra ese mapa en memoria. **NO** hacer N× `clickup_get_task`. `get_task` queda solo para tareas que no salgan en el filtro (subtareas, tareas sin tag). Esto reduce drásticamente las llamadas y la exposición a los **502 transitorios** — validado en el piloto (sustituir `get_task` por `filter_tasks` por tag absorbió los 502 sin abortar el pase).

📐 **Alcance del refresco de Col D según cadencia (v1.5):** como esta skill corre **a diario** y un refresco live del 100% de las filas cada día es caro en llamadas y aporta poco a media-sprint, el alcance se acota así:
- **Pase diario (lun–vie):** refrescar Col D **solo** de (i) filas con actividad (imputación) en ESTE pase y (ii) filas cuya resolución producto→tarea cambió respecto al pase anterior. El resto conserva su estatus.
- **Pase semanal / de cierre de sprint:** refresco live del **100%** de las filas de plan (vía el `filter_tasks` por tag, que ya trae todo el sprint en un mapa, así que el coste marginal es bajo).
- El reporte Cliq (PASO 9) debe **declarar con transparencia** qué alcance se aplicó en el pase (diario acotado vs. 100%). La compuerta DoD (a) sigue exigiendo **resolución** completa (`n_resueltas==n_plan`, `n_ambiguas==0`) en TODOS los pases; el alcance acotado afecta solo a la **frescura de Col D** de filas sin actividad, no a la resolución.

- Cada cambio → Log de Cambios (anterior → nuevo, fila, concepto, fuente ClickUp).
- **Incoherencias** (saltos sospechosos) → Log + 🤖 **acumular para reporte Cliq y para el Informe Ejecutivo de Equipo**.

#### Mejora 11 — Enlaces HYPERLINK a la ficha ClickUp

En Col E de Tiempos, envolver el nombre en `=HYPERLINK("https://app.clickup.com/t/XXXXX";"Nombre exacto [CLIENTE]")`. Validado: el motor evalúa el HYPERLINK como su `cell_text`, no rompe SUMAR.SI. Para cada **fila resuelta sin enlace** (artefacto `resolucion[]`), `E = HYPERLINK(url; nombre)` con el `url` resuelto; el `task_id` queda embebido en el enlace. Verificar que `K` (SUMAR.SI) NO cae a 0 tras envolver.

- **Filas con enlace**: plan + huérfanas con task ID + Gestiones Cliente de Tabla21 Bloque B. SIN enlace: ceremonias y Metodología interna.
- **Match aproximado + corrección de nombre desde ClickUp** (triple umbral):
  - **Alta confianza** (prefijo exacto, o coincide ignorando truncamiento/espacios/tildes) → corregir nombre al canónico + enlace + Log.
  - **Dudoso** (varios candidatos) → 🤖 **OVERRIDE DESATENDIDO**: NO tocar el nombre, NO enlazar, **acumular candidatos para reporte Cliq** (nunca adivinar en desatendido).
  - **Sin match** → sin enlace, acumular para reporte Cliq.
- 🚨 **Doble renombrado obligatorio**: si se corrige el nombre en Col E (solo en alta confianza), renombrar TAMBIÉN Data!Column20 en el mismo pase. Log de cada corrección.

#### Mejora 9 — Atribución NÉSTOR-PO (rediseño): de fila paralela a nota en Col M

🚨 **Deroga el patrón de fila paralela `[NÉSTOR-PO]`.** Comportamiento:
- **Eliminar** la fila paralela `[NÉSTOR-PO]` de Tabla2.
- La hora de Refinamiento Automático queda **solo en Tabla21 Bloque A**.
- En la **fila original**, **añadir en Col M** una nota que incluya el literal **"Refinamiento IA"**.
- **Col A NO se toca**.

🚨 **Col M es multi-información, se escribe por APPEND con saltos de línea**: nunca borrar "Refinamiento IA"; preservar siempre el contenido previo (leer, concatenar con salto de línea, escribir).

#### Mejora 14 — Peticiones duplicadas del cliente

La skill **NO fusiona ni borra automáticamente**:
- **Dejar las dos filas**, consecutivas. La **buena es la 2ª** (corregida, por fecha de creación ClickUp).
- En **Col A de la MALA (la 1ª)**: anteponer `Duplicado. ` a su contenido actual (ej. `Duplicado. 🤖 Soporte/WIP`). La buena conserva su Col A.
- **Horas (Opción 1)**: la buena conserva SUMAR.SI y refleja TODAS las horas del concepto; la mala con **K vacía**. El tiempo cuenta una vez.
- 🤖 **OVERRIDE DESATENDIDO**: NO reportar al PO en chat → **acumular para reporte Cliq** (limpieza manual en ClickUp pendiente).

⚠️ **Limitación conocida (capacidad)**: el tiempo duplicado-pero-cobrable entra en capacidad vía la fila buena. Ver "Evolución prevista v3.6" (tabla aparte de "tiempo facturable no productivo").

#### Mejora 8 — Limpieza global + estructura de bloques + colchón permanente

**Estructura canónica de Tabla2**:

```
Bloque Plan (Sprint Planning)
[3 filas vacías — separador deliberado]
Bloque Soporte estimado
[3 filas vacías — separador deliberado]
Bloque Huérfanas (entran durante el sprint)
[buffer ≥ 3 filas vacías formateadas]
```

Las huérfanas forman un **tercer bloque visualmente separado** con su propia separación de 3 filas. Tabla21 empieza **siempre vacía**.

- **8.1 Limpieza global**: eliminar filas completamente vacías intercaladas en Tabla2 (verificación previa Bug 8). **Excepciones**: los dos separadores de 3 filas y el buffer final.
- **8.2 Preservar bloques**: respetar los 3 bloques y sus separadores de 3 filas (sagrados).
- **8.3 Colchón permanente (Tabla2 Y Tabla21)**: garantizar **≥3 filas vacías formateadas de buffer al final** de cada tabla tras cada pase. Insertar fila debajo (hereda formato) ANTES de cubrir la última vacía. **Nunca agotar la tabla** (vistos AUTOIAs con Tabla21 llena hasta el borde).

#### Mejora 5 — Validación de cuadre contra ClickUp API en VIVO

🚨 Ver PASO 8 (reescrito v3.5). Validación contra ClickUp API en vivo (no contra Data). Umbrales escalonados; el bloqueo (>0,5h) en desatendido → no sella + reporta a Cliq.

#### Mejora 10 — Cierre canónico atómico

🚨 Ver PASO 8b (reescrito v3.5). Checklist indivisible: verificación estatus + cuadre + colchón + Log + doble sello.

#### Orden recomendado de aplicación del PASO 6c

1. **Mejora 12** (retroactivo completo) — base del pase.
2. **Mejora 13** (anomalía API) — solo si falla la lectura.
3. **Mejora 7** (limpieza `[BORRADO ClickUp]`).
4. **Mejora 6** (refresco Col D Status).
5. **Mejora 14** (duplicados) y **Mejora 9** (NÉSTOR-PO) — durante la clasificación.
6. **Mejora 11** (HYPERLINK + nombres).
7. **Mejora 8** (limpieza + bloques + colchón).
8. **Mejora 5 + Mejora 10** (validación + cierre atómico) — PASO 8 y 8b.

---

Cuando la columna **Diferencia horas (K)** es negativa, significa que el tiempo registrado supera al estimado. La norma Reinicia exige rellenar dos campos en esa fila:

#### Col L — Motivo desvío (dropdown CERRADO de 5 valores)

⚠️ **Catálogo CERRADO — fuente de verdad: pestaña `Leyenda` sección 5 (v3.4+) / pestaña `Motivos Desvío` (v3.0-v3.3) del Sprint Backlog**. Estos son los ÚNICOS valores admitidos. Cualquier valor fuera del catálogo (`NO SE TOCA`, `FALTA DE TIEMPO`, `DEPENDENCIAS`, etc.) es inválido y la skill debe corregirlo o vaciarlo.

| Valor | Significado |
|---|---|
| `MALA ESTIMACIÓN` | El estimado original era irrealista para el alcance del producto |
| `PARKING` | El producto quedó detenido (parking e incidencias) por bloqueo, espera de información o decisión del cliente, o priorización |
| `NO ESTIMADO` | El producto entró en sprint sin estimación previa. Huérfana o tarea reactiva no contemplada en el planning original |
| `COORDINACIÓN CLIENTE` | Desviación por interacciones, dudas, validaciones o cambios solicitados por el cliente que no estaban contempladas en la estimación inicial |
| `MALA COORDINACIÓN INTERNA` | Desviación por fricciones internas en Reinicia: bloqueos entre miembros del equipo, retrabajo por falta de información, dependencias mal gestionadas, traspasos incompletos |

#### Col M — Comentario (texto libre breve)

Nota orientativa de qué pasó concretamente. Ejemplo: "Estimación de 2h pero el cliente cambió el alcance dos veces; se llegó a 5,5h reales".

#### Procedimiento de la skill

> 🤖 **OVERRIDE 4 DESATENDIDO (ver PASO 0 BIS): NO pedir validación del PO motivo por motivo.** Aplicar la tabla de sugerencia automática del Override 4 según el contexto detectado (huérfana sin estimación → `NO ESTIMADO`, status parking → `PARKING`, status validación cliente → `COORDINACIÓN CLIENTE`, status done con J/G≥1,5 → `MALA ESTIMACIÓN`, resto ambiguo → dejar en blanco). Registrar en Log como `MOTIVO_DESVIO_AUTO`. Acumular para reporte Cliq. La lógica de "pedir validación" del paso 3 que sigue documentada aquí es de la skill supervisada; saltarse esa interacción en modo desatendido.

🚨 **Regla crítica de aplicación**: Col L (Motivo desvío) y Col M (Comentario) **SOLO se rellenan cuando el tiempo registrado (J) SUPERA al estimado (G)**, es decir cuando Col K (Diferencia horas) = G - J es NEGATIVA. Si J ≤ G (no hay sobreesfuerzo, K positiva o cero), ambas celdas quedan VACÍAS SIEMPRE. La columna no documenta:
- "Desvíos positivos" (trabajo entregado en menos tiempo del estimado)
- Filas en curso donde aún no se ha consumido la estimación
- Productos agregados con J=0 deliberado (patrón Opción B del Paso 5)

Solo desvíos REALES que requieren justificación.

1. **Identificar todas las filas con K < 0** del Sprint Backlog principal (incluidas huérfanas Grupo B insertadas en Paso 5) y del bloque Metodología (Paso 6). Las filas con K ≥ 0 quedan al margen y se vacían si tuvieran algún motivo histórico residual.
2. **Por cada fila, proponer al PO** un motivo y comentario sugerido en base al contexto disponible:
   - Si la huérfana fue Soporte/WIP sin estimación → sugerir `NO ESTIMADO`.
   - Si el producto está en `parking e incidencias` o `validación cliente` con tiempo real >> estimado → sugerir `PARKING` o `COORDINACIÓN CLIENTE`.
   - Si el producto cerró en `done` con desvío grande → sugerir `MALA ESTIMACIÓN`.
   - El comentario se sugiere a partir de las descripciones de los time entries de la tarea (campo `description` de ClickUp).
3. **Pedir validación del PO** antes de escribir. El PO puede aceptar la sugerencia, cambiar el motivo o ajustar el comentario.
4. **Escribir** Col L (dropdown) y Col M (texto) tras validación.
5. **Registrar en Log de Cambios** cada motivo y comentario añadido.

Estos motivos y comentarios se llevarán al Informe Ejecutivo del Equipo correspondiente para tener visibilidad de causas reincidentes y poder mejorar el sprint siguiente.

### PASO 8 — Validación matemática contra ClickUp API en vivo (v3.5)

🚨 **Mejora 5 — La validación se hace contra el total REAL de ClickUp leído en vivo, NO contra la pestaña Data.** El refresco retroactivo completo (Mejora 12) garantiza que se ha leído todo el periodo de ClickUp.

```
suma(SUMAR.SI Tabla2 Sprint Backlog principal)
+ suma(Tabla21 Metodología y Gestión)
==  total_ClickUp_API_live(persona, periodo completo del sprint)
```

**Umbrales escalonados**:

| Discrepancia | Acción |
|---|---|
| **≤ 0,1h** | Cuadre OK. Cierre normal. |
| **0,1h – 0,5h** | Cierra, pero 🤖 **acumula AVISO para el reporte Cliq** (margen de redondeos acumulados). |
| **> 0,5h** | **BLOQUEA el cierre**: NO sella, NO actualiza Log de sello. 🤖 **Reporta el descuadre a Cliq** con desglose. La persona queda sin cerrar; el resto del Equipo continúa (no abortar el pase global — Override 7). |

**Desglose obligatorio cuando hay aviso o bloqueo** (en el reporte Cliq):
- **Entries fantasma**: en el AUTOIA pero NO en ClickUp API live → candidatas a eliminar.
- **Entries faltantes**: en ClickUp API live pero NO en el AUTOIA → candidatas a añadir.

Registrar en Log: `[timestamp] | VALIDACION | Cuadre AUTOIA | Plan: [X]h, Metodología: [Y]h, Total: [X+Y]h | ClickUp API live: [Z]h | Discrepancia: [D]h | Resultado: [OK / AVISO / BLOQUEO]`.

Si bloquea (>0,5h): la persona se marca como NO CERRADA en el reporte Cliq; revisar en la siguiente ejecución supervisada (Paso 4 + Mejora 7).

### PASO 8b — Sello de actualización y estilo final del Log

#### 🆕 Plantilla nueva Sprint 6-26 (v3.3)

Para AUTOIAs Sprint 6-26+:

- **Sello E1 + Log!M1**: se conserva el procedimiento (escribir timestamp en formato canónico Manrope bold 14pt #3812CF).
- **Estilo final del Log**: NO aplicar bandeo manual, NO aplicar `format_ranges` masivo. La plantilla nueva trae las ~55 filas vacías ya formateadas; al escribir contenido en una fila vacía, el formato se hereda automáticamente.

Solo aplicar el procedimiento clásico de bandeo manual si el AUTOIA es Sprint 5-26 o anterior.

---

Tras la validación, antes de generar el reporte, asegurar que el fichero queda con metadato y formato correctos.

#### Sello de actualización

1. **Tiempos!E1**: escribir `Última actualización: DD/MM/AAAA HH:MM:SS — Sprint X-YY` (timestamp del momento de cierre, no del inicio). Aplicar formato canónico Reinicia: **Manrope bold 14pt color #3812CF**, vertical_alignment middle. Hora completa hh:mm:ss para precisar versión.
2. **Log de Cambios!M1**: mismo texto.

Estos sellos se sobreescriben siempre — el valor anterior se descarta (se asume que la última ejecución es la fuente de verdad).

#### Estilo final del Log de Cambios

Tras todas las inserciones del proceso (renames, datas, motivos, sello), el Log de Cambios habrá crecido en N filas nuevas que probablemente vienen sin el estilo canónico. Recalcular `last_row` con `ZohoSheet_get_used_area` y aplicar el estilo uniforme al rango completo de datos:

```
format_ranges(
    range="A2:K[last_row]",
    fill_color="#EBEBEB",
    border={
        border_color="#FFFFFF",
        border_style="solid",
        border_type="all_border"
    },
    font_name="Manrope",
    font_size=10,
    vertical_alignment="top",
    wrap_text=true
)
```

Esta es la garantía operativa de que el Log queda visualmente coherente al final de cada ejecución, independientemente de cuántas inserciones se hayan hecho durante el proceso. **Sin bandeo intercalado** — todas las filas de datos con el mismo fondo gris Reinicia.

#### Verificación de tipografía Manrope (NO aplicación global)

⚠️ La plantilla maestra del Sprint Backlog **YA viene con Manrope aplicado por defecto** a todas las celdas (incluso vacías) como parte de la identidad visual Reinicia. La skill **NO aplica Manrope global** como paso obligatorio de cierre — eso era práctica antigua y consume tokens innecesariamente.

En su lugar, **VERIFICAR** con una muestra que la tipografía sigue siendo Manrope:
1. Leer `Tiempos!E10` (o cualquier celda con datos del plan principal) y comprobar que `font_name = "Manrope"`.
2. Si por edición manual alguna celda se hubiera salido de Manrope, aplicar `font_name="Manrope"` SOLO al rango afectado, NO a toda la hoja.

(Aprendizaje validado piloto Fabián 06/05/2026: aplicar Manrope global era trabajo desperdiciado porque la plantilla ya lo trae).

#### Registro de cierre

Registrar en Log de Cambios:
- `[timestamp] | Tiempos | 1 | E | - | [sello previo o vacío] | [sello nuevo] | SELLO_ACTUALIZACION | Skill | Sello de fin de ejecución`
- `[timestamp] | Log de Cambios | 1 | M | - | [sello previo o vacío] | [sello nuevo] | SELLO_ACTUALIZACION | Skill | Sello de fin de ejecución`

#### 🆕 Mejora 10 (v3.5) — Cierre canónico ATÓMICO (checklist obligatorio e indivisible)

🚨 **Tras procesar cada AUTOIA se ejecuta SIEMPRE este checklist de cierre completo.** Orden estricto:

1. **(a) Verificación de estatus de los productos** — Mejora 6: Col D refrescada contra ClickUp (estatus NATIVOS, sin unificar) en todas las filas con task ID resoluble; incoherencias en Log + acumuladas para Cliq + Informe Ejecutivo.
2. **(a-bis) Enlaces a ClickUp** — Mejora 11: Col E envuelta en `=HYPERLINK(...)` en productos del plan + huérfanas con task ID + Gestiones Cliente (Tabla21 Bloque B). Tras escribir, verificar que el `K` (SUMAR.SI) de CADA fila enlazada NO cae a 0 (el `cell_text` debe ser el nombre NFC exacto de Data). Matches dudosos / sin match → NO enlazar, acumular para Cliq (Override desatendido: nunca adivinar).
3. **(b) Validación de cuadre** — Mejora 5 (PASO 8): contra ClickUp API live. **Si bloquea (>0,5h): NO sellar, marcar persona como NO CERRADA, acumular para Cliq.** Continuar con el resto del Equipo.
4. **(c) Verificación de colchón** — Mejora 8.3: ≥3 filas vacías formateadas al final de Tabla2 Y Tabla21.
5. **(d) Entradas en Log de Cambios** — registrar TODO lo modificado en el pase.
6. **(e) Doble sello** — `Tiempos!E1` Y `Log de Cambios!M1` → "Última actualización: DD/MM/AAAA HH:MM:SS — Sprint XX-XX".

Si (b) bloquea, la persona queda explícitamente sin cerrar (sin (d) ni (e) para ella) y se reporta a Cliq; el pase global continúa con las demás personas.

##### 🚦 Compuerta de sellado — Definición de Hecho (DoD) OBLIGATORIA (v1.5 — por evidencia, sin sello parcial, invalida sello previo si falla)

🚨 **El doble sello (e) NO se escribe nunca sin pasar la compuerta DoD.** Como no hay PO delante, la compuerta es DETERMINISTA, se computa **desde el sheet real + el artefacto de Resolución de ESTE pase** (no de memoria, no de estados heredados) y se deja registrada por escrito:

1. **Releer literalmente** el PASO 6c (Resolución producto→tarea + Mejoras 6 y 11, incluida la regla de **ejecución obligatoria en cada pase**) y este PASO 8b antes de cerrar cada persona.
2. **Recomputar los conteos reales** desde el sheet y el artefacto `resolucion[]` **construido en este pase** (una fila "conservada del pase previo" NO cuenta como ejecutada):
```
n_plan        = filas de plan
n_resueltas   = filas con task_id resuelto en ESTE pase
n_drifts      = Col D modificadas (status_vivo ≠ anterior)
n_resolubles  = filas resueltas que deben llevar enlace
n_enlazadas   = filas con HYPERLINK (re)escrito en ESTE pase (K intacto)
n_ambiguas    = filas MATCH_AMBIGUO
```
3. **Criterios de la compuerta** (cada uno ✅/❌):
```
(a)     Col D / Mejora 6   → ✅ solo si  n_resueltas == n_plan  Y  n_ambiguas == 0
(a-bis) Enlaces / Mejora 11 → ✅ solo si  n_enlazadas == n_resolubles
(b)     Cuadre vs ClickUp   → ✅ si  |dif| ≤ 0,1 h
(c)     Colchón             → ✅ si ≥3 filas en Tabla2 Y en Tabla21
(d)     Log escrito         → ✅
```
4. **Registrar en Log (`DOD_CIERRE`) y en el reporte Cliq con los conteos reales**:
```
🚦 DoD [Persona]: (a) Col D ✅/❌ [n_resueltas/n_plan, ambiguas=N] · (a-bis) Enlaces ✅/❌ [n_enlazadas/n_resolubles] · (b) Cuadre ✅/❌ [Δ X,XXh] · (c) Colchón ✅/❌ · (d) Log ✅/❌
```
5. **REGLA DURA — NO EXISTE "SELLO PARCIAL":** o (a)–(d) están **TODOS al 100% / ✅** y se escribe el sello (e), o **NO se escribe E1/M1** y la persona queda **NO CERRADA**. Está PROHIBIDO escribir el doble sello si **(a) o (a-bis) están por debajo del 100%**, aunque se documente como "parcial". Documentar el parcial NO autoriza a sellar: si falta ejecutar Mejora 6/11, se **ejecutan** (son deterministas, no requieren PO) o se deja **NO CERRADA**.
6. 🤖 **[SOLO DESATENDIDA]** Si tras intentar ejecutarlas (a)/(a-bis) siguen <100%, o hay anomalía API → **NO sellar**; marcar la persona como **NO CERRADA (DoD incompleta)** en Cliq, con el **detalle de los productos** no resueltos / no enlazados / ambiguos, y continuar con el resto del Equipo (Override 7). **Nunca sellar a ciegas ni en parcial.**
7. 🧹 **[SOLO DESATENDIDA] Invalidar sello previo (v1.5):** cuando una persona queda NO CERRADA pero su AUTOIA **ya tenía un sello previo** (de un pase anterior) en `Tiempos!E1` / `Log!M1`, ese sello queda **desfasado y contradictorio** (el fichero diría "cerrado" sin estarlo). No basta con no reescribirlo: **sustituir** `E1`/`M1` por la marca **`NO CERRADA — [fecha/hora] — DoD incompleta`** (no dejar el timestamp viejo) y registrar `DOD_CIERRE` en el Log con el motivo. Como no hay PO delante, esta limpieza es **determinista y automática**: el automatismo no puede depender de una limpieza manual del sello. Reflejarlo en el reporte Cliq.

### PASO 9 — Reporte y siguientes pasos

```
✅ Sprint Backlog actualizado — [Persona]

Cuadre AUTOIA:
  - Plan original (Tiempos principal):  [X,XX]h
  - Metodología y Gestión:              [Y,YY]h
  - TOTAL AUTOIA:                       [X+Y]h
  - Total real ClickUp:                 [Z,ZZ]h
  - Match: ✅ / ⚠️ desvío [Δ]h

Huérfanas integradas:
  - Grupo B - Fuera de plan (DENTRO Tabla2): [N] productos, [Hb1]h reales
  - Grupo B - Soporte/WIP   (DENTRO Tabla2): [N] productos, [Hb2]h reales
  - Grupo A - Metodología y Gestión (APARTE): [N] conceptos, [Ha]h reales
  - TOTAL huérfanas: [Hb1+Hb2+Ha]h

Filas con desvío negativo (K < 0): [N]
  - Motivos más frecuentes: [resumen]

Avisos:
  - [N] productos de Soporte sin estimación informada (ver lista)
  - [N] time entries sin task asociada (ver lista)
  - [N] alertas de sobrecarga emitidas
  - [N] propuestas de mejora de skill identificadas (Mejoras Propuestas Skill Sprint Backlog: documentar en Reinnova ClickUp)

Próximo paso sugerido: [siguiente miembro del equipo, o generación de Informes Ejecutivos si es el último].
```

Si quedan miembros pendientes y el modo es por defecto (preguntar antes de cada uno), preguntar:

```
¿Sigo con [siguiente miembro]?
```

---

## REGLA DEL DELTA Y VALIDACIÓN DE CUADRE

⚠️ **Regla añadida en Sprint 6-26 Día 2** tras detectar un fallo silencioso de duplicación al procesar el Día 2 con Día 1 ya escrito.

> 🚨 **DEROGADA POR LA MEJORA 12 (v3.5), TAMBIÉN EN MODO DESATENDIDO.** Desde v3.5 el modo desatendido **repuebla Data retroactivamente desde cero con todo el periodo del sprint en cada ejecución** (decisión de Néstor: prioriza no perder información sobre el coste de tool calls del cron). Esto **deroga el Override 2 del PASO 0 BIS** (refresco incremental Opción D). Esta sección se conserva como referencia histórica y porque el razonamiento de cuadre task-by-task sigue siendo válido como verificación de integridad.

### El modo de fallo silencioso

Cuando se procesa un AUTOIA en el día N+1 con el día N ya escrito en Data, ClickUp devuelve **el periodo completo** (no solo los entries del día nuevo). Es muy fácil confundir mentalmente "número de entries del periodo nuevo a añadir" con "número de entries del día N+1", lo que provoca duplicaciones de filas Data sin que las cuentas de horas necesariamente lo evidencien (la SUMAR.SI agrega bien las horas, así que sin un cuadre estricto contra ClickUp el error pasa desapercibido).

**Caso real validado** (Alejandro Sprint 6-26 Día 2):
- ClickUp DataPrep Exeltis: 3 entries de 30m cada una = 1,50h totales del periodo (Día 1 + Día 2)
- Día 1 ya escrito en Data: 2 filas × 0,5h = 1,00h (las 2 entries del Día 1)
- Día 2 nuevo: 1 entry de 30m = 0,50h
- **Error cometido**: escribí **2 filas** de 0,50h en Día 2 (filas 10 y 16 de Data) en lugar de **1 fila**, dando 4 filas totales × 0,5h = 2,00h cuando ClickUp solo tenía 3 entries totalizando 1,50h.
- **Resultado**: cuadre AUTOIA = 12,50h vs ClickUp = 12,00h, 30 minutos de exceso silencioso.

### Procedimiento canónico para procesar deltas

Cuando se procesa un AUTOIA en día N+1 con día N ya escrito en Data, seguir este procedimiento estricto:

```
1. Pedir a ClickUp el rango completo del sprint hasta hoy
   (start_date = inicio sprint, end_date = hoy 23:59).

2. Por cada task agregada del periodo (`summary.by_task`), calcular:
     entries_total_ClickUp     = task.entry_count
     horas_total_ClickUp       = task.total_duration_ms / 3600000
     filas_ya_escritas_Data    = COUNT(Data WHERE Col20 = task.name)
     horas_ya_escritas_Data    = SUM(Data[Col57] WHERE Col20 = task.name)

3. Calcular delta:
     filas_a_añadir            = entries_total_ClickUp - filas_ya_escritas_Data
     horas_delta               = horas_total_ClickUp   - horas_ya_escritas_Data

4. Escribir EXACTAMENTE `filas_a_añadir` filas nuevas en Data,
   distribuyendo `horas_delta` entre ellas según las duraciones reales
   de los entries nuevos (los que NO estaban en periodo anterior).

5. Si filas_a_añadir == 0 y horas_delta != 0:
   → ANOMALÍA: alguien ha modificado un entry existente en ClickUp
     (no añadido uno nuevo). Investigar antes de tocar.

6. Si filas_a_añadir != 0 y horas_delta == 0:
   → ANOMALÍA: hay entries nuevos pero suman 0h. Investigar.
```

⚠️ **Lo crítico**: el número de filas Data a añadir es **`entries_totales_del_periodo − filas_Data_ya_escritas_para_esa_task`**, NO "entries del día N+1". Confundirlos provoca duplicaciones.

### Validación obligatoria de cuadre antes de cerrar

⚠️ **PASO DE VALIDACIÓN OBLIGATORIO** antes de aplicar el sello E1 y cerrar el AUTOIA:

```
1. Leer K total Tabla2 (típicamente K66 o K67 según AUTOIA).
2. Leer K total Tabla21 (típicamente K94 o K95).
3. Calcular cuadre_AUTOIA = K_total_Tabla2 + K_total_Tabla21
4. Comparar con summary.total_duration_ms / 3600000 que devolvió ClickUp.
5. Calcular discrepancia = |cuadre_AUTOIA - cuadre_ClickUp|.

Si discrepancia <= 2 minutos (~0,033h):
   ✅ Margen aceptable por redondeo decimal. Cerrar el AUTOIA.

Si 2 minutos < discrepancia <= 30 minutos:
   ⚠️ Margen alto pero plausible por acumulación de redondeos
   (especialmente con 15+ entries). Avisar al PO líder con el dato
   pero permitir cerrar si lo confirma.

Si discrepancia > 30 minutos:
   ❌ NO CERRAR. Hacer un repaso entry-by-entry para localizar:
   - Filas duplicadas en Data (mismo task con n+1 filas cuando debería ser n)
   - Filas omitidas en Data (entry de ClickUp que no se pegó)
   - Errores de sub-marca o atribución de subtarea
   - Bug Unicode silencioso (K=0 inesperado en alguna fila)
   Solo cerrar tras corregir y repasar el cuadre.
```

### Por qué este filtro es necesario

La SUMAR.SI de Col K matchea por nombre de Concepto. Si dupliques una fila Data, **la fila correspondiente de Tabla2/Tabla21 sumará el doble** sin avisar. Visualmente todo parece correcto. El único filtro fiable es comparar el total acumulado del AUTOIA contra el total acumulado que reporta ClickUp en su `summary.total_duration_ms`.

⚠️ **Margen aceptable de redondeo**: con 2 decimales de precisión por entry (`1,73h` para `1h 43m 47s`), 15+ entries pueden acumular hasta 30s de error agregado. Por eso el umbral "ok" es <2 min, no 0.

### Caso especial — entries con duración < 1 minuto

Entries de unos pocos segundos (típico: arranque accidental de timer en ClickUp con stop inmediato) producen valores como `0,00h` en Col57 de Data. **Pegarlos igualmente** con valor `0,00` por trazabilidad — el cuadre numérico no se ve afectado pero la fila queda como evidencia de que la entry existe en ClickUp.

---

## OPERACIONES DESTRUCTIVAS — REGISTRO EN LOG DE CAMBIOS

Toda operación que modifique el fichero **debe registrarse** en la hoja `Log de Cambios` con timestamp, tipo de operación, detalle, estado anterior y posterior. Tipos de operación estandarizados:

| Tipo | Descripción |
|---|---|
| `INICIALIZACIÓN` | Creación de la hoja Log de Cambios |
| `TABLA_LOG_CREADA` | Creación de tabla formal sobre Log de Cambios preexistente (migración a TablaLog) |
| `SELLO_ACTUALIZACION` | Actualización de timestamp en Tiempos!E1 y Log de Cambios!M1 al cierre de la ejecución |
| `DATA_CLEAR` | Vaciado de la hoja Data antes de pegar registros nuevos |
| `DATA_PASTE` | Pegado de registros desde ClickUp en la hoja Data |
| `DATA_PASTE_INCREMENTAL` | Pegado incremental de entries nuevas posteriores al último timestamp registrado (sub-paso 3d) |
| `TIEMPOS_RENAME` | Modificación de un concepto en Tiempos!Concepto para forzar match (validado por PO) |
| `TIEMPOS_RENAME_RECHAZADO` | Rename propuesto y rechazado por el PO (registro de referencia para no reproponerlo en revisiones siguientes del mismo sprint) |
| `TIEMPOS_INSERT` | Inserción de filas físicas en Tiempos para huérfanas |
| `TIEMPOS_PASTE` | Escritura de datos de huérfanas en filas insertadas |
| `METODOLOGIA_CREATE` | Creación o actualización del bloque Metodología y Gestión |
| `MOTIVO_DESVIO` | Escritura de motivo y comentario en filas con K negativo |
| `VALIDACION` | Resultado de la validación matemática final |

El registro permite **revertir manualmente** si algo sale mal (no es automático, pero es auditable).

---

## INSUMO PARA INFORMES EJECUTIVOS POR EQUIPO

> ⚠️ **La generación del Informe Ejecutivo NO es responsabilidad de esta skill.** Existirá una skill aparte (a futuro) que consume los datos producidos por esta skill y los agrega a nivel Equipo.

Tras procesar todos los miembros de un Equipo, esta skill produce los siguientes datos consumibles por la skill de Informes Ejecutivos:

| Métrica por equipo | Origen |
|---|---|
| Total horas trabajadas equipo | Suma de `Tiempos!J[TOTAL DISPONIBLES]` + `[TOTAL METODOLOGÍA]` de todos los miembros |
| Capacidad equipo | Suma de capacidades individuales |
| % utilización equipo | Total / Capacidad |
| Sobrecarga (estim - capacidad) | Plan vs capacidad |
| Distribución por cliente | Cruzando Col E (Cliente) de Tiempos de todos los miembros |
| Productos vencidos (Plan vs ejecución) | Status `DOING` o anterior con fecha límite ya pasada |
| Productos en `parking e incidencias` | Lista para discusión en Sprint Review |
| Carga de Metodología y Gestión por cliente | Bloque "Metodología y Gestión" agrupado por col Cliente |
| Huérfanas Grupo B totales (desglosadas en Fuera de plan / Soporte/WIP) | Diagnóstico de trabajo no planificado |
| Alertas de sobrecarga emitidas | Lista de productos huérfanos Grupo B - Fuera de plan con sobrecarga |
| Motivos de desvío por miembro | Cruce Col L + Col M de filas con K negativo |
| Personas sin Sprint Backlog (caso Amigos Reinicia) | Pestaña aparte con horas tracked agregadas |
| Mejoras Propuestas Skill Sprint Backlog | Lista de propuestas de mejora identificadas durante el procesamiento, con etiqueta "documentar en Reinnova ClickUp" |

### 🆕 Matriz % Facturable cruzada Tabla2 + Tabla21 (v3.3 Día 2)

⚠️ **Métrica nueva añadida en Sprint 6-26 Día 2** — insumo para Informe Ejecutivo. La skill `revision-sprint-backlog-equipo-reinicia` debe poder producir esta matriz por persona y por equipo cuando el Informe Ejecutivo lo solicite.

Para cada persona del Equipo, calcular:

| | Estimado (Col G) | Tracked real (Col K) |
|---|---|---|
| **Facturable** (Col J = "Sí") | `SUMIF(Tabla2[J];"Sí";Tabla2[G]) + SUMIF(Tabla21[J];"Sí";Tabla21[G])` | `SUMIF(Tabla2[J];"Sí";Tabla2[K]) + SUMIF(Tabla21[J];"Sí";Tabla21[K])` |
| **No Facturable** (Col J = "No") | `SUMIF(Tabla2[J];"No";Tabla2[G]) + SUMIF(Tabla21[J];"No";Tabla21[G])` | `SUMIF(Tabla2[J];"No";Tabla2[K]) + SUMIF(Tabla21[J];"No";Tabla21[K])` |

**Métricas derivadas clave**:

- **% Facturable plan**: `Estimado_Facturable / Estimado_Total`
- **% Facturable real**: `Real_Facturable / Real_Total`
- **% Utilización facturable**: `Real_Facturable / Capacidad` (donde Capacidad = G66 ó G71 "Operativas")
- **Desviación facturable**: `Real_Facturable − Estimado_Facturable`
- **Brecha plan vs real**: `% Facturable real − % Facturable plan`

**Insight ejecutivo**: 
- A inicio de sprint la brecha es típicamente negativa (ceremonias consumen mucho los primeros días) → es esperable.
- A medio sprint debe converger hacia el ratio plan.
- A final de sprint, brechas persistentes >10 puntos son señal de:
  - Plan mal estimado (productos sobre-estimados o sub-estimados)
  - Ceremonias / Gestiones consumiendo más de lo previsto
  - Trabajo no facturable apareciendo como huérfanas Reinicia/Reinnova

**Implementación**: actualmente las fórmulas D72/D73 del AUTOIA solo cubren Tabla2 estimado (no incluyen Tabla21 ni tracked real). La matriz completa **se construye en el Informe Ejecutivo** consultando los datos de Tabla2 + Tabla21 de cada AUTOIA. En el futuro, cuando se actualice la plantilla maestra, podría incluirse un bloque "Resumen Facturable" propio dentro de cada AUTOIA con esta matriz pre-calculada (Opción C documentada en intercambio Día 2 con PO líder). Pendiente de evolución.

---

## RECURSOS CLAVE

### Constantes de marca Reinicia

- Azul primario: `#3812CF`
- Acento: `#D9D0FB`
- Filas alternas: `#EBEBEB`
- Total fila: `#D9D0FB`
- Fuentes: Manrope Regular y Manrope Bold

### Catálogo CERRADO de Motivos de Desvío (Col M de Tiempos)

Estos son los **5 únicos valores admitidos** en el dropdown Col M (Motivo desvío) de Tiempos. Validado por PO 06/05/2026. La fuente de verdad operativa es la sección 5 de la pestaña `Leyenda` (v3.4+) / la pestaña `Motivos Desvío` (v3.0-v3.3) de cada Sprint Backlog.

| Motivo | Cuándo aplicar |
|---|---|
| `MALA ESTIMACIÓN` | El alcance era correcto pero el tiempo estimado fue inadecuado. Error de planning, no cambios de alcance ni factores externos |
| `PARKING` | Producto detenido por bloqueo, espera de información o decisión del cliente, o priorización |
| `NO ESTIMADO` | El producto entró en sprint sin estimación previa (huérfana o tarea reactiva) |
| `COORDINACIÓN CLIENTE` | Desviación por dudas, validaciones o cambios solicitados por el cliente. Aplica también cuando el cliente extiende el alcance de facto vía soporte continuo |
| `MALA COORDINACIÓN INTERNA` | Fricciones internas Reinicia: bloqueos entre miembros, retrabajo por falta de información, dependencias mal gestionadas, traspasos incompletos |

⚠️ Cualquier valor fuera de este catálogo (`NO SE TOCA`, `FALTA DE TIEMPO`, `DEPENDENCIAS`, `INCIDENCIA CON HERRAMIENTA`, `NUEVO ALCANCE`) es **inválido**. Si aparece en filas existentes:
1. Si la fila tiene `K < 0` (desvío real): mapear al motivo canónico que mejor describa el desvío.
2. Si la fila tiene `K ≥ 0` (no hay desvío): vaciar la celda (la regla del Paso 7 prohíbe rellenar Motivo cuando no hay sobreesfuerzo).

### Herramientas MCP usadas

- **ClickUp**: `clickup_get_time_entries`, `clickup_resolve_assignees`, `clickup_get_task` (para verificar `time_estimate` y `Tiempo MIN/MAX` de huérfanas), `clickup_filter_tasks` (para listar miembros activos por Equipo).
- **Zoho Workdrive Sheet**: `ZohoSheet_list_all_worksheets`, `ZohoSheet_get_content_of_range`, `ZohoSheet_set_content_to_range`, `ZohoSheet_clear_contents_of_range`, `ZohoSheet_insert_row`, `ZohoSheet_delete_rows`, `ZohoSheet_format_ranges`.

---

## LIMITACIONES TÉCNICAS Y BUGS CONOCIDOS DE ZOHO SHEET

### Limitaciones genéricas

1. **Formato numérico personalizado no soportado en API**: las celdas con fórmula muestran decimales largos (ej. `6,802107778` en lugar de `6,80 horas`). Aceptar.
2. **Inserción fuera de tabla no hereda**: las filas insertadas fuera del rango de Tabla2 no copian formato ni fórmulas. Por eso la regla del Paso 5 obliga a insertar dentro del rango actual de Tabla2 (`start_row+2` a `end_row-1`), y por eso el bloque Metodología (Paso 6) se construye con fórmulas explícitas celda a celda.
3. **Time entries sin task no recuperables**: la validación JSON del MCP falla cuando un entry no tiene `task_id`. Fragmentar el rango temporal hasta aislar la entrada problemática y omitirla. Reportar al PO al final qué entradas no se pudieron recuperar (timestamp, duración aproximada, usuario).
4. **`worksheet_id` varía entre ficheros**: siempre listar primero con `ZohoSheet_list_all_worksheets`.
5. **Las columnas de Tiempos pueden estar desplazadas**: mapear siempre desde la cabecera real (fila 3 en AUTOIA, fila 4 en variantes).
6. **Límite de 50 cells por `cells.content.set`** (error 2908): la API de Zoho Sheet rechaza llamadas con más de 50 celdas en una sola petición devolviendo `"Sorry! Only 50 cells can be updated at once. Please reduce the count and try again."`. Además, el límite efectivo de URL puede provocar `414 Request-URI Too Large` antes de llegar al límite de cells. **Solución operativa**: enviar lotes de **≤40 celdas** por llamada para tener margen de seguridad. Si necesitas escribir 200 celdas, partirlas en 5 lotes consecutivos. Detectado en sesión real al poblar pestañas extensas del Informe Ejecutivo Equipo Proactive.
7. **`worksheet.csvdata.set` interpreta comas dentro de campos como separadores de columna**: si una celda contiene texto largo con comas internas (ej. `"117% / 106% / 103%"` o frases con comas naturales), el motor CSV las trata como separadores y parte el texto en celdas adyacentes. **No hay forma fiable** de escapar las comas vía la API actual (las comillas dobles funcionan a veces pero no siempre). **Solución operativa**: para textos largos con comas internas usar **siempre `cells.content.set`** (max 40 celdas por lote, ver limitación 6) en lugar de `csvdata.set`. Reservar `csvdata.set` para datos puramente tabulares (números, identificadores cortos, palabras sueltas). Detectado en sesión real al poblar pestaña Acciones Equipo del Informe Proactive.

### Bugs específicos detectados en sesiones reales

#### Bug 1 — Col J/K hardcoded en lugar de SUMAR.SI

**Síntoma**: la Col J (ClickUp Registro) de algunas filas muestra valores numéricos literales (`11,45 horas`, `12,63 horas`) en lugar de la fórmula SUMAR.SI canónica. La suma del TOTAL se mantiene "cuadrada" pero el cuadre es engañoso: si en revisiones posteriores cambian las horas reales en Data, la fila no se actualiza.

**Causa**: en algún momento (Sprint Planning manual, ajuste rápido) alguien escribió el valor en lugar de la fórmula.

**Solución**: antes de cualquier validación de cuadre, sustituir TODA la columna J del Sprint Backlog principal por la fórmula canónica:

```
=SUMAR.SI(Tabla1[[#All];[Column20]];Tabla2[@Concepto];Tabla1[[#All];[Horas Traqueadas]])
```

(Detectado en AUTOIA José Sprint 5-26.)

#### Bug 2 — Coma decimal en es-ES vs punto

**Síntoma**: una celda con valor `0.92` se interpreta como **texto** (no número), rompiendo fórmulas SUMA y restas. La celda muestra el valor pero `=SUMA(...)` la ignora o devuelve `#VALUE!`.

**Causa**: Zoho Sheet en configuración es-ES usa coma decimal. Punto decimal escrito vía API (`set_content`) se interpreta como string.

**Solución**: usar siempre coma al escribir números numéricos:
- `0` (entero, válido)
- `0,92` (decimal con coma, válido)
- `0.92` ❌ (texto en es-ES)

(Detectado al escribir Col F de huérfanas y bloque Metodología.)

#### Bug 3 — Carácter `+` perdido al pegar CSV

**Síntoma**: literales con `+` como timestamps `06:09:13+01:00` se transforman en `06:09:13 01:00` (espacio en lugar de `+`) al pegarlos en una celda vía CSV en el campo de fórmula. Como consecuencia, los conceptos del plan que llevan `+` no machean con los de Data y SUMAR.SI devuelve 0.

**Causa**: el motor de pegado de Zoho Sheet interpreta el `+` como operador en algunas rutas de procesamiento.

**Solución**:
- Al rellenar la pestaña Data vía `worksheet.csvdata.set`, los timestamps con `+` ya quedarán sin `+` automáticamente.
- En la columna Concepto del plan / huérfanas en Tiempos, escribir el literal **sin `+`** (con espacio en su lugar) para asegurar match.
- Verificar siempre con `=COINCIDIR(D[fila];Tabla1[Column20];0)` en una celda auxiliar; si devuelve `#N/A!`, el match no funciona.

(Detectado en AUTOIA Fabián Sprint 5-26.)

#### Bug 4 — Mismatch silencioso por NFC/NFD (acentos descompuestos)

**Síntoma**: dos textos visualmente idénticos no machean. SUMAR.SI devuelve 0, MATCH devuelve `#N/A!`. Las celdas tienen el mismo `LEN()` pero la comparación `=A1=A2` da `FALSO`.

**Causa**: los conceptos en Tiempos pueden estar en **NFD** (Normalization Form D — acentos descompuestos: la `ó` es código `o` + combining-acute), mientras los entries pegados desde Python u otra fuente vienen en **NFC** (Normalization Form C — caracter precompuesto). Visualmente idénticos, bytes distintos.

**Solución**:
- Verificar siempre con `=COINCIDIR(D[fila];Tabla1[Column20];0)` antes de aceptar un `0` como válido. Si devuelve `#N/A!` y los textos parecen iguales, hay diferencia NFC/NFD.
- Reescribir la celda en Tiempos copiando el literal exacto desde Data (que viene en NFC). Esto regenera la celda en NFC y restaura el match.
- Conceptos típicamente afectados: cualquiera con tildes (`Configuración`, `Gestión`, `Cualificación`, `Análisis`, `Categorización`).

(Detectado en AUTOIA Alejandro Sprint 5-26 con `[SPIKE] Taller Práctico IA`.)

#### Bug 5 — Fórmula estructurada `Tabla1[@Column11]` rota tras pegado CSV

**Síntoma**: tras un refresco completo de Data vía `worksheet.csvdata.set`, la columna `Horas Traqueadas` (col 57 / BE) en Tabla1 muestra `#NAME?` o `#REF!` en algunas filas. La fórmula `=Tabla1[@Column11]/3600000` debería propagarse automáticamente pero no lo hace en filas pegadas.

**Causa**: el motor de pegado `csvdata.set` rompe la propagación de la fórmula estructurada en celdas que vienen sin valor en la columna de origen, o cuando Tabla1 no se ha extendido correctamente al rango pegado.

**Solución**: usar **fórmula directa por celda** en lugar de la estructurada:

```
=K2/3600000
```

(donde `K` es la letra de la columna `Column11` ms en el mapeo concreto del fichero, no necesariamente la K alfabética — verificar). Aplicar en BE2 y propagar manualmente al resto de filas con `cells.content.set` o `csvdata.set`. Esta fórmula no depende de la integridad de Tabla1 y siempre funciona.

(Detectado en sesión real Sprint 5-26.)

#### Bug 6 — Fórmula `Tabla1[[#All];[Column20]]` cross-sheet pierde matches

**Síntoma**: una fórmula del tipo `=SUMAR.SI(Tabla1[[#All];[Column20]];Tabla2[@Concepto];Tabla1[[#All];[Horas Traqueadas]])` que **referencia Tabla1 desde otra hoja** (Tabla2 está en Tiempos, Tabla1 está en Data o Data Entries) devuelve 0 en lugar del valor esperado, incluso cuando los conceptos coinciden visualmente.

**Causa**: la referencia estructurada cross-sheet `Tabla1[[#All];[Column20]]` no se resuelve correctamente en algunos contextos. Más claramente, la referencia depende del nombre de la tabla y del mapeo de columnas — si Tabla1 se ha redefinido durante el refresco de Data o si la hoja activa es `Data Entries` (no `Data`), el SUMAR.SI silenciosamente devuelve 0.

**Solución**: usar **referencias absolutas explícitas a la hoja correcta** en lugar de la fórmula estructurada cross-sheet:

```
=SUMAR.SI('Data Entries'!$T$2:$T$N;Tabla2[@Concepto];'Data Entries'!$BE$2:$BE$N)
```

donde:
- `'Data Entries'!` es el nombre real de la hoja activa de time entries (puede ser `Data` o `Data Entries`).
- `$T$2:$T$N` es el rango absoluto de la columna Concepto (Column20).
- `$BE$2:$BE$N` es el rango absoluto de la columna Horas Traqueadas.
- `N` es el número real de la última fila con datos.

⚠️ **Mantener `$` en filas y columnas** — sin `$` la fórmula es relativa y al propagar se rompe (ver Bug 7).

(Detectado en sesiones reales Sprint 5-26.)

#### Bug 7 — Propagación de fórmulas relativas en celdas de Tabla2 rompe filas con `T#REF!`

**Síntoma**: tras escribir una fórmula con referencias **relativas** en una celda de Col J de Tabla2 (ej. `=SUMAR.SI('Data Entries'!T2:T58;...)`) y dejar que Zoho la propague al resto de filas, las filas siguientes muestran `T#REF!` o devuelven 0. La auto-propagación incrementa los offsets `T2:T58` → `T3:T59` → `T4:T60`... saliéndose del rango real de datos.

**Causa**: Zoho Sheet propaga las fórmulas siguiendo las reglas de referencia relativa estándar de Excel/Sheets. Si las referencias no llevan `$`, cada fila siguiente desplaza el rango.

**Solución**: usar **siempre referencias absolutas** `$T$2:$T$N` y `$BE$2:$BE$N` cuando se refiere a la hoja de time entries desde Tiempos:

```
=SUMAR.SI('Data Entries'!$T$2:$T$58;Tabla2[@Concepto];'Data Entries'!$BE$2:$BE$58)
```

Si tras una propagación errónea hay filas con `T#REF!`, **reescribir las 30-40 filas afectadas** con la fórmula correcta usando `cells.content.set` por celda (o `csvdata.set` si el bloque es contiguo). Detectado y resuelto en Johanna Sprint 5-26 (34 filas plan + 4 filas Metodología reescritas).

(Detectado en AUTOIA Johanna Sprint 5-26.)

#### Bug 8 — `delete_rows` posicional sin verificación rompe filas adyacentes

**Síntoma**: tras un `ZohoSheet_delete_rows` con índices basados en lecturas anteriores, se borran filas erróneas (filas anteriores se han desplazado por inserciones intermedias y los índices ya no son válidos).

**Causa**: `delete_rows` es **posicional** (no filtrado por contenido). Si entre la lectura y el borrado se han hecho inserciones u otros borrados, los índices están corridos.

**Solución**: **antes de cualquier `delete_rows`**, releer el rango pequeño concreto con `start_row` y `end_row` explícitos para verificar el contenido real de cada fila a borrar:

```python
# 1. Releer rango pequeño con el contenido esperado
content = ZohoSheet_get_content_of_range(start_row=N, end_row=N+M, ...)

# 2. Verificar manualmente que las filas N..N+M contienen lo que se quiere borrar
assert content[0] == "fila esperada 1", "índice corrido — abortar y re-mapear"

# 3. Solo entonces, ejecutar delete_rows
ZohoSheet_delete_rows(row_index_array=[{"start_row": N, "end_row": N+M}], ...)
```

Esta verificación añade ~2-3 segundos por borrado pero evita borrar filas correctas por arrastre de índices.

(Detectado en sesiones de procesamiento masivo donde se combinan inserciones y borrados.)

#### Bug 9 — Texto con `=` inicial en Log de Cambios se interpreta como fórmula

**Síntoma**: al escribir una entrada de Log donde el campo `Valor anterior` o `Valor nuevo` empieza por `=` (típico cuando se documenta una fórmula previa o nueva, ej. `=SUMA(J5:J20)`), Zoho Sheet la interpreta como fórmula y devuelve `#REF!` o `#NAME?` en lugar de mostrar el texto.

**Causa**: Zoho Sheet interpreta cualquier celda que empiece por `=` como fórmula independientemente de si la celda forma parte de una tabla o no.

**Solución**: al escribir entradas de Log con texto que empiece por `=`, **omitir el `=` inicial** o sustituirlo por `[=]` o anteponer un apóstrofe:

```
Antes: =SUMA(J5:J20)
Log:   SUMA(J5:J20)            ← omitir =
       [=]SUMA(J5:J20)           ← sustituir
       'SUMA(J5:J20)             ← apóstrofe escape (no siempre funciona vía API)
```

El apóstrofe es la solución estándar Excel pero algunas rutas del MCP de Zoho lo descartan. La opción más fiable vía API es **omitir el `=` inicial**.

(Detectado en sesiones reales al documentar refactor de fórmulas en Log de Cambios.)

#### Bug 10 — Separador decimal punto en celdas string formato "x,xx horas"

**Síntoma**: al intentar convertir a número una celda con valor visible `"11,77 horas"` (típico de las celdas K acumulado del bloque Metodología), una fórmula simple como `=VALOR(SUSTITUIR(K_celda;" horas";""))` devuelve `#¡VALOR!` o `#VALUE!` en es-ES. La interfaz de Zoho Sheet muestra coma decimal pero **internamente la celda contiene punto decimal** como separador.

**Causa**: las celdas con formato personalizado tipo `0,00" horas"` se almacenan internamente como string `"11.77 horas"` con punto decimal. Aunque la UI muestre coma, `SUSTITUIR` opera sobre el contenido real (punto). Tras `SUSTITUIR(K;" horas";"")`, la fórmula recibe `"11.77"` que `VALOR()` no puede convertir en es-ES (espera `"11,77"`).

**Solución**: aplicar **doble SUSTITUIR** para reemplazar tanto el sufijo como el separador decimal:

```
=VALOR(SUSTITUIR(SUSTITUIR(K_celda;" horas";"");".";","))
```

Resultado: convierte `"11.77 horas"` → `"11.77"` → `"11,77"` → `11,77` numérico, válido para operaciones aritméticas en es-ES.

**Casos afectados**: cualquier celda string con formato `0,00" horas"` que se quiera convertir a número para usar en fórmulas. Detectado al implementar:
- Mejora 1 (balance Metodología: `G_estim - VALOR(SUSTITUIR(SUSTITUIR(K_tracked;" horas";"");".";",")))`).
- Mejora 2 (semáforo proyectivo K_fila_cap+1: misma conversión sobre `K_fila_cap`).

**Deuda técnica documentada**: a futuro convendría refactorizar las celdas string `0,00" horas"` (típicamente `K_fila_cap`, `K_fila_tracked_metod` y similares) a número puro `11,77` con formato celular `0,00" horas"` (formato visual, no string). Eso permitiría operaciones directas sin SUSTITUIR. Mientras tanto, el truco doble SUSTITUIR es la solución pragmática validada.

(Detectado en sesión Sprint 6-26 Día 10 al implementar Mejoras 1 y 2 sobre los 5 AUTOIAs del Equipo Operativo.)

#### Bug 11 — Fallo silencioso de `cell.content.set` (singular) en celdas dentro de tabla

**Síntoma**: al escribir en una celda **dentro del rango lógico de una tabla** (Tabla2 / Tabla21) con `cell.content.set` (singular, `set_content_to_cell`), la operación **no extiende el rango lógico de la tabla** y la SUMAR.SI asociada devuelve **`0,00` silencioso**. Reaparición en Fabián f19 (22/05/2026).

**Causa**: el método singular no registra la celda como parte de la tabla estructurada, por lo que las referencias `Tabla2[@Concepto]` / `Tabla21[@...]` no la "ven".

**Solución (REGLA GENERAL)**: para escribir en **cualquier celda dentro de Tabla2 o Tabla21**, usar SIEMPRE `cells.content.set` (plural, `set_content_to_multiple_cells`), aunque sea una sola celda. El método singular solo se usa para celdas **fuera de tablas** (p. ej. sello `Tiempos!E1`).

(Catalogado junto al Bug 10 en v3.5.)

---

#### Diagnóstico ante 0,00 inesperado en Col J/K de una fila

Si Col J de una fila devuelve `0` pero ClickUp reporta horas reales para ese concepto:

1. ¿Hay tildes? → probar Bug 4 (NFC/NFD) con `=COINCIDIR`.
2. ¿Hay timestamps con `+`? → probar Bug 3 (`+` perdido), reescribir sin `+`.
3. ¿Hay diferencia visible en el literal (espacios, mayúsculas, guiones, prefijos)? → es un caso de rename, ir al Paso 4.
4. Si Col K muestra `#VALUE!` (no `0`) → probar Bug 2 (Col J como texto), reescribir con número numérico.
5. ¿La fórmula referencia `Tabla1[[#All];[Column20]]` cross-sheet? → probar Bug 6, sustituir por `'Data Entries'!$T$2:$T$N` con referencia absoluta a la hoja correcta.
6. ¿Hay `T#REF!` en celdas adyacentes? → probar Bug 7 (propagación relativa), reescribir con `$T$2:$T$N` absoluto.
7. ¿La celda se escribió con `cell.content.set` (singular) dentro de una tabla? → probar Bug 11, reescribir con `cells.content.set` (plural).
8. ¿Hay prefijo `[BORRADO ClickUp]` en la entry de Data? → probar Mejora 7 (PASO 6c): si la tarea existe en ClickUp, quitar el prefijo en ambos extremos.

### Checklist rápido ante errores al escribir muchas celdas

Si recibes un error tipo `"Sorry! Only 50 cells can be updated at once"` o `414 Request-URI Too Large`:

1. ¿Estás usando `cells.content.set` con >40 celdas? → partir en lotes ≤40 (limitación 6).
2. ¿Estás usando `csvdata.set` con textos largos que contienen comas internas? → cambiar a `cells.content.set` por celda (limitación 7).
3. ¿Estás usando `csvdata.set` con valores que empiezan por `=`? → omitir el `=` inicial (Bug 9).

---

## PASO 9 — REPORTE DE EJECUCIÓN A ZOHO CLIQ (solo modo desatendido)

⚠️ **Aplica solo a esta versión desatendida.** La supervisada no envía nada a Cliq porque el PO está delante.

### Destino

- **Canal**: Metodología
- **Herramienta MCP**: `ZohoCliq_Post_message_in_a_channel`
- 🚨 **Parámetro de canal**: la herramienta requiere el **`unique_name`** del canal, **`reiniciametodologa`** — NO el channel ID. El channel ID `T45816000000085077` es solo referencia documental; pasarlo como nombre de canal falla. Validado en el piloto del 31/05/2026.

### Estructura del mensaje

Postear UN único mensaje al cierre con la siguiente estructura. Si el contenido excede el límite de longitud del mensaje, dividir en bloques temáticos (resumen ejecutivo primero, anomalías después).

```
🤖 Revisión automática Sprint Backlogs — [DD/MM/AAAA HH:MM] Madrid

═══ RESUMEN ═══
Sprint: [X-AA]
Equipos procesados: [N] ([lista por nombre])
AUTOIAs actualizados: [N] / [N detectados]
Duración total: [X] minutos
Estado global: ✅ OK / ⚠️ Con avisos / ❌ Con errores

═══ POR MIEMBRO ═══
[Para cada AUTOIA procesado:]
  • [Nombre persona] — [Equipo]
    - Tracked nuevo: [N] entries, [Xh]
    - Cuadre: ✅ OK / ⚠️ Discrepancia [Xmin] / ❌ KO
    - Huérfanas insertadas: [N] ([fuera de plan] + [soporte/WIP])
    - Renames auto aplicados: [N]
    - Renames PENDIENTES validación PO: [N]
    - Motivos desvío auto sugeridos: [N]
    - Sobrecarga detectada: [Sí/No] ([Xh sobre Yh capacidad])

═══ PENDIENTES DE VALIDACIÓN HUMANA ═══
[Si hay renames no triviales o anomalías:]
  ⚠️ [Nombre] fila [N]: posible rename "[plan]" ↔ "[Data candidato]" ([Xh]). Razón: [...]
  ⚠️ [Otros pendientes...]

═══ ANOMALÍAS ═══
[Si hubo errores:]
  ❌ [Persona]: [descripción error y AUTOIA afectado]

═══ AMIGOS REINICIA SIN AUTOIA ═══
[Si hay personas con horas tracked pero sin AUTOIA:]
  • [Persona] — [Xh] tracked en sprint actual. Pendiente decisión PO líder.

Próxima ejecución: mañana [DD/MM/AAAA] 06:00 Madrid (si laborable).
Fuente: skill `revision-sprint-backlog-equipo-reinicia-modo-desatendido` v1.5 / Routine trig_011nrUo4Fx9ugWtZUJTB7rbq.
```

### Casos especiales del reporte

> 🤖 **v1.7 — Reglas de redacción del reporte (verbatim):**
> - **Nombres de persona**: usa EXACTAMENTE el token `<Nombre>` del nombre de fichero `Excel-Clickup-Sprint-NN-AA-<Nombre>`. ⛔ Prohibido inferir, completar o inventar apellidos u otros datos de identidad (en el Run now del respaldo del 07/06 se confabularon apellidos — Bergamelli/Pont/Vargas — que no salían del fichero).
> - **Descripción de flags**: describe cada `TIEMPOS_RENAME_PENDIENTE` o anomalía solo con hechos verificables verbatim (literal del concepto en Tiempos vs literal del nombre en Data). No parafrasees ni interpretes la naturaleza de la diferencia.

- **Día sin entries nuevas en ningún AUTOIA**: postear igualmente con mensaje breve "Sin imputaciones nuevas detectadas en [N] AUTOIAs revisados. Cuadre actual conservado". Esto confirma al Equipo que la routine corrió, aunque no haya tocado nada.

- **Día con anomalías estructurales que abortan la ejecución**: postear el error y la causa, con sugerencia de qué hacer manualmente. Ejemplo: "❌ Carpeta sprint actual no encontrada en Workdrive. Revisar manualmente la ubicación de los AUTOIAs antes de relanzar".

- **Día con discrepancias de cuadre >30 minutos en algún AUTOIA**: **NO cerrar ese AUTOIA** (no escribir sello E1 ni Log final). Postear el caso en Cliq con detalle del entry-by-entry para que el PO líder lo revise antes del próximo procesamiento.

### Trazabilidad

Cada mensaje de reporte incluye al final una línea con `Fuente: skill ... v1.5 / Routine trig_011nrUo4Fx9ugWtZUJTB7rbq` para que el Equipo sepa identificar qué versión generó el mensaje y poder rastrear bugs.

---

## VERSIONES

### Versiones de esta skill (modo desatendido)

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v1.0 (desatendido)** | 2026-05-17 | Néstor + Claude | Primera versión desatendida. Duplicado de `revision-sprint-backlog-equipo-reinicia` v3.4 + PASO 0 BIS con 7 overrides para automatización en Claude Code Routine + PASO 9 de reporte a Zoho Cliq (canal Metodología `T45816000000085077`). Sin preguntas humanas: detección dinámica de Equipos por nombre de espacio ClickUp + presencia de AUTOIA en carpeta sprint; refresco incremental Opción D forzado; renames Opción B (triviales auto + no triviales a Log + Col N); motivos desvío con sugerencia automática por heurística; alertas acumuladas en reporte Cliq. Sincronizada con v3.4 supervisada. |
| **v1.1 (desatendido)** | 2026-05-26 | Néstor + Claude | Sincronización con la supervisada v3.5. Incorpora el **PASO 6c con 10 mejoras de integridad y trazabilidad** (M5 cuadre contra ClickUp API en vivo con umbrales escalonados; M6 refresco Col D Status estatus nativos sin unificaciones; M7 limpieza `[BORRADO ClickUp]`; M8 limpieza global + estructura de 3 bloques + colchón ≥3 filas; M9 atribución NÉSTOR-PO vía Col M con saltos de línea; M10 cierre atómico con doble sello; M11 enlaces HYPERLINK con match triple umbral + doble renombrado; M12 refresco retroactivo completo; M13 anomalía API con fragmentación binaria; M14 duplicados de cliente) + **Bug 11** (`cell.content.set` singular falla dentro de tabla). **Override 2 DEROGADO por la Mejora 12**: el modo desatendido pasa de refresco incremental Opción D a **refresco retroactivo completo** (decisión Néstor 26/05: prioriza no perder información sobre coste de tool calls). Todos los puntos de las mejoras que en supervisado reportan al PO → en desatendido **acumulan para el reporte Cliq** (canal Metodología `T45816000000085077`) sin interrumpir el pase; bloqueo de cuadre >0,5h marca la persona como NO CERRADA y continúa con el resto del Equipo. `synced_from_supervised_version: v3.5`. |
| **v1.2 (desatendido)** | 2026-05-30 | Néstor + Claude | Sincronización con la supervisada v3.6. Incorpora la **Compuerta de sellado — Definición de Hecho (DoD)** en el PASO 8b (Mejora 10): **Mejora 11 (enlaces HYPERLINK) añadida como ítem explícito (a-bis)** del checklist atómico, y compuerta determinista antes del doble sello — computar (a) estatus Col D, (a-bis) enlaces, (b) cuadre, (c) colchón, (d) Log; **registrar el resultado ✅/❌ por ítem en el Log (`DOD_CIERRE`) y en el reporte Cliq**; si cualquier ítem (a)–(d) resulta ❌, NO sellar, marcar la persona como NO CERRADA (DoD incompleta) en Cliq y continuar con el resto del Equipo (Override 7). Verificación de que el `K` de cada fila enlazada no cae a 0. `synced_from_supervised_version: v3.6`. |
| **v1.3 (desatendido)** | 2026-05-31 | Néstor + Claude | **Sincronización con la supervisada v3.7 + arranque del automatismo (pilotos en seco Fabián y Paolo, Sprint 7-26).** (A) Añadida la sección **«⚙️ Configuración del automatismo en Claude Code (Routine)»** (repo `agencia-reinicia/claude-skills`, cron `0 6 * * 1-5` → 06:00 Europe/Madrid, prompt de disparo, conectores MCP y permisos ClickUp/Workdrive/Cliq, alcance, checklist pre-piloto, hueco `routine_id`); corregidas las referencias horarias 7AM/07:03 → **06:00**. (B) **Override 1 reescrito**: detección **determinista** de la carpeta del sprint vigente (raíz `i6aloc…`, regex `^Sprint\s+0?(\d+)\s*-\s*0?(\d+)$`, mayor (año,N), **cross-check contra ClickUp → ABORTAR si no coincide/empate/0**, eliminado el ID hardcodeado `8zev…`); **patrón de fichero `^Excel-Clickup-Sprint-\d+-\d+-(.+)$`** (NFC) en vez de `*AUTOIA*`; **allowlist de piloto `[Fabián, Paolo]`** (excluida «Camila»). (C) **PASO 6c — Resolución producto→tarea**: prioridad HYPERLINK Col E → lista del cliente + match EXACTO → asignado solo desempate; artefacto `resolucion[]`; desambiguación por tag de sprint + asignado; `MATCH_AMBIGUO` y `PRODUCTO_NO_RESUELTO` a Cliq sin adivinar; Mejora 6 escribe Col D **solo desde status_vivo** (prohibido snapshot del time entry); Mejora 11 HYPERLINK portante del `url` resuelto; **ceremonias de cierre (Planning/Retro/Daily) al sprint entrante**. (D) **Compuerta DoD por evidencia**: recomputa `n_plan/n_resueltas/n_drifts/n_resolubles/n_enlazadas/n_ambiguas`; (a) ✅ solo si `n_resueltas==n_plan` y `n_ambiguas==0`; (a-bis) ✅ solo si `n_enlazadas==n_resolubles`; **prohibido sellar si (a) o (a-bis) <100%**; NO CERRADA con detalle de productos a Cliq y continuar. `synced_from_supervised_version: v3.7`. |
| **v1.4 (desatendido)** | 2026-05-31 | Néstor + Claude | **Corrección tras el primer Run now del piloto (Fabián y Paolo, Sprint 7-26).** El dry-run selló E1/M1 con (a)/(a-bis) en parcial, "conservando estatus/enlaces del pase previo" — justo lo que la compuerta debe impedir (y siendo el primer pase del sprint, no había pase previo). Cambios: (1) **Ejecución obligatoria en cada pase** — Mejoras 6 (Col D) y 11 (HYPERLINK) se ejecutan fila a fila desde `resolucion[]` en CADA pase; PROHIBIDO "conservar del pase previo"; los conteos miden ESTE pase. (2) **Compuerta DoD sin "sello parcial"** — o (a)–(d) al 100% y se sella, o NO CERRADA sin escribir E1/M1; documentar un parcial NO autoriza a sellar. (3) **Cliq por `unique_name`** — `ZohoCliq_Post_message_in_a_channel` usa `reiniciametodologa`; el channel ID `T45816000000085077` queda solo como referencia. `synced_from_supervised_version: v3.8`. |
| **v1.5 (desatendido)** | 2026-06-06 | Néstor + Claude | **Sincronización con la supervisada v3.9 (lote de endurecimiento tras la semana de piloto Fabián+Paolo).** (1) **Mejora 6 vía `filter_tasks` por tag de sprint en lote** en vez de N× `clickup_get_task` — menos llamadas y mucha menos exposición a 502 (validado en el piloto); `get_task` solo para lo que no salga en el filtro. (2) **Alcance acotado del refresco de Col D por cadencia**: pase diario solo refresca filas con actividad o resolución cambiada; refresco del 100% en el pase semanal/cierre; el reporte Cliq declara el alcance aplicado. La compuerta DoD (a) sigue exigiendo resolución completa en todos los pases. (3) **Invalidación del sello previo si la DoD falla** (punto 7 del PASO 8b): si una persona queda NO CERRADA y tenía sello previo, se sustituye `E1`/`M1` por `NO CERRADA — [fecha] — DoD incompleta` (automático, sin PO) + `DOD_CIERRE` en Log — el automatismo no depende de limpieza manual. (4) **Resiliencia de conector** (Override 7): backoff/reintento (≈30/60/120s) antes de declarar abort estructural, reintento de 502 aislados durante el pase, y **2ª Routine de respaldo** (sugerida 09:00) idempotente que rescata el día si el pase de las 06:00 abortó. (5) **`routine_id` real** del pase principal (`trig_011nrUo4Fx9ugWtZUJTB7rbq`) en el PASO 9 y la línea `Fuente`. `synced_from_supervised_version: v3.9`. |

### Historial heredado de la skill supervisada origen

> ⚠️ Las versiones v1.0 a v3.4 son del historial de la skill **supervisada** (`revision-sprint-backlog-equipo-reinicia`) y se conservan como contexto evolutivo. Cuando la supervisada saque v3.5, v4.0, etc., se sincronizará a esta desatendida y se añadirá una nueva fila v1.x (desatendido) en la tabla superior.

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v1.0** | 2026-05-03 | Néstor + Claude | Primera versión. Validada con Paolo Bergamelli en Sprint 05-26 (cuadre 74,33h al céntimo). Incluye flujo completo de 8 pasos, gestión de Log de Cambios, clasificación A/B/C de huérfanas con keywords. |
| **v2.0** | 2026-05-03 | Néstor + Claude | Skill agnóstica de personas concretas (búsqueda dinámica desde ClickUp). Soporte para Amigos Reinicia sin Sprint Backlog Zoho. Validación PO obligatoria de emparejamientos en renames. Nueva regla Col F priorizando estimado-persona-sprint, con fallback a horas reales si nada informado. Alerta proactiva de sobrecarga al PO. **Nuevo Paso 7**: rellenar Motivo desvío (dropdown: MALA ESTIMACIÓN / PARKING / NO ESTIMADO / COORDINACIÓN CLIENTE / MALA COORDINACIÓN INTERNA) y Comentario en filas con J<0. Aclaración explícita sobre `time_estimate` ClickUp ≠ estimado-persona-sprint. Mención a futura skill aparte de Informes Ejecutivos. Etiqueta "Mejoras Propuestas Skill Sprint Backlog: documentar en Reinnova ClickUp". |
| **v3.0** | 2026-05-03 | Néstor + Claude | Revisión integral tras procesamiento real de 4 AUTOIAs (José, Alejandro, Johanna, Fabián) en Sprint 5-26. **Reorganización de pasos**: Paso 2 simplificado a solo recopilación; Paso 3 reescrito con tres opciones al PO (A: Claude borra/B: PO borra/C: ya está bien) sobre la pestaña Data original (NO se crean pestañas auxiliares). **Nuevo mapeo de columnas** correcto: F=Estim, J=Registro, K=Diferencia, L=Motivo, M=Comentario; cabecera fila 3 AUTOIA / 4 variantes; añadidas Col A (Marca) y Col B (Orden). **Eliminado Grupo C**; clasificación reducida a A vs B con sub-marcas en Col A: `🤖 Fuera de plan` (productos digitales nuevos, gestiones cliente/Reinicia, SPIKEs, incidencias) y `🤖 Soporte/WIP` (microtareas reactivas: `[SUPPORT]`, `[ASSUMED]`, `[BUG]`, Form Submission). **Inserción de huérfanas Grupo B DENTRO de Tabla2** con regla `start_row+2` a `end_row-1`, separadores visuales obligatorios, M=N+2 filas a insertar, verificación post-inserción de `end_row` extendido. **Patrón especial Opción B** validado para productos plan agregados (ej. `Soporte Carritech`) + desglose individual paralelo: agregado con J=0 numérico + NO SE TOCA, individuales como huérfanas B-Soporte/WIP con SUMAR.SI canónica y F=0. **Bloque Metodología APARTE de Tabla2** (no dentro), F=0 numérico (NO estimación retroactiva), fórmula SUMAR.SI con `D[fila]` directa (no `Tabla2[@Concepto]`). **Renames con criterio NO renombrar**: 4 criterios objetivos (ambos literales en Data, cambio de alcance, cliente distinto, decisión PO), formato presentación con casos `✅ rename limpio` / `⚠️ posible producto distinto`, nuevo log type `TIEMPOS_RENAME_RECHAZADO`. **Sección consolidada de bugs Zoho Sheet**: 5 limitaciones genéricas + 4 bugs específicos (Bug 1: Col J/K hardcoded → SUMAR.SI canónica; Bug 2: coma decimal es-ES vs punto; Bug 3: `+` perdido al pegar CSV; Bug 4: NFC/NFD silencioso) + checklist rápido ante 0 inesperado en Col J. **Sello de actualización** en Tiempos!D1 y Log de Cambios!M1 con texto `Última actualización (skill): DD/MM/AAAA HH:MM — Sprint X-YY`, alto fila 45pt en Tiempos. **TablaLog formal** sobre Log de Cambios con `template MEDIUM2` + `color #3812CF` + Manrope 10 + alto 22pt + cabecera `#D9D0FB`/`#3812CF`; bandeo manual fila a fila (`#EBEBEB`/`#FFFFFF`) tras cada inserción para sortear el bug que el `template MEDIUM2` no garantiza bandeo visible cuando hay celdas con fill previo. Limitación documentada: Zoho asigna nombre de tabla automáticamente (no hay método rename_table). **Nuevo Paso 8b** de cierre con sello + bandeo final. Nuevas operaciones de Log: `TABLA_LOG_CREADA`, `SELLO_ACTUALIZACION`, `TIEMPOS_RENAME_RECHAZADO`. Validada con AUTOIAs Fabián, Alejandro, Johanna, José Sprint 5-26. |
| **v3.1** | 2026-05-05 | Néstor + Claude | Actualización menor con 10 hallazgos de la sesión de refresco al 05/05/2026 de los 4 AUTOIAs (Alejandro, Fabián, José, Johanna) y generación de Informes Ejecutivos por Equipo (Columbia y Proactive). **5 bugs específicos nuevos**: Bug 5 (fórmula estructurada `Tabla1[@Column11]` rota tras CSV paste → usar `=K2/3600000` directa); Bug 6 (referencia cross-sheet `Tabla1[[#All];[Column20]]` pierde matches → usar `'Data Entries'!$T$2:$T$N` absolutas); Bug 7 (propagación de fórmulas relativas en celdas Tabla2 rompe filas con `T#REF!` → siempre `$T$2:$T$N`, validado con Johanna 34 filas reescritas); Bug 8 (`delete_rows` posicional sin verificación → releer rango pequeño con start/end explícitos pre-borrado); Bug 9 (texto con `=` inicial en Log se interpreta como fórmula → omitir el `=`). **2 limitaciones genéricas nuevas**: límite de 50 cells por `cells.content.set` (error 2908) y URL 414 → lotes ≤40 cells; `worksheet.csvdata.set` interpreta comas internas como separadores → usar `cells.content.set` para textos con comas naturales. **Mejoras de proceso**: variante hoja `Data` vs `Data Entries` documentada (algunos AUTOIAs tienen tabla viva en `Data Entries` mientras `Data` queda vacía); 4 variantes de mapeo de columnas detectadas en Sprint 5-26 (Alejandro/Johanna estándar, Fabián fila 3 con `Comprometido`, José fila 4 con `Comprometido`); nueva opción **(D) refresco incremental quirúrgico** en Paso 3 para revisiones frecuentes con pocas entries nuevas (validada con Alejandro 1 entry, ~5 min vs ~30 min); patrón "renombrar al canon ClickUp completo con referencia a celda" para conceptos cortados en plan vs nombre largo en ClickUp (lección Johanna fila 32, 152 caracteres). Nueva operación de Log: `DATA_PASTE_INCREMENTAL`. Validada en sesión real Sprint 5-26 al 05/05. |
| **v3.2** | 2026-05-06 | Néstor + Claude | Consolidación de 8 aprendizajes de la **sesión piloto de homologación de plantilla nueva con AUTOIA Fabián Vargas** (Sprint 5-26). **Correcciones críticas**: (1) **Catálogo de Motivos de Desvío CERRADO a 5 valores** (MALA ESTIMACIÓN, PARKING, NO ESTIMADO, COORDINACIÓN CLIENTE, MALA COORDINACIÓN INTERNA) — eliminados NUEVO ALCANCE, DEPENDENCIAS, FALTA DE TIEMPO, INCIDENCIA CON HERRAMIENTA; renombrado COORDINACIÓN INTERNA → MALA COORDINACIÓN INTERNA; "NO SE TOCA" NO es motivo válido. Catálogo añadido a Recursos Clave y referenciado en pestaña `Motivos Desvío` (4ª hoja canónica del Sprint Backlog, fuente de verdad). (2) **Regla CRÍTICA Col L (Motivo desvío)**: solo se rellena cuando J > G (Col K negativa). Si J ≤ G, Col L y Col M VACÍAS siempre — la columna no documenta "desvíos positivos" ni filas en curso. **Ajustes de comportamiento**: (3) **Etiqueta Col A en huérfanas = `column_index = 1` real**, no la primera columna con datos visibles (bug crítico detectado con Fabián: etiquetas escritas en col 2 quedaron desplazadas). Verificar siempre con get_content empezando en start_column=1. (4) **Patrón Opción B agregado**: eliminado "Aplicar NO SE TOCA en Col L" — el agregado tiene K positivo (J=0, G=8h), Col L y M quedan vacías; el comentario explicativo va solo en Col M. Las huérfanas Soporte/WIP individuales con J>0 reciben sugerencia automática `NO ESTIMADO` en Paso 7. (5) **Sello de actualización en E1** (no D1) con formato canónico **Manrope bold 14pt color #3812CF**, hora completa **hh:mm:ss** (no solo fecha) para precisar versión del fichero. (6) **Log de Cambios estilo simplificado**: TODAS las filas con fondo `#EBEBEB` uniforme + borde blanco `#FFFFFF` solid, sin bandeo intercalado gris/blanco. Cabecera fila 1 conserva estilo de tabla. **Verificaciones de cierre que sustituyen aplicaciones globales**: (7) **Manrope NO se aplica global**, solo se VERIFICA con muestra (la plantilla maestra ya viene con Manrope por defecto — aplicar Manrope global era trabajo desperdiciado). (8) **Encabezado de Tabla1 en Data tiene formato propio** (fondo blanco, fuente Manrope bold #3812CF, borde inferior solid #3812CF) — NO sobrescribir en ningún paso; si se recrea Tabla1, capturar formato pre y reaplicar post (o mejor: no recrear nunca, autoextender). **Documentación**: (9) Pestaña `Motivos Desvío` añadida como 4ª hoja canónica leída como referencia, no modificada. (10) Catálogo de motivos en sección Recursos Clave para acceso rápido. Validada con piloto AUTOIA Fabián Vargas 06/05/2026. **Próximo paso**: duplicación a `revision-sprint-backlog-equipo-reinicia-modo-desatendido` v1.0 con optimizaciones operativas (caché time entries compartida, batch, sin recreación tablas, log diferido, sin preguntas) — Fase 2 del plan de evolución. |
| **v3.3** | 2026-05-08 | Néstor + Claude | **Consolidación de aprendizajes piloto Sprint 6-26 Días 1-2** (5 AUTOIAs procesados: Fabián, José, Paolo, Alejandro, Johanna). Mejora de eficiencia ~70% en tool calls y tiempo por persona vs Sprint 5-26 (de 30-45 min a 5-15 min/persona). **Adiciones canónicas Día 1**: (1) Sección **PLANTILLA NUEVA SPRINT 6-26 — ESTRUCTURA CANÓNICA** (4 pestañas predefinidas, Tabla21 canónica, fórmulas de fábrica, capacidad prepoblada G66, mapeo Tabla2 +1 col Comprometido). (2) Sección **SUB-MARCAS COL A — REGLA CERRADA** con `🤖 Fuera de plan` y `🤖 Soporte/WIP`. (3) Sección **HUÉRFANAS — DATOS OBLIGATORIOS DESDE CLICKUP** (Col A/D/E/F/G=0,00/H/M=NO ESTIMADO/N obligatorios). (4) Sección **ATRIBUCIÓN DE SUBTAREAS — REGLA CANÓNICA** (Opción A: subtareas tributan al producto padre del plan, validado con Johanna). (5) Sección **BUG UNICODE EN SUMAR.SI** (caracteres prohibidos `↔ ⟷ → ←`, política de tildes en strings largos). (6) Limitación **Trocear set_content_to_multiple_cells ≤ 40 celdas/llamada**. **Simplificaciones de pasos Día 1**: (7) Sub-pasos 1a/1b deprecados para Sprint 6-26+. (8) Paso 3 modo minimalista por defecto (Col20 + Col57). (9) Paso 5 modo simplificado (set_content_to_cell directo a fila vacía). (10) Paso 6 con Tabla21 canónica. (11) Paso 8b sin bandeo manual. **Adiciones canónicas Día 2**: (12) Sección **COLUMNA J FACTURABLE — REGLA CANÓNICA** con matriz cerrada de 9 casos (`"Sí"`/`"No"`): productos cliente Sí, productos Reinicia/Reinnova No, huérfanas cliente Sí, huérfanas Reinicia No, ceremonias No (Daily, Sprint Planning, Retrospective, Sprint Review), Refinamiento Sí (excepción), Gestión Reinicia interna No, Gestión Cliente Sí. Migración de fórmulas D72/D73 de criterio histórico `"F"`/`"nF"` a `"Sí"`/`"No"` con localización dinámica de filas (varía por AUTOIA: Fabián 72-73, Paolo 73-74, Alejandro 73-74, Johanna 72-73, José 51-52). Plantilla maestra ya actualizada por PO líder. (13) **Excepción crítica en HUÉRFANAS**: Gestiones Cliente NUNCA van a Tabla2; van directamente a Tabla21 Bloque B. La capacidad operativa G71 ya descuenta Gestión + Metodología (~20-30%). Validado con José (Gestión Lider System) y Alejandro (Gestión Exeltis). (14) **Estructura Tabla21 con Bloque A + separador + Bloque B**: Bloque A = Metodología pura (ceremonias + Gestión Reinicia interna, Col J=No salvo Refinamientos=Sí); fila vacía separadora; Bloque B = Gestiones Cliente (Col J=Sí). (15) Nueva sección **REGLA DEL DELTA Y VALIDACIÓN DE CUADRE**: para procesamientos día N+1 con día N ya escrito, calcular `filas_a_añadir = entries_total_periodo - filas_Data_ya_escritas`; NO confundir con "entries del día N+1". Validación obligatoria de cuadre antes de cerrar: `|cuadre_AUTOIA - ClickUp.total_duration| <= 2 minutos` (margen aceptable de redondeo); >30 min = no cerrar hasta repaso entry-by-entry. Validado tras detectar duplicación silenciosa en Alejandro (4 filas DataPrep cuando ClickUp tenía 3 entries → 30 min de exceso silencioso). (16) **Insight nuevo para Informe Ejecutivo**: matriz 2×2 estimado/real × facturable/no facturable cruzada Tabla2 + Tabla21, con métricas derivadas (% facturable plan, % facturable real, % utilización facturable, brecha). Implementación pendiente en skill `informes-ejecutivos-sprint-backlog-equipos-reinicia` (Opción C: solo en Informe Ejecutivo este sprint, plantilla maestra futura podría incluir bloque "Resumen Facturable" pre-calculado). **Adherencia explícita**: antes de añadir cualquier huérfana releer SUB-MARCAS COL A + HUÉRFANAS — DATOS OBLIGATORIOS + COLUMNA J FACTURABLE. Validada con 5 AUTOIAs Sprint 6-26 Días 1-2, cuadre exacto al céntimo en cada uno tras corrección manual del fallo de delta (margen aceptado <2 min por redondeo). **Plan**: continuar pilotando v3.3 durante el sprint actual antes de duplicar a `revision-sprint-backlog-equipo-reinicia-modo-desatendido` v1.0. |
| **v3.4** | 2026-05-16 | Néstor + Claude | **Consolidación de aprendizajes Sprint 6-26 Día 10** (5 AUTOIAs revisitados: Fabián, Paolo, José, Alejandro, Johanna). **Nuevo PASO 6b — Mejoras de cierre canónico**: cuatro mejoras visuales y analíticas obligatorias aplicadas tras el procesamiento estándar. (1) **Mejora 1 — Balance Metodología corregido + semáforo H**: la celda balance Metodología histórica calculaba `0-estimadas` (bug en plantilla maestra), reemplazada por `=G_estim - VALOR(SUSTITUIR(SUSTITUIR(K_tracked;" horas";"");".";","))` + semáforo H con umbrales 75%/100% (🟢/🟠/🔴). Etiqueta canónica D: `"TOTAL BALANCE  HORAS METODOLOGÍA Y GESTIÓN"` con doble espacio literal entre BALANCE y HORAS. (2) **Mejora 2 — Celdas auxiliares de fechas + semáforo proyectivo K_fila_cap+1**: insertar 4 filas (Fecha inicio Sprint / Fecha fin Sprint / Días laborables totales / Días laborables transcurridos) antes de cabecera Metodología, alimentando un semáforo proyectivo `K_(fila_cap+1)` con fórmula `tracked/dias_transcurridos*dias_totales` vs `G_fila_cap` (capacidad). Umbrales 90%/100% (🟢 OK al ritmo actual / 🟠 Cerca del límite / 🔴 Sobrepaso previsto). (3) **Mejora 3 — Pestaña "Motivos desvío" renombrada a "Leyenda"**: reemplaza la pestaña 4ª canónica con un documento completo de 6 secciones (Semáforos visuales / Celdas auxiliares / Sub-marcas huérfanas / Atribución NÉSTOR-PO / Catálogo Motivos / Convenciones), estilos canónicos marca Reinicia (azul `#3812CF`, accent `#D9D0FB`, grey `#EBEBEB`, Manrope), las referencias de celda adaptadas a cada AUTOIA. (4) **Mejora 4 — Col C Tabla21 NUNCA se rellena**: regla canónica añadida; limpiar valores hardcoded tipo `"Sprint 6-26"` al cierre. **Nuevo Bug 10 — Separador decimal punto en celdas string "x,xx horas"**: las celdas con formato personalizado `0,00" horas"` se almacenan internamente con punto decimal (no coma), por lo que `=VALOR(SUSTITUIR(K;" horas";""))` falla en es-ES. Solución validada: doble SUSTITUIR `=VALOR(SUSTITUIR(SUSTITUIR(K;" horas";"");".";","))`. Deuda técnica documentada: refactor futuro a número puro con formato visual. **Adaptación al layout no normalizado**: sección explícita advirtiendo que cada AUTOIA tiene posiciones distintas para `fila_cap` (Fabián 65, Paolo 63, José 69, Alejandro 69, Johanna 70) y `fila_metod_header` (Fabián 79, Paolo 73, José 79, Alejandro 79, Johanna 80). La skill mapea dinámicamente con `get_content_of_range` antes de aplicar las Mejoras. **Orden estricto de aplicación**: Mejora 1 → Mejora 4 → Mejora 2 (inserciones autoajustan fórmulas Mejora 1) → Mejora 3 (con referencias ya reposicionadas). **Pestaña Leyenda**: actualizada en la tabla de pestañas canónicas del Sprint Backlog (sustituye a `Motivos desvío` de v3.2-v3.3). Validada en los 5 AUTOIAs del Equipo Operativo Sprint 6-26 Día 10 (16/05/2026), todos 🟢 OK al ritmo actual y 🟢 OK Metodología. |
| **v1.6 (desatendido)** | 2026-06-06 | Néstor + Claude | **Apertura del automatismo al Equipo (deroga la allowlist de piloto).** Override 1.2: de allowlist `[Fabián, Paolo]` a **lista de exclusión** — procesa todos los AUTOIA del patrón 1.1 (Equipo Operativo completo + POs Pablo Losada y Óscar Díez) **excepto** `EXCLUIDOS=["Síntaris"]` (se omite con match case/acento-insensible y se reporta en Cliq, por la casuística de la columna AK "Situación" aún no soportada → se sigue procesando supervisado). Altas nuevas auto-incluidas; sin allowlist de inclusión. Sección «Alcance» actualizada. `synced_from_supervised_version: v3.9` (la supervisada no cambia: no tiene allowlist). |
| **v1.6.1 (desatendido)** | 2026-06-07 | Néstor + Claude | **Limpieza de consistencia (sin cambio de lógica).** Eliminados los pins a un sprint/carpeta concretos que contradecían la detección dinámica: «Sprint objetivo» y checklist pasan a «sprint vigente» (Override 1.0); ejemplo fechado y ejemplo de nombre de fichero neutralizados; el prompt documentado pasa de «allowlist de piloto si está activa» a «lista de exclusión (Override 1.2)». Validado el alcance abierto en Run now del 07/06/2026 (9 detectados · Síntaris omitido · 8 procesados). `synced_from_supervised_version: v3.9`. |
| **v1.7 (desatendido)** | 2026-06-07 | Néstor + Claude | **Robustez de match y honestidad del reporte (tras el Run now de respaldo del 07/06).** (1) Antes de marcar `TIEMPOS_RENAME_PENDIENTE`: normalizar la fórmula K a la canónica estructurada `=SUMIF(Table1[[#All];[Column20]];Tabla2[@Concepto];Table1[[#All];[Horas Traqueadas]])` (⛔ nunca rangos A1 truncados tipo `$Data.$T$2:$T$33`, que dan K=0 falso cuando la entry cae fuera del rango — caso Óscar Díez f15, entries en filas ~60/67) y normalizar carácter invisible (NFC/ASCII) si Tiempos y Data son visualmente idénticos pero SUMAR.SI=0. (2) Detección de rename SIMÉTRICA: substring **o** superstring tras normalizar espacios — cubre prefijo/cualificador (`Implementación Modelo de Datos` ⊃ `Modelo de Datos`), no solo sufijo; corrige el caso José f21 que el detector v1.6 dejó en `PRODUCTO_NO_RESUELTO` + huérfana duplicada. En desatendido se sigue solo flaggeando (nunca auto-fusión). (3) Reporte Cliq honesto: nombre de persona = token EXACTO del fichero `Excel-Clickup-Sprint-NN-AA-<Nombre>` (prohibido inventar apellidos) y descripción de flags solo verbatim. `synced_from_supervised_version: v3.10`. |

---

## PENDIENTES DE EVOLUCIÓN

- **Aplicar la skill directamente sobre Sprint Backlogs oficiales sin duplicar AUTOIA** (cuando se valide el flujo en todo el equipo).
- **Tabla canónica de "Metodología y Gestión"** dentro del Sprint Backlog (a incorporar en la plantilla del próximo Sprint Planning). Cuando esté disponible, esta skill se actualizará para insertar filas dentro de esa tabla — equivalente al manejo actual de Tabla2 — eliminando la construcción manual del bloque y heredando formato Reinicia automáticamente. Ver Paso 6 para detalle del comportamiento provisional actual.
- **Skill aparte de Informes Ejecutivos por Equipo** que consuma los datos producidos por esta skill.
- **Ampliar lista de keywords** para clasificación de huérfanas conforme aparezcan casos nuevos.
- **Consultar dinámicamente Equipos desde ClickUp** (espacios y asignaciones) en lugar de mantener lista fija.
- **Detección automática de personas transversales** (presencia en varios Equipos) y propuesta al PO.
- **Normalizar plantilla maestra para layout idéntico entre AUTOIAs (v3.4+)**: incorporar a la plantilla maestra las Mejoras 1-4 del PASO 6b para que vengan de fábrica y desaparezca la necesidad de aplicarlas manualmente cada sprint. Una vez normalizado el layout (mismas filas para `fila_cap`, `fila_metod_header`, etc. en todos los AUTOIAs), eliminar el mapeo dinámico previo del PASO 6b.
- **Refactor de celdas string "x,xx horas" a número puro (v3.4+)**: las celdas K_tracked acumulado y similares se almacenan internamente como string con punto decimal, exigiendo doble SUSTITUIR (Bug 10). Refactor pendiente a número puro con formato visual `0,00" horas"` para permitir operaciones aritméticas directas y eliminar el truco SUSTITUIR.
