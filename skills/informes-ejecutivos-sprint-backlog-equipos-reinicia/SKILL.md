---
name: informes-ejecutivos-sprint-backlog-equipos-reinicia
description: >
  Skill para generar y actualizar los Informes Ejecutivos de Sprint Backlog por Equipo de Reinicia
  (Columbia, Proactive y futuros). Consume los Sprint Backlogs ya procesados por la skill
  revision-sprint-backlog-equipo-reinicia y produce un Zoho Sheet por Equipo con: portada, resumen
  ejecutivo agregado, comparativa entre miembros, detalle individual por persona (incluye Amigos
  Reinicia sin Sprint Backlog Zoho), alertas operativas (sobrecarga, productos vencidos, motivos
  de desvío) y acciones recomendadas para Dirección.

  Actívala cuando el PO líder pida: "genera el informe ejecutivo del Equipo [X]", "genera los
  informes ejecutivos por equipo", "actualiza los informes ejecutivos con los AUTOIA actuales",
  "cierre de sprint: dame los informes ejecutivos", o cuando se ejecute la tarea programada de
  cierre de sprint.

  Frecuencia: semanal (estado a mitad de sprint), al cierre de sprint, y a demanda.
  Skill secuencialmente posterior a revision-sprint-backlog-equipo-reinicia.
---

# SKILL: Informes Ejecutivos de Sprint Backlog por Equipo — Reinicia

> ⚠️ **VERSIÓN ESQUELETO v0.1 — En construcción.** Esta versión inicial define la estructura, los inputs/outputs esperados y el flujo en alto nivel. Los detalles de implementación técnica (tools MCP exactas, fórmulas, formato celda a celda) se completarán tras ejecutar el primer ciclo real con los AUTOIA actualizados del Sprint 05-26.

---

## Propósito

Generar un **Informe Ejecutivo por Equipo** (Columbia, Proactive, futuros) que sirva a Dirección y al PO líder para:

- **Entender el estado del sprint** de un vistazo (cuadre, sobrecarga, % utilización).
- **Comparar miembros del Equipo** entre sí y detectar desequilibrios de carga.
- **Identificar problemas operativos**: productos vencidos, parking, motivos de desvío reincidentes, sobrecarga proactiva.
- **Tomar decisiones**: redistribuir carga, sacar productos del backlog, ampliar capacidad con Amigos Reinicia, ajustar estimaciones.
- **Documentar mejoras propuestas** a la metodología/skills detectadas durante el sprint.

La skill **NO procesa Sprint Backlogs individuales** (eso lo hace `revision-sprint-backlog-equipo-reinicia`). Solo **consume** sus outputs ya cuadrados y los **agrega** a nivel Equipo en un Zoho Sheet con formato canónico.

---

## RELACIÓN CON OTRAS SKILLS

```
sprint-planning-reinicia (al inicio del sprint)
  ↓
revision-sprint-backlog-equipo-reinicia (semanal durante el sprint)
  ↓ (consume sus outputs cuadrados)
informes-ejecutivos-sprint-backlog-equipos-reinicia (esta skill)
  ↓
Dirección y PO líder
```

**Precondición crítica**: la skill asume que **todos los Sprint Backlogs de los miembros del Equipo ya han sido procesados** por la skill de revisión (cuadre 100%, huérfanas integradas, bloque Metodología creado, motivos de desvío rellenos). Si no, la skill avisa y propone ejecutar antes la skill de revisión.

---

## ÁMBITO Y BÚSQUEDA DINÁMICA

⚠️ **Esta skill, al igual que la de revisión, NO mantiene una lista hardcoded de Equipos ni de miembros.** Equipos, miembros y clientes cambian sprint a sprint.

### Confirmación inicial (Paso 0)

Al activarse, la skill **siempre confirma** con el PO líder:

1. **Equipo(s) a procesar**. Si el PO no lo dice explícitamente, la skill consulta ClickUp para listar Equipos detectados y los presenta al PO para confirmación.
2. **Miembros del Equipo** (incluidas personas transversales y Amigos Reinicia sin Sprint Backlog Zoho).
3. **Sprint a documentar** (sprint actual por defecto, con opción de seleccionar otro).
4. **Tipo de informe**: parcial (estado a mitad de sprint) o cierre (informe final).
5. **Carpeta destino en Workdrive** donde guardar el Sheet generado.

---

## ESTRUCTURA CANÓNICA DEL INFORME EJECUTIVO

Plantilla validada con el Informe Ejecutivo del Equipo Columbia Sprint 05-26 (`p9ticf86741d7ee6346b69645720b029c9618`).

### 7 pestañas estándar

