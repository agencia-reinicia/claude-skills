---
name: analisis-llamadas-reinicia
description: "Usa esta skill cuando el usuario suba una transcripción de una llamada con un cliente de Reinicia y pida analizarla. Triggers: 'analiza esta llamada', 'analiza la transcripción', 'resumen de la llamada', 'qué pasó en la llamada', o cuando se adjunte un fichero .vtt o transcripción y el contexto sea una llamada (comercial, de seguimiento, de onboarding, de soporte o cualquier otro tipo) con un cliente. También se activa si el usuario menciona 'llamada' junto con un cliente o proyecto. No usar para reuniones de equipo interno sin cliente, ni para generar actas formales de reunión (para eso está la skill actas-reinicia)."
---

# Skill: Análisis de Llamadas con Cliente — Reinicia

> **Versión vigente: v1.7 — 07/07/2026** · ver changelog al final (`## Versiones`)

## Descripción general

Esta skill analiza la transcripción de una llamada con un cliente de Reinicia y produce:

1. **Un resumen estructurado en el chat** con 5 epígrafes (incluyendo análisis emocional)
2. **Un `.docx` con formato corporativo Reinicia** — solo si el usuario lo solicita o confirma

El foco es dar al Product Owner una lectura rápida, operativa y relacional de la llamada: qué se dijo, qué se acordó, y cómo estaba la sala.

---

## Inputs necesarios

Antes de ejecutar, Claude debe tener o solicitar:

1. **Transcripción de la llamada** — obligatorio. Formatos aceptados:
   - `.vtt` — leer con `cat` (texto plano con marcas de tiempo)
   - `.txt` — leer con `cat` (si > 20KB, usar `head` primero para orientarse)
   - `.docx` — extraer con `pandoc fichero.docx -t markdown`
   - `.doc` — convertir primero a `.docx` con LibreOffice, luego `pandoc`

   Si el contenido ya está visible en el contexto (bloque `<documents>`), usarlo directamente sin leer el fichero.
2. **Cliente** — nombre del cliente — puede inferirse del contenido o del contexto
3. **Fecha de la llamada** — puede inferirse del `.vtt` o preguntarse
4. **Tipo de llamada** — **inferir siempre del contenido**; solo preguntar si hay ambigüedad genuina tras leer la transcripción

Si falta algún dato no inferable, preguntarlo antes de continuar.

> **Idioma de salida.** Redactar el resumen en chat y el `.docx` en el **idioma del cliente**: castellano para clientes españoles, inglés para internacionales (p.ej. HomeEspaña, Carritech). Inferirlo de la transcripción y del cliente. **Si no se tiene certeza, preguntar al usuario** antes de generar.

---

## Paso 1 — Procesar la transcripción

Leer el fichero `.vtt` o texto de transcripción y extraer:

> **Regla de lectura (obligatoria).** Leer **SIEMPRE la transcripción completa** antes de analizar. No saltar entre rangos de líneas: el análisis emocional y el perfil reptil dependen de matices que aparecen en cualquier punto de la llamada. Si el fichero es grande, `head` sirve solo para **orientarse**, no para sustituir la lectura íntegra.
>
> **Detección de subida duplicada.** Si llega una **segunda transcripción** que parece aportar contenido nuevo, verificar primero si es **duplicado** de la anterior (fecha, participantes, hora de inicio y fin) antes de tratarla como una llamada distinta. Si es la misma llamada con transcripción más completa, actualizar el análisis, no crear uno nuevo.

- Participantes y sus roles (inferir empresa si no se indica)
- **Tipo de llamada** — inferirlo del contenido. Categorías orientativas:
  - *Comercial / propuesta*: se discute precio, alcance, propuesta, "cómo trabajamos"
  - *Seguimiento de proyecto*: revisión de tareas, incidencias, estado de entregas
  - *Onboarding*: primera toma de contacto operativa tras contratación
  - *Soporte / incidencia*: resolución de un problema concreto
  - *Fricción / conflicto*: tensión explícita, queja, renegociación
  - *Mixta*: combina elementos de más de una categoría
- Contenido sustantivo por bloques temáticos
- Momentos de acuerdo, tensión, duda o resistencia
- **Ideas tratadas** — ideas, propuestas o sugerencias surgidas en la llamada (aunque no se cierren). Para cada una: idea, descripción breve, quién la aportó (nombre + empresa), grado de aceptación del cliente (`Sí` / `Con matices` / `No` / `Pendiente` si no se pronunció) y app(s) involucradas. No forzar ideas inexistentes: si no hubo, omitir el epígrafe.
- Compromisos y próximos pasos mencionados
- Señales emocionales y relacionales por interlocutor

**Si el tipo inferido es comercial/propuesta**, y no hay contexto previo del cliente en la conversación, preguntar antes de continuar el análisis:

> He detectado que es una llamada de tipo comercial. Para enriquecer el análisis (especialmente el perfil reptil y la recomendación relacional), ¿tienes alguna referencia del cliente? Por ejemplo: web, LinkedIn, sector, tamaño de empresa o cualquier contexto relevante que quieras añadir.

