---
name: actas-reinicia
description: "Usa esta skill cuando el usuario pida crear un acta de reunión para un cliente de Reinicia. Triggers: 'crea el acta', 'genera el acta', 'acta de reunión', 'acta de la reunión de', o cuando el usuario adjunte un fichero .vtt o transcripción de una reunión y pida documentarla. También se activa si el usuario menciona 'acta' junto con un cliente o proyecto. No usar para otros tipos de documentos (propuestas, informes, etc.)."
---

# Skill: Crear Acta de Reunión — Reinicia

## Descripción general

Esta skill genera el acta de una reunión de cliente de Reinicia en formato `.docx` con el estilo corporativo, y registra su creación en ClickUp en la tarea de Gestión del mes correspondiente.

El resultado es un fichero `.docx` listo para subir manualmente a Zoho Workdrive vía Truesync y convertir a Zoho Writer.

---

## Inputs necesarios

Antes de ejecutar, Claude debe tener o solicitar:

1. **Transcripción de la reunión** — obligatorio. Formatos aceptados:
   - `.vtt` — leer con `cat` (texto plano con marcas de tiempo)
   - `.txt` — leer con `cat` (si > 20KB, usar `head` primero)
   - `.docx` — extraer con `pandoc fichero.docx -t markdown`
   - `.doc` — convertir primero a `.docx` con LibreOffice, luego `pandoc`

   Si el contenido ya está visible en el contexto (bloque `<documents>`), usarlo directamente sin leer el fichero.
2. **Cliente** — nombre del cliente (p.ej. "HomeEspaña") — puede inferirse del .vtt o del contexto
3. **Fecha de la reunión** — formato `DDMMYYYY` — puede inferirse del .vtt
4. **Descripción corta** — tema de la reunión (p.ej. "Portal-Web-Hosting-Servicio-Acuerdos") — puede inferirse del contexto o preguntarse al usuario
5. **Carpeta de destino en Workdrive** — preguntar siempre antes de generar el documento:

   > ¿Dónde debe guardarse esta acta en Workdrive?
   > - 📁 **Proyectos Activos** — seguimiento de un proyecto en curso
   > - 💼 **Comercial** — reunión comercial (carpeta Comercial genérica)
   > - 💬 **Comercial WhatsApp** — contacto comercial iniciado por WhatsApp
   > - 🔵 **Comercial Zoho** — contacto comercial gestionado vía Zoho CRM

   Una vez elegida la opción, buscar dinámicamente la carpeta en Workdrive (ver **Búsqueda dinámica de carpeta** más abajo).

6. **Tarea ClickUp de Gestión** — se busca automáticamente por mes y cliente

Si falta algún dato no inferable, preguntarlo antes de continuar.

---

## Paso 1 — Procesar la transcripción

Leer el fichero `.vtt` adjunto y extraer:

- **Participantes** separados por empresa (cliente primero, Reinicia después)
- **Guión** — temas tratados en la reunión
- **Comentarios** — desarrollo de cada tema con el patrón de formato enriquecido:
  - **Negrita** → conceptos técnicos clave, soluciones acordadas, datos relevantes (cifras, herramientas, sistemas)
  - *Cursiva* → ejemplos concretos, anécdotas o casos ilustrativos
  - Subrayado → solo en encabezados de bloque (HomeEspaña / Reinicia), nunca en Comentarios
- **Decisiones y acciones** — separadas por responsable (Reinicia primero, cliente después), con fecha concreta si se mencionó

---

## Paso 2 — Construir el nombre del fichero

Nomenclatura: `YYYYMMDD-Acta-Reunion-[Descripción]-[CLIENTE]`

Ejemplos:
- `20260323-Acta-Reunion-Portal-Web-Hosting-Servicio-Acuerdos-HOMEESPANA`
- `20260415-Acta-Reunion-Seguimiento-Zoho-CRM-TIMEDI`

Reglas:
- Sin tildes ni caracteres especiales
- Sin espacios (guiones como separador)
- CLIENTE en mayúsculas sin espacios ni tildes