| # | Pestaña | Propósito |
|---|---|---|
| 1 | **Portada** | Identificación del informe (Equipo, sprint, fechas, autoría, versión) |
| 2 | **Resumen Equipo** | KPIs agregados del Equipo (capacidad, tracked, % utilización, sobrecarga, top alertas) |
| 3 | **Comparativa Personas** | Tabla comparativa una fila por miembro del Equipo (incluyendo Amigos Reinicia) |
| 4..N | **Detalle [Persona]** | Una pestaña por miembro con desglose individual (productos, motivos de desvío, mejoras) |
| N+1 | **Detalle Alertas Equipo** | Alertas operativas consolidadas: sobrecarga, productos vencidos, parking, motivos reincidentes |
| N+2 | **Acciones Equipo** | Decisiones recomendadas y compromisos a discutir en Sprint Review |

### Pestaña adicional para casos especiales

- **Detalle [Amigo Reinicia]** (caso Síntaris, Chisco, etc.): si imputan horas en ClickUp pero no tienen Sprint Backlog Zoho propio, se les crea pestaña aparte con sus horas tracked agregadas.

---

## CONTENIDO POR PESTAÑA

> 🚧 **TODO**: el detalle exacto de celdas, fórmulas y formato de cada pestaña se documentará tras ejecutar el primer ciclo real con AUTOIA actualizados. Lo que sigue es la estructura macro.

### Pestaña 1 — Portada
- Logo y marca Reinicia
- Equipo (Columbia / Proactive / [Otro])
- Sprint identificador (ej. "Sprint 05-26")
- Fechas inicio-fin del sprint
- Tipo de informe (Parcial / Cierre)
- Autor + fecha de generación
- Enlace al Sprint Backlog AUTOIA de cada miembro

### Pestaña 2 — Resumen Equipo
KPIs principales:
- Capacidad total del Equipo (h)
- Total tracked (h) — desglose: plan / metodología / huérfanas
- % utilización
- Sobrecarga (estim - capacidad)
- Productos planificados completados / en curso / vencidos
- Productos huérfanos integrados (Grupo B+C)
- Distribución por cliente (top 5)
- Top 5 alertas más críticas (resumen, detalle en pestaña Alertas)
- Mejoras Propuestas Skill Sprint Backlog: documentar en Reinnova ClickUp (resumen)

### Pestaña 3 — Comparativa Personas
Tabla con una fila por miembro:

| Persona | Capacidad | Tracked plan | Tracked metodología | Tracked total | % util | Sobrecarga | Productos planif. | Huérfanas B+C | Filas con desvío negativo | Motivo desvío más frecuente |
|---|---|---|---|---|---|---|---|---|---|---|

Incluye fila para cada Amigo Reinicia con horas tracked aunque sin Sprint Backlog Zoho (capacidad y % util quedan en blanco o N/A).

### Pestaña 4..N — Detalle [Persona]
Una pestaña por miembro con:
- Cuadre AUTOIA del miembro (extraído del Log de Cambios del AUTOIA)
- Distribución de tiempo por cliente y por fase de proyecto
- Productos del Sprint Backlog principal con estado actual y horas
- Huérfanas integradas (Grupo B y C)
- Bloque Metodología y Gestión
- **Filas con desvío negativo (J<0)**: tabla con concepto, F-estim, I-tracked, J-diff, **Motivo desvío** (Col K) y **Comentario** (Col L)
- Alertas individuales (sobrecarga, productos sin estimación, etc.)
- Mejoras propuestas detectadas durante el procesamiento de su Sprint Backlog

### Pestaña N+1 — Detalle Alertas Equipo
Consolidación de alertas operativas:
- **Sobrecarga**: huérfanas Grupo B con estimación significativa que rompen el plan
- **Productos vencidos**: status `DOING` o anterior con fecha límite ya pasada
- **Productos en `parking e incidencias`**: lista para discusión en Sprint Review
- **Productos de Soporte sin estimación informada** (norma Reinicia incumplida)
- **Time entries sin task asociada** detectados durante la revisión
- **Motivos de desvío más frecuentes** (agregado dropdown Col K)
- **Mejoras Propuestas Skill Sprint Backlog: documentar en Reinnova ClickUp** (lista completa)

### Pestaña N+2 — Acciones Equipo
Decisiones y compromisos recomendados:
- Productos a sacar del Sprint Backlog para abordar sobrecarga
- Reasignaciones a Amigos Reinicia propuestas
- Productos a renegociar con cliente (alcance, fechas)
- Estimaciones a revisar con el PO Cliente
- Cambios de proceso interno propuestos
- Acciones de retrospective (qué mejorar el siguiente sprint)
- Responsable de cada acción y plazo

---

## INPUTS DE LA SKILL

