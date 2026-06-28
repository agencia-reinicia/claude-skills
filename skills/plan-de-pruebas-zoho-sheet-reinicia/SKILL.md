---
name: plan-de-pruebas-zoho-sheet-reinicia
description: >
  Crea Planes de Pruebas Funcionales en Zoho Sheet para proyectos Zoho CRM
  de Reinicia. Peina TRES fuentes de scope (Diseño Funcional si se aporta + Contenido
  completo de la tarjeta ClickUp del producto y relacionadas — descripción, criterios,
  subtareas, comentarios, adjuntos — + Elicitación al PO), detecta gaps en el DF,
  propone cobertura validada ajustada al perfil (rápida/estándar/exhaustiva), copia la
  plantilla canónica en Workdrive, escribe las pruebas con trazabilidad al origen, crea
  pestañas de capturas, comenta en la tarjeta del producto en ClickUp e imputa tiempo
  al responsable.

  Actívala cuando el PO pida "crea el plan de pruebas para [CLIENTE]", "plan de pruebas
  funcional de [DESARROLLO]", "casos de uso para validar SANDBOX", "test plan", o cuando
  se adjunte un Diseño Funcional y se mencione "pruebas", "validación funcional", "QA"
  o "SANDBOX". No usar para crear productos en ClickUp, actas, diagramas, ni pruebas Web
  o WhatsApp (extensiones futuras documentadas al final).
---

# SKILL: Plan de Pruebas Funcionales Zoho en Zoho Sheet — Reinicia

> **Versión vigente: v2.0 — 21/06/2026** · ver changelog al final (`## Versiones`)

## Propósito

Crear y mantener el documento de **Plan de Pruebas Funcionales** de un desarrollo Zoho CRM en Zoho Sheet, siguiendo la plantilla canónica de Reinicia. El Plan de Pruebas es el contrato funcional entre Reinicia y el cliente sobre qué se va a validar en SANDBOX antes de pasar a PRO. Cubre la trazabilidad bidireccional con todas las fuentes de scope (DF + contenido completo de la tarjeta ClickUp + conocimiento del PO) y permite registrar resultados, estados de revisión y enlaces a evidencias (capturas, vídeos).

**Principio rector:** el scope real de un desarrollo NO está solo en el Diseño Funcional. Vive también en **todo el contenido del producto en ClickUp** — descripción, criterios de aceptación, subtareas, comentarios, respuestas anidadas, adjuntos — y en el conocimiento del PO que aún no ha sido escrito en ningún sitio. La skill peina las **tres fuentes** y consolida la cobertura, además de detectar gaps en el DF para sugerir su actualización.

## Plantilla canónica

| Recurso | ID Workdrive |
|---|---|
| Plantilla Plan de Pruebas Reinicia (Zoho Sheet) | `b6g99e39964d2bbbe4173a46f3a80f0b8c905` |
| Ejemplo validado: Breezom (multilanguage, 6 pruebas) | `b2vmkae4b177965a34d62be0c0de9c54c3290` |
| Ejemplo validado: Psicomagister LATAM (16 pruebas, 6 bloques) | `pdobndfda0fe579894dfca00844cfae753ce8` |

La plantilla viene con 4 hojas: `Portada`, `Pruebas` (con 2 ejemplos a borrar), `Capturas PRUEBA-01`, `Capturas PRUEBA-02`.

---

## PASO 1 — ELICITACIÓN

Preguntas secuenciales (una por turno hasta tener respuesta). NO lanzar todas de golpe.

### Pregunta 1: Cliente y desarrollo
"¿Para qué cliente y qué desarrollo concreto es el Plan de Pruebas? ¿Tienes el Diseño Funcional ya redactado, o lo construimos por elicitación?"

→ Determina si entra por **modo DF** o **modo elicitación pura**.

### Pregunta 2: Producto en ClickUp
"¿Cuál es la tarjeta del producto en ClickUp (URL o ID)? ¿Hay subtarea específica de Plan de Pruebas dentro de ese producto? ¿Hay tarjetas relacionadas (otros productos o SPIKEs) que aporten contexto?"

→ Localiza:
- **Tarjeta del producto principal** (destino del comentario final con enlace y resumen, y fuente principal a peinar)
- **Subtarea de Plan de Pruebas** si existe (a marcar como `Doing` / `Validación Reinicia` / `Validación Cliente` / `Done` según indique el PO al cierre)
- **Tarjetas relacionadas** para peinar también su contenido (SPIKE de origen, productos previos, etc.)

⚠️ **Importante:** la skill leerá en el PASO 2 **todo el contenido** de estas tarjetas (descripción, criterios de aceptación, subtareas, comentarios + respuestas anidadas, adjuntos) para detectar funcionalidad mencionada pero no escrita en el Diseño Funcional. Por eso esta pregunta va antes de iniciar el análisis.

### Pregunta 3: Responsable y tipo de proyecto
"¿Quién es el responsable de preparar el Plan de Pruebas (será el assignee al que imputo el tiempo de análisis y diseño)? ¿Es proyecto Zoho CRM, Web, WABA, Email Marketing u otro?"

→ Determina la carpeta destino en Workdrive (ver PASO 4) y el usuario a quien imputar.

Aceptados: PO Técnico (Paolo, Fabián), PO Cliente, cualquier persona del Equipo Operativo. **No asumir que es siempre PO Técnico.**

### Pregunta 4: Entorno
"¿Qué entornos cubre el Plan? Lo habitual mínimo es DES y PRO, pero puede incluir PRE."
Opciones: `DES`, `DES + PRO`, `DES + PRE + PRO`, otro.

→ Si solo es uno, Claude rellena la Columna B (Entorno) con ese valor en todas las pruebas. Si son varios, divide pruebas por entorno (etiqueta en Col B) o crea filas separadas según indique el PO.