---

## Paso 3 — Generar el `.docx` con Node.js

Usar el script de referencia (`build_acta.js`) que está al final de esta skill.

Ejecutar con:
```bash
cd /home/claude && node build_acta.js
python3 /mnt/skills/public/docx/scripts/office/validate.py output.docx
```

### Estructura del documento

```
CABECERA (tabla 3 columnas, sin bordes)
  Col izquierda:  Logotipo Reinicia en negro
  Col centro:     Vacía
  Col derecha:    Nombre del fichero (alineado a la derecha, máx. 2 líneas)
  + Línea separadora azul corporativo (#3812CF)
  + Salto de línea extra

1_Participantes       [H1 — Manrope Regular 36pt #0D0D0D]
  HomeEspaña          [texto normal subrayado]
  • Nombre | Rol      [bullet]
  Reinicia            [texto normal subrayado]
  • Nombre | Rol | Empresa  [bullet]

2_Guión               [H1]
  1. Punto            [numerado]
  2. Punto

3_Comentarios         [H1]
  3.1 Subtítulo       [H2 — Manrope Bold 18pt #0D0D0D]
  Texto con negritas, cursivas según patrón

4_Decisiones – Acciones a realizar  [H1]
  [Tabla: Acción/Decisión | Responsable | Fecha entrega]
  Cabecera: fondo #3812CF, texto blanco negrita, separadores blancos gruesos
  Bloque Reinicia: fondo #D9D0FB
  Bloque [Cliente]: fondo #D9D0FB
  Filas alternas: blanco / #EBEBEB, sin líneas de separación

REVISIÓN PO
  ☐  He revisado el acta y confirmo que refleja correctamente los acuerdos de la reunión.
  Product Owner: _______________     Fecha: _______________

⚠️ Nota: Acta redactada a partir de la transcripción completa...
```

---

## Paso 4 — Buscar tarea de Gestión en ClickUp

Buscar en ClickUp la tarea de Gestión del mes correspondiente:

```
Búsqueda: "Gestión [Mes] [Año] [CLIENTE]"
Ejemplo:  "Gestión marzo 2026 HomeEspaña"
Lista:    Gestión [Cliente] (dentro del espacio Reinicia Clientes)
```

Usar `clickup_search` con la query anterior. Si hay coincidencia exacta, usar esa tarea. Si no existe todavía, indicarlo al usuario para que la cree.

---

## Paso 5 — Añadir comentario en ClickUp

Una vez localizada la tarea, añadir el siguiente comentario (adaptando los datos):

```
📋 Acta de reunión generada — [DD de Mes de YYYY]

Se ha generado el acta de la reunión de seguimiento del proyecto [Cliente] correspondiente al mes de [Mes YYYY].

Reunión: [Descripción de la reunión]
Fecha: [DD/MM/YYYY] · [HH:MM–HH:MM] h
Participantes: [Nombres clave de cada parte]

📁 Ubicación en Zoho Workdrive:
Proyectos Activos › [Cliente] › 01. Seguimiento › Actas de Reuniones
Nombre del archivo: [NOMBRE_FICHERO]

🔗 [Enlace al documento en Workdrive si está disponible]

⚠️ Pendiente de revisión y validación por el Product Owner antes de compartir con el cliente.
```

---

## Paso 6 — Entregar el fichero

Copiar el `.docx` generado a `/mnt/user-data/outputs/` y presentarlo al usuario con `present_files`.

Indicar al usuario:
1. Descargar el `.docx`
2. Copiarlo a la carpeta correspondiente en Zoho Workdrive vía **Truesync**:
   `Proyectos Activos › [Cliente] › 01. Seguimiento › Actas de Reuniones`
3. Abrirlo en Workdrive y convertirlo a **Zoho Writer** (clic derecho → Abrir con → Zoho Writer)
4. Marcar el **checkbox de revisión** del PO una vez revisado

---

## Tabla de referencia — IDs raíz de carpetas Workdrive

