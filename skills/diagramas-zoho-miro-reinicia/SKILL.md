---
name: diagramas-zoho-miro-reinicia
description: >
  Skill para crear flujogramas de procesos de negocio y modelos entidad-relación (ERD)
  en Miro para proyectos Zoho CRM de Reinicia. Cubre el flujo completo desde la elicitación
  con el PO hasta la creación de los diagramas en el board de Miro del cliente, incluyendo
  recomendaciones de mejora de procesos y claridad visual.
  Actívala siempre que el PO pida crear o documentar un flujograma de procesos de negocio
  en Miro, diseñar el modelo de datos / entidad-relación de Zoho CRM en Miro, preparar los
  entregables de consultoría de procesos o modelo de datos para un cliente, o revisar y
  mejorar un board de Miro existente de procesos o ERD.
  No usar para flujogramas conversacionales de WhatsApp/WABA (skill flujograma-waba-miro-reinicia)
  ni para crear productos en ClickUp (skill productos-digitales-zoho-clickup-reinicia).
---

# SKILL: Diagramas Zoho en Miro — Reinicia

> **Versión vigente: v1.0 — 21/06/2026** · ver changelog al final (`## Versiones`)
## Flujogramas de Procesos de Negocio y Modelo Entidad-Relación

## Propósito
Crear y documentar en Miro los dos entregables visuales clave de la consultoría Zoho CRM de Reinicia:
1. **Flujograma de Procesos de Negocio**: refleja cómo fluyen los procesos del cliente (ventas, marketing, administración, posventa) y cómo se integran con Zoho CRM y otros sistemas.
2. **Modelo Entidad-Relación (ERD)**: refleja cómo se estructura la información en Zoho CRM — módulos, campos clave, relaciones entre entidades y tipos de campo.

Ambos documentos están íntimamente relacionados: el ERD debe mostrar cómo se almacena y relaciona la información que fluye por todos los procesos del flujograma. Se trabajan en el mismo proyecto y fase (Consultoría), y se entregan al cliente de forma conjunta.

**Proyectos de referencia:**
- Gonher (flujograma): https://miro.com/app/board/uXjVImh4s1c=/
- INEFSO (flujograma): https://miro.com/app/board/uXjVJyIJOw0=/
- INEFSO (ERD): https://miro.com/app/board/uXjVGcm6V64=/
- Mazarea (flujograma): https://miro.com/app/board/uXjVGbZ0HYQ=/

---

## PASO 1 — ELICITACIÓN

Claude hace las preguntas de forma **secuencial**.

### Pregunta 1: Cliente y tipo de diagrama
"¿Para qué cliente es el diagrama? ¿Qué quieres crear o actualizar: el flujograma de procesos, el modelo entidad-relación (ERD), o los dos?"

→ Determina el flujo de trabajo. Si son los dos, se trabaja primero el flujograma y luego el ERD, ya que el ERD se construye sobre la base de lo que se ha documentado en los procesos.

### Pregunta 2: Board de Miro
"¿Cuál es la URL del board de Miro del cliente donde creo el diagrama? Si no tienes board todavía, me lo indicas cuando lo tengas y mientras trabajo el contenido."

### Pregunta 3: Fuentes de información disponibles
"¿Qué información tengo disponible para entender los procesos? Por ejemplo: Sprint Cero, actas de entrevistas, Listado de Requerimientos, conclusiones de entrevistas, o cualquier otro documento."

→ Claude accede a las fuentes disponibles en Workdrive antes de continuar.

### Pregunta 4 (solo para flujograma): Departamentos y fases
"¿Cuáles son los departamentos o áreas de la empresa que intervienen en los procesos? ¿Y cuáles son las fases del customer journey (por ejemplo: Atracción / Conversión / Expansión)?"

→ Determina los swim lanes y la estructura horizontal del flujograma.

### Pregunta 5 (solo para flujograma): Procesos a documentar
"¿Qué procesos concretos hay que incluir? Por ejemplo: captación de leads, cualificación, visitas comerciales, gestión de pedidos, posventa, etc."

