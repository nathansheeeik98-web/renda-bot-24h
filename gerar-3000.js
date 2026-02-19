const fs = require("fs");
const path = require("path");

const total = 3000;
const dist = path.join(__dirname, "dist");
const pasta = path.join(dist, "gerado");

if (!fs.existsSync(pasta)) {
  fs.mkdirSync(pasta, { recursive: true });
}

function gerarTitulo(i) {
  return `Ideia de Renda Extra ${i}`;
}

function gerarConteudo(i) {
  return `
  <h1>${gerarTitulo(i)}</h1>
  <p>Descubra uma forma prática de gerar renda online em 2026.</p>
  <p>Estratégia número ${i} focada em serviço digital, afiliados ou SEO automático.</p>
  <a href="/">Voltar</a>
  `;
}

for (let i = 1; i <= total; i++) {
  const slug = `renda-${i}.html`;
  const html = `
  <!DOCTYPE html>
  <html lang="pt-br">
  <head>
    <meta charset="UTF-8">
    <title>${gerarTitulo(i)}</title>
    <meta name="description" content="Método ${i} para ganhar dinheiro online.">
  </head>
  <body>
    ${gerarConteudo(i)}
  </body>
  </html>
  `;

  fs.writeFileSync(path.join(pasta, slug), html);
}

console.log("✅ 3000 páginas criadas com sucesso!");