### Pregunta 5: Profundidad esperada del Plan
"¿Qué profundidad esperas para este Plan? Lo ajustamos al alcance del desarrollo:
- **Rápida** (4-8 pruebas): desarrollos pequeños, ajustes puntuales, single feature
- **Estándar** (10-20 pruebas): desarrollos medios, varias funcionalidades, integraciones simples
- **Exhaustiva** (20+ pruebas): desarrollos amplios con multi-región, multi-módulo, integraciones críticas y backfill histórico

Esta cifra es orientativa — me ajusto a lo que el alcance real exija, pero me ayuda a no quedarme corto ni hincharlo innecesariamente."

→ Calibra la propuesta de cobertura del PASO 3. Ejemplos de referencia:
- Breezom (formularios multi-idioma): 6 pruebas — perfil **Rápida**
- Psicomagister LATAM (multi-región, multi-módulo, backfill, conversión moneda): 16 pruebas — perfil **Estándar/Exhaustiva**

### Pregunta 6: Datos de prueba
"¿Quieres usar datos reales para las pruebas, o solo placeholders y datos sintéticos?
- **Reales**: dame ejemplos concretos. Por ejemplo: emails específicos de testing (`pruebas@empresa.com`), URLs de cursos/productos ya publicados, IDs reales de testing, etc.
- **Sintéticos**: yo generaré nombres realistas pero ficticios (`carlos.test03@ejemplo-pruebas.mx`) y placeholders en formato `{ORDER_ID_TEST_NN}`, `{URL_PRUEBA_NN}` para lo que prefieras dejar abierto."

**Reglas obligatorias de datos** (Claude las aplica sin excepción):
- NUNCA usar PII real de clientes/contactos en producción (ni en `billing.email`, `first_name`, teléfonos, direcciones reales dentro de payloads JSON ni en ningún otro campo)
- NUNCA incluir credenciales, tokens, contraseñas, claves API, tokens OAuth en los pasos
- SÍ usar emails de testing del equipo o sintéticos
- SÍ usar URLs reales de productos/cursos públicos cuando aporten claridad
- Placeholders sin sustituir → siempre en formato `{VAR_NN}` para que sean fácilmente reemplazables
- ⚠️ **Revisión obligatoria de payloads JSON antes de escribir cada prueba:** si un payload incluye `billing`, `customer`, `email`, `phone`, o cualquier campo personal, verificar que los valores son sintéticos (`carlos.test03@ejemplo-pruebas.mx`) o claramente identificables como testing (`pruebas+abc@empresa.com`). Si hay duda → sintético por defecto, advertir al responsable.

---

## PASO 2 — ANÁLISIS DE FUENTES DE SCOPE

La skill peina **tres fuentes** para construir la cobertura. Ninguna es opcional excepto el DF.

### Fuente 1 — Diseño Funcional (si se aporta)

Si el PO aporta un DF:

1. **Leer el documento completo** (no por trozos):
   - Si es `.docx` Zoho Writer nativo: `ZohoWriter_Get_Document_Details` para metadatos + lectura del cuerpo
   - Si es `.docx` ofimático: lectura por el sistema de documentos en contexto
   - Si es subido directamente: leer desde `/mnt/user-data/uploads/`

2. **Identificar las secciones clave** y guardar mapeo `sección DF → tema funcional`:
   - Alcance y objetivos del desarrollo
   - Modelo de datos: campos nuevos, modificados, eliminados
   - Lógica funcional: flujos, workflows, blueprints, funciones Deluge
   - Integraciones afectadas (Books, Campaigns, Flow, otros)
   - Sección de tests/pruebas SANDBOX si el DF la tiene (sección 8 en DFs estándar de Reinicia)

### Fuente 2 — Contenido completo de la tarjeta ClickUp (SIEMPRE, haya DF o no)

⚠️ **Crítico:** una tarjeta de producto en ClickUp es la representación viva del desarrollo. El scope real **no está solo en los comentarios** — está distribuido entre descripción, criterios de aceptación, subtareas, comentarios, respuestas anidadas y adjuntos. Si solo se peinan los comentarios y no el resto, queda fuera funcionalidad que aparecerá como falso bug en SANDBOX.

Para la tarjeta del producto principal y para las tarjetas relacionadas indicadas por el PO en la Pregunta 2, leer **todos** los apartados siguientes:

#### 2.1 Descripción de la tarjeta
Con `clickup_get_task` (atributo `description` o `text_content`). Aplicando el formato canónico Reinicia (skill `formato-tarjeta-clickup-reinicia`), la descripción suele contener bloques estructurados:
- **Historia de usuario**: define el "Como [rol], QUIERO [qué], PARA [para qué]" — clave para entender la intención de negocio
- **Descripción / Alcance**: límites del producto, web/dominio, objetivo cliente
- **Ready to Backlog**: prerrequisitos técnicos y funcionales que pueden generar pruebas de precondición
- **Entregables al Cliente**: lo que se compromete entregar — cada entregable es candidato a prueba de validación
- **Equipo Reinicia**: quién hace qué (útil para asignación de pruebas)
- **Documentación de referencia**: enlaces a Sprint Cero, Propuesta Comercial, actas — fuentes secundarias a peinar si aportan claridad funcional
- **Observaciones**: notas del PO que pueden contener restricciones, decisiones de diseño, edge cases

#### 2.2 Criterios de aceptación
Con `clickup_get_task` (atributo `checklists` o ítems del checklist `CRITERIOS DE ACEPTACIÓN`). **Cada criterio de aceptación es literalmente un requisito verificable** y debe traducirse a una o varias pruebas. Convención Reinicia: criterios categorizados como `[Técnicos]`, `[Funcionales]`, `[De proceso]`.

