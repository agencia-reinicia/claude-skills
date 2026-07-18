#!/usr/bin/env node
/**
 * generar-webapp.mjs — Convierte un Diseño Funcional en markdown en una
 * webapp Vite con marca Reinicia, lista para `npm install && npm run dev`.
 *
 * Sin dependencias externas (se ejecuta ANTES de `npm install`).
 *
 * Uso:
 *   node scripts/generar-webapp.mjs <ruta-al-md> [--out <carpeta>]
 *
 * Ejemplo:
 *   node scripts/generar-webapp.mjs docs/diseno-funcional-gonher.md --out df-webapp
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PLANTILLA = path.resolve(__dirname, "..", "assets", "webapp-vite");

// ---- Argumentos ----
const args = process.argv.slice(2);
if (args.length === 0 || args.includes("-h") || args.includes("--help")) {
  console.log("Uso: node scripts/generar-webapp.mjs <ruta-al-md> [--out <carpeta>]");
  process.exit(args.length === 0 ? 1 : 0);
}
const mdPath = path.resolve(args[0]);
const outIdx = args.indexOf("--out");
const outDir = path.resolve(outIdx !== -1 && args[outIdx + 1] ? args[outIdx + 1] : "df-webapp");

if (!fs.existsSync(mdPath)) {
  console.error(`✗ No existe el markdown: ${mdPath}`);
  process.exit(1);
}
if (!fs.existsSync(PLANTILLA)) {
  console.error(`✗ No encuentro la plantilla en ${PLANTILLA}`);
  process.exit(1);
}

// ---- Copiar la plantilla (sin node_modules/dist) ----
fs.cpSync(PLANTILLA, outDir, {
  recursive: true,
  filter: (src) => !/[\\/](node_modules|dist|\.vite)([\\/]|$)/.test(src),
});

// ---- Inyectar el Diseño Funcional real ----
const md = fs.readFileSync(mdPath, "utf8");
fs.writeFileSync(path.join(outDir, "src", "diseno-funcional.md"), md, "utf8");

// ---- Título del documento desde el front-matter (lectura mínima) ----
function leerFrontMatter(texto) {
  const t = texto.replace(/^\uFEFF/, "").replace(/^\s*<!--[\s\S]*?-->\s*/, "");
  const m = t.match(/^---\s*\n([\s\S]*?)\n---/);
  if (!m) return {};
  const out = {};
  for (const linea of m[1].split("\n")) {
    const mm = linea.match(/^([A-Za-z_]+):\s*(.*?)\s*(?:#.*)?$/);
    if (mm && mm[2] !== "") out[mm[1]] = mm[2];
  }
  return out;
}
const fm = leerFrontMatter(md);
const titulo = [fm.proyecto, fm.cliente].filter(Boolean).join(" · ") || "Diseño Funcional";

const idxPath = path.join(outDir, "index.html");
let html = fs.readFileSync(idxPath, "utf8");
html = html.replace(/<title>[\s\S]*?<\/title>/, `<title>Diseño Funcional · ${titulo}</title>`);
fs.writeFileSync(idxPath, html, "utf8");

// ---- Resumen ----
const rel = path.relative(process.cwd(), outDir) || ".";
console.log(`\n✅ Webapp de marca Reinicia generada en: ${rel}`);
console.log(`   Documento: ${titulo}${fm.idioma ? `  ·  idioma: ${fm.idioma}` : ""}`);
console.log(`\nSiguientes pasos (desde terminal):`);
console.log(`   cd ${rel}`);
console.log(`   npm install`);
console.log(`   npm run dev       # servidor local con recarga`);
console.log(`   npm run build     # genera dist/ estático para desplegar\n`);
