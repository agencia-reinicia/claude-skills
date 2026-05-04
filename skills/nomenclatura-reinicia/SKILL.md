---
name: nomenclatura-reinicia
description: "Usa esta skill cuando el usuario quiera revisar, auditar o corregir los nombres de archivos en carpetas de Workdrive de Reinicia. Triggers: 'revisa la nomenclatura', 'comprueba los nombres de los archivos', 'audita los documentos de', 'renombra los archivos que no sigan la nomenclatura', 'verifica el naming', o cuando el usuario mencione 'nomenclatura' junto con un cliente, proyecto o carpeta de Workdrive. También se activa si el usuario pide 'ordenar', 'limpiar' o 'normalizar' los archivos de una carpeta de actas o análisis de llamada. No usar para crear documentos nuevos ni para mover archivos entre carpetas."
---

# Skill: Revisión y Corrección de Nomenclatura — Reinicia

## Propósito

Esta skill audita los nombres de archivos en las carpetas de Actas de Reunión y Análisis de Llamada de un proyecto o cliente en Zoho Workdrive, identifica los que no siguen la nomenclatura oficial de Reinicia y ejecuta los renombrados validados por el usuario.

Opera únicamente sobre **documentos Zoho Writer nativos** (los `.docx` sin convertir se ignoran, ya que el endpoint de renombrado solo funciona con archivos nativos Writer).

---

## Paso 0 — Preguntas iniciales obligatorias

Antes de acceder a ninguna carpeta, preguntar siempre:

**1. ¿Qué cliente o proyecto se quiere revisar?**
*(Puede ser un Proyecto Activo, un posible cliente en Comercial, o ambos.)*

**2. ¿Qué ámbito de carpetas se debe revisar?**
- 📁 **Solo Proyectos Activos**
- 💼 **Solo carpetas de Comercial** (Comercial general, Comercial WhatsApp, Comercial Zoho)
- 🔁 **Ambos** (el cliente puede tener carpetas en las dos ubicaciones)

**3. ¿Qué tipo de documentos se quiere auditar?**
- 📋 **Solo Actas de Reunión**
- 📞 **Solo Análisis de Llamada**
- 📋📞 **Ambos tipos**

No proceder hasta tener respuesta a las tres preguntas.

---

## Paso 1 — Nomenclaturas válidas de Reinicia

### Actas de Reunión

```
YYYYMMDD-Acta-Reunion-[Descripción]-[CLIENTE]
```

Ejemplos válidos:
- `20260323-Acta-Reunion-Portal-Web-Hosting-Servicio-Acuerdos-HOMEESPANA`
- `20260415-Acta-Reunion-Seguimiento-Zoho-CRM-GONHER`

### Análisis de Llamada

```
YYYYMMDD-Analisis-Llamada-[Descripción]-[CLIENTE]
```

Ejemplos válidos:
- `20260310-Analisis-Llamada-Onboarding-CRM-AVADERM`
- `20260401-Analisis-Llamada-Seguimiento-Propuesta-TIMEDI`

### Reglas comunes

- Fecha al inicio en formato `YYYYMMDD` (8 dígitos)
- Separador: guión `-` (nunca espacios ni guiones bajos)
- Sin tildes ni caracteres especiales (`á → a`, `é → e`, `ó → o`, `ú → u`, `ñ → n`, `ü → u`)
- `[CLIENTE]` siempre en **mayúsculas**, sin espacios ni tildes
- `[Descripción]` en formato Title-Case con guiones: `Portal-Web-Hosting`
- El tipo de documento (`Acta-Reunion` o `Analisis-Llamada`) es obligatorio e invariable

### Regex de validación (referencia interna)

```
Acta:    ^[0-9]{8}-Acta-Reunion-.+-[A-Z0-9]+$
Llamada: ^[0-9]{8}-Analisis-Llamada-.+-[A-Z0-9]+$
```

---

## Paso 2 — Navegación en Workdrive

### IDs raíz conocidos

| Carpeta | ID |
|---|---|
| Proyectos Activos (Team Folder raíz) | `2km7j8be2bc8587ca4a01b6f044678ca4309e` |

> Las carpetas de Comercial se localizan dinámicamente (ver abajo).

### Lógica de navegación — Proyectos Activos

1. Listar el Team Folder raíz con `ZohoWorkdrive_getFolderFiles` (folder_id: `2km7j8be2bc8587ca4a01b6f044678ca4309e`)
2. Localizar la subcarpeta del cliente por nombre
3. Entrar en la subcarpeta de seguimiento (p.ej. `01. Seguimiento`)
4. Localizar las carpetas objetivo:
   - `Actas de Reuniones` (o nombre equivalente) — si el usuario pidió actas
   - `Análisis de Llamadas` (o nombre equivalente) — si el usuario pidió análisis

### Lógica de navegación — Carpetas de Comercial

1. Usar `ZohoWorkdrive_searchTeamFoldersFiles` con keywords `"Comercial"` para localizar la raíz
2. Dentro de ella, buscar subcarpeta del cliente si existe
3. Localizar las carpetas objetivo dentro de la estructura del cliente

### Confirmación de ruta siempre obligatoria

Antes de listar archivos, informar al usuario de la ruta encontrada y pedir confirmación:

> *"He localizado: `Proyectos Activos › HomeEspaña › 01. Seguimiento › Actas de Reuniones`. ¿Es correcta esta ubicación?"*

- ✅ Confirma → proceder a listar archivos
- ❌ Corrige → navegar a la ruta indicada o pedir el ID directamente
- ❓ No encontrada → indicarlo e informar al usuario para que proporcione la ruta o ID

