---
name: productos-digitales-waba-clickup-reinicia
description: >
  Skill para crear productos digitales WABA / WhatsApp Business en ClickUp de forma asistida
  para clientes de Reinicia. Cubre el flujo completo: elicitación con el PO, búsqueda en
  Workdrive y ClickUp, propuesta de estructura de backlog y creación de tareas con subtareas y
  campos personalizados. Actívala siempre que el PO pida crear productos en ClickUp para
  proyectos de WhatsApp Business, WABA, Woztell, Blip, Eazybe, chatbot conversacional,
  bot de WhatsApp, campañas masivas WA, automatizaciones WA desde Zoho CRM, ecommerce en
  WhatsApp o catálogo Meta. También se activa para organizar el backlog WABA de un cliente,
  crear un SPIKE de WhatsApp o gestionar soporte de flujos conversacionales. No usar para
  proyectos solo de Zoho CRM (skill Zoho) ni solo web (skill web).
---

# SKILL: Crear Productos Digitales WABA/WhatsApp en ClickUp — Reinicia

> **Versión vigente: v1.0 — 21/06/2026** · ver changelog al final (`## Versiones`)

## Descripción
Esta skill permite a los Product Owners de Reinicia crear tareas de producto digital WABA
(WhatsApp Business API) en ClickUp de forma asistida. Claude busca la información del proyecto en
Workdrive y ClickUp, propone primero una **estructura completa de Épicas / PBIs / Productos** para
validación del PO, y luego desarrolla el detalle de cada producto uno a uno antes de crearlo en
ClickUp.

Las herramientas WABA que usa Reinicia actualmente son:
- **Woztell** — plataforma principal WABA (chatbots, flujos, integración CRM)
- **Blip.ai** — plataforma alternativa de IA conversacional avanzada
- **Eazybe** — potenciador de WhatsApp Business Individual vía WhatsApp Web + conector Zoho CRM

---

## PASO 1 — ELICITACIÓN: Preguntas una a una al PO

Claude hace las preguntas de forma **secuencial**. No lanzar todas de golpe — las respuestas de
unas condicionan las siguientes.

### Pregunta 1: Cliente, plataforma y estado del proyecto
"¿Para qué cliente es? ¿Qué plataforma WABA vais a usar (Woztell, Blip, Eazybe, otra)?
¿El proyecto es nuevo o ya está en curso?"

→ La plataforma condiciona las subtareas estándar y los criterios de aceptación (ver Paso 4).

### Pregunta 2: Tipo de trabajo
"¿Qué tipo de trabajo WABA quieres organizar en ClickUp? Por ejemplo:
alta y configuración de cuenta, diseño de flujos/chatbot, integración con Zoho CRM,
conector con LLM (OpenAI, Claude, Gemini…), campañas masivas de WA, automatizaciones
disparadas desde Zoho CRM, ecommerce/catálogo en WA, formación al equipo del cliente,
soporte y mantenimiento de flujos, SPIKE de investigación…
¿Hay algo de todo esto o es una combinación?"

→ Determina qué tipos de producto proponer en el Paso 3.

### Pregunta 3: Carpeta del proyecto en Workdrive
"¿Cuál es el ID de la carpeta raíz del proyecto en Proyectos Activos de Workdrive?
Si no lo tienes a mano, puedo buscarlo yo con el nombre del cliente."

→ Claude busca con `ZohoWorkdrive_searchTeamFoldersFiles` si el PO no lo sabe.

### Pregunta 4: Lista en ClickUp
"¿Conoces el ID de la lista `General [CLIENTE]` en ClickUp? Si no, lo busco yo."

→ Claude busca con `clickup_search` o `clickup_get_list`.

### Pregunta 5: PO de Reinicia
"¿Quién es el Product Owner de Reinicia para este proyecto?"
(Opciones: ALVARO, NESTOR, ELENA, BORJA, ALEJANDRO, PATRICIA, MARTA, PABLO, OSCAR)

### Pregunta 6: Equipo asignado
"¿Qué personas del equipo de Reinicia van a trabajar en estos productos?
Cuéntame quién se encarga de qué, o lo dejamos para cuando proponga la estructura."

### Pregunta 7: Amigos Reinicia
"¿Hay algún Amigo Reinicia (colaborador externo) que vaya a participar?
¿En qué productos en concreto?"

### Pregunta 8: Buenas prácticas
"Al desarrollar cada producto, ¿quieres que te proponga ideas de mejora y buenas prácticas
basadas en fuentes oficiales de WhatsApp Business, Woztell y Blip? Si es así, puedes también
aportarme fuentes específicas que quieras que consulte."

→ Si el PO dice que sí, Claude activa la sección de buenas prácticas al desarrollar cada
  producto en el Paso 4. Si no, la omite.

---

## PASO 2 — BÚSQUEDA DE INFORMACIÓN

