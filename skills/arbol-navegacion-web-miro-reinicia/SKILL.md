---
name: arbol-navegacion-web-miro-reinicia
description: Skill para crear árboles de navegación (sitemaps) de proyectos Web y WebApp en Miro para clientes de Reinicia, replicando la identidad visual de Reinicia (TARJETAS de colores vía layout_create, NO flowchart) y creando el producto correspondiente en ClickUp. El árbol se construye con CARDs de color por nivel jerárquico; la URL de cada página va dentro de la tarjeta (campo desc); admite iconos opcionales (internos de identidad o marcadores externos de conversión, validados con el PO) y bloques de contenido por plantilla dentro de la tarjeta. Actívala cuando el PO pida crear o actualizar el árbol de navegación, el sitemap, la arquitectura de páginas de una web en Miro, o el producto de Arquitectura Web en ClickUp; o cuando se mencione "árbol de navegación", "sitemap", "arquitectura de páginas", "estructura de la web" junto a un cliente. No usar para flujogramas conversacionales de WhatsApp (skill WABA Miro) ni para productos web genéricos sin componente de sitemap.
---

# SKILL: Árbol de Navegación Web en Miro — Reinicia

## Descripción
Esta skill permite a los Product Owners de Reinicia crear árboles de navegación (sitemaps) de proyectos Web y WebApp directamente en un board de Miro, siguiendo el estándar visual de Reinicia establecido en los proyectos HomeEspaña y BirdEase. Cubre dos outputs:

1. **El árbol en Miro** — generado con **tarjetas (CARDs) vía `Miro:layout_create`**, NO con un diagrama flowchart. Es la identidad visual real de Reinicia: tarjetas de colores por nivel jerárquico, dentro de un nuevo frame del board del proyecto.
2. **El producto en ClickUp** — tarea "Arquitectura website [CLIENTE]" en `General [CLIENTE]`.

**Principio iterativo:** cada versión del árbol ocupa un nuevo frame en el mismo board (v1.00, v2.00...). Las versiones anteriores se conservan. Claude siempre pregunta qué versión está creando y lee el board antes de colocar el frame nuevo.

> ⚠️ **Cambio de enfoque respecto a versiones anteriores de esta skill:** el sitemap NO se hace con `diagram_create`/flowchart. Se hace con tarjetas (`layout_create` + DSL de CARDs/TEXT). El conector de Miro **no crea conectores/flechas** por API, así que el árbol se lee por **columnas** (las hojas se colocan bajo su cabecera) y las flechas, si se quieren, son una pasada manual posterior.

---

## SISTEMA VISUAL REINICIA (tarjetas)

Spec extraída y validada de los boards de referencia (HomeEspaña y BirdEase). Se aplica **siempre** salvo instrucción explícita del PO.

### Colores (themes de CARD)
| Color | Hex | Uso |
|---|---|---|
| **Azul** | `#3812CF` | Nodo raíz (Home) y elementos funcionales transversales del header (Teléfono, Buscador, Login, CTAs tipo "Contact"/"Start now", selector de idiomas) |
| **Turquesa** | `#70EED6` | Cabeceras de navegación: categorías de la **navegación principal** y del **menú secundario** del header; también cabeceras de columna del footer |
| **Amarillo** | `#EBE31D` | Hojas: subpáginas / páginas de segundo nivel bajo una cabecera, y enlaces del footer |
| **Coral/Rojo** | `#D14351` | Páginas especiales: fichas de detalle, páginas dinámicas, landing pages específicas, apps externas |

> ⚠️ **Correcciones respecto a la versión anterior de la skill:**
> - El azul correcto es **`#3812CF`** (la versión antigua ponía `#3812CB`, erróneo).
> - El board de referencia usa **solo estos 4 colores** (sin gris). El footer va en **turquesa (cabeceras) + amarillo (enlaces)**, igual que la navegación. El gris `#E7E7E7` queda como **opción** del PO (p. ej. para restar peso a secundarios), **no como estándar**.

