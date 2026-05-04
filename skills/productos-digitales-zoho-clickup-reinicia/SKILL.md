---
name: productos-digitales-zoho-clickup-reinicia
description: Skill para crear productos digitales Zoho (Productos y SPIKEs) en ClickUp de forma asistida. Cubre el flujo completo desde la elicitacion con el PO hasta la creacion de tareas, subtareas y campos personalizados en ClickUp, incluyendo busqueda en Workdrive y proyectos similares.
triggers:
  - crea un producto
  - crea varios productos
  - organizar el backlog de Zoho
  - nuevo producto ClickUp
  - crea un SPIKE
  - quiero organizar el backlog de
---

# SKILL: Crear Productos Digitales Zoho en ClickUp — Reinicia

## Descripción
Esta skill permite a los Product Owners de Reinicia crear tareas de producto digital Zoho (Productos y SPIKEs) en ClickUp de forma asistida. Claude busca la información del proyecto en Workdrive, la web del cliente y LinkedIn, propone primero una **estructura completa de Épicas / PBIs de primer nivel / Productos** para validación del PO, y luego desarrolla el detalle de cada producto uno a uno antes de crearlo en ClickUp.

**Principio de mejora continua:** al redactar cada producto, Claude no se limita a copiar referencias existentes. Siempre enriquece el contenido con información de la propuesta, el Sprint Cero, los contenidos del cliente, las actas y las mejores prácticas de consultoría, implementación y adopción de Zoho. Las propuestas de mejora se plantean siempre — algunas serán aceptadas y otras rechazadas, pero deben estar sobre la mesa.

## Cuándo activar esta skill
Triggers: "crea un producto", "crea varios productos", "quiero organizar el backlog de Zoho de [CLIENTE]", "crea una tarea en ClickUp para", "nuevo producto [cliente]", "crea un SPIKE", o cuando el PO pida crear uno o varios productos digitales Zoho en ClickUp.

NO usar para: actas de reunión, tareas de gestión, tareas de soporte, microcampañas de marketing (skills separadas).

---

## PASO 1 — ELICITACIÓN: Preguntas una a una al PO

Claude hace las preguntas de forma **secuencial**. No lanzar todas de golpe — las respuestas de unas condicionan las siguientes.

### Pregunta 1: Cliente y estado del proyecto
"¿Para qué cliente es y qué tipo de trabajo de Zoho quieres organizar en ClickUp? ¿El proyecto es nuevo o ya está en curso?"

→ Según la respuesta, Claude determina qué fuentes buscar (ver Paso 2).

### Pregunta 2: Carpeta del proyecto en Workdrive
"¿Cuál es el ID de la carpeta raíz del proyecto en Proyectos Activos de Workdrive? Si no lo tienes a mano, puedo buscarlo yo con el nombre del cliente."

→ Claude busca con `ZohoWorkdrive_searchTeamFoldersFiles` si el PO no lo sabe.

### Pregunta 3: Lista en ClickUp
"¿Conoces el ID de la lista `General [CLIENTE]` en ClickUp? Si no, lo busco yo."

→ Claude busca con `clickup_search` o `clickup_get_list`.

### Pregunta 4: PO de Reinicia
"¿Quién es el Product Owner de Reinicia para este proyecto?"
(Opciones: ALVARO, NESTOR, ELENA, BORJA, ALEJANDRO, PATRICIA, MARTA, PABLO, OSCAR)

### Pregunta 5: Equipo asignado
"¿Qué personas del equipo de Reinicia van a trabajar en estos productos? Cuéntame quién se encarga de qué, producto a producto si lo sabes ya, o lo dejamos para cuando proponga la estructura."

→ Si el PO no lo sabe todavía, queda pendiente para el Paso 3 (al proponer la estructura, Claude pregunta asignado por producto).

### Pregunta 6: Amigos Reinicia
"¿Hay algún Amigo Reinicia (colaborador externo) que vaya a participar? ¿En qué productos en concreto?"

### Pregunta 7: Propuestas de mejora con fuentes oficiales
"Al redactar cada producto, puedo buscar en fuentes oficiales de Zoho (Zoho Learn, blog, YouTube, Marketplace...) e incluir propuestas de funcionalidades o mejoras relevantes para el proyecto, marcadas claramente como ideas fuera del alcance actual. ¿Quieres que lo haga? Y si tienes alguna fuente o módulo específico que te interese explorar, indícamelo."