### Estructura estándar de carpetas — Proyectos Activos
```
[CLIENTE] (carpeta raíz)
  ├── 00. Información
  │     ├── Comercial          ← PROPUESTA COMERCIAL aquí
  │     ├── Empresa            ← SPRINT CERO aquí (PDF) + info cliente
  │     ├── Credenciales Cliente
  │     └── Recursos gráficos
  ├── 01. Seguimiento          ← ACTAS aquí
  ├── WhatsApp / WABA          ← docs consultoría WABA del proyecto
  └── [Otras carpetas según servicios]
```

### Orden de búsqueda según tipo de proyecto

**Proyecto NUEVO** (prioridad decreciente):
1. `00. Información > Empresa` → Sprint Cero (PDF). **Prevalece** si existe.
2. `00. Información > Comercial` → Propuesta Comercial aceptada (PDF).
3. `01. Seguimiento` → actas de arranque y fase comercial.
4. ClickUp → buscar proyectos **similares** de WABA/WhatsApp en otros clientes para reutilizar estructura de productos. Usar `clickup_search` con keywords: "Woztell", "Blip", "WhatsApp", "chatbot", "WABA", "flujograma bot". Referencia validada: **Tee Travel** (lista `901214586754`).
5. Web del cliente + LinkedIn de personas clave.

**Proyecto EN CURSO** (prioridad decreciente):
1. Sprint Cero > Propuesta Comercial > Actas recientes.
2. ClickUp → tareas existentes en `General [CLIENTE]` para ver qué ya está hecho.
3. ClickUp → proyectos similares en otros clientes para reutilizar experiencia.
4. Web del cliente + LinkedIn.

### Herramientas de búsqueda en Workdrive
- `ZohoWorkdrive_searchTeamFoldersFiles` — buscar carpeta raíz por nombre de cliente
- `ZohoWorkdrive_getFolderFiles` — listar contenido de subcarpetas
- `ZohoWorkdrive_downloadWorkDriveFile` — leer PDFs (Propuesta, Sprint Cero)

### Referencia Miro
Si en el proyecto existe un flujograma conversacional en Miro (como en Tee Travel), acceder con
`Miro:context_get` o `Miro:context_explore` para entender la lógica de flujos ya diseñada.
Esto es especialmente relevante si hay un SPIKE de flujograma previo al chatbot.

El flujograma en Miro se genera con la skill **flujograma-waba-miro-reinicia**, que produce el
contenido de cada nodo siguiendo la plantilla oficial de cards de Reinicia.
Referencia: Tee Travel → https://miro.com/app/board/uXjVJhRL5MA=/

El documento Miro aprobado por el cliente es el **Ready to Backlog obligatorio** del producto
Chatbot V1 en ClickUp. Incluirlo siempre en la descripción de la tarea de implementación.

---

## PASO 3 — PROPUESTA DE ESTRUCTURA: ÉPICAS / PBIs / PRODUCTOS

Antes de entrar al detalle, Claude presenta la **arquitectura del backlog** para validación del PO.
No crear nada hasta que el PO apruebe.

```
📐 PROPUESTA DE ESTRUCTURA DE BACKLOG — [CLIENTE]

Basado en [fuentes consultadas], propongo organizar el trabajo así:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ÉPICA: PLANIFICACIÓN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  PBI de primer nivel: Setup inicial

    → [SPIKE] Selección de plataforma WABA [CLIENTE]   ← solo si hay duda entre Woztell/Blip/Eazybe
      Historia de usuario: Como [PO CLIENTE], QUIERO evaluar las plataformas WABA disponibles,
      PARA elegir la que mejor se adapta a nuestras necesidades y presupuesto.

    → Alta y configuración WABA [CLIENTE]
      Historia de usuario: Como [PO CLIENTE], QUIERO dar de alta la cuenta WABA en [plataforma],
      PARA poder operar WhatsApp Business de forma profesional.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ÉPICA: 02. INVESTIGACIÓN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  PBI de primer nivel: Diseño conversacional

    → [SPIKE] Flujograma Bot WhatsApp [CLIENTE]
      Historia de usuario: Como [PO CLIENTE], QUIERO diseñar y aprobar el flujograma
      de conversaciones del bot, PARA garantizar una experiencia coherente antes de implementar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ÉPICA: 05. ADOPTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  PBI de primer nivel: Implementación

    → Chatbot V1 – [Plataforma] [CLIENTE]
      Historia de usuario: Como [PO CLIENTE], QUIERO implementar el chatbot según el flujograma
      aprobado, PARA atender a prospectos y clientes de forma automática por WhatsApp.

    → Integración WABA ↔ Zoho CRM [CLIENTE]   ← si aplica
    → Conector LLM – [OpenAI/Gemini/Claude] [CLIENTE]   ← si aplica
    → Campañas masivas WhatsApp [CLIENTE]   ← si aplica
    → Automatizaciones WA desde Zoho CRM [CLIENTE]   ← si aplica
    → Ecommerce / Catálogo WhatsApp [CLIENTE]   ← si aplica

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ÉPICA: FORMACIÓN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    → Formación [Plataforma] [CLIENTE]

¿Estás de acuerdo con esta estructura? ¿Añades, quitas o ajustas algo?
Cuando confirmes, desarrollo el detalle de cada producto uno a uno.
```

