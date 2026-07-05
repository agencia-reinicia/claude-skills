---
name: actas-reinicia
description: "Usa esta skill cuando el usuario pida crear un acta de reunión para un cliente de Reinicia. Triggers: 'crea el acta', 'genera el acta', 'acta de reunión', 'acta de la reunión de', o cuando el usuario adjunte un fichero .vtt o transcripción de una reunión y pida documentarla. También se activa si el usuario menciona 'acta' junto con un cliente o proyecto. No usar para otros tipos de documentos (propuestas, informes, etc.)."
---

# Skill: Crear Acta de Reunión — Reinicia

> **Versión vigente: v1.4 — 20/06/2026** · ver changelog al final (`## Versiones`)

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
   > - 🤝 **Amigo Reinicia** — reunión transversal con un colaborador externo (no ligada a un cliente concreto)
   > - 💼 **Comercial** — reunión comercial (carpeta Comercial genérica)
   > - 💬 **Comercial WhatsApp** — contacto comercial iniciado por WhatsApp
   > - 🔵 **Comercial Zoho** — contacto comercial gestionado vía Zoho CRM

   Una vez elegida la opción, buscar dinámicamente la carpeta en Workdrive (ver **Búsqueda dinámica de carpeta** más abajo).

6. **Tarea ClickUp de Gestión** — se busca automáticamente por mes y cliente

Si falta algún dato no inferable, preguntarlo antes de continuar.

> **Idioma de salida.** Redactar el acta en el **idioma del cliente**: castellano para clientes españoles, inglés para clientes internacionales (p.ej. HomeEspaña, Carritech). Inferirlo de la transcripción y del cliente. **Si no se tiene certeza del idioma preferido, preguntar al usuario** antes de generar. (Coherente con la regla "idioma del cliente" de la skill de diagramas.)

---

## Paso 1 — Procesar la transcripción

Leer el fichero `.vtt` adjunto y extraer:

> **Regla de lectura (obligatoria).** Leer **SIEMPRE la transcripción completa** antes de redactar. No saltar entre rangos de líneas asumiendo que ya se captan los temas: un acta parcial que luego hay que fusionar es peor que tardar más en la lectura inicial. Si un fichero es grande, `head` sirve solo para **orientarse**, no para sustituir la lectura íntegra.
>
> **Detección de subida duplicada.** Si llega una **segunda transcripción** que "parece aportar temas nuevos", verificar primero si es un **duplicado** de la anterior (comparar fecha interna, participantes, hora de inicio y de fin) antes de asumir que son reuniones distintas. Si es la misma reunión con transcripción más completa, **rehacer/actualizar** el acta existente, no crear una nueva. (Caso real: las dos versiones del acta de HomeEspaña 23/03/2026.)

- **Participantes** separados por empresa (cliente primero, Reinicia después)
- **Guión** — temas tratados en la reunión
- **Comentarios** — desarrollo de cada tema con el patrón de formato enriquecido:
  - **Negrita** → conceptos técnicos clave, soluciones acordadas, datos relevantes (cifras, herramientas, sistemas)
  - *Cursiva* → ejemplos concretos, anécdotas o casos ilustrativos
  - Subrayado → solo en encabezados de bloque (HomeEspaña / Reinicia), nunca en Comentarios
- **Ideas tratadas** — ideas, propuestas o sugerencias que surgieron en la reunión (aunque no cristalizasen en acción). Para cada una extraer: idea, descripción breve, quién la aportó (nombre + empresa), grado de aceptación del cliente (`Sí` / `Con matices` / `No` / `Pendiente` si no se pronunció) y app(s) involucradas. No forzar ideas inexistentes: si la reunión no tuvo ideas reseñables, omitir el bloque.
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
# build_acta.js escribe /home/claude/<FILENAME>.docx — validar ESE fichero, no "output.docx"
python3 /mnt/skills/public/docx/scripts/office/validate.py "/home/claude/<FILENAME>.docx"
```

### Reglas estrictas de estilo

**1. Cabecera — patrón obligatorio: tabla de 3 columnas SIN bordes.**

Estructura: `[logo a la izquierda] | [hueco central] | [nombre del fichero a la derecha]`. Las celdas deben llevar `verticalAlign: VerticalAlign.CENTER` para que el nombre del fichero quede centrado verticalmente respecto al logo. La línea separadora azul (`#3812CF`) va en un **párrafo independiente debajo de la tabla**, nunca como `border-bottom` del párrafo del nombre del fichero (eso pega el texto a la línea).

