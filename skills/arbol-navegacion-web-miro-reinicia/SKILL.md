---
name: arbol-navegacion-web-miro-reinicia
description: Skill para crear árboles de navegación (sitemaps) de proyectos Web y WebApp en Miro para clientes de Reinicia, incluyendo el producto correspondiente en ClickUp. Actívala siempre que el PO pida crear o actualizar el árbol de navegación, el sitemap o la arquitectura de páginas de una web en Miro, o cuando se mencione "árbol de navegación", "sitemap", "arquitectura de páginas", "estructura de la web" junto a un cliente. También se activa cuando el PO pida crear el producto de Arquitectura Web en ClickUp dentro de un proyecto web. No usar para flujogramas conversacionales de WhatsApp (skill WABA Miro) ni para productos web genéricos sin componente de sitemap.
---

# SKILL: Árbol de Navegación Web en Miro — Reinicia

## Descripción
Esta skill permite a los Product Owners de Reinicia crear árboles de navegación (sitemaps) de proyectos Web y WebApp directamente en un board de Miro, siguiendo el estándar visual de Reinicia establecido en el proyecto HomeEspaña. Cubre dos outputs simultáneos:

1. **El árbol en Miro** — generado como diagrama `flowchart` con el sistema de colores estándar de Reinicia, en un nuevo frame dentro del board del proyecto.
2. **El producto en ClickUp** — tarea "Arquitectura de la web / Sitemap [CLIENTE]" en `General [CLIENTE]`, siguiendo la estructura de la skill Web.

**Principio iterativo:** cada versión del árbol ocupa un nuevo frame en el mismo board (v1.00, v2.00...). Las versiones anteriores se conservan. Claude siempre pregunta qué versión está creando.

---

## SISTEMA DE COLORES ESTÁNDAR REINICIA

Este sistema se aplica **siempre** en todos los proyectos, salvo instrucción explícita del PO.

| Color | Hex | Uso |
|---|---|---|
| **Azul** | `#3812CB` | Nodo raíz (Home), elementos funcionales transversales (Buscador, Login/Registro, Selector de idiomas) |
| **Turquesa** | `#70EED6` | Categorías de primer nivel de la **navegación principal** (Header Primary Nav) |
| **Amarillo** | `#EBE31D` | Subcategorías y páginas de segundo nivel |
| **Rojo** | `#D14351` | Páginas especiales: fichas de detalle, páginas generadas dinámicamente, landing pages específicas |
| **Gris claro** | `#E7E7E7` | Elementos del **Header Secondary Menu**, del **footer** y de cualquier menú de menor peso jerárquico |

**Secciones del Header que se deben distinguir siempre:**
- **Header Primary Navigation** — el menú principal visible en todas las páginas (Buying, Selling, Areas...). Sus categorías van en **turquesa**.
- **Header Secondary Menu** — elementos secundarios del header fuera del menú principal (About, Offices, Login, News en HomeEspaña). Van en **gris claro** o como nodos funcionales **azul** según su naturaleza.
- Si el header tiene un **doble menú de navegación** (ej. menú principal + barra de categorías secundaria), ambos se representan con sus propios clusters diferenciados en el diagrama.

**Secciones del footer que se deben distinguir:**
- Footer puede tener varias subsecciones (Prefooter, Footer principal, barra legal). Cada una va en su propio cluster, todos con nodos en **gris claro** salvo que tengan peso equivalente al menú principal.

**Sugerencia de mejora sobre HomeEspaña:** Se propone añadir un color diferenciado para **páginas de área privada / autenticación** (ej. `#DEDAFF`, violeta suave), que en HomeEspaña se mezclaban con nodos funcionales azul creando ambigüedad. El PO puede adoptarlo o mantener el esquema de 5 colores base.

---

## PASO 1 — ELICITACIÓN

Claude hace las preguntas de forma **secuencial**.