### Secuencia canónica de un proyecto WABA en Reinicia
```
PLANIFICACIÓN
  └─ [SPIKE] Selección de plataforma (si no está decidida)
  └─ Alta y configuración de cuenta WABA

INVESTIGACIÓN / CONSULTORÍA
  └─ [SPIKE] Flujograma conversacional (en Miro — obligatorio antes de implementar)
  └─ [SPIKE] Conector LLM (si se va a usar IA generativa)

IMPLEMENTACIÓN
  └─ Chatbot V1 (funcionalidades básicas, sin integraciones complejas)
  └─ Integración WABA ↔ Zoho CRM (si aplica)
  └─ Conector LLM implementado (si aplica)
  └─ Campañas masivas / Automatizaciones (si aplica)
  └─ Ecommerce / Catálogo (si aplica)
  └─ Chatbot V2+ (iteraciones con nuevas funcionalidades)

FORMACIÓN
  └─ Formación [Plataforma] al equipo del cliente

SOPORTE (si hay contrato de mantenimiento)
  └─ Soporte y mantenimiento de flujos
```

**Notas:**
- El **flujograma en Miro es condición obligatoria** (Ready to Backlog) antes de cualquier producto de implementación de chatbot. Nunca crear el chatbot sin el flujograma aprobado.
- Los **conectores con LLM** siempre van precedidos de un SPIKE.
- Separar siempre el chatbot V1 (básico) de versiones posteriores con integraciones. Tamaño máximo: 1-2 sprints por producto.
- Para **Eazybe** (WA Business Individual + WhatsApp Web): no requiere cuenta WABA oficial, pero sí configuración de extensión + conector Zoho CRM. Tratar como producto independiente.

---

## PASO 4 — DETALLE DE CADA PRODUCTO (uno a uno)

Aprobada la estructura, Claude desarrolla el contenido de cada producto **de uno en uno**,
presentándolo para revisión antes de pasar al siguiente.

### Plantilla de producto

```
📋 PRODUCTO [N de M]: [NOMBRE DEL PRODUCTO] [CLIENTE]

NOMBRE TAREA: [Nombre del producto] [CLIENTE]

DESCRIPCIÓN:
  Historia de usuario:
  Como [NOMBRE PO CLIENTE], QUIERO [qué], PARA [para qué].

  Descripción:
  Web: [URL del cliente]
  Objetivo Cliente: [objetivo del proyecto WABA]
  Público objetivo: [si aplica]

  Ready to Backlog:
  - [prerrequisitos específicos de este tipo de producto — ver tabla abajo]

  Contexto:
  [Información clave del cliente extraída de Sprint Cero / Propuesta / actas]

  Importante: se trabajará con las funcionalidades estándar de [plataforma] y Zoho CRM
  a no ser que se haya especificado lo contrario. [Indicar si hay personalizaciones
  via API, Zoho Flow o LLM previstas.]

  Accesos [Plataforma]: [pendiente alta / disponibles en Vault]

  Entregables Interno Reinicia:
  - Plantilla Pruebas y Documentación – Reinicia

  Entregables a Cliente:
  - [Entregable principal: bot/flujo/integración según Flujograma aprobado]
  - [Otros entregables: documentación de uso, manual de plantillas, etc.]

  Documentación de referencia:
  - Propuesta WABA [CLIENTE]: [enlace Workdrive versión pública]
  - Flujograma conversacional: [enlace Miro o Workdrive]
  - [actas relevantes con enlace]

SUBTAREAS (adaptar según tipo de producto):
  Ver tabla de subtareas estándar por tipo de producto abajo.

CRITERIOS DE ACEPTACIÓN (para copiar manualmente en ClickUp):
  Formato: una línea por criterio con la categoría entre corchetes como prefijo.
  Permite copiar y pegar directo al checklist de ClickUp, donde cada línea se
  convierte en un ítem y la categoría queda visible en cada uno.

  Checklist: CRITERIOS DE ACEPTACIÓN
  Ver tabla de criterios estándar por tipo de producto abajo.

CAMPOS PERSONALIZADOS:
  PROYECTO: [CLIENTE]
  TIPO DE PRODUCTO: WHATSAPP
  PO: [Nombre PO]
  ÉPICA: [acordada en Paso 3]
  PBIs PRIMER NIVEL: [acordado en Paso 3]
  REFINADO: No (por defecto)
  AMIGOS REINICIA: [nombre si aplica para este producto concreto]
  Tiempo estimado: [si el PO lo indica]
  ORDEN: ⚠️ pendiente — el PO lo asigna en el Sprint Planning

💡 PROPUESTAS DE MEJORA (solo si el PO ha confirmado que quiere recibirlas):
  Ver instrucciones en sección "Buenas prácticas WABA" al final de esta skill.

¿Apruebas este producto tal como está? ¿Modificas algo antes de crearlo?
```