### Pregunta 6 (solo para ERD): Módulos de Zoho CRM
"¿Cuáles son los módulos principales de Zoho CRM que se van a usar? Por ejemplo: Posibles Clientes, Contactos, Cuentas, Oportunidades, Pedidos, Productos, Campañas, etc."

→ Determina las entidades del ERD.

---

## PASO 2 — ANÁLISIS Y RECOMENDACIONES PREVIAS

Antes de crear nada en Miro, Claude analiza la información disponible y presenta al PO:

### 2.1 Estructura propuesta
Una propuesta de arquitectura del diagrama para validación antes de crearlo:

**Para el flujograma:**
```
📐 PROPUESTA DE FLUJOGRAMA — [CLIENTE]

Swim lanes (departamentos):
  - [Departamento 1]
  - [Departamento 2]
  - ...

Fases horizontales (customer journey):
  - [Fase 1: Atracción]
  - [Fase 2: Conversión]
  - [Fase 3: Expansión]

Procesos principales por fase:
  Atracción: [lista de actividades]
  Conversión: [lista de actividades]
  Expansión: [lista de actividades]

Sistemas integrados: [Zoho CRM, BC, WhatsApp, etc.]
```

**Para el ERD:**
```
📐 PROPUESTA DE ERD — [CLIENTE]

Entidades principales (módulos Zoho CRM):
  - [Módulo 1] → campos clave: [...]
  - [Módulo 2] → campos clave: [...]
  - ...

Relaciones principales:
  - [Módulo A] → [Módulo B]: [tipo de relación]
  - ...
```

### 2.2 Recomendaciones de mejora de procesos
Claude analiza los procesos documentados e identifica proactivamente oportunidades de mejora, tanto para la **claridad del diagrama** como para los **procesos del cliente**:

**Mejoras de claridad del diagrama:**
- Actividades que conviene desagregar en pasos más pequeños
- Decisiones que faltan o están implícitas
- Integraciones con sistemas que no están visualmente representadas
- Swim lanes que se solapan o cuya responsabilidad no es clara

**Mejoras de proceso para el cliente:**
- Cuellos de botella detectados (pasos manuales que se pueden automatizar)
- Falta de trazabilidad (momentos donde se pierde información entre sistemas)
- Inconsistencias (mismo proceso documentado de dos formas distintas)
- Oportunidades de automatización via Zoho CRM (blueprints, workflows, funciones)
- SLAs ausentes en pasos críticos (aprobaciones, validaciones, respuestas)

Estas recomendaciones se presentan siempre al PO antes de crear el diagrama, organizadas por prioridad (alta / media / baja impacto) y con una propuesta concreta de cómo reflejarlas en el diagrama.

---

## PASO 3 — ESTRUCTURA ESTÁNDAR DE CARDS

### 3.1 Card de actividad (elemento rectangular)

Cada actividad del flujograma debe contener:

```
┌─────────────────────────────────────┐
│ [EMOJI SISTEMA] TÍTULO DE ACTIVIDAD │
│─────────────────────────────────────│
│ Responsable: [Departamento/Rol]     │
│ Sistema: [Zoho CRM / SAP / WA / ..] │
│ Automatización: [Manual / Semi / Auto]│
│ SLA: [si aplica — p.ej. 24h]        │
└─────────────────────────────────────┘
```

**Emojis de sistema estándar (coherente con otros boards Reinicia):**
- 🟣 Zoho CRM
- 🔵 Business Central / SAP / ERP
- 💬 WhatsApp / Woztell / Blip
- 📧 Email / Mailchimp / Zoho Campaigns
- 📋 Zoho Forms
- 📊 Zoho Analytics
- ✍️ Zoho Sign
- 🌐 Web / Zoho SalesIQ
- 🔁 Zoho Flow (automatización)
- 👤 Acción manual sin sistema

**Nivel de automatización:**
- 🔴 Manual: la persona lo hace sin ayuda del sistema
- 🟡 Semi-automático: el sistema ayuda pero requiere intervención humana
- 🟢 Automático: el sistema lo ejecuta sin intervención

