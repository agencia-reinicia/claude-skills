---
name: flujograma-waba-miro-reinicia
description: >
  Skill para generar el contenido completo de un flujograma conversacional WABA/WhatsApp
  en Miro para clientes de Reinicia. Produce el texto de cada nodo del flujograma siguiendo
  la plantilla oficial de cards de Reinicia (extraída del proyecto Tee Travel): Texto Mensaje,
  Paso a paso en CRM, Paso a paso en Woztell/Blip, Cascada de validación y Notas Técnicas.
  Actívala siempre que el PO pida crear o documentar un flujograma conversacional de WhatsApp
  en Miro, diseñar el contenido de los nodos de un bot WABA, preparar el SPIKE de flujograma
  para un cliente, o generar la estructura de conversación de un chatbot antes de implementarlo.
  No usar para crear tareas en ClickUp (skill WABA ClickUp) ni para implementar el bot.
---

# SKILL: Flujograma WABA en Miro — Reinicia

## Propósito
Generar el contenido completo de cada nodo de un flujograma conversacional WABA siguiendo
la plantilla de cards de Reinicia, y crear el documento de referencia en el board de Miro
del cliente. El output está listo para que el equipo traslade el contenido al canvas visual
usando el Glosario / Leyenda visual de Reinicia.

**Referencia de proyecto validado:** Tee Travel
Board: https://miro.com/app/board/uXjVJhRL5MA=/

---

## PASO 1 — ELICITACIÓN

Claude hace las preguntas de forma **secuencial**.

### Pregunta 1: Cliente y objetivo del bot
"¿Para qué cliente es el flujograma? ¿Cuál es el objetivo principal del bot?
(Ejemplos: precualificación de leads, atención al cliente, soporte postventa, campañas…)"

### Pregunta 2: Plataforma
"¿Qué plataforma WABA usaréis: Woztell, Blip, u otra?"

→ Condiciona la sección "Paso a paso en [Plataforma]" de cada card.

### Pregunta 3: Integración CRM
"¿El bot se integrará con Zoho CRM? ¿Qué módulos usaréis: Leads (Posibles Clientes),
Contactos, Expedientes, otro?"

→ Determina si hay sección "Paso a paso en Zoho CRM" y qué módulos mapear.

### Pregunta 4: Idiomas
"¿El bot funcionará en un solo idioma o en varios? ¿Cuáles?"

→ Determina si hay nodos [ESP] / [ENG] paralelos o flujo único.

### Pregunta 5: Opciones del menú principal
"¿Qué opciones principales ofrecerá el menú del bot? ¿Cuántas y cuáles?
(Máximo 3 opciones en WhatsApp estándar — máximo 20 caracteres por opción)"

### Pregunta 6: Datos a recoger
"¿Qué información necesita recoger el bot del usuario antes de pasarlo a un agente?
(Nombre, apellidos, email, teléfono, número de expediente, destino, fecha…)
¿Estos campos están en Zoho CRM? ¿En qué módulo y con qué API Name?"

### Pregunta 7: Horario de atención y comportamiento
"¿Cuál es el horario de atención al cliente? ¿Qué hace el bot fuera de horario?
¿Hay número de emergencias al que derivar en casos urgentes?"

### Pregunta 8: T&C y privacidad
"¿Necesita el bot que el usuario acepte la Política de Privacidad antes de continuar?
Si es así, ¿cuál es la URL de la política?"

### Pregunta 9: Board de Miro
"¿Cuál es la URL del board de Miro donde creo el documento de referencia del flujograma?
Si no tienes board aún, puedo crear el documento igualmente y me pasas la URL después."

---

## PASO 2 — ESTRUCTURA DEL FLUJOGRAMA

Con la información recogida, Claude propone la **arquitectura de nodos** antes de desarrollar
el contenido de cada uno.

### Estructura canónica (basada en Tee Travel v2)

