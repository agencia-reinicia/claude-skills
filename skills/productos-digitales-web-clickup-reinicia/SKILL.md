---
name: productos-digitales-web-clickup-reinicia
description: Skill para crear productos digitales Web y WebApp (nueva web, mantenimiento, integraciones, soporte) en ClickUp de forma asistida para clientes de Reinicia. Cubre el flujo completo desde la elicitación con el PO hasta la creación de tareas, subtareas y campos personalizados en ClickUp. Actívala siempre que el PO pida crear productos o tareas en ClickUp para proyectos web o WebApp (WordPress, Drupal, React, widget Zoho, rediseño, nueva web, soporte web, integración CRM-Web, GA4, SEO técnico, mantenimiento de servidores), o cuando el contexto sea claramente un proyecto web o WebApp para un cliente. También se activa cuando el PO pida organizar el backlog web de un cliente, crear un SPIKE web, gestionar soporte operativo o mejoras evolutivas de una web. No usar para proyectos exclusivamente de Zoho CRM sin componente web (usar la skill de Zoho).
triggers:
  - crea un producto web
  - crea productos para la web de
  - organizar el backlog web de
  - nueva web ClickUp
  - crea un SPIKE web
  - crea el soporte web de
  - mejoras evolutivas web
---

# SKILL: Crear Productos Digitales Web y WebApp en ClickUp — Reinicia

## Descripción
Esta skill permite a los Product Owners de Reinicia crear tareas de producto digital web y WebApp en ClickUp de forma asistida. Cubre tres grandes tipos de trabajo: **nueva web o WebApp** (diseño, desarrollo con WordPress, Drupal, React u otras tecnologías, incluidas WebApps embebidas en Zoho como widgets), **soporte y mantenimiento** (soporte operativo continuo, mejoras evolutivas), e **integraciones web** (con Zoho CRM, otros CRMs, ERPs, plataformas de marketing o cualquier plataforma de terceros). Claude busca información del proyecto en Workdrive y proyectos similares en ClickUp, propone primero una **estructura completa de Épicas / PBIs / Productos** para validación del PO, y luego desarrolla el detalle de cada producto uno a uno antes de crearlo en ClickUp.

**Principio de mejora continua:** al redactar cada producto, Claude no se limita a copiar referencias existentes. Siempre enriquece el contenido con información de la propuesta, el Sprint Cero, los contenidos del cliente, las actas y las mejores prácticas de diseño y desarrollo web. Las propuestas de mejora se plantean siempre — algunas serán aceptadas y otras rechazadas, pero deben estar sobre la mesa.

## Cuándo activar esta skill
Triggers: "crea un producto web", "crea un producto WebApp", "organizar el backlog web de [CLIENTE]", "crea una tarea para la web", "nuevo producto web [cliente]", "crea un SPIKE web", "soporte web", "mantenimiento web", o cuando el PO pida crear uno o varios productos digitales para un proyecto web o WebApp en ClickUp.

NO usar para: actas de reunión, tareas de gestión, tareas de soporte de Zoho CRM sin componente web (skill separada), microcampañas de marketing.

---

## PASO 1 — ELICITACIÓN: Preguntas una a una al PO

Claude hace las preguntas de forma **secuencial**. No lanzar todas de golpe.

### Pregunta 1: Cliente, tipo de proyecto y estado
"¿Para qué cliente es y qué tipo de trabajo quieres organizar en ClickUp? ¿Es una nueva web o WebApp, soporte/mantenimiento de una web existente, una integración, o una combinación? ¿El proyecto es nuevo o ya está en curso?"

→ Según la respuesta, Claude determina qué tipo de tecnología y estructura proponer.