**2. Líneas horizontales decorativas en el cuerpo: PROHIBIDAS.**

La única línea azul `#3812CF` permitida en todo el documento es la que va dentro de la cabecera. **No** usar bordes inferiores ni superiores azules como separador entre secciones, antes de bloques como "Revisión del Product Owner", ni antes de la nota final. Esto incluye también líneas grises, naranjas o de cualquier otro color: el cuerpo va limpio. La separación entre bloques se consigue con espaciado (`spacing.before` / `spacing.after`) y con la propia tipografía de los headings, nunca con líneas decorativas.

**3. Bordes de la tabla de Decisiones: blancos en TODAS las celdas.**

Toda la tabla de Decisiones lleva bordes blancos (`#FFFFFF`) — incluidas las celdas de cabecera, las filas-categoría (Reinicia / Cliente) y las filas de datos. La legibilidad la dan las bandas alternas (blanco / `#EBEBEB`) y el fondo lila (`#D9D0FB`) de la cabecera y de las filas-categoría. **No usar bordes grises ni de ningún otro color**: si se omiten en alguna fila (típicamente en la fila-categoría con `columnSpan`), Word/LibreOffice aplican bordes negros por defecto. Definir siempre los cuatro bordes (`top`, `bottom`, `left`, `right`) explícitamente en blanco en cada `TableCell`, sin excepciones.

```javascript
const whiteBorder = { style: BorderStyle.SINGLE, size: 8, color: "FFFFFF" };
borders: { top: whiteBorder, bottom: whiteBorder, left: whiteBorder, right: whiteBorder }
```

**4. Cabecera de la tabla de Decisiones: lila `#D9D0FB`, no azul.**

La cabecera de la tabla usa fondo lila `#D9D0FB` con texto en negro de heading `#0D0D0D` (alineado con el patrón canónico de la skill `marca-reinicia`). **Nunca azul saturado `#3812CF` con texto blanco**: ese azul se reserva para acentos puntuales (líneas separadoras, énfasis tipográficos), no como fondo de cabecera de tabla.

**5. Tabla de "Ideas tratadas": mismo estilo que la de Decisiones, 5 columnas, sin bloques-categoría.**

La tabla de Ideas usa la misma estética que la de Decisiones (cabecera lila `#D9D0FB` con texto negro `#0D0D0D`, bordes BLANCOS en todas las celdas, filas alternas blanco/`#EBEBEB`), pero **sin filas-categoría** (Reinicia/Cliente): es una tabla plana porque la columna "Aportada por" ya indica el origen de cada idea. Columnas: `Idea | Descripción | Aportada por | Aceptación cliente | App(s) involucradas`.

- **Aceptación cliente**: vocabulario controlado de **cuatro** valores — `Sí` / `Con matices` / `No` / `Pendiente`. "Pendiente" se usa cuando la idea se planteó pero el cliente no se pronunció (típicamente ideas que lanza Reinicia y el cliente aún no valora). No usar otros valores.
- **Aportada por**: nombre + empresa entre paréntesis, p.ej. `Paolo (Reinicia)` o `Robin (HomeEspaña)`.
- **App(s) involucradas**: nombres en **texto plano** (Zoho CRM, WordPress, WhatsApp/WABA, Zoho Forms, Cloudways…), coherentes con el vocabulario de sistemas de la casa. **No usar emojis** en el `.docx` (riesgo de render como cajas en Word/LibreOffice).
- **Orden de filas**: en el orden en que surgieron en la reunión (trazable).
- Una idea con aceptación `Sí` puede aparecer también en la tabla de Decisiones (con responsable y fecha). No es duplicación: Ideas captura la lente *buy-in + apps*; Decisiones, la de *acción comprometida*.