### 3.2 Card de decisión (elemento rombo)

```
┌──────────────────────────────┐
│ ◆ PREGUNTA DE DECISIÓN       │
│ Sí → [destino]               │
│ No → [destino]               │
└──────────────────────────────┘
```

### 3.3 Card de integración entre sistemas

Cuando un proceso implica un traspaso de datos entre dos sistemas:

```
┌──────────────────────────────────────┐
│ 🔄 INTEGRACIÓN: [Sistema A → B]      │
│ Datos: [qué información se traspasa] │
│ Dirección: [bidireccional / unidirec.]│
│ Trigger: [qué lo dispara]            │
└──────────────────────────────────────┘
```

### 3.4 Card de entidad ERD

```
┌────────────────────────────────────────┐
│ 📦 NOMBRE MÓDULO ZOHO CRM              │
│────────────────────────────────────────│
│ PK: [Campo clave primario]             │
│ [Campo 1]: [Tipo] — [Descripción]      │
│ [Campo 2]: [Tipo] — [Descripción]      │
│ FK: [Nombre relación] → [Módulo]       │
│────────────────────────────────────────│
│ Nota: [si aplica]                      │
└────────────────────────────────────────┘
```

**Tipos de campo estándar en Zoho CRM (usar siempre en español):**
- Línea / Texto largo
- Número / Decimal / Moneda / Porcentaje
- Fecha / Fecha y hora
- Lista de selección / Lista de selección múltiple
- Casilla de verificación
- Lookup (relación a otro módulo) — indicar módulo destino
- Lookup múltiple
- Fórmula
- Usuarios (Owner/Propietario)
- URL / Email / Teléfono
- Zoho Sign (integración firma digital)

**Tipos de relación:**
- 1:1 — uno a uno
- 1:N — uno a muchos
- N:N — muchos a muchos (indicar si hay módulo intermedio)
- Se convierte en (conversión de módulo, ej. Posible Cliente → Contacto)

---

## PASO 4 — CREACIÓN EN MIRO

### 4.1 Flujograma de procesos

Claude usa `Miro:diagram_create` con `diagram_type: "flowchart"` para crear el diagrama base, siguiendo la estructura de swim lanes y fases validada en el Paso 2.

**Convenciones visuales (coherencia con boards Reinicia existentes):**

| Elemento | Color sugerido | Uso |
|---|---|---|
| Swim lane encabezado | #1A1A2E (azul muy oscuro) | Fondo del nombre del departamento |
| Actividad Atracción | #d14351 (rojo) | Actividades de captación/marketing |
| Actividad Conversión | #ebe31d (amarillo) | Actividades comerciales y ventas |
| Actividad Expansión | #305bab (azul) | Actividades posventa y fidelización |
| Automatización | #067429 (verde) | Actividades 100% automáticas |
| Decisión | #f5a623 (naranja) | Nodos de decisión |
| Integración sistemas | #7b68ee (morado) | Cards de traspaso entre sistemas |
| Línea flujo principal | Sólida negra | Flujo principal del proceso |
| Línea flujo condicional | Discontinua gris | Flujo alternativo o de excepción |
| Línea información | Punteada azul | Traspaso de datos entre sistemas |

**Leyenda mínima obligatoria** (incluir siempre en el board):
- Tipos de flecha (sólida / discontinua / punteada)
- Colores de actividad por fase
- Emojis de sistema
- Escala de automatización (🔴 Manual / 🟡 Semi / 🟢 Auto)

### 4.2 Modelo Entidad-Relación

Claude usa `Miro:diagram_create` con `diagram_type: "entity_relationship"` para crear el ERD.

**Principios de diseño del ERD:**
- Cada módulo de Zoho CRM = una entidad
- Campos estándar de Zoho (Propietario, Creado por, etc.) no se incluyen salvo que sean relevantes para el negocio
- Las relaciones deben incluir el nombre de la relación en el modelo de datos de Zoho (ej. "Está asociado", "Se convierte en", "Pertenece a")
- El ERD debe ser coherente con el flujograma: cada entidad debe aparecer en al menos un proceso del flujograma

