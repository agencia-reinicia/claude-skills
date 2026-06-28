---
name: apertura-gestion-mensual-clickup-reinicia
description: >
  Skill para crear los productos de Gestión mensuales activos
  (`Gestión [Mes Siguiente] [Año] [CLIENTE]`) en las listas `Gestión [CLIENTE]` de
  los proyectos activos de Reinicia Clientes, los últimos días del mes en curso.
  Para cada proyecto, si existe el producto del mes en curso, crea el del mes
  siguiente replicando configuración relevante (PO, watchers, tags), con fechas
  automáticas, subtareas semanales reales del calendario y, si aplica, subtareas
  de informes de dedicación detectando la cadencia (mensual, quincenal o semanal)
  del cliente. Idempotente. No copia tiempo registrado ni avance.

  Actívala cuando el PO líder pida: "crea las gestiones mensuales activas",
  "abre los productos de Gestión de [mes]", o cuando se ejecute la tarea
  programada mensual "Crear gestiones mensuales activas" (día 27 a las 09:00
  hora de Madrid). Complementaria a cierre-gestion-mensual-clickup-reinicia.
---

# SKILL: Crear Gestiones Mensuales Activas en ClickUp — Reinicia

> **Versión vigente: v1.1 — 17/05/2026** · ver changelog al final (`## Versiones`)

## Propósito

Asegurar que cada cliente activo de Reinicia tenga creada a tiempo la tarea
`Gestión [Mes Siguiente] [Año] [CLIENTE]` en su lista `Gestión [CLIENTE]`, con la
configuración canónica replicada del mes en curso, las subtareas semanales reales
del calendario, y las subtareas de informes de dedicación horas si aplican según
la cadencia del cliente.

La tarea mensual de Gestión actúa como receptáculo de:
- Comentarios de actas de reunión (publicados por la skill `actas-reinicia`)
- Logs de soporte diarios (publicados por la skill
  `soporte-procesamiento-clickup-reinicia` en estrategia b: prefiere
  `Soporte [Mes Año]`, fallback a `Gestión [Mes Año]`)
- Comunicación operativa entre POs sobre el cliente durante el mes
- Generación de informes de dedicación horas hacia el cliente (subtareas tipo B)

## Cuándo activar esta skill

**Triggers**:
- "crea las gestiones mensuales activas"
- "crea los productos de Gestión del próximo mes"
- "abre los productos de Gestión de [mes]"
- "apertura mensual de Gestión"
- Tarea programada mensual "Crear gestiones mensuales activas" (día 27 a las 09:00
  hora de Madrid)

**No usar para**:
- Cerrar / revisar el cierre del mes anterior (skill
  `cierre-gestion-mensual-clickup-reinicia`)
- Crear productos digitales en `General [CLIENTE]` (skills
  `productos-digitales-*-clickup-reinicia`)
- Crear tareas de Soporte mensuales (`Soporte [Mes] [CLIENTE]`) — patrón convivente
  pero distinto que aquí no se cubre
- Arrancar el primer mes de un cliente nuevo (lo gestiona el PO líder a mano)

---

## PASO 0 — DETERMINACIÓN DEL MES OBJETIVO

Por defecto, la skill toma como **mes objetivo** el mes inmediatamente posterior a
la fecha de ejecución:

- Si se ejecuta el 27 de abril de 2026 → crea `Gestión Mayo 2026 [CLIENTE]`.
- Si se ejecuta el 27 de mayo de 2026 → crea `Gestión Junio 2026 [CLIENTE]`.

El **mes en curso** (mes anterior al objetivo, usado como mes de referencia) es el
mes de la fecha de ejecución.

Si el usuario invoca la skill manualmente especificando otro mes, respetar esa
elección.

---

## PASO 1 — DETECCIÓN DE PROYECTOS ACTIVOS CON GESTIÓN VIVA

### 1.1 Búsqueda dinámica con filtros de no-archivado

La skill **no hardcodea clientes**. Detecta dinámicamente qué proyectos tienen
Gestión mensual activa mediante `clickup_search`:

- `keywords: "Gestión [Mes En Curso] [Año]"` con `asset_types: ["task"]`.
- Donde `Mes En Curso` es el mes anterior al objetivo (ej. si objetivo es Mayo 2026,
  buscamos `Gestión Abril 2026`).
- Filtros estrictos: solo proyectos / carpetas / listas / tareas **NO archivados**
  en cada nivel de la jerarquía.

### 1.2 Patrones de matching del mes en curso

La skill matchea contra los patrones canónicos:

```
^Gesti[oó]n\s+(Mes En Curso)\s+\d{4}.*\[.*\]
```

Variantes históricas toleradas (case-insensitive, tildes opcionales, guion antes
del corchete opcional, espacios extra).

**Incluir también** las tareas internas Reinicia (lista `Gestión Reinicia` `3350803`)
con patrones dedicados:
- `^Gesti[oó]n Reinicia TODOS\s+(Mes En Curso)\s+\d{4}\s+\[REINICIA\]`
- `^Gesti[oó]n\s+(Mes En Curso)\s+\d{4}\s+Marketing\s+\[REINICIA\]`

Estas tareas las gestiona Néstor. La skill las incluye en el ciclo con el mismo flujo
que el resto de clientes.

### 1.3 Filtro estricto de elegibilidad

