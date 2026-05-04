---
name: soporte-correo-clickup-reinicia
description: Skill conversacional para crear productos de soporte en ClickUp a partir de correos electrónicos enviados por clientes (HomeEspaña, Carritech, Gonher, Avaderm). El PO pega el correo en Claude, Claude reconstruye los 5 campos del formulario estándar de soporte (Solicitante, Email, Nombre de la petición, Detalle, Adjuntos) — extrayendo lo que pueda del correo y preguntando lo que falte — propone tarjeta canónica completa, valida con el PO, y solo entonces crea la tarjeta en `Soporte [CLIENTE]` directamente en estado Product Backlog. Imputa el tiempo de análisis del PO como time entry. La estructura resultante es idéntica a las tareas brutas del cron, garantizando paridad y trazabilidad. Marca "Primer Refinamiento Individual Realizado" para coherencia. No usar para tareas creadas vía formulario (skill `soporte-procesamiento-clickup-reinicia`), ni para crear productos en General.
triggers:
  - tengo un correo de soporte
  - crea producto de soporte desde correo
  - cliente me ha enviado correo
  - soporte por email
  - soporte por correo
  - producto de soporte desde correo
---

# SKILL: Soporte por Correo Electrónico — ClickUp Reinicia

## Propósito

Cuando un cliente envía un correo electrónico con una petición de soporte (a Néstor, Óscar, Pablo o cualquier interlocutor de Reinicia), esta skill convierte ese correo en un producto de soporte en ClickUp con la **misma estructura** que tendría si el cliente hubiera rellenado el formulario estándar de ClickUp.

A diferencia de la skill `soporte-procesamiento-clickup-reinicia` (que procesa tareas brutas creadas automáticamente por el formulario y corre desde un cron cada 30 min), esta skill es **manual y conversacional**: el PO la dispara, pega el correo, valida la propuesta y se crea la tarjeta. El tiempo de análisis del PO se imputa como time entry para reflejar el trabajo de valor que el PO ha hecho.

**Decisión clave de diseño (v1.1):** la skill no inventa campos — usa el **formulario de soporte de ClickUp como contrato canónico**. Reconstruye los mismos 5 campos que rellenaría el cliente, garantizando que la tarjeta resultante sea estructuralmente idéntica a una tarea procesada por el flujo automático. Esto asegura paridad entre los dos flujos y permite que reportes, métricas y auditorías traten ambos como un único conjunto.

---

## 1. El formulario estándar de soporte como contrato

El formulario de ClickUp que rellenan los clientes en sus listas de Soporte tiene 5 campos canónicos (extraídos del análisis de tareas reales con `taskType: form_response`):

| # | Pregunta del formulario | ID custom field | Tipo | Required |
|---|---|---|---|---|
| 1 | ¿Quién realiza la solicitud? | `9ac2e551-f71b-4f2f-af2f-5720be57801d` | short_text | No |
| 2 | Email para contactarte | `4b38d200-d2a4-495b-8f4e-2482bcac4185` | short_text | No |
| 3 | Pon nombre a lo que necesitas | `f2e37010-9f11-4a2b-b30c-0d8aa3aeb96c` | short_text | No |
| 4 | Cuéntanos con todo el detalle que puedas qué es lo que necesitas | `b969c43b-e83c-4ae9-9a22-2a1b8d4b3c82` | text | No |
| 5 | Adjuntos que puedas aportar | `1bc6bbc6-0be2-4393-8c71-9a3f808f1e8e` | attachment | No |

**Comportamiento dinámico:** al arrancar, la skill **verifica los IDs y nombres de los campos** leyendo el último `taskType: form_response` de la lista de Soporte del cliente seleccionado. Si los IDs no coinciden con la tabla, la skill usa los IDs reales del cliente y deja la discrepancia como pista para iteración (sección 11). Si el formulario evoluciona, la skill se adapta sin tocar código.

**Ámbito v1.1:** esta tabla refleja el formulario reverse-engineered de Carritech. La hipótesis vigente es que los 4 clientes piloto comparten el mismo formulario plantilla, por lo que los IDs deberían coincidir. Si en una ejecución concreta no coinciden, la skill se adapta dinámicamente y reporta la diferencia.

---

## 2. Configuración de clientes piloto

