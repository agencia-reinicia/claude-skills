---
name: formato-tarjeta-clickup-reinicia
description: >
  Patrón canónico de tarjeta de producto en ClickUp para Reinicia. Fuente de verdad transversal que aplican
  todas las skills de creación de productos (Zoho, Web, WABA, SPIKEs y futuras). Cubre la descripción de
  la tarjeta (estructura de bloques en markdown), convenciones de campos personalizados, comentarios,
  checklists, Elementos relacionados y el flujo formal de cierre del producto.

  Esta skill NO se invoca por el usuario directamente: actúa como referencia que las skills de creación
  de productos consultan al generar tarjetas, y al ejecutar cierres formales. Se activa cuando otra skill
  necesita crear o actualizar la descripción de una tarjeta ClickUp, decidir qué bloque va dentro y cuál
  fuera (en comentario o checklist), o cuando el PO vuelve a Claude para cerrar formalmente un producto
  y registrar conclusión, decisión del cliente, lecciones aprendidas y producto derivado.
---

# Skill: Formato Tarjeta ClickUp — Reinicia

## Propósito

Define el patrón canónico de una tarjeta de producto en ClickUp de Reinicia. Todas las skills de creación de productos en ClickUp se remiten a este patrón para garantizar consistencia visual y estructural en el backlog, y al flujo de cierre formal aquí definido para registrar el resultado de cada producto.

Esta skill es a las skills de creación de productos lo que `marca-reinicia` es a las skills de generación de documentos: una fuente de verdad de patrón visual y de proceso.

---

## 1. Filosofía del patrón

Tres principios que rigen el formato:

**P1. Lectura por capas.** La descripción debe poder leerse a tres niveles: vistazo (segundos), lectura normal (1 minuto), o profundidad. El bloque RESUMEN al inicio es el primer nivel.

**P2. Bloques opcionales claros.** Hay bloques **fijos** (siempre presentes) y bloques **opcionales** (presentes solo si el producto los necesita). El PO no debe sentirse obligado a rellenar lo que no aplica.

**P3. Continuidad temporal.** La descripción no es solo el "encargo" — es la historia viva del producto. Contempla el cierre (resultado, decisión, conexión con productos derivados). El bloque "Resultado y cierre" se crea vacío al inicio y se completa al cerrar el producto, aplicando el flujo formal definido en la sección 11.

---

## 2. Estructura canónica de la descripción

Orden fijo de bloques. Los marcados como **opcional** se omiten si no aplican al tipo de producto. Los marcados como **diferido** se crean vacíos al inicio y se rellenan al cierre del producto.

```
═══════════════════════════════════════════════════════
> 🎯 RESUMEN                                  [bloque fijo - cita]
═══════════════════════════════════════════════════════

## 📌 Historia de usuario                     [bloque fijo]

## 📋 Descripción                             [bloque fijo]

## 📥 Requerimientos Cliente                  [opcional - sólo Soporte y peticiones directas]

## ✅ Ready to Backlog                        [bloque fijo]

## 🧩 Hipótesis de solución a validar         [opcional - sólo SPIKEs con hipótesis]

## ❓ Preguntas a responder durante el SPIKE  [opcional - sólo SPIKEs de investigación]

## 🌍 Contexto                                [bloque fijo - puede aparecer vacío con "No definida"]

## 🎯 Alcance                                 [opcional]

## 📦 Entregables                             [bloque fijo]

## 📚 Documentación de referencia             [bloque fijo]

═══════════════════════════════════════════════════════
## 🏁 Resultado y cierre                      [bloque fijo - diferido (sección 11)]
═══════════════════════════════════════════════════════
```

### 2.1 Bloque RESUMEN (formato cita)

Bloque fijo. Va siempre **el primero**. Va como **cita** (`>`) y no como `## H2`, porque las citas no aplican margen como los headers y permiten compactar el resumen visual.

```markdown
> 🎯 **RESUMEN**
> [Resumen de qué hace el producto en 1-3 líneas]
> **Entrega:** [qué se entrega al cierre]
```

Importante: siempre que dentro de una cita haya una línea destacada como "Entrega:", "Plazo:", "Decisión:" etc., debe ir en **negrita** y en línea aparte (otra línea con `>` al inicio).

### 2.2 Bloque "📌 Historia de usuario"

Un único párrafo con la fórmula clásica, **personalizada con el usuario real del cliente**:

```markdown
## 📌 Historia de usuario
Como **[Nombre Apellido] ([Rol] de [CLIENTE])**, **QUIERO** [necesidad], **PARA** [beneficio].
```

Las palabras clave **Como**, **QUIERO** y **PARA** van en negrita. El nombre de la persona y el rol también van dentro del bloque en negrita (forman parte del "Como").

**Por qué la persona y no sólo el rol:** la Historia de usuario es la voz humana del producto. Nombrar a la persona concreta del cliente que vivirá el resultado (a) hace el producto más tangible para el Equipo Operativo, (b) ayuda al PO a recordar a quién validar, y (c) deja rastro útil cuando el producto se cierra meses después.