Para que un proyecto entre en el ciclo automático, **debe existir** la tarea de
Gestión del mes en curso en su lista de Gestión:

- **Si existe**: el proyecto es elegible. La skill creará `Gestión [Mes Siguiente]
  [CLIENTE]` (siguiendo Pasos 2 a 6).
- **Si no existe**: el proyecto **no es elegible**. La skill **no crea nada** para
  ese cliente. Esto cubre dos casos:
  - Cliente pausado o que ha caído del ciclo mensual (no queremos reintroducirlo
    automáticamente).
  - Cliente nuevo cuyo primer mes aún no se ha arrancado (es trabajo del PO líder
    crear el primer mes a mano; la skill solo se ocupa del ciclo automático ya rodado).

### 1.4 Para cada tarea del mes en curso, recoger

Datos de referencia que la skill replicará en el mes siguiente:

- Lista (cliente) — `list.id`
- Folder/carpeta del cliente (para Paso 4.4 — detección de lista Soporte)
- Custom field `PO/Product Owner` (UUID `14d40a06-639f-4ad3-a241-aa66df2fcf23`)
- Assignees actuales (1 PO líder en convención canónica)
- Watchers (típicamente PO líder + PO Técnico + Néstor)
- Tags (excluyendo `sprint - XX - YY`)
- Custom fields rellenos (`TIPO DE PRODUCTO = GESTIÓN`)
- Subtareas y su detalle completo (nombre y status), para Pasos 4.3 y 4.4

---

## PASO 2 — IDEMPOTENCIA: COMPROBACIÓN DE EXISTENCIA DEL MES SIGUIENTE

Antes de crear, la skill comprueba si ya existe la tarea del mes objetivo en la
misma lista:

1. Buscar tareas con patrón `Gestión [Mes Siguiente] [Año] [CLIENTE]` en la lista.
2. **Si existe una y solo una**: marcar como "OK — ya existe" y **no hacer nada**.
   Reportar al final.
3. **Si existen dos o más** (caso duplicado): reportar al PO con todos los duplicados
   y **no crear más**. Sugerir consolidación manual (no destructiva en automático).
4. **Si no existe**: continuar al Paso 3.

---

## PASO 3 — CREACIÓN DE LA TAREA MADRE DEL MES SIGUIENTE

### 3.1 Nomenclatura canónica

```
Gestión [Mes Siguiente] [Año] [CLIENTE]
```

Reglas:
- Mes en castellano y capitalizado (`Enero`, `Febrero`, ..., `Diciembre`).
- Año con 4 dígitos.
- CLIENTE en mayúsculas, entre corchetes, sin guion antes del corchete.
- Tildes obligatorias (`Gestión`, no `Gestion`).

Casos especiales:
- Tareas internas Reinicia: `Gestión Reinicia TODOS [Mes Siguiente] [Año] [REINICIA]`
  y `Gestión [Mes Siguiente] [Año] Marketing [REINICIA]`.
- Cliente con nombre exacto preservado de la tarea de referencia (ej.
  `[LACROIX ENVIRONMENT SOFREL]`, `[LIDER SYSTEM]`).

### 3.2 Campos de la tarea madre

| Campo | Valor |
|---|---|
| `name` | `Gestión [Mes Siguiente] [Año] [CLIENTE]` |
| `description` | Vacía (patrón histórico observado) |
| `status` | `Open` (estado por defecto de ClickUp) |
| `assignees` | El **PO detectado** (ver 3.3) |
| `watchers` | Replicados de la tarea de referencia |
| `start_date` | **Primer día del mes siguiente** a las 00:00 (timestamp ms, Europe/Madrid) |
| `due_date` | **Último día del mes siguiente** a las 23:59 (timestamp ms, Europe/Madrid) |
| `time_estimate` | **NULL** — convención Reinicia: nunca se estima en productos de Gestión |
| `priority` | Replicado de la tarea de referencia (típicamente `null`) |
| `tags` | Replicados de la tarea de referencia, **excluyendo tags de sprint** (`sprint - XX - YY`) |
| Custom field `TIPO DE PRODUCTO` | `GESTIÓN` (UUID opción `f100a89f-cdf8-408e-a10a-1f1584255c2b`) |
| Custom field `PO/Product Owner` | Replicado de la tarea de referencia |
| Otros custom fields | Replicar **solo si tienen valor** en la tarea de referencia |

**Lo que NO se replica nunca:**
- Tiempo registrado (`time_spent`)
- Avance (`AVANCE DE PRODUCTO` y similares automatic_progress fields)
- Métricas consumidas o derivadas
- Comentarios
- `time_estimate` (siempre null)
- Tags de sprint específicos
- Estado terminal del mes anterior

### 3.3 Identificación del PO (cascada de fallback)

Tres niveles, igual que en la skill de cierre para mantener coherencia:

1. **Nivel 1 — Custom field `PO/Product Owner`**: si está relleno en la tarea de
   referencia, usar ese valor. Resolverlo a un User ID de ClickUp con
   `clickup_resolve_assignees` o tabla de mapeo (ver Recursos clave).
2. **Nivel 2 — Assignee**: si el custom field PO no está relleno, usar el primer
   assignee de la tarea de referencia.
3. **Nivel 3 — Reportar al final**: si ni custom field PO ni assignee permiten
   identificar al PO, la skill **crea la tarea sin assignee** y la reporta al final
   como "PO no detectado — pendiente de tu confirmación". El PO líder asigna a mano
   posteriormente.

