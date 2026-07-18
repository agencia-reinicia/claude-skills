// Manrope embebida vía npm (offline). Pesos de marca: 300 / 400 / 700.
import "@fontsource/manrope/300.css";
import "@fontsource/manrope/400.css";
import "@fontsource/manrope/700.css";
import "./style.css";

import { marked } from "marked";
import yaml from "js-yaml";
// El markdown del Diseño Funcional como texto crudo (lo sustituye el generador).
import rawMd from "./diseno-funcional.md?raw";

marked.setOptions({ gfm: true, breaks: false });

// ---- Separar front-matter (YAML) del cuerpo ----
function separarFrontMatter(texto) {
  let t = texto.replace(/^\uFEFF/, "");
  // Saltar un comentario HTML de guía al inicio, si lo hubiera.
  t = t.replace(/^\s*<!--[\s\S]*?-->\s*/, "");
  const m = t.match(/^---\s*\n([\s\S]*?)\n---\s*\n?/);
  if (!m) return { meta: {}, body: t };
  let meta = {};
  try { meta = yaml.load(m[1]) || {}; } catch { meta = {}; }
  return { meta, body: t.slice(m[0].length) };
}

const { meta, body } = separarFrontMatter(rawMd);

// ---- Cabecera: nombre de fichero lógico ----
const nombreFichero = [meta.proyecto, meta.cliente].filter(Boolean).join(" · ") || "Diseño Funcional";
document.title = `Diseño Funcional · ${nombreFichero}`;

// ---- Ficha de metadatos desde el front-matter ----
function fila(dt, dd) {
  if (dd === undefined || dd === null || dd === "" || (Array.isArray(dd) && dd.length === 0)) return "";
  const val = Array.isArray(dd) ? dd.map((x) => `<code>${escapar(String(x))}</code>`).join(" ") : escapar(String(dd));
  return `<dt>${dt}</dt><dd>${val}</dd>`;
}
function escapar(s) { return s.replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c])); }

const fichaHtml = `
  <div class="df-meta">
    <dl>
      ${fila("Cliente", meta.cliente)}
      ${fila("Proyecto", meta.proyecto)}
      ${fila("Fecha", meta.fecha)}
      ${fila("Autor", meta.autor)}
      ${fila("Stack", meta.stack)}
      ${fila("Repositorio", meta.repo)}
      ${fila("Commit", meta.commit)}
      ${fila("Idioma", meta.idioma)}
    </dl>
  </div>`;

// ---- Render del cuerpo + IDs en encabezados para el TOC ----
let idx = 0;
const headings = [];
const renderer = new marked.Renderer();
const baseHeading = renderer.heading.bind(renderer);
renderer.heading = (text, level, raw) => {
  if (level === 2 || level === 3) {
    const id = `sec-${++idx}`;
    headings.push({ id, level, text: raw.replace(/<[^>]+>/g, "") });
    return `<h${level} id="${id}">${text}</h${level}>`;
  }
  return baseHeading(text, level, raw);
};

const contenidoHtml = marked.parse(body, { renderer });

// ---- TOC ----
const tocHtml = headings.length
  ? `<nav class="df-toc"><h2>Contenido</h2>${headings
      .map((h) => `<a class="nivel-${h.level}" href="#${h.id}">${escapar(h.text)}</a>`)
      .join("")}</nav>`
  : "";

// ---- Montaje ----
document.getElementById("app").outerHTML = `
  <header class="df-header">
    <img src="/logo-reinicia.png" alt="Reinicia" />
    <div class="df-file">${escapar(nombreFichero)}</div>
  </header>
  <hr class="df-rule" />
  <div class="df-shell">
    ${tocHtml}
    <main class="df-content">
      ${fichaHtml}
      ${contenidoHtml}
    </main>
  </div>
  <footer class="df-footer">Documento generado por Reinicia · Diseño Funcional</footer>
`;