→ Si el PO dice sí: Claude activa el modo mejoras para todos los productos de la sesión. Si aporta fuentes o áreas concretas, se priorizan. Si dice no: se omite el bloque 💡 en todos los productos.

---

## PASO 2 — BÚSQUEDA DE INFORMACIÓN

### Estructura estándar de carpetas — Proyectos Activos
Referencia canónica: "00. Cliente Ficticio" (`5yo4ga6064aeac57d4ec8aa6e100a06249b94`)

```
[CLIENTE] (carpeta raíz)
  ├── 00. Información                    ← SIEMPRE DEBE EXISTIR
  │     ├── Administración               (contratos, facturas)
  │     ├── Comercial                    ← PROPUESTA COMERCIAL aquí
  │     ├── Empresa                      ← SPRINT CERO aquí (PDF) + info cliente
  │     ├── Credenciales Cliente
  │     └── Recursos gráficos
  ├── 01. Seguimiento                    ← SIEMPRE DEBE EXISTIR / ACTAS aquí
  ├── CRM - Zoho
  │     └── 03. Consultoría             ← docs consultoría del proyecto Zoho
  └── [Otras carpetas según servicios contratados]
```

Si `00. Información` o `01. Seguimiento` no existen, avisar al PO — hay que crearlas siguiendo la estructura de "00. Cliente Ficticio".

### IDs Carritech (ejemplo de referencia actualizado)
```
Carritech (raíz):      5iy7l53545d05aa664589b810dad41e9c5f90
  00. Información:     5iy7lcd5ad2ad240e4feaa4dc17e5d2837427
    Comercial:         5iy7l4f1980c9605b4999b8879e84f8c61f52  ← Propuesta Comercial
    Empresa:           5iy7ld822f32ca572492294957cf71763517d   ← Sprint Cero
    Administración:    5iy7l2890c81ff38f4055a0620821499ac51d
    Credenciales:      5iy7l7ee0cf8b820c40a0a228e220a1ad3579
    Recursos gráficos: 5iy7l25ca37a43b0c4d89bdb66e5648b39f07
  01. Seguimiento:     6uek57e2252af6b0a4d4690bdc6f6f4f7a617   ← Actas reuniones
  CRM - Zoho:          5iy7l404a1851290c4a0b863c8f10e69af5a6
    03. Consultoría:   [buscar dentro de CRM - Zoho]
```

### Orden de búsqueda según tipo de proyecto

**Proyecto NUEVO** (prioridad decreciente):
1. `00. Información > Empresa` → Sprint Cero (PDF). **Prevalece** si existe — tiene el alcance mejor acotado. Ojo: puede contener enlace a pedido en Zoho Books — anotarlo.
2. `00. Información > Comercial` → Propuesta Comercial aceptada (PDF).
3. `01. Seguimiento` → actas de reuniones de fase comercial y arranque.
4. Web del cliente + LinkedIn de personas clave.
5. ClickUp → buscar proyectos **similares** (mismo tipo de producto Zoho, mismo sector, similar alcance) en otras listas `General [OTRO CLIENTE]` para inspirar la estructura de productos y reutilizar conocimiento previo. Usar `clickup_search` con keywords del tipo de trabajo (ej. "Conector Zoho CRM", "Consultoría Prototipo", "Entrevistas Personas"). Proponer al PO qué referencias se han encontrado y qué se puede aprovechar.

**Proyecto EN CURSO** (prioridad decreciente):
1. `00. Información > Empresa` → Sprint Cero (si existe, prevalece).
2. `00. Información > Comercial` → Propuesta Comercial.
3. `01. Seguimiento` → actas recientes (las más recientes para contexto actual).
4. ClickUp → tareas existentes en `General [CLIENTE]` para entender qué ya está hecho y en qué estado (`clickup_filter_tasks`).
5. ClickUp → buscar proyectos **similares** en otros clientes para reutilizar conocimiento y estructura de productos ya validados.
6. Web del cliente + LinkedIn.

**Principio general:** siempre que sea posible, aprovechar experiencias anteriores de todo lo que hay en ClickUp — tanto para proponer la estructura como para el contenido de los productos (subtareas, criterios, entregables).

### Herramientas de búsqueda en Workdrive
- `ZohoWorkdrive_searchTeamFoldersFiles` — buscar carpeta raíz por nombre de cliente
- `ZohoWorkdrive_getFolderFiles` — listar contenido de subcarpetas
- `ZohoWorkdrive_downloadWorkDriveFile` — leer PDFs (Propuesta, Sprint Cero)

---