---

### Subtareas estándar por tipo de producto

| Tipo de producto | Subtareas estándar |
|---|---|
| **[SPIKE] Selección de plataforma** | Investigación de opciones (Woztell / Blip / Eazybe) · Comparativa de funcionalidades y costes · Recomendación documentada · Validación Reinicia · Validación Cliente |
| **Alta y configuración WABA** | Registro y verificación de número de teléfono en Meta · Alta en [Woztell/Blip] · Configurar Reinicia como Partner · Configuración de perfil de empresa WhatsApp · Configuración de respuestas automáticas fuera de horario · Accesos a Vault · Validación Reinicia · Validación Cliente |
| **[SPIKE] Flujograma Bot** | Definición de objetivos y casos de uso · Identificación de intenciones del usuario · Generación del contenido de cada nodo con la skill **flujograma-waba-miro-reinicia** · Diseño del flujograma en Miro (canvas visual con Glosario Reinicia) · Revisión con el equipo técnico · Validación Reinicia · Validación Cliente + aprobación del flujograma |
| **Chatbot V1 (sin integraciones)** | Revisar chatbot previo si existe · Configuración de cuenta en [plataforma] · Crear árbol conversacional según flujograma · Configurar respuestas automáticas · Crear plantillas de comunicación personalizadas · Pruebas y tests · Demo al cliente · Validación Reinicia · Validación Cliente |
| **Chatbot V2+ (iteraciones)** | Revisar feedback V1 · [Nuevas funcionalidades acordadas] · Pruebas y tests · Demo al cliente · Validación Reinicia · Validación Cliente |
| **Integración WABA ↔ Zoho CRM** | Mapeo de campos CRM ↔ conversación WA · Configuración del conector [Woztell/Blip] – Zoho CRM · Registro de conversaciones en módulo CRM · Asociación de conversaciones a expedientes/contactos · Implementar medición · Pruebas y tests · Validación Reinicia · Validación Cliente |
| **Conector LLM** | [SPIKE previo obligatorio] · Selección y configuración del LLM (OpenAI/Claude/Gemini) · Definición de contexto y prompts del sistema · Integración LLM ↔ [plataforma WABA] · Pruebas de conversación y alucinaciones · Control de privacidad y datos · Validación Reinicia · Validación Cliente |
| **Campañas masivas WA** | Definición de segmentos de envío · Creación de plantillas aprobadas por Meta · Configuración del envío masivo · Prueba piloto (muestra reducida) · Envío y monitorización · Análisis de resultados · Validación Reinicia · Validación Cliente |
| **Automatizaciones WA desde Zoho CRM** | Mapeo de triggers en CRM → WA · Configuración de Zoho Flow / Deluge · Creación de plantillas de mensaje WA · Pruebas end-to-end · Validación Reinicia · Validación Cliente |
| **Ecommerce / Catálogo WhatsApp** | Configuración del catálogo en Meta Business · Conexión catálogo ↔ cuenta WABA · Carga y estructuración de productos/servicios · Integración con CRM o ecommerce si aplica · Pruebas de visualización y compra · Validación Reinicia · Validación Cliente |
| **Formación [Plataforma]** | Preparación de materiales y guía de uso · Sesión formativa (~1,5h) · Documento de buenas prácticas · Validación Reinicia · Validación Cliente |

---

### Criterios de aceptación estándar por tipo de producto

Formato: una línea por criterio con la categoría entre corchetes como prefijo. Permite copiar y pegar directo al checklist de ClickUp.

| Tipo de producto | Criterios de aceptación |
|---|---|
| **Alta y configuración WABA** | [Técnicos] Número verificado y activo en Meta <br> [Técnicos] Cuenta creada en [plataforma] <br> [Técnicos] Reinicia configurado como Partner <br> [Técnicos] Accesos disponibles en Zoho Vault <br> [Funcionales] Perfil de empresa WA completo <br> [Funcionales] Respuesta automática fuera de horario activa |
| **[SPIKE] Flujograma** | [Funcionales] Flujograma completo en Miro <br> [Funcionales] Todos los flujos principales cubiertos (bienvenida, consulta, derivación a agente, fuera de horario) <br> [De proceso] Flujograma aprobado por el cliente |
| **Chatbot V1** | [Técnicos] Woztell/Blip contratado y Reinicia como Partner <br> [Técnicos] Chat integrado y operativo en [plataforma] <br> [Funcionales] Flujograma aprobado implementado en [plataforma] <br> [Funcionales] Respuesta automática fuera de horario activa <br> [Funcionales] Plantillas de comunicación creadas <br> [De proceso] Pruebas superadas y documentadas en Zoho Sheet <br> [De proceso] Validación Reinicia <br> [De proceso] Validación Cliente |
| **Integración WABA ↔ Zoho CRM** | [Técnicos] Campos mapeados correctamente entre WA y CRM <br> [Técnicos] Medición implementada (como en Breezom si aplica) <br> [Funcionales] Conversaciones registradas en CRM <br> [Funcionales] Asociación a contactos/expedientes correcta <br> [De proceso] Pruebas superadas y documentadas en Zoho Sheet |
| **Conector LLM** | [Técnicos] LLM conectado y respondiendo en el flujo <br> [Técnicos] Datos sensibles no expuestos <br> [Funcionales] Prompts del sistema definidos y validados <br> [De proceso] Control de alucinaciones probado <br> [De proceso] Pruebas de conversación superadas y documentadas |
| **Campañas masivas** | [Técnicos] Plantillas aprobadas por Meta <br> [Funcionales] Segmentos definidos y cargados <br> [De proceso] Prueba piloto exitosa <br> [De proceso] Métricas de apertura y respuesta registradas |
| **Formación** | [Funcionales] Guía de uso entregada <br> [De proceso] Sesión formativa realizada <br> [De proceso] Equipo cliente capaz de operar de forma autónoma |

