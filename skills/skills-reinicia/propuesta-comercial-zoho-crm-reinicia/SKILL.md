---
name: propuesta-comercial-zoho-crm-reinicia
description: >
  Skill para crear y gestionar Propuestas Comerciales en el módulo Deals de Zoho CRM
  para clientes de Reinicia. Cubre el flujo completo: verificación de propuesta existente,
  elicitación de campos, creación del Deal, nota de trazabilidad Claude AI, borrador de
  correo con firma corporativa y comentario en ClickUp.

  Actívala siempre que el PO quiera:
  - "crear una propuesta comercial para [CLIENTE]"
  - "crea una propuesta en Zoho CRM"
  - "hay una oportunidad para [CLIENTE], crea la propuesta"
  - cuando desde la skill de Sprint Planning se detecta una oportunidad y el PO confirma
    que quiere crear la propuesta

  Skills complementarias:
  - sprint-planning-reinicia: detecta oportunidades durante el planning y activa esta skill
  - plan-proyecto-zoho-sheet-reinicia: actualización del Plan de Proyecto
---

# SKILL: Propuesta Comercial en Zoho CRM — Reinicia

> **Versión vigente: v1.0 — 21/06/2026** · ver changelog al final (`## Versiones`)

## Propósito

Crear propuestas comerciales en el módulo Deals de Zoho CRM de forma asistida, siguiendo
el patrón de nomenclatura y campos establecidos por Reinicia, y generar automáticamente
el borrador de correo corporativo con la firma del responsable.

---

## RECURSOS CLAVE

### MCPs disponibles
| MCP | Uso |
|---|---|
| `Zoho CRM Comercial Propuestas Nestor` | Crear/actualizar Deals, notas, borradores de email, plantillas |
| `Zoho Comercial y Marketing MCP Alvaro` | Consultar Deals, Contactos, Productos, Cuentas |

### Plantillas de correo — consulta dinámica obligatoria

**Las plantillas se actualizan con frecuencia. NUNCA usar IDs hardcodeados.**
Consultar siempre el inventario actualizado en tiempo real al llegar al Paso 2 Pregunta 10:

```
ZohoCRM_getEmailTemplates (MCP: Zoho Comercial y Marketing MCP Alvaro)
  → primary_module: "Deals"
  → sort_by: "modified_time"
  → sort_order: "desc"
  → per_page: 50
  → Filtrar resultados por carpeta "REI Comercial"
```

Mostrar al PO el listado actualizado y sugerir la más adecuada según el tipo:
- Conectores entre sistemas → plantilla con "Conectores" en el nombre
- WABA / WhatsApp → plantilla con "WABA" o "Woztell" en el nombre
- Bolsa de horas → plantilla con "Bolsa" en el nombre
- Resto → plantilla genérica de primer envío

### Catálogo de productos Zoho CRM (principales)
| Producto | Categoría | ID |
|---|---|---|
| CRM - Consultoría | CRM | `227186000000949038` |
| Zoho CRM | CRM | `227186000002516082` |
| Zoho One | CRM | `227186000002516098` |
| Zoho Analytics | CRM | `227186000013724001` |
| Zoho Forms | CRM | `227186000015438073` |
| Zoho Flow | CRM | `227186000048564061` |
| Zoho Books | CRM | `227186000002800117` |
| Servicios | CRM | `227186000057069102` |
| Whatsapp Business API | Marketing | `227186000020321051` |
| Licencia de Woztell | CRM | `227186000039835066` |
| Gestión publicidad digital | Marketing | `227186000044027057` |
| Gestión de Proyecto | Marketing | `227186000011003036` |

> Consultar catálogo completo con `ZohoCRM_getRecords` módulo `Products`
> si ninguno de los anteriores encaja.

---

## PRINCIPIO FUNDAMENTAL — VALIDACIÓN ANTES DE EJECUTAR

Presentar siempre el resumen completo de la propuesta al PO y esperar confirmación
explícita antes de crear nada en Zoho CRM.

---

## PASO 1 — VERIFICAR SI YA EXISTE LA PROPUESTA

Antes de cualquier elicitación, buscar en Zoho CRM si ya existe una propuesta similar
para ese cliente en los últimos 365 días.

