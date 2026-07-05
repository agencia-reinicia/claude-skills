---
name: cierre-gestion-mensual-clickup-reinicia
description: >
  Skill para revisar el cierre de los productos de Gestión mensuales
  (`Gestión [Mes Anterior] [Año] [CLIENTE]`) en las listas `Gestión [CLIENTE]` de
  los proyectos activos de Reinicia, en los primeros días del mes siguiente. La
  skill **no cierra** los productos por sí misma: si la tarea del mes anterior no
  está en `Done` o `Closed`, deja un comentario asignado al Product Owner
  recordándole revisar los comentarios asignados aún abiertos, cerrarlos o
  moverlos al mes en curso, y llevar la tarea a `Closed` cuando esté todo
  revisado. Incluye enlace al mes en curso si existe. Idempotente.

  Actívala cuando el PO líder pida: "revisa el cierre de gestiones mensuales",
  "cierre mensual de Gestión", o cuando se ejecute la tarea programada mensual
  "Revisar cierre de gestiones mensuales" (día 3 a las 08:15 hora de Madrid).
  Complementaria a apertura-gestion-mensual-clickup-reinicia.
---

# SKILL: Revisar Cierre de Gestiones Mensuales en ClickUp — Reinicia

> **Versión vigente: v1.0 — 05/05/2026** · ver changelog al final (`## Versiones`)

## Propósito

Asegurar que cada Product Owner reciba un recordatorio asignado en ClickUp sobre las
tareas `Gestión [Mes Anterior] [Año] [CLIENTE]` que aún no están cerradas, para que las
revise y cierre formalmente.

La skill **no cierra** productos por sí misma. **No traslada arrastres**. **No publica
comentario de cierre estructurado**. Solo deja un comentario recordatorio asignado al
PO en cada tarea del mes anterior que siga abierta, listando lo que el PO debe hacer
para cerrar el ciclo del mes.

Decisión de filosofía explícita: hasta que esté operativa la integración con Zoho
Catalyst (tabla dedicada para registrar comentarios asignados no resueltos en ClickUp),
la skill no puede determinar con suficiente fiabilidad qué arrastres trasladar. Por
tanto, la responsabilidad de cerrar formalmente la tarea y arrastrar pendientes recae
en el PO. La skill se limita a recordárselo de forma sistemática y trazable.

## Cuándo activar esta skill

**Triggers**:
- "revisa el cierre de gestiones mensuales"
- "revisa el cierre del mes anterior"
- "cierre mensual de Gestión"
- "deja comentarios recordatorios de cierre"
- Tarea programada mensual "Revisar cierre de gestiones mensuales" (día 3 a las
  08:15 hora de Madrid)

**No usar para**:
- Abrir el mes nuevo (skill `apertura-gestion-mensual-clickup-reinicia`)
- Cerrar productos digitales de `General [CLIENTE]` (cada uno tiene su propio cierre
  formal — ver `formato-tarjeta-clickup-reinicia` sección 11)
- Cerrar tareas de Soporte mensuales (`Soporte [Mes] [CLIENTE]`) — patrón convivente
  pero con su propia lógica que esta skill no cubre

---

## PASO 0 — DETERMINACIÓN DEL MES OBJETIVO

Por defecto, la skill toma como **mes objetivo** el mes inmediatamente anterior a la
fecha de ejecución:

- Si se ejecuta el 3 de mayo de 2026 → revisa `Gestión Abril 2026 [CLIENTE]` en cada
  proyecto.
- Si se ejecuta el 3 de junio de 2026 → revisa `Gestión Mayo 2026 [CLIENTE]`.

Si el usuario invoca la skill manualmente especificando otro mes, respetar esa
elección.

El **mes en curso** (donde puede existir o no la tarea nueva del PO) es el mes de la
fecha de ejecución. Por defecto sin override.

---

## PASO 1 — DETECCIÓN DE TAREAS A REVISAR

### 1.1 Búsqueda dinámica con filtros de no-archivado

La skill **no hardcodea clientes**. Detecta dinámicamente las tareas del mes objetivo
en proyectos activos de Reinicia Clientes mediante `clickup_search`:

- `keywords: "Gestión [Mes Anterior] [Año]"` con `asset_types: ["task"]`.
- Filtros estrictos: solo proyectos / carpetas / listas / tareas **NO archivados**.
  ClickUp expone la propiedad `archived` en cada nivel de la jerarquía; la skill las
  excluye en cada uno.

### 1.2 Patrones de matching

La skill matchea contra los patrones canónicos:

```
^Gesti[oó]n\s+(Mes Anterior)\s+\d{4}.*\[.*\]
```