**Conexión explícita flujograma ↔ ERD:**
Claude debe indicar en los comentarios del board (o en una nota introductoria) qué módulos del ERD intervienen en cada fase del flujograma, para que el cliente entienda la relación entre ambos documentos.

---

## PASO 5 — DOCUMENTO DE REFERENCIA EN MIRO

Además del diagrama visual, Claude crea un **documento de referencia** en el mismo board usando `Miro:doc_create` con el siguiente contenido:

```markdown
# Flujograma / ERD [CLIENTE] — Documento de Referencia

## Versión: [v1.0] — Fecha: [fecha]
## Estado: Borrador / Preliminar / Definitivo

---

## Glosario de términos
[Lista de términos específicos del sector/cliente con su definición]

## Leyenda visual
[Descripción de colores, flechas, emojis y elementos visuales usados]

## Decisiones de diseño
[Por qué se ha estructurado así — útil para iteraciones futuras]

## Recomendaciones de mejora de proceso
[Lista con prioridad: Alta / Media / Baja]
[Para cada una: descripción del problema, propuesta de mejora, impacto esperado]

## Pendientes y preguntas abiertas
[Lo que falta por confirmar con el cliente]

## Historial de versiones
[v1.0 — fecha — descripción de cambios]
```

---

## PASO 6 — PRESENTACIÓN AL PO Y AL CLIENTE

Antes de dar el diagrama por válido, Claude presenta al PO un resumen con:

```
✅ DIAGRAMA CREADO EN MIRO — [CLIENTE]

URL del board: [enlace]

Elementos creados:
  - [N] actividades documentadas
  - [N] decisiones
  - [N] integraciones entre sistemas
  - [N] entidades en el ERD (si aplica)

Recomendaciones de mejora identificadas:
  🔴 Alta prioridad: [N]
  🟡 Media prioridad: [N]
  🟢 Baja prioridad: [N]
  → Ver detalle en el documento de referencia del board

Pendientes antes de presentar al cliente:
  - [Lista de preguntas abiertas o elementos a validar con el PO]
  - Revisar leyenda visual
  - Confirmar nombres de departamentos con el cliente
```

---

## NOTAS IMPORTANTES

- **Flujograma primero, ERD después:** el ERD se construye sobre la base del flujograma. Si se hace el ERD sin tener claro el flujograma, es probable que falten entidades o relaciones relevantes.
- **Versiones del flujograma:** los boards de referencia (Gonher, INEFSO, Mazarea) muestran versiones evolutivas (V3, V4, V5). Cada entrega al cliente debe tener número de versión claro. Las versiones preliminares se marcan como "BORRADOR" o "PRELIMINAR" en el título del frame.
- **Coherencia con el modelo de datos de Zoho Sheet:** el ERD debe ser consistente con el Modelo de Datos que se documenta en Zoho Sheet durante la consultoría. Son dos representaciones del mismo modelo: una visual (ERD en Miro) y una tabular (Zoho Sheet).
- **Recomendaciones de proceso:** siempre identificar y proponer mejoras, tanto de claridad visual como de proceso. El objetivo no es solo documentar lo que el cliente ya hace, sino ayudarle a mejorar. Priorizar: automatizaciones en Zoho CRM, eliminación de pasos manuales repetitivos, mejora de trazabilidad, y reducción de fricciones entre departamentos.
- **Leyenda visual obligatoria:** todo board debe tener una leyenda. Sin leyenda, el diagrama no es autónomo ni entregable al cliente.
- **Nomenclatura de frames:** `[CLIENTE] V[N] — [Estado]` — por ejemplo: `CARRITECH V1 — BORRADOR`
- **Idioma:** los diagramas se crean en el idioma del cliente (castellano para clientes españoles / inglés para clientes internacionales como Carritech).

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0 | 21/06/2026 | Néstor + Claude | Estado previo sin versionar, tabulado por primera vez al incorporar el estándar de versionado de Reinicia (21/06/2026). Creación de flujogramas de procesos de negocio y modelos entidad-relación (ERD) en Miro para proyectos Zoho CRM. |