Si el usuario proporciona una URL → usar `web_fetch` para obtener contexto del cliente antes de generar el análisis. Si no tiene referencia o prefiere continuar sin ella → proceder igualmente.

---

## Paso 2 — Generar el resumen en chat

Presentar directamente en el chat el análisis estructurado en **6 epígrafes**:

---

### Estructura del resumen en chat

```
## 📞 Análisis de llamada — [Cliente] · [Tipo detectado] · [Fecha]

> ⚠️ **Uso interno Reinicia** — contiene análisis emocional y perfil reptil; no compartir con el cliente.

> 🔍 Tipo de llamada detectado: **[Comercial / Seguimiento / Onboarding / Soporte / Fricción / Mixta]**  
> *(Si no es correcto, indícalo y reajusto el análisis)*

---

### 1. Participantes
[Nombre] | [Rol] | [Empresa]
...

---

### 2. Contexto y objetivo de la llamada
Breve párrafo describiendo el propósito de la llamada y el momento del proyecto
en que se produce.

---

### 3. Resumen de contenido
Desarrollo por bloques temáticos. Usar:
- **Negrita** para conceptos técnicos clave, decisiones, datos relevantes
- *Cursiva* para ejemplos concretos, citas aproximadas o anécdotas ilustrativas

#### 3.1 [Primer tema]
[Texto]

#### 3.2 [Segundo tema]
[Texto]
...

---

### 4. Ideas tratadas
Tabla en markdown (omitir el epígrafe si no hubo ideas reseñables):

| Idea | Descripción | Aportada por | Aceptación cliente | App(s) involucradas |
|------|-------------|--------------|--------------------|---------------------|
| ...  | ...         | Persona (Empresa) | Sí / Con matices / No / Pendiente | ... |

Orden: en el que surgieron en la llamada. Aceptación cliente: vocabulario controlado
**Sí / Con matices / No / Pendiente** ("Pendiente" = el cliente no se pronunció).

---

### 5. Decisiones y próximos pasos
Tabla en markdown:

| Acción | Responsable | Plazo | Estado |
|--------|-------------|-------|--------|
| ...    | ...         | ...   | Pendiente |

Ordenar: primero acciones de Reinicia, después acciones del cliente.

---

### 6. Análisis emocional

#### Tono general
[Párrafo breve: ¿cómo fue el clima de la llamada? ¿fluida, tensa, cordial, distante, 
resolutiva, ambigua?]

#### Momentos clave
Lista de momentos concretos de la llamada con carga emocional relevante:
- ⚡ **[Momento de tensión]** — [descripción breve + contexto]
- ✅ **[Momento de acuerdo o alineación]** — [descripción breve]
- ❓ **[Momento de duda o ambigüedad]** — [descripción breve]
- 🤝 **[Momento de confianza o vínculo]** — [descripción breve]

Usar solo los iconos relevantes. No forzar momentos si no existen con claridad.

#### Análisis por interlocutor
Para cada participante relevante (normalmente cliente + PO Reinicia):

**[Nombre]** ([Empresa])
- *Postura*: [quién lidera, quién escucha, quién presiona, quién cede]
- *Señales positivas*: [apertura, validaciones, humor, agradecimiento...]
- *Señales de riesgo*: [evasivas, silencios significativos, resistencia encubierta, 
  compromisos vagos...]
- *Palanca clave*: [qué le mueve, qué le preocupa, cómo hay que trabajar con esta persona]

#### Perfil reptil
Análisis basado en los impulsos subconscientes del cerebro reptiliano (neuroventas).
El encuadre varía según el tipo de llamada detectado:

- **Llamada comercial / propuesta / negociación:**  
  Identificar qué impulso primario domina en cada interlocutor clave del cliente:
  - 🦎 *Supervivencia*: miedo a perder algo (dinero, tiempo, reputación, control)
  - 🏰 *Seguridad*: necesidad de certeza, predictibilidad, pruebas de que funcionará
  - 👑 *Poder / dominancia*: necesidad de sentir que decide, que lidera, que gana estatus

  Para cada impulso identificado, señalar: qué lo activa en esta persona, qué lo amenaza,
  y cómo puede Reinicia posicionarse para activar el impulso positivo (oportunidad) 
  en lugar del negativo (resistencia).

- **Llamada de seguimiento / soporte / onboarding:**  
  Foco en seguridad y control. Señalar si el cliente se siente en territorio seguro con 
  Reinicia o si hay ansiedad de fondo (aunque no se verbalice). Indicar qué gestos 
  o mensajes reforzarían la sensación de control del cliente.

- **Llamada de fricción / conflicto / incidencia:**  
  Aquí el reptil está más activo. Identificar qué impulso está herido (¿se siente amenazado, 
  desprotegido, ignorado?) y qué necesita escuchar para volver a un estado de colaboración.

Formato de salida:

**[Nombre del interlocutor cliente]**
- *Impulso dominante detectado*: [Supervivencia / Seguridad / Poder — o combinación]
- *Qué lo activa en esta llamada*: [señales concretas de la transcripción]
- *Riesgo reptil*: [qué podría desencadenar resistencia o bloqueo]
- *Palanca reptil*: [qué mensaje o gesto de Reinicia podría activar el impulso positivo]

Si hay más de un interlocutor relevante del cliente, analizar a cada uno por separado.
Si la transcripción no ofrece suficiente material para este análisis, indicarlo brevemente 
en lugar de forzar conclusiones.

#### Recomendación relacional
1-3 frases de cierre con la lectura estratégica para el PO: cómo llegar al siguiente 
paso con esta persona, qué evitar, qué reforzar. Integrar si procede la lectura reptil.
```