## PASO 3 — PROPUESTA DE ESTRUCTURA: ÉPICAS / PBIs / PRODUCTOS

Antes de entrar al detalle de cada producto, Claude presenta una propuesta de **arquitectura del backlog** para validación del PO. No crear nada hasta que el PO apruebe esta estructura.

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

**Notas:**
- **Protocolo Hoja de Ruta Zoho CRM como referencia principal:** la secuencia estándar de un proyecto Zoho CRM es: Planificación → Análisis Inicial (Requerimientos + Entrevistas) → Consultoría Preliminar → Consultoría Definitiva → Prototipo / Implementación → Formación. Claude debe seguir esta secuencia para proponer la estructura de épicas y productos, consultando el Protocolo (`3fa50ac0fed1d5b064a588ec5c0c24095f793`) si necesita detalle sobre qué documentos y entregables corresponden a cada paso.
- **Norma de tamaño de producto:** cada producto debe ser **digerible en 1-2 sprints máximo (3 semanas cada uno)**. No crear productos que arrastren trabajo indefinidamente entre sprints sin hitos claros. Esto implica, por ejemplo, separar siempre la Consultoría Preliminar y la Consultoría Definitiva en dos productos distintos, y cada Prototipo de implementación en su propio producto.
- **Connectores:** para todo conector (Business Central, Brokerbin, LinkedIn, etc.) siempre habrá primero un SPIKE antes del producto de implementación. Los SPIKEs se hacen durante la fase de Consultoría, no en Implementación.
- Las épicas se proponen en base al contexto (opciones del dropdown: 00. BRAND AWARENESS, 01. DESCUBRIMIENTO, 02. INVESTIGACIÓN, 03. CONSIDERACIÓN, 04. CONVERSION, 05. ADOPTION, 06. REPETITION, 07. EXPANSION, 08. ADVOCACY, FORMACIÓN, PLANIFICACIÓN). Para proyectos Zoho en fase inicial, lo habitual es PLANIFICACIÓN (arranque) y 02. INVESTIGACIÓN (consultoría).
- Los PBIs de primer nivel se acuerdan con el PO aquí — es su criterio personal como PO (ej. "Consultoría Zoho" puede agrupar Entrevistas + Consultoría Preliminar + Consultoría Definitiva).

---

## PASO 4 — DETALLE DE CADA PRODUCTO (uno a uno)

Aprobada la estructura, Claude desarrolla el contenido de cada producto **de uno en uno**, presentándolo para revisión antes de pasar al siguiente.

### 4.1 Patrón visual de la tarjeta

**El formato canónico de la descripción de la tarjeta lo gobierna la skill `formato-tarjeta-clickup-reinicia`.** Esta skill (Zoho) NO replica el patrón — lo referencia. Aplican:

- Los **bloques fijos** del patrón canónico: RESUMEN, Historia de usuario, Descripción, Ready to Backlog, Contexto, Entregables, Documentación de referencia, Resultado y cierre.
- Los **bloques opcionales** que correspondan según el caso: Requerimientos Cliente (sólo si el producto nace de petición directa del cliente), Alcance (recomendable cuando hay riesgo de scope creep).
- El bloque "🏁 Resultado y cierre" se crea **siempre** con sus placeholders. Se rellenará al cierre del producto siguiendo el flujo formal de cierre (sección 11 de `formato-tarjeta-clickup-reinicia`).

### 4.2 Delegación a la skill de SPIKE

Cuando el producto a desarrollar es un **SPIKE** (su nombre lleva prefijo `[SPIKE]` y su naturaleza es de investigación, no de entrega), Claude **delega en la skill `spike-clickup-reinicia`** para producir el contenido específico del SPIKE (hipótesis, preguntas de investigación, alcance, subtareas de investigación, criterios de aceptación de SPIKE, generación opcional del documento de Diseño Funcional al cierre).

Esta skill (Zoho) **conserva**:
- El contexto del proyecto (cliente, lista, PO, equipo, Amigos Reinicia, Épica, PBI de primer nivel)
- La ejecución de las llamadas a la API de ClickUp en el Paso 5
- La continuación del flujo con el siguiente producto del backlog

La skill `spike-clickup-reinicia` se ocupa **solo** del contenido propio del SPIKE.

### 4.3 Fuentes para el contenido de productos NO-SPIKE

Para proponer subtareas, criterios y entregables de productos de implementación / consultoría / formación (no-SPIKE), Claude consulta en este orden:

1. **El Protocolo Hoja de Ruta Zoho CRM** (`3fa50ac0fed1d5b064a588ec5c0c24095f793`) para identificar qué documentos y entregables internos de Reinicia y de Cliente corresponden a cada tipo de producto.
2. **La plantilla [PLANTILLA] de Reinnova** más similar al tipo de producto (ver tabla de plantillas) para las subtareas y criterios de aceptación estándar.
3. **Proyectos similares en ClickUp** para reutilizar experiencia previa.
4. **La propuesta comercial, el Sprint Cero y las actas** del proyecto — para enriquecer el contenido con el contexto real del cliente.
5. **Búsqueda de mejoras en fuentes oficiales** (solo si el PO lo ha confirmado en Pregunta 7): Claude realiza búsquedas en Zoho Learn (`learn.zoho.com`), el blog de Zoho (`zoho.com/blog`), YouTube (`youtube.com/@ZohoCRM` y canales de producto) y el Marketplace (`marketplace.zoho.com`) para encontrar funcionalidades, integraciones o casos de uso relevantes para este producto concreto. Si el PO indicó fuentes específicas, se consultan primero.

**Formato del bloque de mejoras** (se añade al final del producto, después de los criterios de aceptación, solo si el PO activó la opción):

```
💡 PROPUESTAS DE MEJORA — [NOMBRE PRODUCTO]

Estas ideas están FUERA del alcance actual del producto. Se presentan como oportunidades
a valorar con el cliente en futuras iteraciones o como ampliación del alcance.

  💡 [Título de la mejora]
     Descripción breve de la funcionalidad o integración propuesta y por qué
     sería relevante para este cliente en concreto.
     Fuente: [URL o nombre del recurso consultado]
     Estado: Fuera de alcance — requiere valoración y presupuesto adicional

  💡 [Título de la mejora]
     ...
     Fuente: [URL]
     Estado: Fuera de alcance — requiere valoración y presupuesto adicional
```

### 4.4 Presentación del producto al PO

Tanto si Claude redactó el producto directamente (no-SPIKE) como si lo redactó la skill `spike-clickup-reinicia` (SPIKE), Claude presenta al PO la propuesta completa antes de crear nada en ClickUp. La presentación sigue el patrón canónico de la skill `formato-tarjeta-clickup-reinicia` (sección 2 — Estructura canónica de la descripción), con los siguientes apartados como bloque resumen para validación:

- Nombre de la tarea
- Resumen de cada bloque que aplica (los marcados como fijos siempre, los opcionales según corresponda)
- Subtareas propuestas
- Criterios de aceptación (preparados para el comentario que se publicará en ClickUp tras crear la tarjeta — ver Paso 5)
- Campos personalizados y sus valores
- Tiempo estimado (si el PO lo conoce)

```
¿Apruebas este producto tal como está? ¿Modificas algo antes de crearlo?
```

---

## PASO 5 — CREACIÓN EN CLICKUP

Una vez aprobado cada producto por el PO, Claude lo crea siguiendo el patrón canónico de `formato-tarjeta-clickup-reinicia`.

### 5.1 Tarea principal
`clickup_create_task` → `list_id`, `name`, `markdown_description` (con la estructura de bloques del patrón canónico aplicada — sección 2 de `formato-tarjeta-clickup-reinicia`), `assignees`, `time_estimate` (ms = horas × 3.600.000), `tags`.

Para SPIKEs, añadir tag `spike` además del tag específico del tipo (`zoho crm`, etc.).

### 5.2 Subtareas
`clickup_create_task` para cada subtarea con `parent`: ID de la tarea principal. Las subtareas se crean **sin asignar** — la asignación se decide en el Paso 5.6 con el PO.

### 5.3 Campos personalizados
`clickup_update_task` con `custom_fields`:

```
PROYECTO:          a0020a79-1794-4539-8db5-19ca810a317c
TIPO DE PRODUCTO:  5bd9072e-deae-4352-b35b-bdbaa3cc216d
PO:                14d40a06-639f-4ad3-a241-aa66df2fcf23
ÉPICA:             6e3bf4c0-354b-4a8c-8cb5-dbedeec1cf6e
ORDEN:             a2fac0a6-0f12-4c9b-9f2f-c5bbc2aa7a98
REFINADO:          998657ca-d6e1-4880-966a-34a431195d12
PBIs PRIMER NIVEL: 6758065a-bd4f-4d7d-9a48-926e81fe343f
AMIGOS REINICIA:   aab85ad0-1d1f-43f4-b41d-c8593aa2c4ac
```

