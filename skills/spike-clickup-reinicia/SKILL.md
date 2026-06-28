---
name: spike-clickup-reinicia
description: >
  Skill complementaria para crear y cerrar SPIKEs en ClickUp para clientes de Reinicia. Cubre el contenido
  específico de un SPIKE (hipótesis, preguntas de investigación, alcance, criterios de aceptación) y el
  flujo de cierre con generación opcional del documento de Diseño Funcional con marca Reinicia.

  Esta skill NO la invoca el usuario directamente: la invocan las skills madre de creación de productos
  (Zoho, Web, WABA) cuando un producto de la propuesta de estructura es un SPIKE. La skill madre conserva
  la elicitación general (cliente, lista, PO, equipo) y delega aquí el contenido específico del SPIKE.

  También se invoca cuando el PO vuelve a Claude para cerrar formalmente un SPIKE: ejecuta el flujo de
  cierre formal de formato-tarjeta-clickup-reinicia (sección 11) y, opcionalmente, genera el documento
  de Diseño Funcional con marca Reinicia.
---

# Skill: SPIKE en ClickUp — Reinicia

> **Versión vigente: v1.0 — 21/06/2026** · ver changelog al final (`## Versiones`)

## Propósito

Cubre el contenido específico de un SPIKE (Solution Probe Investigation Knowledge Effort) en ClickUp para clientes de Reinicia: estructura propia, hipótesis a validar, preguntas de investigación, alcance Sí/No, subtareas tipo de investigación, criterios de aceptación específicos de SPIKE, y flujo de cierre con generación opcional del documento de Diseño Funcional con marca Reinicia.

Es una **skill complementaria** — no autónoma. La invocan las skills madre de creación de productos cuando un producto del backlog se identifica como SPIKE. El formato visual de la tarjeta lo gobierna `formato-tarjeta-clickup-reinicia`; esta skill aporta el **contenido** propio del SPIKE.

---

## 1. Cuándo se considera SPIKE un producto

Un producto es un SPIKE — y por tanto activa esta skill — cuando se cumple **al menos una** de estas condiciones:

- **Investigación de viabilidad técnica** previa a una implementación (¿se puede hacer? ¿con qué mecanismo?).
- **Exploración de alternativas** cuando el PO no tiene aún claro el enfoque.
- **Validación de una hipótesis técnica** del PO antes de comprometerse a un producto de implementación.
- **Análisis de impacto** de un cambio sobre sistemas existentes (integraciones, performance, seguridad).
- **Prueba de concepto** acotada en sandbox antes de escalar.

Un producto NO es SPIKE cuando:
- El alcance está definido y solo falta ejecutar (es **producto de implementación**).
- Es trabajo recurrente de soporte (es **producto de soporte**).
- Es una entrega concreta acordada con el cliente y presupuestada (es **producto contratado**).

**Convención de nombres:** los SPIKEs son la **excepción documentada** en la sección 2.13 "Convención del nombre de la tarjeta" de `formato-tarjeta-clickup-reinicia`. Su nombre describe el **objeto de investigación** (no un entregable cerrado, porque el entregable es conocimiento sobre ese objeto) y lleva prefijo `[SPIKE]`. Patrón: `[SPIKE] [Objeto de investigación] [CLIENTE]`. Ejemplo: `[SPIKE] Automatic Opportunity Closure (Quote → Sales Order) [CARRITECH]`.

---

## 2. Punto de invocación desde la skill madre

La skill madre (`productos-digitales-zoho-clickup-reinicia`, `productos-digitales-web-clickup-reinicia` o `productos-digitales-waba-clickup-reinicia`) invoca esta skill **en el Paso 4 (Detalle de cada producto)**, cuando llega el turno de un producto marcado como SPIKE en la propuesta de estructura del Paso 3.

La skill madre transfiere a la skill SPIKE el siguiente contexto ya elicitado:

- Cliente y proyecto
- Lista destino en ClickUp e ID
- PO de Reinicia
- Equipo asignado al SPIKE concreto (si ya está acordado)
- Amigos Reinicia que participen
- Tipo de producto (CRM / WEB / WABA / etc.)
- Épica y PBI de primer nivel acordados
- Documentación disponible (Sprint Cero, Propuesta, actas, web cliente, etc.)
- Contexto general del proyecto (para los bloques RESUMEN y Contexto)

