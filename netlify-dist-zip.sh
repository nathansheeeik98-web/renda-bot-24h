#!/data/data/com.termux/files/usr/bin/bash
set -e

cd renda-bot-24h

echo "==> Garantindo export..."
npm run export >/dev/null 2>&1 || true

# Se não existir dist, tenta criar (caso você ainda não rodou o export)
if [ ! -d "dist" ]; then
  echo "==> dist não existe, criando export agora..."
  npm run export
fi

echo "==> Instalando zip..."
pkg install -y zip >/dev/null

echo "==> Gerando ZIP do dist..."
rm -f dist-netlify.zip
cd dist
zip -r ../dist-netlify.zip . >/dev/null
cd ..

echo ""
echo "✅ PRONTO: dist-netlify.zip criado!"
echo "Arquivo em: $(pwd)/dist-netlify.zip"
echo ""
echo "Agora faça assim (sem número, sem app):"
echo "1) Abra netlify.com no navegador"
echo "2) Sites -> Add new site -> Deploy manually"
echo "3) Faça upload do dist-netlify.zip"
echo ""
echo "Dica: depois copie a URL do site Netlify e use como BASE_URL no Render."