Si el ámbito incluye **ambas ubicaciones** (Proyectos Activos + Comercial), confirmar cada una por separado antes de proceder.

---

## Paso 3 — Listar y analizar archivos

Para cada carpeta localizada y confirmada:

1. Llamar a `ZohoWorkdrive_getFolderFiles` con el `folder_id` correspondiente
2. Para cada archivo devuelto:
   - Extraer el nombre (`name`) y el ID del recurso (`id`)
   - Determinar el tipo esperado según la carpeta (Acta o Análisis de Llamada)
   - Aplicar la regex de validación correspondiente
   - Clasificar: ✅ **Correcto** / ⚠️ **Incorrecto**
3. Para los **incorrectos**, generar un nombre propuesto aplicando las reglas:
   - **Inferir la fecha del nombre actual** si es posible (buscar secuencias de 6 u 8 dígitos, formatos `YYYYMMDD`, `YYYY-MM-DD`, `DD/MM/YYYY`, etc.)
   - **Si la fecha no es inferible del nombre**, llamar a `ZohoWorkdrive_getFileOrFolderDetails` con el `resource_id` del archivo y extraer el campo `created_time`. Convertirlo al formato `YYYYMMDD` y usarlo como fecha en el nombre propuesto. Indicarlo visualmente en el informe con la nota `📅 fecha de creación`.
   - Eliminar tildes, reemplazar espacios por guiones, poner CLIENTE en mayúsculas
   - Insertar el tipo de documento si falta (`Acta-Reunion` o `Analisis-Llamada`)

**Ignorar** silenciosamente los archivos que no sean documentos Zoho Writer nativos (`.docx`, imágenes, PDFs, etc.).

---

## Paso 4 — Presentar el informe al usuario

Mostrar una tabla clara organizada por carpeta. Ejemplo:

---

**📁 Proyectos Activos › HomeEspaña › Actas de Reuniones**

| # | Nombre actual | Estado | Nombre propuesto |
|---|---|---|---|
| 1 | `20260323-Acta-Reunion-Portal-Web-Hosting-Servicio-Acuerdos-HOMEESPANA` | ✅ Correcto | — |
| 2 | `Acta reunion homeespana febrero 2026` | ⚠️ Incorrecto | `20260201-Acta-Reunion-HOMEESPANA` |
| 3 | `Llamada Onboarding` | ⚠️ Incorrecto | `20260310-Analisis-Llamada-Onboarding-HOMEESPANA` 📅 fecha de creación |

---

Después del informe, indicar:

> *"¿Quieres que proceda a renombrar todos los marcados como ⚠️, o prefieres seleccionar cuáles?*
> *Para los que tienen `[FECHA?]`, indícame la fecha correcta antes de continuar."*

---

## Paso 5 — Validación del usuario

Esperar respuesta explícita antes de ejecutar ningún cambio. Opciones:

- **"Renombra todos"** → proceder con todos los ⚠️ que tengan nombre propuesto completo (sin `[FECHA?]`)
- **"Renombra el 2 y el 3"** → proceder solo con los indicados
- **"El nombre propuesto del 2 debería ser X"** → actualizar el nombre propuesto y confirmar antes de ejecutar
- **"Cancela"** → no ejecutar ningún cambio

**Nunca renombrar sin confirmación explícita.**

---

## Paso 6 — Ejecutar renombrados

Para cada archivo a renombrar, llamar a `ZohoWriter_Update_Document_Meta`:

```json
{
  "path_variables": { "document_id": "<id_del_archivo>" },
  "query_params": { "from": "zoho_mcp" },
  "body": { "operations": "{\"name\": \"<nombre_propuesto>\"}" }
}
```

Ejecutar los renombrados **de uno en uno** y confirmar el resultado de cada operación antes de pasar al siguiente.

### Informe de resultados

Al finalizar, presentar resumen:

| Archivo | Resultado |
|---|---|
| `Acta reunion homeespana febrero 2026` | ✅ Renombrado a `20260201-Acta-Reunion-Onboarding-HOMEESPANA` |
| `2026-03-10 Llamada Onboarding` | ❌ Error — no se pudo renombrar (indicar motivo) |

Si algún renombrado falla, indicar el error devuelto por la API y sugerir al usuario revisarlo manualmente en Workdrive.

---

## Notas operativas

- **Documentos no nativos Writer:** Si `getFolderFiles` devuelve archivos `.docx` u otros formatos no nativos, ignorarlos en la auditoría e indicarlo al final del informe: *"X archivos no nativos (.docx) han sido omitidos — deben renombrarse manualmente en Workdrive."*
- **Carpetas vacías:** Si una carpeta de Actas o Análisis está vacía, indicarlo al usuario.
- **Carpeta no encontrada:** Si no se localiza la carpeta esperada dentro de la estructura del cliente, indicarlo y preguntar si el usuario quiere proporcionar el ID directamente.
- **Fecha de creación como fallback:** Si `created_time` está disponible en los metadatos pero el valor parece anómalo (p.ej. es muy reciente y no encaja con el contenido del nombre), indicarlo con 📅⚠️ y pedir confirmación al usuario antes de usarla.
- **Nombres ambiguos:** Si el tipo de documento (Acta vs. Análisis) no es inferible del nombre actual, preguntar al usuario antes de proponer un nombre.
- **Clientes con presencia en múltiples ubicaciones:** Si el ámbito es "Ambos", procesar primero Proyectos Activos y luego Comercial, presentando informes separados por ubicación.