La tabla canónica vive en `soporte-procesamiento-clickup-reinicia` sección 2. Esta skill la usa por referencia, sin duplicar.

Resumen aplicable:

| Cliente | Equipo | Lista Soporte | PO Técnico | PO Cliente |
|---|---|---|---|---|
| HomeEspaña | Proactive | `901216563068` | Paolo Bergamelli (`2447443`) | Óscar Díez (`93631901`) |
| Carritech | Proactive | `901215748066` | Fabián Vargas (`93744950`) | Óscar Díez (`93631901`) |
| Gonher | Columbia | `901209826214` | Paolo Bergamelli (`2447443`) | Pablo Losada (`87715920`) |
| Avaderm | Columbia | `901210493032` | Paolo Bergamelli (`2447443`) | Pablo Losada (`87715920`) |

**Cliq durante piloto:** desactivado (`cliq_publish: false` para los 4 clientes).

---

## 3. Flujo conversacional

El flujo se ejecuta en **8 pasos secuenciales**. Claude no se salta pasos ni los reordena.

### Paso 1 — Identificación del PO disparador

Pregunta corta al inicio:

```
Antes de empezar, ¿quién dispara este producto?
- Néstor
- Óscar
- Pablo
- Otro (escribe el nombre)
```

**Comportamiento:**

- Por defecto Néstor si el contexto sugiere que es él y no responde explícitamente.
- "Otro" → el PO escribe nombre en texto libre. Claude lo busca en ClickUp con `clickup_find_member_by_name` para obtener el `user_id` necesario para el time entry.
- Si "Otro" se repite en sesiones futuras, queda como pista para añadirlo al menú en próxima versión.

El PO identificado se usa para:
1. Crear el time entry asociado a su `user_id`.
2. Mantener contexto del equipo.

### Paso 2 — Identificación del cliente

```
¿Para qué cliente es la petición?
- HomeEspaña
- Carritech
- Gonher
- Avaderm
```

Si el correo ya menciona claramente el cliente, Claude propone uno por defecto y pide confirmación. Si no, pregunta abierto.

**Tras este paso, Claude carga la estructura del formulario del cliente** consultando el último `taskType: form_response` de su lista de Soporte. Esto verifica IDs y detecta variaciones del formulario base.

### Paso 3 — Recibir el correo

El PO pega el correo. La skill acepta cualquier formato:

- Cabeceras (From, To, Subject, Date) + cuerpo + mención de adjuntos — ideal.
- Solo cuerpo del correo — válido, la skill no insiste en cabeceras.
- Hilo largo (múltiples respuestas) — la skill **prioriza el último mensaje del cliente** como petición principal y referencia el resto como contexto.

### Paso 4 — Reconstrucción del formulario (5 campos)

Aquí está el corazón de la skill. Claude **reconstruye los 5 campos del formulario** uno por uno, extrayendo del correo lo que pueda y preguntando solo lo que no esté claro. Validación campo a campo.

#### 4.1 ¿Quién realiza la solicitud?

Claude extrae el nombre del solicitante del `From` del correo, de la firma o de menciones internas. Pregunta:

```
Campo 1/5 — ¿Quién realiza la solicitud?
Detectado del correo: [nombre]
¿Es correcto? [Sí / Corregir]
```

Si no se detecta, pregunta abiertamente.

#### 4.2 Email para contactarte

Claude extrae el email del `From` o de la firma. Pregunta:

```
Campo 2/5 — Email para contactarte
Detectado del correo: [email]
¿Es correcto? [Sí / Corregir]
```

#### 4.3 Pon nombre a lo que necesitas

Claude propone un nombre corto extrayéndolo del asunto del correo o sintetizando del cuerpo. **Aún no es el nombre canónico de la tarjeta** — es el campo del formulario tal como lo rellenaría el cliente, en su voz.

```
Campo 3/5 — Pon nombre a lo que necesitas
Propuesta: "[texto sintético en la voz del cliente]"
¿Te parece bien? [Sí / Reformular / Lo escribo yo]
```

Ejemplo: si el cliente escribe sobre cambiar la lista de Reasons for loss, una propuesta válida es `"New list of reasons for loss"` (en su idioma) o `"Cambio de lista de motivos de pérdida"` (si el correo está en castellano).

#### 4.4 Cuéntanos con todo el detalle que puedas qué es lo que necesitas