---

## Paso 3 — Ofrecer el `.docx`

Al final del resumen en chat, preguntar siempre:

> ¿Quieres que genere también el documento `.docx` con formato corporativo Reinicia para subir a Workdrive?

Si el usuario confirma → preguntar a continuación dónde debe guardarse:

> ¿Dónde debe guardarse este análisis en Workdrive?
> - 📁 **Proyectos Activos** — cliente en curso
> - 🤝 **Amigo Reinicia** — llamada transversal con un colaborador externo (no ligada a un cliente concreto)
> - 💼 **Comercial** — carpeta Comercial genérica
> - 💬 **Comercial WhatsApp** — contacto iniciado por WhatsApp
> - 🔵 **Comercial Zoho** — contacto gestionado vía Zoho CRM

Una vez elegida la opción, buscar dinámicamente la carpeta en Workdrive (ver **Búsqueda dinámica de carpeta** más abajo) antes de generar el fichero.

Si el usuario ya pidió el `.docx` desde el principio → preguntar la carpeta de destino antes de generarlo, sin esperar al final.

---

## Paso 4 — Generar el `.docx` (solo si se solicita)

Leer primero la skill de docx:
```
/mnt/skills/public/docx/SKILL.md
```

Usar Node.js con `docx` para generar el fichero con el mismo stack que la skill de actas — **incluido el embebido de fuentes Manrope**. Seguir la subsección canónica **"Embebido de fuentes Manrope (OBLIGATORIO)"** de `marca-reinicia`: leer los estáticos `Manrope-Regular.ttf` / `Manrope-Bold.ttf` del ZIP de Workdrive, declarar el array `fonts:` con **dos nombres distintos** (`Manrope Regular` / `Manrope Bold`) en el constructor `Document`, y **tras generar ejecutar `patch_fonts.py`** (fontKey en mayúsculas + `<w:embedTrueTypeFonts/>`). Verificar con `pdffonts` que ambas Manrope salen `emb=yes`.

### Nombre del fichero

```
YYYYMMDD-Analisis-Llamada-[Descripcion]-[CLIENTE]-INTERNO
```

Ejemplos:
- `20260401-Analisis-Llamada-Seguimiento-Zoho-CRM-GONHER-INTERNO`
- `20260415-Analisis-Llamada-Comercial-Propuesta-Soporte-HOMEESPANA-INTERNO`

Reglas: sin tildes, sin espacios (guiones), CLIENTE en mayúsculas. **Sufijo `-INTERNO` siempre**: el análisis contiene perfil reptil y análisis emocional y es de uso interno (ver banner de confidencialidad).

### Estructura del `.docx`

Misma cabecera corporativa que las actas (logo + nombre fichero + línea azul **debajo de toda la cabecera**).

#### Reglas estrictas de estilo

**1. Cabecera — patrón obligatorio: tabla de 3 columnas SIN bordes.**

Estructura: `[logo a la izquierda] | [hueco central] | [nombre del fichero a la derecha]`. Las celdas deben llevar `verticalAlign: VerticalAlign.CENTER` para que el nombre del fichero quede centrado verticalmente respecto al logo. La línea separadora azul (`#3812CF`) va en un **párrafo independiente debajo de la tabla**, nunca como `border-bottom` del párrafo del nombre del fichero (eso pega el texto a la línea, defecto observado).

```javascript
// Patrón correcto (resumido)
const NO_BORDER = { style: BorderStyle.NONE, size: 0, color: "FFFFFF" };
const noBorders = { top: NO_BORDER, bottom: NO_BORDER, left: NO_BORDER, right: NO_BORDER, insideHorizontal: NO_BORDER, insideVertical: NO_BORDER };

function noBorderCell(paragraphs, width) {
  return new TableCell({
    width: { size: width, type: WidthType.DXA },
    borders: noBorders,
    verticalAlign: VerticalAlign.CENTER,  // <- clave
    margins: { top: 0, bottom: 0, left: 0, right: 0 },
    children: paragraphs
  });
}

const headerTable = new Table({
  width: { size: 9506, type: WidthType.DXA },
  columnWidths: [3500, 1000, 5006],
  borders: noBorders,
  rows: [new TableRow({ children: [
    noBorderCell([logoPara], 3500),
    noBorderCell([new Paragraph({})], 1000),
    noBorderCell([filenamePara], 5006)
  ]})]
});

const separatorLine = new Paragraph({
  spacing: { before: 60, after: 60 },
  border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: "3812CF", space: 1 } },
  children: [new TextRun({ text: "", font: "Manrope Regular", size: 2 })]
});

return new Header({ children: [headerTable, separatorLine] });
```