### Estructura del documento

```
CABECERA (tabla 3 columnas, sin bordes)
  Col izquierda:  Logotipo Reinicia en negro
  Col centro:     Vacía
  Col derecha:    Nombre del fichero (alineado a la derecha, vAlign CENTER)
  + Línea separadora azul corporativo (#3812CF) en párrafo independiente debajo

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

4_Ideas tratadas      [H1]
  [Tabla: Idea | Descripción | Aportada por | Aceptación cliente | App(s) involucradas]
  Cabecera: fondo lila #D9D0FB, texto negro #0D0D0D negrita, bordes BLANCOS
  Filas alternas: blanco / #EBEBEB, bordes BLANCOS
  Aceptación cliente: Sí / Con matices / No / Pendiente (vocabulario controlado)

5_Decisiones – Acciones a realizar  [H1]
  [Tabla: Acción/Decisión | Responsable | Fecha entrega]
  Cabecera: fondo lila #D9D0FB, texto negro #0D0D0D negrita, bordes BLANCOS
  Bloque Reinicia: fondo lila #D9D0FB, bordes BLANCOS
  Bloque [Cliente]: fondo lila #D9D0FB, bordes BLANCOS
  Filas alternas: blanco / #EBEBEB, bordes BLANCOS

REVISIÓN PO (sin línea horizontal gris encima — solo espaciado)
  ☐  He revisado el acta y confirmo que refleja correctamente los acuerdos de la reunión.
  Product Owner: _______________     Fecha: _______________

⚠️ Nota final: CONDICIONAL según cobertura de la transcripción (ver `NOTA_FINAL` en el script)
   - Transcripción completa → "Acta redactada a partir de la transcripción completa de la reunión..."
   - Transcripción parcial   → "Acta redactada a partir de una transcripción parcial...; las partes
     no cubiertas se han reconstruido a partir del contexto... pendiente de la transcripción completa."
   (sin línea horizontal antes de la nota — solo espaciado)
```

---

## Paso 4 — Entregar el fichero

Copiar el `.docx` generado a `/mnt/user-data/outputs/` y presentarlo al usuario con `present_files`.

Indicar al usuario:
1. Descargar el `.docx`
2. Copiarlo a la carpeta confirmada en Zoho Workdrive vía **Truesync** (la de la búsqueda dinámica de carpeta)
3. Abrirlo en Workdrive y convertirlo a **Zoho Writer** (clic derecho → Abrir con → Zoho Writer)
4. Marcar el **checkbox de revisión** del PO una vez revisado

Entregar el fichero **antes** del Paso 5, para que el usuario pueda subirlo a Workdrive y, si quiere, tener ya el enlace al registrar el acta.

---

## Paso 5 — Registro opcional en ClickUp / Zoho CRM

El registro **ya no es automático**. Preguntar **siempre** al usuario si quiere dejar constancia del acta y, en su caso, dónde. Destino **único** (no multi-destino):

```
¿Quieres dejar registro de esta acta en algún sitio?
  🟢 ClickUp — tarea de Gestión del Proyecto del cliente
  💼 Zoho CRM — Oportunidad (Deal)   → la nota se asocia también al Contacto del Deal
  👤 Zoho CRM — Ficha de Contacto
  ⛔ No dejar registro
```

Si el usuario elige **No dejar registro** → terminar aquí.

### 5.1 Enlace al documento

Antes de publicar, preguntar: *"¿Ya tienes el enlace de Workdrive del acta?"*
- Si **sí** → incrustar la URL en el cuerpo.
- Si **no** → dejar la línea `(pega aquí el enlace tras subir el documento a Workdrive)` y recordárselo al usuario al final.

### 5.2 Cuerpo del registro (común a los tres destinos)

