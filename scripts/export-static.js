const fs = require("fs");
const path = require("path");

function copyDir(src, dest){
  if (!fs.existsSync(src)) return;
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, entry.name);
    const d = path.join(dest, entry.name);
    if (entry.isDirectory()) copyDir(s, d);
    else fs.copyFileSync(s, d);
  }
}

function rmDir(dir){
  if (!fs.existsSync(dir)) return;
  fs.rmSync(dir, { recursive: true, force: true });
}

rmDir("dist");
fs.mkdirSync("dist", { recursive: true });

// copia conteúdo estático
copyDir("public", "dist");
copyDir("generated", "dist/generated");

// cria uma home estática simples caso precise (mantém sua index do public)
if (!fs.existsSync("dist/index.html") && fs.existsSync("public/index.html")) {
  fs.copyFileSync("public/index.html", "dist/index.html");
}

console.log("✅ Export pronto em /dist");
console.log("Dica: hospede a pasta dist em Netlify/Vercel/GitHub Pages.");