Donde `Mes Anterior` es el mes objetivo (ej. `Abril` si se ejecuta en mayo). Variantes
históricas toleradas (case-insensitive, tildes opcionales, guion antes del corchete
opcional, espacios extra).

**Incluir también** las tareas internas Reinicia (lista `Gestión Reinicia` `3350803`)
con patrones dedicados:
- `^Gesti[oó]n Reinicia TODOS\s+(Mes Anterior)\s+\d{4}\s+\[REINICIA\]`
- `^Gesti[oó]n\s+(Mes Anterior)\s+\d{4}\s+Marketing\s+\[REINICIA\]`

Estas tareas las gestiona Néstor. La skill las incluye en el ciclo con el mismo flujo
que el resto de clientes.

### 1.3 Para cada tarea detectada, recoger

- ID, nombre, estado actual (`status.status`)
- Lista (cliente)
- Custom field `PO/Product Owner` (UUID `14d40a06-639f-4ad3-a241-aa66df2fcf23`)
- Assignees actuales
- Watchers
- URL de la tarea

---

## PASO 2 — IDENTIFICACIÓN DEL PO PARA EL COMENTARIO ASIGNADO

Para cada tarea, la skill identifica el destinatario del comentario asignado mediante
una **cascada de fallback** de tres niveles:

1. **Nivel 1 — Custom field `PO/Product Owner`**: si está relleno, usar ese valor.
   Resolverlo a un User ID de ClickUp:
   - El custom field es un dropdown con valores `ALVARO / NESTOR / ELENA / BORJA /
     ALEJANDRO / PATRICIA / MARTA / PABLO / OSCAR`.
   - Mapear a User IDs reales con `clickup_resolve_assignees` o tabla de mapeo
     mantenida (ver Recursos clave).

2. **Nivel 2 — Assignee**: si el custom field PO no está relleno, usar el primer
   assignee de la tarea. Si hay varios assignees, usar el primero por orden o el que
   coincida con un PO conocido del cliente.

3. **Nivel 3 — Pregunta al PO líder**: si ni custom field PO ni assignee permiten
   identificar destinatario, la skill **omite** el comentario en esa tarea y la
   reporta al final como "PO no identificado — pendiente de tu confirmación".

En modo programado (Cowork / Claude Code), el Nivel 3 se traduce en omisión silenciosa
y reporte. En modo asistido (manual), la skill puede preguntar al PO líder en chat.

---

## PASO 3 — EVALUACIÓN DE LA TAREA Y BÚSQUEDA DEL MES EN CURSO

Para cada tarea con PO identificado:

### 3.1 Evaluar estado

- Si `status.status` es `Done` o `Closed` (estados terminales) → **no hacer nada**.
  La tarea ya está cerrada formalmente.
- Si `status.status` es cualquier otro estado (`Open`, `product backlog`,
  `sprint backlog`, `doing`, `validación reinicia`, `validación cliente`, etc.) →
  proceder al Paso 3.2.

### 3.2 Buscar la tarea del mes en curso

En la misma lista del cliente, buscar la tarea `Gestión [Mes En Curso] [Año] [CLIENTE]`
con el mismo patrón de matching del Paso 1.

- **Si existe**: capturar URL para incluirla en el comentario recordatorio.
- **Si no existe**: el comentario recordatorio incluirá una nota explícita pidiendo al
  PO que la cree (la apertura del mes nuevo debería haberse hecho con la skill
  complementaria `apertura-gestion-mensual-clickup-reinicia`; si no, el PO la creará a
  mano).

---

## PASO 4 — IDEMPOTENCIA

Antes de publicar el comentario recordatorio, la skill comprueba si **ya lo publicó
en una ejecución previa**:

- Buscar en los comentarios de la tarea (`clickup_get_task_comments`) un comentario
  con marcador exacto:

```
🔔 Recordatorio de cierre — Gestión [Mes Anterior] [Año] [CLIENTE]
```

- Si **existe**: la skill ya recordó al PO en una ejecución previa. **No re-publicar**.
  Reportar como "ya recordado".
- Si **no existe**: continuar con el Paso 5.

---

## PASO 5 — PUBLICACIÓN DEL COMENTARIO RECORDATORIO

La skill publica un comentario en la tarea, **asignado al PO identificado en el Paso 2**.

### 5.1 Asignación del comentario

`clickup_create_task_comment` con `assignee` = User ID del PO. Esto hace que el
comentario aparezca en la bandeja de pendientes del PO en ClickUp.

### 5.2 Contenido del comentario (texto plano, sin markdown)