---

## PASO 3.bis — ESPERA DE MATERIALIZACIÓN DE PLANTILLA CLICKUP

⚠️ **Crítico para idempotencia con plantillas**: cuando una lista `Gestión [CLIENTE]`
tiene asociada una **plantilla ClickUp** (template), las subtareas, custom fields y
campos derivados de la plantilla se materializan de forma **asíncrona** tras la
creación de la tarea madre. Si la skill crea inmediatamente sus propias subtareas
(Patrón A o B) sin esperar, puede generar **duplicados** que la plantilla iba a
crear unos segundos después.

### 3.bis.1 — Espera inicial obligatoria

Tras `clickup_create_task` de la tarea madre del Paso 3 (o si la tarea madre ya
existía por re-ejecución), **esperar 15 segundos** antes de inspeccionar subtareas.
Tiempo validado empíricamente para que ClickUp materialice las subtareas de
plantilla en la mayoría de los casos.

### 3.bis.2 — Inspección de subtareas materializadas

Llamar `clickup_get_task` con `subtasks: true` sobre la tarea madre y registrar el
inventario de subtareas existentes en ese momento:

- Para cada subtarea, capturar `id`, `name`, `status`, `assignees`, `start_date`,
  `due_date` y matchear contra los patrones canónicos esperados (Patrón A:
  `^Gesti[oó]n Semana \d+$`; Patrón B: `^Generaci[oó]n informe dedicaci[oó]n horas`).
- Marcar cada subtarea materializada como **"ya presente por plantilla — no
  crear"** en la estructura interna de planificación.

### 3.bis.3 — Reintento si el inventario está vacío

Si en el primer check **no aparece ninguna subtarea** y el cliente tiene plantilla
asociada (deducible si el mes en curso de referencia tiene subtareas que encajan
con los patrones canónicos), **esperar 30 segundos adicionales** (total 45s desde
la creación) y reinspeccionar.

- Si en el reintento aparecen subtareas → continuar con el inventario.
- Si tras el reintento sigue vacío → asumir que la plantilla **no incluye**
  subtareas predefinidas y proceder a crear todo desde cero (Pasos 4.1 y 4.2 sin
  filtro de duplicados de plantilla).

### 3.bis.4 — Patrón de detección antes de crear

A partir de este punto, todas las decisiones de creación de subtareas (Patrones A
y B en Paso 4) se cruzan con el inventario obtenido aquí:

```
Por cada subtarea canónica a crear:
  ¿Existe ya en el inventario una subtarea con nombre que matchee el patrón
   canónico (regex tolerante a variaciones de espaciado, formato de fecha,
   capitalización)?
  ├─► SÍ → NO crear. Verificar campos canónicos (start_date, due_date, assignees).
  │         Si falta alguno, completarlo con clickup_update_task SIN sobrescribir.
  └─► NO → Crear normalmente.
```

### 3.bis.5 — Anomalía: múltiples matches

Si el match detecta **dos o más** subtareas candidatas para el mismo patrón
canónico (ej. dos `Gestión Semana 1` o dos informes del mismo periodo): **no crear
nada** para ese hueco y **reportar al PO** como duplicado de plantilla a resolver
manualmente. La skill no borra ni renombra subtareas existentes.

---

## PASO 4 — CREACIÓN DE SUBTAREAS

### 4.1 Patrón A: Gestión Semanal (siempre se crea)

Subtareas con nombre exacto `Gestión Semana N`, donde N va de 1 al número de
semanas reales del mes objetivo.

**Cálculo de semanas reales del mes**:
- Una "semana" es un bloque de **lunes a domingo** que contiene **al menos un día
  del mes objetivo**.
- Esto produce 4 o 5 semanas según el calendario (ej. mayo 2026 tiene 5; febrero
  2026 tiene 4).

Configuración de cada subtarea Gestión Semana N:
- `name`: `Gestión Semana N`
- `parent`: ID de la tarea madre creada en Paso 3
- `status`: `product backlog` (estado típico observado en histórico para semanas)
- `assignees`: vacío (las semanas no se asignan en la creación; el PO las trabaja
  semana a semana)
- `start_date` y `due_date`: bordes lunes-domingo de la semana correspondiente
  (cuando los bordes caen fuera del mes objetivo, se usan los bordes del mes para
  no extender la subtarea más allá de su tarea madre).
- Sin custom fields (las subtareas semanales no llevan).
- Sin tiempo estimado.

### 4.2 Patrón B: Generación de Informes de Dedicación (condicional)

Las subtareas tipo B reportan al cliente las horas dedicadas. Su composición depende
de **dos factores combinados**: si el cliente tiene lista de Soporte (que activa el
informe del mes anterior fijo) y la cadencia adicional que aplique al cliente
(mensual pura, quincenal o semanal del mes propio, esta última con acumulado
integrado en cada subtarea).

#### 4.2.1 Pieza fija — Informe del mes anterior (cuando hay Soporte)

**Regla**: si el cliente tiene **lista `Soporte [CLIENTE]` no archivada en su
carpeta** → siempre se crea una subtarea de informe mensual del mes anterior.

Detección de lista Soporte:
- Listar las listas hermanas de la lista `Gestión [CLIENTE]` (mismo `folder.id`).
- Buscar una con nombre `Soporte [CLIENTE]` (case-insensitive, no archivada).