### Dimensiones y tipografía (valores exactos del board de referencia)
- **Tarjeta de cabecera** (Home, funcionales, categorías de nav, cabeceras de footer): `w=460.335` `h=94.9269`.
- **Tarjeta de hoja** (subpáginas, enlaces de footer, páginas especiales): `w=350.463` `h=72.27`.
- **Paso vertical entre hojas de una misma columna:** `112.87` (de centro a centro).
- **Cabeceras de bloque / títulos de sección** (TEXT): `font=open_sans` `size=36` `align=left|center`, texto en `<strong>…</strong>`, `color=#1a1a1a`, `fill=#ffffff` con `fill_opacity=0.0` (fondo transparente).
- **Frame:** `fill=#ffffff`, tamaño aprox. `w≈6002` `h≈5580` (ajustar al contenido real). Título del frame: `[NOMBRE CLIENTE] — Sitemap v[N].00`.
- **Etiqueta de la tarjeta:** solo el **nombre** de la página. La **URL va dentro de la tarjeta** (campo `desc`, visible al abrirla), no en la etiqueta.

---

## PASO 1 — ELICITACIÓN

Claude hace las preguntas de forma **secuencial**.

### Pregunta 1: Cliente y board
"¿Para qué cliente es el árbol de navegación? ¿Cuál es la URL del board de Miro del proyecto? (Claude no puede crear boards; si no existe, el PO lo crea primero y pasa la URL.)"

### Pregunta 2: Versión
"¿Es la primera versión (v1.00) o una iteración sobre una anterior? Si es iteración, ¿partimos del árbol anterior como base o hay cambios concretos?"

→ En cualquier caso, Claude **lee el board primero** (`board_search_boards` para localizarlo si hace falta, `layout_read`/`context_get` para ver frames existentes) y coloca la versión nueva en un **frame a la derecha** de lo existente, sin tocar lo anterior.

### Pregunta 3: Origen de la estructura
- **A) Claude la propone** (Sprint Cero, propuesta comercial, web actual, buenas prácticas) → la valida el PO antes de crear nada.
- **B) El PO aporta un borrador** → Claude lo estructura.
- **C) Ya está definida** → Claude la ejecuta.

→ Si A o B, presentar la estructura como **texto jerárquico** y esperar aprobación antes de tocar Miro.

### Pregunta 4: Nivel de detalle de los nodos
- **Básico:** solo nombre.
- **Medio:** nombre + URL (dentro de la tarjeta) + tipo de página.
- **Completo:** lo anterior + **bloques de contenido por plantilla** dentro de la tarjeta (ver Paso 3b).

### Pregunta 5: Secciones a incluir
"¿Qué secciones represento? Navegación principal, menú secundario del header, páginas especiales/dinámicas, footer… ¿todas? ¿El header tiene doble menú (principal + utilidades)?"

### Pregunta 6: Iconos (opcional)
"¿Quieres iconos en las tarjetas? Hay dos usos: (a) **icono interno** de identidad en nodos principales; (b) **marcador externo** (a la derecha, fuera de la tarjeta) para señalar páginas con un objetivo concreto (conversión por formulario, compra, consulta). **¿Qué tarjetas llevan icono y de qué tipo?** Esto lo decides tú o la persona del Equipo Operativo. ¿Y qué banco de iconos usamos?"

→ Ver Paso 4b. Si el PO no decide aún, se puede dejar para una pasada posterior.

### Pregunta 7: Producto en ClickUp
"¿Creo también el producto 'Arquitectura website [CLIENTE]' en `General [CLIENTE]`? Si es iteración, ya existe — solo añadiríamos comentario con el enlace al nuevo frame."

---

## PASO 2 — BÚSQUEDA DE INFORMACIÓN (si Claude propone la estructura)

