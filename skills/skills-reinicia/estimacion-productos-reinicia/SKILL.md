---
name: estimacion-productos-reinicia
description: >
  Skill para que los POs de Reinicia (de Cliente y Técnicos) estimen el esfuerzo de un
  producto o microcampaña (General o Soporte) antes de comprometerlo, a partir de lo solicitado por
  el Cliente o de un SPIKE aprobado (Diseño Funcional). Descompone el trabajo en subtareas con horas
  (PERT), busca productos similares en ClickUp, pregunta quién ejecuta cada subtarea y calcula la
  tasa de desvío personal de cada ejecutor (real vs. estimado) para devolver DOS cifras: estimación
  de referencia (cara cliente) y dedicación realista (interna); el Motivo de Desvío enruta qué
  sobrecoste es facturable. Escribe MIN/MAX y time_estimate en horas (pasos de 0,5h), deja un
  comentario de aprobación al PO en la Gestión del mes y, tras el OK, alimenta la propuesta en Zoho
  CRM. Outputs en ES o EN según el cliente. Actívala cuando el PO pida "estima este producto",
  "cuántas horas lleva [desarrollo]", "estima lo que pidió [CLIENTE]", "estima el SPIKE de [X]", o al
  cerrarse un SPIKE. No crea productos ni cierra propuestas; las alimenta.
---

# SKILL: Estimación de Productos — Reinicia
## Estimación de esfuerzo a partir de una solicitud de Cliente o de un SPIKE aprobado

> **Versión vigente: v0.2 — 21/06/2026**
> ⚠️ Versión funcional **pendiente de calibración** tras el primer ciclo real. El método y el flujo
> están cerrados; los coeficientes (tasa por tipo, contingencia aditiva) y la unidad efectiva de
> `time_estimate` se afinan con los datos de los primeros usos.

---

## Propósito

Dar a los Product Owners una forma **repetible, defendible y trazable** de estimar un producto o
microcampaña antes de comprometerlo con el Cliente o de planificarlo en un sprint, separando lo que
el trabajo **debería costar** de lo que **realmente va a costar** según quién lo ejecute.

La estimación es el punto débil histórico del flujo de Reinicia: el catálogo de **Motivos de
Desvío** (`MALA ESTIMACIÓN`, `NO ESTIMADO`, `COORDINACIÓN CLIENTE`, `MALA COORDINACIÓN INTERNA`,
`PARKING`) existe porque las desviaciones se repiten. Esta skill convierte esos datos en aprendizaje:
ancla cada estimación en lo que productos similares costaron de verdad, ajusta por la **tasa de
desvío personal** de cada ejecutor y usa el Motivo de Desvío para decidir qué sobrecoste es
legítimamente facturable al cliente y cuál es un problema interno de calibración.

La skill **no crea productos** (lo hacen `productos-digitales-*-clickup-reinicia`) ni **cierra
propuestas comerciales** (`propuesta-comercial-zoho-crm-reinicia`). Es el eslabón entre el
refinamiento/cierre de SPIKE y la propuesta cerrada o el Sprint Planning.

---

## Las DOS cifras (concepto central)

| | **Estimación de REFERENCIA** | **Dedicación REALISTA** |
|---|---|---|
| Responde a | Lo que el trabajo *debería* costar | Lo que *de verdad* va a llevar |
| Cómo se calcula | PERT + reference class (productos similares) | Referencia × **tasa de desvío personal** del ejecutor |
| Para quién | Cara cliente → **propuesta** (Zoho CRM) | Interna → **Sprint Planning / capacidad** |
| Dónde se escribe | Cifra base del Deal en Zoho CRM | `MIN`/`MAX`/`time_estimate` del producto en ClickUp |

**El Motivo de Desvío enruta el sobrecoste.** La diferencia entre realista y referencia se explica
con los Motivos de Desvío del ejecutor:
- `COORDINACIÓN CLIENTE` o crecimiento real de alcance → es coste legítimo del trabajo → **puede
  subir también la referencia** (cara cliente).
- `MALA ESTIMACIÓN` / `MALA COORDINACIÓN INTERNA` → ineficiencia interna → se queda en la realista
  como señal de calibración, **no se factura**.

**Comparar ambas cifras** por persona y tipo de producto es, además, un indicador de eficiencia.
⚠️ Con el histórico actual (los AUTOIA están vivos solo desde el **Sprint 5-26**), esta señal es
**direccional**: sirve para detectar tendencias, nunca para juzgar a nadie con uno o dos datos.