Si **no hay lista de Soporte** en la carpeta → la skill **no crea ninguna subtarea
tipo B**, ni la del mes anterior ni las del mes propio. Fin del Patrón B para ese
cliente.

Si **sí hay lista de Soporte** → crear siempre la subtarea:

```
Generación informe dedicación horas periodo 01-MM_anterior-YYYY a UU-MM_anterior-YYYY [Cliente]
```

Donde:
- `MM_anterior` es el mes en curso (mes anterior al objetivo de la madre). Ej. si la
  madre es `Gestión Junio 2026`, el informe mensual cubre Mayo: `01-05-2026 a
  31-05-2026`.
- `UU` = último día del mes anterior (28, 29, 30 o 31 según corresponda).
- `[Cliente]` se replica literalmente del formato observado en la tarea de
  referencia (puede ser `[GONHER]`, `[Gonher]`, `[LIDER SYSTEM]`, etc.).

Configuración:
- `parent`: ID de la tarea madre del mes objetivo
- `status`: `Open`
- `assignees`: replicados de la subtarea equivalente del mes en curso (típicamente
  el equipo operativo del proyecto)
- `start_date` y `due_date`: bordes del rango calculado
- `priority`: replicada de la subtarea equivalente (típicamente `high`)

#### 4.2.2 Cadencia adicional — Detección sobre el mes en curso + validación con el PO

Solo si hay lista de Soporte (paso 4.2.1 activo), la skill examina la composición
de subtareas tipo B en la **tarea madre del mes en curso** para identificar la
cadencia adicional del cliente.

##### Flujo general de decisión

```
¿La tarea madre del mes en curso tiene subtareas B canónicas que permitan
 inferir cadencia adicional?

  ├─► SÍ → Inferencia automática (M / Q / S) + VALIDAR con el PO antes de crear:
  │         "Para [CLIENTE], detecto cadencia [X] (informes [periodicidad])
  │          basándome en Gestión [Mes En Curso] [Año] [CLIENTE]. ¿La mantenemos
  │          para [Mes Siguiente]?"
  │         ├─► OK (o modo desatendido) → usar cadencia detectada.
  │         └─► Cambiar → preguntar cadencia nueva al PO (M/Q/S/Otra).
  │
  └─► NO (es la primera vez con Soporte para este cliente, o no hay patrón
        canónico identificable) → PREGUNTAR al PO directamente:
        "Es la primera vez (o no detecto patrón canónico) que se abre Gestión
         con Soporte para [CLIENTE]. ¿Con qué cadencia generamos el informe de
         dedicación al cliente?
         A) Mensual cerrado (canónico v1.4)
         B) Quincenal con acumulado (1-15 y 16-fin)
         C) Semanal con acumulado (lunes-domingo)
         D) Otra (especifica)"
```

##### Modos de ejecución

- **Modo asistido** (PO presente en chat): la validación / pregunta se hace de
  forma síncrona en chat y se espera respuesta antes de crear las subtareas
  adicionales.
- **Modo desatendido** (tarea programada día 27 sin PO presente): la skill **NO
  pregunta** y aplica la siguiente regla:
  - Si la inferencia automática es **clara y consistente** (M, Q o S sin
    anomalías) → usar cadencia detectada y registrarlo en el reporte para
    auditoría posterior por el PO.
  - Si la inferencia es **dudosa o es primera vez** → aplicar 4.2.5 (crear solo
    la pieza fija del mes anterior + comentario asignado al PO solicitando que
    cree las subtareas adicionales manualmente y confirme la cadencia para
    siguientes meses).

##### Inferencia automática — tabla de detección

1. Recoger todas las subtareas tipo B del mes en curso (matchee el regex
   `^Generaci[oó]n informe dedicaci[oó]n horas`).
2. Filtrar duplicados manifiestos (mismo rango exacto repetido) y rangos anómalos
   (los que no encajan en ningún patrón canónico). Estos van al reporte del Paso 6
   pero **no se replican**.
3. Sobre las subtareas B "limpias", **descontar** la del mes anterior (ya cubierta
   en 4.2.1) y analizar las que cubren el **mes propio**. Identificar la cadencia
   según esta tabla:

| Composición observada en mes propio | Cadencia |
|---|---|
| Ninguna subtarea cubre el mes propio | **M** (mensual pura) |
| 2 subtareas, cada una cubre una quincena del mes propio | **Q** (quincenal con acumulado) |
| 4 o 5 subtareas, cada una cubre una semana del mes propio | **S** (semanal con acumulado) |

4. Si la composición no encaja con ninguno de los tres patrones (irregularidades
   dominantes, mezcla atípica) → cadencia **no identificable**. Aplicar 4.2.5.

##### Persistencia de la cadencia confirmada

Cuando la cadencia queda confirmada (sea por validación del PO o por inferencia
clara en modo desatendido), la skill **persiste el dato** en la descripción de la
tarea madre del mes objetivo recién creada, con una etiqueta canónica al final:

```
📋 Cadencia informe dedicación: [M | Q | S]
🔁 Fuente: [inferencia automática mes anterior | confirmación PO | primera definición PO]
🕓 Registrado: [fecha YYYY-MM-DD]
```

