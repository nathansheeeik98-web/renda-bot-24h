#!/data/data/com.termux/files/usr/bin/bash
set -e

cd renda-bot-24h

pkg install -y git >/dev/null || true

git init
git add .
git commit -m "renda-bot 24h" || true

echo ""
echo "✅ Repo local criado."
echo "Agora no GitHub crie um repositório vazio e rode:"
echo "git remote add origin URL_DO_SEU_REPO"
echo "git branch -M main"
echo "git push -u origin main"
