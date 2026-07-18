# Fase B — Generación del `.docx` de Diseño Funcional con marca Reinicia

Esta fase corre **en claude.ai / Cowork**, no dentro del repo. Aquí sí están disponibles la skill `marca-reinicia`, el skill público `docx` y el MCP de Workdrive para el logo. La entrada es el **markdown ya revisado** de la Fase A; el repo no tiene por qué estar delante, por eso el markdown debe ser autosuficiente (front-matter completo + 6 secciones).

No se reinventa el pipeline docx de Reinicia: se **reutiliza** el de `marca-reinicia`. Esta referencia solo orquesta esa reutilización para el caso "Diseño Funcional".

## Precedencia de fuentes de verdad

1. `marca-reinicia` — paleta, tipografía, extracción del logo, embebido de Manrope, patrones de cabecera y tabla. **Prevalece** para valores de marca.
2. `/mnt/skills/public/docx/SKILL.md` — mecánica de construcción y validación del `.docx`.
3. Esta referencia — estructura del documento DF, nombre de fichero y flujo de entrega.

Lee 1 y 2 antes de construir. No copies constantes de memoria si puedes leerlas de `marca-reinicia`.

## Pasos

**B1. Cargar entrada y marca.**
- Toma el markdown revisado (subido por el PO o ya en la conversación). Parsea el front-matter: `cliente`, `idioma`, `descripcion_corta`, `fecha`, `stack`, `fuentes_analizadas`, etc.
- **Idioma:** renderiza el `.docx` en el `idioma` del front-matter (títulos de sección y cualquier texto que generes). El markdown ya viene en ese idioma; no lo traduzcas ni lo mezcles. La convención del nombre de fichero (`Diseno-Funcional`) se mantiene tal cual —es filing interno de Reinicia— aunque el contenido esté en inglés.
- Consulta `marca-reinicia`. Extrae el logo real de Workdrive (nunca sintético) y prepara las fuentes Manrope Regular/Bold para embebido, según su procedimiento.

**B2. Construir el documento** (docx-js, Node.js), aplicando los patrones de `marca-reinicia`:
- **Cabecera corporativa** (Patrón 1): tabla de 3 columnas sin bordes → logo (≈120×22 px) | hueco | nombre de fichero a la derecha, `vAlign CENTER`; línea separadora azul `#3812CF` en párrafo independiente debajo.
- **Tipografía:** H1 36pt (sz 72), H2 18pt Bold (sz 36), cuerpo 12pt (sz 24), color cuerpo `#545454`, titulares `#0D0D0D`. Manrope embebida (`FUENTE_R`/`FUENTE_B`, dos nombres distintos en el array `fonts`).
- **Tablas** (Patrón 2): bordes **blancos** (nunca grises), cabecera lila `#D9D0FB` con texto `#0D0D0D` en negrita, filas alternas blanco/`#EBEBEB`, sin fusionar celdas.
  - ⚠️ **Anchos de columna:** usa valores **absolutos DXA** que sumen 9602 twips (A4, márgenes 0,8"), **no** `WidthType.PERCENTAGE` — el porcentaje colapsa columnas en Pages/Word.
- **Chips** (Patrón 3) si conviene para prioridades de criterios o niveles de riesgo: fondos pálidos de la paleta de recurso (`chipCell`), nunca saturados de fondo.
- **Cuerpo limpio:** sin líneas decorativas fuera de la cabecera; la separación se logra con espaciado y jerarquía.

**Estructura del documento** (mapea 1:1 con el markdown; H2 por sección):
1. Objetivo
2. Contexto y problemática
3. Análisis y propuesta
4. Diseño técnico-funcional (4.1 Mapa de componentes · 4.2 Modelo de datos)
5. Criterios de aceptación
6. Riesgos

Opcional al inicio: una tabla-ficha de metadatos (Cliente, Proyecto, Fecha, Stack, Repo/commit, Fuentes analizadas) construida desde el front-matter — útil para trazabilidad.

**B3. Nombre de fichero.** Convención Reinicia:
```
YYYYMMDD-Diseno-Funcional-[descripcion_corta]-[CLIENTE].docx
```
Deriva `YYYYMMDD` de `fecha` del front-matter; `descripcion_corta` y `CLIENTE` también del front-matter (sin tildes ni espacios).

**B4. Validar (obligatorio).** Sigue el bloque de verificación de `marca-reinicia`:
```bash
node build_df.js
python3 patch_fonts.py "/home/claude/<FICHERO>.docx"
python3 /mnt/skills/public/docx/scripts/office/validate.py "/home/claude/<FICHERO>.docx"
soffice --headless --convert-to pdf "/home/claude/<FICHERO>.docx" --outdir /home/claude >/dev/null 2>&1 \
  && pdffonts "/home/claude/<FICHERO>.pdf" | grep -i manrope
```
`pdffonts` debe mostrar `Manrope-Regular` y `Manrope-Bold` con `emb=yes`. Haz además una revisión visual (rasteriza 1-2 páginas) para confirmar cabecera, tipografía y tablas.

**B5. Entregar.** Copia el `.docx` a `/mnt/user-data/outputs/` y preséntalo con `present_files`. Sin postámbulos largos.

**B6. Recordatorio flujo Opción C** (igual que el cierre de SPIKE):
```
📝 Flujo de documentación generada:
1. Sube el .docx a Workdrive (vía Truesync).
2. Conviértelo a Zoho Writer (clic derecho → Abrir con → Zoho Writer).
3. Pégame la URL del Writer si quieres que la registre donde corresponda
   (p.ej. el producto en ClickUp).
A partir de ahí, las ediciones son directas en Zoho.
```

## Notas

- Si falta el logo/fuentes por no haber MCP de Workdrive en el entorno, dilo claramente y no generes un `.docx` "casi de marca": el documento de marca requiere logo real y Manrope embebida.
- Si el front-matter está incompleto, pídele al PO los campos que falten antes de generar (sobre todo `cliente`, `idioma`, `descripcion_corta`, `fecha`). Si falta `idioma`, confírmalo con el PO en vez de asumir español.
