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

  const mensalLow = (p.min * riskMult) * horasDia * diasMes * capitalBoost;
  const mensalHigh = (p.max * riskMult) * horasDia * diasMes * capitalBoost;

  return {
    ok: true,
    input: { capital, horasDia, diasMes, perfil, caminho },
    estimate: {
      low: money(mensalLow),
      high: money(mensalHigh),
      note: "Estimativas educativas (não garantia). Resultados variam conforme execução e mercado."
    },
    tips: [
      "Começo: foque em 1 canal (site/SEO ou um serviço único).",
      "Reinvista 20% do que entrar em tráfego, domínio ou conteúdo.",
      "Crie oferta clara: 'faço X por Y' e repita todo dia.",
    ]
  };
}

function generateIdeas(input){
  const capital = clamp(Number(input.capital ?? 10), 0, 100000);
  const cidadePequena = !!input.cidadePequena;
  const tempo = (input.tempo || "medio").toLowerCase();
  const habilidade = (input.habilidade || "geral").toLowerCase();

  const ideas = [];
  const push = (title, why, steps, monet) => ideas.push({ title, why, steps, monetization: monet });

  if (capital <= 50){
    push(
      "Site de calculadoras simples (renda, juros, orçamento)",
      "Alta busca no Google + fácil de publicar + monetiza com anúncios.",
      ["Criar 3 calculadoras", "Publicar em Vercel/Netlify/Render", "Fazer 10 páginas SEO (perguntas)"],
      ["AdSense/Monetag", "Afiliados (ferramentas/curso)"]
    );
    push(
      "Landing page para orçamento (serviço local)",
      "Pequenos negócios precisam de presença rápida e você pode vender barato no começo.",
      ["Modelo pronto", "Oferecer para 30 negócios", "Fechar 3 clientes"],
      ["Setup + mensalidade de manutenção"]
    );
  }

  if (capital > 50 && capital <= 500){
    push(
      "Robô de conteúdo SEO: gera páginas todo dia",
      "O site cresce sozinho com páginas novas (long tail).",
      ["Gerar 3 páginas/dia", "Indexar no Search Console", "Melhorar títulos e FAQs"],
      ["AdSense", "Afiliados", "E-book simples"]
    );
  }

  if (habilidade === "apps"){
    push(
      "Mini SaaS: gerador de ideias de negócio + ranking",
      "Você consegue diferenciar com um app simples e prender usuários.",
      ["Salvar favoritos", "Criar páginas por nicho", "Plano PRO com mais ideias"],
      ["Assinatura R$9,90", "Ads", "Afiliados"]
    );
  }

  if (cidadePequena){
    push(
      "Serviço 'catálogo online' para comércio",
      "Em cidade pequena fecha rápido e dá recorrência.",
      ["Modelo de catálogo", "Hospedar", "Cobrar mensalidade"],
      ["R$49–R$149/mês por cliente"]
    );
  }

  const hint =
    tempo === "baixo" ? "Escolha 1 coisa e publique hoje."
    : tempo === "alto" ? "Publique 30 páginas em 7 dias e acelere SEO."
    : "Publique 3 páginas/dia e melhore sempre.";

  return { ok: true, input: { capital, cidadePequena, tempo, habilidade }, ideas: ideas.slice(0, 8), hint };
}

module.exports = { simulateIncome, generateIdeas };