**Tipos de proyecto:**
- **Nueva web o WebApp:** Planificación → Consultoría Inicial (Arquitectura, Requerimientos, Contenidos) → Diseño UI/UX (Alta fidelidad, por rondas y bloques) → Desarrollo/Integración (por bloques de páginas o módulos) → Integraciones/Conectores → Analítica → Formación → Soporte
- **Soporte operativo continuo:** Bolsa de horas por sprint, mantenimiento de entornos — se crea en `Soporte [CLIENTE]`
- **Mejoras evolutivas:** Nuevas funcionalidades sobre web existente — se crea en `General [CLIENTE]`
- **Plan de Proyecto:** Documento de planificación — se crea en `Gestión [CLIENTE]`
- **Integración o Conector:** SPIKE primero → Implementación — siempre que haya incertidumbre técnica previa

**Tecnologías habituales en Reinicia:**
- CMS: WordPress, Drupal
- WebApps / Frontend: React, Vue u otras tecnologías JavaScript
- WebApps embebidas: widgets dentro de plataformas Zoho (Zoho CRM, Zoho Books, etc.)
- Integraciones: con Zoho CRM, otros CRMs/ERPs (SAP, Odoo, etc.), plataformas de marketing (Mailchimp, etc.) u otras plataformas de terceros

### Pregunta 2: Tecnología
"¿Con qué tecnología se va a desarrollar? ¿WordPress, Drupal, React, un widget de Zoho u otra cosa?"

→ La respuesta condiciona el naming de los productos de desarrollo (ej. "Integración WordPress V1" vs "Implementación React V1" vs "Widget Zoho CRM V1").

### Pregunta 3: Lista(s) en ClickUp
"¿Sabes los IDs de las listas de ClickUp que vamos a usar? Para implementación nueva es `General [CLIENTE]`, para soporte es `Soporte [CLIENTE]` y para el plan de proyecto es `Gestión [CLIENTE]`. Si no los tienes, los busco yo."

→ Claude busca con `clickup_search` si el PO no los tiene.

### Pregunta 4: Carpeta del proyecto en Workdrive
"¿Cuál es el ID de la carpeta raíz del proyecto en Proyectos Activos de Workdrive? Si no lo tienes a mano, puedo buscarlo con el nombre del cliente."

→ Claude busca con `ZohoWorkdrive_searchTeamFoldersFiles` si el PO no lo sabe.

### Pregunta 5: PO de Reinicia
"¿Quién es el Product Owner de Reinicia para este proyecto?"
(Opciones: ALVARO, NESTOR, ELENA, BORJA, ALEJANDRO, PATRICIA, MARTA, PABLO, OSCAR)

### Pregunta 6: Equipo asignado y perfiles especiales
"¿Qué personas del equipo de Reinicia van a trabajar en estos productos? ¿Hay algún Amigo Reinicia (freelance externo como diseñador o desarrollador)? ¿Participarán perfiles de Analítica Web o SEO? Cuéntame quién se encarga de qué, o lo dejamos para cuando proponga la estructura."

→ Los perfiles de Analítica (Analista Web) y SEO (Consultor SEO) generan sus propios productos, no son solo subtareas.

### Pregunta 7: Propuestas de mejora con fuentes oficiales
"Al redactar cada producto, puedo buscar en fuentes de referencia del sector (documentación oficial de WordPress/Drupal/React, Google Developers, Web.dev, MDN, blogs de Zoho para integraciones web...) e incluir propuestas de funcionalidades o mejoras relevantes para el proyecto, marcadas claramente como ideas fuera del alcance actual. ¿Quieres que lo haga? Y si tienes alguna fuente o área específica que te interese explorar (ej. rendimiento web, accesibilidad, integración con un servicio concreto...), indícamelo."

→ Si el PO dice sí: Claude activa el modo mejoras para todos los productos de la sesión. Si aporta fuentes o áreas concretas, se priorizan. Si dice no: se omite el bloque 💡 en todos los productos.

---

## PASO 2 — BÚSQUEDA DE INFORMACIÓN

