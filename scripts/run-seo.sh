#!/data/data/com.termux/files/usr/bin/bash
set -e
cd "$(dirname "$0")/.."

SITE_URL="${SITE_URL:-https://lucky-gingersnap-021478.netlify.app}"

mkdir -p dist generated dist/generated

# Copia generated -> dist/generated (garante que está lá)
cp -r generated/* dist/generated/ 2>/dev/null || true

# Cria generated_index.json
node - <<'NODE'
const fs = require("fs");
const path = require("path");

const genDir = path.join(process.cwd(), "dist", "generated");
if (!fs.existsSync(genDir)) fs.mkdirSync(genDir, { recursive: true });

const files = fs.readdirSync(genDir).filter(f=>f.endsWith(".html")).sort();
const pages = files.map((file, idx)=>({
  dayKey: new Date().toISOString().slice(0,10),
  title: file.replace(/-/g," ").replace(".html","").slice(0,80),
  file,
  createdAt: Date.now() - idx*1000
}));

fs.writeFileSync(path.join(process.cwd(),"dist","generated_index.json"), JSON.stringify({pages}, null, 2));
console.log("generated_index.json pages:", pages.length);
NODE

# Cria robots.txt
cat > dist/robots.txt <<EOF2
User-agent: *
Allow: /
Sitemap: $SITE_URL/sitemap.xml
EOF2

# Cria sitemap.xml
node - <<'NODE'
const fs = require("fs");
const path = require("path");

const SITE_URL = process.env.SITE_URL || "https://lucky-gingersnap-021478.netlify.app";
const idxPath = path.join(process.cwd(),"dist","generated_index.json");
const outPath = path.join(process.cwd(),"dist","sitemap.xml");

let pages=[];
try{
  pages = JSON.parse(fs.readFileSync(idxPath,"utf-8")).pages || [];
}catch(e){ pages=[]; }

function esc(s){ return String(s).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;"); }

const urls = [];
urls.push(`${SITE_URL}/`);
pages.forEach(p=> urls.push(`${SITE_URL}/generated/${p.file}`));

const xml =
`<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls.map(u=>`  <url><loc>${esc(u)}</loc></url>`).join("\n")}
</urlset>
`;
fs.writeFileSync(outPath, xml, "utf-8");
console.log("sitemap.xml urls:", urls.length);
NODE

echo "✅ SEO pronto: dist/sitemap.xml + dist/robots.txt + dist/generated_index.json"
