#!/data/data/com.termux/files/usr/bin/bash
set -e
cd "$(dirname "$0")"

# 1) refaz dist do zero
rm -rf dist
mkdir -p dist

# 2) copia a home (site)
cp -r public/* dist/

# 3) copia páginas geradas
mkdir -p dist/generated
cp -r generated/* dist/generated/ 2>/dev/null || true

# 4) garante índice (usa o que já existe em public, se existir)
if [ -f public/generated_index.json ]; then
  cp public/generated_index.json dist/generated_index.json
fi

# 5) garante robots/sitemap (se existir)
if [ -f public/robots.txt ]; then cp public/robots.txt dist/robots.txt; fi
if [ -f public/sitemap.xml ]; then cp public/sitemap.xml dist/sitemap.xml; fi

# 6) monetag (se existir)
if [ -f public/monetag.js ]; then cp public/monetag.js dist/monetag.js; fi

# 7) cria ZIP correto (raiz do zip = conteúdo do dist)
pkg install -y zip >/dev/null 2>&1 || true
rm -f NETLIFY_OK.zip
cd dist
zip -r ../NETLIFY_OK.zip ./*
cd ..

echo "✅ Pronto: NETLIFY_OK.zip"
echo "Conteúdo (primeiras linhas):"
unzip -l NETLIFY_OK.zip | head -n 25