**Convención transversal:** aplica a **todos los tipos de producto** — Productos de Implementación, Microcampañas, SPIKEs y Soporte. No hay exenciones por tipo.

**Tres casos según el conocimiento del PO sobre la persona:**

**Caso A — Persona única conocida**

Un usuario claro del producto. Se nombra a la persona y se indica su rol entre paréntesis.

```markdown
Como **María García (Responsable de Marketing de Carritech)**, **QUIERO**...
```

**Caso B — Varias personas posibles**

Varios usuarios beneficiarios. Se eligen 2-3 representativos como mucho. Si exceden ese número, se nombra al usuario principal y se referencia al colectivo.

```markdown
Como **María García y Pedro Ruiz (Comerciales de Carritech)**, **QUIEREN**...
```

```markdown
Como **María García y el equipo Comercial de Carritech**, **QUIEREN**...
```

(El verbo se ajusta al plural: **QUIEREN**, **NECESITAN**.)

**Caso C — Persona no conocida todavía**

Productos planificados antes de tener interlocutor concreto en el cliente (típico en Sprint Cero, productos del primer sprint, o relaciones nuevas). Se mantiene visible que falta el nombre con un placeholder explícito.

```markdown
Como **(persona pendiente de identificar) (Comercial de Carritech)**, **QUIERO**...
```

El placeholder `(persona pendiente de identificar)` actúa como recordatorio para el PO: cuando se confirme el interlocutor, se vuelve a la tarjeta y se sustituye. Nunca inventar un nombre.

**Regla operativa para las skills madre:**

Toda skill que cree un producto en ClickUp **debe preguntar al PO por la persona del cliente** durante la elicitación, de forma sistemática:

```
¿Quién del cliente es el usuario principal de este producto?
- Si lo sabes, dime nombre y rol.
- Si hay varios, dime los principales (máx. 2-3) o el colectivo.
- Si todavía no lo conoces, lo dejamos como "pendiente de identificar"
  y lo cierras cuando hables con el cliente.
```

Si una skill ya tiene contexto suficiente (correo del cliente, transcripción de Sprint Planning donde aparece el nombre, formulario de soporte con el solicitante), puede **proponer** el nombre al PO en lugar de preguntar abierto. La validación del PO es siempre necesaria — no se inventa.

### 2.3 Bloque "📋 Descripción"

Lista no numerada (5 viñetas habituales). La etiqueta de cada viñeta va en negrita seguida de dos puntos:

```markdown
## 📋 Descripción
- **Web:** [URL — usar markdown [texto](url) con texto descriptivo]
- **Idiomas:** [Español / Inglés / Francés...]
- **Objetivo Cliente:** [una frase]
- **Objetivo del Producto/SPIKE:** [una frase]
- **Público objetivo:** [destinatarios principales]
```

Si el producto añade datos relevantes (presupuesto, plazo, ubicación física), se añaden como nuevas viñetas con la misma convención.

### 2.4 Bloque "📥 Requerimientos Cliente" (opcional)

Sólo se incluye cuando el producto tiene su origen en una petición directa del cliente (correo, formulario de ClickUp, ticket de soporte, mensaje de WhatsApp). Es el **encargo en bruto del cliente**, sin reformular.

Estructura:

```markdown
## 📥 Requerimientos Cliente
> Petición original del cliente — [origen: email / formulario ClickUp / ticket / etc.] — [fecha]

[Texto literal o muy fiel a la petición del cliente]

[Si la petición venía por correo: incluir remitente y asunto]
```

**Cuándo activarlo:**
- Productos en listas de **Soporte** del cliente
- Productos de **microcampañas** que vienen de petición concreta del cliente
- Cualquier producto cuyo origen sea una petición trazable del cliente y donde resulte útil tener el texto literal a mano

**Cuándo NO activarlo:**
- Productos planificados desde el Sprint Cero o desde la Propuesta Comercial (no hay "petición" — son trabajo planificado)
- SPIKEs internos de investigación

**Regla de preservación literal cuando el origen es un formulario de ClickUp:**

Cuando un cliente rellena un formulario de ClickUp, ClickUp crea automáticamente una tarjeta en la lista destino y vuelca el contenido del formulario en la descripción de la tarjeta (típicamente como pares pregunta/respuesta).

Antes de aplicar el patrón canónico a esa tarjeta, Claude debe:

1. **Leer la descripción auto-generada** por el formulario tal como está, sin alterarla.
2. **Copiar ese contenido íntegro y literal** al bloque "📥 Requerimientos Cliente", sin resumir, reformular ni omitir campos. Mantener las preguntas originales del formulario y las respuestas del cliente exactamente como las escribió.
3. **Construir el resto del patrón canónico alrededor** (Historia de usuario, Descripción, Contexto, Ready to Backlog, etc.) como capa de interpretación profesional sobre la petición original.

