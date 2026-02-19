const cron = require("node-cron");
const path = require("path");
const fs = require("fs");
const { readJSON, writeJSON } = require("./storage");

function ensureDir(dir){ if(!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive:true }); }
function slugify(s){
  return String(s || "")
    .toLowerCase()
    .normalize("NFD").replace(/[\u0300-\u036f]/g,"")
    .replace(/[^a-z0-9]+/g,"-")
    .replace(/(^-|-$)/g,"")
    .slice(0, 90);
}

function todayKey(){
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,"0")}-${String(d.getDate()).padStart(2,"0")}`;
}

function buildFAQSchema(question, answer){
  return `
<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@type": "FAQPage",
 "mainEntity": [{
   "@type": "Question",
   "name": "${question}",
   "acceptedAnswer": {
     "@type": "Answer",
     "text": "${answer}"
   }
 }]
}
</script>`;
}

function htmlPage({ title, description, bodyHtml, faqSchema }){
  return `<!doctype html>
<html lang="pt-br">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>${title}</title>
<meta name="description" content="${description}"/>
<meta name="robots" content="index, follow"/>
${faqSchema}
<style>
body{font-family:system-ui;margin:0;background:#0b0f14;color:#e9eef5;}
.wrap{max-width:900px;margin:0 auto;padding:24px;}
.card{background:#121a24;border-radius:14px;padding:18px;margin:12px 0}
a{color:#8bd3ff;text-decoration:none}
</style>
</head>
<body>
<div class="wrap">
<div class="card">
<h1>${title}</h1>
<p>${description}</p>
<a href="/">Abrir simulador</a>
</div>

${bodyHtml}

<div class="card">
<h2>Outras páginas relacionadas</h2>
<a href="/categoria/renda-extra-em-casa">Renda em casa</a><br/>
<a href="/categoria/renda-extra-com-celular">Renda com celular</a><br/>
<a href="/categoria/renda-extra-sem-investimento">Sem investimento</a><br/>
<a href="/categoria/ideias-de-negocio-baratas">Negócios baratos</a>
</div>

</div>
</body>
</html>`;
}

function createCategoryPages(){
  const db = readJSON("data/pages.json", { pages: [] });
  const categories = {};

  db.pages.forEach(p => {
    if(!categories[p.niche]) categories[p.niche] = [];
    categories[p.niche].push(p);
  });

  ensureDir("public/categoria");

  for(const niche in categories){
    const html = `
<!doctype html>
<html>
<head>
<title>${niche.replace(/-/g," ")}</title>
<meta name="description" content="Guia completo sobre ${niche.replace(/-/g," ")}"/>
</head>
<body style="background:#0b0f14;color:#fff;font-family:system-ui;padding:20px">
<h1>${niche.replace(/-/g," ")}</h1>
${categories[niche].map(p=>`<div><a href="/generated/${p.file}">${p.title}</a></div>`).join("")}
</body>
</html>`;
    fs.writeFileSync(`public/categoria/${niche}.html`, html);
  }
}

function runBulkGenerator({ n=30 } = {}){
  const pools = [
    "renda-extra-em-casa",
    "renda-extra-com-celular",
    "renda-extra-sem-investimento",
    "ideias-de-negocio-baratas"
  ];

  const addItems = [];
  const key = todayKey();

  for(let i=0;i<n;i++){
    const niche = pools[Math.floor(Math.random()*pools.length)];
    const question = "Como ganhar dinheiro começando hoje?";
    const answer = "Escolha um caminho simples, execute por 7 dias e reinvista parte do lucro.";
    const title = `${niche.replace(/-/g," ")} - ${key}-${i}`;
    const description = "Guia atualizado e checklist prático.";
    const body = `<div class="card"><h2>${question}</h2><p>${answer}</p></div>`;
    const faqSchema = buildFAQSchema(question, answer);

    ensureDir("generated");
    const file = slugify(title)+".html";
    fs.writeFileSync(`generated/${file}`, htmlPage({title,description,bodyHtml:body,faqSchema}));

    addItems.push({title,file,niche,createdAt:Date.now()});
  }

  const db = readJSON("data/pages.json", { pages: [] });
  db.pages = [...addItems, ...db.pages];
  writeJSON("data/pages.json", db);

  createCategoryPages();
  return {generated:n};
}

module.exports = { runBulkGenerator };