| Input | Origen | Usado en |
|---|---|---|
| Sprint Backlog AUTOIA por miembro | Workdrive (carpeta del sprint) | Pestañas Detalle [Persona], Comparativa, Resumen |
| Hoja `Tiempos` cuadrada | AUTOIA del miembro | Métricas de horas, motivos de desvío, alertas |
| Hoja `Log de Cambios` | AUTOIA del miembro | Trazabilidad de cambios aplicados durante revisión |
| Sheet de capacidad del Equipo | Workdrive (`7f4pe6b0dbe08986b48ad8a9242b549ad7eaf` Sprint 05-26 — verificar por sprint) | Capacidad por miembro |
| ClickUp time entries por persona | API ClickUp | Validación cruzada y horas de Amigos sin Sprint Backlog |
| ClickUp tareas filtradas por Equipo | API ClickUp | Productos vencidos, status, parking |
| Plantilla canónica del Informe Ejecutivo | Workdrive (referencia: `p9ticf86741d7ee6346b69645720b029c9618`) | Estructura de pestañas y formato |

---

## OUTPUT DE LA SKILL

Un **Zoho Sheet por Equipo** con las 7 pestañas estándar, guardado en la carpeta del sprint en Workdrive con nomenclatura:

```
Informe Ejecutivo Sprint Backlog [Equipo] [Sprint identificador].xlsx
```

Ejemplo: `Informe Ejecutivo Sprint Backlog Columbia 05-26.xlsx`.

---

## FLUJO DE EJECUCIÓN

> 🚧 **TODO**: detallar cada paso con tool calls específicas tras la primera ejecución real.

### PASO 0 — Confirmación dinámica
- Confirmar Equipo(s) a procesar.
- Confirmar miembros (incluyendo transversales y Amigos Reinicia sin Sprint Backlog).
- Confirmar sprint a documentar.
- Confirmar tipo de informe (parcial / cierre).
- Confirmar carpeta destino.

### PASO 1 — Verificación de precondiciones
- Comprobar que **todos los AUTOIA del Equipo están procesados** (la skill de revisión se ha ejecutado en cada uno).
- Si falta alguno, **avisar al PO** y proponer ejecutar la skill de revisión antes.
- Si hay **Amigos Reinicia sin Sprint Backlog Zoho**, recopilar sus time entries de ClickUp para incluirlos como pestaña.

### PASO 2 — Lectura de datos por miembro
- Por cada miembro, leer:
  - Hoja `Tiempos` completa (Sprint Backlog principal + huérfanas + bloque Metodología)
  - Hoja `Log de Cambios` (extraer alertas, propuestas de mejora, motivos de desvío)
  - Capacidad del miembro (de Sheet de capacidad)
- Acumular datos en estructura de Python para agregación.

### PASO 3 — Lectura de datos transversales de ClickUp
- Productos del Equipo con status `DOING` y fecha límite vencida.
- Productos en `parking e incidencias`.
- Time entries de Amigos Reinicia sin Sprint Backlog Zoho.

### PASO 4 — Cálculo de KPIs agregados
- Capacidad total Equipo.
- Total tracked y desglose plan / metodología / huérfanas.
- % utilización.
- Sobrecarga.
- Distribución por cliente.
- Productos por status.
- Motivos de desvío agregados (dropdown Col K).

### PASO 5 — Creación / actualización del Zoho Sheet
- Si es **primera generación del sprint**: duplicar plantilla canónica y renombrar.
- Si es **actualización** (informe parcial → cierre): abrir el Sheet existente y actualizar contenido.
- Crear pestañas necesarias (incluyendo una por miembro y por Amigo Reinicia).

### PASO 6 — Rellenar pestaña Portada
- Datos identificativos del Equipo, sprint, fechas, autor, versión.

### PASO 7 — Rellenar pestaña Resumen Equipo
- KPIs agregados, top 5 alertas, top 5 mejoras propuestas.

### PASO 8 — Rellenar pestaña Comparativa Personas
- Una fila por miembro con métricas comparables.

### PASO 9 — Crear pestañas Detalle por Persona
- Una pestaña por miembro con desglose individual.
- Pestañas adicionales para Amigos Reinicia sin Sprint Backlog Zoho.

### PASO 10 — Rellenar pestaña Detalle Alertas Equipo
- Consolidación de alertas operativas detectadas en cada AUTOIA + transversales de ClickUp.

### PASO 11 — Rellenar pestaña Acciones Equipo
- Decisiones recomendadas, derivadas de las alertas y de la sobrecarga detectada.
- Esta pestaña puede requerir **input del PO líder** para validar las acciones propuestas antes de incluirlas.

### PASO 12 — Validación y entrega
- Verificar coherencia de datos entre pestañas (ej. suma de tracked en Comparativa = suma en Detalle de cada persona).
- Generar URL de acceso al Sheet.
- Reporte final al PO líder con resumen y enlace.

---

## INTERACCIÓN CON EL PO LÍDER DURANTE LA EJECUCIÓN