```
🔔 Recordatorio de cierre — Gestión [Mes Anterior] [Año] [CLIENTE]
Generado por la skill cierre-gestion-mensual-clickup-reinicia el [DD/MM/YYYY HH:MM].

Esta tarea sigue en estado [estado actual] y aún no se ha cerrado formalmente.
Por favor, revisa los siguientes puntos para cerrarla:

1. Revisa los comentarios asignados a ti en esta tarea que sigan abiertos.
2. Cierra los que estén resueltos.
3. Para los que sigan abiertos y deban continuar, trasládalos al producto de
   gestión del mes en curso (copia el contenido relevante como nuevo comentario
   asignado allí).
4. Cuando hayas terminado todo lo anterior, cambia el estado de esta tarea a
   Closed.

[SI EXISTE LA TAREA DEL MES EN CURSO:]
Producto de gestión del mes en curso (donde trasladar lo abierto):
Gestión [Mes En Curso] [Año] [CLIENTE]
URL: [url tarea mes en curso]

[SI NO EXISTE LA TAREA DEL MES EN CURSO:]
⚠️ No he encontrado el producto Gestión [Mes En Curso] [Año] [CLIENTE] en esta
lista. Por favor, créalo (manualmente o ejecutando la skill
apertura-gestion-mensual-clickup-reinicia) antes de trasladar lo que esté abierto.

Gracias.
```

Notas de formato:
- **Texto plano**, sin markdown ni hipervínculos custom (limitación comentarios ClickUp).
- URLs siempre en línea separada del texto descriptivo (convención Reinicia).
- Marcador inicial `🔔 Recordatorio de cierre — Gestión [Mes Anterior] [Año] [CLIENTE]`
  exacto, para idempotencia (Paso 4).

---

## PASO 6 — REPORTE FINAL AL PO LÍDER

Al terminar todas las tareas, la skill publica en chat (modo asistido) o en el
historial de la tarea programada (modo Cowork / Claude Code) un resumen:

```
📋 REVISIÓN CIERRE GESTIÓN [Mes Anterior] [Año] — Resumen

Total tareas detectadas: [N]

✔️ Ya cerradas (Done/Closed) — sin acción ([N]):
  - [CLIENTE 1]
  - [CLIENTE 2]
  ...

🔔 Recordatorios publicados ([N]):
  - [CLIENTE 3] → comentario asignado a [PO] [con / sin] enlace al mes en curso
  - [CLIENTE 4] → comentario asignado a [PO] [con / sin] enlace al mes en curso
  ...

🔁 Ya recordados en ejecución previa ([N]):
  - [CLIENTE 5] (recordatorio existente del [fecha previa])

⚠️ PO no identificado — pendiente de tu confirmación ([N]):
  - [CLIENTE 6]: tarea sin custom field PO ni assignee. Revisa manualmente quién
    es el PO y vuelve a ejecutar.

⚠️ Mes en curso no encontrado ([N]):
  - [CLIENTE 7]: el recordatorio se publicó pero sin enlace al mes en curso.
    Considera ejecutar la skill apertura-gestion-mensual-clickup-reinicia.

📌 Tareas internas Reinicia ([N]):
  - Gestión Reinicia TODOS [Mes Anterior] [Año] [REINICIA]: [estado] — [acción
    realizada]
  - Gestión [Mes Anterior] [Año] Marketing [REINICIA]: [estado] — [acción
    realizada]
```

---

## NOTAS IMPORTANTES

- **La skill no cambia estados**: nunca pasa una tarea a `Closed` ni a otros estados.
  Esa decisión es del PO. La skill solo recuerda y aporta el enlace al mes en curso
  para facilitar el trabajo.
- **La skill no traslada arrastres**: no copia comentarios ni mueve subtareas. El
  comentario recordatorio le explica al PO que esa labor le corresponde a él.
- **Comentarios asignados — limitación actual**: el MCP de ClickUp puede no exponer
  con fiabilidad el flag "asignado pendiente / resuelto" de cada comentario. Por eso
  la skill no intenta listar arrastres específicos; solo recuerda al PO que los
  revise. **Plan futuro**: integración con tabla en Zoho Catalyst (alimentada por
  proceso paralelo) que registre comentarios asignados no resueltos en ClickUp.
  Cuando esté operativa, una v2.0 podrá listar los arrastres específicos en el
  recordatorio o incluso proponer el cierre automático con datos fiables.
- **Idempotencia estricta**: el marcador `🔔 Recordatorio de cierre —` garantiza que
  ejecuciones repetidas no dupliquen el comentario.
- **Tareas archivadas excluidas**: la skill filtra carpetas, listas y tareas
  archivadas en cada nivel para evitar acción sobre proyectos cerrados o pausados.