```
FASE ATRACCIÓN
  └─ Inicio / Bienvenida
  └─ T&C / Política de Privacidad   ← si aplica

FASE CONVERSIÓN
  └─ Menú principal (¿En qué podemos ayudarte?)
       ├─ Opción 1: [nombre] → Recogida de datos → Función CRM → Cierre / Transferencia
       ├─ Opción 2: [nombre] → Recogida de datos → Función CRM → Cierre / Transferencia
       └─ Opción 3: [nombre] → Cierre alternativo (canal de contacto)

NODOS TRANSVERSALES
  └─ Función: Revisar si existe Lead o Contacto   ← rhombus amarillo
  └─ Registro Existe / Registro No Existe          ← etiquetas de rama
  └─ Paso a paso CRM: Alta Lead / Alta Contacto / Actualización
  └─ Transferencia a agente humano con variantes de horario
```

Claude presenta esta estructura y espera aprobación del PO antes de desarrollar el contenido.

```
📐 ESTRUCTURA DEL FLUJOGRAMA — [CLIENTE]

ATRACCIÓN:
  [1] Inicio / Bienvenida
  [2] T&C / Política de Privacidad

CONVERSIÓN:
  [3] Menú: ¿En qué podemos ayudarte?
       ├─ [4a] Opción 1: [nombre]
       │    ├─ [5a] Recopilar información
       │    ├─ [6a] Función: ¿Existe en CRM?
       │    │    ├─ [7a] Registro Existe → Actualización CRM
       │    │    └─ [7b] Registro No Existe → Alta CRM
       │    └─ [8a] Cierre / Transferencia a agente
       ├─ [4b] Opción 2: [nombre]
       │    └─ [...]
       └─ [4c] Opción 3: [nombre] → Cierre alternativo

¿Añades o modificas algo antes de que desarrolle el contenido nodo a nodo?
```

---

## PASO 3 — CONTENIDO DE CADA NODO (uno a uno)

Aprobada la estructura, Claude genera el contenido completo de cada nodo siguiendo la
**plantilla oficial de cards de Reinicia**.

### ─────────────────────────────────────────
### PLANTILLA DE CARD — REINICIA WABA
### ─────────────────────────────────────────

```
TÍTULO: [IDIOMA si aplica] Nombre descriptivo del nodo
COLOR:  Azul #3812CF  → nodos de conversación / recogida de datos / CRM
        Amarillo #FFDC4A → nodos de T&C / legales
        Rombos amarillos #EBE31D → funciones y decisiones (no son cards)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEXTO MENSAJE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Texto literal que recibe el usuario en WhatsApp]

Formato: [Menú con N opciones (máx. 20 car./opción) / Conversacional pregunta a pregunta /
          Formulario in-app / Texto plano]

Variables dinámicas: [NOMBRE], [EXPEDIENTE], [FECHA]…

Si hay variantes condicionales, indicar TODAS:
  • Horario laborable + agente activo: [texto]
  • Horario laborable + sin agente activo: [texto]
  • Fuera de horario: [texto]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PASO A PASO EN ZOHO CRM   ← SOLO si hay integración CRM en este nodo
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Módulo destino: [Leads (Posibles Clientes) / Contactos / ambos con lógica condicional]

  Si existe como Lead →
    • Acción: [actualizar / convertir a Contacto / crear interacción]
    • Campos a actualizar (solo vacíos): [campo] → API Name: [api_name]

  Si existe como Contacto →
    • Acción: [actualizar / crear interacción]
    • Campos a actualizar (solo vacíos): [campo] → API Name: [api_name]

  Si NO existe →
    • Módulo: [Leads / Contactos]
    • Campos a guardar:
        [Nombre campo] → API Name: [api_name]
        ...
    • Campos recogidos de conversación (no preguntados):
        Teléfono → API Name: Phone
    • Campos ocultos automáticos:
        Canal de comunicación: WhatsApp
    • Campos que requieren desarrollo aparte ⚠️:
        UTM medium → API Name: utm_medium
        UTM source → API Name: utm_source
        UTM campaign → API Name: utm_campaign
        [otros UTMs si aplican]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PASO A PASO EN [WOZTELL / BLIP]   ← SOLO si hay lógica de plataforma en este nodo
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  • Comprobar si hay agente activo en [plataforma]
  • Si activo → avisar y transferir al agente
  • Si no activo → enviar mensaje "Laborable. No activo."

  ℹ️ La asignación automática a agentes se puede configurar en [plataforma]
  ⚠️ La asignación a carpetas del Inbox requiere desarrollo custom mediante API

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CASCADA DE VALIDACIÓN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Regla general: Ante cualquier input no esperado → [acción: repetir pregunta / repetir menú]

Mensaje de error: "[texto exacto que muestra el bot]"

Excepciones aceptadas (se dan por válidas):
  • Si escribe "1", "2"… → continuar con flujo
  • Si escribe palabras similares a las opciones (ej. "viaje comprado") → continuar
  • [otras excepciones específicas del nodo]

Regla para listas de selección: si la respuesta es textualmente similar a una opción
del listado, se acepta y guarda como seleccionada. Se aplican las mismas reglas de
validación que rigen en Zoho CRM para el campo de destino.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTAS TÉCNICAS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ [Decisión pendiente o limitación a resolver antes de implementar]
ℹ️ [Aclaración técnica sobre el comportamiento]
🔧 [Requiere desarrollo custom — indicar qué y por qué]
```