**2. Líneas horizontales decorativas en el cuerpo: PROHIBIDAS.**

La única línea azul `#3812CF` permitida en todo el documento es la que va dentro de la cabecera. **No** usar bordes inferiores ni superiores azules como separador entre secciones, entre el bloque de metadatos y el cuerpo, ni antes de la nota final. Esto incluye también líneas grises, naranjas o de cualquier otro color: el cuerpo va limpio. La separación entre bloques se consigue con espaciado (`spacing.before` / `spacing.after`) y con la propia tipografía de los headings, nunca con líneas decorativas.

**3. Bordes de la tabla de Decisiones: blancos en TODAS las celdas.**

Toda la tabla de Decisiones lleva bordes blancos (`#FFFFFF`) — incluidas las celdas de cabecera, las filas-categoría (Reinicia / Cliente) y las filas de datos. La legibilidad la dan las bandas alternas (blanco / `#EBEBEB`) y el fondo lila (`#D9D0FB`) de la cabecera y de las filas-categoría. **No usar bordes grises ni de ningún otro color**: si se omiten en alguna fila (típicamente en la fila-categoría con `columnSpan`), Word/LibreOffice aplican bordes negros por defecto. Definir siempre los cuatro bordes (`top`, `bottom`, `left`, `right`) explícitamente en blanco en cada `TableCell`, sin excepciones.

```javascript
// Patrón correcto para cualquier celda de la tabla
const whiteBorder = { style: BorderStyle.SINGLE, size: 4, color: "FFFFFF" };
borders: { top: whiteBorder, bottom: whiteBorder, left: whiteBorder, right: whiteBorder }
```

**4. Cabecera de la tabla de Decisiones: lila `#D9D0FB`, no azul.**

La cabecera de la tabla usa fondo lila `#D9D0FB` con texto en negro de heading `#0D0D0D` (alineado con el patrón canónico de la skill `marca-reinicia`). **Nunca azul saturado `#3812CF` con texto blanco**: ese azul se reserva para acentos puntuales (líneas separadoras, énfasis tipográficos), no como fondo de cabecera de tabla.

**5. Tabla de "Ideas tratadas": mismo estilo que la de Decisiones, 5 columnas, sin bloques-categoría.**

Reutilizar el builder `makeIdeasTable` del stack de la skill de actas (idéntico aquí). Cabecera lila `#D9D0FB` texto negro `#0D0D0D`, bordes BLANCOS en todas las celdas, filas alternas blanco/`#EBEBEB`, **sin filas-categoría** (la columna "Aportada por" ya indica el origen). Columnas: `Idea | Descripción | Aportada por | Aceptación cliente | App(s) involucradas`.

- **Aceptación cliente**: vocabulario controlado `Sí` / `Con matices` / `No` / `Pendiente` ("Pendiente" cuando el cliente no se pronunció). No usar otros valores.
- **Aportada por**: nombre + empresa entre paréntesis (`Paolo (Reinicia)`, `Robin (HomeEspaña)`).
- **App(s)**: nombres en **texto plano** (Zoho CRM, WordPress, WhatsApp/WABA, Zoho Forms, Cloudways…). **No usar emojis** en el `.docx`.
- **Orden**: en el que surgieron en la llamada. Omitir el bloque si no hubo ideas reseñables.

**6. Banner de confidencialidad (OBLIGATORIO en este `.docx`) + pie de página.**

El análisis contiene Perfil reptil y Análisis emocional (datos personales de personas identificadas). Es de **uso interno**. Por eso, a diferencia de las actas, este documento lleva SIEMPRE:

- **Banner arriba del cuerpo**, justo bajo la cabecera y antes del título: caja de una celda a todo el ancho, fondo **Rojo Reinicia `#D14351`**, texto **blanco `#FFFFFF` en negrita**, centrado, bordes blancos. Texto: `CONFIDENCIAL · USO INTERNO REINICIA · NO COMPARTIR CON EL CLIENTE`. (El rojo es color de marca — "generador de atención"; es la única excepción al uso de color fuera de cabecera/tablas, y es intencionada.)
- **Pie de página en todas las hojas** (`Footer`), texto pequeño rojo `#D14351`: `CONFIDENCIAL · USO INTERNO REINICIA`.

```javascript
const REINICIA_RED = "D14351";
const confBanner = new Table({
  width: { size: 9026, type: WidthType.DXA }, columnWidths: [9026],
  rows: [ new TableRow({ children: [ new TableCell({
    width: { size: 9026, type: WidthType.DXA },
    shading: { fill: REINICIA_RED, type: ShadingType.CLEAR },
    borders: { top: whiteBorder, bottom: whiteBorder, left: whiteBorder, right: whiteBorder },
    margins: { top: 80, bottom: 80, left: 120, right: 120 },
    children: [ new Paragraph({ alignment: AlignmentType.CENTER, children: [ new TextRun({
      text: "CONFIDENCIAL · USO INTERNO REINICIA · NO COMPARTIR CON EL CLIENTE",
      font: "Manrope Bold", size: 22, bold: true, color: "FFFFFF"
    })] }) ]
  })] }) ]
});
// El banner va como primer hijo del cuerpo (children[0]), antes del título H1.
// Footer en cada página:
const confFooter = new Footer({ children: [ new Paragraph({ alignment: AlignmentType.CENTER, children: [ new TextRun({
  text: "CONFIDENCIAL · USO INTERNO REINICIA", font: "Manrope Bold", size: 16, bold: true, color: REINICIA_RED
})] }) ] });
// Añadir en la sección:  footers: { default: confFooter }
```