Texto **plano**, sin markdown ni hipervínculos, con la URL en su propia línea. Incluir siempre el bloque **Ideas tratadas** si las hubo:

```
Acta de reunión generada — [DD de Mes de YYYY]

Reunión: [Descripción de la reunión]
Fecha: [DD/MM/YYYY] · [HH:MM–HH:MM] h
Participantes: [Nombres clave de cada parte]

Ideas tratadas:
[Sí] [Idea] ([Aportada por]) — [App(s)]
[Con matices] [Idea] ([Aportada por]) — [App(s)]
[No] [Idea] ([Aportada por]) — [App(s)]
[Pendiente] [Idea] ([Aportada por]) — [App(s)]

Ubicación en Zoho Workdrive: Proyectos Activos › [Cliente] › 01. Seguimiento › Actas de Reuniones
Archivo: [NOMBRE_FICHERO]
[URL del documento o placeholder]

Pendiente de revisión y validación por el Product Owner antes de compartir con el cliente.
```

El prefijo `[Sí]/[Con matices]/[No]/[Pendiente]` reproduce la convención de criterios en corchetes de la casa. Omitir el bloque "Ideas tratadas" si no hubo ideas reseñables.

### 5.3 Destino ClickUp — Gestión del Proyecto

1. Buscar la tarea `Gestión [Mes] [Año] [CLIENTE]` con `clickup_search` en la lista `Gestión [Cliente]` (espacio Reinicia Clientes).
2. Proponer la tarea encontrada al usuario para confirmar. Si no existe, indicarlo para que la cree.
3. Publicar el cuerpo como **comentario** (texto plano; ClickUp no admite markdown/HTML/hipervínculos en comentarios — la URL va sola en su línea).

> Caso especial — reunión transversal con Amigo Reinicia: el comentario va a `Gestión [Mes] Marketing [REINICIA]` (lista `3350803`), no a la tarea de Gestión del cliente.

### 5.4 Destino Zoho CRM — Oportunidad (Deal)

1. Buscar el Deal por nombre de cliente (`ZohoCRM_getDealsRecords`, filtrar por nombre) y proponerlo para confirmar.
2. Crear una **Nota** en el Deal con `ZohoCRM_createNotes` (parent = Deal): `Note_Title` = "Acta de reunión — [Cliente] — [DD/MM/YYYY]", `Note_Content` = el cuerpo del 5.2.
3. **Asociar también al Contacto del Deal**: leer el Contacto del Deal (campo Contacto principal o sus Contact Roles con `ZohoCRM_getAssociatedContactRoles`) y crear la misma Nota en ese registro de Contacto.

### 5.5 Destino Zoho CRM — Ficha de Contacto

1. Buscar el Contacto por nombre/email del participante y proponerlo para confirmar.
2. Crear una **Nota** en el Contacto con `ZohoCRM_createNotes` (parent = Contacto), mismo `Note_Title`/`Note_Content` que en 5.4.

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
4. Dentro de ella, localizar "Actas de Reuniones" (o equivalente)
5. Proponer al usuario: *"He encontrado: `Proyectos Activos › HomeEspaña › 01. Seguimiento › Actas de Reuniones`. ¿Es correcta esta ubicación?"*

**Opción B — Carpetas Comercial:**
1. Usar `ZohoWorkdrive_searchTeamFoldersFiles` con el nombre de la carpeta ("Comercial", "Comercial WhatsApp" o "Comercial Zoho") para localizar la carpeta raíz correspondiente
2. Dentro de ella, buscar subcarpeta del cliente si existe, o usar la raíz directamente
3. Proponer al usuario la ruta encontrada para confirmación