Si un criterio no se puede mapear a ninguna prueba propuesta → revisar si está cubierto en otra prueba o añadir prueba específica.

#### 2.3 Subtareas
Con `clickup_get_task` (atributo `subtasks`) o `clickup_filter_tasks` con `parent` = id del producto. Las subtareas reflejan el **desglose real del trabajo ejecutado**. Para cada subtarea relevante:
- Leer su nombre y descripción (puede tener detalle adicional al producto padre)
- Leer sus comentarios si los tiene
- Detectar subtareas que sean "trabajo derivado no contractado" — gap potencial del DF

#### 2.4 Comentarios y respuestas anidadas
1. Leer comentarios con `clickup_get_task_comments` (paginar si hay muchos).
2. Leer respuestas anidadas con `clickup_get_threaded_comments` sobre los comment_ids relevantes. ⚠️ Lección aprendida: información crítica suele estar en las respuestas anidadas, no en los comentarios principales.

#### 2.5 Adjuntos
Con `clickup_get_task` (atributo `attachments`). Listar todos los adjuntos y considerar leer (si son `.png`, `.pdf`, `.docx`, `.xlsx` razonables): wireframes, capturas, esquemas, payloads de ejemplo. Si hay adjuntos pesados o muchos, listarlos al PO y preguntar cuáles vale la pena consultar.

#### 2.6 Clasificación e interpretación

Por cada elemento encontrado (independientemente del apartado de origen), clasificar:
- **Requisito funcional explícito**: descripción, criterio de aceptación, entregable comprometido → genera prueba obligatoria
- **Aclaración de cliente** (en comentarios): explica cómo debe comportarse algo concreto → posible prueba
- **Decisión técnica del equipo**: cómo se ha resuelto algo → posible prueba o criterio
- **Bug detectado + corregido**: posible prueba de no-regresión
- **Ampliación de alcance verbal**: scope no contractado pero acordado → posible prueba + gap del DF
- **Restricción / observación** del PO: precondición o exclusión → afecta a precondiciones o cobertura
- **Conversación operativa** (planning, gestiones): ignorar

#### 2.7 Tabla preliminar de fuentes → temas funcionales

Tras peinar todos los apartados, construir una tabla consolidada:

| Fuente | Detalle | Tema funcional | ¿Está en DF? |
|---|---|---|---|
| DF §4 | Campo Region_Origen en 4 módulos | Modelo de datos multi-región | ✅ |
| ClickUp Descripción - Entregables al Cliente | Set de vistas custom por región | Vistas multi-región | ✅ §6 |
| ClickUp Criterio de aceptación [Funcionales] | "Las personas de Reinicia ven en su Vault los accesos del proyecto" | Provisión de credenciales | ❌ — fuera de alcance Plan |
| ClickUp Subtarea "Backfill histórico" | Migración de Deals existentes con Region_Origen=EU | Backfill | ✅ §7 |
| Comentario ClickUp 2026-03-12 (Robin) | Si vienen 2 pedidos en el mismo mes del mismo email, no duplicar Contact | Deduplicación cross-month | ❌ — GAP DF |
| Adjunto wireframe-cabecera.png | Botón "Cambiar región" en cabecera CRM | Cambio manual de región | ❌ — GAP DF |

### Fuente 3 — Conocimiento del PO (elicitación)

Tras peinar las dos fuentes anteriores, preguntar al PO **bloque a bloque** sobre lo que cree que pueda faltar:

"He peinado el DF y todo el contenido de la tarjeta ClickUp (descripción, criterios de aceptación, subtareas, comentarios, adjuntos). Antes de proponerte la cobertura, una última ronda contigo para asegurar que no se nos escapa nada:

1. ¿Qué cambios hay en el modelo de datos que no estén ya cubiertos? (campos, constraints, validaciones)
2. ¿Hay algún flujo principal a probar que no haya aparecido aún?
3. ¿Hay lookups, asignaciones automáticas o búsquedas críticas que considerar?
4. ¿Hay segmentación multi-región / multi-marca / multi-canal?
5. ¿Hay vistas nuevas, owner rules, asignaciones de comercial?
6. ¿Qué hay que verificar de no-regresión? (Books, Campaigns, integraciones existentes)
7. ¿Hay algún edge case o escenario raro que sepas que ha dado problemas en el pasado en este cliente o desarrollos similares?"

Una pregunta por turno hasta cubrir todos los bloques aplicables. **Modo elicitación pura**: si no hay DF, ESTA fuente se convierte en la principal y las preguntas son las únicas que aportan scope.

### Consolidación y organización en bloques

Tras las tres fuentes, organizar el scope detectado en bloques temáticos:
- **Bloque A — Modelo de datos**: verificar campos creados, modificados, constraints
- **Bloque B — Flujo principal**: alta, edición, conversión de registros
- **Bloque C — Lookups y relaciones**: búsquedas, asignaciones automáticas
- **Bloque D — Multi-región / Multi-segmento** (si aplica)
- **Bloque E — Vistas y asignación**: custom views, owner rules
- **Bloque F — No-regresión**: comportamiento previo no roto, integraciones existentes

Los bloques sin contenido aplicable simplemente no aparecen — no forzar todos.

---

## PASO 3 — PROPUESTA DE COBERTURA Y VALIDACIÓN DEL PO

Antes de tocar Workdrive, Claude presenta la propuesta de cobertura completa para validación del PO. **No crear nada hasta aprobación explícita.**