Este campo es **el cuerpo del correo, literal**. La skill no resume, no reformula, no traduce. Preserva exactamente lo que el cliente escribió.

```
Campo 4/5 — Cuéntanos con todo el detalle que puedas qué es lo que necesitas
He copiado el cuerpo del correo literal. ¿Quieres revisarlo o lo dejamos tal cual?
[Dejarlo tal cual / Quiero ajustar]
```

Si el correo es un hilo largo, la skill incluye el último mensaje del cliente como cuerpo principal y añade los anteriores como contexto al final del campo, identificados con un separador claro:

```
[Último mensaje del cliente, completo]

---
Contexto adicional (mensajes anteriores del hilo):
[mensaje N-1]
[mensaje N-2]
```

#### 4.5 Adjuntos que puedas aportar

Si el correo mencionaba adjuntos, Claude pregunta:

```
Campo 5/5 — Adjuntos que puedas aportar
El correo original incluía [N] adjuntos: [lista de nombres].

Para mantener trazabilidad, lo recomendable es subirlos a Zoho Workdrive y darme la ruta. ¿Cómo procedemos?

1. Subir a Workdrive y darme la ruta:
   - Si es un solo fichero: dame la ruta del fichero.
   - Si son varios: dame la ruta de la carpeta donde los pongas.
2. No puedo / no quiero subirlos ahora — los menciono en el campo y los subes después.
```

Si no había adjuntos, Claude lo confirma y pasa al Paso 5 sin preguntar.

### Paso 5 — Clasificación interna y propuesta de tarjeta canónica

Con los 5 campos del formulario ya rellenos, Claude:

1. **Clasifica internamente**:
   - Dominio: Zoho CRM / Web / WABA / Mixto / Por confirmar.
   - Tipo: BUG / MEJORA / DUDA / PETICIÓN / SOPORTE-SERVIDOR.
   - Nivel de servicio propuesto: Soporte Operativo Continuo / Mejoras Evolutivas / Proyectos Nuevos.

2. **Busca productos similares** en ClickUp para enriquecer la propuesta de subtareas (sección 6).

3. **Construye la tarjeta canónica completa** siguiendo el patrón de `formato-tarjeta-clickup-reinicia` y la presenta al PO en un único bloque para validación.

```
📋 PROPUESTA DE PRODUCTO DE SOPORTE — [CLIENTE]

CAMPOS DEL FORMULARIO (los 5 que se rellenarán):
1. ¿Quién realiza la solicitud?: [valor]
2. Email para contactarte: [valor]
3. Pon nombre a lo que necesitas: [valor]
4. Cuéntanos con todo el detalle que puedas qué es lo que necesitas: [valor — primeras líneas + resto preservado]
5. Adjuntos que puedas aportar: [ruta Workdrive o "Pendiente subir"]

CLASIFICACIÓN INTERNA:
- Dominio: [...]
- Tipo: [...]
- Nivel de servicio propuesto: [...]
- Razonamiento del nivel: [1-2 líneas]

NOMBRE CANÓNICO DE LA TARJETA:
[TIPO] [Entregable en estado final] [CLIENTE]

EQUIPO Y ASIGNADOS:
- Equipo: [Proactive / Columbia]
- PO Técnico: [...]
- PO Cliente: [...]

DESCRIPCIÓN CANÓNICA (preview):

> 🎯 RESUMEN
> [...]
> Entrega: [...]

## 📌 Historia de usuario
Como **[rol]**, **QUIERO** [...], **PARA** [...].

## 📋 Descripción
- Web: [...]
- Idiomas: [...]
- Objetivo Cliente: [...]
- Objetivo del Producto: [...]
- Público objetivo: [...]

## 📥 Requerimientos Cliente

> Petición original del cliente — correo electrónico — [fecha]
> De: [solicitante] <[email]>
> Para: [destinatario en Reinicia]
> Asunto: [asunto]

[Cuerpo del correo, literal]

[Si había adjuntos:]
Adjuntos del correo original — [disponibles en Workdrive: ruta] / [pendiente subir a Workdrive: lista]

## ✅ Ready to Backlog
- [...]

## 🌍 Contexto
[...]

## 📦 Entregables
**Reinicia (interno):** [...]
**Cliente:** [...]

## 📚 Documentación de referencia
- [...]

## 🏁 Resultado y cierre
> ⚠️ Bloque diferido — se completa al cierre del producto.

CAMPOS PERSONALIZADOS DE CLICKUP:
- PROYECTO: [Cliente]
- TIPO DE PRODUCTO: [CRM / DESARROLLO WEB / WHATSAPP CORPORATIVO]
- PO: [OSCAR o PABLO]
- ÉPICA: [05. ADOPTION habitualmente]
- REFINADO: false
- ORDEN: sin asignar
+ Los 5 campos del formulario rellenados con los valores del Paso 4

SUBTAREAS PROPUESTAS:
[Patrón mínimo o adaptado según búsqueda de similares]
1. [...] → [Asignado]
2. [...] → [Asignado]
3. [...] → [Asignado]
4. [...] → [Asignado]

POSIBLES DUPLICADOS DETECTADOS:
[Lista con URLs si los hay, o "ninguno detectado en lista Soporte CLIENTE"]

¿Apruebas esta propuesta tal como está?
- ✅ Sí, créala
- ✏️ Quiero ajustar [qué]
```