```
ZohoCRM_getRecords (módulo: Deals)
  → fields: Deal_Name, Account_Name, Stage, Amount, Created_Time
  → per_page: 50, sort_by: Created_Time, sort_order: desc
  → Paginar hasta cubrir 365 días (hasta 4 páginas de 50)
  → Filtrar por Account_Name del cliente
```

**Si NO existe propuesta similar** → continuar con PASO 2 (elicitación).

**Si YA existe propuesta similar** → preguntar al PO:
> "Ya existe una propuesta para esta oportunidad: **[nombre]** (Etapa: [etapa], Importe: [importe]€, Fecha: [fecha]).
> ¿Qué quieres hacer?"

Opciones (pueden combinarse — el PO puede elegir una o varias):
- **Añadir nota** → ir a PASO 6 (nota de actualización)
- **Generar borrador de correo** → consultar plantillas disponibles (igual que Pregunta 10
  del PASO 2) y ejecutar directamente el PASO 4.3 asociado a la propuesta existente.
  Antes verificar si ya existe un borrador con `ZohoCRM_getEmailDrafts` (módulo Deals,
  record: ID del deal):
  - Si NO existe borrador → crear uno nuevo
  - Si YA existe borrador → preguntar al PO si quiere actualizarlo o crear uno nuevo.
    Si actualiza → usar `ZohoCRM_updateEmailDrafts` con el ID del borrador existente
- **Crear propuesta nueva** → continuar con PASO 2

---

## PASO 2 — ELICITACIÓN

Preguntas secuenciales, una a una. Las respuestas de unas condicionan las siguientes.

### Pregunta 1: Nombre de la propuesta
Sugerir nombre siguiendo el patrón: `Propuesta [Tipo] [Descripción] [Cliente]`

Ejemplos del patrón real en Zoho CRM:
- `Propuesta Zoho Doble Barrido Conector SAP Gonher`
- `Propuesta Zoho Estructura Organizativa Inefso - Dinam`
- `Propuesta WhatsApp Business API Clinica Dr. Diego Casas`
- `Propuesta Bolsa 30 horas mantenimiento Avaderm`

→ Proponer nombre y pedir confirmación o ajuste.

### Pregunta 2: Etapa
Para **clientes existentes** → "Cualificación" por defecto.
Para **clientes nuevos** → preguntar al PO.

Valores disponibles: `Qualification`, `Needs Analysis`, `Value Proposition`,
`Identify Decision Makers`, `Proposal/Price Quote`, `Negotiation/Review`,
`Closed Won`, `Closed Lost`, `Closed Lost to Competition`

### Pregunta 3: Tipo
- `Existing Business` → cliente ya en cartera
- `New Business` → cliente nuevo

### Pregunta 4: Importe estimado
Obligatorio siempre — se puede ajustar después. No dejar vacío.

### Pregunta 5: Fecha de cierre estimada
Obligatoria siempre. Pedir fecha concreta.

### Pregunta 6: Responsable (Owner)
Preguntar siempre — no asumir:
> "¿Quién será el responsable de esta propuesta — el PO del proyecto o Néstor?
> (Si la propuesta es compleja o requiere intervención comercial directa, asignar a Néstor)"

⚠️ **Limitación técnica actual:** el campo Owner no está expuesto en el MCP.
El Deal se crea con el usuario autenticado del conector. Hasta que se resuelva,
indicar al PO que reasigne manualmente desde Zoho CRM si el responsable no es el
usuario del conector.

### Pregunta 7: Contacto principal y Contact Roles

**Contacto principal (obligatorio):**
Buscar los contactos de la cuenta del cliente en Zoho CRM:
```
ZohoCRM_getDealsRecords (módulo: Deals, filtrar por Account_Name del cliente)
  → o bien buscar directamente en Contacts filtrando por Account_Name
```
Presentar al PO la lista de contactos encontrados para que elija el contacto principal.
El email del contacto se extrae directamente del registro en Zoho CRM — nunca pedirlo
manualmente al PO si ya existe en el sistema.

**Contact Roles (opcional pero recomendado):**
Una vez elegido el contacto principal, preguntar al PO si quiere asociar contactos
adicionales con roles específicos:
> "¿Hay otros contactos del cliente que deban estar asociados a esta propuesta
> con un rol concreto (ej. decisor, influenciador, usuario final)?"