La skill SPIKE NO repite la elicitación que ya hizo la skill madre. Se concentra en el contenido específico del SPIKE.

---

## 3. Contenido específico del SPIKE (Paso 4 expandido)

Dentro del Paso 4 de la skill madre, esta skill ejecuta el siguiente sub-flujo. Las preguntas se hacen **una a una**, no en bloque.

### 3.1 Pregunta S1 — Resumen del SPIKE

```
Para el bloque RESUMEN, ¿qué frase corta resume mejor lo que va a investigar este SPIKE?
Te propongo: "[propuesta de Claude]"
```

Claude propone una frase basada en lo que sabe; el PO la acepta o la ajusta.

### 3.2 Pregunta S2 — Historia de usuario

Claude propone la Historia de usuario en formato:

```
Como [rol del solicitante], QUIERO investigar y validar [objetivo del SPIKE], PARA [decisión que se podrá tomar al cierre].
```

El PO valida o ajusta. Es importante que la historia de usuario refleje que es **una investigación**, no una entrega final.

### 3.3 Pregunta S3 — Hipótesis a validar (opcional)

Esta pregunta es **mixta** según contexto disponible:

- **Si en la conversación con la skill madre el PO ya ha mencionado una hipótesis técnica concreta**, Claude la formaliza siguiendo el patrón del bloque "🧩 Hipótesis de solución a validar" y se la presenta para validación.
- **Si NO hay hipótesis en el contexto**, Claude pregunta abierto:

```
¿Tienes alguna hipótesis técnica que quieras dejar registrada como punto de partida
de la investigación? Si la tienes, la incluyo en el bloque "🧩 Hipótesis de solución
a validar". Si no, este bloque se omite.
```

Importante: la hipótesis SIEMPRE va con la cita inicial que aclara *"Punto de partida de la investigación, no la solución aprobada"* — esto es invariable y previene que el bloque se interprete como decisión cerrada.

### 3.4 Pregunta S4 — Preguntas de investigación (opcional)

Mismo enfoque mixto:

- **Si hay hipótesis técnica del PO**, Claude propone preguntas de investigación derivadas de esa hipótesis (qué hay que confirmar para validarla). Ejemplo: si la hipótesis es "usar una función Deluge sobre Sales Order", las preguntas serán "¿se puede capturar el evento de conversión Quote→SO con un workflow rule?", "¿la relación se propaga al Sales Order recién creado?", etc.
- **Si NO hay hipótesis pero el PO quiere registrar preguntas abiertas**, Claude pregunta abierto:

```
¿Quieres dejar planteadas en la tarjeta las preguntas que el SPIKE debe responder?
Si las tienes ahora, las registro como "❓ Preguntas a responder durante el SPIKE".
Si prefieres dejarlas para el inicio de la investigación, omitimos el bloque y se
añaden cuando arranque el equipo operativo.
```

### 3.5 Pregunta S5 — Alcance Sí/No

Para SPIKEs, el bloque **🎯 Alcance es muy recomendable** (aunque sea opcional en el patrón canónico). Los SPIKEs son especialmente propensos a expandir su alcance ("ya que estamos investigando, miramos también..."). Claude propone explícitamente el alcance:

```
Te propongo este alcance del SPIKE:

✅ Sí — dentro del SPIKE:
  - [Items propuestos por Claude basados en hipótesis y preguntas]

❌ No — fuera del SPIKE:
  - Implementación en producción
  - Cobertura de todos los casos borde
  - Formación a usuarios
  - [Otros items que Claude detecte como riesgo de scope creep]

Todo lo de "No" vivirá en el producto de implementación posterior si la
investigación lo justifica. ¿Te encaja el alcance, o lo ajustamos?
```

### 3.6 Pregunta S6 — Ready to Backlog

Claude propone los prerequisitos típicos de un SPIKE:

- Accesos al sistema relevante con permisos suficientes (registrados en Zoho Vault)
- Entorno sandbox o entorno de pruebas disponible
- Confirmación del listado de elementos relevantes del sistema (stages, módulos, plataformas, según aplique)
- Documentación accesible de las integraciones afectadas (si las hay)
- Confirmación de criterios de comportamiento del cliente para los casos borde

El PO añade o quita según el caso concreto.

### 3.7 Pregunta S7 — Subtareas