- **Subtareas `Gestión Semana N`**: con la incorporación de las revisiones semanales
  de Sprint Planning, estas subtareas se cierran cada semana. La skill no las toca
  porque su responsabilidad es solo recordar al PO sobre la tarea madre. Si el PO
  decide cerrarlas o no al cerrar el mes, es decisión suya.
- **Tareas internas Reinicia incluidas**: `Gestión Reinicia TODOS [Mes]` y `Gestión
  [Mes] Marketing` se gestionan con el mismo flujo. Néstor recibe los recordatorios
  asignados.
- **No hay validación humana en modo programado**: la skill se diseña para ser
  ejecutable de forma desatendida (Cowork o Claude Code el día 3 a las 08:15). Como
  no toma decisiones destructivas (solo deja comentarios), no requiere validación
  previa. En modo asistido sí puede preguntar al PO líder por casos ambiguos
  (Nivel 3 de la cascada de identificación de PO).
- **Convivencia con la skill de apertura**: la skill de apertura debería ejecutarse
  antes (días 1-3 del mes). Si por algún motivo se ejecuta esta skill primero y la
  tarea del mes en curso no existe, el comentario recordatorio lo refleja
  explícitamente para que el PO actúe.

---

## RECURSOS CLAVE

### Custom field UUIDs

| Campo | UUID |
|---|---|
| PO/Product Owner | `14d40a06-639f-4ad3-a241-aa66df2fcf23` |
| TIPO DE PRODUCTO | `5bd9072e-deae-4352-b35b-bdbaa3cc216d` |

### Mapeo Custom field PO → User ID ClickUp (para asignación de comentarios)

Tabla de referencia (a confirmar y mantener actualizada):

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

Cuando el valor del dropdown no esté en la tabla, usar `clickup_resolve_assignees`
con el nombre como query.

### Marcadores de comentario (para idempotencia)

| Marcador | Significado |
|---|---|
| `🔔 Recordatorio de cierre — Gestión [Mes] [Año] [CLIENTE]` | Comentario recordatorio publicado por esta skill |

### Herramientas MCP usadas

- `clickup_search` — detección dinámica de tareas mensuales y mes en curso
- `clickup_filter_tasks` — listado de tareas por lista (alternativa a search)
- `clickup_get_task` — datos completos de la tarea (custom fields, estado, assignees)
- `clickup_get_task_comments` — comprobar idempotencia (¿ya hay recordatorio?)
- `clickup_create_task_comment` — publicar comentario recordatorio asignado al PO
- `clickup_resolve_assignees` — resolver nombre de PO a User ID

---

## NOTAS OPERATIVAS PARA LA TAREA PROGRAMADA

Cuando el PO líder registre la tarea programada (Cowork o Claude Code):

1. **Nombre**: `Revisar cierre de gestiones mensuales`.
2. **Disparo**: día 3 de cada mes a las 08:15 (hora de Madrid, Europe/Madrid).
3. **Plataforma**: pendiente de decidir (Cowork con app abierta, o Claude Code en
   background 24/7).
4. **Modelo**: Opus 4.7.
5. **Carpeta / Proyecto**: `Asesor Product Owners Reinicia` (para que la tarea
   programada herede skills y MCPs disponibles).
6. **Prompt sugerido**:

```
Ejecuta la skill cierre-gestion-mensual-clickup-reinicia. Revisa los productos de
gestión del mes anterior en proyectos activos de Reinicia Clientes y deja
comentarios recordatorios asignados al PO correspondiente en cada tarea que no
esté en estado Done o Closed. Reporta el resumen final.
```

Si en el futuro se cambia el mecanismo de disparo (de Cowork a Claude Code, o
viceversa), la skill funciona idéntica — solo cambia el disparador. Skill agnóstica
del mecanismo de scheduling.

---

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v1.0** | 2026-05-05 | Néstor + Claude | Versión inicial. Cambio de filosofía respecto a borrador previo: la skill **no cierra** tareas ni traslada arrastres. Solo deja un comentario recordatorio asignado al PO cuando la tarea del mes anterior no está en `Done` o `Closed`. Identificación del PO por cascada de fallback (custom field PO → assignee → pregunta al PO líder). Filtros estrictos de no-archivado en carpetas, listas y tareas. Inclusión de tareas internas Reinicia. Idempotencia con marcador `🔔 Recordatorio de cierre —`. Tarea programada "Revisar cierre de gestiones mensuales" día 3 a las 08:15 hora de Madrid. Plan futuro: integración con tabla Catalyst para una v2.0 que pueda listar arrastres específicos o ejecutar el cierre automático con datos fiables. |
