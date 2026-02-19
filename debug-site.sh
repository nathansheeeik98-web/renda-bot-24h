#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT="$(pwd)"
DIST="$ROOT/dist"
REPORT="$ROOT/debug-report.txt"

echo "==> Gerando relatório em: $REPORT"
: > "$REPORT"

log(){ echo -e "$*" | tee -a "$REPORT"; }
section(){ log "\n====================\n$*\n===================="; }

section "INFO"
log "Data: $(date)"
log "PWD:  $ROOT"
log "Node: $(node -v 2>/dev/null || echo 'N/A')"
log "NPM:  $(npm -v 2>/dev/null || echo 'N/A')"

section "DIST CHECK"
if [ ! -d "$DIST" ]; then
  log "❌ dist/ não existe."
  exit 1
fi

log "Arquivos na raiz do dist:"
ls -la "$DIST" | tee -a "$REPORT"

if [ ! -f "$DIST/index.html" ]; then
  log "❌ dist/index.html NÃO existe. Netlify vai dar 404."
  exit 1
fi

log "✅ dist/index.html existe (size: $(wc -c < "$DIST/index.html") bytes)"

section "GENERATED CHECK"
if [ -d "$DIST/generated" ]; then
  CNT=$(ls "$DIST/generated" 2>/dev/null | wc -l | tr -d ' ')
  log "✅ dist/generated existe. Total arquivos: $CNT"
  log "Amostra:"
  ls -la "$DIST/generated" | head -n 15 | tee -a "$REPORT"
else
  log "⚠️ dist/generated NÃO existe. /generated/* vai dar 404 no Netlify."
fi

section "INDEX JSON / SITEMAP / ROBOTS"
for f in generated_index.json sitemap.xml robots.txt; do
  if [ -f "$DIST/$f" ]; then
    log "✅ $f existe (size: $(wc -c < "$DIST/$f") bytes)"
  else
    log "⚠️ $f NÃO existe"
  fi
done

section "HTML: SCRIPTS E LINKS IMPORTANTES"
log "Linhas com <script> / monetag:"
grep -nE '<script|monetag\.js' "$DIST/index.html" | head -n 80 | tee -a "$REPORT" || true

log "\nProcurando referências a assets externos (src/href):"
grep -oE '(src|href)="[^"]+"' "$DIST/index.html" \
  | sed 's/.*="\(.*\)"/\1/' \
  | head -n 120 | tee -a "$REPORT" || true

section "MONETAG CHECK"
if grep -q "monetag\.js" "$DIST/index.html"; then
  log "ℹ️ index.html carrega /monetag.js"
  if [ -f "$DIST/monetag.js" ]; then
    log "✅ dist/monetag.js existe (size: $(wc -c < "$DIST/monetag.js") bytes)"
    log "Primeiras linhas:"
    head -n 15 "$DIST/monetag.js" | tee -a "$REPORT"

    # Teste de sintaxe (pega muitos erros que quebram o JS do browser)
    section "MONETAG SYNTAX (node --check)"
    if node --check "$DIST/monetag.js" >>"$REPORT" 2>&1; then
      log "✅ node --check: sem erro de sintaxe aparente"
    else
      log "❌ node --check encontrou erro de sintaxe em monetag.js (isso pode travar o site)"
      log "➡️ SOLUÇÃO: remover temporariamente a linha <script src=\"/monetag.js\"> e redeploy para testar."
    fi
  else
    log "❌ dist/monetag.js NÃO existe, mas index.html tenta carregar. Isso pode gerar erro no console."
  fi
else
  log "ℹ️ index.html NÃO carrega monetag.js (ok)."
fi

section "FUNÇÕES NO JS INLINE (Simular/Ideias)"
if grep -q "function runSim" "$DIST/index.html"; then
  log "✅ Encontrou function runSim() no index.html"
else
  log "❌ NÃO encontrou runSim(). Botão Simular pode não funcionar."
fi
if grep -q "function runIdeas" "$DIST/index.html"; then
  log "✅ Encontrou function runIdeas() no index.html"
else
  log "❌ NÃO encontrou runIdeas(). Botão Ideias pode não funcionar."
fi

section "PWA / SERVICE WORKER (CACHE)"
# Se tiver SW/manifest, pode estar cacheando versão quebrada
SW_FOUND=$(find "$DIST" -maxdepth 2 -type f \( -name "sw.js" -o -name "service-worker.js" -o -name "*worker*.js" -o -name "manifest.json" \) 2>/dev/null | wc -l | tr -d ' ')
if [ "$SW_FOUND" != "0" ]; then
  log "⚠️ Encontrou arquivos de PWA/service worker/manifest em dist (pode cachear versão antiga):"
  find "$DIST" -maxdepth 2 -type f \( -name "sw.js" -o -name "service-worker.js" -o -name "*worker*.js" -o -name "manifest.json" \) | tee -a "$REPORT"
  log "➡️ SOLUÇÃO: no Chrome Android: Configurações do site -> Armazenamento -> Limpar dados, ou abrir com ?v=99"
else
  log "✅ Não achei sw/manifest óbvios (menos chance de cache PWA)."
fi

section "TESTE LOCAL (SERVIR E BAIXAR COM CURL)"
pkg install -y curl >/dev/null 2>&1 || true

# tenta instalar serve silenciosamente se não existir
npx --yes serve "$DIST" -l 4173 >/dev/null 2>&1 &
SERVE_PID=$!
sleep 1

log "Testando GET /"
curl -s -I http://localhost:4173/ | head -n 5 | tee -a "$REPORT" || true
log "Testando GET /generated_index.json"
curl -s -I http://localhost:4173/generated_index.json | head -n 5 | tee -a "$REPORT" || true
log "Testando GET /sitemap.xml"
curl -s -I http://localhost:4173/sitemap.xml | head -n 5 | tee -a "$REPORT" || true

kill $SERVE_PID >/dev/null 2>&1 || true
log "\n✅ Teste local concluído."

section "CONCLUSÃO (DICAS AUTOMÁTICAS)"
log "- Se o site abre mas botões não respondem: 80% das vezes é monetag.js com erro ou cache."
log "- Teste rápido: remover monetag do index e redeploy. Se funcionar, monetag era a causa."
log "- Se /generated/* dá 404: dist/generated não foi enviado no deploy."
log "- Se /generated_index.json não abre no site: deploy incompleto ou zip com raiz errada."

echo ""
echo "✅ Relatório pronto: $REPORT"
echo "Para ver: cat $REPORT"