- Consultar los roles disponibles en tiempo real con `ZohoCRM_getContactRoles`
  — nunca usar roles hardcodeados, pueden variar
- Presentar al PO la lista de contactos de la cuenta + los roles disponibles
- Para cada contacto adicional: elegir contacto → asignar rol
- Se ejecuta con `ZohoCRM_associateContactRoleToDeal` tras crear el Deal (Paso 4.4)

### Pregunta 8: Productos
Mostrar al PO el catálogo relevante según el tipo de propuesta y preguntar cuáles aplican.
Sugerir productos basándose en el contexto (tipo de propuesta, tecnologías mencionadas).
Pueden ser uno o varios.

⚠️ **Limitación técnica actual:** la asociación de productos al Deal no está disponible
vía MCP. Indicar al PO los productos seleccionados para que los añada manualmente
desde Zoho CRM.

### Pregunta 9: Información de contexto / descripción
"¿Quieres añadir información de contexto, requerimientos del cliente u otra información
relevante para esta propuesta?"
- Si es texto simple → campo `Description` del Deal
- Si tiene formato enriquecido (listas, secciones) → nota en Zoho CRM

### Pregunta 10: Plantilla de correo
Mostrar las plantillas disponibles y preguntar cuál usar:
> "¿Qué plantilla de correo usamos como base para el borrador?"

Sugerir la más adecuada según el tipo de propuesta:
- Conectores → Propuesta Comercial Conectores Zoho
- WABA/WhatsApp → Propuesta Comercial WABA con Woztell
- Bolsa horas → Propuesta Bolsa Horas Zoho
- Resto → Primer Correo Envío Propuesta Genérica

---

## PASO 3 — PROPUESTA DE RESUMEN PARA VALIDACIÓN

Antes de crear nada, presentar resumen completo:

```
📋 PROPUESTA A CREAR EN ZOHO CRM

| Campo | Valor |
|---|---|
| Nombre | [nombre] |
| Cuenta | [cliente] |
| Etapa | [etapa] |
| Tipo | [tipo] |
| Importe | [importe] € |
| Fecha de cierre | [fecha] |
| Responsable | [nombre] ⚠️ asignar manualmente si ≠ usuario conector |
| Contacto | [nombre contacto] |
| Productos | [producto 1] · [producto 2] ⚠️ asociar manualmente |
| Descripción | [si la hay] |
| Plantilla correo | [nombre plantilla] |
| Versión | 1 |

¿Confirmas y ejecuto?
```

---

## PASO 4 — CREACIÓN EN ZOHO CRM

Una vez confirmado por el PO, ejecutar en este orden:

### 4.1 Crear el Deal
```
ZohoCRM_createDealsRecords
  → Deal_Name, Account_Name (id), Contact_Name (id)
  → Stage, Type, Amount, Closing_Date
  → Pipeline: "Standard (Standard)"
  → Description (si la hay)
```

⚠️ Campos pendientes de habilitar en el MCP (añadir cuando estén disponibles):
- `Owner` → ID del responsable
- `Empresa` → nombre de la empresa (campo custom)
- `Versi_n` → valor `1` al crear

### 4.2 Crear nota de trazabilidad Claude AI
```
ZohoCRM_createNotes (módulo: Deals, record: ID del deal)
  → Note_Title: "Propuesta creada desde Claude AI"
  → Note_Content:
    "Esta propuesta fue creada automáticamente desde Claude AI el [fecha].
    Oportunidad identificada por [PO] durante [contexto: sprint planning / reunión / etc.].
    Pendiente de revisión y validación por [responsable].

    Pendientes manuales en Zoho CRM:
    - Asignar Owner → [nombre responsable]
    - Asociar productos → [lista de productos]
    - Rellenar campo Empresa → [nombre empresa]
    - Rellenar campo Versión → 1"
```

### 4.4 Asociar Contact Roles (si el PO los indicó en Pregunta 7)
Para cada contacto adicional confirmado por el PO:
```
ZohoCRM_associateContactRoleToDeal
  → dealId: ID del deal recién creado
  → contactId: ID del contacto adicional
  → Contact_Role: {id: ID del rol, name: nombre del rol}
```
Ejecutar una llamada por cada contacto adicional.