### Pregunta 1: Cliente y contexto del proyecto
"¿Para qué cliente es el árbol de navegación? ¿Tienes ya el board de Miro del proyecto, o hay que crearlo desde cero?"

→ Si hay board existente, pedir la URL. Si no, el PO deberá crear el board primero y facilitar la URL — Claude no puede crear boards, solo trabajar dentro de boards existentes.

### Pregunta 2: Versión
"¿Es la primera versión del árbol (v1.00) o es una iteración sobre una versión anterior? Si es una iteración, ¿hay cambios concretos que quieras incorporar o partimos del árbol anterior como base?"

→ Si es v1.00 → ir a Pregunta 3.
→ Si es vN → Claude lee el frame anterior con `context_get` antes de proceder.

### Pregunta 3: Origen de la estructura
"¿Cómo quieres que construya la estructura del árbol?"

**Opciones:**
- **A) Claude la propone** a partir del Sprint Cero, propuesta comercial, web actual del cliente y buenas prácticas — el PO la revisa antes de generar el diagrama.
- **B) El PO aporta un borrador** (lista de páginas, esquema en texto, documento...) — Claude lo estructura y lo plasma en Miro.
- **C) La estructura ya está definida** — Claude la ejecuta directamente en Miro sin proponer cambios.

→ Si A o B: Claude elabora la estructura como texto jerárquico y la presenta al PO para validación **antes de generar el diagrama en Miro**. No generar el diagrama hasta que el PO apruebe la estructura.

### Pregunta 4: Nivel de detalle de los nodos
"¿Qué información quieres en cada nodo del árbol?"

**Opciones:**
- **Básico:** Solo nombre de la página.
- **Medio:** Nombre + tipo de página (estática, dinámica, área privada...) + URL prevista.
- **Completo:** Nombre + tipo + URL + notas de desarrollo (ej. "requiere autenticación", "generada por Zoho CRM"...).

→ El nivel elegido determina el texto dentro de cada nodo del diagrama.

### Pregunta 5: Secciones del árbol a incluir
"¿Qué secciones quieres que el árbol represente? Por ejemplo: navegación principal (Header Primary), menú secundario del header (Header Secondary), prefooter, footer, área privada... ¿o todas?"

Preguntar también: "¿El header tiene un doble menú de navegación — es decir, un menú principal y además una barra de categorías secundaria o menú de utilidades separado? Si es así, los representaré como secciones diferenciadas."

→ En proyectos complejos puede ser útil hacer un frame por sección. Claude lo sugiere si la estructura supera ~40 nodos.

### Pregunta 6: Producto en ClickUp
"¿Quieres que también cree el producto 'Arquitectura de la web / Sitemap [CLIENTE]' en ClickUp (lista General [CLIENTE])? Si es una iteración, el producto ya existe — solo actualizaríamos el comentario con el enlace al nuevo frame."

→ Si sí: pedir el ID de la lista `General [CLIENTE]` si no lo tiene (buscar con `clickup_search`).

---

## PASO 2 — BÚSQUEDA DE INFORMACIÓN (si Claude propone la estructura)

Solo se ejecuta si el PO eligió opción A en Pregunta 3.

**Orden de consulta:**
1. `00. Información > Empresa` → Sprint Cero (PDF) — arquitectura propuesta si existe.
2. `00. Información > Comercial` → Propuesta Comercial — páginas y secciones comprometidas.
3. `01. Seguimiento` → Actas recientes — cambios acordados en reuniones.
4. Web actual del cliente (si existe) — para entender la estructura que se migra o mejora.
5. Board de Miro del proyecto — si hay versiones anteriores del árbol.

**Herramientas:**
- `ZohoWorkdrive_getFolderFiles` / `ZohoWorkdrive_downloadWorkDriveFile` → documentos del proyecto
- `Miro:context_get` → leer versiones anteriores del árbol si las hay
- `web_search` → estructura de la web actual del cliente si es pública

---

## PASO 3 — PROPUESTA DE ESTRUCTURA (si Claude propone)