De este modo la tarjeta conserva la petición original del cliente para trazabilidad y referencia, y a la vez incorpora la estructura Reinicia para el trabajo del Equipo Operativo.

Si Claude detecta que la descripción auto-generada contiene información sensible o muy extensa (ej. correos largos copiados literalmente, datos personales no relevantes para el producto), puede preguntar al PO si conviene editarla — pero **nunca** silenciosamente.

### 2.5 Bloque "✅ Ready to Backlog"

Lista no numerada con las condiciones que deben cumplirse para que el producto entre en sprint:

```markdown
## ✅ Ready to Backlog
- [Condición 1 — accesos, credenciales]
- [Condición 2 — datos confirmados]
- [Condición 3 — entornos disponibles]
- [Condición 4 — confirmaciones del cliente]
```

### 2.6 Bloque "🧩 Hipótesis de solución a validar" (opcional)

Sólo en SPIKEs cuyo PO tiene una hipótesis técnica concreta. La skill `spike-clickup-reinicia` decide cuándo incluirlo.

Estructura:

```markdown
## 🧩 Hipótesis de solución a validar
> Propuesta por el PO de Reinicia. Punto de partida de la investigación, **no** la solución aprobada — el SPIKE debe confirmarla o refutarla antes de escalar a producto de implementación.

[Descripción narrativa de la hipótesis]

1. [Paso 1 del flujo propuesto]
2. [Paso 2]
3. [Paso 3]
```

La cita inicial es invariable: deja claro que es hipótesis y no decisión.

### 2.7 Bloque "❓ Preguntas a responder durante el SPIKE" (opcional)

Sólo en SPIKEs de investigación. Formato Q&A diferenciado visualmente:

```markdown
## ❓ Preguntas a responder durante el SPIKE
**P1.** [Pregunta 1]
**R1.** [Respuesta cuando esté disponible]

**P2.** [Pregunta 2]
**R2.** [Respuesta cuando esté disponible]
```

Las respuestas se rellenan **a medida que la investigación avanza**, no necesariamente al crear la tarjeta.

### 2.8 Bloque "🌍 Contexto"

Lista no numerada. **El contenido depende del tipo de producto:**

**Productos de Implementación (lista General):**

Información de empresa para dar pie al Equipo Operativo. Se nutre de Propuesta Comercial, actas de Comercial o Proyecto, Sprint Cero, Web del cliente, LinkedIn de personas clave.

```markdown
## 🌍 Contexto
- [Cómo opera hoy el cliente — modelo de negocio, estructura, sector]
- [Equipo del cliente involucrado en el proyecto]
- [Stack tecnológico y sistemas implicados]
- [Por qué este producto importa para el cliente]
```

**Productos de Soporte (lista Soporte):**

Contexto operativo o casuístico — incidencia previa, histórico de tickets, urgencia, sistemas afectados.

**Microcampañas y otros:**

Lo que aplique al caso.

**Si no hay contexto disponible**, se deja la sección visible con el texto:

```markdown
## 🌍 Contexto
No definida.
```

Esto sirve de recordatorio de que falta información y permite añadirla más tarde sin tocar la estructura.

### 2.9 Bloque "🎯 Alcance" (opcional)

Sí/No explícito con emojis ✅ y ❌. Es la mejor herramienta para gestionar expectativas, especialmente útil en SPIKEs y en productos donde el alcance es propenso a expandirse.

```markdown
## 🎯 Alcance

**✅ Sí — dentro del [SPIKE/Producto]:**
- [Item 1 dentro del alcance]
- [Item 2]

**❌ No — fuera del [SPIKE/Producto]:**
- [Item 1 fuera del alcance]
- [Item 2]

[Frase de cierre opcional indicando dónde vive lo que queda fuera]
```

**Cuándo activarlo:** SPIKEs (siempre), productos donde haya riesgo de scope creep, productos con cliente exigente o relación frágil.

**Cuándo omitirlo:** productos pequeños, soporte recurrente, microcampañas con alcance trivial.

### 2.10 Bloque "📦 Entregables"

Dos sub-bloques con negrita:

```markdown
## 📦 Entregables

**Reinicia (interno):**
- [Entregable interno 1] → basado en [Plantilla X](url-Workdrive)
- [Entregable interno 2]
- [Entregable interno 3] → basado en [Plantilla Y](url-Workdrive)

**Cliente:**
- [Entregable a cliente 1]
- [Entregable a cliente 2]
```

**Convención de enlaces:** los entregables internos enlazan a las **plantillas** correspondientes en Workdrive (`Recursos Comunes › Plantillas Reinicia › Zoho › Zoho CRM › Plantillas` u otra carpeta de plantillas que aplique). Cuando una plantilla no esté localizada, dejar placeholder explícito *"(plantilla a localizar)"* en lugar de inventar URL.

### 2.11 Bloque "📚 Documentación de referencia"

Lista no numerada de enlaces a recursos del proyecto:

```markdown
## 📚 Documentación de referencia
- [Sprint Cero CLIENTE (versión pública — PDF)](url-Workdrive) — para Equipo y Amigos Reinicia
- [Sprint Cero CLIENTE (versión interna — Zoho Show)](url-Workdrive) — solo PO y Director de Operaciones
- [Board de Miro CLIENTE (Flujograma + ERD)](url-Miro)
```

**Convenciones críticas:**
- Sprint Cero: enlazar **siempre las dos versiones** (pública para equipo y Amigos Reinicia; interna para PO y Director de Operaciones).
- Cuando un recurso no exista todavía (por ejemplo, board de Miro pendiente de crear), dejar placeholder explícito *"(pendiente de crear)"* en lugar de URL falsa.
- Usar siempre formato `[texto descriptivo](URL)` — los enlaces markdown sí funcionan en la descripción de la tarjeta (NO en comentarios).

### 2.12 Bloque "🏁 Resultado y cierre" (diferido)

Bloque fijo pero **diferido**: se crea vacío con placeholders al crear la tarjeta y se completa al cierre del producto/SPIKE aplicando el flujo formal de cierre (sección 11).

**Importante:** al crear la tarjeta, este bloque se incluye **siempre** con los placeholders intactos. Sirve de recordatorio visual de que el producto tiene una fase de cierre pendiente.

```markdown
---

## 🏁 Resultado y cierre
> ⚠️ Bloque diferido — se completa al cierre del [SPIKE/Producto] siguiendo el flujo formal de cierre (skill `formato-tarjeta-clickup-reinicia`, sección 11).

**Conclusión**
*[Hipótesis confirmada / refutada / parcialmente confirmada — 1-2 líneas]*

**Decisión del cliente**
*[Autorizar implementación / Replantear / Descartar — fecha de la decisión]*

**Estimación de esfuerzo para producto de implementación**
*[Horas estimadas para el producto de implementación posterior]*

**Producto de implementación derivado**
*[Enlazar vía la funcionalidad nativa de "Elementos relacionados" de ClickUp]*

**Documentación generada**
*[Enlace al documento Zoho Writer en Workdrive — añadir cuando esté disponible]*

> 📝 **Nota de proceso para el PO:** El flujo estándar para la documentación generada es Opción C (híbrido):
> - **C.1 — Ediciones menores:** editar directamente el Zoho Writer desde la web (lo natural).
> - **C.2 — Actualizaciones mayores:** pedir a Claude que regenere el .docx con marca Reinicia y subir nueva versión a Workdrive (mantiene historial de versiones).
>
> Recordatorio: Claude no puede editar el contenido del Zoho Writer directamente vía MCP a día de hoy. Cuando esos endpoints estén disponibles, este flujo se automatizará.

**Lecciones aprendidas**
*[Aprendizajes que pueden aplicarse a futuros productos similares]*
```

**Convención visual:** los subepígrafes dentro de "Resultado y cierre" usan **negrita** (no `### H3`) por una razón técnica: ClickUp aplica margen vertical fijo a todos los headers, lo que impide que el subepígrafe quede pegado al placeholder. La negrita resuelve el problema sin perder legibilidad para subepígrafes con contenido corto.

El separador `---` antes del bloque marca visualmente que estamos en otra fase temporal del producto.

### 2.13 Convención del nombre de la tarjeta

Patrón base: `[Qué se entrega] [CLIENTE]`. En soporte y SPIKEs el patrón se extiende con prefijo de tipo: `[TIPO] [Qué se entrega] [CLIENTE]`.

**Principio rector:** el nombre describe el **entregable en estado final**, no la acción que se ejecuta para producirlo. Pensar siempre: *"cuando este producto se cierre, ¿qué quedará entregado?"* — eso es lo que da nombre a la tarjeta.

**Forma gramatical:** sustantivo o participio (estado), nunca verbo en infinitivo (acción).

**Ejemplos correctos vs antipatrón:**

| ❌ Antipatrón (acción) | ✅ Correcto (entregable) |
|---|---|
| Simplificar campos obligatorios en módulo Visitas | Campos obligatorios simplificados en módulo Visitas |
| Configurar Enhanced Conversions desde Zoho Forms | Enhanced Conversions configurado desde Zoho Forms |
| Reemplazar lista "Reasons for loss" | Lista "Reasons for loss" reemplazada |
| Implementar conector Zoho ↔ BC | Conector Zoho ↔ BC integrado |
| Resolver bug de duplicados en propiedades | Bug de duplicados en propiedades resuelto |
| Documentar protocolo de push a producción | Protocolo de push a producción documentado |

**Test rápido:** si el nombre puede ir precedido de *"Tarea: ___"* sin que suene raro, está en modo acción y hay que reformularlo. Si va precedido de *"Entregable: ___"* con naturalidad, está bien.

**Excepción — SPIKEs:** los SPIKEs llevan prefijo `[SPIKE]` y su nombre describe el **objeto de investigación**, no un entregable cerrado, porque su entregable es **conocimiento** sobre ese objeto. Ejemplos: `[SPIKE] Conector Zoho ↔ Brokerbin [CLIENTE]`, `[SPIKE] Viabilidad de migración a Drupal 10 [CLIENTE]`.