Las subtareas de un SPIKE siguen un patrón diferenciado de los productos de implementación. Son subtareas **de investigación**, no de ejecución. Claude propone una estructura tipo:

```
1. Entrevista corta con [rol del solicitante / experto del cliente] para validar
   Ready to Backlog y cerrar casos borde
2. Auditoría técnica del sistema [cliente] (esquema actual, integraciones,
   restricciones)
3. Investigación en documentación oficial [Zoho / WordPress / Woztell / etc.]
   sobre [mecanismo investigado]
4. Prueba de concepto en sandbox — camino feliz de la hipótesis
5. Análisis de impacto sobre [integraciones existentes / sistemas críticos]
6. Documento de recomendación técnica (hipótesis confirmada/refutada,
   alternativas, casos borde, estimación)
7. Validación Reinicia (PO Técnico)
8. Validación Cliente (sesión con solicitante y decisión sobre siguiente paso)
```

Claude adapta estas subtareas al SPIKE concreto. El PO valida o ajusta.

### 3.8 Pregunta S8 — Criterios de aceptación

Los criterios de aceptación de un SPIKE se diferencian de los de implementación:

- **Técnicos**: condiciones del entorno (sandbox disponible, accesos, sin impacto en producción durante la investigación)
- **Funcionales**: confirmaciones que la investigación debe entregar (mecanismo identificado, alcance acordado, casos borde documentados)
- **De proceso**: documento de recomendación entregado, decisión del cliente registrada, transición clara al producto de implementación si procede

Claude propone los criterios y los deja preparados para que el PO los copie al checklist tras la creación (limitación de ClickUp documentada en `formato-tarjeta-clickup-reinicia` sección 7).

### 3.9 Pregunta S9 — Estimación de tiempo

```
¿Cuántas horas estimas para este SPIKE? (Lo dejamos en el campo "Tiempo estimado".)
```

SPIKEs típicos de Reinicia van de **8 a 24 horas**. Si el PO estima más, conviene preguntar si en realidad se trata de un SPIKE o de un producto de consultoría (que merecería otro tratamiento).

---

## 4. Estructura final de la descripción del SPIKE

Aplica el patrón canónico de `formato-tarjeta-clickup-reinicia`. Los bloques que aplican siempre a un SPIKE son:

- ✅ RESUMEN
- ✅ Historia de usuario
- ✅ Descripción
- 🟡 Requerimientos Cliente — sólo si el SPIKE nace de petición directa del cliente (raro, pero posible)
- ✅ Ready to Backlog
- 🟡 Hipótesis de solución a validar — según S3
- 🟡 Preguntas a responder durante el SPIKE — según S4
- ✅ Contexto
- ✅ Alcance — siempre recomendable en SPIKEs
- ✅ Entregables
- ✅ Documentación de referencia
- ✅ Resultado y cierre (diferido)

Los bloques marcados 🟡 son los que la skill SPIKE puede activar o desactivar según las respuestas del PO.

---

## 5. Convenciones específicas de SPIKE

### 5.1 Plantilla de Diseño Funcional como entregable Reinicia

El bloque "📦 Entregables" del SPIKE incluye **siempre** el entregable interno:

```markdown
**Reinicia (interno):**
- Privado - Documento de Diseño Funcional - [CLIENTE] → basado en [Plantilla-DF-Conector-Zoho-CRM-y-Plataforma-X-REINICIA](https://workdrive.zoho.eu/file/6vv8s83c30c1303674c5cbbd32b9f89519110)
- Privado - Documento de Diseño Funcional - [CLIENTE] (enlace externo para Amigos Reinicia)
- Privado - Elaboración del plan de pruebas → basado en [Plantilla-Pruebas-Funcionales-Reinicia](https://workdrive.zoho.eu/file/b6g99e39964d2bbbe4173a46f3a80f0b8c905)
```

La generación del `.docx` se ejecutará **al cierre del SPIKE**, no al crearlo (ver sección 7).

### 5.2 Tag "spike" en ClickUp

Toda tarjeta de SPIKE lleva el tag `spike` en ClickUp además de los tags habituales del tipo de producto (`zoho crm`, `web`, `waba`, etc.). Esto permite filtrar SPIKEs en el backlog y reporting.

### 5.3 Convención de nombres del documento de Diseño Funcional

Cuando se genere el `.docx` (sección 7), el nombre sigue la convención:

```
YYYYMMDD-Diseno-Funcional-SPIKE-[Descripción]-[CLIENTE].docx
```

Ejemplo: `20260423-Diseno-Funcional-SPIKE-Cierre-Oportunidad-CARRITECH.docx`.

---

## 6. Devolución de control a la skill madre

Una vez la skill SPIKE ha rellenado la plantilla del producto SPIKE y obtenido el OK del PO, **devuelve el control a la skill madre** para que ésta:

1. Cree la tarjeta en ClickUp con `clickup_create_task` y los campos personalizados.
2. Cree las subtareas con `clickup_create_task` + `parent`.
3. Pegue el comentario con criterios de aceptación.
4. Pregunte al PO sobre asignación de subtareas (sección 5 de `formato-tarjeta-clickup-reinicia`).
5. Continúe con el siguiente producto de la propuesta de estructura (sea SPIKE u otro).

La skill SPIKE **no ejecuta directamente** las llamadas a la API de ClickUp. Esa responsabilidad es de la skill madre, que ya tiene el flujo completo de creación.

---

## 7. Cierre formal del SPIKE

Cuando el PO vuelve a Claude para cerrar el SPIKE, esta skill se invoca para coordinar el cierre. Aplica el flujo de cierre formal de `formato-tarjeta-clickup-reinicia` (sección 11) **con una extensión propia**: la generación opcional del documento de Diseño Funcional.

### 7.1 Flujo

**Paso 7.1 — Detección del cierre**

Triggers que activan el cierre del SPIKE:
- "Cierra el SPIKE de [cliente] sobre [tema]"
- "Vamos a cerrar formalmente el SPIKE [nombre o ID]"
- "Hemos terminado el SPIKE de [cliente], registra el cierre"

**Paso 7.2 — Aplicar flujo formal de cierre**

Claude ejecuta los pasos definidos en `formato-tarjeta-clickup-reinicia` sección 11:
- Pregunta C1 (tarjeta), C2 (persona del Equipo Operativo), C3 (fuentes adicionales)
- Recopilación de información
- Síntesis estructurada de los 6 sub-bloques
- Validación con el PO
- Doble escritura (descripción + comentario)
- Enlace a producto derivado si aplica

**Paso 7.3 — Pregunta extensión SPIKE: ¿generamos el `.docx`?**

Después del cierre formal genérico (Paso 7.2), Claude pregunta al PO:

```
He registrado el cierre del SPIKE en la descripción y en un comentario.
¿Quieres que genere también el documento de Diseño Funcional con marca Reinicia
(.docx) basado en las conclusiones del SPIKE?

Sí — lo genero ahora con la información del cierre y te lo entrego para que
   lo subas a Workdrive y lo conviertas a Zoho Writer.
No — el SPIKE concluye sin documento formal (típico cuando la conclusión es
   refutada o cuando se cierra con un comentario suficiente).
```

**Paso 7.4 — Generación del `.docx` (si el PO dice sí)**

Si el PO confirma, Claude genera el documento siguiendo:

- **Estructura del documento:** 6 secciones canónicas — Objetivo / Contexto y problemática / Análisis y propuesta / Diseño técnico-funcional (Mapa de componentes + Modelo de datos) / Criterios de aceptación / Riesgos.
- **Marca visual:** aplicar la skill `marca-reinicia`. Logo oficial Reinicia (extraído de `TEST-Merge-Store-HomeEspana.docx`, `word/media/image3.png`), color brand blue `#3812CF`, color light accent `#D9D0FB`, color alternating grey `#EBEBEB`, fuentes Manrope Regular y Manrope Bold.
- **Cabecera:** logo a 120×22px en la izquierda + nombre del fichero alineado a la derecha + línea horizontal azul Reinicia debajo.
- **Nombre del fichero:** convención `YYYYMMDD-Diseno-Funcional-SPIKE-[Descripción]-[CLIENTE].docx`.
- **Output:** primero a `/home/claude/`, luego copia a `/mnt/user-data/outputs/` y se presenta al PO con `present_files`.

**Paso 7.5 — Recordatorio de flujo Opción C**

Tras entregar el `.docx`, Claude recuerda al PO el flujo Opción C:

```
📝 Recordatorio del flujo de documentación generada:

1. Sube el .docx a Workdrive (vía Truesync).
2. Conviértelo a Zoho Writer (clic derecho → Abrir con → Zoho Writer).
3. Copia la URL del Writer y pégamela aquí: actualizaré el bloque
   "Documentación generada" del bloque "Resultado y cierre" de la tarjeta
   ClickUp con ese enlace.

A partir de ese momento, las ediciones del Writer son directas en Zoho.
Si necesitas regenerar el .docx por una actualización mayor, dímelo.
```

**Paso 7.6 — Actualización del bloque "Documentación generada"**

Cuando el PO entregue la URL del Zoho Writer, Claude actualiza el sub-bloque "Documentación generada" del bloque "🏁 Resultado y cierre" de la tarjeta con esa URL.

---

## 8. Variantes por tipo de producto

Aunque el flujo es transversal, hay matices según el tipo de SPIKE. La skill SPIKE detecta el tipo desde el contexto de la skill madre (CRM / DESARROLLO WEB / WHATSAPP CORPORATIVO) y aplica los siguientes matices:

### 8.1 SPIKE Zoho CRM

- **Subtareas típicas:** auditoría del CRM, investigación documentación oficial Zoho, prueba en sandbox Zoho, análisis de impacto sobre integraciones existentes (Business Central, Books, Campaigns, etc.).
- **Plantilla de Diseño Funcional:** `Plantilla-DF-Conector-Zoho-CRM-y-Plataforma-X-REINICIA` en Recursos Comunes Workdrive.
- **Casos típicos:** automatizaciones Deluge, conectores entre CRM y plataformas externas, blueprints, optimización de procesos comerciales en CRM.
- **Equipo habitual:** PO Técnico Reinicia + Amigo Reinicia especialista Zoho (Síntaris, Síntaris+Seuba, etc.).

### 8.2 SPIKE Web

- **Subtareas típicas:** auditoría del stack web (WordPress / Drupal / React), investigación en documentación del framework / plugins, prueba de concepto en entorno staging, análisis de impacto sobre integración con CRM o con web actual.
- **Plantilla de Diseño Funcional:** la plantilla genérica de Diseño Funcional de Recursos Comunes (mismo `Plantilla-DF-Conector-Zoho-CRM-y-Plataforma-X-REINICIA` cuando hay integración con CRM, o equivalente web cuando aplique).
- **Casos típicos:** integraciones CRM-Web, optimización de performance, accesibilidad (WCAG), prueba de plugins, migración de stack.
- **Equipo habitual:** PO Técnico Reinicia + Amigo Reinicia especialista web (Síntaris para webs Zoho widget, Chisco para WordPress/Drupal).

### 8.3 SPIKE WABA

- **Subtareas típicas:** investigación de capacidades de la plataforma WABA (Woztell, Blip, Eazybe), pruebas de límites de API de Meta, validación de plantillas aprobadas, prototipado del flujo conversacional en sandbox.
- **Plantilla de Diseño Funcional:** plantilla de Recursos Comunes adaptada al contexto WABA (consultar en Plantillas Reinicia si existe versión específica).
- **Casos típicos:** chatbots conversacionales nuevos, campañas masivas WhatsApp, automatizaciones desde Zoho CRM, integración con catálogo Meta.
- **Equipo habitual:** PO Técnico Reinicia + Amigo Reinicia especialista WABA si lo hay.

---

## 9. Versionado

| Versión | Fecha | Cambio |
|---|---|---|
| v1.0 | 2026-04-23 | Versión inicial. Skill complementaria a las skills madre de Zoho/Web/WABA. Decisiones acordadas con el PO: invocación desde Paso 4 de la skill madre (P23.b), enfoque mixto para hipótesis y preguntas (P24.c), sin categorización formal del SPIKE (P25.b), cierre formal con extensión propia para generación opcional del .docx (P26.b). Flujo con 9 preguntas (S1-S9) en creación + 6 pasos en cierre (7.1-7.6) integrando el flujo formal de cierre de formato-tarjeta-clickup-reinicia. |

## Versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0 | 21/06/2026 | Néstor + Claude | Estado previo sin versionar, tabulado por primera vez al incorporar el estándar de versionado de Reinicia (21/06/2026). Creación y cierre de SPIKEs en ClickUp con contenido específico (hipótesis, preguntas, alcance, criterios) y Diseño Funcional opcional. |
