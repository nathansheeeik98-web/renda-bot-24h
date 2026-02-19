const fs = require("fs");

const total = 3000;
let sitemap = `<?xml version="1.0" encoding="UTF-8"?>\n`;
sitemap += `<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n`;

for (let i = 1; i <= total; i++) {
  sitemap += `
  <url>
    <loc>https://renda-bot-24h.pages.dev/gerado/renda-${i}.html</loc>
  </url>
  `;
}

sitemap += `</urlset>`;

fs.writeFileSync("dist/sitemap.xml", sitemap);

console.log("✅ Sitemap atualizado!");
