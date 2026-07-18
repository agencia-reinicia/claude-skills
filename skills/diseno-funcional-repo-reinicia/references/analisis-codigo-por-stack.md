# Análisis de código y SPECS por stack

Guía de qué leer y qué extraer en la Fase A, según el stack del repo. El objetivo no es documentar el código línea a línea, sino **reconstruir el comportamiento funcional**: qué hace el sistema, cuándo, con qué reglas y contra qué integraciones. Cada hallazgo funcional debe quedar rastreable a un fichero o función real.

Índice:
1. Localizar las SPECS (transversal)
2. Inventario inicial del repo (transversal)
3. Deluge / Zoho
4. WordPress / PHP
5. React / widgets JS (Zoho widgets y afines)
6. Integraciones y contratos entre piezas
7. Señales de deuda técnica y riesgo

---

## 1. Localizar las SPECS (transversal)

Las "SPECS" rara vez están en un único sitio. Peina, por orden de valor:

- `README.md`, `README.*` en la raíz y en subcarpetas.
- Carpetas `docs/`, `doc/`, `spec/`, `specs/`, `design/`, `rfc/`, `adr/`.
- Ficheros `*.md` sueltos, `SPEC*`, `RFC*`, `DESIGN*`, `FUNCTIONAL*`, `DISENO*`, `DISEÑO*`.
- Contratos de API: `openapi.*`, `swagger.*`, `*.postman_collection.json`.
- Comportamiento esperado en tests: `*.feature` (Gherkin), carpetas `tests/`, `__tests__/`, `cypress/`.
- Comentarios de cabecera en los ficheros de código (a menudo describen el propósito de la función mejor que el README).
- Issues/PR referenciados en comentarios (`#123`), CHANGELOG.

Regla: las SPECS dicen la **intención**; el código dice la **realidad**. Cuando difieran, documenta ambas y márcalo como gap para el PO (no asumas cuál gana).

```bash
# Barrido rápido de documentación y specs
find . -type f \( -iname 'readme*' -o -iname '*.md' -o -iname 'spec*' -o -iname 'openapi*' -o -iname 'swagger*' -o -iname '*.feature' \) \
  -not -path '*/node_modules/*' -not -path '*/vendor/*' | sort
```

---

## 2. Inventario inicial del repo (transversal)

Antes de leer a fondo, hazte un mapa:

```bash
# Estructura (sin ruido)
find . -type d -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' | head -60
# Perfil de lenguajes por extensión
find . -type f -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' \
  | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -25
# Punto de entrada / manifiestos
ls -a; cat package.json composer.json plugin-manifest.json 2>/dev/null
```

Identifica: puntos de entrada, manifiestos, ficheros de configuración, y el/los stack(s) reales (pueden convivir varios: un widget React que llama a funciones Deluge, un plugin WP que sincroniza con CRM).

---

## 3. Deluge / Zoho

Ficheros típicos: `.dg`, `.deluge`, o funciones exportadas como texto/`.txt`; a veces dentro de exports de configuración de Zoho.

Qué extraer:
- **Tipo y disparador de cada función:** función personalizada, workflow, botón, schedule, webhook (`standalone`, `on create/edit`, cron). El disparador define *cuándo* actúa.
- **Módulos y campos API tocados:** busca `zoho.crm.getRecordById`, `zoho.crm.createRecord`, `updateRecord`, `searchRecords`, `getRelatedRecords`. Anota módulo y **nombres API reales** de campos (no etiquetas).
- **Llamadas externas:** `invokeurl` (método, URL, cabeceras, cuerpo) → integraciones con plataformas externas (WooCommerce, WhatsApp/Woztell, ERPs).
- **Reglas de negocio:** condicionales (`if/else`), bucles sobre colecciones, validaciones, cálculos, mapeos de picklist.
- **Dominio EU:** IDs con `.toLong()`, endpoints `zohoapis.eu` / `crm.zoho.eu` indican org europea.
- **Manejo de errores:** `try/catch`, ramas de fallo, reintentos.

Reconstruye por función: disparador → lecturas → transformaciones/reglas → escrituras/llamadas → resultado. Esto alimenta directamente §3 (Análisis) y §4.1 (Mapa de componentes).

```bash
grep -rniE "zoho\.(crm|books|...)|invokeurl|standalone|on (create|edit)" --include=*.dg --include=*.deluge --include=*.txt . | head -60
```