#### Estructura de contenido

```
CABECERA (tabla 3 col sin bordes: logo | hueco | nombre fichero — vAlign CENTER
          + línea separadora azul #3812CF DEBAJO de la tabla)

🔴 BANNER CONFIDENCIAL (primer elemento del cuerpo): caja roja #D14351, texto blanco
   negrita centrado "CONFIDENCIAL · USO INTERNO REINICIA · NO COMPARTIR CON EL CLIENTE"

Título principal: "Análisis de llamada — [Descripción]"  [H1 grande]
Bloque metadatos: Cliente · Tipo · Fecha (en línea, SIN línea separadora azul debajo)

1_Participantes          [H1]
  [Subrayado por empresa, bullets por persona]

2_Contexto y objetivo    [H1]
  [Párrafo]

3_Resumen de contenido   [H1]
  3.1 [Subtema]          [H2]
  [Texto con negritas/cursivas]

4_Ideas tratadas         [H1]
  [Tabla corporativa de 5 columnas, mismo estilo que la de Decisiones pero SIN
   filas-categoría: cabecera #D9D0FB (lila) texto #0D0D0D, filas alternas
   blanco/#EBEBEB, bordes BLANCOS en todas las celdas]
  Columnas: Idea | Descripción | Aportada por | Aceptación cliente | App(s) involucradas
  Aceptación cliente ∈ { Sí, Con matices, No, Pendiente }
  App(s) en texto plano (sin emojis en el .docx). Omitir el bloque si no hubo ideas.

5_Decisiones y próximos pasos  [H1]
  [Tabla corporativa: cabecera #D9D0FB (lila) con texto #0D0D0D, filas-categoría
   #D9D0FB, filas alternas blanco/#EBEBEB, bordes BLANCOS en todas las celdas]
  Columnas: Acción / Decisión | Responsable | Plazo | Estado
  Bloques: Reinicia primero, cliente después

6_Análisis emocional     [H1]
  6.1 Tono general       [H2]
  [Párrafo]
  6.2 Momentos clave     [H2]
  [Lista con iconos ⚡ ✅ ❓ 🤝]
  6.3 Análisis por interlocutor  [H2]
  [Bloque por persona con etiquetas Postura / Señales positivas / Señales de riesgo / Palanca clave]
  6.4 Perfil reptil      [H2]
  [Bloque por interlocutor cliente con: Impulso dominante / Qué lo activa / Riesgo reptil / Palanca reptil]
  6.5 Recomendación relacional   [H2]
  [Párrafo de cierre estratégico integrando lectura reptil si procede]

REVISIÓN PO
  ☐  He revisado el análisis y confirmo que refleja correctamente la llamada.
  Product Owner: _______________     Fecha: _______________

⚠️ Nota final: CONDICIONAL según cobertura/calidad de la transcripción (coherente con las Notas de diseño)
   - Transcripción completa → "Análisis redactado a partir de la transcripción completa de la llamada..."
   - Transcripción parcial / baja calidad → indicarlo explícitamente (no afirmar "completa")
   (sin línea horizontal azul antes de la nota — solo espaciado)

PIE DE PÁGINA (todas las hojas): "CONFIDENCIAL · USO INTERNO REINICIA" en rojo #D14351 pequeño
```

### Logo corporativo

El logo real de Reinicia se obtiene descargando el fichero `TEST-Merge-Store-HomeEspana.docx` (ID Workdrive: `okcqm65a2ea3684c2473583559fb91f0c3a59`) y extrayendo `word/media/image3.png`:

```python
import json, base64, zipfile, io
raw = json.load(open('<tool_result_path>'))
data = json.loads(raw[0]['text'])
docx_bytes = base64.b64decode(data['content'])
with zipfile.ZipFile(io.BytesIO(docx_bytes)) as z:
    with open('/home/claude/logo_reinicia.png', 'wb') as out:
        out.write(z.read('word/media/image3.png'))
```

**Nunca generar el logo sintéticamente** — siempre extraerlo de esta fuente.

### Identidad visual

Usar los mismos valores que la skill de actas:

| Elemento | Valor |
|----------|-------|
| Color corporativo principal | `#3812CF` |
| Color corporativo secundario | `#D9D0FB` |
| Fondo fila alterna tabla | `#EBEBEB` |
| Color texto cuerpo | `#545454` |
| Color headings H1 | `#0D0D0D` |
| Color headings H2 | `#0D0D0D` |
| Fuente | `Manrope Regular` / `Manrope Bold` (familias canónicas, **embebidas**; respaldo `Manrope` solo si no se puede embeber) |
| H1 | 36pt |
| H2 | 18pt |
| Cuerpo | 12pt |
| Logotipo | `/home/claude/logo_reinicia.png` |
| Fuentes embebidas | `manrope/static/Manrope-Regular.ttf` + `Manrope-Bold.ttf` — del ZIP de Workdrive (resource_id `a2xhx44f0cbde39da4b6ba1186a213b92ebfd`); usar los estáticos, no la variable. Ver `marca-reinicia`. |

Ejecutar con:
```bash
# 0) PRERREQUISITO — logo y fuentes Manrope en /home/claude (ver "Embebido de fuentes Manrope" en marca-reinicia):
#    logo_reinicia.png  +  manrope/static/Manrope-Regular.ttf  y  Manrope-Bold.ttf (estáticos del ZIP de Workdrive)
cd /home/claude && node build_analisis.js
# build_analisis.js escribe /home/claude/<FILENAME>.docx — validar ESE fichero, no "output.docx"

# 1) Parche de fuentes embebidas (OBLIGATORIO): fontKey en mayúsculas + <w:embedTrueTypeFonts/>
python3 patch_fonts.py "/home/claude/<FILENAME>.docx"

# 2) Validación estructural
python3 /mnt/skills/public/docx/scripts/office/validate.py "/home/claude/<FILENAME>.docx"

# 3) Sanity de fuentes embebidas — deben aparecer Manrope-Regular y Manrope-Bold con emb=yes:
soffice --headless --convert-to pdf "/home/claude/<FILENAME>.docx" --outdir /home/claude >/dev/null 2>&1 \
  && pdffonts "/home/claude/<FILENAME>.pdf" | grep -i manrope \
  || echo "⚠️ REVISAR: Manrope no aparece embebida en el render"
```

---

## Paso 5 — Entregar el `.docx`

Copiar a `/mnt/user-data/outputs/` y presentar con `present_files`.

Indicar al usuario:
1. Descargar el `.docx`
2. Copiarlo a Zoho Workdrive vía **Truesync**:  
   `Proyectos Activos › [Cliente] › 01. Seguimiento › Actas de Reuniones`  
   (crear la carpeta si no existe)
3. Convertirlo a **Zoho Writer** (clic derecho → Abrir con → Zoho Writer)
4. Marcar el **checkbox de revisión** del PO una vez revisado

---

## Paso 6 — Registro opcional en ClickUp / Zoho CRM

Preguntar **siempre** al usuario si quiere dejar constancia del análisis y, en su caso, dónde. Destino **único** (no multi-destino):

```
¿Quieres dejar registro de este análisis en algún sitio?
  🟢 ClickUp — tarea de Gestión del Proyecto del cliente
  💼 Zoho CRM — Oportunidad (Deal)   → la nota se asocia también al Contacto del Deal
  👤 Zoho CRM — Ficha de Contacto
  ⛔ No dejar registro
```

Si elige **No dejar registro** → terminar aquí. En llamadas comerciales de prospecto sin tarea de Gestión, el destino natural suele ser el Deal o la Ficha de Contacto en Zoho CRM.

### 6.1 Enlace al documento
Preguntar *"¿Ya tienes el enlace de Workdrive?"*. Si **sí** → incrustar la URL; si **no** → dejar la línea `(pega aquí el enlace tras subir el documento a Workdrive)` y recordárselo al final.

### 6.2 Cuerpo del registro (común a los tres destinos)
Texto **plano**, sin markdown ni hipervínculos, con la URL en su línea. **Es un resumen**: incluye datos de la llamada, el bloque **Ideas tratadas** y el enlace. **No volcar en la nota/comentario el Análisis emocional ni el Perfil reptil** — son de uso interno y van solo en el `.docx`.

```
Análisis de llamada — [Cliente] — [DD/MM/YYYY]

Tipo: [Comercial / Seguimiento / Onboarding / Soporte / Fricción / Mixta]
Participantes: [Nombres clave de cada parte]

Ideas tratadas:
[Sí] [Idea] ([Aportada por]) — [App(s)]
[Con matices] [Idea] ([Aportada por]) — [App(s)]
[No] [Idea] ([Aportada por]) — [App(s)]
[Pendiente] [Idea] ([Aportada por]) — [App(s)]

Ubicación en Zoho Workdrive: Proyectos Activos › [Cliente] › 01. Seguimiento › Actas de Reuniones
Archivo: [NOMBRE_FICHERO]
[URL del documento o placeholder]

Pendiente de revisión y validación por el Product Owner.
```

Omitir el bloque "Ideas tratadas" si no hubo ideas reseñables.