```
📐 PROPUESTA DE COBERTURA — Plan de Pruebas [DESARROLLO] [CLIENTE]

Perfil solicitado: [Rápida / Estándar / Exhaustiva]
Entorno(s): [DES / DES+PRO / DES+PRE+PRO]
Datos: [sintéticos con placeholders / mezcla con datos reales: ...]
Total de pruebas propuestas: [N]  (ajustado al perfil; orientativo: Rápida 4-8, Estándar 10-20, Exhaustiva 20+)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔵 BLOQUE A — MODELO DE DATOS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PRUEBA-01: [título breve] — origen: DF §4
  PRUEBA-02: [título breve] — origen: ClickUp Comentario 2026-03-12 (Robin)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🟢 BLOQUE B — FLUJO PRINCIPAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PRUEBA-03: ... — origen: DF Test #1
  ...

[Resto de bloques...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚪ BLOQUE F — NO-REGRESIÓN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PRUEBA-N: ... — origen: aportación PO (edge case histórico)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 POSIBLES ACTUALIZACIONES AL DISEÑO FUNCIONAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
He detectado funcionalidad mencionada en la tarjeta ClickUp o aportada por ti, pero NO
escrita en el DF actual. Recomiendo al autor del DF (Fabián/Paolo) revisarlo y
decidir si actualizar el documento:

1. [Funcionalidad / regla de negocio] — origen: [ClickUp Descripción / Criterio / Subtarea / Comentario / Adjunto / Aportación PO]
   → Cubierta en este Plan por PRUEBA-NN
   → Sugerencia: añadir al DF §X
2. ...

¿Validas esta cobertura, ajustamos algo o añades/quitas pruebas?
¿Quieres que las "Posibles actualizaciones al DF" queden también listadas en el
comentario final de ClickUp para que el autor del DF las revise?
Cuando confirmes, copio la plantilla y escribo las pruebas.
```

**Notas:**
- Cada PRUEBA-NN debe tener un título corto y descriptivo (la columna C `Acción` del Sheet)
- Cada prueba lleva trazabilidad inline al origen: `DF §X`, `DF Test #N`, `ClickUp Descripción`, `ClickUp Criterio aceptación [tipo]`, `ClickUp Subtarea [nombre]`, `ClickUp Adjunto [nombre]`, `ClickUp Comentario DD/MM/YYYY (autor)`, `Aportación PO`
- Si el DF tiene tests explícitos (sección 8), mapear cada uno a una PRUEBA-NN y completarlo con pruebas adicionales que identifique Claude (typing strict, edge cases, no-regresión)
- Los bloques sin contenido aplicable simplemente no aparecen — no forzar todos los bloques
- La sección **📝 Posibles actualizaciones al DF** SOLO aparece si se ha encontrado funcionalidad fuera del DF. Si todo está cubierto en el DF, omitir la sección.

---

## PASO 4 — LOCALIZACIÓN DE LA CARPETA DESTINO

Claude propone la carpeta destino y **confirma con el PO** antes de copiar.

### Estructura canónica Reinicia por tipo de proyecto

| Tipo de proyecto | Carpeta destino por defecto |
|---|---|
| Zoho CRM | `[CLIENTE] › CRM - Zoho › 04. Implementación › Pruebas` |
| Web / WebApp | `[CLIENTE] › Web › 04. Implementación › Pruebas` |
| WABA / WhatsApp | `[CLIENTE] › WABA › 04. Implementación › Pruebas` |
| Email Marketing | `[CLIENTE] › Email Marketing › 04. Implementación › Pruebas` |
| Otro | Elicitar al PO |

⚠️ **Variantes detectadas en clientes existentes** (carpeta no canónica):
- `4. Implantación` (sin `0` inicial, sin acento moderno) — caso INEFSO/Psicomagister. Si la estructura es preexistente, **respetar el nombre tal cual existe**, no renombrar.

### Flujo de localización

1. Navegar desde Workdrive raíz del cliente con `ZohoWorkdrive_getFolderFiles` (más fiable que `searchTeamFoldersFiles`).
2. Identificar la carpeta del dominio del proyecto (`CRM - Zoho`, `Web`, `WABA`, etc.)
3. Bajar a `04. Implementación` (o variante) → `Pruebas`.
4. Confirmar al PO: *"Carpeta destino: `[CLIENTE] › CRM - Zoho › 04. Implementación › Pruebas` (ID: `xxx`). ¿Confirmas o me indicas otra ubicación?"*

Si la carpeta `Pruebas` no existe, avisar al PO y proponer crearla.

### Validación de existencia previa

Antes de copiar, listar el contenido de la carpeta destino con `getFolderFiles` y comprobar si ya hay Planes de Pruebas previos del mismo desarrollo (buscar coincidencias por nombre que contenga `Plan-de-Pruebas` y palabras clave del desarrollo).

Casos posibles:

- **No existe Plan previo** → seguir con normalidad al PASO 5
- **Existe un Plan previo (cualquier versión)** → ⚠️ preguntar al PO antes de copiar:

  *"He encontrado un Plan de Pruebas previo en la carpeta destino:
  - `[nombre fichero existente]` (modificado: [fecha])

  ¿Qué prefieres?
  1. **Crear v2.0**: copio nueva plantilla con sufijo `-v2.0-BORRADOR`, dejando intacto el anterior
  2. **Sustituir**: muevo el anterior a una subcarpeta `Históricos` y creo el nuevo
  3. **Actualizar el existente**: en lugar de crear uno nuevo, leo el existente y le añado/modifico las pruebas que correspondan
  4. **Cancelar**: paro la operación"*

⚠️ La opción 3 (actualizar el existente) es la más delicada — implica leer estructura previa, conservar pruebas ya ejecutadas con resultados, y solo añadir/modificar lo que toque. Si el PO la elige, confirmar el alcance del cambio antes de tocar nada.

---

## PASO 5 — COPIA DE LA PLANTILLA Y NOMENCLATURA