---

## PASO 5 — CREACIÓN EN CLICKUP

Una vez aprobado cada producto por el PO, Claude lo crea.

### 5.1 Tarea principal
`clickup_create_task` → `list_id`, `name`, `description`, `assignees`,
`time_estimate` (ms = horas × 3.600.000)

### 5.2 Subtareas
`clickup_create_task` para cada subtarea con `parent`: ID de la tarea principal.

### 5.3 Campos personalizados
`clickup_update_task` con `custom_fields`:

```
PROYECTO:          a0020a79-1794-4539-8db5-19ca810a317c
TIPO DE PRODUCTO:  5bd9072e-deae-4352-b35b-bdbaa3cc216d  → usar WHATSAPP (ID pendiente de crear en ClickUp)
PO:                14d40a06-639f-4ad3-a241-aa66df2fcf23
ÉPICA:             6e3bf4c0-354b-4a8c-8cb5-dbedeec1cf6e
ORDEN:             a2fac0a6-0f12-4c9b-9f2f-c5bbc2aa7a98
REFINADO:          998657ca-d6e1-4880-966a-34a431195d12
PBIs PRIMER NIVEL: 6758065a-bd4f-4d7d-9a48-926e81fe343f
AMIGOS REINICIA:   aab85ad0-1d1f-43f4-b41d-c8593aa2c4ac
```

⚠️ Nota: Si el cliente tiene lista propia con campos diferentes,
verificar IDs con `clickup_get_custom_fields` antes de crear.

### 5.4 Checklist
⚠️ No disponible via MCP. Añadir comentario en la tarea recordando al PO que debe
crearlo manualmente con los criterios del Paso 4.

---

## PASO 6 — CONFIRMACIÓN FINAL

```
✅ Productos creados en ClickUp — [CLIENTE]
[Lista de productos con URLs]

Lista General Tee Travel (referencia): https://app.clickup.com/t/[id]

⚠️ Pendiente de completar manualmente:
  - Checklist "CRITERIOS DE ACEPTACIÓN" en cada producto
  - Campo ORDEN → asignar en el próximo Sprint Planning
  - Marcar REFINADO = true cuando cada producto esté listo para el sprint
  - Si aplica: crear board de Miro para el flujograma conversacional antes
    de iniciar cualquier producto de implementación de chatbot
```

---

## IDs DE LISTAS CONOCIDAS EN CLICKUP

| Cliente | Lista General ID |
|---|---|
| Tee Travel | `901214586754` |
| Carritech | `901207893908` |
| General Reinnova (plantillas) | `48885324` |

---

## CAMPOS PERSONALIZADOS — VALORES DROPDOWN

### PO
| Nombre | ID |
|---|---|
| ALVARO | 5ba7ac0e-72a3-4135-a8eb-30bb5b294692 |
| NESTOR | fa403009-5d93-4e47-875f-db7ce14cc047 |
| ELENA | 1a728383-7532-4393-910c-c0fc9589d111 |
| BORJA | fabb9c2c-ff44-46be-8282-0fad42c2d502 |
| ALEJANDRO | 8d13248e-407f-4651-b0a6-0f66780ed4f5 |
| PATRICIA | b609c4bf-12eb-402b-b70d-44555e8a9e25 |
| MARTA | 94f302e2-7cfb-49cf-a33d-8361b7eb7422 |
| PABLO | f572629f-4cc3-47a3-808b-52c33c0f7c9e |
| OSCAR | 4b96ec57-6c52-4fee-858f-c517b1305c56 |

### ÉPICAS
| Nombre | ID |
|---|---|
| 02. INVESTIGACIÓN | 69b75ed5-fcc4-4f88-b43a-3ee68d9928bc |
| 05. ADOPTION | 70bb9189-873a-4481-b8bf-3cf0e99c399f |
| 07. EXPANSION | de9a38bb-03fe-4c0b-ba14-7c5f57d95578 |
| FORMACIÓN | a25f454d-b805-4cda-9feb-482c6a912e5e |
| PLANIFICACIÓN | 574b22cf-6754-475f-af40-17ac9f03994b |