### 6.3 Destinos
Misma mecánica que la skill de actas (sección "Paso 5 — Registro opcional"):
- **ClickUp** → comentario en `Gestión [Mes] [Año] [CLIENTE]` (texto plano; sin markdown/HTML/hipervínculos). Caso especial: si la llamada es transversal con un **Amigo Reinicia**, el comentario va a `Gestión [Mes] Marketing [REINICIA]` (lista `3350803`), no a la Gestión de un cliente.
- **Zoho CRM – Oportunidad (Deal)** → Nota con `ZohoCRM_createNotes` (parent = Deal) y la misma Nota en el Contacto asociado del Deal (leerlo vía Contacto principal o `ZohoCRM_getAssociatedContactRoles`).
- **Zoho CRM – Ficha de Contacto** → Nota con `ZohoCRM_createNotes` (parent = Contacto).

Buscar y proponer el registro para confirmar (Deal por nombre de cliente; Contacto por nombre/email del participante), igual que con las carpetas de Workdrive.

---

## Tabla de referencia — IDs raíz de carpetas Workdrive

Estos IDs son estables y no cambian. Son los puntos de entrada para la búsqueda dinámica.

| Carpeta raíz | ID |
|---|---|
| Proyectos Activos (Team Folder raíz) | `2km7j8be2bc8587ca4a01b6f044678ca4309e` |
| Amigos Reinicios (`Agencia Reinicia › 00. Seguimiento y Control › Amigos Reinicios`) | `62rwt1fabec685e80405c8a1e79be2046fe48` |
| ↳ Agencia Reinicia | `5mzblac5a403d578e4e5eaecf9a153cb6cbe8` |
| ↳ 00. Seguimiento y Control | `572lgc3c39a1f1e0648968f1bac1ab001ac67` |

> Las carpetas de Comercial, Comercial WhatsApp y Comercial Zoho se localizan dinámicamente desde la raíz del workspace. Si en algún momento se conoce su ID directo, añadirlo aquí para acelerar la búsqueda.

---

## Búsqueda dinámica de carpeta en Workdrive

Ejecutar **antes de generar el `.docx`**, una vez el usuario ha indicado el tipo de destino.

### Lógica de búsqueda

**Opción A — Proyectos Activos:**
1. Listar contenido del Team Folder raíz (`2km7j8be2bc8587ca4a01b6f044678ca4309e`) con `ZohoWorkdrive_getFolderFiles`
2. Localizar la subcarpeta del cliente (p.ej. "HomeEspaña")
3. Dentro de ella, localizar la subcarpeta de seguimiento (p.ej. "01. Seguimiento" o similar)
4. Dentro de ella, localizar "Actas de Reuniones" (los análisis se guardan en la misma carpeta que las actas)
5. Proponer al usuario: *"He encontrado: `Proyectos Activos › HomeEspaña › 01. Seguimiento › Actas de Reuniones`. ¿Es correcta esta ubicación?"*

**Opción B — Carpetas Comercial:**
1. Usar `ZohoWorkdrive_searchTeamFoldersFiles` con el nombre de la carpeta ("Comercial", "Comercial WhatsApp" o "Comercial Zoho") para localizar la carpeta raíz correspondiente
2. Dentro de ella, buscar subcarpeta del cliente si existe, o usar la raíz directamente
3. Proponer al usuario la ruta encontrada para confirmación

**Opción C — Amigo Reinicia (llamada transversal con colaborador externo):**
Ruta verificada (20/06/2026): `Proyectos Activos › Agencia Reinicia › 00. Seguimiento y Control › Amigos Reinicios › [Amigo]`. ⚠️ La carpeta se llama literalmente **"Amigos Reinicios"** (con -s).
1. Listar el contenido de "Amigos Reinicios" (`62rwt1fabec685e80405c8a1e79be2046fe48`) con `ZohoWorkdrive_listTeamFolderFilesAndFolders`
2. Localizar la subcarpeta del Amigo concreto (p.ej. "Sintaris" `p9tic39e50c26029f4891a81debde6e644478`, "Paolo", "GoToMarket", "The Last Dock", "Braulio", "Carlos Garcia del Real")
3. Proponer al usuario la ruta encontrada para confirmación
4. **Enrutado del comentario (Paso 6)**: a `Gestión [Mes] Marketing [REINICIA]` (lista Gestión Reinicia `3350803`), no a la Gestión de un cliente.

> Solo para llamadas **transversales** del Amigo. Si la llamada es sobre un cliente concreto, va en la carpeta de ese cliente (Opción A). Anclajes: Agencia Reinicia `5mzblac5a403d578e4e5eaecf9a153cb6cbe8` › 00. Seguimiento y Control `572lgc3c39a1f1e0648968f1bac1ab001ac67` › Amigos Reinicios `62rwt1fabec685e80405c8a1e79be2046fe48`.

### Confirmación siempre obligatoria

Nunca guardar sin confirmación explícita del usuario. Proponer siempre la ruta encontrada y esperar respuesta:
- ✅ Usuario confirma → guardar en esa carpeta
- ❌ Usuario corrige → navegar a la ruta indicada o pedir el ID directamente
- ❓ No se encuentra la carpeta → indicarlo e informar al usuario para que proporcione la ruta o ID

---

## Notas de diseño