### 5.1 Copiar la plantilla canónica

**Intento 1 — Con nombre destino al copiar** (probar primero):

```
ZohoWorkdrive_copyFileOrFolder
  destination_parent_id: [ID de la carpeta Pruebas]
  body: {
    data: {
      attributes: {
        resource_id: "b6g99e39964d2bbbe4173a46f3a80f0b8c905",
        display_attr_name: "Plan-de-Pruebas-Funcionales-[DESARROLLO]-[CLIENTE]-v1.0-BORRADOR"
      },
      type: "files"
    }
  }
```

→ Tras la copia, verificar con `getFileOrFolderDetails` que el nombre del nuevo fichero es el solicitado. Si SÍ es el correcto, saltar la sección 5.3 (rename manual).

**Intento 2 — Sin nombre (fallback)**: si el `display_attr_name` no es aceptado por la API o el fichero hereda igualmente el nombre de la plantilla, copiar sin el atributo:

```
ZohoWorkdrive_copyFileOrFolder
  destination_parent_id: [ID de la carpeta Pruebas]
  body: {data: {attributes: {resource_id: "b6g99e39964d2bbbe4173a46f3a80f0b8c905"}, type: "files"}}
```

→ Devuelve el `resource_id` del nuevo Sheet. El nombre será el de la plantilla → aplicar sección 5.3 (rename manual obligatorio).

⚠️ Lección aprendida (sesiones anteriores): Zoho Sheet NO admite rename vía API una vez creado. Si el intento 1 no fija el nombre al crear, el rename **debe** hacerse manualmente desde la UI de Workdrive. Esta es la primera comprobación obligatoria post-copia.

### 5.2 Nomenclatura del fichero

Convención obligatoria (siempre con guiones, sin espacios, sin caracteres especiales):

```
Plan-de-Pruebas-Funcionales-[DESARROLLO]-[CLIENTE]-v1.0-BORRADOR
```

Ejemplos:
- `Plan-de-Pruebas-Funcionales-CRM-LATAM-PSICOMAGISTER-v1.0-BORRADOR`
- `Plan-de-Pruebas-Funcionales-Conector-BC-CARRITECH-v1.0-BORRADOR`
- `Plan-de-Pruebas-Funcionales-Formularios-Web-BREEZOM-v1.0-BORRADOR`

### 5.3 ⚠️ Limitación conocida — Rename manual (solo si el Intento 1 falla)

**Si el Intento 1 fija el nombre correctamente** → ✅ no hay nada que hacer, saltar a 5.4.

**Si el Intento 1 no fija el nombre** (el fichero hereda `Plantilla-Pruebas-Funcionales-Formulario-Contacto-Reinicia`):
- La API MCP no permite renombrar Zoho Sheet (`ZohoWriter_Update_Document_Meta` solo funciona con Writer nativos).
- **Acción obligatoria al final del flujo**: incluir el rename manual como pendiente destacado en el comentario final de ClickUp.

### 5.4 Verificación post-copia

```
ZohoWorkdrive_getFileOrFolderDetails (resource_id del nuevo fichero)
```

Validar:
- `status = 1`
- El fichero existe en la carpeta destino
- `display_url_name` no tiene caracteres encoded raros

---

## PASO 6 — POBLADO DEL SHEET

### 6.1 Portada (hoja `Portada`)

Actualizar 4 celdas vía `cells.content.set`:

| Celda | Contenido |
|---|---|
| C3 (row 3, col 3) | `Pruebas Funcionales [Nombre del Desarrollo] - [CLIENTE]` |
| D5 (row 5, col 4) | Nombre del cliente |
| D6 (row 6, col 4) | Idioma/s (Español, Inglés, Multi, ...) |
| D7 (row 7, col 4) | País/es (España, México, Multi, ...) |

### 6.2 Limpieza de la hoja `Pruebas`

La plantilla viene con 2 pruebas de ejemplo en filas 5-6. **Borrarlas siempre** antes de insertar las nuevas:

```
ZohoSheet_delete_rows
  worksheet_name: "Pruebas"
  row_index_array: [{start_row: 5, end_row: 6}]
```

Actualizar título de la hoja (fila 1) y fecha (fila 2):

| Celda | Contenido |
|---|---|
| A1 | `Pruebas funcionales [Nombre del Desarrollo] - [CLIENTE]` |
| A2 | Fecha actual en formato `DD/MM/YYYY` |

### 6.3 Estructura de columnas (Sheet `Pruebas`)

| Col | Nombre | Contenido |
|---|---|---|
| A (1) | Código de prueba | `PRUEBA-NN` |
| B (2) | Entorno | `DES`, `PRE`, `PRO` |
| C (3) | Acción | Título descriptivo corto |
| D (4) | Pasos | Pasos detallados, numerados, con payloads/datos |
| E (5) | Precondiciones | Estado previo necesario (puede dejarse vacío) |
| F (6) | Resultado esperado | Lista numerada 1) 2) 3) con criterios verificables |
| G (7) | Resultado real | Vacío al crear, lo rellena el ejecutor |
| H (8) | Estado | Vacío al crear (`Correcta` / `Incorrecta`) |
| I (9) | Revisión | `Pendiente` por defecto |
| J (10) | Solución | Vacío al crear |
| K (11) | Notas Cliente | Vacío al crear |
| L (12) | Respuesta Cliente / Reinicia | Vacío al crear |

### 6.4 Escritura de las pruebas

⚠️ **Lección aprendida (validada en Psicomagister 17/05/2026):** `cells.content.set` falla cuando el payload contiene muchas pruebas con texto largo. **Máximo recomendado: 2 pruebas por llamada (12 celdas).** Un payload con 48 celdas (8 pruebas) hace fallar la API silenciosamente.

