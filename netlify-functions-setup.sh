#!/data/data/com.termux/files/usr/bin/bash
set -e
cd "$(dirname "$0")"

mkdir -p netlify/functions
mkdir -p dist

# -----------------------------
# 1) Redirects (no Netlify, dentro de dist/)
# -----------------------------
cat > dist/_redirects <<'R'
/api/simulate  /.netlify/functions/simulate  200
/api/ideas     /.netlify/functions/ideas     200
/api/hit       /.netlify/functions/hit       200
/api/stats     /.netlify/functions/stats     200
R

# -----------------------------
# 2) Function simulate (copia do seu logic.js)
# -----------------------------
cat > netlify/functions/simulate.js <<'JS'
function clamp(n, a, b){ return Math.max(a, Math.min(b, n)); }
function money(n){ const v = Number(n || 0); return Math.round(v * 100) / 100; }

function simulateIncome(input){
  const capital = clamp(Number(input.capital ?? 10), 0, 100000);
  const horasDia = clamp(Number(input.horasDia ?? 2), 0, 16);
  const diasMes = clamp(Number(input.diasMes ?? 26), 1, 31);
  const perfil = (input.perfil || "normal").toLowerCase();
  const caminho = (input.caminho || "servico").toLowerCase();

  const riskMult = perfil === "conservador" ? 0.75 : perfil === "agressivo" ? 1.25 : 1.0;

  const baseByPath = {
    servico: { min: 8, max: 25 },
    afiliado: { min: 2, max: 15 },
    conteudo: { min: 1, max: 12 },
    revenda: { min: 4, max: 20 },
  };
  const p = baseByPath[caminho] || baseByPath.servico;

  const capitalBoost = clamp(1 + (Math.log10(capital + 1) / 10), 1, 1.35);

  const hourlyLow = p.min * riskMult;
  const hourlyHigh = p.max * riskMult;

  const mensalLow = hourlyLow * horasDia * diasMes * capitalBoost;
  const mensalHigh = hourlyHigh * horasDia * diasMes * capitalBoost;

  const dicas = [
    "Começo: foque em 1 canal (site/SEO ou um serviço único).",
    "Reinvista 20% do que entrar em tráfego, domínio ou conteúdo.",
    "Crie oferta clara: 'faço X por Y' e repita todo dia.",
  ];

  return {
    ok: true,
    input: { capital, horasDia, diasMes, perfil, caminho },
    estimate: {
      low: money(mensalLow),
      high: money(mensalHigh),
      note: "Estimativas educativas (não garantia). Resultados variam conforme execução e mercado."
    },
    tips: dicas
  };
}

exports.handler = async (event) => {
  try{
    const body = event.body ? JSON.parse(event.body) : {};
    const out = simulateIncome(body);
    return {
      statusCode: 200,
      headers: { "Content-Type":"application/json", "Access-Control-Allow-Origin":"*" },
      body: JSON.stringify(out),
    };
  }catch(e){
    return { statusCode: 500, body: JSON.stringify({ ok:false, error:String(e) }) };
  }
};
JS

# -----------------------------
# 3) Function ideas (copia do seu logic.js)
# -----------------------------
cat > netlify/functions/ideas.js <<'JS'
function clamp(n, a, b){ return Math.max(a, Math.min(b, n)); }

function generateIdeas(input){
  const capital = clamp(Number(input.capital ?? 10), 0, 100000);
  const cidadePequena = !!input.cidadePequena;
  const tempo = (input.tempo || "medio").toLowerCase();
  const habilidade = (input.habilidade || "geral").toLowerCase();

  const ideas = [];
  function push(title, why, steps, monet){ ideas.push({ title, why, steps, monetization: monet }); }

  if (capital <= 50){
    push(
      "Site de calculadoras simples (renda, juros, orçamento)",
      "Alta busca no Google + fácil de publicar + monetiza com anúncios.",
      ["Criar 3 calculadoras", "Publicar no Netlify", "Fazer 10 páginas SEO (perguntas)"],
      ["Ads (AdSense/Monetag)", "Afiliados (ferramentas/curso)"]
    );
    push(
      "Landing page de orçamento (serviço local)",
      "Pequenos negócios precisam de presença rápida e você vende barato no começo.",
      ["Modelo pronto", "Oferecer para 30 negócios", "Fechar 3 clientes"],
      ["Setup + mensalidade de manutenção"]
    );
  }

  if (capital > 50 && capital <= 500){
    push(
      "Robô de conteúdo SEO: gera páginas todo dia",
      "O site cresce sozinho com páginas novas (long tail).",
      ["Gerar 1 página/dia", "Indexar no Search Console", "Melhorar títulos e FAQs"],
      ["Ads", "Afiliados", "E-book simples"]
    );
  }

  if (habilidade === "apps"){
    push(
      "Mini SaaS: gerador de ideias + ranking",
      "Você diferencia com app simples e segura usuários.",
      ["Salvar favoritos", "Plano PRO com mais ideias", "Páginas SEO por nicho"],
      ["Assinatura R$9,90", "Ads", "Afiliados"]
    );
  }

  if (cidadePequena){
    push(
      "Cardápio digital / catálogo online para comércio",
      "Em cidade pequena fecha rápido e dá recorrência.",
      ["Modelo de catálogo", "Hospedar no Netlify", "Cobrar mensalidade"],
      ["R$49–R$149/mês por cliente"]
    );
  }

  const tempoHint =
    tempo === "baixo" ? "Escolha 1 coisa e faça o mínimo publicável hoje."
    : tempo === "alto" ? "Publique 30 páginas em 7 dias e acelere SEO."
    : "Publique 1 página por dia e melhore com o tempo.";

  return { ok:true, input:{ capital, cidadePequena, tempo, habilidade }, ideas: ideas.slice(0, 8), hint: tempoHint };
}

exports.handler = async (event) => {
  try{
    const body = event.body ? JSON.parse(event.body) : {};
    const out = generateIdeas(body);
    return {
      statusCode: 200,
      headers: { "Content-Type":"application/json", "Access-Control-Allow-Origin":"*" },
      body: JSON.stringify(out),
    };
  }catch(e){
    return { statusCode: 500, body: JSON.stringify({ ok:false, error:String(e) }) };
  }
};
JS

# -----------------------------
# 4) hit/stats (simples; no Netlify não é banco real)
#    -> vai resetar às vezes, mas já ajuda a testar.
# -----------------------------
cat > netlify/functions/hit.js <<'JS'
let hits = 0;
exports.handler = async () => {
  hits += 1;
  return {
    statusCode: 200,
    headers: { "Content-Type":"application/json", "Access-Control-Allow-Origin":"*" },
    body: JSON.stringify({ ok:true, hits, ts: Date.now() })
  };
};
JS

cat > netlify/functions/stats.js <<'JS'
let hits = 0;
exports.handler = async () => {
  return {
    statusCode: 200,
    headers: { "Content-Type":"application/json", "Access-Control-Allow-Origin":"*" },
    body: JSON.stringify({ hits, byDay: {} })
  };
};
JS

echo "✅ Functions + redirects criados!"
echo "Agora: faça upload novamente da pasta DIST no Netlify *junto* com a pasta netlify/."
echo ""
echo "⚠️ IMPORTANTE:"
echo "No Netlify Drop, você precisa arrastar uma pasta ZIP contendo:"
echo "  - dist/ (seu site)"
echo "  - netlify/functions/ (as functions)"