### TIPO DE PRODUCTO
| Nombre | ID |
|---|---|
| WHATSAPP | ⚠️ pendiente — crear en ClickUp Metodología |
| MARKETING AUTOMÁTICO | ac796e2a-c2bb-408c-b9e3-4ec975648653 |
| FORMACIÓN | 53d02eea-43f1-4101-b505-29a938da581e |

---

## NOTAS IMPORTANTES

- **Preguntas secuenciales:** una a una, sin agrupar.
- **El flujograma en Miro es condición previa obligatoria** para cualquier producto de
  implementación de chatbot. Si no existe aún, el SPIKE de flujograma debe estar en el backlog
  y ser el primero en ejecutarse.
- **Estructura antes del detalle:** proponer Épicas/PBIs/Productos en Paso 3 y esperar aprobación
  antes de desarrollar productos.
- **Tamaño máximo por producto:** 1-2 sprints (3 semanas cada uno). V1 → V2+ → V3+ si hay muchas
  funcionalidades.
- **Convención de nombres:** ver sección 2.13 "Convención del nombre de la tarjeta" en `formato-tarjeta-clickup-reinicia`. Resumen: el nombre describe el entregable en estado final (sustantivo o participio), no la acción. Test rápido: "Entregable: ___" debe sonar natural; "Tarea: ___" indica que está en modo acción y hay que reformular. SPIKEs son la excepción documentada (objeto de investigación con prefijo `[SPIKE]`).
- **Lista destino:** siempre `General [CLIENTE]`. Nunca Gestión ni Soporte.
- **REFINADO:** siempre `false` al crear.
- **ORDEN:** no asignar al crear — recordatorio al PO para Sprint Planning.
- **Tipo de producto WHATSAPP:** una vez creado en ClickUp (pendiente de Metodología), actualizar
  el ID en la tabla de campos personalizados de esta skill.
- **Accesos:** registrar siempre en Zoho Vault. No incluir credenciales en el cuerpo de la tarea.
- **Plataforma Eazybe:** no requiere cuenta WABA oficial Meta. Se instala como extensión de Chrome
  sobre WhatsApp Web. Tratar su configuración como producto separado de la cuenta WABA estándar.
- **Reutilizar conocimiento:** buscar siempre proyectos similares en ClickUp. Referencia validada:
  Tee Travel (lista `901214586754`) — chatbot Woztell con flujograma previo en Miro.
- **Checklist:** no disponible via MCP — siempre recordar al PO con criterios listos para copiar.

---

## BUENAS PRÁCTICAS WABA — Instrucciones para Claude

### Cuándo activar esta sección
Solo si el PO ha confirmado que quiere recibir propuestas de mejora (Pregunta 8 de la
elicitación). Si el PO aporta fuentes propias, consultarlas además de las oficiales.

### Cómo presentarlas
Al final del detalle de cada producto, antes de "¿Apruebas este producto?", añadir:

```
💡 PROPUESTAS DE MEJORA — [NOMBRE PRODUCTO]

[Para cada propuesta:]
Idea: [descripción concisa de la mejora]
Fuente: [nombre y URL de la fuente oficial]
Dentro del alcance actual: [Sí / No / Parcialmente]
Si está fuera de alcance: [indicar qué requeriría — desarrollo custom, presupuesto adicional, etc.]
```

Presentar un máximo de 3 propuestas por producto. Priorizarlas por impacto esperado para
el cliente, no por complejidad técnica.

### Fuentes oficiales de referencia

**Woztell (plataforma principal de Reinicia):**
- Índice general documentación: https://doc.woztell.com/
- Best practices chatbot: https://doc.woztell.com/docs/documentations/get-started/best-practices/
- Blog y casos de uso: https://woztell.com/use-cases/
- Documentación WhatsApp Cloud: https://doc.woztell.com/docs/documentations/whatsapp/wa-overview/
- Catálogo / Product Messages: https://doc.woztell.com/docs/procedures/basic-whatsapp-chatbot-setup/standard-procedures-wa-product-msg/
- Integrations (Zoho CRM y otras): https://doc.woztell.com/docs/integrations/whatsapp/wa-overview

**Blip.ai:**
- Docs oficiales ES (precios, privacidad, seguridad): https://www.blip.ai/es/docs/
- API Reference técnica (Builder, SDK, tipos contenido, extensiones): https://docs.blip.ai/#introduction
- Blog oficial ES: https://www.blip.ai/blog/es/
- LinkedIn (novedades y casos): https://www.linkedin.com/company/blipbr/

**Eazybe (WhatsApp Business Individual + Zoho CRM):**
- Help Docs completo: https://eazybehelpdesk-meb4m.desk.notaku.site/
  Cubre: Productivity Tools · WhatsApp as a CRM · 3rd Party CRM Integrations (incluye Zoho)