**Aplicabilidad:** esta convención aplica a **todos los productos creados en ClickUp por las skills de Reinicia** — productos digitales (`productos-digitales-zoho-clickup-reinicia`, `productos-digitales-web-clickup-reinicia`, `productos-digitales-waba-clickup-reinicia`), SPIKEs (`spike-clickup-reinicia`) y tareas de soporte (`soporte-procesamiento-clickup-reinicia`). Las skills mencionadas referencian esta sección 2.13 en lugar de duplicar la regla.

---

## 3. Convenciones de markdown en ClickUp

### 3.1 Lo que funciona

| Elemento | Funciona | Notas |
|---|---|---|
| `# H1` y `## H2` | ✅ | Aplican margen fijo (limitación, ver 3.3) |
| `### H3` | ✅ | Margen menor que H2 |
| `**negrita**` | ✅ | |
| `*cursiva*` | ✅ | Útil para placeholders en bloque diferido |
| Listas `-` | ✅ | |
| Listas numeradas `1.` | ✅ | |
| `> blockquote` | ✅ | Sin margen extra — ideal para RESUMEN y notas destacadas |
| `[texto](url)` | ✅ | **Funciona en descripción** |
| Emojis | ✅ | Anclas visuales por sección |
| `---` separador | ✅ | Marca cambio de fase temporal |

### 3.2 Lo que NO funciona

| Elemento | No funciona | Alternativa |
|---|---|---|
| `[texto](url)` en comentarios | ❌ | URL en línea separada del texto descriptivo |
| Citas anidadas `> >` | ⚠️ Frágil | Evitar |
| HTML embebido (`<br>`, `<div>`) | ⚠️ No fiable | Evitar |

### 3.3 Limitación conocida de ClickUp: margen fijo bajo `## H2`

**Síntoma:** ClickUp aplica un margen vertical fijo bajo cada header `##`. No hay forma de eliminarlo desde markdown — ni con saltos de línea, ni sin ellos, ni con caracteres invisibles.

**Implicación:** la separación entre un header y su contenido siempre tendrá un espacio visual mayor del que generaría si todo fuera párrafo. Esto puede dar sensación de "huecos" en algunas secciones cortas.

**Mitigaciones:**

1. **Aceptarlo como parte del patrón** — la separación funciona como respiración entre bloques temáticos.
2. **Usar `**negrita**` en lugar de `## H2`** sólo para subepígrafes dentro de un bloque (caso de "🏁 Resultado y cierre").
3. **Pase manual del PO** — el editor visual de ClickUp permite eliminar manualmente esos espacios si la tarjeta requiere compacidad extra. Esto NO es replicable por Claude vía MCP (Claude trabaja sobre markdown fuente; el PO trabaja sobre el árbol de bloques renderizado).

**Regla de uso:**
- `## H2` para bloques de primer nivel (las secciones del patrón).
- `**negrita**` para subepígrafes dentro de un bloque cuando se necesita compactar (sólo en "Resultado y cierre" en el patrón canónico actual).

---

## 4. Convenciones de campos personalizados

Las tarjetas de producto en ClickUp usan campos personalizados que dependen de la lista. Los IDs y opciones se documentan en cada skill de creación de producto. Aquí se fija únicamente la **convención de uso**:

### 4.1 Campos siempre rellenados al crear

- **PROYECTO** — cliente del producto
- **TIPO DE PRODUCTO** — CRM / DESARROLLO WEB / WHATSAPP CORPORATIVO / GESTIÓN CRM / EMAIL MARKETING / etc.
- **PO** — Product Owner de Reinicia (ALVARO, NESTOR, ELENA, BORJA, ALEJANDRO, PATRICIA, MARTA, PABLO, OSCAR)
- **ÉPICA** — fase del customer journey (00. BRAND AWARENESS … 08. ADVOCACY) o transversal (PLANIFICACIÓN, FORMACIÓN)
- **PBIs PRIMER NIVEL** — texto libre, lo acuerda el PO

### 4.2 Campos condicionales

- **AMIGOS REINICIA** — sólo si participa colaborador externo
- **REFINADO** — checkbox. Siempre `false` al crear. El PO lo marca cuando el producto está listo para sprint
- **ORDEN** — numérico. **No se asigna al crear**. Se asigna en Sprint Planning
- **Tiempo estimado** — sólo si el PO lo conoce al crear

### 4.3 Convención sobre el campo PO

El campo PO tiene un valor único por producto. Si hay co-PO (raro), se documenta en la descripción y se elige uno como titular en el campo.

---

## 5. Asignación de subtareas (pregunta al PO)

Las skills de creación de producto **deben preguntar explícitamente** al PO cómo asignar las subtareas creadas. La pregunta se hace al final de la creación, una vez todas las subtareas están en ClickUp:

```
He creado [N] subtareas sin asignar. ¿Cómo prefieres asignarlas?

a) Todas al mismo equipo / persona — me dices a quién.
b) Distribución por bloque (yo te propongo, tú apruebas).
c) Subtarea por subtarea — me indicas cada una.
d) Las asignas tú directamente desde ClickUp.
```

**Importante:** Claude **nunca asigna subtareas sin confirmación explícita del PO**.

---

## 6. Comentarios

### 6.1 Limitación de markdown en comentarios

El MCP de ClickUp **no acepta markdown en comentarios** — solo texto plano. Esto incluye:
- ❌ Sin `**negrita**`
- ❌ Sin `[texto](url)` (los enlaces deben ir en línea separada como URL cruda)
- ❌ Sin headers
- ❌ Sin listas formateadas con caracteres especiales

Las listas se simulan con saltos de línea y prefijos planos (`- item` o `[Tag] descripción`).

### 6.2 Uso canónico de comentarios

Los comentarios cubren cuatro casos de uso fijos:

**Caso A — Criterios de aceptación pendientes de copiar al checklist**

Después de crear la tarjeta, Claude pega un comentario con los criterios de aceptación listos para que el PO los copie manualmente al checklist (ClickUp no permite crear checklists vía MCP).

Formato:

```
CRITERIOS DE ACEPTACIÓN — para copiar manualmente al checklist

[Técnicos] Criterio 1
[Técnicos] Criterio 2
[Funcionales] Criterio 3
[Funcionales] Criterio 4
[De proceso] Criterio 5
```

Una línea por criterio. Categoría en corchetes como prefijo. Sin headers, sin negrita.

**Caso B — Enlaces a documentos relacionados**

Cuando se quiere enlazar un documento o recurso desde un comentario, formato en dos líneas:

```
"Privado - Diseño Funcional - CARRITECH"
https://workdrive.zoho.eu/file/abc123
```

Texto descriptivo entrecomillado en una línea. URL cruda en la siguiente.

**Caso C — Trazas y notas de proceso**

Comentarios cortos que registran un evento (entrega, validación, decisión, cambio de estatus). Texto plano corto, sin formato.

**Caso D — Comentario de cierre (trazabilidad)**

Comentario estructurado que registra el cierre formal del producto. Se usa **junto con** la edición del bloque "🏁 Resultado y cierre" en la descripción (ver sección 11). El comentario aporta trazabilidad temporal (queda en el feed de comentarios con su fecha); la descripción aporta consolidación (queda como historia oficial).

Formato:

```
CIERRE DEL [PRODUCTO/SPIKE] — [fecha]
Cerrado por: [Persona del Equipo Operativo que cerró el producto]

Conclusión:
[Texto de conclusión]

Decisión del cliente:
[Texto de decisión]

Estimación esfuerzo implementación:
[Horas]

Producto derivado:
[Nombre del producto + URL si aplica]

Documentación generada:
"[Nombre del documento]"
[URL del documento]

Lecciones aprendidas:
[Texto]
```

---

## 7. Checklist

### 7.1 Limitación

ClickUp permite crear checklists desde la interfaz pero **NO vía MCP**. Claude no puede crear checklists ni añadir items a checklists existentes.

### 7.2 Patrón estándar

Toda tarjeta de producto debe tener un checklist titulado **"CRITERIOS DE ACEPTACIÓN"** con los criterios divididos en tres bloques:

```
[Técnicos]    — entorno, infraestructura, accesos, despliegue
[Funcionales] — comportamiento esperado del sistema o entregable
[De proceso]  — validaciones, evidencias, comunicación, trazabilidad
```

Como Claude no puede crearlo, deja el contenido en un comentario (ver 6.2 caso A) y avisa al PO de que debe copiarlo manualmente al checklist.

---

## 8. Elementos relacionados

ClickUp ofrece la funcionalidad nativa de **"Elementos relacionados"** para enlazar tarjetas entre sí. Se usa en Reinicia para:

### 8.1 Casos de uso

- **SPIKE → Producto de implementación derivado** — cuando un SPIKE concluye con autorización del cliente y nace un producto de implementación, se enlazan ambas tarjetas.
- **Producto principal ↔ Productos prerequisito** — cuando un producto depende de otro (típico en backlog Zoho con Consultoría Preliminar → Definitiva).
- **Versiones del mismo producto** — V1, V2, V3 si hay iteraciones mayores.
- **Producto Soporte ↔ Producto General de origen** — cuando un soporte se origina en una funcionalidad implementada por un producto previo, conviene enlazar.

### 8.2 Cómo se enlaza vía MCP

La herramienta `clickup_add_task_link` crea la relación bidireccional entre dos tareas. Las skills de creación de productos documentan cómo invocarla (típicamente al ejecutar el flujo de cierre formal — ver sección 11).

---

## 9. Limitaciones conocidas (resumen consolidado)