Orden de consulta:
1. `00. Información > Empresa` → Sprint Cero.
2. `00. Información > Comercial` → Propuesta Comercial.
3. `01. Seguimiento` → actas recientes.
4. **Web actual del cliente** (`web_fetch`) — clave para enumerar páginas y, en el Paso 3b, bloques reales.
5. Board de Miro → versiones anteriores del árbol.

Herramientas: `ZohoWorkdrive_getFolderFiles` / `ZohoWorkdrive_downloadWorkDriveFile`, `Miro:layout_read` / `Miro:context_get`, `web_fetch` / `web_search`.

---

## PASO 3 — PROPUESTA DE ESTRUCTURA (texto, antes de Miro)

```
📐 ÁRBOL DE NAVEGACIÓN — [CLIENTE] v[N].00

🔵 Home + funcionales del header (Teléfono, CTA Contact, CTA Start, Login…)

🟦 Header Primary Navigation
   🟩 [Categoría 1]
      🟨 [hoja 1.1]
      🟨 [hoja 1.2]
   🟩 [Categoría 2] …

🟦 Header Secondary Menu  [si existe]
   🟩 [ítem] …

🟥 Páginas especiales / dinámicas
   🟥 [ficha de detalle], [landing], [app externa]…

🟦 Footer
   🟩 [Columna 1] → 🟨 enlaces…
   🟩 [Columna 2] → 🟨 enlaces…
   🟩 Legal & Social → 🟨 enlaces…

💡 Mejoras propuestas (con fuente), si las hay.

¿Apruebas esta estructura?
```

→ No tocar Miro hasta confirmación explícita.

---

## PASO 3b — BLOQUES DE CONTENIDO DENTRO DE LA TARJETA (opcional, nivel Completo)

Documenta, **dentro de cada tarjeta** (campo `desc`), de qué secciones se compone esa página/plantilla. Útil para alcance de rediseño y para que el cliente entienda cada plantilla. Se ejecuta si el PO lo pide o elige nivel Completo.

### Modelo (texto del `desc`, una sola línea física con `<p>…</p>`)
```
URL: <url completa>
Plantilla: <tipo de página>
Objetivo: <conversión / consulta / compra / informar…>  (si aplica)
Bloques:
<estado> <bloque 1>
<estado> <bloque 2>
…
```

### Taxonomía de tipos de bloque (genérica, reutilizable)
Hero/cabecera · Prueba social (logos) · KPIs/cifras · Bloque de feature (imagen + bullets + CTA) · Grid de features/servicios · Testimonios/reseñas · Formulario (contacto/demo/registro) · Listado dinámico · Ficha/detalle · Precios/planes · FAQ · CTA · Legal · Footer.

### Estados de cada bloque
- **✓ Existente** — ya está en la web actual.
- **✎ Mejora** — existe pero se propone rework.
- **＋ Nuevo** — no existe; propuesto.
- **⦸ Fuera de alcance** — queda fuera del alcance actual.

> Documentando la web **actual** todo va en ✓. Los estados ✎ / ＋ / ⦸ se usan al planificar rework o alcance de proyecto.

### Reglas
- **Por plantilla, no por página repetida.** Si 9 hojas comparten la plantilla "ficha de feature", se documenta el patrón una vez (o se replica el mismo `desc` patrón). Identificar qué nodos comparten plantilla.
- **Basado en la web real:** leer cada página con `web_fetch` y enumerar sus bloques reales antes de escribir.
- **Reversible:** el `desc` se edita con `layout_update` (las CARDs sí están en el DSL), así que se puede iterar sin problema.
- **Formato `desc`:** una sola línea física (sin saltos de línea reales, que romperían el DSL); usar `<p>…</p>` para los saltos. No usar comillas dobles dentro del `desc`.