### Estructura canónica de la carpeta Web — Cliente Ficticio
```
[CLIENTE] (carpeta raíz)
  ├── 00. Información                    ← SIEMPRE DEBE EXISTIR
  │     ├── Comercial                    ← PROPUESTA COMERCIAL aquí
  │     ├── Empresa                      ← SPRINT CERO aquí (PDF) + info cliente
  │     └── Credenciales Cliente
  ├── 01. Seguimiento                    ← ACTAS aquí
  └── Web/                              ← Documentación web del proyecto
        ├── Pruebas
        ├── Desarrollo Web
        ├── Contenidos
        ├── Diseño UI / UX
        ├── Diseño Funcional
        └── Mantenimiento Web
```

**Nota:** En proyectos Web NO existe carpeta "03. Consultoría" dentro de Web. La estructura es distinta a los proyectos Zoho CRM.

### Plan de Proyecto Web
Es un entregable clave al arrancar cualquier proyecto web nuevo. Usar la **Plantilla-Project-Calendar-Web-REINICIA** (Zoho Sheet, `ftk3m336061084ebf48c3bf609e373c993519`). Si el documento estuviera en inglés, el PO deberá traducirlo y convertirlo a Zoho Writer.

### Orden de búsqueda según tipo de proyecto

**Proyecto NUEVO:**
1. `00. Información > Empresa` → Sprint Cero (PDF). **Prevalece** — tiene el alcance acotado.
2. `00. Información > Comercial` → Propuesta Comercial aceptada (PDF).
3. `01. Seguimiento` → actas de reuniones de arranque.
4. Web del cliente + LinkedIn de personas clave.
5. ClickUp → buscar en **General TI-MEDI** (`900800044926`) como referencia de proyecto web nuevo completo reciente, y en **General Reinnova** (`48885324`) para plantillas [PLANTILLA] web.

**Proyecto EN CURSO:**
1. Sprint Cero / Propuesta Comercial.
2. Actas recientes en `01. Seguimiento`.
3. ClickUp → tareas existentes en `General [CLIENTE]` con `clickup_filter_tasks`.
4. Referencias TI-MEDI y Reinnova para estructura de productos.

### Herramientas de búsqueda en Workdrive
- `ZohoWorkdrive_searchTeamFoldersFiles` — buscar carpeta raíz por nombre de cliente
- `ZohoWorkdrive_getFolderFiles` — listar contenido de subcarpetas
- `ZohoWorkdrive_downloadWorkDriveFile` — leer PDFs (Propuesta, Sprint Cero)

---

## PASO 3 — PROPUESTA DE ESTRUCTURA: ÉPICAS / PBIs / PRODUCTOS

Antes de entrar al detalle de cada producto, Claude presenta una propuesta de **arquitectura del backlog** para validación del PO. No crear nada hasta que el PO apruebe.

```
📐 PROPUESTA DE ESTRUCTURA DE BACKLOG — [CLIENTE]

Basado en [fuentes consultadas], propongo organizar el trabajo así:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ÉPICA: [nombre épica]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  PBI de primer nivel: [agrupación]

    → Producto 1: [Nombre producto] [CLIENTE]
      Historia de usuario: Como [PO CLIENTE], QUIERO..., PARA...

    → Producto 2: [Nombre producto] [CLIENTE]
      Historia de usuario: Como [PO CLIENTE], QUIERO..., PARA...

  PBI de primer nivel: [otra agrupación]

    → [SPIKE] [Nombre investigación] [CLIENTE]
      Historia de usuario: Como [PO CLIENTE], QUIERO..., PARA...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ÉPICA: [segunda épica, si aplica]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ...

¿Estás de acuerdo con esta estructura? ¿Añades, quitas o ajustas algo?
Cuando confirmes, desarrollo el detalle de cada producto uno a uno.
```

### Notas sobre la estructura de productos web/WebApp:

**Norma de tamaño:** cada producto debe ser digerible en 1-2 sprints (3 semanas cada uno). Separar siempre el diseño UI/UX de la implementación en el CMS/framework, y dividir el desarrollo por bloques de páginas o funcionalidades.

**Secuencia canónica para nueva web/WebApp completa:**
1. Arquitectura de la web / Sitemap
2. Requerimientos técnicos y funcionales
3. Contenidos preliminares / Briefing de contenidos
4. Propuestas UI/UX Alta Fidelidad V1 (bloque de páginas 1) — Ronda 1, Ronda N
   - Entregable: PDF o Figma/prototipo interactivo (NO en WordPress todavía)