---

## Cuándo activar / cuándo NO

**Activar** para dimensionar trabajo discreto en **General o Soporte** (productos y microcampañas):
- Estimar un producto/microcampaña recién creado o refinado en `General [CLIENTE]`.
- Estimar una petición en `Soporte [CLIENTE]` antes de comprometerla.
- Dimensionar el desarrollo derivado de un **SPIKE cerrado** (Diseño Funcional).
- Preparar las horas de una **propuesta cerrada**.
- Recalibrar un producto cuyo alcance ha cambiado, o simular asignar a otra persona.

**NO activar para:**
- Crear la tarjeta → skills `productos-digitales-{zoho|web|waba}-clickup-reinicia`.
- Cerrar la propuesta en Zoho CRM → `propuesta-comercial-zoho-crm-reinicia`.
- Dimensionar **retainers recurrentes** (Mantenimiento de entornos, Soporte Operativo Continuo): son
  acuerdos de cadencia, no estimaciones de producto. Esta skill estima **presupuestos cerrados**.
- Procesar el Sprint Backlog → `revision-sprint-backlog-equipo-reinicia`.

---

## Relación con otras skills

```
spike-clickup-reinicia (cierra SPIKE → Diseño Funcional)
productos-digitales-*-clickup-reinicia (crea/refina la tarjeta)
        │
        ▼
estimacion-productos-reinicia ◄── tasa de desvío ── ClickUp time_entries vs. time_estimate
        │                         (porqué: AUTOIA / Informes Ejecutivos)
        ├──► ClickUp: MIN / MAX / time_estimate (dedicación realista)
        ├──► propuesta-comercial-zoho-crm-reinicia (Deal + correo borrador, cifra de referencia)
        └──► sprint-planning-reinicia (encaje en capacidad)
```

**Precondición:** debe existir un **alcance estimable**. En Modo B (SPIKE) lo aporta el Diseño
Funcional. En Modo A (solicitud directa) la skill construye un alcance mínimo con el PO; si sigue
demasiado abierto, la salida correcta no es una cifra inflada, sino **recomendar un SPIKE**.

---

## Dos modos de entrada

| | **Modo A — Solicitud del Cliente** | **Modo B — SPIKE aprobado** |
|---|---|---|
| Alcance | Petición del cliente (correo/acta/reunión) | Diseño Funcional validado |
| Incertidumbre | Alta (banda más ancha) | Media-baja (banda más estrecha) |
| Riesgo | Scope creep, supuestos no dichos | Subestimar la integración real |
| Si falta base | Acotar con el PO o **proponer SPIKE** | Estimar; señalar zonas grises del DF |

---

## PASO 0 — Elicitación (preguntas secuenciales, una a una)

1. **Cliente, producto y ámbito.** "¿Para qué cliente es, qué producto/microcampaña hay que estimar
   y en qué lista — `General` o `Soporte`? ¿Es uno o varios?"
2. **Idioma.** "¿La estimación y la propuesta van en **español o inglés**?" → por defecto, el idioma
   del cliente (p. ej. Carritech / HomeEspaña → inglés). Todos los outputs (estimación, comentario,
   propuesta) salen en ese idioma.
3. **Origen.** "¿Estimamos **lo que pidió el Cliente** (Modo A) o **lo aprobado en un SPIKE** (Modo
   B)? Si es SPIKE, ¿tienes el Diseño Funcional o la tarjeta del SPIKE cerrado?"
4. **Tu rol.** "¿Entras como **PO Técnico** (esfuerzo, descomposición, riesgo técnico) o **PO de
   Cliente** (alcance, valor, encaje comercial)? ¿Lo valida también el otro PO?"
5. **Tarjeta y carpeta.** "¿ID de la tarjeta en ClickUp (si existe) y carpeta del proyecto en
   Workdrive? Si no, los busco yo."
6. **Destino.** "¿Para qué la necesitas: escribir horas en ClickUp, preparar una **propuesta
   cerrada**, o ambas? ¿Hay fecha o tope de horas/precio que respetar?"
7. **Perfil de precisión.** "¿**Rápida** (anclada en histórico), **estándar** (descomposición +
   histórico + tasa personal), o **exhaustiva** (PERT por subtarea + Hoja de Estimación en Zoho
   Sheet)?" → por defecto: **estándar**.