### Ejemplo real (card "Home" de BirdEase)
```
<p>URL: https://birdeasepro.com/</p><p>Plantilla: Home (landing modular)</p><p>Objetivo: conversión (Free Trial / Demo)</p><p>Bloques:</p><p>✓ Hero: titular + subtítulo + CTA START TODAY + visual</p><p>✓ Prueba social: barra de logos</p><p>✓ What is BirdEase + KPIs (5 cifras)</p><p>✓ 7 bloques de feature (img + bullets + CTA)</p><p>✓ Formulario contacto/demo (conversión)</p><p>✓ Testimonios (carrusel)</p><p>✓ CTA final</p><p>✓ Footer</p>
```

---

## PASO 4 — GENERACIÓN DEL ÁRBOL EN MIRO (tarjetas)

> Las escrituras en Miro requieren **aprobación del usuario en el cliente**. Es habitual que el **primer intento** devuelva "No approval received": pedir OK al usuario y reintentar.

### 4.1 Leer el board y elegir hueco del frame
- `Miro:board_search_boards` (si no se tiene la URL) → localizar el board.
- `Miro:layout_read` del frame anterior (si lo hay) → entender la versión previa.
- Elegir coordenadas **board-absolutas** del nuevo frame a la derecha de todo lo existente (p. ej. `x` del borde derecho actual + margen).

### 4.2 Generar el DSL de CARDs con script + verificación
- Construir el DSL con un script (columnas: cada cabecera arriba y sus hojas debajo con paso `112.87`). Verificar que todas las coordenadas caen dentro del frame (`0 ≤ x,y` y dentro de `w,h`).
- Crear todo el frame en **una** llamada `Miro:layout_create`.

**Formato de cada línea del DSL:**
- Cabecera de bloque (título de sección): `TEXT … font=open_sans size=36 align=center "<strong>Nombre sección</strong>"` con fondo transparente.
- Tarjeta: `CARD … w=… h=… theme=#XXXXXX desc="<URL o bloques>" "Nombre de la página"`.
- Cabeceras → `w=460.335 h=94.9269`; hojas → `w=350.463 h=72.27`.
- `theme` según el color del nivel (ver Sistema Visual).
- `desc` = URL (nivel Básico/Medio) o el bloque de contenido completo (nivel Completo, Paso 3b).

### 4.3 Lectura por columnas (sin flechas)
El conector **no crea conectores/flechas**. El árbol se entiende por disposición: cada cabecera arriba de su columna y las hojas debajo. Si el cliente quiere flechas explícitas, es una **pasada manual** posterior (anotarlo en la confirmación final).

---

## PASO 4b — ICONOS (opcional, validado con el PO)

Hay **dos clases de icono**, y **qué tarjetas los llevan lo decide el PO / Equipo Operativo** (Paso 1, Pregunta 6):

1. **Icono interno (identidad/semántico)** — dentro de la tarjeta, pegado a la **derecha**. Para nodos principales (Home, categorías de nav, páginas con objetivo claro).
   - Offset desde el centro de la tarjeta: **+190 px** en cabeceras (`w≈460`), **+145 px** en hojas (`w≈350`). `y` = centro vertical de la tarjeta.
2. **Marcador externo (estado/objetivo)** — **fuera** de la tarjeta, a la derecha, ~**15 px** del borde derecho. Señala páginas con objetivo (conversión por formulario, compra, consulta). Puede ir en **cualquier nivel de profundidad**.

**Tamaño estándar:** **40 px** de ancho (alto proporcional).

### Banco de iconos — Material Symbols (Google Fonts Icons)
Banco oficial: https://fonts.google.com/icons. Estilo de Reinicia: **Outlined, peso 400, sin relleno**, monocromo (negro).