Esto permite que en el siguiente ciclo, la skill pueda **leer la cadencia
directamente de la tarea madre del mes en curso** (más fiable que reinferirla cada
vez) y **validar contra el PO** que sigue siendo correcta. Si la etiqueta no
existe (caso de tareas históricas anteriores a v1.1), la skill cae a inferencia
sobre las subtareas como en v1.0.

#### 4.2.3 Cadencia M (mensual pura) — sin acción adicional

Si la cadencia es M, la subtarea del mes anterior creada en 4.2.1 es la **única**
subtarea tipo B en la madre. No se crean más.

#### 4.2.4 Cadencias Q y S — Subtareas con acumulado integrado

**Convención de nomenclatura unificada** (aplica a Q y S):

```
Generación informe dedicación horas semana DD-MM-YYYY a DD-MM-YYYY + acumulado mes a fecha [Cliente]
```

(Para Q se usa la misma plantilla; el rango es de quincena en lugar de semana, pero
el nombre conserva la palabra "semana" como cabecera del modelo unificado. **Nota:**
si en evolución posterior queremos diferenciar "quincena" en el nombre, ajustamos en
una v1.1 — para v1.0 mantenemos la nomenclatura única para no fragmentar.)

**Por qué "+ acumulado mes a fecha"**: cada subtarea cubre tanto el informe de su
periodo (semana o quincena) como el acumulado del mes desde el día 1 hasta el final
de ese periodo. Esto refleja la práctica real del PO al generar los informes y evita
crear subtareas separadas para "informe semanal" y "acumulado", que es como se hacía
antes y producía los rangos confusos vistos en GONHER mayo 2026.

##### Cadencia S (semanal con acumulado) — N subtareas

Crear N subtareas (N = 4 o 5 según calendario), una por cada **semana real
lunes-domingo** del mes objetivo, alineadas con las `Gestión Semana N` del
Patrón A:

- Si la primera semana del mes empieza un día que no es lunes (ej. mayo 2026
  empieza viernes), la primera subtarea tiene su `start_date` en el primer día
  del mes (`01-MM-YYYY`) y su `due_date` en el primer domingo.
- Si la última semana del mes acaba un día que no es domingo, la última subtarea
  tiene su `start_date` en el último lunes y su `due_date` en el último día del
  mes (`UU-MM-YYYY`).

Ejemplo aplicado a `Gestión Junio 2026 [GONHER]` (junio 2026 empieza lunes y tiene
30 días → 5 semanas):

```
Generación informe dedicación horas semana 01-06-2026 a 07-06-2026 + acumulado mes a fecha [GONHER]
Generación informe dedicación horas semana 08-06-2026 a 14-06-2026 + acumulado mes a fecha [GONHER]
Generación informe dedicación horas semana 15-06-2026 a 21-06-2026 + acumulado mes a fecha [GONHER]
Generación informe dedicación horas semana 22-06-2026 a 28-06-2026 + acumulado mes a fecha [GONHER]
Generación informe dedicación horas semana 29-06-2026 a 30-06-2026 + acumulado mes a fecha [GONHER]
```

##### Cadencia Q (quincenal con acumulado) — 2 subtareas

Crear 2 subtareas:

```
Generación informe dedicación horas semana 01-MM-YYYY a 15-MM-YYYY + acumulado mes a fecha [Cliente]
Generación informe dedicación horas semana 16-MM-YYYY a UU-MM-YYYY + acumulado mes a fecha [Cliente]
```

Configuración común a Q y S:
- `parent`: ID de la tarea madre del mes objetivo
- `status`: `Open`
- `assignees`: replicados de la subtarea equivalente del mes en curso
- `start_date` y `due_date`: bordes del rango calculado
- `priority`: replicada de la subtarea equivalente

#### 4.2.5 Cadencia no identificable — comentario al PO

Si la skill detecta subtareas B en el mes en curso pero **no puede identificar la
cadencia adicional con fiabilidad** (anomalías que dominan, rangos irregulares,
duplicados masivos), la skill:

1. Crea **solo** la subtarea fija del mes anterior (4.2.1 — siempre se crea cuando
   hay lista Soporte).
2. **No crea** subtareas adicionales de cadencia Q ni S.
3. Publica en la tarea madre del mes objetivo un comentario asignado al PO:

```
🔔 Cadencia de informes no detectada con fiabilidad
Generado por la skill apertura-gestion-mensual-clickup-reinicia el [fecha].

He creado la subtarea fija de informe del mes anterior (Gestión Mensual del mes
anterior), pero no he podido identificar la cadencia adicional del cliente
(quincenal o semanal con acumulado) en Gestión [Mes En Curso] [Año] [CLIENTE]
debido a:
- [motivo: anomalías, rangos solapados, duplicados, etc.]

Por favor, crea manualmente las subtareas adicionales de Generación de informe
dedicación horas para [Mes Siguiente] [Año] siguiendo el patrón que aplique a
este cliente. Si dejas el patrón estabilizado este mes, la skill lo detectará
y replicará el mes que viene.

Tarea de referencia (mes en curso):
URL: [url Gestión Mes En Curso]
```

#### 4.2.6 Normalización del modelo nuevo (semanal/quincenal con acumulado)