> El ejecutor por subtarea y el PO asociado se preguntan en el **Paso 3**, cuando ya hay subtareas
> concretas a las que asignarlos.

---

## PASO 1 — Recopilación de fuentes

**Alcance (qué hay que hacer):**
- Modo B: Diseño Funcional / tarjeta del SPIKE cerrado.
- Modo A: petición del cliente + tarjeta (descripción, criterios, subtareas, comentarios) + Sprint
  Cero / Propuesta si aplica.
- `formato-tarjeta-clickup-reinicia` para entender los bloques del producto.

**Estructura de trabajo estándar (cómo se hace):**
- Plantilla `[PLANTILLA]` de Reinnova más parecida al tipo (lista `48885324`) → lista canónica de
  subtareas y criterios. Consultar con `clickup_get_task`.
- Protocolo Hoja de Ruta Zoho CRM (Writer `3fa50ac0fed1d5b064a588ec5c0c24095f793`) para la secuencia
  de fase (Análisis → Consultoría Preliminar → Definitiva → Prototipo → Formación).

**Histórico para la calibración (clave):**
- Productos/microcampañas **similares** en ClickUp por **tipo** (`clickup_filter_tasks` por `TIPO DE
  PRODUCTO` + keywords) **y por nombre igual o parecido** (`clickup_search`) en cualquier cliente.
- Para cada referencia: `time_estimate` y suma de `clickup_get_time_entries` → ratio real/estimado.
- **Si no aparecen referencias fiables, pedir al PO enlaces de ClickUp** que él sepa que sirven de
  referencia.

**Capacidad (¿cabe?):**
- Sheet de Capacidades del sprint (`7f4pe6b0dbe08986b48ad8a9242b549ad7eaf`) → horas/sprint por
  persona. Sprint = **3 semanas**.

---

## PASO 2 — Descomposición en subtareas actualizadas (con horas base)

Estimar "a ojo" es lo que produce `MALA ESTIMACIÓN`. La skill **siempre descompone**, partiendo de
la plantilla Reinnova y **actualizándola** con el DF / la petición y los productos similares, en
unidades del tamaño de una subtarea (idealmente ≤ 1 día). Para cada una, el PO Técnico (o Claude
proponiendo y el PO ajustando) da tres cifras **O/M/P** (optimista / más probable / pesimista) y la
skill calcula la base **insesgada**:

```
E_ref (esperado)  = (O + 4·M + P) / 6
σ (incertidumbre) = (P − O) / 6
```

`E_ref` y σ son la **estimación de referencia** de esa subtarea (sin sesgo personal todavía).

**Reglas de descomposición (norma Reinicia):**
- **Encaje 1-2 sprints máximo.** Si la suma supera ~1,5 sprints de una persona, **proponer trocear**
  el producto (separar Consultoría Preliminar/Definitiva, cada Prototipo aparte). Avisar al PO.
- **Conector ⇒ SPIKE primero.** Estimar la implementación de un conector sin SPIKE previo → avisar.
- **Validaciones** (Reinicia + Cliente) siempre como unidades propias; la de Cliente arrastra
  coordinación.
- **Horas de gestión/coordinación del PO** se estiman explícitamente; no son "gratis".

---

## PASO 3 — Asignación de ejecutores por subtarea + PO

Con las subtareas ya sobre la mesa:

> "¿Quién del equipo ejecuta **cada subtarea**? ¿Y quién es el **PO asociado** que aprobará las
> horas?"

La asignación por subtarea es lo que permite aplicar la tasa de desvío de **la persona correcta** a
**su** trabajo. Si una subtarea no tiene ejecutor claro, se estima con la tasa del tipo
(reference-class) y se marca como pendiente de asignar.

---

## PASO 4 — Calibración: referencia → dedicación realista

### 4.1 Tasa de desvío personal (vía ClickUp, directo)
Por cada ejecutor distinto del Paso 3:
- Sumar sus `clickup_get_time_entries` por producto y compararlo con el `time_estimate` de cada
  producto → **R_p = Σ tracked / Σ estimado** (su sesgo: >1 tiende a pasarse, <1 tiende a quedarse
  corto).
- **Filtrar por tipo de producto** cuando haya muestra suficiente; si no, usar su ratio global y
  decirlo.
- **Capar ratios extremos** para que un outlier no dispare la cifra.

