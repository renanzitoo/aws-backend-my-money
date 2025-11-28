#!/bin/bash
set -e  # Exit on any error

echo "=== ApplicationStart: Iniciando aplicação ==="
echo "Data/Hora: $(date)"
echo "Usuário: $(whoami)"
echo "PID: $$"

# Diretório da aplicação (definido pelo appspec.yml)
APP_DIR="${APP_DIR:-/opt/apps/backend/current}"
SECRET_NAME="${SECRET_NAME:-money2-backend-dev-secret-rds}"
AWS_REGION="${AWS_REGION:-us-east-1}"

echo "✓ APP_DIR: $APP_DIR"
echo "✓ SECRET_NAME: $SECRET_NAME"
echo "✓ AWS_REGION: $AWS_REGION"

# Verificar se o diretório da aplicação existe
if [ ! -d "$APP_DIR" ]; then
  echo "✗ Diretório da aplicação não encontrado: $APP_DIR"
  exit 1
fi
echo "✓ Diretório da aplicação existe"

# Verificar PM2 disponível (script roda como appuser)
if ! command -v pm2 >/dev/null 2>&1; then
  echo "✗ PM2 não encontrado"
  exit 1
fi
pm2 --version
echo "✓ PM2 disponível"

# Verificar se ecosystem.config.js existe
if [ ! -f "$APP_DIR/ecosystem.config.js" ]; then
  echo "✗ Arquivo ecosystem.config.js não encontrado em $APP_DIR"
  ls -la "$APP_DIR/" | head -20
  exit 1
fi
echo "✓ Arquivo ecosystem.config.js encontrado"

# Criar diretório de logs se não existir
mkdir -p "$APP_DIR/logs"
chmod 755 "$APP_DIR/logs"
echo "✓ Diretório de logs criado"

# Buscar JWT_SECRET do AWS Secrets Manager
echo "Buscando JWT_SECRET do Secrets Manager..."
JWT_SECRET=""

if command -v aws >/dev/null 2>&1; then
  echo "  AWS CLI disponível, tentando buscar secret..."
  if command -v jq >/dev/null 2>&1; then
    JWT_SECRET=$(aws secretsmanager get-secret-value \
      --secret-id "$SECRET_NAME" \
      --region "$AWS_REGION" \
      --query 'SecretString' \
      --output text 2>/dev/null | jq -r '.jwt_secret // .JWT_SECRET // empty' || echo "")
  else
    echo "  ⚠️  jq não disponível, tentando parse manual..."
    JWT_SECRET=$(aws secretsmanager get-secret-value \
      --secret-id "$SECRET_NAME" \
      --region "$AWS_REGION" \
      --query 'SecretString' \
      --output text 2>/dev/null | grep -o '"jwt_secret":"[^"]*' | cut -d'"' -f4 || echo "")
  fi
else
  echo "  ⚠️  AWS CLI não disponível"
fi

# Se JWT_SECRET não foi obtido do Secrets Manager, tentar variável de ambiente
if [ -z "$JWT_SECRET" ]; then
  echo "  ⚠️  JWT_SECRET não encontrado no Secrets Manager"
  if [ -z "${JWT_SECRET:-}" ]; then
    echo "  Tentando variável de ambiente JWT_SECRET..."
    JWT_SECRET="${JWT_SECRET:-}"
  fi
fi

# Validar JWT_SECRET
if [ -z "$JWT_SECRET" ]; then
  echo "✗ JWT_SECRET não disponível (nem no Secrets Manager nem como variável de ambiente)"
  echo "  Configure o secret no AWS Secrets Manager ou defina como variável de ambiente"
  exit 1
fi

export JWT_SECRET
echo "✓ JWT_SECRET carregado (primeiros 20 caracteres: ${JWT_SECRET:0:20}...)"

# Deletar processos PM2 antigos para garantir aplicação das novas configurações
echo "Removendo processos PM2 antigos..."
pm2 delete meu-backend 2>/dev/null || true
pm2 kill 2>/dev/null || true
sleep 1
echo "✓ Processos PM2 antigos removidos"

# Iniciar aplicação com PM2 usando ecosystem.config.js
echo "Iniciando aplicação com PM2..."
cd "$APP_DIR"

# Verificar dependências
if [ ! -d "node_modules" ]; then
  echo "✗ node_modules não encontrado, rodando npm ci..."
  npm ci --omit=dev || npm install --omit=dev || exit 1
fi
echo "✓ Dependências verificadas"

# PM2 herdará as variáveis de ambiente do shell (incluindo JWT_SECRET)
if pm2 start ecosystem.config.js --update-env; then
  echo "✓ Aplicação iniciada com PM2"
else
  echo "✗ Falha ao iniciar aplicação com PM2"
  pm2 logs meu-backend --lines 30 --nostream 2>/dev/null || true
  exit 1
fi

# Esperar um pouco para a aplicação iniciar
sleep 2

# Salvar configuração do PM2
pm2 save
echo "✓ Configuração PM2 salva"

# Verificar status
echo ""
echo "Status do PM2:"
pm2 list
echo ""
echo "Logs recentes (primeiras 30 linhas):"
pm2 logs meu-backend --lines 30 --nostream

echo "=== ApplicationStart: Concluído com sucesso ==="