- El **Análisis Emocional** es el valor diferencial de esta skill respecto al acta. Debe ser honesto, directo y útil para el PO: no es un eufemismo, es una herramienta de gestión relacional.
- El **Perfil reptil** se incluye siempre, pero el encuadre cambia según el tipo de llamada (comercial → palancas de decisión; seguimiento → gestión de seguridad; fricción → reconectar desde el estado de colaboración). No es un análisis psicológico clínico: es una lectura práctica de impulsos subconscientes que el PO puede usar para preparar el siguiente contacto.
- No inventar señales emocionales ni reptiles que no estén respaldadas por la transcripción. Si hay poco material, decirlo explícitamente en lugar de especular.
- Si la transcripción es parcial o de baja calidad, indicarlo en la nota final.
- Esta skill **no sustituye al acta de reunión** cuando se requiere un registro formal de seguimiento. Pueden usarse ambas de forma complementaria.
- **Confidencialidad (uso interno).** El Perfil reptil y el Análisis emocional son datos personales de personas identificadas; el documento es de uso interno de Reinicia y **no se comparte con el cliente**. Por eso lleva banner rojo, pie en cada página y sufijo `-INTERNO`, y se guarda en el árbol interno del cliente (`01. Seguimiento › Actas de Reuniones`), al que el cliente no accede. El registro en ClickUp/Zoho CRM nunca vuelca el reptil ni el emocional (solo resumen + ideas + enlace). No es asesoramiento legal, pero conviene tratarlo con la cautela de un dato sensible.

---

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0 | 21/06/2026 | Néstor + Claude | Estado previo sin versionar: resumen en chat (5 epígrafes con análisis emocional y perfil reptil) y `.docx` opcional con marca Reinicia, sin registro en ClickUp/Zoho CRM. |
| v1.1 | 20/06/2026 | Néstor + Claude | Nuevo epígrafe `4. Ideas tratadas` (tabla Idea / Descripción / Aportada por / Aceptación cliente [Sí, Con matices, No, Pendiente] / App(s)) en chat y en el `.docx`, antes de Decisiones; renumerado Decisiones→5 y Análisis emocional→6. Nuevo Paso 6 = Registro opcional en ClickUp/Zoho CRM (pregunta siempre; destino único: Gestión del cliente / Deal+Contacto / Ficha de Contacto) con el bloque de ideas en el cuerpo; el registro NO vuelca el análisis emocional ni el perfil reptil (uso interno, solo en el `.docx`). |
| v1.2 | 20/06/2026 | Néstor + Claude | Fix: el comando de validación apuntaba a `output.docx` (inexistente) → ahora valida `/home/claude/<FILENAME>.docx`. Fix: la nota final del `.docx` ya no afirma siempre "transcripción completa"; es condicional según cobertura/calidad de la transcripción, coherente con las Notas de diseño. |
| v1.3 | 20/06/2026 | Néstor + Claude | Añadida la regla obligatoria de leer la transcripción completa antes de analizar y de detectar subidas duplicadas (misma llamada con transcripción más completa → actualizar el análisis, no duplicar). |
| v1.4 | 20/06/2026 | Néstor + Claude | Replicado el destino Amigo Reinicia (opción de menú, Opción C de búsqueda con ruta/ID verificados "Amigos Reinicios" `62rwt1fabec685e80405c8a1e79be2046fe48`, enrutado del comentario a `Gestión [Mes] Marketing [REINICIA]` lista `3350803`). Añadida la regla de idioma de salida (idioma del cliente; preguntar si no hay certeza). |
| v1.5 | 20/06/2026 | Néstor + Claude | Confidencialidad del perfil reptil/emocional: banner rojo `#D14351` (color de marca) con texto blanco "CONFIDENCIAL · USO INTERNO REINICIA · NO COMPARTIR CON EL CLIENTE" arriba del cuerpo, pie de página en todas las hojas, sufijo `-INTERNO` en el nombre, aviso de uso interno en el resumen de chat y nota de datos personales en Notas de diseño. Corregida la ubicación de guardado a `01. Seguimiento › Actas de Reuniones` (los análisis se guardan junto a las actas; árbol interno sin acceso del cliente). |
| v1.6 | 20/06/2026 | Néstor + Claude | Alineada la fuente a las familias canónicas `Manrope Regular` / `Manrope Bold` en los fragmentos del `.docx` y la tabla de identidad (banner y pie pasan a `Manrope Bold`), con regla de respaldo a `Manrope` si esas familias no resuelven en el entorno de render. Actas no cambia (ya las usaba). Sin cambio de motor: la generación real hereda del stack de actas. |
| v1.7 | 07/07/2026 | Néstor + Claude | **Embebido de fuentes Manrope** en el `.docx` (siguiendo la sección canónica de `marca-reinicia`): sourcing de los estáticos `Manrope-Regular.ttf`/`Manrope-Bold.ttf` del ZIP de Workdrive, array `fonts:` de dos nombres distintos en el `Document`, `patch_fonts.py` obligatorio tras generar y verificación con `pdffonts`. Bloque de ejecución del Paso 4 ampliado (prerrequisito de fuentes + parche + pdffonts) y filas de fuente/fuentes embebidas en la tabla de identidad. Cierra la brecha con actas v1.5 (el "respaldo si no resuelven" queda como último recurso). |