Nota: IDs de la lista General Carritech. Verificar con `clickup_get_custom_fields` si el cliente tiene lista diferente.

### 5.4 Comentario de criterios de aceptación
`clickup_create_task_comment` con los criterios de aceptación en formato texto plano (Caso A de la sección 6.2 de `formato-tarjeta-clickup-reinicia`):

```
CRITERIOS DE ACEPTACIÓN — para copiar manualmente al checklist

[Técnicos] Criterio 1
[Técnicos] Criterio 2
[Funcionales] Criterio 3
[De proceso] Criterio 4
```

Sin markdown. Una línea por criterio. Categoría entre corchetes como prefijo.

### 5.5 Checklist
⚠️ No disponible vía MCP. El PO debe copiar manualmente los criterios del comentario del Paso 5.4 al checklist "CRITERIOS DE ACEPTACIÓN".

### 5.6 Pregunta sobre asignación de subtareas
**Importante:** Claude **nunca asigna subtareas sin confirmación explícita del PO**. Tras crear todas las subtareas, Claude pregunta:

```
He creado [N] subtareas sin asignar. ¿Cómo prefieres asignarlas?

a) Todas al mismo equipo / persona — me dices a quién.
b) Distribución por bloque (yo te propongo, tú apruebas).
c) Subtarea por subtarea — me indicas cada una.
d) Las asignas tú directamente desde ClickUp.
```

Según la respuesta del PO, Claude ejecuta `clickup_update_task` sobre cada subtarea con los `assignees` correspondientes, o deja la asignación al PO si elige la opción d).

### 5.7 Cierre formal del producto

El producto queda creado con su bloque "🏁 Resultado y cierre" placeholder. Cuando el producto se complete operativamente, el PO volverá a Claude para ejecutar el **flujo formal de cierre** definido en la sección 11 de `formato-tarjeta-clickup-reinicia` (o, si es un SPIKE, definido en la sección 7 de `spike-clickup-reinicia` que extiende el flujo canónico con la generación opcional del documento de Diseño Funcional).

---

## PASO 6 — CONFIRMACIÓN FINAL

Al terminar todos los productos:

```
✅ Productos creados en ClickUp — [CLIENTE]
[Lista de productos con URLs]

⚠️ Pendiente de completar manualmente por el PO:
  - Checklist "CRITERIOS DE ACEPTACIÓN" en cada producto (copiar desde el comentario que ha publicado Claude)
  - Campo ORDEN → asignar en el próximo Sprint Planning
  - Marcar REFINADO = true cuando cada producto esté listo para el sprint
  - [Si aplica] Asignaciones de subtareas si el PO eligió la opción d) en el Paso 5.6
```

---

## PLANTILLAS [PLANTILLA] DE REFERENCIA — REINNOVA (lista `48885324`)

| Tipo de producto | ID |
|---|---|
| Requerimientos Técnicos y Funcionales | `865c0mffr` |
| Entrevistas Personas Cliente | `865bz8gzq` |
| Consultoría Prototipo | `865bz8gu2` |
| Entrega Final | `865bz9538` |
| Conector Zoho CRM y Otra Plataforma | `865c0mt5z` |
| [SPIKE] Conector Zoho CRM y Otra Plataforma | `865c0mt57` |
| Cuadro de mandos Zoho CRM | `865c0ndn8` |
| Conector Zoho CRM y Zoho Campaigns | `865c37093` |
| Conector Zoho CRM y Zoho Survey | `865c3707d` |
| Zoho Campaigns: Optimización y Plantilla | `865c0mtbw` |
| Plantilla genérica producto Reinnova | `8697jhwd1` |

Consultar con `clickup_get_task` para revisar subtareas/criterios estándar de cada tipo.

---

## PLANTILLAS DE ENTREGABLES — RECURSOS COMUNES WORKDRIVE

```
Recursos Comunes Reinicia: 6y4l6e0b8c445ef5c4d8b825374831009c9ad
  └── Plantillas Reinicia:  68xkj415360a2ef2547c68c2e21e08b3ccb3a
      └── Zoho:             a0lrk23ed4c626274440d8eee913154c4da3d
          └── Zoho CRM:     awerf29aac7ecbcf640a4bfec1752a6e3ed05
              ├── Plantillas (18): b4i024a6b9aa39f5842859e8d4e5b377b8688 ← entregables
              ├── Ejemplos (15):   b4i02c535e6ded753489fa0c2246276e89e31
              └── Protocolo Hoja de Ruta Zoho CRM (Writer): 3fa50ac0fed1d5b064a588ec5c0c24095f793
```