---

### Reglas de aplicación de la plantilla

**Secciones obligatorias:** Título, Texto Mensaje, Cascada de validación.

**Secciones condicionales:**
- "Paso a paso en Zoho CRM" → solo si el nodo escribe o lee datos del CRM.
- "Paso a paso en [Plataforma]" → solo si el nodo transfiere a agente o comprueba disponibilidad.
- "Notas Técnicas" → solo si hay algo relevante que documentar.

**Nodos que NO usan la plantilla de card** (son formas en el canvas, no cards):
- Rombos de función/decisión: `Función: Revisar si existe Lead o Contacto`
- Etiquetas de rama: `Registro Existe` / `Registro No Existe`
- Etiquetas de menú: `1. Info Nuevo Viaje`, `2. Hablar con Consultor`
- Bandas de fase: `ATRACCIÓN`, `CONVERSIÓN`, `EXPANSIÓN`

**Separación CRM / Plataforma:** cuando un nodo implica acción en Zoho CRM Y transferencia
en Woztell/Blip, estas secciones van SIEMPRE separadas — primero CRM, luego Plataforma.
Nunca mezclar instrucciones de ambas plataformas en un mismo bloque.

**Módulo CRM destino:** siempre declarar explícitamente el módulo (Lead / Contacto / ambos
con lógica) ANTES de listar los campos API. No enterrar esta información dentro de la lista.

---

## PASO 4 — CREACIÓN EN MIRO

Una vez el PO aprueba el contenido de todos los nodos, Claude crea en el board de Miro
un **documento de referencia** con el contenido completo del flujograma, organizado por fases
y listo para que el equipo lo traslade al canvas.

```python
# Herramienta a usar
Miro:doc_create(
  miro_url = "[URL del board del cliente]",
  content  = "[Documento Markdown con todos los nodos]",
  x = 15000,   # Posicionar fuera de los frames existentes
  y = 0
)
```

El documento se estructura así en Markdown:

```markdown
# FLUJOGRAMA BOT WHATSAPP — [CLIENTE]
Versión: v1 | Fecha: [fecha] | Plataforma: [Woztell/Blip]
Board: [URL del board]

---

## GLOSARIO VISUAL (referencia)
- Línea azul sólida → Flujo de proceso
- Línea azul punteada → Flujo de información
- Línea verde punteada (óvalo inicio) → Contacto con sistema externo
- Línea roja punteada (óvalo final) → Contacto con cliente
- Card azul #3812CF → Nodo de conversación / CRM
- Card amarilla #FFDC4A → Nodo legal / T&C
- Rombo amarillo #EBE31D → Función / Decisión

---

## FASE: ATRACCIÓN

### [1] Inicio / Bienvenida
[contenido de la card]

### [2] T&C / Política de Privacidad
[contenido de la card]

---

## FASE: CONVERSIÓN

### [3] Menú: ¿En qué podemos ayudarte?
[contenido de la card]

[...resto de nodos...]

---

## NOTAS GENERALES DEL PROYECTO
- Horario de atención: [horario]
- Teléfono de emergencias: [teléfono si aplica]
- Coste por conversación: sin coste hasta [N] conversaciones de usuario al día
- Campo único de identificación en CRM: [email / teléfono]
- Asignación automática a agentes: configurable en [plataforma]
- Asignación a carpetas de Inbox: requiere desarrollo custom ⚠️
```

---