⚠️ **Histórico escaso:** los datos fiables arrancan en el **Sprint 5-26**. Es habitual no tener
muestra suficiente. Umbral mínimo orientativo: si una persona no tiene al menos ~2 productos
cerrados del tipo (o ~2 sprints), **no hay tasa personal fiable**.

### 4.2 Aplicación
- **Con tasa personal fiable:** `E_real = E_ref × R_p` para las subtareas de esa persona. La tasa
  **reemplaza** cualquier contingencia aditiva (ya incluye los sobrecostes pasados — no duplicar).
- **Sin tasa personal fiable (caso frecuente hoy):** se usa `E_ref` y se añade **contingencia
  aditiva por Motivo de Desvío** dominante del cliente/tipo (tabla 4.4), declarándolo.

### 4.3 El porqué (Motivo de Desvío)
Para explicar y enrutar el desvío, leer los Motivos de Desvío del ejecutor en su **AUTOIA Sprint
Backlog** (raíz `i6aloc646e871a46d46cab983dd7a6704ef9b` → carpeta del sprint → fichero de la persona
→ hoja `Tiempos`, columna de Motivo **leída por etiqueta, no por letra fija**) o, ya agregados, en el
Informe Ejecutivo por Equipo. El ratio de ClickUp da el *cuánto*; el Motivo da el *de qué tipo*.

### 4.4 Enrutador de sobrecoste (referencia vs. realista)
| Motivo dominante del sobrecoste | ¿A qué cifra va? |
|---|---|
| `COORDINACIÓN CLIENTE` / crecimiento real de alcance | Referencia **y** realista (es coste legítimo, facturable) |
| `MALA ESTIMACIÓN` / `MALA COORDINACIÓN INTERNA` | Solo realista (calibración interna, no facturable) |
| Sin muestra → contingencia aditiva genérica | Realista; documentar que es genérica |

---

## PASO 5 — Agregación, encaje, supuestos y riesgos

- **Totales:** `E_ref_total` y `E_real_total` (suma de subtareas); banda con `σ_total = √(Σ σ²)`
  (68% = E ± σ; 95% = E ± 2σ). Las horas de gestión entran en ambas.
- **Encaje en capacidad:** convertir `E_real_total` por persona a sprints (3 semanas). Si no cabe →
  recomendar trocear (Paso 2).
- **Comparación referencia ↔ realista** por persona/tipo: señal de eficiencia (direccional; histórico
  escaso).
- **Supuestos y exclusiones** (anti scope creep): incluido/excluido; supuestos (entornos
  dev/staging, accesos en Zoho Vault, contenido del cliente, DF estable); dependencias del cliente.
- **Riesgos** con impacto en horas (acercan el resultado a P).

---

## PASO 6 — (Opcional) Simulación de asignación

Si el PO pregunta "¿y si lo hace X en vez de Y?" — o de forma proactiva si detecto un encaje mejor —
recalcular la **dedicación realista** con otro ejecutor (su R_p × `E_ref`). Reglas:
- **Solo propone; el PO decide.** Nunca reasigna por su cuenta.
- Mira **fit por tipo** Y **capacidad** (no proponer a alguien sobrecargado; cruzar con el Sheet de
  Capacidades).
- Cambia **solo la cifra realista**; la referencia (cara cliente) no se mueve.
- Con histórico escaso, presentarlo como **tentativo** y orientado a entrega/capacidad, no como un
  ranking de rendimiento.

---

## PASO 7 — Presentación y comentario de aprobación

Claude presenta las dos cifras para validación **antes** de escribir nada:

```
🧮 ESTIMACIÓN — [Producto] [CLIENTE]   ·   Modo A/B   ·   Idioma: ES/EN   ·   Perfil: estándar

REFERENCIA (cara cliente):   E XX,X h   ·   banda 68% [XX,X – XX,X]
DEDICACIÓN REALISTA (int.):  E XX,X h   ·   banda 68% [XX,X – XX,X]
  Ajuste por desvío:  [persona] R_p 1,3 (tipo CRM) · [persona] sin muestra → contingencia +X,X h
Encaje:  cabe en N sprint(s) de [persona]   /   ⚠️ supera 1-2 sprints → trocear

Desglose por rol:  Consultor XX,X · Ingeniero X,X · QA X,X · PO (gestión) X,X
Referencias usadas:  [Producto A], [Producto B]  (ratio mediano 1,3)
Supuestos clave: [...]   ·   Exclusiones: [...]   ·   Riesgos: 🔴[...] 🟡[...]

¿Validas? ¿Ajustas O/M/P, alcance, supuestos o asignaciones?
```

