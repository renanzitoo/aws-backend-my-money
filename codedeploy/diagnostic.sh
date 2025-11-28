#!/bin/bash
# Script de diagnóstico para debugar problemas 502

echo "====== DIAGNÓSTICO DE ERRO 502 ======"
echo "Data/Hora: $(date)"
echo ""

echo "1. VERIFICANDO PM2"
echo "=================="
if command -v pm2 >/dev/null 2>&1; then
  pm2 list
  echo ""
  echo "Status detalhado:"
  pm2 describe meu-backend || echo "❌ Processo meu-backend não encontrado"
  echo ""
  echo "Últimos 50 logs:"
  pm2 logs meu-backend --lines 50 --nostream || echo "❌ Sem logs disponíveis"
else
  echo "❌ PM2 não instalado"
fi

echo ""
echo "2. VERIFICANDO PORTA 3001"
echo "========================="
netstat -tlnp | grep 3001 || echo "❌ Nenhum processo escutando na porta 3001"
lsof -i :3001 2>/dev/null || echo "❌ lsof não disponível ou nenhum processo"

echo ""
echo "3. TESTE HTTP LOCAL"
echo "==================="
curl -v http://localhost:3001/ || echo "❌ Falha ao conectar em localhost:3001"

echo ""
echo "4. VERIFICANDO LOGS DO NODE"
echo "==========================="
if [ -f "/opt/apps/backend/current/logs/pm2-out.log" ]; then
  echo "Últimas 50 linhas do pm2-out.log:"
  tail -50 /opt/apps/backend/current/logs/pm2-out.log
else
  echo "❌ Log file não encontrado"
fi

echo ""
echo "5. VERIFICANDO CONFIGURAÇÃO"
echo "==========================="
echo "NODE_ENV: $NODE_ENV"
echo "PORT: $PORT"
echo "SECRET_NAME: $SECRET_NAME"
echo "AWS_REGION: $AWS_REGION"
echo "JWT_SECRET: ${JWT_SECRET:0:20}..." || echo "JWT_SECRET não definido"

echo ""
echo "6. VERIFICANDO PERMISSÕES"
echo "========================="
ls -la /opt/apps/backend/current/ 2>/dev/null | head -20 || echo "❌ Diretório não encontrado"

echo ""
echo "====== FIM DO DIAGNÓSTICO ======"