Antes de generar nada en Miro, Claude presenta la estructura como texto jerárquico para validación:

```
📐 PROPUESTA DE ÁRBOL DE NAVEGACIÓN — [CLIENTE] v[N].00

🔵 Home

  ── HEADER ──────────────────────────────────────

  🔵 Elementos funcionales del header
     • Selector de idiomas (EN / DE / NL / ES)
     • Buscador
     • Login / Registro

  ⚪ Header Secondary Menu   [si existe]
     • [Ítem secundario 1]   (ej. About, Offices, News)
     • [Ítem secundario 2]

  🟢 Header Primary Navigation   [menú principal]
     • [Categoría 1]
          - [Subcategoría 1.1]
          - [Subcategoría 1.2]
     • [Categoría 2]
          - [Subcategoría 2.1]

  ⚪ Header Secondary Navigation   [si hay doble menú de navegación]
     • [Categoría barra secundaria 1]
     • [Categoría barra secundaria 2]

  🔴 Páginas especiales / Fichas de detalle
     • [Nombre página dinámica]   (ej. Property Detailed Page)

  ── FOOTER ──────────────────────────────────────

  ⚪ Prefooter   [si existe, sección justo antes del footer]
     • [Elemento prefooter]

  ⚪ Footer — [Sección 1]   (ej. Popular Links)
     • [Enlace 1]
     • [Enlace 2]

  ⚪ Footer — [Sección 2]   (ej. Popular Areas)
     • [Enlace 1]

  ⚪ Footer — Legal
     • Aviso legal / Privacidad / Cookies

💡 Propuestas de mejora respecto a la estructura actual:
   - [Si las hay, con fuente]

¿Apruebas esta estructura? ¿Añades, eliminas o ajustas algo antes de generar el diagrama?
```

→ No generar el diagrama hasta confirmación explícita del PO.

---

## PASO 3b — ANÁLISIS DE BLOQUES DE CONTENIDO POR PLANTILLA (opcional)

Este paso se ejecuta **solo si el PO lo solicita** — en la elicitación o en cualquier momento del proceso. Se puede hacer en paralelo con la aprobación de la estructura (Paso 3) o después.

### Cuándo activarlo
El PO puede pedirlo con frases como: "¿qué contenido debería tener cada página?", "analiza la web del cliente", "propón mejoras sobre la web actual", "mira webs de referencia del sector". También Claude puede sugerirlo proactivamente al presentar la estructura si detecta que hay web actual del cliente o Sprint Cero con información suficiente.

### Qué genera
Un **documento en Miro** (`doc_create`) colocado junto al diagrama del árbol, con una ficha por cada plantilla de página identificada en el árbol. Cada ficha propone los bloques de contenido recomendados, diferenciando claramente qué existe en la web actual y qué se propone como mejora.

### Proceso de análisis

**Fuentes a consultar (en este orden):**
1. **Web actual del cliente** — si existe, Claude la analiza con `web_fetch` para entender qué bloques de contenido tiene cada plantilla actualmente.
2. **Sprint Cero y propuesta comercial** — para entender los objetivos del proyecto y el alcance comprometido.
3. **Webs de referencia del sector** — el PO puede aportar URLs concretas, o Claude puede buscar con `web_search` ("best practices [tipo de web] [sector] site structure content blocks") para encontrar 2-3 referentes relevantes.
4. **Estándares de UX y conversión** — buenas prácticas generales de diseño web (above the fold, CTA placement, social proof, etc.) aplicadas al tipo de plantilla y al sector.

**Pregunta al PO antes de buscar:**
"¿Tienes URLs de webs del sector que quieras que tome como referencia? Si no, busco yo referentes relevantes para [tipo de web / sector del cliente]."

### Formato del documento en Miro