**Opción C — Amigo Reinicia (reunión transversal con colaborador externo):**
Ruta verificada (20/06/2026): `Proyectos Activos › Agencia Reinicia › 00. Seguimiento y Control › Amigos Reinicios › [Amigo]`. ⚠️ La carpeta se llama literalmente **"Amigos Reinicios"** (con -s).
1. Listar el contenido de "Amigos Reinicios" (`62rwt1fabec685e80405c8a1e79be2046fe48`) con `ZohoWorkdrive_listTeamFolderFilesAndFolders`
2. Localizar la subcarpeta del Amigo concreto (existen, p.ej. "Sintaris" `p9tic39e50c26029f4891a81debde6e644478`, "Paolo", "GoToMarket", "The Last Dock", "Braulio", "Carlos Garcia del Real"). Usar la subcarpeta de ese Amigo
3. Proponer al usuario la ruta encontrada para confirmación
4. **Enrutado del comentario (Paso 5)**: NO va a la Gestión de un cliente, sino a `Gestión [Mes] Marketing [REINICIA]` (lista Gestión Reinicia `3350803`). Ver Paso 5.3.

> Usar esta opción solo para reuniones **transversales** del Amigo (relación, acuerdos, varios clientes). Si la reunión es sobre un cliente concreto, el acta va en la carpeta de ese cliente (Opción A).
> Anclajes de navegación: Agencia Reinicia `5mzblac5a403d578e4e5eaecf9a153cb6cbe8` › 00. Seguimiento y Control `572lgc3c39a1f1e0648968f1bac1ab001ac67` › Amigos Reinicios `62rwt1fabec685e80405c8a1e79be2046fe48`.

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
| Color corporativo principal | `#3812CF` (solo línea separadora cabecera y acentos puntuales) |
| Color corporativo secundario | `#D9D0FB` (lila — cabecera de tabla y bloques) |
| Fondo fila alterna tabla | `#EBEBEB` |
| Color texto cuerpo | `#545454` |
| Color headings H1 / H2 | `#0D0D0D` |
| Color bordes tabla | `#FFFFFF` (siempre blancos, nunca grises) |
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
const REINICIA_BLUE  = "3812CF";       // solo línea separadora cabecera + acentos
const REINICIA_LIGHT = "D9D0FB";       // lila — cabecera tabla y bloques
const GRAY_ROW       = "EBEBEB";
const WHITE          = "FFFFFF";
const MANROPE_R      = "Manrope Regular";
const MANROPE_B      = "Manrope Bold";
const TEXT_COLOR     = "545454";
const HEADING_COLOR  = "0D0D0D";
const H2_COLOR       = "0D0D0D";

// ── ADAPTAR ESTOS VALORES A CADA ACTA ───────────────────────────────────────
const FILENAME = "YYYYMMDD-Acta-Reunion-Descripcion-CLIENTE";

// Nota final — ELEGIR según la cobertura real de la transcripción (no dejar siempre "completa"):
const NOTA_FINAL = "⚠️ Nota: Acta redactada a partir de la transcripción completa de la reunión. Pendiente de revisión y validación por parte de los asistentes.";
// Si la transcripción fue PARCIAL, usar en su lugar (y ajustar qué partes recoge):
// const NOTA_FINAL = "⚠️ Nota: Acta redactada a partir de una transcripción parcial de la reunión (recoge [qué partes]); las partes no cubiertas se han reconstruido a partir del contexto. Pendiente de revisión y validación por parte de los asistentes una vez se disponga de la transcripción completa.";
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

// ── Tabla de decisiones ─────────────────────────────────────────────────────
// Bordes BLANCOS en todas las celdas (regla 3 de estilo)
const whiteBorder = { style: BorderStyle.SINGLE, size: 8, color: WHITE };
const noBorderHdr = { style: BorderStyle.NONE,   size: 0, color: WHITE };

const COL1 = 4500, COL2 = 2500, COL3 = 1800;
const TABLE_W = COL1 + COL2 + COL3;