5. Contenidos definitivos
6. Propuestas UI/UX Alta Fidelidad V2 (bloque de páginas 2)... tantos como bloques
7. Integración [Tecnología] V1 (mismo bloque que alta fidelidad V1)
   - Para WordPress: "Integración WordPress V1 [CLIENTE]"
   - Para React: "Implementación React V1 [CLIENTE]"
   - Para widget Zoho: "Widget [Nombre] Zoho CRM V1 [CLIENTE]"
   - Entregable: la web/WebApp publicada en entorno de desarrollo/staging
8. Integración V2, V3...
9. [SPIKE] [Nombre] [CLIENTE] — siempre que haya incertidumbre técnica previa
10. Conector/Integración técnica [CLIENTE]
11. Analítica Web / GA4 [CLIENTE] — si hay Analista Web en el equipo
12. SEO [fase] [CLIENTE] — si hay Consultor SEO
13. Formación [CLIENTE]
14. Soporte Operativo Continuo / Mejoras Evolutivas → en listas `Soporte`/`General`

**SPIKEs:** se usan siempre que haya necesidad de investigación previa para definir la solución. No solo para conectores: también para funcionalidades a medida, integraciones complejas o decisiones de arquitectura técnica. Formato: `[SPIKE] [descripción corta] [CLIENTE]`.

**Nomenclatura de productos (preferir TI-MEDI sobre Reinnova cuando existan equivalentes):**
- Diseño → "Propuestas UI/UX Alta Fidelidad V1 (páginas que cubre) [CLIENTE]" (NO "Diseño Web: Ronda 1")
- Desarrollo → "Integración [Tecnología] V1 (páginas que cubre) [CLIENTE]"
- Investigación → "[SPIKE] [descripción] [CLIENTE]"

**Perfiles y sus productos propios:**
- Analista Web → productos de Analítica (GA4, GTM, dashboards, informes)
- Consultor SEO → productos de SEO (auditoría previa, informe, guía buenas prácticas)
- Diseñador UI/UX → productos de Propuestas Alta Fidelidad
- Desarrollador → productos de Integración en tecnología

**Épicas habituales en proyectos web:**
- PLANIFICACIÓN (arquitectura, requerimientos, plan de proyecto)
- 02. INVESTIGACIÓN (consultoría, SEO previo, SPIKEs)
- 03. CONSIDERACIÓN (diseño UI/UX, alta fidelidad)
- 05. ADOPTION (desarrollo, integraciones, formación)
- 06. REPETITION (soporte operativo)
- 07. EXPANSION (mejoras evolutivas)

---

## PASO 4 — DETALLE DE CADA PRODUCTO (uno a uno)

Aprobada la estructura, Claude desarrolla cada producto de uno en uno. Para cada uno consulta:
1. **La propuesta comercial y/o Sprint Cero** — fuente de verdad sobre alcance y compromisos.
2. **Actas relevantes** — para contexto de decisiones y ajustes acordados.
3. **Plantillas [PLANTILLA] de Reinnova** similares al tipo de producto (ver tabla más abajo).
4. **Proyectos TI-MEDI** como referencia de proyecto web completo reciente.
5. **Protocolo Hoja de Ruta Web** (`fr4m2e806d4863b044e3fb64a30a1af012bb0`) si necesita detalle de fases.
6. **Búsqueda de mejoras en fuentes oficiales** (solo si el PO lo ha confirmado en Pregunta 7): Claude realiza búsquedas en las fuentes de referencia relevantes según la tecnología del proyecto — documentación oficial de WordPress/Drupal/React, Google Developers (`developer.chrome.com`, `web.dev`), MDN Web Docs (`developer.mozilla.org`), blog y documentación de Zoho para integraciones web, recursos de accesibilidad (WCAG), herramientas de rendimiento (PageSpeed, Core Web Vitals), etc. Si el PO indicó fuentes o áreas específicas, se consultan primero.