**Comentario de aprobación (tras validación del contenido):** dejar la estimación + petición de
aprobación como **comentario en "Gestión [Mes] [CLIENTE]" asignado al PO** (texto plano, sin
markdown; patrón `formato-tarjeta-clickup-reinicia`): las dos cifras, banda, referencias, supuestos
y exclusiones, fecha y "Estimación asistida por Claude AI". **Si el producto ya está fichado**
(re-estimación de un General/Soporte existente), dejar además un comentario corto en la propia
tarjeta y **cross-linkear** ambos.

La skill **debe parar y pedir input** si: la suma supera 1-2 sprints; el alcance (Modo A) sigue
abierto (→ proponer SPIKE); o antes de cualquier escritura en ClickUp.

---

## PASO 8 — Tras la aprobación del PO

**8.1 Escritura en ClickUp (dedicación realista).** En **horas, pasos de 0,5 h**. Tres valores sobre
el producto/microcampaña:
- `MIN` ← banda inferior realista  ·  `MAX` ← banda superior realista  ·  `time_estimate` ← E realista.
- `MIN`/`MAX` son campos personalizados numéricos (escribir el valor en horas, p. ej. `8,5`); sus
  **UUID se obtienen en runtime** con `clickup_get_custom_fields` sobre la lista destino.
- `time_estimate` es campo nativo: escribir con `clickup_update_task` (no en `create`).
  > ⚠️ Unidad a confirmar en la primera ejecución (la skill de productos Zoho documenta
  > milisegundos = horas × 3.600.000; `update` lo acepta, `create` no). Registrar en VERSIONES.
- Redondear a 0,5 h antes de escribir.

**8.2 Handoff a propuesta comercial (cifra de referencia).** Pasar a
`propuesta-comercial-zoho-crm-reinicia`: genera el **Deal en Zoho CRM** y el **correo borrador** con
la cifra de **referencia** + supuestos y exclusiones (protegen el presupuesto). **No** se genera un
Word suelto.

**8.3 Handoff a Sprint Planning.** `MIN`/`MAX`/`time_estimate` (realista) alimentan el encaje en
capacidad de `sprint-planning-reinicia`.

**8.4 Montaje del producto si aún no existe.** Si la estimación era previa al fichado, recordar montar
la tarjeta con la skill de producto correspondiente y volcar ahí las horas.

---

## (Opcional) Hoja de Estimación en Zoho Sheet — perfil exhaustivo

Para estimaciones grandes o multi-producto, volcar el desglose a un Zoho Sheet trazable (una fila por
subtarea: O, M, P, E_ref, σ, ejecutor, R_p, E_real, referencia usada). Reglas de casa:
- Decimales con **coma** es-ES (`"8,5"`), `cells.content.set`, nunca `csvdata.set` con coma.
- **Identidad visual Reinicia**: azul `#3812CF`, lavanda `#D9D0FB`, gris `#EBEBEB`, bordes
  `#FFFFFF`, Manrope. ≤40 celdas por llamada.

> 🚧 Formato celda a celda de la Hoja de Estimación: pendiente de definir tras el primer uso real.

---

## Reparto de responsabilidad por rol (PO Técnico ↔ PO de Cliente)

| | **PO Técnico** | **PO de Cliente** |
|---|---|---|
| Posee | Descomposición, O/M/P, asignación, riesgo técnico, encaje | Alcance, valor, supuestos cara cliente, encaje comercial |
| Valida | Que la dedicación realista es técnicamente creíble | Que alcance y exclusiones son defendibles ante el cliente |

Flujo recomendado: el PO Técnico cierra la dedicación realista; el PO de Cliente valida alcance,
supuestos y exclusiones antes del handoff a la propuesta.

---

## Herramientas MCP (esperadas)

- **ClickUp:** `clickup_get_task`, `clickup_filter_tasks`, `clickup_search` (referencias y plantilla
  Reinnova), `clickup_get_time_entries` + `time_estimate` (tasa de desvío y reference class),
  `clickup_get_custom_fields` (UUID de `MIN`/`MAX`), `clickup_update_task` (horas),
  `clickup_create_comment` (aprobación/trazabilidad).