```markdown
# Análisis de bloques de contenido — [CLIENTE] v[N].00

## Cómo leer este documento
- ✅ Bloque existente en la web actual
- 🔄 Bloque existente pero con propuesta de mejora
- 💡 Bloque nuevo propuesto (fuera del alcance actual — requiere valoración)
- ⚠️ Bloque recomendado por buenas prácticas del sector

---

## [Nombre plantilla 1] — ej. Home

**Descripción de la plantilla:** Página de entrada principal del sitio. 
Primera impresión para el usuario, debe comunicar la propuesta de valor 
y dirigir al usuario a las secciones clave.

**Objetivos de esta plantilla:** [extraídos del Sprint Cero o propuesta]

| Bloque | Estado | Notas |
|---|---|---|
| Hero con titular y CTA principal | ✅ | Existe en web actual — revisar mensaje |
| Buscador prominente | ✅ | — |
| Sección de categorías principales | 🔄 | Actualmente son 6 — propuesta: reducir a 4 con iconos |
| Propiedades destacadas / featured listings | 💡 | No existe — alta conversión en webs inmobiliarias de referencia |
| Testimonios de clientes | 💡 | No existe — recomendado para generar confianza |
| Áreas geográficas con imagen | ⚠️ | Buena práctica para webs inmobiliarias por zona |
| Newsletter / captura de lead | 🔄 | Existe en footer — propuesta: añadir también en home |

**Fuentes consultadas:**
- Web actual: [URL]
- Referente 1: [URL] — [nombre web]
- Referente 2: [URL] — [nombre web]

---

## [Nombre plantilla 2] — ej. Ficha de Producto / Property Detail Page

**Descripción de la plantilla:** ...
**Objetivos:** ...

| Bloque | Estado | Notas |
|---|---|---|
| Galería de imágenes | ✅ | — |
| Precio y características clave | ✅ | — |
| Mapa de ubicación | ✅ | — |
| Formulario de contacto / solicitar visita | 🔄 | Mejora: añadir CTA de WhatsApp directo |
| Propiedades similares | 💡 | No existe — reduce tasa de abandono |
| Calculadora de hipoteca | 💡 | Alta demanda en sector inmobiliario |
| Botón guardar en favoritos | ✅ | — |

**Fuentes consultadas:**
- ...

---

[Una sección por cada plantilla identificada en el árbol]
```

### Reglas de aplicación

- **Solo plantillas, no páginas repetidas.** Si el árbol tiene 40 nodos pero solo 8 plantillas distintas (Home, Listado, Ficha, Contacto, Sobre nosotros...), se generan 8 fichas — no 40. Claude identifica qué nodos comparten la misma plantilla.
- **Alcance explícito en cada propuesta.** Los bloques 💡 siempre llevan la nota "fuera del alcance actual — requiere valoración y presupuesto adicional".
- **Objetivos como brújula.** Las propuestas de mejora deben estar justificadas en función de los objetivos del proyecto (captación de leads, conversión, posicionamiento SEO, reducción de llamadas de soporte...), no solo por tendencias genéricas.
- **El documento va junto al diagrama.** Se posiciona en el board de Miro a la derecha del árbol de navegación del mismo frame, con coordenadas `x = x_diagrama + 4000`.
- **No bloquea la generación del árbol.** Este análisis es paralelo — el árbol puede generarse aunque el análisis de bloques esté en curso o pendiente.
- **Conexión con ClickUp:** los bloques 💡 aprobados por el PO se trasladan a la descripción de la tarea "Arquitectura website [CLIENTE]" como parte del listado de plantillas y requisitos de arquitectura para UX. No se crea una tarea separada.

---

## PASO 4 — GENERACIÓN DEL DIAGRAMA EN MIRO

Una vez aprobada la estructura, Claude genera el diagrama:

### 4.1 Leer el DSL
Siempre ejecutar `Miro:diagram_get_dsl` con `diagram_type: flowchart` antes de generar, para usar el formato correcto.

### 4.2 Reglas de generación del DSL