| Limitación | Impacto | Mitigación |
|---|---|---|
| Margen fijo bajo `## H2` | Espaciado no compactable desde markdown | Aceptarlo o pase manual del PO |
| Comentarios sin markdown | URLs y formato pierden estructura | Texto plano + URL cruda en línea separada |
| Checklists no creables vía MCP | El PO debe copiar manualmente desde un comentario | Claude pega el comentario con el contenido listo |
| Edición fina del editor visual | Backspace tras headers, márgenes ajustables, etc. son sólo manuales | El PO puede pulir tras la generación automática |
| Zoho Writer no editable directamente | Claude no puede actualizar el contenido del Writer vía MCP | Flujo Opción C documentado en bloque "Resultado y cierre" |

---

## 10. Cómo invocar este patrón desde otra skill

Las skills de creación de producto (Zoho, Web, WABA, SPIKE) **no replican el patrón** — lo referencian. Patrón de invocación en cada skill de creación:

```
Para la descripción de la tarjeta, sigue el patrón canónico definido en la skill
`formato-tarjeta-clickup-reinicia`. Aplican los bloques fijos y los opcionales que
correspondan al tipo de producto. El bloque "🏁 Resultado y cierre" se crea siempre
con sus placeholders, y se completa al cierre invocando el flujo de cierre formal
(sección 11 de `formato-tarjeta-clickup-reinicia`).
```

Si una skill necesita matizar algún bloque (por ejemplo, "Descripción" en WABA puede incluir "Plataforma WABA: Woztell / Blip / Eazybe"), el matiz se documenta en la skill específica como **extensión del patrón canónico**, no como redefinición.

**Recordatorio para skills madre:** durante la elicitación, preguntar siempre al PO por la persona del cliente que aparecerá en la Historia de usuario (sección 2.2). Aplica los tres casos (única conocida, varias, no conocida todavía) y nunca inventes un nombre.

---

## 11. Flujo formal de cierre del producto

Esta sección define el procedimiento que ejecuta Claude cuando el PO vuelve a la conversación para **cerrar formalmente** un producto. Las skills de creación de producto referencian esta sección — no la duplican.

### 11.1 Cuándo se ejecuta

El cierre formal se ejecuta cuando se cumplen las dos condiciones:

1. **El producto está terminado operativamente** — todas las subtareas hechas, criterios de aceptación validados, entregables entregados.
2. **El PO vuelve a Claude solicitando el cierre** — típicamente con frases como:
   - "Vamos a cerrar el SPIKE de Carritech"
   - "Cierra formalmente el producto X"
   - "Hemos terminado el producto Y, registra el cierre"

Si una skill de creación de producto detecta que un producto se va a cerrar, puede invocar esta sección directamente.

### 11.2 Inputs requeridos

Antes de iniciar el cierre, Claude pregunta secuencialmente:

**Pregunta C1 — Identificación de la tarjeta**

```
¿Cuál es la tarjeta ClickUp del producto a cerrar? (ID o URL)
```

**Pregunta C2 — Persona del Equipo Operativo que cerró el producto**

```
¿Quién del Equipo Operativo ha cerrado este producto? Necesito su nombre para
registrarlo en la trazabilidad del cierre.
```

**Pregunta C3 — Confirmación de fuentes**

```
Para preparar el cierre voy a:
- Leer todos los comentarios de la tarjeta
- Listar los enlaces a documentación generada
- Recoger el estado actual de subtareas y checklist
- Identificar el producto derivado (si aplica) para enlazarlo

¿Procedo o quieres añadirme alguna fuente adicional (acta de cierre, correo, etc.)?
```

### 11.3 Procedimiento de cierre

**Paso 11.3.1 — Recopilación de información**

Claude ejecuta:
- `clickup_get_task` con `subtasks=true` para recuperar la tarjeta y sus subtareas
- `clickup_get_task_comments` y `clickup_get_threaded_comments` para todos los comentarios
- Si hay enlaces a Workdrive en la descripción o comentarios, registra los IDs de los documentos

**Paso 11.3.2 — Síntesis estructurada**

Claude prepara una propuesta de contenido para los 6 sub-bloques del bloque "🏁 Resultado y cierre":

1. **Conclusión** — síntesis 1-2 líneas. Para SPIKEs: hipótesis confirmada/refutada/parcialmente.
2. **Decisión del cliente** — autorizada / replanteada / descartada + fecha. Si no hay decisión registrada, dejar "Pendiente de registrar".
3. **Estimación de esfuerzo para producto de implementación** — solo aplica a SPIKEs y a productos preparatorios. Tomar de comentarios o preguntar al PO.
4. **Producto de implementación derivado** — si existe, identificar tarjeta destino para enlazarla con `clickup_add_task_link`.
5. **Documentación generada** — listar enlaces a Zoho Writer / docs subidos a Workdrive durante el producto.
6. **Lecciones aprendidas** — propuestas extraídas de los comentarios + propuestas propias de Claude. Confirmar con el PO antes de plasmar.

**Paso 11.3.3 — Validación con el PO**

Claude presenta la propuesta completa al PO:

```
PROPUESTA DE CIERRE — [Nombre del producto]

Cerrado por: [Persona del Equipo Operativo]
Fecha: [hoy]

[Propuesta para los 6 sub-bloques]

¿Apruebas este contenido para el cierre? ¿Quieres modificar algo?
```

El PO valida o ajusta. Claude espera aprobación explícita antes de escribir.

**Paso 11.3.4 — Escritura en ClickUp**

Una vez aprobado, Claude ejecuta **dos acciones**:

**Acción 1 — Edición de la descripción (consolidación)**

`clickup_update_task` con `markdown_description` que reemplaza el bloque "🏁 Resultado y cierre" placeholder por el contenido aprobado, manteniendo intacto el resto de la descripción.

**Acción 2 — Comentario de cierre (trazabilidad temporal)**

`clickup_create_task_comment` con el formato del Caso D (sección 6.2) — texto plano con la misma información, pero como evento datado en el feed.

**Acción 3 — Enlace a producto derivado (si aplica)**

`clickup_add_task_link` para crear la relación bidireccional entre la tarjeta cerrada y el producto de implementación derivado.

**Paso 11.3.5 — Confirmación final al PO**

```
✅ Cierre formal completado — [Nombre del producto]

URL: [URL de la tarjeta]

Acciones ejecutadas:
- Bloque "Resultado y cierre" actualizado en la descripción
- Comentario de cierre publicado en la tarjeta
- [Si aplica] Enlace a producto derivado creado

Pendiente de tu lado:
- Cambiar el estatus de la tarjeta a "cerrada" / "completada"
- Marcar como REFINADO=false si procede archivarla
```

### 11.4 Flujo Opción C aplicado al cierre

Durante el cierre formal, si hay un documento Zoho Writer asociado al producto (típicamente el de Diseño Funcional en SPIKEs), el PO puede querer actualizarlo para reflejar el resultado. Aplica el flujo **Opción C** documentado en el bloque "🏁 Resultado y cierre":

- **C.1 — Ediciones menores:** el PO edita el Zoho Writer manualmente desde la web.
- **C.2 — Actualizaciones mayores:** Claude regenera el `.docx` con marca Reinicia incluyendo la nueva información de cierre, y el PO sube nueva versión a Workdrive.

Claude **no puede** editar el contenido de un Zoho Writer existente vía MCP. Esta limitación se recuerda al PO durante el flujo de cierre.

---

## 12. Versionado del patrón

| Versión | Fecha | Cambio |
|---|---|---|
| v1.0 | 2026-04-23 | Versión inicial. Patrón consolidado tras iteración con SPIKE Carritech (tarjetas 869cwcgd0 y 869d27k45). |
| v1.1 | 2026-04-23 | Cambios validados: "Datos del producto" → "Descripción"; "Ready to Backlog" sube de posición; "Alcance" pasa a opcional; "Resultado y cierre" se mantiene como bloque diferido pero su rellenado se modela como flujo formal (sección 11); nuevo bloque opcional "📥 Requerimientos Cliente" para Soporte y peticiones directas; "Contexto" puede aparecer como "No definida"; añadido Caso D de comentarios para cierre; protocolo de cierre formal en 5 pasos con doble escritura (descripción + comentario). |
| v1.2 | 2026-04-23 | Añadida en bloque 2.4 la regla de preservación literal (Alt B) cuando el origen del producto es un formulario de ClickUp: Claude copia íntegra y literalmente la descripción auto-generada al bloque "Requerimientos Cliente" antes de aplicar el patrón canónico al resto de la tarjeta. |
| v1.3 | 2026-04-27 | Sección 2.13 nueva — Convención del nombre de la tarjeta como principio rector explícito, con tabla de antipatrón → correcto, test rápido ("Tarea:" vs "Entregable:") y excepción documentada para SPIKEs. Consolida en fuente de verdad transversal lo que antes estaba mencionado de pasada en las skills madre. Motivada por la primera prueba de soporte-procesamiento-clickup-reinicia v1.0 sobre Avaderm 869ctbft1 (27/04/2026), donde el nombre canónico salió en modo acción ("Simplificar campos...") en lugar de modo entregable ("Campos simplificados..."). Skills derivadas que referencian 2.13: productos-digitales-zoho-clickup-reinicia, productos-digitales-web-clickup-reinicia, productos-digitales-waba-clickup-reinicia, spike-clickup-reinicia, soporte-procesamiento-clickup-reinicia. |
| v1.4 | 2026-05-03 | Sección 2.2 reescrita: la Historia de usuario incorpora ahora la persona concreta del cliente (Nombre + Rol) en lugar de sólo el rol genérico. Documentados los tres casos (única conocida, varias, no conocida todavía) con placeholder visible "(persona pendiente de identificar)". Convención transversal a todos los tipos de producto. Añadido recordatorio en sección 10 para que las skills madre pregunten por la persona durante la elicitación. |

Cualquier cambio futuro al patrón se documenta aquí. Las skills que lo referencian se actualizan en consecuencia.