- Los iconos son **items de imagen** (`Miro:image_create`), **no** van en el DSL de CARDs.
- **Acceso por nombre vía CDN** (no se reutiliza ningún board; se elige el icono semánticamente correcto y las URLs son estables, no caducan):
  - Sin relleno: `https://cdn.jsdelivr.net/npm/@material-symbols/svg-400@latest/outlined/<nombre>.svg`
  - Con relleno: `https://cdn.jsdelivr.net/npm/@material-symbols/svg-400@latest/outlined/<nombre>-fill.svg`
  - `<nombre>` = nombre del icono en Material Symbols, en minúsculas y con guion bajo (p. ej. `home`, `call`, `mail`, `check_circle`, `shopping_cart`, `article`, `map`, `add`, `lock`, `search`).
  - Crear con `Miro:image_create(image_url=<URL CDN>, width=40, x, y)` apuntando al frame con `?moveToWidget=<frame_id>` (x/y relativos al frame).

**Mapeo orientativo por tipo de nodo / objetivo** (ajustar al sector con el PO):

| Nodo / objetivo | Material Symbol |
|---|---|
| Home / raíz | `home` |
| Teléfono / llamar (consulta) | `call` |
| Email / contacto / demo (consulta) | `mail` |
| Conversión por formulario / alta | `check_circle` |
| Compra / planes / pricing | `shopping_cart` |
| Blog / artículos | `article` |
| Ubicaciones / mapa | `map` |
| Features / funcionalidades | `widgets` (o `add`) |
| Acceso / login (área privada) | `lock` |
| Buscador | `search` |

⚠️ **Limitaciones del conector con imágenes (Material Symbols o cualquier otra fuente):**
- **No existe herramienta para mover ni borrar imágenes** (`layout_update` solo afecta a items del DSL; las imágenes se omiten como "unsupported"). Por tanto: **decidir la colocación antes de crear**, validar tamaño/posición con **un icono de prueba**, y reposicionar = el usuario borra a mano en Miro + Claude recrea.
- Las URLs de CDN de Material Symbols **no caducan**. Aun así, si un `image_create` falla puntualmente ("Unable to execute" o similar), reintentar.

### Alternativa secundaria — reutilizar iconos de otro board Miro
Solo si por algún motivo no se usa Material Symbols. Se reutiliza un icono ya presente en un board (p. ej. el banco temático inmobiliario del board HomeEspaña `uXjVJMZC4G4=`): `Miro:image_get_url` sobre el item del icono → URL pública firmada (`r.miro.com/…svg`) → `Miro:image_create(image_url=…, width=40, x, y)`.
> ⚠️ Esas URLs firmadas **caducan en pocos minutos**: **refrescar con `image_get_url` JUSTO ANTES de cada `image_create`**; si falla, casi siempre es URL caducada → refrescar y reintentar. Iconos de placeholder en ese board: casa `3458764594812751532`, carrito `3458764594813160335`, email `3458764594813482666`, check `3458764594907872030`, noticia `3458764594813482376`, mapa `3458764594813357263`, plus `3458764594813482319`, candado `3458764594815860223`.

---

## PASO 5 — PRODUCTO EN CLICKUP (si el PO lo solicitó)

Si es **v1.00**, crear tarea nueva **"Arquitectura website [CLIENTE]"** en `General [CLIENTE]`. Lo que distingue esta tarea de un sitemap genérico es que incluye el árbol de navegación, las plantillas necesarias, los macro/micro-objetivos por página y los criterios SEO básicos.