- **Workdrive:** `ZohoWorkdrive_getFolderFiles`, `ZohoWorkdrive_downloadWorkDriveFile` (DF, Sprint
  Cero, Capacidades, AUTOIA), `ZohoWorkdrive_searchTeamFoldersFiles`.
- **Zoho Sheet (exhaustivo):** `ZohoSheet_create_workbook`, `ZohoSheet_set_content_to_range`,
  `ZohoSheet_format_ranges`.

---

## Notas importantes

- **Dos cifras siempre, nunca una sola.** Referencia (cliente) y realista (interna). La realista va a
  ClickUp; la referencia va a la propuesta.
- **No duplicar colchón:** tasa personal **o** contingencia aditiva, nunca las dos.
- **Sin muestra fiable → contingencia aditiva + Motivo de Desvío** (histórico vivo solo desde Sprint
  5-26: el caso "sin muestra" es frecuente).
- **El Motivo de Desvío enruta** qué sobrecoste es facturable.
- **Anclar en datos, no en optimismo.** Sin referencias fiables, declararlo y ensanchar la banda.
- **Alcance abierto = SPIKE, no inflar horas.**
- **1-2 sprints es un límite, no un objetivo.** Si no cabe, trocear.
- **Simulación de asignación: solo propone**, mira capacidad, no juzga rendimiento.
- **Idioma del cliente** en todos los outputs.
- **Validar antes de escribir.** Ninguna escritura en ClickUp sin OK del PO.
- **Terminología:** el modelo recurrente es **Soporte Operativo Continuo** (nunca "bolsa de horas");
  esta skill estima **presupuestos cerrados**.

---

## Limitaciones conocidas (a confirmar tras primer uso)

- **Histórico corto** (desde Sprint 5-26): tasas personales poco pobladas; el camino "sin muestra"
  será el habitual al principio.
- **Unidad de `time_estimate`** (min vs. ms) pendiente de verificación empírica (ver 8.1).
- **UUID de `MIN`/`MAX`** no constantes entre listas: recuperar siempre en runtime.
- **Calidad del tracked:** productos con anomalías de imputación (p. ej. `ANOMALIA_API`) distorsionan
  el ratio → excluir y avisar. `time_entries` sin task no recuperables → pueden infravalorar.

---

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v0.1** | 2026-06-21 | Néstor + Claude | Versión inicial. PERT + reference class, dos modos, flujo de 8 pasos, reparto de roles, contingencia por Motivo de Desvío. |
| **v0.2** | 2026-06-21 | Néstor + Claude | Modelo de **dos cifras** (referencia vs. dedicación realista). **Tasa de desvío personal por ejecutor** (vía ClickUp) que reemplaza la contingencia aditiva; fallback a contingencia aditiva + Motivo cuando no hay muestra (histórico desde Sprint 5-26). **Motivo de Desvío como enrutador** de sobrecoste facturable. Asignación de ejecutor por subtarea. Ámbito ampliado a **Soporte** y a microcampañas. Idioma **ES/EN** por cliente. Escritura de **MIN/MAX/time_estimate** en horas (0,5 h). Búsqueda de referencias por nombre + petición de enlaces al PO. Comentario de aprobación en **Gestión del mes** asignado al PO (+ tarjeta si fichada). **Simulación de asignación** opcional. Handoff de propuesta = **Zoho CRM + correo borrador**. Hoja de Estimación con identidad visual Reinicia. |

---

## Pendientes de evolución

**Próxima iteración (tras primer uso real):**
- Verificar y fijar la unidad de `time_estimate`.
- Cuantificar la contingencia aditiva por tipo y el cap de ratios extremos con datos reales.
- Definir la **Hoja de Estimación** en Zoho Sheet celda a celda.
- Validar el PERT agregado (σ_total) y el umbral de muestra mínima.

**Medio plazo:**
- **Bucle de aprendizaje cerrado:** al cerrar cada producto, comparar E vs. tracked y realimentar
  ratios por persona/tipo (círculo con `revision-sprint-backlog-equipo-reinicia`).
- **Catálogo de tasas por persona/tipo** mantenido y consultable, para alimentar simulaciones.
- **Extensión a Web y WABA** con plantillas de descomposición propias.
- **Vista de eficiencia por persona/tipo** para retrospectiva (cuando el histórico lo soporte).