### Paso 6 — Validación e iteración

El PO valida con OK o pide ajustes. Si pide ajustes, Claude los aplica y vuelve a presentar la propuesta. **Hasta que el PO da OK, no se crea nada en ClickUp.**

### Paso 7 — Tiempo de análisis del PO

Antes de crear:

```
¿Cuánto tiempo has dedicado al análisis y documentación de este correo?
- 30 min (por defecto)
- 45 min
- 60 min
- Otro (escribe el valor en minutos)
```

Por defecto 30 min. Si el PO escribe "Otro" + valor, Claude lo normaliza a minutos.

### Paso 8 — Creación atómica en ClickUp

Una vez validado todo, la skill ejecuta en orden:

1. **Crea la tarea principal** en `Soporte [CLIENTE]` con:
   - `name`: nombre canónico aprobado en Paso 5/6.
   - `markdown_description`: descripción canónica completa.
   - `assignees`: [PO Técnico, PO Cliente] según tabla.
   - `status`: `"Product Backlog"` directamente.
   - `priority`: según urgencia detectada en el correo. Por defecto `normal`.
   - `custom_fields`: incluye **dos bloques**:
     - **Los 5 campos del formulario** rellenados con los valores del Paso 4 (IDs según tabla sección 1).
     - **Los campos canónicos**: PROYECTO, TIPO DE PRODUCTO, PO, ÉPICA, REFINADO=false.

2. **Crea las subtareas** validadas en el Paso 6, con `parent` apuntando a la tarea principal.

3. **Publica los comentarios estándar** (mismos que la skill automática, sección 8 de `soporte-procesamiento-clickup-reinicia`):
   - Comentario al PO Técnico con clasificación, nivel de servicio propuesto, preguntas pendientes si las hay, posibles duplicados.
   - Comentario con criterios de aceptación listos para checklist.
   - Comentario "Primer Refinamiento Individual Realizado" — **mismo texto exacto** que la skill automática, para que el cron del flujo formulario reconozca la tarjeta como ya procesada y no la toque.

4. **Imputa el time entry** del PO con la duración elegida en el Paso 7.

### Paso 9 — Reporte al PO

Tras la creación:

```
✅ Producto de soporte creado

[TIPO] [Nombre canónico] [CLIENTE]
URL: [https://app.clickup.com/t/...]

Resumen de lo creado:
- Tarjeta principal con descripción canónica completa
- 5 campos del formulario rellenados (paridad con tareas brutas del cron)
- [N] subtareas creadas y asignadas
- 3 comentarios publicados (refinamiento al PO Técnico, criterios de aceptación, marca de refinamiento)
- Time entry de [X] minutos imputado a [PO]
- Estado actual: Product Backlog

[Si había adjuntos pendientes de subir:]
⚠️ Recuerda subir a Workdrive los adjuntos del correo original: [lista]

[Si hay pistas para iteración:]
🔍 Pistas detectadas para mejorar la skill:
- [...]
```

---

## 4. Reglas canónicas que esta skill respeta

Esta skill **no inventa lógica nueva** — aplica las reglas que ya existen en otras skills:

| Regla | Fuente |
|---|---|
| Patrón de descripción de tarjeta (bloques 2.1 a 2.13) | `formato-tarjeta-clickup-reinicia` |
| Convención del nombre = entregable en estado final | `formato-tarjeta-clickup-reinicia` sección 2.13 |
| Preservación literal de la petición original | `formato-tarjeta-clickup-reinicia` sección 2.4 |
| Tipos de incidencia (BUG/MEJORA/DUDA/PETICIÓN/SOPORTE-SERVIDOR) | `soporte-procesamiento-clickup-reinicia` sección 6.1 |
| Niveles de servicio (Operativo / Evolutivas / Proyectos Nuevos) | `soporte-procesamiento-clickup-reinicia` sección 8.3 |
| Asignaciones por equipo (Proactive / Columbia) | `soporte-procesamiento-clickup-reinicia` sección 8.1 |
| Comentarios estándar al PO Técnico (Casos A y C) | `soporte-procesamiento-clickup-reinicia` sección 8 |
| Patrón mínimo de subtareas (4) | `soporte-procesamiento-clickup-reinicia` sección 9 |
| Marca "Primer Refinamiento Individual Realizado" | `soporte-procesamiento-clickup-reinicia` sección 8.6 |
| Limitaciones de markdown en comentarios | `formato-tarjeta-clickup-reinicia` sección 6 |
| **Estructura de los 5 campos del formulario** | **Esta skill, sección 1 — fuente de verdad** |

Cuando alguna de esas skills se actualice, esta hereda los cambios automáticamente sin tocar nada aquí.

---

## 5. Diferencias clave respecto a la skill automática

| Aspecto | Cron automático | Correo manual |
|---|---|---|
| Disparo | Tarea programada cada 30 min | Manual: PO pega correo |
| Origen del trabajo | Tarea bruta ya existe (`form_response`) | Tarea no existe — se crea desde cero |
| Estado inicial | Open → Product Backlog | Directamente Product Backlog |
| Validación humana | No (automático) | **Sí — obligatoria antes de crear** |
| Origen de la petición | Formulario ClickUp | Correo electrónico |
| Bloque "Requerimientos Cliente" | Descripción auto-generada del formulario | Cabeceras + cuerpo del correo |
| **Los 5 campos del formulario** | **Rellenos por el cliente al enviar** | **Rellenos por la skill desde el correo** |
| Time entry del PO | No (cron no consume tiempo del PO) | **Sí — imputación obligatoria al final** |
| Subtareas | Patrón mínimo único | Patrón mínimo + adaptaciones según similares |
| Búsqueda de similares | No | Sí (2-3 búsquedas) |
| Reporte | En conversación de Cowork | En conversación con el PO |

**Paridad estructural:** las dos rutas producen tarjetas con la **misma estructura de campos personalizados** (los 5 del formulario + los canónicos). Esto significa que reportes, métricas y auditorías pueden tratar las dos rutas como un único conjunto sin distinguir el origen.

---

## 6. Subtareas adaptadas

La búsqueda de productos similares para enriquecer las subtareas funciona así:

### 6.1 Búsqueda en el cliente actual

`clickup_filter_tasks` o `clickup_search` con `list_ids: [Soporte del cliente actual]` y keywords del campo 4 del formulario (Cuéntanos con detalle...). Filtrar por:

- Mismo tipo de incidencia (`[BUG]`, `[PETICIÓN]`, etc.) en el nombre.
- Mismo módulo / sistema afectado (palabras clave del correo).

Para cada resultado, llamar `clickup_get_task` con `subtasks=true` y leer las subtareas.

### 6.2 Búsqueda cruzada en otros clientes piloto

Si el paso 6.1 devuelve menos de 2 resultados con subtareas significativas, búsqueda en las otras 3 listas de Soporte (excluyendo el actual) con las mismas keywords.

### 6.3 Decisión de enriquecimiento

Comparar las subtareas de los productos similares con el patrón mínimo:

- Si todos los similares siguen el patrón mínimo → mantener patrón mínimo en la propuesta.
- Si los similares incluyen un paso recurrente que NO está en el patrón mínimo (ej. "Coordinar con Síntaris", "Reproducir en sandbox", "Documentar en Confluence", "Comunicar a delegados"), proponer ese paso adicional **citando el origen** en la justificación.

### 6.4 Cuando no hay similares útiles

Caer al patrón mínimo de 4 subtareas sin más, sin mencionar la búsqueda fallida en la propuesta.

### 6.5 El PO siempre puede ajustar