---

## 4. WordPress / PHP

Ficheros típicos: `functions.php`, `wp-content/plugins/*`, `wp-content/themes/*`, clases PHP.

Qué extraer:
- **Hooks:** `add_action(...)`, `add_filter(...)` → qué se engancha a qué evento del ciclo de WP. Son los disparadores.
- **Endpoints REST:** `register_rest_route(...)` → rutas, métodos, callbacks, `permission_callback`.
- **Tipos de contenido y campos:** `register_post_type`, `register_taxonomy`, campos ACF (`get_field`/`update_field`), metaboxes.
- **Formularios:** Gravity Forms (`gform_*` hooks), Contact Form 7 → captura de datos y su destino.
- **Tareas programadas:** `wp_schedule_event`, `wp_cron`.
- **Integraciones con CRM/externos:** `wp_remote_post`/`wp_remote_get`, cURL, SDKs → webhooks salientes/entrantes hacia Zoho u otros.
- **Datos:** consultas `$wpdb`, tablas propias, opciones (`get_option`/`update_option`).
- **Multilingüe:** WPML, Polylang (relevante en proyectos con traducción).

```bash
grep -rniE "add_action|add_filter|register_rest_route|register_post_type|wp_schedule_event|wp_remote_(post|get)|get_field" \
  --include=*.php . -l | head -40
```

---

## 5. React / widgets JS (Zoho widgets y afines)

Ficheros típicos: `plugin-manifest.json` (widget Zoho), `package.json`, `src/**/*.jsx|tsx|js`, config de bundler (`webpack`, `vite`).

Qué extraer:
- **Manifiesto del widget:** `plugin-manifest.json` → dónde se monta (related list, botón, web tab, dashboard), permisos, módulos.
- **API de Zoho embebida:** `ZOHO.CRM.API.*`, `ZOHO.CRM.UI.*`, `ZOHO.embeddedApp` → lecturas/escrituras contra CRM desde el front.
- **Puntos de entrada y componentes:** componente raíz, rutas, estado (hooks/`useState`/store), y el árbol de componentes con su responsabilidad.
- **Llamadas externas:** `fetch`/`axios` → APIs de terceros; anota endpoints y forma de los datos.
- **Contrato de datos:** props, tipos (TS/PropTypes), y las formas JSON que entran/salen → alimentan §4.2 (Modelo de datos).
- **Build/despliegue:** cómo se empaqueta el widget (afecta a riesgos de despliegue).

```bash
cat plugin-manifest.json 2>/dev/null
grep -rniE "ZOHO\.(CRM|embeddedApp)|fetch\(|axios|useState|useEffect" --include=*.js --include=*.jsx --include=*.ts --include=*.tsx src 2>/dev/null | head -50
```

---

## 6. Integraciones y contratos entre piezas

Muchos proyectos Reinicia son varios stacks hablando entre sí (widget React → Deluge → API externa; WooCommerce → webhook → Zoho Flow/Deluge → Moodle). Documenta explícitamente:

- **Quién dispara a quién** (dirección del flujo).
- **El contrato:** forma de los datos que cruzan la frontera (campos, formatos, unidades). Presta atención a transformaciones típicas: costes de Google Ads en micros (÷1.000.000), IDs que necesitan `.toLong()`, deduplicación por campo de plataforma.
- **Puntos únicos de fallo** en la cadena.

Esto es el corazón de §3 y §4.1: sin el mapa de integraciones el DF queda incompleto.

---

## 7. Señales de deuda técnica y riesgo (para §6)

Marca lo que veas, sin dramatizar, con su fuente:

- Valores **hardcodeados** que deberían ser configuración (IDs, URLs, umbrales, credenciales).
- **Techos de escalabilidad:** enfoques de N-URLs/N-ramas que no escalan al añadir mercados/idiomas, límites de filas, paginación ausente.
- **Sandbox vs producción:** IDs distintos por entorno; código que asume un entorno.
- Ausencia de manejo de errores en llamadas externas; sin reintentos ni idempotencia.
- Duplicación de lógica entre piezas; lógica de negocio en el front que debería estar en backend.
- Merge fields / plantillas rotas, dependencias externas frágiles.
- Cobertura de tests inexistente en flujos críticos.

Cada riesgo con impacto y una mitigación propuesta; no inventes riesgos que el código no respalde.