Para N pruebas: dividir en lotes de 2 pruebas cada uno y ejecutar secuencialmente. Verificar `status: "success"` en cada respuesta antes del siguiente lote.

### 6.5 Datos parametrizados — convención de placeholders

Usar siempre el formato `{VARIABLE_TESTNN}` para que el ejecutor los identifique fácilmente:

- `{ORDER_ID_TEST_03}` — order_id a sustituir antes de ejecutar PRUEBA-03
- `{URL_PRUEBA_MX}` — URL real del entorno LATAM cuando esté disponible
- `{URL_EU_CURSO_TEST}` — URL real EU
- `{EMAIL_TEST_NN}` — email específico si no se quiere usar uno sintético

En el comentario final de ClickUp, listar todos los placeholders pendientes de sustituir.

### 6.6 Pestañas de Capturas

**Decisión por defecto (validada con Néstor 18/05/2026):** una pestaña `Capturas PRUEBA-NN` por cada prueba (renombrar las 2 que vienen en plantilla + duplicar la nº 2 N-2 veces).

**Evolución futura — opción simplificada:** en lugar de pestaña por prueba, ampliar la hoja `Pruebas` con columnas adicionales para enlaces a:
- 🎥 Vídeo Loom / ClickUp Clip / Gyazo / otro
- 📸 Captura de pantalla (URL externa)
- 🔗 Enlace al registro creado en Zoho CRM (si aplica)

Esta opción está pendiente de decisión de Néstor. Por ahora la skill **crea pestañas por prueba**, pero al cerrar pregunta al PO si para el siguiente Plan prefiere probar el modelo simplificado.

### 6.7 Crear pestañas de Capturas adicionales

Para N pruebas, se necesitan N pestañas. La plantilla trae 2. Para PRUEBA-03 hasta PRUEBA-N, duplicar `Capturas PRUEBA-02`:

```
ZohoSheet_copy_worksheet (worksheet.copy)
  worksheet_name: "Capturas PRUEBA-02"
  new_worksheet_name: "Capturas PRUEBA-03"
```

Repetir secuencialmente para cada nueva prueba.

---

## PASO 7 — COMENTARIO EN CLICKUP E IMPUTACIÓN DE TIEMPO

### 7.1 Comentario en la tarjeta del PRODUCTO PRINCIPAL

⚠️ **Importante:** el comentario va en la **tarjeta del producto principal**, NO en la subtarea de Plan de Pruebas (aunque exista). La subtarea, si existe, se actualiza por separado en el paso 7.2.

Formato del comentario (plain text — recordatorio: ClickUp NO acepta markdown ni HTML via MCP):

```
Plan de Pruebas Funcional [DESARROLLO] - [CLIENTE] creado en Zoho Sheet.

Cobertura: N pruebas en M bloques ([lista de bloques]). Origen del scope: DF (X pruebas) + Tarjeta ClickUp y relacionadas (Y pruebas, desglose: descripción, criterios, subtareas, comentarios, adjuntos) + Aportación PO (Z pruebas).

Perfil: [Rápida / Estándar / Exhaustiva]. Entorno(s): [DES / DES+PRO / DES+PRE+PRO]. Todas las pruebas marcadas como Revisión Pendiente.

Datos: [sintéticos / mezcla con datos reales]. Placeholders pendientes de sustituir antes de la ejecución: {LISTA_PLACEHOLDERS}.

N+2 pestañas: Portada, Pruebas (con las N pruebas) y Capturas PRUEBA-01 a Capturas PRUEBA-N.

Ubicación: Workdrive > [CLIENTE] > [DOMINIO] > [04. Implementación / variante] > Pruebas

Privado - Plan de Pruebas Funcionales [DESARROLLO] [CLIENTE] v1.0 BORRADOR - [CLIENTE]
https://sheet.zoho.eu/sheet/open/[resource_id]

==== POSIBLES ACTUALIZACIONES AL DISEÑO FUNCIONAL ====
[Solo si la skill ha detectado funcionalidad fuera del DF actual. Si no hay gaps, omitir este bloque entero.]
He detectado funcionalidad mencionada en la tarjeta ClickUp (descripción, criterios, subtareas, comentarios o adjuntos) o aportada por el PO que NO está escrita en el DF actual. Recomiendo al autor del DF revisar si actualizarlo:
1. [Funcionalidad] - origen: [ClickUp Descripción / Criterio / Subtarea / Comentario DD/MM/YYYY / Adjunto / Aportación PO] - cubierta en PRUEBA-NN
2. ...

==== PROCESO ANTES DE EJECUTAR EN SANDBOX ====
1. VALIDACIÓN INTERNA REINICIA: revisar el Plan con el PO Técnico ([Paolo/Fabián]) antes de enviar al Cliente. Especialmente importante si el preparador del Plan no es PO Técnico.

2. RENOMBRAR el fichero en Workdrive (si Claude no consiguió fijar el nombre al copiar): debe llamarse "Plan-de-Pruebas-Funcionales-[DESARROLLO]-[CLIENTE]-v1.0-BORRADOR". La API no permite renombrar Zoho Sheet, hay que hacerlo desde la UI.

3. GENERAR ENLACE PÚBLICO desde Workdrive con permisos "Ver y comentar" (NO solo lectura) y enviar al Cliente para validación funcional.

4. ESPERAR validación del Cliente antes de empezar a ejecutar las pruebas en SANDBOX.

5. SUSTITUIR placeholders {VAR_NN} por valores reales antes de empezar la ejecución.
```

Asignar el comentario al responsable identificado en PASO 1 (assignee del comentario en ClickUp).

