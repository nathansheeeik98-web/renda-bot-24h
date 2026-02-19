#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "==> Criando arquivo de monetização (Monetag)..."

# Arquivo pra você colar o script do Monetag
cat > public/monetag.js << 'EOF'
// COLE AQUI o script do Monetag (do seu painel).
// Exemplo (não use esse, pegue o seu):
// (function(){ ... })();
EOF

# Injeta no index.html se ainda não existir
if ! grep -q "monetag.js" public/index.html; then
  # tenta inserir antes de </head>
  sed -i 's#</head>#  <script src="/monetag.js"></script>\n</head>#' public/index.html
fi

echo "✅ Monetag preparado."
echo ""
echo "Agora abra o arquivo e cole o código do Monetag:"
echo "nano public/monetag.js"
echo ""
echo "Depois reinicie:"
echo "pm2 restart renda-bot"
