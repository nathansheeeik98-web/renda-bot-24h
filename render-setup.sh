#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "==> Preparando Render (Node Web Service)..."

# render.yaml (opcional, ajuda)
cat > render.yaml << 'EOF'
services:
  - type: web
    name: renda-bot-24h
    env: node
    plan: free
    buildCommand: npm install
    startCommand: node src/server.js
    envVars:
      - key: NODE_VERSION
        value: 20
      - key: BASE_URL
        value: ""
EOF

# garantir start no package.json
node - <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json","utf-8"));
pkg.scripts = pkg.scripts || {};
pkg.scripts.start = pkg.scripts.start || "node src/server.js";
fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
console.log("OK: package.json start =", pkg.scripts.start);
NODE

echo ""
echo "✅ Render pronto."
echo ""
echo "Agora faça o deploy assim:"
echo "1) Crie um repo no GitHub (no navegador) e suba esse projeto."
echo "2) No Render: New + > Web Service > Connect GitHub repo."
echo "3) Start Command: node src/server.js"
echo "4) Depois de deploy, coloque BASE_URL com o domínio do Render."