**Formato del bloque de mejoras** (se añade al final del producto, después de los criterios de aceptación, solo si el PO activó la opción):

```
💡 PROPUESTAS DE MEJORA — [NOMBRE PRODUCTO]

Estas ideas están FUERA del alcance actual del producto. Se presentan como oportunidades
a valorar con el cliente en futuras iteraciones o como ampliación del alcance.

  💡 [Título de la mejora]
     Descripción breve de la funcionalidad, patrón de diseño o integración propuesta
     y por qué sería relevante para este cliente en concreto.
     Fuente: [URL o nombre del recurso consultado]
     Estado: Fuera de alcance — requiere valoración y presupuesto adicional

  💡 [Título de la mejora]
     ...
     Fuente: [URL]
     Estado: Fuera de alcance — requiere valoración y presupuesto adicional
```

**Entregables según tipo de producto:**
- Propuestas UI/UX Alta Fidelidad → PDF exportado de Figma o similar (presentación visual), no WordPress
- Integración en CMS/framework → web publicada en entorno dev/staging
- Contenidos → documento Zoho Writer (basado en Plantilla-Contenidos-Web)
- Requerimientos → Zoho Sheet (Plantilla-Toma-Requerimientos-Inicial-Web)
- Pruebas → Zoho Sheet (Plantilla-Pruebas-Funcionales-y-Técnicas)
- SEO → Zoho Writer (Template-Good-Practices-Guide-SEO-Web, traducido al español si estuviera en inglés)
- Plan de Proyecto → Zoho Sheet (Plantilla-Project-Calendar-Web)

```
📋 PRODUCTO [N de M]: [NOMBRE DEL PRODUCTO] [CLIENTE]

NOMBRE TAREA: [Nombre del producto] [CLIENTE]

DESCRIPCIÓN:
  Historia de usuario:
  Como [NOMBRE PO CLIENTE], QUIERO [qué], PARA [para qué].

  Descripción:
  Web: [URL del cliente]
  Objetivo Cliente: [objetivo del proyecto]
  Público objetivo: [si aplica]

  Ready to Backlog:
  - [prerrequisitos específicos del producto]

  Entregables a Cliente:
  - [Entregable 1] → [enlace plantilla Workdrive Web]
  - [Entregable 2]

  Entregables Internos Reinicia: [si aplica]
  - [Entregable interno] → [enlace plantilla]

  Documentación de referencia:
  - Sprint Cero [CLIENTE]: [enlace versión pública Workdrive]
  - Propuesta Comercial: [enlace Workdrive si aplica]
  - [actas relevantes con enlace]

SUBTAREAS:
  1. [Subtarea de trabajo 1]
  2. [Subtarea de trabajo 2]
  ...
  N-1. Validación Reinicia
  N. Validación Cliente
  [Si hay iteraciones: Ronda 2 → Validación Reinicia → Validación Cliente]

CRITERIOS DE ACEPTACIÓN (copiar manualmente en ClickUp):
  Formato: una línea por criterio con la categoría entre corchetes como prefijo.
  Permite copiar y pegar directo al checklist de ClickUp, donde cada línea se
  convierte en un ítem y la categoría queda visible en cada uno.

  Checklist: CRITERIOS DE ACEPTACIÓN

  [Técnicos] Entorno de desarrollo (dev/staging) activo y accesible
  [Técnicos] Repositorio GitHub con rama de trabajo creado
  [Técnicos] [Criterios técnicos propios del producto]
  [Funcionales] [Criterios funcionales propios del producto]
  [Funcionales] Las personas de Reinicia ven en su Zoho Vault los accesos del proyecto
  [De proceso] Pruebas funcionales superadas y documentadas en Zoho Sheet
  [De proceso] Informe WSA Ejecutivo sin errores graves para entornos web
  [De proceso] [Criterios de proceso propios del producto]

CAMPOS PERSONALIZADOS:
  PROYECTO: [CLIENTE]
  TIPO DE PRODUCTO: DESARROLLO WEB
  PO: [Nombre PO]
  ÉPICA: [acordada en Paso 3]
  PBIs PRIMER NIVEL: [acordado en Paso 3]
  REFINADO: No (por defecto)
  AMIGOS REINICIA: [nombre si aplica para este producto concreto]
  Tiempo estimado: [si el PO lo indica]
  ORDEN: ⚠️ pendiente — el PO lo asigna en el Sprint Planning

¿Apruebas este producto tal como está? ¿Modificas algo antes de crearlo?
```

