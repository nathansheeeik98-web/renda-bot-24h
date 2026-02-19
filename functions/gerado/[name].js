export async function onRequest({ request, env }) {
  const url = new URL(request.url);
  const name = decodeURIComponent(url.pathname.split("/").pop() || "");

  // Espera: renda-123.html
  const m = name.match(/^renda-(\d+)\.html$/i);
  if (!m) {
    return new Response("Use /gerado/renda-123.html", { status: 400 });
  }
  const n = Number(m[1]);

  // Pega o total atual do contador (stats.json ou generated_index.json) via ASSETS
  let total = 0;
  try {
    const u = new URL(request.url);
    u.pathname = "/stats.json";
    const r = await env.ASSETS.fetch(new Request(u.toString(), request));
    const j = await r.json();
    total = Number(j?.meta?.total || 0);
  } catch {}

  const baseTitle = `Ideia ${n}: Renda extra online (guia rápido 2026)`;
  const desc = `Página ${n} gerada sob demanda. Total atual no contador: ${total}.`;
  const canonical = `${url.origin}/gerado/renda-${n}.html`;

  const prev = n > 1 ? `/gerado/renda-${n-1}.html` : null;
  const next = (total && n < total) ? `/gerado/renda-${n+1}.html` : `/gerado/renda-${n+1}.html`;

  const jsonLd = {
    "@context":"https://schema.org",
    "@type":"Article",
    "headline": baseTitle,
    "description": desc,
    "mainEntityOfPage": canonical,
    "author":{"@type":"Person","name":"RendaBot 24h"},
    "publisher":{"@type":"Organization","name":"RendaBot 24h"},
    "datePublished": new Date().toISOString(),
    "dateModified": new Date().toISOString()
  };

  const html = `<!doctype html>
<html lang="pt-br"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${baseTitle}</title>
<meta name="description" content="${desc}">
<link rel="canonical" href="${canonical}">
<meta property="og:type" content="article">
<meta property="og:title" content="${baseTitle}">
<meta property="og:description" content="${desc}">
<meta property="og:url" content="${canonical}">
<meta name="twitter:card" content="summary">
<meta name="twitter:title" content="${baseTitle}">
<meta name="twitter:description" content="${desc}">
<script type="application/ld+json">${JSON.stringify(jsonLd)}</script>
<style>
body{font-family:system-ui;margin:0;background:#0b1220;color:#e7eefc}
.wrap{max-width:920px;margin:0 auto;padding:18px}
.card{background:#111b33;border:1px solid rgba(255,255,255,.08);border-radius:16px;padding:16px}
a{color:#a9c7ff;text-decoration:none} a:hover{text-decoration:underline}
.pill{display:inline-block;padding:6px 10px;border-radius:999px;background:rgba(255,255,255,.08);margin-right:8px}
ul{line-height:1.7}
</style>
</head>
<body><div class="wrap">
  <div class="card">
    <div class="pill">Renda extra</div><div class="pill">#${n}</div><div class="pill">Dinâmica</div>
    <h1 style="margin:10px 0 0">${baseTitle}</h1>
    <p style="opacity:.85">${desc}</p>

    <h2>Passo a passo</h2>
    <ul>
      <li>Escolha 1 micro-serviço simples e repetível.</li>
      <li>Monte 1 exemplo pronto (antes/depois).</li>
      <li>Faça 30 abordagens/dia (grupos + DM).</li>
      <li>Padronize entrega e cobre por pacote.</li>
    </ul>

    <p style="margin-top:14px">
      <a href="/">Home</a>
      ${prev ? ` • <a rel="prev" href="${prev}">Anterior</a>` : ``}
      • <a rel="next" href="${next}">Próxima</a>
      • <a href="/dashboard.html">Dashboard</a>
    </p>

    <p style="opacity:.7;margin-top:12px">Total no contador: <b>${total}</b></p>
  </div>
</div></body></html>`;

  return new Response(html, { headers: { "content-type":"text/html; charset=utf-8" }});
}