```
NOMBRE: Arquitectura website [CLIENTE]

DESCRIPCIÓN:
  Historia de usuario:
  Como [interlocutor cliente], QUIERO una arquitectura web clara
  (secciones, plantillas, tipos de página y flujos de navegación)
  alineada con negocio, marketing y SEO, PARA que el [rediseño / nueva
  web] sea escalable, mantenible y optimizado para conversión y SEO.

  Descripción:
  Web: [URL cliente]
  Objetivo Cliente: [qué hace la empresa y qué busca]
  Público objetivo: [perfiles]

  Ready to Backlog:
  - Objetivos de negocio identificados y priorizados.
  - Inventario inicial de contenidos y secciones actuales.
  - Públicos objetivo y journeys definidos.
  - Criterios SEO básicos acordados (URLs a respetar, términos clave).

  Entregables Internos Reinicia:
  - Mapa web/sitemap con niveles, páginas y objetivos
  - Listado de plantillas con descripción funcional y contenido a soportar
  - Documento de requisitos de arquitectura para UX y desarrollo
  - URLs clave a mantener/redirigir y nuevas URLs

  Entregables a Cliente:
  - Diagrama de arquitectura web (Miro) → [URL board/frame]
  - Árbol de navegación con macro/micro-objetivos por página

  Documentación de referencia:
  - Sprint Cero [CLIENTE]: [enlace]
  - Web actual: [URL]

SUBTAREAS:
  1. Análisis documentación y web actual
  2. Arquitectura web V1
  3. Validación Reinicia
  4. Validación Cliente
  [Por iteración: Arquitectura web V2 → Validación Reinicia → Validación Cliente]

CRITERIOS DE ACEPTACIÓN:
  ☐ Sitemap aprobado con todas las secciones y niveles.
  ☐ Cada página principal con macro-objetivo (y micro-objetivos cuando aplique).
  ☐ Listado de plantillas aprobado, con propósito y relación con el árbol.
  ☐ Documentado qué URLs clave se mantienen/cambian/redirigen (SEO).
  ☐ La estructura refleja objetivos de marketing y ventas.
  ☐ Acceso a cualquier sección clave en ≤3 clics desde Home.
  ☐ Arquitectura preparada para crecimiento futuro (secciones, landings, idiomas).
  ☐ [Interlocutor cliente] ha validado la arquitectura (escrito o acta).

CAMPOS PERSONALIZADOS:
  PROYECTO: [CLIENTE]
  TIPO DE PRODUCTO: DESARROLLO WEB
  PO: [Nombre PO]
  ÉPICA: PLANIFICACIÓN
  PBIs PRIMER NIVEL: [según acuerdo]
  REFINADO: Sí
  ORDEN: ⚠️ pendiente Sprint Planning
```

Si es **vN (iteración)**: añadir comentario a la tarea existente con el enlace al nuevo frame y un resumen de cambios; crear la subtarea "Arquitectura web V[N]" dentro de la tarea madre. No crear tarea nueva.

**Referencias ClickUp:**
- TI-MEDI: `869aeg8td` — Closed, estructura completa con V1 y V2.
- BirdEase: `869c513ey` — descripción detallada (objetivos, plantillas, SEO).
- HomeEspaña: sin producto de Arquitectura Web (arrancó en Maquetas/Plantillas).

Herramientas: `clickup_create_task`, `clickup_update_task`, `clickup_create_task_comment`.

---

## PASO 6 — CONFIRMACIÓN FINAL

```
✅ Árbol de navegación — [CLIENTE] v[N].00

📋 Miro — Frame: [URL del frame]
🗂️ ClickUp: [URL tarea] (nueva / actualizada)

⚠️ Pendiente manual:
  - Flechas/conectores entre nodos (no creables por API)
  - Iconos descartados en pruebas: borrar a mano (no hay borrado por API)
  - Validar bloques de contenido / iconos con el PO o Equipo Operativo
  - Checklist "CRITERIOS DE ACEPTACIÓN" en ClickUp
  - Campo ORDEN → Sprint Planning
  - Validación con el cliente antes de diseño UI/UX
```

---

## REFERENCIAS — BOARDS

- **HomeEspaña — Sitemap** (estándar visual y banco de iconos): `https://miro.com/app/board/uXjVJMZC4G4=/`
  - Frames de versiones: v1.00 `3458764594810877774`, v2.00 `3458764595784638855`, v3.00 `3458764599341387688`.
- **BirdEase — Arquitectura Web** (ejemplo completo con esta metodología): `https://miro.com/app/board/uXjVGk03Paw=/`
  - Frame Sitemap v2.00: `3458764674675713367` (tarjetas + iconos + bloques de contenido en `desc`).