---

## PASO 5 — CREACIÓN EN CLICKUP

Una vez aprobado cada producto por el PO, Claude lo crea.

### 5.1 Tarea principal
`clickup_create_task` → `list_id`, `name`, `description`, `assignees`, `time_estimate` (ms = horas × 3.600.000)

### 5.2 Subtareas
`clickup_create_task` para cada subtarea con `parent`: ID de la tarea principal.

### 5.3 Campos personalizados
`clickup_update_task` con `custom_fields`. Usar los mismos IDs de campos que la skill de Zoho (son los mismos campos en el workspace). Verificar con `clickup_get_custom_fields` si la lista del cliente es diferente a Carritech.

IDs de referencia (lista General Carritech):
```
PROYECTO:          a0020a79-1794-4539-8db5-19ca810a317c
TIPO DE PRODUCTO:  5bd9072e-deae-4352-b35b-bdbaa3cc216d  → usar valor "DESARROLLO WEB": c0fd12ed-112f-4150-aa70-0268e8de3ac5
PO:                14d40a06-639f-4ad3-a241-aa66df2fcf23
ÉPICA:             6e3bf4c0-354b-4a8c-8cb5-dbedeec1cf6e
ORDEN:             a2fac0a6-0f12-4c9b-9f2f-c5bbc2aa7a98
REFINADO:          998657ca-d6e1-4880-966a-34a431195d12
PBIs PRIMER NIVEL: 6758065a-bd4f-4d7d-9a48-926e81fe343f
AMIGOS REINICIA:   aab85ad0-1d1f-43f4-b41d-c8593aa2c4ac
```

### 5.4 Checklist
⚠️ No disponible via MCP. Añadir comentario en la tarea recordando al PO que debe crearlo manualmente con los criterios del Paso 4.

---

## PASO 6 — CONFIRMACIÓN FINAL

Al terminar todos los productos:

```
✅ Productos creados en ClickUp — [CLIENTE]
[Lista de productos con URLs]

⚠️ Pendiente de completar manualmente:
  - Checklist "CRITERIOS DE ACEPTACIÓN" en cada producto
  - Campo ORDEN → asignar en el próximo Sprint Planning
  - Marcar REFINADO = true cuando cada producto esté listo para el sprint
```

---

## PLANTILLAS [PLANTILLA] DE REFERENCIA — REINNOVA (lista `48885324`)

| Tipo de producto | ID ClickUp |
|---|---|
| Diseños Web: Ronda 1 - Escritorio | `8695excpc` |
| Diseños Web: Ronda 1 - Móvil | `8695gx0kk` |
| Diseños Web: Ronda N | `8695gx0hq` |
| Maquetas Web: Ronda 1 | `8695excwn` |
| Contenidos Web Preliminar | `8695exca2` |
| Contenidos Web Definitivos | `8695excbh` |
| Contenidos Migrados o Nueva Web | `8695gx0pj` |
| Diseño Página de aterrizaje | `865c37f6r` |
| Plantilla genérica producto Reinnova | `8697jhwd1` |

Consultar con `clickup_get_task` para revisar subtareas/criterios estándar de cada tipo.