Estos IDs son estables y no cambian. Son los puntos de entrada para la búsqueda dinámica.

| Carpeta raíz | ID |
|---|---|
| Proyectos Activos (Team Folder raíz) | `2km7j8be2bc8587ca4a01b6f044678ca4309e` |

> Las carpetas de Comercial, Comercial WhatsApp y Comercial Zoho se localizan dinámicamente desde la raíz del workspace. Si en algún momento se conoce su ID directo, añadirlo aquí para acelerar la búsqueda.

---

## Búsqueda dinámica de carpeta en Workdrive

Ejecutar **antes de generar el `.docx`**, una vez el usuario ha indicado el tipo de destino.

### Lógica de búsqueda

**Opción A — Proyectos Activos:**
1. Listar contenido del Team Folder raíz (`2km7j8be2bc8587ca4a01b6f044678ca4309e`) con `ZohoWorkdrive_getFolderFiles`
2. Localizar la subcarpeta del cliente (p.ej. "HomeEspaña")
3. Dentro de ella, localizar la subcarpeta de seguimiento (p.ej. "01. Seguimiento" o similar)
4. Dentro de ella, localizar "Actas de Reuniones" (o equivalente)
5. Proponer al usuario: *"He encontrado: `Proyectos Activos › HomeEspaña › 01. Seguimiento › Actas de Reuniones`. ¿Es correcta esta ubicación?"*

**Opción B — Carpetas Comercial:**
1. Usar `ZohoWorkdrive_searchTeamFoldersFiles` con el nombre de la carpeta ("Comercial", "Comercial WhatsApp" o "Comercial Zoho") para localizar la carpeta raíz correspondiente
2. Dentro de ella, buscar subcarpeta del cliente si existe, o usar la raíz directamente
3. Proponer al usuario la ruta encontrada para confirmación

### Confirmación siempre obligatoria

Nunca guardar sin confirmación explícita del usuario. Proponer siempre la ruta encontrada y esperar respuesta:
- ✅ Usuario confirma → guardar en esa carpeta
- ❌ Usuario corrige → navegar a la ruta indicada o pedir el ID directamente
- ❓ No se encuentra la carpeta → indicarlo e informar al usuario para que proporcione la ruta o ID

## Tabla de referencia — Acta base en Zoho Writer (para clonar formato)

| Propósito | Document ID |
|-----------|-------------|
| Acta base con formato correcto (HomeEspaña 20250206) | `ipyuw07c391f272df4912952b8503d86440dc` |

---

## Tabla de referencia — Identidad visual Reinicia

| Elemento | Valor |
|----------|-------|
| Color corporativo principal | `#3812CF` |
| Color corporativo secundario | `#D9D0FB` |
| Fondo fila alterna tabla | `#EBEBEB` |
| Color texto cuerpo | `#545454` |
| Color headings H1 | `#0D0D0D` |
| Color headings H2 | `#0D0D0D` |
| Fuente Regular | `Manrope Regular` |
| Fuente Bold | `Manrope Bold` |
| H1 tamaño | 36pt (sz: 72) |
| H2 tamaño | 18pt (sz: 36) |
| Cuerpo tamaño | 12pt (sz: 24) |
| Logotipo | `/home/claude/logo_reinicia.png` — extraer siempre de Workdrive (ver nota abajo) |

> **Logo corporativo:** Extraer `word/media/image3.png` del fichero `TEST-Merge-Store-HomeEspana.docx` (ID Workdrive: `okcqm65a2ea3684c2473583559fb91f0c3a59`) usando `ZohoWorkdrive_downloadWorkDriveFile` + decodificación base64 + extracción del ZIP. **Nunca generar el logo sintéticamente.**

---

## Script de referencia — build_acta.js

Este es el script Node.js completo y validado para generar el `.docx`. Adaptar el contenido de las secciones al acta concreta manteniendo la estructura.

