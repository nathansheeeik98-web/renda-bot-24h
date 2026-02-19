#!/data/data/com.termux/files/usr/bin/bash
set -e
cd "$(dirname "$0")/.."

# usa o seu script existente (se tiver) ou gera 30 páginas simples
if [ -f "./upgrade-agressivo.sh" ]; then
  bash ./upgrade-agressivo.sh
else
  node - <<'NODE'
const fs = require("fs");
const path = require("path");

function slug(s){ return s.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"").replace(/[^a-z0-9]+/g,"-").replace(/(^-|-$)/g,"").slice(0,90); }
function page(title, desc){
  return `<!doctype html><html lang="pt-br"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${title}</title><meta name="description" content="${desc}"><style>body{font-family:system-ui;background:#0b0f14;color:#e9eef5;margin:0} .wrap{max-width:860px;margin:0 auto;padding:22px} .card{background:#121a24;border:1px solid #1e2a3a;border-radius:16px;padding:16px;margin:12px 0} a{color:#8bd3ff;text-decoration:none} .btn{display:inline-block;padding:10px 14px;border-radius:12px;border:1px solid #2a3a52;background:#162233;color:#e9eef5}</style></head><body><div class="wrap"><div class="card"><div style="opacity:.7">RendaBot 24h</div><h1>${title}</h1><p style="opacity:.75">${desc}</p><p><a class="btn" href="/">Abrir simulador</a></p></div><div class="card"><h2>Checklist</h2><ul><li>Escolha 1 oferta simples</li><li>Publique 1 página por dia</li><li>Reinvista em tráfego/conteúdo</li></ul></div></div></body></html>`;
}

const topics = [
 "Como fazer renda extra começando do zero",
 "Como ganhar dinheiro com micro-serviços online",
 "Como criar um site simples que gera renda",
 "Ideias de renda extra para iniciante",
 "Como monetizar um site com anúncios",
 "Como usar SEO para renda extra",
];

const gen = path.join(process.cwd(),"generated");
if(!fs.existsSync(gen)) fs.mkdirSync(gen,{recursive:true});

const d = new Date();
const stamp = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,"0")}-${String(d.getDate()).padStart(2,"0")}`;

for(let i=0;i<30;i++){
  const t = topics[Math.floor(Math.random()*topics.length)];
  const title = `${t} (${stamp}-${String(i+1).padStart(2,"0")})`;
  const file = `${slug(title)}.html`;
  fs.writeFileSync(path.join(gen,file), page(title, "Guia curto + checklist + passo a passo."), "utf-8");
}
console.log("✅ Gerou 30 páginas em generated/");
NODE
fi

mkdir -p dist/generated
cp -r generated/* dist/generated/ 2>/dev/null || true
bash scripts/run-seo.sh

echo "✅ Bulk 30 pronto e copiado para dist/"
echo "Total dist/generated:"
ls dist/generated | wc -l