**Referencia de proyecto web completo:** lista General TI-MEDI (`900800044926`), proyecto de referencia más reciente y completo. IDs clave de tareas:
- Arquitectura website: `869aeg8td`
- Contenidos Nueva Web: `869amt9bm`
- Prototipo alta fidelidad V1: `869abz8pn`
- Prototipo alta fidelidad V2-V6: `869au8wkz`, `869au8z3v`, `869b8rbr9`, `869b8rbxb`, `869bh66pn`
- Prototipo WordPress V1-V6: `869b4bq8e`, `869c52uwu`, `869c52vtk`, `869c52x0q`, `869cem5ru`, `869cem4mm`
- [SPIKE] Conector Odoo: `869cg8u0j`
- [SPIKE] Conector Mailchimp: `869cmqz5m`
- Conector Odoo: `869cmqz01`
- Conector Mailchimp: `869cmqz9b`

---

## PLANTILLAS DE ENTREGABLES — RECURSOS COMUNES WORKDRIVE (Web)

```
Recursos Comunes Reinicia: 6y4l6e0b8c445ef5c4d8b825374831009c9ad
  └── Plantillas Reinicia > Web: fr4m26f22abee7e594b7a91e55b79ff23f5b8
      ├── Protocolo Hoja de Ruta Web (Writer): fr4m2e806d4863b044e3fb64a30a1af012bb0
      └── Plantillas (carpeta):               ftk3m942f82808b1e49bd931439b246d7de55
          ├── Plantilla-Toma-Requerimientos-Inicial-Web (Sheet): ftk3m44d619da8e3c4398a5743ed15d89338e
          ├── Plantilla-Project-Calendar-Web (Sheet):            ftk3m336061084ebf48c3bf609e373c993519
          ├── Plantilla-Contenidos-Web (Writer):                 fzegfa7a17a9fe7f44cfcad362ffe5d9c90b3
          ├── Plantilla-Listado-URLs-Redirecciones (Sheet):      i51mdca2b99d6d923408bb30bfa707ea8eadf
          ├── Plantilla-Pruebas-Funcionales-y-Técnicas (Sheet):  ftk3m08c60c8ac4364183aca25eea8d32c1e2
          ├── Plantilla-Propuestas-Mejora-UX-y-WPO (Show):       fzegfa27dfda0e2fa4a108188ff5c0bc20e19
          ├── Template-Good-Practices-Guide-SEO-Web (Writer):    ftk3m8b23df59969449289ee85bff186406b7
          └── Catálogo de Técnicas UX/UI (carpeta):              4sfs6a5e09f3d3645436cbd20e56c2b5eb56c
```

**Plantillas de Soporte — Comercial > Zoho (adaptables a Web):**
```
  └── Comercial > Zoho: 542y5872b154c6c254596b20358f693a5ccf7
      ├── Soporte Operativo Continuo 1.01 (Writer): o16et26cabb411f5a49e98c4eaa28ee2288a5
      ├── Soporte Operativo Continuo 1.01 (PPTX):   o16et9eabdfef81014d488500484c56008c32
      ├── Crédito Mejoras Evolutivas 1.00 (Writer):  nx8q7144b1fc0de214c649bfd122aa25ffdd0
      └── Crédito Mejoras Evolutivas 1.00 (PPTX):   o16et7dbcfbf424bd4d9eb937919e182c7e56
```

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

### TIPO DE PRODUCTO (para proyectos web usar DESARROLLO WEB)
| Nombre | ID |
|---|---|
| DESARROLLO WEB | c0fd12ed-112f-4150-aa70-0268e8de3ac5 |
| CRM | 814e9896-f224-458f-afef-3aaa1506ce5b |
| GESTIÓN CRM | f100a89f-cdf8-408e-a10a-1f1584255c2b |
| EMAIL MARKETING | 04dc1e6d-e865-45e2-b306-9d9dabe41e3d |
| FORMACIÓN | 53d02eea-43f1-4101-b505-29a938da581e |
| ESTRATEGIA | 275e9d12-d1d4-4514-9251-e904f20e19c4 |