### 4.3 Generar borrador de correo con firma

**Principio obligatorio:** el borrador SIEMPRE se genera a partir de una plantilla
existente en Zoho CRM — nunca escribir el HTML desde cero. La firma debe corresponder
al remitente real del correo y obtenerse de forma dinámica, nunca escribirla manualmente.

1. Obtener HTML de la plantilla seleccionada con firma del remitente resuelta:
```
ZohoCRM_generateEmailTemplateContent
  → emailTemplateId: [ID plantilla seleccionada]
  → record_id: [ID del deal recién creado]
```
Esto resuelve automáticamente `${!userSignature}` con la firma real del usuario
autenticado en el conector (nombre, cargo, teléfono, logo, banner corporativo).
Si el remitente es distinto al usuario del conector, advertir al PO que la firma
puede no corresponderse y que deberá ajustarla manualmente antes de enviar.

2. Sustituir en el HTML obtenido:
   - El cuerpo de la plantilla por el contenido adaptado a la propuesta concreta
   - Mantener TODA la estructura visual (tablas, estilos, espaciados, fondos)
   - Mantener la firma tal como viene resuelta — no modificarla
   - Resolver el nombre del contacto (`${!Deals.Contact_Name}` → nombre real)
   - Eliminar los textos en verde (son instrucciones al remitente, no van al cliente)

3. Crear el borrador:
```
ZohoCRM_createEmailDrafts (módulo: Deals, record: ID del deal)
  → subject: "REINICIA: Propuesta [Descripción] [Cliente]"
  → from: email del remitente
  → to: email del contacto principal (extraído de Zoho CRM)
  → content: HTML completo con contenido adaptado + firma del remitente
  → rich_text: true
```

**Estructura estándar del cuerpo del correo** (basada en plantilla Conectores Zoho):
```
Buenos días, [Nombre contacto]:

Tal y como hemos hablado, te mando a continuación la propuesta para [descripción breve].

Te indico las condiciones a continuación:

ENTREGABLES
1. [Entregable 1]
2. [Entregable 2]

LIMITACIONES
- [Limitación si aplica]

ACTIVIDADES
- [Actividad 1]
- [Actividad 2]

CONDICIONES ECONÓMICAS Y DE TIEMPO
- Precio: [desglose]
- Condiciones de pago: [condiciones]
- Fecha de entrega estimada: [plazos]

EXCLUSIONES
- [Exclusión si aplica]

Cualquier duda o pregunta, quedo a tu disposición.
¡Hasta pronto y muchas gracias!

[Firma corporativa Néstor — extraída de generateEmailTemplateContent]
```

---

## PASO 5 — COMENTARIO EN CLICKUP

Al finalizar el proceso completo, ofrecer al PO dejar un comentario en ClickUp:
> "¿Quieres que deje un comentario en ClickUp con el enlace a la propuesta?"

Si confirma → preguntar en qué producto de Gestión dejarlo si no es obvio por contexto,
y confirmar el responsable al que asignarlo:
> "¿A quién asigno el comentario? Normalmente sería Néstor — ¿confirmas?"

```
clickup_create_task_comment
  → task_id: ID del producto Gestión [Mes] [AÑO] [CLIENTE]
  → comment_text:
    "Propuesta comercial creada en Zoho CRM:
    [Nombre propuesta]
    https://crm.zoho.eu/crm/org227186000/tab/Potentials/[ID del deal]

    Importe estimado: [importe] €
    Fecha cierre estimada: [fecha]
    Etapa: [etapa]
    Responsable: [nombre responsable]

    Pendiente en Zoho CRM: asignar Owner + asociar productos + campos Empresa y Versión"
  → assignee: ID del responsable confirmado por el PO
              (Néstor por defecto: ID ClickUp 766716)
```

Si el comentario es en el contexto del Sprint Planning (skill sprint-planning-reinicia),
este paso ya está cubierto por esa skill — no duplicar.

---

## PASO 6 — NOTA DE ACTUALIZACIÓN (propuesta existente)

Si ya existe una propuesta y el PO quiere añadir una nota:

1. Preguntar qué información quiere añadir
2. Determinar el título de la nota siguiendo el patrón de notas anteriores
   (consultar notas existentes de propuestas similares para inferir el patrón)
3. Crear la nota mencionando a Néstor en el contenido:
```
ZohoCRM_createNotes
  → Note_Title: [patrón del título según histórico]
  → Note_Content: [información indicada por el PO] + "CC: Néstor Tejero Bermejo"
```
4. Añadir comentario en Gestión [Mes] [CLIENTE] en ClickUp informando de la nota,
   asignado a Néstor por defecto

---

## PASO 7 — RESUMEN FINAL

Al terminar, presentar resumen de lo ejecutado:

```
✅ PROPUESTA CREADA — [NOMBRE PROPUESTA]

🔗 Zoho CRM: https://crm.zoho.eu/crm/org227186000/tab/Potentials/[ID]
   Número: [PREI-XXXX]

📧 Borrador de correo creado — listo para revisar y enviar desde Zoho CRM
   Para: [nombre contacto] — [email]
   Plantilla usada: [nombre plantilla]

💬 Comentario añadido en ClickUp — Gestión [Mes] [CLIENTE]

⚠️ Pendientes manuales en Zoho CRM:
   - Asignar Owner → [nombre responsable]
   - Asociar productos → [lista]
   - Rellenar campo Empresa → [nombre empresa]
   - Rellenar campo Versión → 1
```

---

## GESTIÓN DE VERSIONES

- **Al crear:** Versión = 1 (pendiente manual hasta habilitar campo en MCP)
- **Al enviar nueva versión al cliente:** incrementar Versión en 1
  → actualizar campo `Versi_n` del Deal (pendiente de habilitar en MCP)
  → crear nuevo borrador de correo con el contenido actualizado
  → añadir nota en Zoho CRM indicando qué cambió respecto a la versión anterior

---

## LIMITACIONES TÉCNICAS ACTUALES Y PLAN DE RESOLUCIÓN

| Limitación | Causa | Solución pendiente |
|---|---|---|
| Campo `Owner` no escribible | No expuesto en MCP | Ampliar scope MCP o crear MCP custom |
| Campo `Empresa` no escribible | Campo custom no mapeado en MCP | Ampliar scope / MCP custom |
| Campo `Versión` no escribible | Campo custom no mapeado en MCP | Ampliar scope / MCP custom |
| Productos no asociables vía API | Endpoint no expuesto en MCP | Añadir scope `ZohoCRM.modules.products.ALL` |

**Vía de resolución:** ir a https://api-console.zoho.eu → app del MCP de Propuestas →
ampliar scopes OAuth → revocar y re-autenticar el conector.
Si los campos custom siguen sin aparecer, crear MCP custom sobre la API REST de Zoho CRM v8.

---

## NOTAS OPERATIVAS

- **Patrón de nombre:** `Propuesta [Tipo] [Descripción] [Cliente]`
- **Email del contacto:** siempre extraerlo de Zoho CRM (campo Email del registro
  Contacts) — nunca pedirlo manualmente al PO si el contacto ya existe en el sistema.
  El ID del contacto vinculado al Deal está disponible en el campo `Contact_Name` del Deal.
- **Lead Source:** se hereda automáticamente de la Cuenta — no rellenar manualmente
- **Pipeline:** siempre `Standard (Standard)`
- **Etapa por defecto clientes existentes:** `Qualification`
- **Versión inicial:** siempre 1
- **Importe:** obligatorio siempre — se ajusta después si es necesario
- **Fecha de cierre:** obligatoria siempre
- **Búsqueda de propuestas existentes:** cubrir siempre los últimos 365 días (hasta 4 páginas)
- **Firma del correo:** obtener siempre con `generateEmailTemplateContent` pasando el ID
  del deal recién creado — nunca escribir la firma manualmente
- **Borrador de correo:** mantener TODA la estructura HTML de la plantilla;
  solo sustituir el cuerpo del contenido y resolver variables en verde

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0 | 21/06/2026 | Néstor + Claude | Estado previo sin versionar, tabulado por primera vez al incorporar el estándar de versionado de Reinicia (21/06/2026). Creación y gestión de propuestas comerciales en el módulo Deals de Zoho CRM (trazabilidad, borrador de correo y comentario en ClickUp). |