## PASO 5 — CONFIRMACIÓN FINAL

```
✅ Flujograma generado — [CLIENTE]

Documento creado en Miro: [URL del doc]
Nodos desarrollados: [N]
Pendiente de trasladar al canvas visual usando el Glosario de Reinicia.

⚠️ Pendiente de validar con el cliente antes de implementar:
  - [Lista de decisiones marcadas con ⚠️ en las notas técnicas]
  - Campos API Name de Zoho CRM a confirmar con el equipo técnico
  - T&C: confirmar URL de política de privacidad

Próximo paso: una vez aprobado por el cliente, este flujograma es el
Ready to Backlog del producto "Chatbot V1 – [Plataforma] [CLIENTE]" en ClickUp.
```

---

## REFERENCIA — LEYENDA VISUAL DE REINICIA (extraída del board de Tee Travel)

| Elemento | Descripción |
|---|---|
| Línea azul sólida `#3812CF` | Flujo de proceso |
| Línea azul punteada `#3812CF` | Flujo de información |
| Línea verde punteada + óvalo inicio | Punto de contacto con sistema externo |
| Línea roja punteada + óvalo final | Punto de contacto con cliente |
| 💬 WhatsApp Personal | Icono canal |
| 💬 WhatsApp Corporativo | Icono canal |
| 📧 Correo electrónico | Icono canal |
| 📞 Llamada por teléfono | Icono canal |
| 📱 SMS | Icono canal |
| Fuente Noto Sans 30-40pt | Tipografía del board |
| Logo REINICIA (cabecera glosario) | Branding Reinicia |
| Logo CLIENTE (pie glosario) | Branding cliente |

**Colores de fase (bandas horizontales):**
- ATRACCIÓN → `#12CDD4` al 30% de opacidad
- CONVERSIÓN → `#FFF6B6` al 70% de opacidad
- EXPANSIÓN → `#C6DCFF` al 70% de opacidad

**Colores de card:**
- Card estándar (conversación / CRM) → `#3812CF`
- Card legal / T&C → `#FFDC4A`
- Card inglés (en flujos bilingües) → `#067429`
- Rombo función/decisión → `#EBE31D` con borde `#3812CF`
- Etiqueta de rama → `#F5F5F5` con borde `#3812CF`

---

## NOTAS IMPORTANTES

- **Proponer estructura antes de contenido:** validar arquitectura de nodos con el PO
  antes de desarrollar el texto de cada card.
- **Un nodo a la vez:** presentar cada card para revisión antes de pasar al siguiente.
- **Separación CRM / Plataforma siempre:** nunca mezclar instrucciones de Zoho CRM y
  Woztell/Blip en el mismo bloque de una card.
- **Módulo CRM explícito:** declarar Lead / Contacto / ambos antes de los campos API.
- **Máximo 3 opciones de menú** en WhatsApp estándar (máx. 20 caracteres por opción).
- **El flujograma aprobado es el Ready to Backlog** del producto Chatbot en ClickUp.
  Recordar al PO que lo enlace en la tarea correspondiente de ClickUp.
- **Referencia de proyecto:** Tee Travel, board https://miro.com/app/board/uXjVJhRL5MA=/
  Contiene v1 (bilingüe) y v2 (simplificado español) — v2 es la referencia preferida.

---

## BUENAS PRÁCTICAS DE DISEÑO CONVERSACIONAL — Instrucciones para Claude

### Cuándo activar esta sección
Al desarrollar el contenido de cada nodo (Paso 3), preguntar primero al PO:

"Al redactar el contenido de los nodos, ¿quieres que incluya propuestas de mejora
basadas en buenas prácticas de diseño conversacional de Woztell, Blip y Meta?
¿Hay alguna fuente específica que quieras que consulte?"

Si el PO dice que sí, aplicar las prácticas abajo al redactar cada card.

### Cómo presentarlas
Al final del contenido de cada nodo, añadir:

```
💡 PROPUESTA DE MEJORA
Idea: [descripción]
Fuente: [nombre y URL]
Dentro del alcance del flujograma actual: [Sí / No / Requiere revisión técnica]
```

Máximo 2 propuestas por nodo. No interrumpir el flujo principal del contenido.

---

### Principios de diseño conversacional validados