- Tutoriales YouTube: https://www.youtube.com/playlist?list=PLi3dUwNVY25MX7Brhu4GXa2dGQ5V7L4NK
- Instalar extensión Chrome: https://chromewebstore.google.com/detail/eazybe-best-whatsapp-web/clgficggccelgifppbcaepjdkklfcefd

**Meta / WhatsApp Business Platform:**
- WhatsApp Business Platform (developers): https://developers.facebook.com/docs/whatsapp
- Novedades Conversations 2025: https://business.whatsapp.com/blog/conversations-2025
- Precios por conversación Blip/Europa (actualizado nov. 2025): https://www.blip.ai/es/docs/conversacion-europa/
- Precios por conversación Blip/USD: https://www.blip.ai/es/docs/conversacion-mexico/

**Si el PO aporta fuentes adicionales:** consultarlas con web_fetch antes de redactar las
propuestas del producto correspondiente.

---

### Buenas prácticas por tipo de producto

#### Alta y configuración WABA
- **Verificación del negocio en Meta** — completar la verificación de Business Manager
  para desbloquear límites de mensajería (de 250 a 1.000 contactos/día y más).
  Fuente: Woztell docs (Connect WABA). Dentro del alcance: Sí, es parte del setup estándar.
- **Display Name aprobado** — elegir un nombre que refleje la marca real del cliente;
  Meta lo revisa y puede rechazarlo si no coincide con el nombre comercial registrado.
  Fuente: Woztell docs. Dentro del alcance: Sí.
- **Configurar Reinicia como Partner desde el inicio** — garantiza acceso técnico directo
  sin depender de credenciales del cliente para gestiones urgentes.
  Fuente: experiencia Tee Travel / Woztell. Dentro del alcance: Sí.

#### [SPIKE] Flujograma Bot
- **Flujo de máximo 5 nodos por rama directa** — según Woztell, los usuarios pierden
  paciencia si el flujo supera 5 pasos. Diseñar rutas cortas y cerradas.
  Fuente: https://doc.woztell.com/docs/documentations/get-started/best-practices/
  Dentro del alcance: Sí, afecta al diseño del flujograma.
- **Quick replies en lugar de botones para acciones únicas** — los botones permanecen
  en el historial y pueden provocar clics repetidos; las quick replies desaparecen.
  Fuente: Woztell Best Practices. Dentro del alcance: Sí.
- **Personalidad y tono consistentes** — definir la voz del bot (formal, cercana, con
  emojis o sin ellos) antes de redactar los mensajes. Afecta a toda la experiencia.
  Fuente: Woztell Best Practices / Woztell blog. Dentro del alcance: Sí, parte del SPIKE.
- **Recovery message (re-engagement)** — configurar un mensaje automático si la
  conversación lleva 30 minutos inactiva para recuperar usuarios que abandonaron a medias.
  Fuente: Woztell Best Practices. Dentro del alcance: Parcialmente (configurable en Woztell
  sin desarrollo custom).

#### Chatbot V1 / V2
- **WhatsApp Flows para recogida de datos** — en lugar de preguntas conversacionales
  una a una, usar WhatsApp Flows (formulario in-app) para recoger varios campos a la vez.
  Reduce el abandono y mejora la calidad de los datos.
  Fuente: Tee Travel v2 (notas en cards del flujograma) / Meta for Developers.
  Dentro del alcance: Parcialmente — requiere configuración adicional en Woztell/Blip.
- **Menú persistente** — añadir un menú siempre visible (persistent menu) con acceso
  directo a soporte humano, para usuarios que no quieran interactuar con el bot.
  Fuente: Woztell Best Practices. Dentro del alcance: Sí.
- **Fail-safe en todos los nodos de decisión** — ante cualquier input no esperado,
  el bot debe reconducir al usuario en lugar de quedarse bloqueado. Estándar de Reinicia
  según flujograma Tee Travel. Fuente: Woztell Best Practices + metodología Reinicia.
  Dentro del alcance: Sí, obligatorio.

#### Integración WABA ↔ Zoho CRM
- **Email como campo único de identificación** — usar el email (no el teléfono) como
  identificador para evitar duplicados en CRM cuando el usuario contacta desde distintos
  números. Aprendizaje de Tee Travel v2.
  Fuente: metodología interna Reinicia. Dentro del alcance: Sí.
- **Actualizar solo campos vacíos** (no sobrescribir) en registros existentes — política
  de actualización segura para no perder datos ya validados en CRM.
  Fuente: Tee Travel v2 (cards de flujograma). Dentro del alcance: Sí.
- **UTM tracking** — capturar parámetros UTM para atribuir conversaciones a campañas de
  marketing. Requiere desarrollo custom adicional (API).
  Fuente: Tee Travel v1/v2 (notas técnicas). Dentro del alcance: No en alcance estándar
  — presupuestar aparte como mejora evolutiva.