const tCell = (text, opts = {}) => {
  const isHeader = opts.header || false;
  // Cabecera = lila (regla 4); fila-categoría también lila; alterna gris claro
  const fill = isHeader ? REINICIA_LIGHT
             : (opts.block ? REINICIA_LIGHT
             : (opts.alt   ? GRAY_ROW
             : WHITE));
  return new TableCell({
    width: { size: opts.width || COL1, type: WidthType.DXA },
    shading: { fill, type: ShadingType.CLEAR },
    borders: { top: whiteBorder, bottom: whiteBorder, left: whiteBorder, right: whiteBorder },
    margins: { top: 100, bottom: 100, left: 150, right: 150 },
    verticalAlign: VerticalAlign.CENTER, columnSpan: opts.span,
    children: [new Paragraph({ children: [new TextRun({
      text, font: (isHeader || opts.block) ? MANROPE_B : MANROPE_R,
      size: isHeader ? 22 : (opts.block ? 22 : 20),
      // Texto NEGRO en cabecera (sobre fondo lila), no blanco
      color: (isHeader || opts.block) ? HEADING_COLOR : TEXT_COLOR,
      bold: isHeader || opts.block,
    })] })]
  });
};

const blockRow = (label) => new TableRow({ children: [new TableCell({
  columnSpan: 3, width: { size: TABLE_W, type: WidthType.DXA },
  shading: { fill: REINICIA_LIGHT, type: ShadingType.CLEAR },
  borders: { top: whiteBorder, bottom: whiteBorder, left: whiteBorder, right: whiteBorder },
  margins: { top: 80, bottom: 80, left: 150, right: 150 },
  children: [new Paragraph({ children: [new TextRun({
    text: label, font: MANROPE_B, size: 22, bold: true, color: HEADING_COLOR
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

// ── Tabla de Ideas tratadas (5 columnas, sin bloques-categoría) ──────────────
const COLI1 = 1700, COLI2 = 2800, COLI3 = 1500, COLI4 = 1400, COLI5 = 1400;
const IDEAS_W = COLI1 + COLI2 + COLI3 + COLI4 + COLI5;

const ideaRow = (idea, desc, autor, acept, apps, alt) => new TableRow({ children: [
  tCell(idea,  { width: COLI1, alt }),
  tCell(desc,  { width: COLI2, alt }),
  tCell(autor, { width: COLI3, alt }),
  tCell(acept, { width: COLI4, alt }),
  tCell(apps,  { width: COLI5, alt }),
] });

const makeIdeasTable = (rows) => {
  const header = new TableRow({ tableHeader: true, children: [
    tCell("Idea",                { header: true, width: COLI1 }),
    tCell("Descripción",         { header: true, width: COLI2 }),
    tCell("Aportada por",        { header: true, width: COLI3 }),
    tCell("Aceptación cliente",  { header: true, width: COLI4 }),
    tCell("App(s) involucradas", { header: true, width: COLI5 }),
  ]});
  return new Table({
    width: { size: IDEAS_W, type: WidthType.DXA }, columnWidths: [COLI1, COLI2, COLI3, COLI4, COLI5],
    rows: [ header, ...rows.map(([i,d,a,ac,ap], idx) => ideaRow(i, d, a, ac, ap, idx % 2 !== 0)) ]
  });
};

// ── Logotipo y cabecera (tabla 3 columnas sin bordes + línea azul debajo) ────
const NO_BORDER = { style: BorderStyle.NONE, size: 0, color: WHITE };
const noBorders = { top: NO_BORDER, bottom: NO_BORDER, left: NO_BORDER, right: NO_BORDER, insideHorizontal: NO_BORDER, insideVertical: NO_BORDER };

const logoData = fs.readFileSync('/home/claude/logo_reinicia.png');
const logoRun = new ImageRun({ data: logoData, transformation: { width: 120, height: 22 }, type: "png" });

const noBorderCell = (children, width) => new TableCell({
  width: { size: width, type: WidthType.DXA },
  borders: noBorders,
  verticalAlign: VerticalAlign.CENTER,
  margins: { top: 0, bottom: 0, left: 0, right: 0 },
  children,
});

const headerTable = new Table({
  width: { size: 9026, type: WidthType.DXA }, columnWidths: [3000, 2026, 4000],
  borders: noBorders,
  rows: [new TableRow({ children: [
    noBorderCell([new Paragraph({ children: [logoRun] })], 3000),
    noBorderCell([new Paragraph({ children: [] })], 2026),
    noBorderCell([new Paragraph({
      alignment: AlignmentType.RIGHT,
      children: [new TextRun({ text: FILENAME, font: MANROPE_R, size: 16, color: TEXT_COLOR })]
    })], 4000),
  ]})]
});

// Línea separadora azul: párrafo INDEPENDIENTE debajo de la tabla, no border-bottom de la celda del nombre
const headerSeparatorLine = new Paragraph({
  spacing: { before: 60, after: 60 },
  border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: REINICIA_BLUE, space: 1 } },
  children: [new TextRun({ text: "", font: MANROPE_R, size: 2 })]
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
    headerSeparatorLine,
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

    // ── 4. IDEAS TRATADAS ─────────────────────────────────────────────────
    h1("4_Ideas tratadas"),
    spacer(),
    makeIdeasTable([
      // [idea, descripción breve, "Persona (Empresa)", aceptación, "App(s)"]
      // aceptación ∈ { "Sí", "Con matices", "No", "Pendiente" }
      ["[Idea 1]", "[Descripción breve]", "[Persona (Empresa)]", "[Sí / Con matices / No / Pendiente]", "[App(s)]"],
    ]),

    // ── 5. DECISIONES ─────────────────────────────────────────────────────
    h1("5_Decisiones – Acciones a realizar"),
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

    // ── REVISIÓN PO (sin línea horizontal — solo espaciado) ────────────────
    spacer(), spacer(),
    new Paragraph({
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
    italicNote(NOTA_FINAL),

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

---

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0 | 21/06/2026 | Néstor + Claude | Estado previo sin versionar: generación del acta `.docx` con marca Reinicia, búsqueda dinámica de carpeta en Workdrive y comentario automático en la tarea de Gestión del cliente en ClickUp. |
| v1.1 | 20/06/2026 | Néstor + Claude | Nuevo bloque `4_Ideas tratadas` (tabla Idea / Descripción / Aportada por / Aceptación cliente [Sí, Con matices, No, Pendiente] / App(s)) antes de Decisiones, con `makeIdeasTable` en `build_acta.js`. Pasos 4–6 reestructurados: Paso 4 = entregar fichero; Paso 5 = Registro opcional en ClickUp/Zoho CRM (pregunta siempre; destino único: Gestión del cliente / Deal+Contacto / Ficha de Contacto), con el bloque de ideas en el cuerpo. |
| v1.2 | 20/06/2026 | Néstor + Claude | Fix: el comando de validación apuntaba a `output.docx` (inexistente) → ahora valida `/home/claude/<FILENAME>.docx`. Fix: la nota final estaba hardcodeada como "transcripción completa" → ahora es la constante `NOTA_FINAL`, a elegir entre variante completa o parcial según la cobertura real de la transcripción. |
| v1.3 | 20/06/2026 | Néstor + Claude | Completado el caso "reunión transversal con Amigo Reinicia": nueva opción de destino Workdrive 🤝 Amigo Reinicia (raíz `8dktwacf39023e8274b1bab0ab423a81b5ed3`), Opción C de búsqueda dinámica y enrutado del comentario a `Gestión [Mes] Marketing [REINICIA]` (lista `3350803`). Añadida la regla obligatoria de leer la transcripción completa y de detectar subidas duplicadas (misma reunión con transcripción más completa → actualizar, no duplicar). |
| v1.4 | 20/06/2026 | Néstor + Claude | Corrección del destino Amigo Reinicia (ruta/ID verificados en vivo contra Workdrive): la carpeta correcta es "Amigos Reinicios" (`62rwt1fabec685e80405c8a1e79be2046fe48`) en `Agencia Reinicia › 00. Seguimiento y Control`, NO la `02. Colaboradores - Amigos Reinicia` (`8dktwacf…`) que estaba anotada por error. Añadida la regla de idioma de salida (idioma del cliente; preguntar si no hay certeza). |