En la validación del Paso 6, el PO puede añadir, quitar o renombrar subtareas libremente. Las subtareas son una propuesta basada en evidencia previa, no un contrato.

---

## 7. Casos límite

### 7.1 Correo en idioma distinto al castellano

- Campos 3 y 4 del formulario: literales en el idioma del correo (preservación).
- Resto del patrón canónico (descripción interna): castellano.
- Nombre canónico de tarjeta: castellano (manteniendo términos técnicos en idioma original si el sistema los usa así).

### 7.2 Solicitante no identificable en el correo

Si el `From` o la firma no permiten identificar al solicitante del cliente, Claude pregunta al PO en el Paso 4.1. No bloquea — registra "Solicitante no identificado" como pista.

### 7.3 Correo con múltiples peticiones distintas

Si el correo mezcla 2+ peticiones (BUG + MEJORA + DUDA, por ejemplo), Claude **propone crear varios productos** uno por petición, no uno solo. Pregunta al PO antes:

```
He detectado [N] peticiones distintas en este correo. ¿Quieres que cree [N] productos separados o un único producto para todas?
```

Si el PO elige separados, Claude ejecuta el flujo **una vez por petición**, manteniendo en cada bloque "📥 Requerimientos Cliente" la sección del correo correspondiente y nota cruzada al resto.

### 7.4 Correo que es respuesta a tarjeta existente

Si el correo hace referencia a una tarjeta ya en ClickUp (cliente comenta sobre algo en curso), Claude no crea producto nuevo — propone añadir el contenido del correo como **comentario** a la tarjeta existente. Pregunta al PO:

```
Este correo parece ser respuesta al producto [URL]. ¿Quieres que lo añada como comentario en lugar de crear uno nuevo?
```

### 7.5 Correo ambiguo o sin petición clara

Si el correo es informativo, una respuesta de cortesía o no contiene una petición accionable, Claude **no propone tarjeta** — informa al PO:

```
Este correo no contiene una petición de soporte clara. Confirma si quieres crear una tarjeta de seguimiento igualmente o si lo dejamos.
```

### 7.6 Tiempo del PO con valor "Otro"

Si el PO escribe "Otro" en el Paso 7 y luego un valor (ej. "75 minutos", "1.5h", "2h"), Claude lo normaliza a minutos y lo imputa. Si el valor no es interpretable, vuelve a preguntar.

### 7.7 Discrepancia entre IDs del formulario y la tabla canónica

Si al cargar el formulario del cliente (Paso 2) los IDs no coinciden con la tabla de la sección 1, Claude:

1. Usa los IDs reales del cliente (no falla la creación).
2. Reporta la discrepancia como pista de iteración: "El formulario de [CLIENTE] tiene los siguientes campos con IDs distintos a la tabla canónica: [...]. Considerar actualizar la sección 1 de la skill."

### 7.8 No hay ningún `form_response` previo en la lista del cliente

Si la lista de Soporte del cliente está vacía o ninguna tarea tiene `taskType: form_response`, la skill cae a la **tabla estática** de la sección 1 y advierte: "No he podido verificar la estructura del formulario de [CLIENTE] dinámicamente. Uso los IDs canónicos por defecto. Si el formulario es distinto, los campos no se rellenarán correctamente."

---

## 8. Principio de prudencia

Aunque esta skill es manual y conversacional, aplica el mismo principio de prudencia documentado en `soporte-procesamiento-clickup-reinicia` sección 12:

- Ante cualquier duda razonable sobre clasificación, asignación, dominio o subtareas, Claude **pregunta al PO** antes de proponer.
- Las dudas se concentran en el bloque de propuesta del Paso 5 como observaciones explícitas para que el PO las resuelva en la validación.
- Mejor 5 puntos a confirmar con el PO que 5 decisiones que el PO tendrá que revertir.

---

## 9. Captura de pistas para iteración

Igual que la skill automática (sección 11.3 de `soporte-procesamiento-clickup-reinicia`), esta skill registra explícitamente al final del reporte (Paso 9) las casuísticas raras o decisiones no triviales:

```
🔍 PISTAS PARA ITERACIÓN DE LA SKILL

[Solo si hay algo que reportar:]
- [Caso 1]
- [Caso 2]
```

