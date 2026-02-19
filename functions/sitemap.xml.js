export async function onRequest({ request, env }) {
  let total = 0;
  try {
    const u = new URL(request.url);
    u.pathname = "/stats.json";
    const r = await env.ASSETS.fetch(new Request(u.toString(), request));
    const j = await r.json();
    total = Number(j?.meta?.total || 0);
  } catch {}

  const origin = new URL(request.url).origin;
  const max = Math.min(total || 0, 45000);

  let xml = `<?xml version="1.0" encoding="UTF-8"?>\n`;
  xml += `<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n`;
  xml += `  <url><loc>${origin}/</loc></url>\n`;
  xml += `  <url><loc>${origin}/dashboard.html</loc></url>\n`;

  for (let i=1; i<=max; i++) {
    xml += `  <url><loc>${origin}/gerado/renda-${i}.html</loc></url>\n`;
  }
  xml += `</urlset>\n`;

  return new Response(xml, {
    headers: { "content-type":"application/xml; charset=utf-8" }
  });
}