**Regla de oro (Woztell):** diseñar siempre para el usuario, no para la empresa.
Fuente: https://doc.woztell.com/docs/documentations/get-started/best-practices/

**1. Flujos cortos y cerrados**
Máximo 5 nodos por rama directa. Preguntas cerradas (con opciones) siempre mejor que
abiertas. Los usuarios abandonan si el flujo es largo o ambiguo.
Fuente: Woztell Best Practices.

**2. Quick replies vs. botones**
- Quick replies → acciones únicas (selección de menú, aceptación de T&C). Desaparecen
  tras usar, evitando clics repetidos en el historial.
- Botones → acciones permanentes o recurrentes (acceso a soporte, newsletter).
Fuente: Woztell Best Practices.

**3. Fail-safe en todos los nodos de decisión**
Todo nodo que espere una respuesta del usuario debe tener definido qué ocurre ante input
no esperado. El texto del mensaje de error debe ser específico: repetir la pregunta o
reconducir al menú. Estándar de Reinicia según metodología Tee Travel.
Fuente: Woztell Best Practices + metodología interna Reinicia.

**4. Recovery message (re-engagement)**
Si la conversación lleva 30 minutos inactiva, el bot puede reactivarla con un mensaje
de recuperación. Útil en flujos de captación donde el usuario puede distraerse.
Fuente: Woztell Best Practices.

**5. Tono y personalidad consistente**
Definir antes de redactar los textos: ¿el bot usa emojis? ¿tutea o usted? ¿tono formal
o cercano? Aplicarlo de forma uniforme en todos los nodos.
Fuente: Woztell Best Practices / Woztell blog chatbot building.

**6. WhatsApp Flows para recogida de datos**
Para nodos de recogida de múltiples campos (nombre, email, fecha…), considerar
WhatsApp Flows (formulario in-app) en lugar de preguntas conversacionales una a una.
Reduce el abandono y mejora calidad de los datos.
Fuente: notas técnicas Tee Travel v2 / Meta for Developers.
⚠️ Requiere configuración adicional — indicarlo como propuesta fuera del alcance estándar.

**7. Menú persistente (persistent menu)**
Botón siempre visible que da acceso directo a soporte humano, independientemente del
punto del flujo en que esté el usuario. Fundamental en flujos de atención al cliente.
Fuente: Woztell Best Practices.

**8. Lógica horaria siempre documentada**
Todo nodo de cierre/transferencia a agente debe tener documentadas las tres variantes:
laborable + agente activo / laborable + sin agente activo / no laborable.
Omitir una variante provoca comportamientos inesperados en producción.
Fuente: metodología interna Reinicia (aprendizaje Tee Travel).

**9. Privacidad desde el primer nodo**
El nodo de T&C/política de privacidad debe ir antes de cualquier recogida de datos.
No es opcional — es un requisito legal (RGPD) y de las políticas de Meta.
Fuente: regulación RGPD + Meta WhatsApp Business Policy.

**10. Opt-in explícito para comunicaciones salientes**
Si el flujograma incluye envíos de plantillas (mensajes iniciados por la empresa),
documentar el mecanismo de opt-in. Sin él, riesgo de bloqueo de la cuenta WABA.
Fuente: Meta WhatsApp Business Policy / WhatsApp Business Best Practices 2025.

---

### Fuentes de referencia para búsqueda activa
Antes de redactar propuestas de mejora para un nodo específico, Claude puede buscar
con web_search si hay documentación más actualizada:

- Woztell índice general: https://doc.woztell.com/
- Woztell best practices: https://doc.woztell.com/docs/documentations/get-started/best-practices/
- Woztell WhatsApp docs: https://doc.woztell.com/docs/documentations/whatsapp/wa-overview/
- Blip docs técnicos (Builder, SDK, tipos de contenido): https://docs.blip.ai/#introduction
- Blip docs ES (precios, privacidad, seguridad): https://www.blip.ai/es/docs/
- Blip blog ES: https://www.blip.ai/blog/es/
- Eazybe Help Docs: https://eazybehelpdesk-meb4m.desk.notaku.site/
- Meta WhatsApp Business: https://business.whatsapp.com/
- Meta for Developers (WhatsApp): https://developers.facebook.com/docs/whatsapp