#### Campañas masivas WA
- **Conversaciones user-initiated gratuitas desde nov. 2024** — las conversaciones
  iniciadas por el usuario son gratis (sin límite). Las iniciadas por la empresa siguen
  siendo de pago por plantilla. Informar siempre al cliente de este modelo.
  Fuente: Meta pricing updates 2024-2025.
  Dentro del alcance: Sí, es información relevante para el cliente al planificar campañas.
- **Precios reales por conversación según plataforma y mercado** — los costes varían
  significativamente según el país destinatario y la categoría del mensaje (Marketing,
  Utility, Authentication, Service). Compartir siempre la tabla actualizada con el cliente
  antes de definir el volumen de campañas.
  Fuente: https://www.blip.ai/es/docs/conversacion-europa/ (actualizado nov. 2025).
  Dentro del alcance: Sí, es parte del diseño de la campaña.
- **Segmentación antes del envío** — enviar mensajes relevantes a segmentos concretos
  (no blast genérico) para mantener alta la calidad de la cuenta y evitar bloqueos por
  Meta. El Quality Score bajo puede limitar el alcance.
  Fuente: WhatsApp Business Best Practices 2025 / Woztell blog.
  Dentro del alcance: Sí, parte del diseño de la campaña.
- **Opt-in explícito obligatorio** — todos los destinatarios deben haber dado consentimiento
  expreso para recibir mensajes. Sin opt-in, riesgo de bloqueo de cuenta WABA.
  Fuente: Meta WhatsApp Business Policy. Dentro del alcance: Sí.

#### Eazybe (WhatsApp Business Individual + Zoho CRM)
- **Eazybe como CRM ligero sobre WhatsApp Web** — permite etiquetar contactos, crear
  recordatorios, añadir notas y gestionar el pipeline de ventas directamente desde
  WhatsApp Web, sin necesidad de cuenta WABA oficial Meta.
  Fuente: https://eazybehelpdesk-meb4m.desk.notaku.site/ (sección "WhatsApp as a CRM").
  Dentro del alcance: Sí, es la funcionalidad core de Eazybe.
- **Integración nativa con Zoho CRM** — Eazybe se conecta con Zoho CRM para sincronizar
  contactos y actividades. Documentado en la sección "3rd Party CRM Integrations" de la
  help doc.
  Fuente: https://eazybehelpdesk-meb4m.desk.notaku.site/ (sección "3rd Party CRM Integrations").
  Dentro del alcance: Sí, requiere configuración de la integración.
- **Limitación clave de Eazybe** — al trabajar sobre WhatsApp Web (no API oficial), no
  permite automatizaciones avanzadas, chatbots ni campañas masivas. Es adecuado para
  equipos pequeños de ventas, no para atención al cliente a escala.
  Fuente: documentación Eazybe / comparativa con WABA API.
  Dentro del alcance: Sí, informar al cliente de esta limitación antes de implementar.

#### Conector LLM
- **Definir contexto y límites del LLM desde el inicio** — establecer qué puede y no puede
  responder el LLM (scope), para evitar alucinaciones y mantener el control de la marca.
  Fuente: buenas prácticas generales de IA conversacional / Blip docs.
  Dentro del alcance: Sí, parte del SPIKE de conector LLM.
- **LLM + escalado a agente humano** — el LLM gestiona consultas frecuentes; para casos
  complejos, escalar siempre a agente. No depender 100% del LLM.
  Fuente: Woztell Best Practices (mix of robot and real person) / Blip AI documentation.
  Dentro del alcance: Sí.
- **Privacidad de datos** — definir qué datos del usuario se envían al LLM y cuáles no,
  en cumplimiento del RGPD. Especialmente relevante con OpenAI/Gemini (servidores fuera UE).
  Fuente: regulación RGPD + buenas prácticas de implementación de IA.
  Dentro del alcance: Sí, debe documentarse en el SPIKE.

#### Ecommerce / Catálogo WhatsApp
- **Catálogo en Facebook Commerce Manager** — el catálogo se gestiona en Meta Business
  Manager y se conecta al número WABA. Máximo 30 productos por mensaje multi-producto.
  Fuente: Woztell docs (Product Message). Dentro del alcance: Sí.
- **WhatsApp como canal de discovery, no solo de soporte** — el catálogo permite que
  el cliente explore productos sin salir del chat, reduciendo fricción en el embudo.
  Fuente: Meta Conversations 2025 / Woztell coexistence page.
  Dentro del alcance: Sí.

#### Formación
- **Documentación de buenas prácticas para el equipo del cliente** — entregar una guía
  de uso con qué se puede hacer en la plataforma, cuándo y cómo, para evitar acciones
  que afecten al bot o a la cuenta WABA. Aprendizaje de HomeEspaña (Zoho ↔ Web).
  Fuente: metodología interna Reinicia. Dentro del alcance: Sí.

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0 | 21/06/2026 | Néstor + Claude | Estado previo sin versionar, tabulado por primera vez al incorporar el estándar de versionado de Reinicia (21/06/2026). Creación asistida de productos digitales WABA/WhatsApp en ClickUp (elicitación, estructura de backlog, tareas y campos). |