Leer con `Miro:layout_read` para reutilizar estructura, spec y decisiones.

---

## LIMITACIONES TÉCNICAS DEL CONECTOR MIRO (importantes)

1. **Sin conectores/flechas por API** — el árbol se lee por columnas; flechas = pasada manual.
2. **Imágenes: solo crear** — no hay mover ni borrar. Decidir colocación antes de crear; validar con un icono de prueba; reposicionar = borrar a mano + recrear.
3. **Iconos:** banco principal = **Material Symbols** vía CDN (URLs estables, no caducan). Solo la **alternativa** de reutilizar iconos de otro board usa URLs firmadas que **caducan en minutos** → en ese caso refrescar con `image_get_url` justo antes de cada `image_create`.
4. **Escrituras requieren aprobación** del usuario en el cliente (el primer intento puede devolver "No approval received").
5. **`desc` en una sola línea física** — usar `<p>` para saltos; sin comillas dobles internas.
6. **CARDs sí son editables** vía `layout_update` (find-and-replace sobre el DSL); las imágenes no aparecen en ese DSL.

---

## NOTAS IMPORTANTES

- **Validar antes de crear:** nunca crear el frame sin que el PO apruebe la estructura en texto.
- **Versiones en el mismo board:** frames nuevos a la derecha; nunca boards nuevos por versión; leer el board primero.
- **Colores:** sistema estándar de 4 colores (`#3812CF` / `#70EED6` / `#EBE31D` / `#D14351`); gris opcional. Si se detecta inconsistencia con la referencia, reportarla para ajustar este estándar.
- **URL dentro de la tarjeta** (`desc`); etiqueta = solo el nombre.
- **Iconos:** banco = **Material Symbols** vía CDN (Outlined 400, sin relleno). Validar con el PO/Equipo Operativo qué tarjetas y qué clase (interno/externo); 40 px; interno a la derecha dentro (+190/+145), externo ~15 px fuera del borde.
- **Producto ClickUp:** una sola tarea por proyecto; las versiones se documentan con comentarios/subtareas.
- **Idioma:** el árbol se genera en el idioma de la web del cliente (castellano para clientes españoles, inglés para internacionales como BirdEase/Carritech), aunque el Sprint Cero esté en otro idioma.

---

## VERSIONES

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v2.1 | 2026-06-07 | Néstor + Claude | Banco de iconos pasa a **Material Symbols** (Google Fonts Icons, estilo Outlined peso 400 sin relleno, monocromo negro), con **acceso por nombre vía CDN jsDelivr** (`@material-symbols/svg-400@latest/outlined/<nombre>.svg`) y mapeo orientativo por tipo de nodo; las URLs de CDN son estables (no caducan). La reutilización de iconos de otro board queda **degradada a alternativa secundaria**. Probado con el icono `home` en el board BirdEase. | Reescritura tras el piloto BirdEase: el sitemap pasa de flowchart (`diagram_create`) a **tarjetas** (`layout_create`); spec visual exacta (themes, tamaños 460.335×94.9269 / 350.463×72.27, paso 112.87, Open Sans 36, frame ≈6002×5580); corrección de color azul a `#3812CF` y footer en turquesa+amarillo (gris opcional); URL dentro de la tarjeta (`desc`); nuevo Paso 4b de **iconos** (dos clases, reutilización del banco vía `image_get_url`→`image_create`, 40 px, refresco de URLs caducas, sin mover/borrar); reescritura del Paso 3b de **bloques de contenido dentro de la tarjeta** (modelo URL/Plantilla/Objetivo/Bloques + taxonomía + 4 estados); documentadas limitaciones del conector (sin flechas, aprobación de escrituras). |
| v1.x | — | Néstor + Claude | Versión inicial basada en flowchart `diagram_create` y bloques de contenido como documento Miro aparte (sustituida por v2.0). |
