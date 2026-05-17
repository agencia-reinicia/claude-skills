---
name: analisis-llamadas-reinicia
description: "Usa esta skill cuando el usuario suba una transcripción de una llamada con un cliente de Reinicia y pida analizarla. Triggers: 'analiza esta llamada', 'analiza la transcripción', 'resumen de la llamada', 'qué pasó en la llamada', o cuando se adjunte un fichero .vtt o transcripción y el contexto sea una llamada (comercial, de seguimiento, de onboarding, de soporte o cualquier otro tipo) con un cliente. También se activa si el usuario menciona 'llamada' junto con un cliente o proyecto. No usar para reuniones de equipo interno sin cliente, ni para generar actas formales de reunión (para eso está la skill actas-reinicia)."
---

# Skill: Análisis de Llamadas con Cliente — Reinicia

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

---

## Paso 1 — Procesar la transcripción

Leer el fichero `.vtt` o texto de transcripción y extraer:

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
- Compromisos y próximos pasos mencionados
- Señales emocionales y relacionales por interlocutor

**Si el tipo inferido es comercial/propuesta**, y no hay contexto previo del cliente en la conversación, preguntar antes de continuar el análisis:

> He detectado que es una llamada de tipo comercial. Para enriquecer el análisis (especialmente el perfil reptil y la recomendación relacional), ¿tienes alguna referencia del cliente? Por ejemplo: web, LinkedIn, sector, tamaño de empresa o cualquier contexto relevante que quieras añadir.

Si el usuario proporciona una URL → usar `web_fetch` para obtener contexto del cliente antes de generar el análisis. Si no tiene referencia o prefiere continuar sin ella → proceder igualmente.

---

## Paso 2 — Generar el resumen en chat

Presentar directamente en el chat el análisis estructurado en **5 epígrafes**:

---

### Estructura del resumen en chat

```
## 📞 Análisis de llamada — [Cliente] · [Tipo detectado] · [Fecha]

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

### 4. Decisiones y próximos pasos
Tabla en markdown:

| Acción | Responsable | Plazo | Estado |
|--------|-------------|-------|--------|
| ...    | ...         | ...   | Pendiente |

Ordenar: primero acciones de Reinicia, después acciones del cliente.

---

### 5. Análisis emocional

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

Usar Node.js con `docx` para generar el fichero con el mismo stack que la skill de actas.

### Nombre del fichero

```
YYYYMMDD-Analisis-Llamada-[Descripcion]-[CLIENTE]
```

Ejemplos:
- `20260401-Analisis-Llamada-Seguimiento-Zoho-CRM-GONHER`
- `20260415-Analisis-Llamada-Comercial-Propuesta-Soporte-HOMEESPANA`

Reglas: sin tildes, sin espacios (guiones), CLIENTE en mayúsculas.

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
  children: [new TextRun({ text: "", font: "Manrope", size: 2 })]
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

#### Estructura de contenido

```
CABECERA (tabla 3 col sin bordes: logo | hueco | nombre fichero — vAlign CENTER
          + línea separadora azul #3812CF DEBAJO de la tabla)

Título principal: "Análisis de llamada — [Descripción]"  [H1 grande]
Bloque metadatos: Cliente · Tipo · Fecha (en línea, SIN línea separadora azul debajo)

1_Participantes          [H1]
  [Subrayado por empresa, bullets por persona]

2_Contexto y objetivo    [H1]
  [Párrafo]

3_Resumen de contenido   [H1]
  3.1 [Subtema]          [H2]
  [Texto con negritas/cursivas]

4_Decisiones y próximos pasos  [H1]
  [Tabla corporativa: cabecera #D9D0FB (lila) con texto #0D0D0D, filas-categoría
   #D9D0FB, filas alternas blanco/#EBEBEB, bordes BLANCOS en todas las celdas]
  Columnas: Acción / Decisión | Responsable | Plazo | Estado
  Bloques: Reinicia primero, cliente después

5_Análisis emocional     [H1]
  5.1 Tono general       [H2]
  [Párrafo]
  5.2 Momentos clave     [H2]
  [Lista con iconos ⚡ ✅ ❓ 🤝]
  5.3 Análisis por interlocutor  [H2]
  [Bloque por persona con etiquetas Postura / Señales positivas / Señales de riesgo / Palanca clave]
  5.4 Perfil reptil      [H2]
  [Bloque por interlocutor cliente con: Impulso dominante / Qué lo activa / Riesgo reptil / Palanca reptil]
  5.5 Recomendación relacional   [H2]
  [Párrafo de cierre estratégico integrando lectura reptil si procede]

REVISIÓN PO
  ☐  He revisado el análisis y confirmo que refleja correctamente la llamada.
  Product Owner: _______________     Fecha: _______________

⚠️ Nota: Análisis redactado a partir de la transcripción completa...
   (sin línea horizontal azul antes de la nota — solo espaciado)
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
| Fuente | `Manrope` (Regular / Bold) |
| H1 | 36pt |
| H2 | 18pt |
| Cuerpo | 12pt |
| Logotipo | `/home/claude/logo_reinicia.png` |

Ejecutar con:
```bash
cd /home/claude && node build_analisis.js
python3 /mnt/skills/public/docx/scripts/office/validate.py output.docx
```

---

## Paso 5 — Entregar el `.docx`

Copiar a `/mnt/user-data/outputs/` y presentar con `present_files`.

Indicar al usuario:
1. Descargar el `.docx`
2. Copiarlo a Zoho Workdrive vía **Truesync**:  
   `Proyectos Activos › [Cliente] › 01. Seguimiento › Análisis de Llamadas`  
   (crear la carpeta si no existe)
3. Convertirlo a **Zoho Writer** (clic derecho → Abrir con → Zoho Writer)
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
4. Dentro de ella, localizar "Análisis de Llamadas" (o equivalente; crearla si no existe)
5. Proponer al usuario: *"He encontrado: `Proyectos Activos › HomeEspaña › 01. Seguimiento › Análisis de Llamadas`. ¿Es correcta esta ubicación?"*

**Opción B — Carpetas Comercial:**
1. Usar `ZohoWorkdrive_searchTeamFoldersFiles` con el nombre de la carpeta ("Comercial", "Comercial WhatsApp" o "Comercial Zoho") para localizar la carpeta raíz correspondiente
2. Dentro de ella, buscar subcarpeta del cliente si existe, o usar la raíz directamente
3. Proponer al usuario la ruta encontrada para confirmación

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