**Paleta de colores Reinicia (en este orden en el DSL):**
```
palette #3812CB #70EED6 #EBE31D #D14351 #E7E7E7
```
→ color_index 0 = Azul (Home, funcionales), 1 = Turquesa (nivel 1), 2 = Amarillo (nivel 2), 3 = Rojo (páginas especiales), 4 = Gris (footer/secundarios)

**Tipo de nodo según el contenido:**
- `flowchart-terminator` → nodo Home (raíz)
- `flowchart-process` → páginas de contenido estándar
- `flowchart-data` → elementos funcionales (buscador, login, idiomas)
- `flowchart-decision` → usar con moderación, solo para bifurcaciones reales (ej. "¿Autenticado?")

**Dirección:** `graphdir TB` (Top-to-Bottom) es el estándar para sitemaps. Cambiar a `LR` si hay más de 5 categorías de primer nivel para mejorar la legibilidad.

**Clusters:** usar para agrupar cada sección diferenciada. Nombre del cluster en español y descriptivo. Clusters obligatorios cuando la sección existe:

- `"Elementos funcionales del header"` — buscador, idiomas, login (nodos azul)
- `"Header Secondary Menu"` — menú de utilidades del header si existe (nodos gris)
- `"Header Primary Navigation"` — menú de navegación principal (nodos turquesa + sus subcategorías amarillas)
- `"Header Secondary Navigation"` — segunda barra de navegación si existe (nodos gris o turquesa según peso)
- `"Páginas especiales"` — fichas de detalle, páginas dinámicas (nodos rojo)
- `"Prefooter"` — si existe (nodos gris)
- `"Footer — [nombre sección]"` — un cluster por cada bloque diferenciado del footer (nodos gris)
- `"Footer — Legal"` — privacy, disclaimer, cookies (nodos gris)
- `"Área privada"` — si existe, sección de usuario autenticado (nodos violeta si se adopta la sugerencia, o azul)

**Nomenclatura del título del diagrama:**
`Sitemap [NOMBRE CLIENTE] v[N].00 — [fecha AAAA-MM-DD]`

### 4.3 Posicionamiento en el board
Cada versión va a la derecha de la anterior. Incrementar X en ~8000 unidades por versión:
- v1.00 → `x=0, y=0`
- v2.00 → `x=8000, y=0`
- v3.00 → `x=16000, y=0`

### 4.4 Notas de desarrollo (nivel Medio o Completo)
Si el PO eligió nivel Medio o Completo, añadir tras el diagrama un `doc_create` en Miro con las notas estructuradas por nodo, en el mismo frame. Formato:

```markdown
# Notas de desarrollo — Sitemap [CLIENTE] v[N].00

## [Nombre página]
- **Tipo:** Estática / Dinámica / Área privada
- **URL prevista:** /ruta/url
- **Notas:** [descripción, integraciones, condiciones...]
```

---

## PASO 5 — PRODUCTO EN CLICKUP (si el PO lo solicitó)

Si es **v1.00** — crear tarea nueva. La referencia canónica son las tareas de TI-MEDI (`869aeg8td`) y Birdease (`869c513ey`). El nombre del producto es siempre **"Arquitectura website [CLIENTE]"**.

Lo que distingue esta tarea de un sitemap genérico es que incluye explícitamente:
- El árbol de navegación (niveles, jerarquía, relaciones)
- La definición de **plantillas necesarias** y qué contenido debe soportar cada una
- Los **macro-objetivos** (envío formulario, solicitud demo, compra...) y **micro-objetivos** (clic CTA, visualización vídeo...) por página
- Los **criterios SEO básicos**: URLs clave a mantener/redirigir, slugs, jerarquía de contenidos