> 🚧 **TODO**: especificar puntos de validación obligatorios.

Casos donde la skill **debe pedir input al PO** antes de continuar:

- Discrepancias detectadas entre AUTOIA (ej. cuadre KO en alguno).
- Acciones propuestas en la pestaña Acciones Equipo.
- Mejoras propuestas a la skill `revision-sprint-backlog-equipo-reinicia` detectadas durante la generación.
- Inclusión de un Amigo Reinicia con horas tracked como pestaña aparte.

---

## OPERACIONES DESTRUCTIVAS Y AUDITORÍA

> 🚧 **TODO**: definir si esta skill mantiene también su propio Log de Cambios o si se apoya en los Log de los AUTOIA. Mi propuesta inicial: **un Log propio en una pestaña adicional del Informe Ejecutivo** llamada "Log de Generación" que registre cada generación y actualización del Informe.

---

## RECURSOS CLAVE

### Constantes de marca Reinicia
- Azul primario: `#3812CF`
- Acento: `#D9D0FB`
- Filas alternas: `#EBEBEB`
- Total fila: `#D9D0FB`
- Fuentes: Manrope Regular y Manrope Bold

### Plantilla canónica de referencia
- Informe Ejecutivo Equipo Columbia Sprint 05-26: `p9ticf86741d7ee6346b69645720b029c9618`
- Informe Ejecutivo Equipo Proactive Sprint 05-26: `p9ticd3012db452cd4137b59248ed46b5512b`
- Informe Ejecutivo Paolo Sprint 05-26: `p9tic3a7d7cda48b1451696c166509c3ff35a`
- Informe Ejecutivo Fabián Sprint 05-26: `p9tic51207f22fa6742e68f2620efaec33a05`

### Herramientas MCP usadas
> 🚧 **TODO**: listar tras primera ejecución. Esperadas:
- **Zoho Workdrive Sheet**: `ZohoSheet_list_all_worksheets`, `ZohoSheet_get_content_of_range`, `ZohoSheet_set_content_to_range`, `ZohoSheet_create_worksheet`, `ZohoSheet_copy` (para duplicar plantilla), `ZohoSheet_format_ranges`.
- **Zoho Workdrive**: `ZohoWorkdrive_copyFileOrFolder` (para crear el Sheet a partir de plantilla en la carpeta del sprint).
- **ClickUp**: `clickup_filter_tasks`, `clickup_get_time_entries`, `clickup_get_task` (para detalles de productos vencidos y parking).

---

## LIMITACIONES TÉCNICAS CONOCIDAS

> 🚧 **TODO**: completar tras primera ejecución real.

Heredadas de la skill de revisión:
1. **Formato numérico personalizado no soportado en API**: aceptar decimales largos en celdas con fórmula.
2. **Time entries sin task no recuperables**: reportar al PO como anomalía.
3. **`worksheet_id` varía entre ficheros**: siempre listar primero.

Específicas de esta skill (a confirmar):
- Sin tool nativo de "duplicar plantilla y renombrar" en Zoho Sheet API: posiblemente haya que crear cada pestaña programáticamente.
- Generación de gráficos integrados: pendiente de validar si la API soporta crearlos o si solo se dejan tablas tabulares.

---

## VERSIONES

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| **v0.1 (esqueleto)** | 2026-05-03 | Néstor + Claude | Esqueleto inicial. Estructura validada con el Informe Ejecutivo Columbia Sprint 05-26 (7 pestañas). Inputs/outputs/flujo en alto nivel. Pendiente detalle técnico tras primera ejecución real. |

---

## PENDIENTES DE EVOLUCIÓN

### Para la próxima iteración (tras primera ejecución real)
- **Detallar contenido celda a celda** de cada pestaña inspeccionando la plantilla Columbia.
- **Especificar tool calls exactas** para cada paso del flujo.
- **Definir formato y fórmulas** de la pestaña Comparativa Personas.
- **Decidir mecanismo de "actualización" vs "regeneración"** (informe parcial → cierre).
- **Validar generación de gráficos** o aceptar que el formato sea solo tabular.
- **Especificar punto de validación humana** en la pestaña Acciones Equipo.

### A futuro (medio plazo)
- **Export adicional a Word/PDF** para Dirección si se solicita.
- **Comparativa entre sprints** (sprint actual vs anteriores) en una pestaña aparte.
- **Detección automática de patrones de desvío** entre sprints (ej. mismo cliente con `COORDINACIÓN CLIENTE` recurrente).
- **Dashboard agregado de varios Equipos** para vista global de Reinicia.
- **Plantilla canónica del Informe** documentada como Sheet base que se duplica (en lugar de generar desde cero).
- **Tabla canónica de Métodos de desvío en ClickUp** alimentada con los hallazgos de cada sprint.