**Notas adicionales del comentario:**
- Si Claude consiguió fijar el nombre al copiar la plantilla (Intento 1 en PASO 5.1 exitoso), eliminar el punto 2 del bloque "PROCESO ANTES DE EJECUTAR".
- Si no hay placeholders pendientes (todos los datos son fijos), eliminar el punto 5.
- Si no hay subtarea de Plan de Pruebas, eliminar el aviso de "VALIDACIÓN INTERNA REINICIA" SOLO si el preparador es PO Técnico (Paolo o Fabián). Si no lo es, MANTENER el aviso siempre.

### 7.2 Subtarea de Plan de Pruebas (si existe)

Si el PO confirmó en PASO 1 que existe una subtarea específica de Plan de Pruebas:

"¿En qué estatus quieres que ponga la subtarea de Plan de Pruebas?
- `Doing` — sigo trabajando en ella
- `Validación Reinicia` — listo para revisión interna antes de enviar al cliente
- `Validación Cliente` — enviado al cliente, esperando feedback
- `Done` — cerrada

Por defecto sugiero `Validación Reinicia` (el siguiente paso es revisión interna antes de enviar al cliente)."

Aplicar el cambio de status con `clickup_update_task`.

### 7.3 Imputación de tiempo

Imputar el tiempo de análisis y diseño del Plan de Pruebas en la tarjeta del producto principal (o en la subtarea si existe), al responsable identificado en PASO 1.

Preguntar al PO/responsable: "¿Cuánto tiempo apunto de análisis y diseño del Plan de Pruebas? (en horas o minutos)"

Usar `clickup_add_time_entry` con:
- `task_id`: ID del producto o subtarea
- `assignee`: user_id del responsable
- `duration`: en milisegundos (horas × 3.600.000)
- `description`: "Análisis y diseño del Plan de Pruebas Funcionales [DESARROLLO]"

Si `clickup_add_time_entry` no acepta `assignee` distinto del usuario autenticado (limitación conocida ClickUp API), avisar al PO para que impute manualmente.

---

## PASO 8 — RECORDATORIO DE PROCESO DE VALIDACIÓN

Cierre obligatorio de la conversación con el resumen final. El proceso completo tiene **6 pasos secuenciales**:

```
✅ Plan de Pruebas creado.

📌 PROCESO DE VALIDACIÓN antes de empezar a ejecutar en SANDBOX:

1. VALIDACIÓN INTERNA REINICIA (obligatoria si el preparador NO es PO Técnico):
   Revisar el Plan con el PO Técnico ([Paolo / Fabián]) antes de enviar al Cliente.
   Comprobar cobertura, coherencia de pasos, sentido de los resultados esperados.

2. RENOMBRAR el fichero en Workdrive desde la UI (SOLO si el rename no se fijó al copiar):
   Nombre actual: Plantilla-Pruebas-Funcionales-Formulario-Contacto-Reinicia
   Nombre correcto: Plan-de-Pruebas-Funcionales-[DESARROLLO]-[CLIENTE]-v1.0-BORRADOR

3. SUSTITUIR placeholders {VAR_NN} por valores reales (URLs, order_ids, emails específicos)
   si no van a permanecer abiertos para el ejecutor.

4. GENERAR ENLACE PÚBLICO desde Workdrive:
   Click derecho sobre el fichero > Compartir > Crear enlace
   Permisos: "Ver y comentar" (NO solo lectura)
   Configurar caducidad si procede

5. ENVIAR al Cliente con un mensaje del tipo:
   "Aquí tienes el Plan de Pruebas Funcionales del desarrollo [X]. Por favor revísalo
   y déjanos comentarios sobre cobertura, casos faltantes o pasos que veas confusos.
   Cuando lo apruebes, procederemos a ejecutarlo en SANDBOX y te compartiremos los
   resultados."

6. ESPERAR validación del Cliente antes de empezar a ejecutar en SANDBOX.
```

⚠️ Adaptar el resumen al caso concreto:
- Si Claude consiguió fijar el nombre al copiar (Intento 1 OK) → eliminar paso 2.
- Si no hay placeholders abiertos → eliminar paso 3.
- Si el preparador ES PO Técnico → reformular paso 1 como recomendación opcional ("autovalidación o segunda opinión de [otro PO Técnico]"), no obligatorio.

---

## RECURSOS Y CONSTANTES

### Plantilla y ejemplos validados
- Plantilla canónica: `b6g99e39964d2bbbe4173a46f3a80f0b8c905`
- Ejemplo simple (Breezom, 6 pruebas): `b2vmkae4b177965a34d62be0c0de9c54c3290`
- Ejemplo complejo (Psicomagister LATAM, 16 pruebas, 6 bloques): `pdobndfda0fe579894dfca00844cfae753ce8`

### Herramientas MCP usadas
- **Workdrive**: `getFolderFiles`, `getFileOrFolderDetails`, `copyFileOrFolder`
- **Zoho Sheet**: `list_all_worksheets`, `get_content_of_worksheet`, `set_content_to_multiple_cells`, `delete_rows`, `copy_worksheet_-_same_workbook`, `rename_worksheet`
- **ClickUp**: `clickup_get_task` (descripción, criterios, subtareas, adjuntos), `clickup_filter_tasks` (subtareas en bloque si la API lo requiere), `clickup_update_task`, `clickup_get_task_comments`, `clickup_get_threaded_comments`, `clickup_create_task_comment`, `clickup_add_time_entry`

### Identidad visual
La skill produce un Zoho Sheet basado en la plantilla canónica de Reinicia, que ya incorpora la identidad visual. No es necesario aplicar branding adicional. Si en una evolución futura se añade exportación a PDF u otros formatos, consultar la skill `marca-reinicia` para colores, tipografía y logo.

---

## LIMITACIONES TÉCNICAS CONOCIDAS