### ÉPICAS
| Nombre | ID |
|---|---|
| 00. BRAND AWARENESS | 76a03f3b-a706-4e13-9069-7cb48605004f |
| 01. DESCUBRIMIENTO | b30d21f9-6a42-4624-9b04-2edc01597793 |
| 02. INVESTIGACIÓN | 69b75ed5-fcc4-4f88-b43a-3ee68d9928bc |
| 03. CONSIDERACIÓN | 0c3e943e-525b-4ef8-98fd-fcc643bf6bc6 |
| 04. CONVERSION | 41512e45-494a-4337-b41b-1138eb543fb2 |
| 05. ADOPTION | 70bb9189-873a-4481-b8bf-3cf0e99c399f |
| 06. REPETITION | db7f50ec-592b-4c05-9d75-7e662a3627d2 |
| 07. EXPANSION | de9a38bb-03fe-4c0b-ba14-7c5f57d95578 |
| 08. ADVOCACY | 0ed66cff-e1ab-48ec-9402-d41a0b1c8e11 |
| FORMACIÓN | a25f454d-b805-4cda-9feb-482c6a912e5e |
| PLANIFICACIÓN | 574b22cf-6754-475f-af40-17ac9f03944b |

---

## IDs DE LISTAS CONOCIDAS EN CLICKUP

| Cliente | Lista ID |
|---|---|
| General TI-MEDI (referencia web) | 900800044926 |
| General Carritech | 901207893908 |
| General Reinnova (plantillas) | 48885324 |

---

## NOTAS IMPORTANTES

- **Preguntas secuenciales:** una a una, sin agrupar.
- **Estructura antes del detalle:** proponer Épicas/PBIs/Productos en Paso 3 y esperar aprobación antes de desarrollar productos.
- **PBIs de primer nivel:** criterio personal del PO — acordar en Paso 3.
- **Convención de nombres:** ver sección 2.13 "Convención del nombre de la tarjeta" en `formato-tarjeta-clickup-reinicia`. Resumen: el nombre describe el entregable en estado final (sustantivo o participio), no la acción. Test rápido: "Entregable: ___" debe sonar natural. Preferir nomenclatura de TI-MEDI sobre Reinnova cuando existan equivalentes. Ejemplos: Diseño → "Propuestas UI/UX Alta Fidelidad V1 [CLIENTE]"; Desarrollo → "Integración [Tecnología] V1 [CLIENTE]". SPIKEs son la excepción documentada (objeto de investigación con prefijo `[SPIKE]`).
- **Listas destino:** implementación nueva en `General [CLIENTE]`, soporte en `Soporte [CLIENTE]`, plan de proyecto en `Gestión [CLIENTE]`. Nunca mezclar.
- **SPIKEs:** se usan para cualquier necesidad de investigación previa (no solo conectores). Siempre antes del producto que implementa.
- **Validaciones:** `Validación Reinicia` y `Validación Cliente` al final de cada bloque. Pueden repetirse por rondas.
- **REFINADO:** siempre `false` al crear.
- **ORDEN:** no asignar al crear — recordatorio al PO para Sprint Planning.
- **TI-MEDI como referencia:** proyecto web más completo y reciente. Consultar subtareas y criterios de sus productos.
- **Soporte y mejoras evolutivas:** usar plantillas de Comercial > Zoho adaptadas a Web.
- **Analítica y SEO:** si hay estos perfiles, crear productos propios para ellos (no solo subtareas dentro de otros productos).
- **Entregables UI/UX:** los diseños de alta fidelidad se entregan como PDF o Figma, no en WordPress. La integración en la tecnología viene después.
- **Mejoras continuas:** si el PO activó la opción (Pregunta 7), buscar en fuentes oficiales y añadir bloque 💡 al final de cada producto. Citar siempre la fuente. El cliente decide si acepta cada propuesta.
- **Documentos en inglés:** si una plantilla está en inglés (ej. Template-Good-Practices-Guide-SEO), indicar al PO que debe traducirlo al español y convertirlo a Zoho Writer.
- **Checklist:** no disponible via MCP — siempre recordar al PO con criterios listos para copiar.
- **Carpetas inexistentes:** si `00. Información` o `01. Seguimiento` no existen en Workdrive, avisar al PO.
