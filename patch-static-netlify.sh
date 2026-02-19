#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "==> Patch: modo estático para Netlify (sem /api)..."

# Substitui as funções JS do index.html por versão offline
node - <<'NODE'
const fs = require("fs");
let html = fs.readFileSync("public/index.html","utf-8");

// 1) Remove/neutraliza post("/api/...") e usa lógica local
// Vamos injetar um bloco JS novo (simples) antes de </script>
const marker = "</script>";
if (!html.includes("/* STATIC_MODE */")) {
  html = html.replace(marker, `
/* STATIC_MODE */
function clamp(n,a,b){ return Math.max(a, Math.min(b,n)); }
function money(n){ return Math.round((Number(n||0))*100)/100; }
function fmtMoney(n){ return "R$ " + (Number(n||0)).toFixed(2).replace(".", ","); }

function simulateLocal(data){
  const capital = clamp(Number(data.capital ?? 10), 0, 100000);
  const horasDia = clamp(Number(data.horasDia ?? 2), 0, 16);
  const diasMes = clamp(Number(data.diasMes ?? 26), 1, 31);
  const perfil = (data.perfil || "normal").toLowerCase();
  const caminho = (data.caminho || "servico").toLowerCase();

  const riskMult = perfil === "conservador" ? 0.75 : perfil === "agressivo" ? 1.25 : 1.0;

  const baseByPath = {
    servico: { min: 8, max: 25 },
    afiliado: { min: 2, max: 15 },
    conteudo: { min: 1, max: 12 },
    revenda: { min: 4, max: 20 },
  };
  const p = baseByPath[caminho] || baseByPath.servico;
  const capitalBoost = clamp(1 + (Math.log10(capital + 1) / 10), 1, 1.35);

  const mensalLow = (p.min * riskMult) * horasDia * diasMes * capitalBoost;
  const mensalHigh = (p.max * riskMult) * horasDia * diasMes * capitalBoost;

  return {
    ok: true,
    estimate: { low: money(mensalLow), high: money(mensalHigh) },
    tips: [
      "Começo: foque em 1 canal (site/SEO ou um serviço único).",
      "Reinvista 20% do que entrar em conteúdo e páginas.",
      "Repita diariamente: publicar + interlinkar + melhorar títulos."
    ]
  };
}

function ideasLocal(){
  return {
    ok:true,
    hint:"Publique mais páginas long tail (perguntas específicas) e interligue por categorias.",
    ideas:[
      { title:"Renda extra em casa (SEO)", why:"Alta busca no Google.", steps:["Gerar 50 páginas","Criar FAQs","Linkar entre si"], monetization:["Monetag","Afiliados"]},
      { title:"Renda extra com celular", why:"Muitas dúvidas específicas.", steps:["Gerar 50 páginas","Melhorar titles","Publicar todo dia"], monetization:["Monetag","Afiliados"]},
      { title:"Ideias de negócio baratas", why:"Long tail converte bem.", steps:["Gerar 50 páginas","Criar categorias","Atualizar sitemap"], monetization:["Monetag","E-book simples"]}
    ]
  };
}

// Override das funções do site (sem /api)
async function runSim(){
  const data = {
    capital: Number(document.getElementById("capital").value),
    horasDia: Number(document.getElementById("horasDia").value),
    diasMes: Number(document.getElementById("diasMes").value),
    perfil: document.getElementById("perfil").value,
    caminho: document.getElementById("caminho").value,
  };
  const out = simulateLocal(data);
  const el = document.getElementById("out");
  el.innerHTML = \`
    <div><b>Estimativa mensal</b> (offline)</div>
    <div style="margin-top:6px"><b>\${fmtMoney(out.estimate.low)}</b> até <b>\${fmtMoney(out.estimate.high)}</b></div>
    <div class="muted small" style="margin-top:6px">Estimativa educativa (não garantia).</div>
    <div style="margin-top:10px"><b>Dicas</b></div>
    <ul>\${out.tips.map(t=>\`<li>\${t}</li>\`).join("")}</ul>
  \`;
}

async function runIdeas(){
  const out = ideasLocal();
  const el = document.getElementById("out");
  el.innerHTML = \`
    <div><b>Ideias sugeridas</b> (offline)</div>
    <div class="muted small" style="margin-top:4px">\${out.hint}</div>
    <div style="margin-top:10px">
      \${out.ideas.map(i => \`
        <div class="card" style="background:#0b1220;border-color:#22324a">
          <div><b>\${i.title}</b></div>
          <div class="muted small" style="margin-top:4px">\${i.why}</div>
          <div style="margin-top:8px" class="small"><b>Passos</b><ul>\${i.steps.map(s=>\`<li>\${s}</li>\`).join("")}</ul></div>
          <div style="margin-top:8px" class="small"><b>Monetização</b><ul>\${i.monetization.map(m=>\`<li>\${m}</li>\`).join("")}</ul></div>
        </div>
      \`).join("")}
    </div>
  \`;
}

// Pages list (Netlify): lê generated_index.json
async function loadPages(){
  try{
    const r = await fetch("/generated_index.json");
    const db = await r.json();
    const el = document.getElementById("pages");
    if(!db.pages || !db.pages.length){
      el.innerHTML = "<div class='muted small'>Ainda sem páginas exportadas.</div>";
      return;
    }
    el.innerHTML = db.pages.slice(0,30).map(p => \`
      <div style="padding:10px;border-bottom:1px solid #1f2c41">
        <div class="small"><a href="/generated/\${p.file}" target="_blank">\${p.title}</a></div>
        <div class="muted small">\${p.key || p.dayKey || ""}</div>
      </div>
    \`).join("");
  }catch(e){
    document.getElementById("pages").innerHTML = "<div class='muted small'>Sem índice ainda.</div>";
  }
}

// Stats: desliga (não existe backend)
async function loadStats(){
  const el = document.getElementById("stats");
  if (el) el.innerHTML = "Modo estático (sem backend).";
}

(async function init(){
  await loadStats();
  await loadPages();
})();
` + marker);
}
fs.writeFileSync("public/index.html", html);
console.log("OK: public/index.html em modo estático");
NODE

echo "==> Exportando dist..."
npm run export

echo ""
echo "✅ Patch aplicado. Agora faça upload da pasta dist no Netlify de novo."