La skill aplica el modelo unificado descrito en 4.2.4 ("semana DD-MM a DD-MM +
acumulado mes a fecha") incluso si el mes en curso tenía el modelo antiguo de
subtareas separadas (semanales sueltas + acumulados aparte como anomalías).

Es decir: la skill **detecta la cadencia** (S o Q) examinando el mes en curso, pero
al **crear las subtareas en el mes objetivo** usa siempre el modelo nuevo unificado.
Esto normaliza el flujo a futuro sin perder el patrón del cliente.

En el reporte del Paso 6, la skill indica explícitamente cuando ha aplicado esta
normalización para que el PO sepa que el formato de las subtareas ha cambiado
respecto al mes anterior.

---

## PASO 5 — IDEMPOTENCIA EN SUBTAREAS

La idempotencia opera en dos niveles complementarios:

1. **Inventario previo** del Paso 3.bis (subtareas materializadas por plantilla
   ClickUp tras la creación de la tarea madre). Esto cubre el caso de listas con
   plantilla asociada que crea subtareas predefinidas de forma asíncrona.
2. **Re-ejecución parcial**: si la tarea madre del mes objetivo ya existía (skill
   ejecutada dos veces el mismo día, o continuación tras error), la skill
   comprueba antes de crear cada subtarea si ya existe en la madre con el mismo
   nombre. **Solo crea las que falten**.

Ejemplos:
- Si ya existen `Gestión Semana 1` y `Gestión Semana 2` (porque las creó la
  plantilla o una ejecución previa) pero faltan `3, 4, 5`, la skill crea solo las
  que faltan.
- Si una subtarea B con un rango concreto ya existe, no se duplica.
- Si la subtarea de plantilla tiene un nombre **ligeramente distinto** al canónico
  pero matchee el regex tolerante (ej. "Informe dedicación Mayo 2026 [GONHER]"
  contra "Generación informe dedicación horas periodo 01-05-2026 a 31-05-2026
  [GONHER]"), se considera **match positivo**: no se duplica y se reporta la
  diferencia de naming al PO en el Paso 6 para que decida si renombrar o aceptar.

---

## PASO 6 — REPORTE FINAL AL PO LÍDER

Al terminar todas las tareas, la skill publica en chat (modo asistido) o en el
historial de la tarea programada (modo Cowork / Claude Code) un resumen:

```
📋 APERTURA GESTIÓN [Mes Siguiente] [Año] — Resumen

Total proyectos elegibles (con Gestión [Mes En Curso] viva): [N]

✅ Tareas creadas ([N]):
  - Gestión [Mes Siguiente] [Año] [CLIENTE 1]
    URL: [url]
    Asignada a: [PO]
    Subtareas A (semanas reales): [N1] (Gestión Semana 1..N1)
    Subtareas B (informes): [N2]
      · Informe del mes anterior: [creado / no aplica (sin Soporte) / no creado]
      · Cadencia adicional: [M (sin extras) / Q (2 quincenales con acumulado) / S (N semanales con acumulado) / no identificable]
      · Normalización aplicada: [sí / no]
  - Gestión [Mes Siguiente] [Año] [CLIENTE 2]
    ...

✔️ Ya existían ([N]):
  - [CLIENTE 3]: Gestión [Mes Siguiente] ya estaba creada
  ...

⚠️ Duplicados detectados en mes objetivo ([N]):
  - [CLIENTE 4]: 2 tareas — [URL1] y [URL2] — revisa manualmente
  ...

⚠️ PO no detectado ([N]):
  - [CLIENTE 5]: tarea creada sin assignee. Asigna a mano.
  ...

⚠️ Cadencia adicional no detectada ([N]):
  - [CLIENTE 6]: informe del mes anterior creado, pero comentario publicado en la
    tarea nueva pidiendo creación manual de las subtareas adicionales (semanal
    o quincenal con acumulado).
  ...

⚠️ Anomalías detectadas en mes en curso (no replicadas) ([N]):
  - [CLIENTE 7]: subtareas B con rangos anómalos que no se replicaron al mes
    objetivo. Detalle:
    - "Generación informe... 01-05-2026 a 14-05-2026" (no encaja en cadencia
       semanal ni quincenal típica)
  ...

🔄 Normalización aplicada ([N]):
  - [CLIENTE X]: el mes en curso usaba el modelo antiguo de subtareas separadas
    (semanales sueltas + acumulado aparte). Las subtareas del mes objetivo se han
    creado con el modelo nuevo unificado ("semana DD-MM a DD-MM + acumulado mes
    a fecha"). El formato cambia respecto al mes anterior.
  ...

🧩 Subtareas heredadas de plantilla ClickUp ([N]):
  - [CLIENTE Y]: la plantilla aplicó [N] subtareas tras la creación de la tarea
    madre. Match canónico verificado, no se duplicaron. Diferencias de naming
    detectadas: [lista de naming alternativos para revisar].
  ...

📋 Cadencia confirmada y persistida ([N]):
  - [CLIENTE Z]: cadencia [M | Q | S] registrada en la descripción de la tarea
    madre del mes objetivo. Fuente: [inferencia automática | confirmación PO |
    primera definición PO].
  ...

🚫 Proyectos no elegibles (sin Gestión [Mes En Curso] viva) ([N]):
  - [CLIENTE 8]: lista de Gestión existe pero no tiene tarea del mes en curso.
    No se crea automáticamente. Si es cliente pausado, ignora. Si debe entrar en
    el ciclo, créale a mano la primera Gestión [Mes En Curso] o [Mes Siguiente]
    para que el próximo ciclo la detecte.
  ...

📌 Tareas internas Reinicia ([N]):
  - Gestión Reinicia TODOS [Mes Siguiente] [Año] [REINICIA]: [creada / ya existía] — [URL]
  - Gestión [Mes Siguiente] [Año] Marketing [REINICIA]: [creada / ya existía] — [URL]
```

---

## NOTAS IMPORTANTES

- **Filtro estricto del mes en curso**: si no hay tarea de Gestión del mes en curso,
  la skill **no crea nada** para ese cliente. Esto cubre tanto clientes pausados
  como clientes nuevos sin arrancar. El arranque inicial de un cliente nuevo es
  trabajo del PO líder a mano.
- **No tiempo estimado**: el campo `time_estimate` siempre se deja en `null` para
  tareas de Gestión y sus subtareas. Convención explícita Reinicia.
- **No copia tiempo registrado, avance ni métricas**: la tarea nueva nace limpia.
  Solo se replican campos descriptivos (PO, watchers, tags no-sprint, custom
  fields configurables).
- **Subtareas semanales reales**: se calculan según el calendario del mes objetivo
  (4 o 5 semanas lunes-domingo). No siempre 5.
- **Espera obligatoria tras crear la tarea madre (15s + 30s reintento)**: dar
  tiempo a ClickUp para materializar las subtareas de la plantilla asociada a la
  lista antes de que la skill cree las suyas. Aplica tanto a subtareas A
  (semanales) como a subtareas B (informes). Sin esta espera, riesgo de
  duplicación.
- **Validación de cadencia con el PO**: la skill **no asume** la cadencia
  automáticamente sin avisar. En modo asistido, valida con el PO antes de crear
  las subtareas adicionales (Q o S). En modo desatendido, aplica la inferencia
  automática si es clara y la reporta para auditoría posterior; si es dudosa o es
  primera vez, escala vía comentario.
- **Persistencia de cadencia en la tarea madre**: cuando la cadencia queda
  confirmada, se registra en la descripción de la tarea madre del mes objetivo
  como etiqueta canónica `📋 Cadencia informe dedicación: [M|Q|S]`. El siguiente
  ciclo lee directamente esa etiqueta y la valida contra el PO en lugar de
  reinferir cada vez.
- **Subtareas de informes — pieza fija + cadencia adicional**: si el cliente tiene
  lista `Soporte [CLIENTE]` en su carpeta, se crea siempre el informe del mes
  anterior (rango `01 a último día del mes anterior`). La cadencia adicional
  (mensual pura M, quincenal con acumulado Q, o semanal con acumulado S) se detecta
  del mes en curso. Si no hay lista Soporte, no se crea ningún informe.
- **Modelo unificado para Q y S**: las subtareas adicionales (quincenales o
  semanales) usan la nomenclatura `Generación informe dedicación horas semana
  DD-MM a DD-MM + acumulado mes a fecha [Cliente]` — una sola subtarea por periodo
  que incluye tanto el informe del periodo como el acumulado del mes hasta esa
  fecha. La skill normaliza al modelo unificado aunque el mes en curso tenga el
  modelo antiguo de subtareas separadas (semanal + acumulado aparte).
- **Anomalías reportadas, no propagadas**: duplicados o rangos anómalos en el mes
  en curso se reportan al final pero no se replican al mes objetivo.
- **Idempotencia estricta**: si la tarea madre ya existe, no se duplica. Si solo
  existe la madre y faltan subtareas (re-ejecución parcial), la skill crea solo
  las que faltan.
- **Tags de sprint excluidos**: tags `sprint - XX - YY` no se replican.
- **Tareas archivadas excluidas**: filtrado en carpeta, lista y tarea.
- **Tareas internas Reinicia incluidas**: `Gestión Reinicia TODOS [Mes]` y
  `Gestión [Mes] Marketing` se gestionan con el mismo flujo. Néstor recibe la
  asignación.
- **Convivencia con la skill de cierre**: esta skill se ejecuta el día 27 (mes en
  curso); la de cierre se ejecuta el día 3 del mes siguiente. Cuando la de cierre
  busca el "mes en curso" para incluir su URL en el recordatorio, encuentra la
  tarea ya creada por esta skill.
- **Limitación conocida — checklists vía API**: ClickUp no permite crear checklists
  vía MCP. No aplicable hoy a esta skill (las tareas de Gestión no llevan checklist).

---

## RECURSOS CLAVE

### IDs de listas Gestión conocidas (referencia, no hardcoded)

Las listas las descubre la skill dinámicamente. Esta tabla es para referencia humana:

| Cliente | Lista Gestión ID |
|---|---|
| Gonher | 901205582846 |
| Avaderm | 901202330083 |
| Carritech | 901207893946 |
| HomeEspaña | (buscar dinámicamente) |
| Ingelyt | 3350970 |
| Synuptic | (buscar dinámicamente) |
| Lacroix Sofrel | 3350990 |
| Niuvo | (buscar dinámicamente) |
| Moradillo | 901217243228 |
| Reinicia (interno) | 3350803 |

### Custom field UUIDs

| Campo | UUID |
|---|---|
| PO/Product Owner | `14d40a06-639f-4ad3-a241-aa66df2fcf23` |
| TIPO DE PRODUCTO | `5bd9072e-deae-4352-b35b-bdbaa3cc216d` |
| Opción `GESTIÓN` (TIPO DE PRODUCTO) | `f100a89f-cdf8-408e-a10a-1f1584255c2b` |

### Mapeo Custom field PO → User ID ClickUp

Tabla de referencia (a mantener actualizada — coincide con la de la skill de cierre):

| Valor dropdown PO | Persona | User ID |
|---|---|---|
| ALVARO | Álvaro O'Donnell | (pendiente confirmar) |
| NESTOR | Néstor Tejero | 766716 |
| ELENA | Elena | (pendiente confirmar) |
| BORJA | Borja | (pendiente confirmar) |
| ALEJANDRO | Alejandro Pont | 93805276 |
| PATRICIA | Patricia | (pendiente confirmar) |
| MARTA | Marta | (pendiente confirmar) |
| PABLO | Pablo Losada | 87715920 |
| OSCAR | Óscar Díez | 93631901 |

### Herramientas MCP usadas

- `clickup_search` — detección dinámica de tareas del mes en curso
- `clickup_filter_tasks` — listado de tareas por lista (mes en curso, mes objetivo)
- `clickup_get_task` — datos completos de la tarea de referencia con subtareas
  (`subtasks: true`)
- `clickup_create_task` — creación de la tarea madre y subtareas (con `parent` para
  subtareas)
- `clickup_update_task` — establecer custom fields tras la creación si es necesario
- `clickup_create_task_comment` — publicar comentario al PO en caso de cadencia no
  detectable
- `clickup_resolve_assignees` — resolver nombre de PO a User ID
- `clickup_get_list` (eventualmente) — listar listas hermanas para detectar
  `Soporte [CLIENTE]` en la misma carpeta

---

## NOTAS OPERATIVAS PARA LA TAREA PROGRAMADA

Cuando el PO líder registre la tarea programada (Cowork o Claude Code):

1. **Nombre**: `Crear gestiones mensuales activas`.
2. **Disparo**: día 27 de cada mes a las 09:00 (hora de Madrid, Europe/Madrid).
3. **Plataforma**: pendiente de decidir (Cowork con app abierta, o Claude Code en
   background 24/7).
4. **Modelo**: Opus 4.7.
5. **Carpeta / Proyecto**: `Asesor Product Owners Reinicia` (para que la tarea
   programada herede skills y MCPs disponibles).
6. **Prompt sugerido**:

```
Ejecuta la skill apertura-gestion-mensual-clickup-reinicia. Crea las tareas
Gestión [Mes Siguiente] [Año] [CLIENTE] en cada proyecto activo de Reinicia
Clientes que tenga la tarea Gestión [Mes En Curso] [Año] [CLIENTE] viva,
incluyendo sus subtareas semanales reales y, si aplica, las subtareas de
informes de dedicación con la cadencia detectada del mes en curso. Reporta el
resumen final.
```

Si en el futuro se cambia el mecanismo de disparo, la skill funciona idéntica
— solo cambia el disparador. Skill agnóstica del mecanismo de scheduling.

---

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v1.0** | 2026-05-05 | Néstor + Claude | Versión inicial. Tarea programada "Crear gestiones mensuales activas" día 27 a las 09:00 hora de Madrid. Filtro estricto: solo crea mes siguiente si existe el mes en curso (sin caso "cliente nuevo"). Subtareas A (Gestión Semana N) según semanas reales del calendario lunes-domingo. Subtareas B (Generación informe dedicación horas): pieza fija = informe del mes anterior (`01 a último día del mes anterior`) cuando el cliente tiene lista Soporte; cadencia adicional detectada del mes en curso (M sin extras / Q con 2 quincenales con acumulado / S con N semanales con acumulado). Modelo unificado de nomenclatura para Q y S: "semana DD-MM a DD-MM + acumulado mes a fecha", con normalización del modelo nuevo aunque el mes en curso tenga el modelo antiguo de subtareas separadas. Comentario al PO si la cadencia adicional no es identificable. Anomalías reportadas pero no propagadas. No copia tiempo registrado ni avance ni métricas. Identificación del PO por cascada (custom field PO → assignee → reporte). Inclusión de tareas internas Reinicia. Idempotencia en madre y subtareas. Plan futuro: integración con Catalyst para una v2.0 que pueda enriquecer la decisión de cadencia con datos externos. |
| **v1.1** | 2026-05-17 | Néstor + Claude | Paso 3.bis nuevo: espera de materialización de plantilla ClickUp (15s + reintento de 30s) tras crear la tarea madre antes de crear subtareas propias. Inventario previo de subtareas para evitar duplicar lo que crea la plantilla. Cadencia: validación con el PO en modo asistido (primera vez → pregunta directa con 4 opciones; ya hay historial → validación del valor inferido). Modo desatendido aplica inferencia automática solo cuando es clara; si es dudosa, escala vía comentario. Persistencia de la cadencia confirmada en la descripción de la tarea madre con etiqueta canónica `📋 Cadencia informe dedicación: [M\|Q\|S]` + fuente y fecha, para que el siguiente ciclo la lea directamente sin reinferir. Idempotencia reforzada con match tolerante de naming (renombrados de plantilla detectados sin duplicar). Reporte final ampliado con tres nuevas secciones (subtareas heredadas de plantilla, cadencia confirmada, naming alternativo detectado). Validado tras dry-run informe dedicación Gonher Mayo 2026. |