1. **No se puede renombrar Zoho Sheet vía API MCP.** `ZohoWriter_Update_Document_Meta` solo funciona con Writer nativos. Rename manual obligatorio desde Workdrive UI.
2. **Payload máximo en `cells.content.set`:** 2 pruebas (12 celdas) por llamada cuando los textos son largos. Lotes mayores fallan silenciosamente.
3. **ClickUp comentarios sin markdown:** plain text obligatorio. Sin enlaces hyperlinkeados — descripción + URL en líneas separadas.
4. **`clickup_get_time_entries` solo devuelve entries del usuario autenticado.** Si el responsable no es Néstor, imputar manualmente (limitación API ClickUp).
5. **`ZohoSheet_copy` puede ignorar `workbook_name`:** verificar nombre tras copiar.
6. **`worksheet.copy` preserva formato** pero también copia el contenido — al duplicar `Capturas PRUEBA-02` para crear `PRUEBA-03`, la nueva hereda los placeholders de captura de la 02. Aceptable (se rellenarán durante la ejecución).

---

## EXTENSIONES FUTURAS (DOCUMENTADAS, NO IMPLEMENTADAS)

### Web / WebApp
Cobertura tipo: pruebas de formularios, navegación, responsive, integraciones AJAX, GTM/GA4, performance básica. Estructura de bloques distinta:
- A — Navegación y arquitectura
- B — Formularios y captura
- C — Integraciones (Zoho Forms, Zoho CRM, Mailchimp)
- D — Tracking (GA4, GTM, conversiones)
- E — Multi-idioma / multi-país
- F — Performance / accesibilidad / SEO básico

### WABA / WhatsApp
Cobertura tipo: pruebas de flujos conversacionales, plantillas Meta aprobadas, fallback humanos, integraciones Woztell/Blip/Eazybe. Estructura:
- A — Plantillas Meta (aprobación, variables, idiomas)
- B — Flujos conversacionales (decision trees, menús)
- C — Integraciones con Zoho CRM (creación de Lead/Contact, asignación)
- D — Handover a humano y horario laboral
- E — Campañas masivas y opt-out
- F — Métricas y reporting

### Email Marketing
Cobertura tipo: pruebas de plantillas, segmentación, A/B test, deliverability, tracking de clicks, integraciones con CRM. Estructura por definir según primer proyecto que se aborde.

### Otras evoluciones a evaluar
- **Pestañas de Capturas simplificadas:** en lugar de una por prueba, ampliar columnas en hoja `Pruebas` con enlaces a Loom/ClickUp Clip/Gyazo y al registro de Zoho. Pregunta abierta con Néstor al cierre de cada Plan generado.
- **Exportación a PDF** para envío al cliente (en lugar de enlace al Sheet).
- **Generación automática de enlace público** desde la API (verificar si Workdrive expone endpoint MCP para esto).
- **Integración con Sprint Backlog:** vincular las pruebas con el Sprint Backlog para trackear horas de QA por prueba.

---

## NOTAS OPERATIVAS

- **Preguntas secuenciales:** una a una, sin agrupar (estilo Néstor).
- **Tres fuentes de scope siempre:** DF (si se aporta) + Contenido completo de la tarjeta ClickUp del producto y relacionadas (descripción, criterios de aceptación, subtareas, comentarios y respuestas anidadas, adjuntos) + Elicitación al PO. Ninguna fuente es opcional excepto el DF.
- **Lectura completa del DF:** nunca leer por trozos. Si el DF es muy largo, leer secciones específicas pero asegurar que se cubre el alcance completo.
- **Lectura completa de la tarjeta ClickUp:** peinar TODOS los apartados, no solo los comentarios. Los criterios de aceptación son requisitos verificables y deben tener prueba asociada. Las subtareas reflejan el desglose real. Los adjuntos pueden contener wireframes/payloads críticos. Las respuestas anidadas de los comentarios suelen tener información crítica — incluir SIEMPRE `get_threaded_comments`.
- **Detectar gaps DF y reportarlos:** si la skill encuentra funcionalidad fuera del DF (en cualquier apartado de la tarjeta ClickUp o aportada por el PO), listarla en la propuesta de cobertura Y en el comentario final de ClickUp para que el autor del DF pueda actualizarlo.
- **Confirmación antes de actuar:** estructura de cobertura en PASO 3 requiere OK explícito antes de copiar la plantilla.
- **Validación previa de existencia:** comprobar si hay Plan de Pruebas previo en la carpeta destino antes de copiar.
- **Carpeta destino:** proponer y confirmar siempre, especialmente para proyectos no-Zoho.
- **Intentar fijar nombre al copiar:** intento con `display_attr_name` primero, fallback a rename manual si no se acepta.
- **Datos sintéticos por defecto, reales por petición:** nunca mezclar PII real con sintética sin avisar. Revisión obligatoria de payloads JSON antes de escribir cada prueba.
- **Plain text en ClickUp:** siempre. Sin markdown, sin HTML, sin custom-link hyperlinks.
- **Validación interna Reinicia antes del envío al Cliente:** obligatoria si el preparador no es PO Técnico; recomendada en cualquier caso.
- **Pendientes manuales destacados al cierre:** rename del fichero (solo si fue necesario), enlace público, sustitución de placeholders, envío al cliente para validación.
- **No olvidar la imputación de tiempo:** preguntar al responsable cuánto apuntar; si la API no permite imputar a otro usuario, avisar para que lo haga manualmente.
- **Una pestaña de Capturas por prueba (por ahora):** consultable a futuro para simplificar.

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v2.0 | 21/06/2026 | Néstor + Claude | Versión vigente registrada al incorporar el estándar de versionado de Reinicia. El histórico previo de cambios está descrito en prosa en el cuerpo de la skill y queda pendiente de tabular. |
