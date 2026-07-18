import { defineConfig } from "vite";

// base: "./" -> el build (dist/) funciona abierto desde cualquier ruta o subcarpeta.
export default defineConfig({
  base: "./",
  server: { port: 5180, open: true },
});
