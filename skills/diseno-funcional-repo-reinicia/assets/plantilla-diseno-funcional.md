<!--
PLANTILLA CANÓNICA — DISEÑO FUNCIONAL A PARTIR DE REPOSITORIO (Reinicia)
Rellena TODO el front-matter y las 6 secciones. Los comentarios <!-- ... --> son guía: bórralos en el documento final.
El front-matter es OBLIGATORIO: es lo que la Fase B (generación .docx en claude.ai) usa para el nombre de fichero, la cabecera y la trazabilidad. Sin él, el .docx no se puede generar bien desde el markdown solo.
El markdown debe ser AUTOSUFICIENTE: alguien que solo tenga este .md (sin el repo delante) debe poder generar el .docx de marca.
Idioma: redacta TODO (títulos incluidos) en el idioma del campo `idioma` (por defecto español; inglés si es 'en'). Las CLAVES del front-matter no se traducen: son metadatos.
-->
---
cliente:            # p.ej. Gonher, INEFSO, Lider System
proyecto:           # nombre del producto/repositorio
idioma:             # es (por defecto) / en — confirmado con el PO; gobierna markdown Y .docx
descripcion_corta:  # 2-4 palabras para el nombre de fichero, sin tildes ni espacios raros (p.ej. Conector-WooCommerce-CRM)
fecha:              # YYYY-MM-DD (fecha de redacción)
autor:              # quién lo redacta (persona de Reinicia)
stack:              # lista: deluge-zoho / wordpress-php / react-widget-js (los que apliquen)
repo:               # URL o nombre del repositorio de GitHub
commit:             # hash corto del commit analizado (para trazabilidad)
fuentes_analizadas: # rutas reales del repo que sustentan el DF (código y SPECS)
  - 
  - 
gaps_pendientes:    # preguntas abiertas que el PO debe resolver (vacío si no hay)
  - 
---

# Diseño Funcional — {proyecto} · {cliente}

<!-- Subtítulo de una línea con el propósito del documento. -->

---

## 1. Objetivo

<!--
Qué resuelve este desarrollo, en términos de negocio, en 2-4 frases. Sin jerga técnica.
Responde: ¿para qué existe este código? ¿qué capacidad da al cliente?
-->

## 2. Contexto y problemática

<!--
Situación de partida: qué había antes, qué duele, por qué se aborda ahora.
Ancla el contexto en lo observado en el repo y las SPECS (no inventes historia de negocio que el código no respalde; si falta, márcalo como gap).
-->

## 3. Análisis y propuesta

<!--
La lectura funcional del sistema tal como está implementado + la propuesta.
Describe QUÉ hace el sistema y CÓMO fluye, en lenguaje funcional:
- Flujo(s) principal(es) paso a paso (disparador -> procesamiento -> resultado).
- Reglas de negocio detectadas en el código (condiciones, validaciones, ramas).
- Integraciones externas (APIs, webhooks, CRM, WhatsApp, WooCommerce...).
- Casuística y excepciones que el código contempla.
Cada afirmación relevante debería poder rastrearse a un fichero/función real (cítalo entre paréntesis: `ruta/fichero.ext` o nombre de función).
-->

## 4. Diseño técnico-funcional

### 4.1 Mapa de componentes

<!--
Inventario de las piezas y cómo encajan: funciones Deluge / hooks WP / componentes React / endpoints / trabajos programados / conectores.
Para cada componente: nombre, responsabilidad, entradas, salidas, con quién habla.
Una tabla suele ir bien: Componente | Tipo | Responsabilidad | Depende de | Fuente en repo.
-->

### 4.2 Modelo de datos

<!--
Entidades y campos que el desarrollo lee o escribe: módulos y campos API de Zoho CRM,
custom post types / tablas WP, formas de datos que viajan por la API.
Marca claramente qué es lectura y qué es escritura, y los nombres API reales.
-->

## 5. Criterios de aceptación

<!--
Lista verificable de "el sistema hace X cuando Y". Deben ser comprobables funcionalmente.
Formato recomendado: casilla + condición observable.
- [ ] Cuando {condición}, el sistema {resultado esperado}.
-->

## 6. Riesgos

<!--
Riesgos técnicos y funcionales detectados: deuda técnica, límites de escalabilidad,
dependencias frágiles, puntos sin cobertura, supuestos no validados.
Incluye la deuda técnica real vista en el código (p.ej. valores hardcodeados, techos de escalado).
Tabla útil: Riesgo | Impacto | Probabilidad | Mitigación propuesta.
-->

---

<!-- Cierre: nada de líneas decorativas extra; la Fase B añade cabecera y marca. -->