```
NOMBRE: Arquitectura website [CLIENTE]

DESCRIPCIÓN:
  Historia de usuario:
  Como [nombre y cargo del interlocutor cliente], QUIERO disponer de
  una arquitectura web clara (secciones, plantillas, tipos de página
  y flujos de navegación) alineada con negocio, marketing y SEO,
  PARA garantizar que el [rediseño / nueva web] sea escalable, fácil
  de mantener y optimizado para conversión y posicionamiento.

  Descripción:
  Web: [URL cliente]
  Objetivo Cliente: [qué hace la empresa y qué busca con la web]
  Público objetivo: [perfiles principales de visitante]

  Objetivo producto:
  Definir la arquitectura de la información y la navegación del sitio:
  secciones principales, subniveles, plantillas necesarias y objetivos
  de cada página (macro y micro-conversiones). Asegurar que la
  arquitectura soporta SEO y crecimiento futuro.

  Ready to Backlog:
  - Están identificados y priorizados los objetivos de negocio de la web.
  - Existe un inventario inicial de contenidos y secciones actuales.
  - Están definidos los públicos objetivo y sus principales journeys.
  - Están acordados los criterios SEO básicos (URLs a respetar, términos clave).

  Contexto: [situación actual de la web y motivación del cambio]

  Entregables Internos Reinicia:
  - Mapa web/sitemap con niveles de navegación, páginas y objetivos
  - Listado de plantillas necesarias con descripción funcional y contenido a soportar
  - Documento de requisitos de arquitectura para UX y desarrollo
  - Lista de URLs clave existentes a mantener/redirigir y propuestas de nuevas URLs

  Entregables a Cliente:
  - Diagrama de arquitectura web (visual) en Miro → [URL board]
  - Documento de árbol de navegación con macro y micro-objetivos por página

  Actividades:
  - Análisis de documentación y web actual del cliente
  - Diseño de propuesta de arquitectura v1.00
  - Revisión con equipo UX/SEO y ajustes
  - [Iteraciones según rondas acordadas]
  - Presentación al cliente para feedback y validación final

  Documentación de referencia:
  - Sprint Cero [CLIENTE]: [enlace Workdrive]
  - Web actual del cliente: [URL]

SUBTAREAS:
  1. Análisis documentación y web actual
  2. Arquitectura web V1
  3. Validación Reinicia
  4. Validación Cliente
  [Para cada iteración adicional: Arquitectura web V2 → Validación Reinicia → Validación Cliente]

CRITERIOS DE ACEPTACIÓN:
  ☐ Existe un sitemap aprobado con todas las secciones y niveles de navegación.
  ☐ Cada página principal tiene definido al menos un macro-objetivo y, cuando aplique, micro-objetivos.
  ☐ Hay un listado de plantillas definido y aprobado, con propósito claro y relación con el árbol.
  ☐ Se ha documentado qué URLs clave actuales se mantienen, cambian o redirigen (impacto SEO).
  ☐ La estructura refleja objetivos de marketing y ventas (atracción, conversión, fidelización).
  ☐ El usuario puede acceder a cualquier sección clave en máximo 3 clics desde Home.
  ☐ La arquitectura facilita crecimiento futuro (nuevas secciones, landing pages, idiomas).
  ☐ [Nombre interlocutor cliente] ha validado la arquitectura por escrito o en acta de reunión.

CAMPOS PERSONALIZADOS:
  PROYECTO: [CLIENTE]
  TIPO DE PRODUCTO: DESARROLLO WEB
  PO: [Nombre PO]
  ÉPICA: PLANIFICACIÓN
  PBIs PRIMER NIVEL: [según acuerdo con PO]
  REFINADO: Sí (al crear con esta skill, el producto ya está refinado)
  ORDEN: ⚠️ pendiente Sprint Planning
```

Si es **vN (iteración)** — añadir comentario a la tarea existente con el enlace al nuevo frame de Miro y un resumen de los cambios incorporados respecto a la versión anterior. No crear tarea nueva. La subtarea correspondiente (ej. "Arquitectura web V2") se crea dentro de la tarea madre existente.

**Referencias ClickUp:**
- TI-MEDI: `869aeg8td` ("Arquitectura website [TIMEDI]") — Closed, referencia de estructura completa con V1 y V2
- Birdease: `869c513ey` ("Arquitectura website [BIRDEASE]") — En sprint backlog, referencia de descripción más detallada con objetivos, plantillas y criterios SEO
- HomeEspaña: no tiene producto de Arquitectura Web (el proyecto arrancó directamente en Maquetas/Plantillas)