Usar `ZohoWorkdrive_getFolderFiles` en la carpeta `Plantillas` para encontrar plantillas específicas.

**Documentación de referencia:** enlazar siempre la versión **pública** del Sprint Cero (accesible para Amigos Reinicia y equipo cliente), no la versión con presupuestos.

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

### TIPO DE PRODUCTO
| Nombre | ID |
|---|---|
| CRM | 814e9896-f224-458f-afef-3aaa1506ce5b |
| DESARROLLO WEB | c0fd12ed-112f-4150-aa70-0268e8de3ac5 |
| GESTIÓN CRM | f100a89f-cdf8-408e-a10a-1f1584255c2b |
| EMAIL MARKETING | 04dc1e6d-e865-45e2-b306-9d9dabe41e3d |
| MARKETING AUTOMÁTICO | ac796e2a-c2bb-408c-b9e3-4ec975648653 |
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
| PLANIFICACIÓN | 574b22cf-6754-475f-af40-17ac9f03994b |

---

## IDs DE LISTAS CONOCIDAS EN CLICKUP

| Cliente | Lista ID |
|---|---|
| General Carritech | 901207893908 |
| General Reinnova | 48885324 |

---

## NOTAS IMPORTANTES

- **Patrón canónico de tarjeta:** la descripción de cada producto sigue **siempre** el patrón canónico de la skill `formato-tarjeta-clickup-reinicia`. Esta skill (Zoho) NO replica el patrón — lo referencia.
- **SPIKEs delegados:** cuando un producto del backlog es un SPIKE, su contenido específico (hipótesis, preguntas, alcance, subtareas de investigación, criterios) lo redacta la skill `spike-clickup-reinicia`. Esta skill (Zoho) sigue ejecutando la creación en ClickUp y la continuidad del flujo.
- **Asignación de subtareas:** **Claude nunca asigna subtareas sin confirmación explícita del PO**. La pregunta canónica está en el Paso 5.6.
- **Cierre formal:** todo producto se cierra invocando el flujo formal de cierre (sección 11 de `formato-tarjeta-clickup-reinicia`), o la sección 7 de `spike-clickup-reinicia` si es SPIKE.
- **Preguntas secuenciales:** una a una, sin agrupar.
- **Estructura antes del detalle:** proponer Épicas/PBIs/Productos en Paso 3 y esperar aprobación antes de desarrollar productos.
- **PBIs de primer nivel:** acordar con el PO en Paso 3, criterio personal del PO.
- **Convención de nombres:** ver sección 2.13 "Convención del nombre de la tarjeta" en `formato-tarjeta-clickup-reinicia`. Resumen: el nombre describe el entregable en estado final (sustantivo o participio), no la acción. Test rápido: "Entregable: ___" debe sonar natural; "Tarea: ___" indica que está en modo acción y hay que reformular. SPIKEs son la excepción documentada (objeto de investigación con prefijo `[SPIKE]`).
- **Lista destino:** siempre `General [CLIENTE]`. Nunca Gestión ni Soporte.
- **Validaciones:** `Validación Reinicia` y `Validación Cliente` al final de cada bloque. Pueden repetirse si hay iteraciones.
- **REFINADO:** siempre `false` al crear.
- **ORDEN:** no asignar al crear — recordatorio al PO para Sprint Planning.
- **Asignaciones por producto (assignees del producto, no de subtareas):** preguntar al PO quién del equipo se encarga de qué producto concreto. Si no lo sabe en el Paso 1, preguntar producto a producto al presentar la estructura en el Paso 3.
- **Amigos Reinicia:** preguntar en qué productos concretos participan (Paso 1, Pregunta 6).
- **Reutilizar conocimiento:** buscar siempre proyectos similares en ClickUp (sea proyecto nuevo o en curso) para aprovechar estructuras y contenidos ya validados en otros clientes.
- **Checklist:** no disponible via MCP — Claude pega un comentario con los criterios listos para copiar (Paso 5.4).
- **Sprint Cero en referencias:** enlazar versión pública únicamente (sin presupuesto). Si hay pedido Zoho Books enlazado en el Sprint Cero, anotarlo internamente.
- **Entregables:** enlazar siempre las plantillas de Recursos Comunes Workdrive.
- **Carpetas inexistentes:** si `00. Información` o `01. Seguimiento` no existen, avisar al PO.