```javascript
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  HeadingLevel, AlignmentType, BorderStyle, WidthType, ShadingType,
  LevelFormat, VerticalAlign, Header, ImageRun
} = require('docx');
const fs = require('fs');

// ── Identidad visual ─────────────────────────────────────────────────────────
const REINICIA_BLUE  = "3812CF";
const REINICIA_LIGHT = "D9D0FB";
const HEADER_TEXT    = "FFFFFF";
const GRAY_ROW       = "EBEBEB";
const MANROPE_R      = "Manrope Regular";
const MANROPE_B      = "Manrope Bold";
const TEXT_COLOR     = "545454";
const HEADING_COLOR  = "0D0D0D";
const H2_COLOR       = "0D0D0D";

// ── ADAPTAR ESTOS VALORES A CADA ACTA ───────────────────────────────────────
const FILENAME = "YYYYMMDD-Acta-Reunion-Descripcion-CLIENTE";
// ────────────────────────────────────────────────────────────────────────────

// Helpers
const spacer = () => new Paragraph({ children: [] });

const h1 = (text) => new Paragraph({
  heading: HeadingLevel.HEADING_1,
  spacing: { before: 480, after: 0 },
  children: [new TextRun({ text, font: MANROPE_R, size: 72, color: HEADING_COLOR, bold: false })]
});

const h2 = (text) => new Paragraph({
  heading: HeadingLevel.HEADING_2,
  spacing: { before: 220, after: 80 },
  children: [new TextRun({ text, font: MANROPE_B, size: 36, color: H2_COLOR, bold: true })]
});

// Párrafo con runs de formato enriquecido
// Cada run puede ser string (texto plano) u objeto { text, bold, italic, underline }
const normalRuns = (runs) => new Paragraph({
  spacing: { before: 40, after: 80 },
  children: runs.map(r => {
    if (typeof r === 'string') return new TextRun({ text: r, font: MANROPE_R, size: 24, color: TEXT_COLOR });
    return new TextRun({
      text: r.text, font: r.bold ? MANROPE_B : MANROPE_R,
      size: 24, color: TEXT_COLOR,
      bold: r.bold || false, italics: r.italic || false,
      underline: r.underline ? {} : undefined,
    });
  })
});

const p = (text) => normalRuns([text]);

const bullet = (text) => new Paragraph({
  numbering: { reference: "bullets", level: 0 },
  spacing: { before: 40, after: 40 },
  children: [new TextRun({ text, font: MANROPE_R, size: 24, color: TEXT_COLOR })]
});

const numbered = (text) => new Paragraph({
  numbering: { reference: "numbers", level: 0 },
  spacing: { before: 40, after: 40 },
  children: [new TextRun({ text, font: MANROPE_R, size: 24, color: TEXT_COLOR })]
});

const blockLabel = (text) => new Paragraph({
  spacing: { before: 120, after: 60 },
  children: [new TextRun({ text, font: MANROPE_B, size: 24, color: TEXT_COLOR, underline: {} })]
});

const italicNote = (text) => new Paragraph({
  spacing: { before: 120, after: 0 },
  children: [new TextRun({ text, font: MANROPE_R, size: 20, color: "888888", italics: true })]
});

// Tabla de decisiones
const noBorder  = { style: BorderStyle.NONE, size: 0, color: "FFFFFF" };
const whiteLine = { style: BorderStyle.SINGLE, size: 6, color: "FFFFFF" };
const COL1 = 4500, COL2 = 2500, COL3 = 1800;
const TABLE_W = COL1 + COL2 + COL3;

const tCell = (text, opts = {}) => {
  const isHeader = opts.header || false;
  const fill = isHeader ? REINICIA_BLUE : (opts.block ? REINICIA_LIGHT : (opts.alt ? GRAY_ROW : "FFFFFF"));
  const borders = isHeader
    ? { top: noBorder, bottom: noBorder, left: whiteLine, right: whiteLine }
    : { top: noBorder, bottom: noBorder, left: noBorder, right: noBorder };
  return new TableCell({
    width: { size: opts.width || COL1, type: WidthType.DXA },
    shading: { fill, type: ShadingType.CLEAR }, borders,
    margins: { top: 100, bottom: 100, left: 150, right: 150 },
    verticalAlign: VerticalAlign.CENTER, columnSpan: opts.span,
    children: [new Paragraph({ children: [new TextRun({
      text, font: (isHeader || opts.block) ? MANROPE_B : MANROPE_R,
      size: isHeader ? 22 : (opts.block ? 22 : 20),
      color: isHeader ? HEADER_TEXT : TEXT_COLOR,
      bold: isHeader || opts.block,
    })] })]
  });
};

const blockRow = (label) => new TableRow({ children: [new TableCell({
  columnSpan: 3, width: { size: TABLE_W, type: WidthType.DXA },
  shading: { fill: REINICIA_LIGHT, type: ShadingType.CLEAR },
  borders: { top: noBorder, bottom: noBorder, left: noBorder, right: noBorder },
  margins: { top: 80, bottom: 80, left: 150, right: 150 },
  children: [new Paragraph({ children: [new TextRun({
    text: label, font: MANROPE_B, size: 22, bold: true, color: TEXT_COLOR
  })] })]
})] });

const dataRow = (accion, responsable, fecha, alt) => new TableRow({ children: [
  tCell(accion, { width: COL1, alt }),
  tCell(responsable, { width: COL2, alt }),
  tCell(fecha, { width: COL3, alt }),
] });

const makeDecisionesTable = (reiniciaRows, clienteRows, clienteNombre) => {
  const header = new TableRow({ tableHeader: true, children: [
    tCell("Acción / Decisión", { header: true, width: COL1 }),
    tCell("Responsable",        { header: true, width: COL2 }),
    tCell("Fecha entrega",      { header: true, width: COL3 }),
  ]});
  return new Table({
    width: { size: TABLE_W, type: WidthType.DXA }, columnWidths: [COL1, COL2, COL3],
    rows: [
      header,
      blockRow("Reinicia"),
      ...reiniciaRows.map(([a,r,f], i) => dataRow(a, r, f, i % 2 !== 0)),
      blockRow(clienteNombre),
      ...clienteRows.map(([a,r,f], i) => dataRow(a, r, f, i % 2 !== 0)),
    ]
  });
};

// Logotipo y cabecera
const logoData = fs.readFileSync('/home/claude/logo_reinicia.png');
const logoRun = new ImageRun({ data: logoData, transformation: { width: 120, height: 22 }, type: "png" });
const noBorderCell = (children, width) => new TableCell({
  width: { size: width, type: WidthType.DXA },
  borders: { top: noBorder, bottom: noBorder, left: noBorder, right: noBorder },
  verticalAlign: VerticalAlign.CENTER, children,
});
const headerTable = new Table({
  width: { size: 9026, type: WidthType.DXA }, columnWidths: [3000, 2026, 4000],
  borders: { top: noBorder, bottom: noBorder, left: noBorder, right: noBorder, insideH: noBorder, insideV: noBorder },
  rows: [new TableRow({ children: [
    noBorderCell([new Paragraph({ children: [logoRun] })], 3000),
    noBorderCell([new Paragraph({ children: [] })], 2026),
    noBorderCell([new Paragraph({
      alignment: AlignmentType.RIGHT,
      children: [new TextRun({ text: FILENAME, font: MANROPE_R, size: 16, color: TEXT_COLOR })]
    })], 4000),
  ]})]
});

// ── DOCUMENTO ────────────────────────────────────────────────────────────────
const doc = new Document({
  numbering: { config: [
    { reference: "bullets", levels: [{ level: 0, format: LevelFormat.BULLET, text: "•",
        alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
    { reference: "numbers", levels: [{ level: 0, format: LevelFormat.DECIMAL, text: "%1.",
        alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
  ]},
  styles: {
    default: { document: { run: { font: MANROPE_R, size: 24 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 72, font: MANROPE_R, color: HEADING_COLOR, bold: false },
        paragraph: { spacing: { before: 480, after: 0 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 36, font: MANROPE_B, color: H2_COLOR, bold: true },
        paragraph: { spacing: { before: 220, after: 80 }, outlineLevel: 1 } },
    ]
  },
  sections: [{ properties: {
    page: { size: { width: 11906, height: 16838 }, margin: { top: 1134, right: 1134, bottom: 1134, left: 1134 } }
  }, headers: { default: new Header({ children: [
    headerTable,
    new Paragraph({ border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: REINICIA_BLUE, space: 4 } },
      spacing: { after: 0 }, children: [] }),
    new Paragraph({ spacing: { after: 240 }, children: [] }),
  ]})},
  children: [

    // ── 1. PARTICIPANTES ──────────────────────────────────────────────────
    h1("1_Participantes"),
    blockLabel("[CLIENTE]"),        // ← sustituir con nombre del cliente
    bullet("[Nombre] | [Rol]"),     // ← añadir un bullet por participante del cliente
    spacer(),
    blockLabel("Reinicia"),
    bullet("[Nombre] | [Rol] | Reinicia"),  // ← añadir un bullet por miembro de Reinicia

    // ── 2. GUIÓN ──────────────────────────────────────────────────────────
    h1("2_Guión"),
    numbered("[Punto 1 del orden del día]"),  // ← adaptar
    numbered("[Punto 2]"),

    // ── 3. COMENTARIOS ────────────────────────────────────────────────────
    h1("3_Comentarios"),
    h2("3.1 [Título del subtema]"),
    normalRuns([
      "Texto normal con ",
      { text: "concepto clave en negrita", bold: true },
      " y ",
      { text: "ejemplo en cursiva.", italic: true },
    ]),

    // ── 4. DECISIONES ─────────────────────────────────────────────────────
    h1("4_Decisiones – Acciones a realizar"),
    spacer(),
    makeDecisionesTable(
      [  // Filas Reinicia: [acción, responsable, fecha]
        ["[Acción Reinicia 1]", "[Persona]", "[Fecha]"],
      ],
      [  // Filas Cliente: [acción, responsable, fecha]
        ["[Acción Cliente 1]", "[Persona]", "[Fecha]"],
      ],
      "[CLIENTE]"  // ← nombre del cliente para el bloque
    ),

    // ── REVISIÓN PO ────────────────────────────────────────────────────────
    spacer(), spacer(),
    new Paragraph({
      border: { top: { style: BorderStyle.SINGLE, size: 4, color: "CCCCCC", space: 8 } },
      spacing: { before: 200, after: 80 },
      children: [new TextRun({ text: "Revisión del Product Owner", font: MANROPE_B, size: 22, bold: true, color: TEXT_COLOR })]
    }),
    new Paragraph({
      spacing: { before: 60, after: 60 },
      children: [new TextRun({ text: "☐  He revisado el acta y confirmo que refleja correctamente los acuerdos de la reunión.", font: MANROPE_R, size: 22, color: TEXT_COLOR })]
    }),
    new Paragraph({
      spacing: { before: 60, after: 60 },
      children: [new TextRun({ text: "Product Owner: _______________________________     Fecha: _______________", font: MANROPE_R, size: 22, color: TEXT_COLOR })]
    }),

    spacer(),
    italicNote("⚠️ Nota: Acta redactada a partir de la transcripción completa de la reunión. Pendiente de revisión y validación por parte de los asistentes."),

  ]}]
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync(`/home/claude/${FILENAME}.docx`, buffer);
  console.log(`OK — ${buffer.length} bytes`);
});
```

---

## Notas para futuras versiones de la skill

- Cuando Zoho MCP habilite el endpoint de upload (`POST /api/v1/upload`), añadir Paso 5b: subida automática a Workdrive
- Cuando Zoho Writer habilite actualización de contenido (`POST /writer/api/v1/documents/{id}/content`), añadir conversión automática a Writer nativo
- La tabla de IDs de carpetas por cliente debe mantenerse actualizada a medida que se añadan proyectos