Qué se considera pista:
- Patrón de correo no contemplado en la skill.
- "Otro" en el menú de PO que se ha repetido y conviene añadir al menú.
- Tipo de adjunto recurrente que merecería tratamiento específico.
- Productos similares encontrados que sugieren un patrón de subtareas estable.
- Casos donde el time entry estimado (30 min por defecto) es claramente insuficiente o excesivo.
- **Discrepancias entre el formulario real del cliente y la tabla canónica de la sección 1** — particularmente importante en v1.x para refinar la tabla.

---

## 10. Limitaciones conocidas

| Limitación | Mitigación |
|---|---|
| Markdown no soportado en comentarios ClickUp | Texto plano, URLs en línea separada |
| Checklists no creables vía MCP | Comentario con criterios de aceptación listos para copiar manualmente |
| Time entries solo se imputan al usuario autenticado en la integración ClickUp | Documentado para resolver en v1.2 con tokens multi-usuario |
| Adjuntos de correo no se suben automáticamente | Pedir al PO subida manual a Workdrive o mención en campo 5 |
| Búsqueda de similares basada en keywords | Falsos positivos posibles — propuesta orientativa, el PO decide |
| El formulario puede variar entre clientes | Comportamiento dinámico (Paso 2) detecta y se adapta. Reporte como pista si hay variación |

---

## 11. Versionado

| Versión | Fecha | Cambio |
|---|---|---|
| v1.0 | 2026-04-28 | Versión inicial. Flujo conversacional manual con elicitación libre. Pregunta inicial de PO disparador. Modo rápido con validación obligatoria antes de crear. Búsqueda de productos similares para enriquecer subtareas. Tiempo del PO con menú 30/45/60/Otro. Adjuntos: ruta en Workdrive o mención en Requerimientos Cliente. Estado inicial directo Product Backlog. Marca "Primer Refinamiento Individual Realizado". |
| v1.1 | 2026-04-28 | Refactor crítico: el formulario de soporte de ClickUp pasa a ser **contrato canónico** de la skill. Sección 1 nueva documenta los 5 campos estándar (¿Quién realiza la solicitud? / Email para contactarte / Pon nombre a lo que necesitas / Cuéntanos con todo el detalle... / Adjuntos que puedas aportar) con sus IDs reverse-engineered de Carritech. El Paso 4 reconstruye estos 5 campos validando uno a uno desde el correo (extracción + pregunta solo si falta). El Paso 8 rellena los 5 custom fields del formulario en la tarjeta creada, garantizando paridad estructural con las tareas brutas del cron. Comportamiento dinámico: la skill verifica IDs leyendo el último `form_response` del cliente antes de actuar (sección 7.7 y 7.8). Esta versión hace que las dos rutas (cron y correo) produzcan tarjetas estructuralmente idénticas, lo que permite reportes y métricas conjuntas. Motivado por feedback del PO el 28/04/2026: "habrá que preguntar cuestiones clave como quién remite la solicitud" y "tendrías que tener como referencia un formulario estándar". |

---

## 12. Notas operativas

- **Esta skill es exclusivamente manual**, no se programa en Cowork.
- El PO la dispara desde una conversación normal de Claude, en el contexto del proyecto Reinicia.
- Si la conversación se interrumpe a medio flujo (p.ej. el PO cierra la app), no se crea nada en ClickUp — la creación es atómica al final del Paso 8.
- La skill **no notifica al cliente** durante el piloto (Cliq desactivado).
- **No usar** esta skill para tareas creadas vía formulario ClickUp — esas las gestiona el cron de `soporte-procesamiento-clickup-reinicia` automáticamente.
- **No usar** para crear productos en `General [CLIENTE]` — eso es trabajo de las skills `productos-digitales-*-clickup-reinicia`.
- Si el correo del cliente describe trabajo que claramente NO es soporte sino un proyecto nuevo (alcance grande, presupuesto cerrado necesario), Claude lo detecta y propone redirigir el flujo: "Esto no parece soporte sino proyecto nuevo. ¿Cierro este flujo y abrimos uno con la skill `productos-digitales-*-clickup-reinicia` correspondiente?"
- **Validación dinámica del formulario:** la primera vez que un nuevo cliente piloto se añada a la tabla (sección 2), conviene ejecutar la skill al menos una vez para que la verificación dinámica (Paso 2) reporte si el formulario tiene algún campo distinto al canónico.