**Herramientas ClickUp:**
- `clickup_create_task` → tarea principal y subtareas (v1.00)
- `clickup_update_task` → campos personalizados
- `clickup_create_task_comment` → actualización de versión (vN)

---

## PASO 6 — CONFIRMACIÓN FINAL

```
✅ Árbol de navegación generado — [CLIENTE] v[N].00

📋 Miro — Árbol: [URL del frame en el board]
📋 Miro — Bloques de contenido: [URL del documento en Miro, si se generó]
🗂️ ClickUp: [URL de la tarea] (nueva / actualizada con comentario)

⚠️ Pendiente manual:
  - Revisar el diagrama en Miro y ajustar posición de nodos si es necesario
  - Revisar y validar las propuestas de bloques de contenido con el equipo
  - Trasladar los bloques 💡 aprobados a la descripción de "Arquitectura website [CLIENTE]" en ClickUp
  - Checklist "CRITERIOS DE ACEPTACIÓN" en ClickUp
  - Campo ORDEN → asignar en Sprint Planning
  - Validación con el cliente antes de pasar a diseño UI/UX
```

---

## REFERENCIA — BOARD HOMEESPAÑA

Board de referencia: `https://miro.com/app/board/uXjVJMZC4G4=/`

Estructura de versiones en el board:
- Frame v1.00 → `3458764594810877774`
- Frame v2.00 → `3458764595784638855`
- Frame v3.00 → `3458764599341387688`

Usar con `Miro:context_get` para consultar versiones anteriores como referencia de estructura y decisiones tomadas.

---

## NOTAS IMPORTANTES

- **Validar antes de generar:** nunca crear el diagrama en Miro sin que el PO haya aprobado la estructura propuesta. Un diagrama mal posicionado en Miro es difícil de revertir.
- **Versiones en el mismo board:** siempre en el mismo board del proyecto, frames nuevos a la derecha. No crear boards nuevos por versión.
- **Diagrama grande → dos llamadas:** si el árbol supera ~50 nodos, dividir en dos diagramas (ej. Header + Navegación / Footer + Área privada) y posicionarlos en el mismo frame con coordenadas Y distintas.
- **Colores:** aplicar el sistema estándar Reinicia salvo instrucción explícita. Si el PO detecta inconsistencias con el board de referencia, reportarlo para ajustar este estándar.
- **Nivel de detalle:** el elegido en Pregunta 4 aplica a todos los nodos. No mezclar niveles en el mismo diagrama.
- **Producto ClickUp:** una sola tarea por proyecto independientemente del número de versiones. Las versiones se documentan como comentarios o actualizando la descripción.
- **Si no hay board de Miro:** indicar al PO que debe crear el board primero desde la interfaz de Miro y facilitar la URL. Claude no puede crear boards nuevos, solo trabajar dentro de boards existentes.
- **Análisis de bloques de contenido (Paso 3b):** no bloquea el árbol — se puede hacer en paralelo o después. Las propuestas 💡 aprobadas por el PO se incorporan al producto "Arquitectura website [CLIENTE]" en ClickUp, dentro del listado de plantillas y requisitos de arquitectura para UX.
- **Plantillas vs páginas:** para el análisis de bloques, Claude identifica qué nodos del árbol comparten la misma plantilla y genera una ficha por plantilla, no por página. Ej.: 5 páginas de "ficha de área" comparten una sola plantilla.
- **Webs de referencia:** si el PO no aporta URLs, Claude busca con `web_search` referentes del mismo sector y tipo de web. Siempre citar la fuente junto a cada propuesta de bloque.
- **Documentos en inglés:** si la propuesta o Sprint Cero está en inglés, el árbol se genera en el idioma de la web del cliente (o en el que indique el PO), no necesariamente en español.
