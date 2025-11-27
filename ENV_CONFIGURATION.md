# URL Shortener Backend - Exemplo de Configuração

Este arquivo serve como referência. Copie para `.env` e configure com seus valores.

```bash
# =====================================================
# DATABASE CONFIGURATION
# =====================================================

# URL de conexão com PostgreSQL
# Formato: postgresql://user:password@host:port/database
DATABASE_URL="postgresql://postgres:senha123@localhost:5432/url_shortener_dev"

# =====================================================
# JWT CONFIGURATION
# =====================================================

# Chave secreta para assinar tokens JWT
# Gere uma chave segura: `openssl rand -base64 32`
JWT_SECRET="sua-chave-super-secreta-mude-isso-em-producao-openssl-rand-base64-32"

# =====================================================
# APPLICATION CONFIGURATION
# =====================================================

# Ambiente da aplicação: development, production, aws
NODE_ENV="development"

# Porta do servidor (padrão: 3000)
PORT=3000

# URL base para URLs encurtadas (necessário para gerar short URLs)
# Será usado para construir URLs como: http://localhost:3000/abc123
BASE_URL="http://localhost:3000"

# =====================================================
# CORS CONFIGURATION
# =====================================================

# URLs permitidas para CORS (separadas por vírgula)
# Exemplo: http://localhost:3001,http://localhost:3002
FRONTEND_URL="http://localhost:3001"

# =====================================================
# AWS CONFIGURATION (opcional)
# =====================================================

# Região AWS (se usar AWS Secrets Manager)
AWS_REGION="us-east-1"

# Nome do secret no AWS Secrets Manager
# Se configurado, o app carregará config daqui em vez do .env
AWS_SECRET_NAME="url-shortener/dev"

# =====================================================
# LOGGING CONFIGURATION (opcional)
# =====================================================

# Nível de log: debug, info, warn, error
LOG_LEVEL="info"

# =====================================================
# RATE LIMITING (para futuro)
# =====================================================

# Requisições máximas por IP por minuto
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW_MS=60000

# =====================================================
# URLS SHORTENER CONFIGURATION
# =====================================================

# Tamanho padrão do short code (nanoid)
SHORT_CODE_LENGTH=6

# Comprimento máximo do custom code
MAX_CUSTOM_CODE_LENGTH=20

# Comprimento mínimo do custom code
MIN_CUSTOM_CODE_LENGTH=3

# =====================================================
# ANALYTICS (opcional)
# =====================================================

# Se deve registrar analytics de cliques
ENABLE_ANALYTICS=true

# Se deve tentar detectar país por IP (requer serviço externo)
ENABLE_GEO_DETECTION=false

# Chave de API para geolocalização (se usar MaxMind, IP2Location, etc)
# GEO_API_KEY="sua-chave-aqui"
```

## Como Usar

### 1. Para Desenvolvimento Local

```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Editar com seus valores locais
nano .env

# Valores mínimos necessários:
DATABASE_URL="postgresql://postgres:password@localhost:5432/url_shortener_dev"
JWT_SECRET="seu-segredo-local"
NODE_ENV="development"
BASE_URL="http://localhost:3000"
FRONTEND_URL="http://localhost:3001"
```

### 2. Para Ambiente de Staging

```bash
# Criar .env.staging
cp .env.example .env.staging

# Configurar com valores de staging
DATABASE_URL="postgresql://user:pass@staging-db.example.com:5432/url_shortener_staging"
JWT_SECRET="use-chave-segura-gerada-com-openssl"
NODE_ENV="production"
BASE_URL="https://short.staging.example.com"
FRONTEND_URL="https://staging.example.com"
```

### 3. Para Produção com AWS

```bash
# Use AWS Secrets Manager em vez de arquivo local
npm run setup-env  # Configura secrets no AWS

# Arquivo .env pode estar vazio ou com apenas:
NODE_ENV="aws"
AWS_REGION="us-east-1"
AWS_SECRET_NAME="url-shortener/prod"
```

## Gerar JWT_SECRET Seguro

```bash
# Linux/Mac
openssl rand -base64 32

# Ou usar Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Ou online (não recomendado para produção)
# https://generate-random.org/api-token-generator
```

## Validação

O servidor inicializará com mensagens de status:

```
✅ Configurations loaded from: local .env
📊 DATABASE_URL: configured
🔐 JWT_SECRET: configured
🚀 Server is running on port 3000
```

## Erros Comuns

### "DATABASE_URL not found"
```bash
# Solução: Adicione DATABASE_URL ao .env
export DATABASE_URL="postgresql://..."
```

### "JWT_SECRET not found"
```bash
# Solução: Gere uma chave segura
openssl rand -base64 32  # Copie e cole no .env
```

### "ECONNREFUSED: PostgreSQL"
```bash
# Verifique se PostgreSQL está rodando
sudo systemctl status postgresql  # Linux
brew services list | grep postgres  # Mac
```

### "CORS blocked"
```bash
# Verifique se FRONTEND_URL está correto
# Exemplo: se app frontend roda em :3001, adicione:
FRONTEND_URL="http://localhost:3001"
```

## Arquivo .env no Git

**IMPORTANTE**: Nunca commit `.env` com valores reais!

```bash
# Adicione ao .gitignore
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore
echo ".env.*.local" >> .gitignore

# Apenas commit .env.example
git add .env.example
```

## Exemplo de .env Completo para Desenvolvimento

```
# Database
DATABASE_URL="postgresql://postgres:12345@localhost:5432/url_shortener_dev"

# JWT
JWT_SECRET="cV7z+8gH9k0L1m2N3o4P5q6R7s8T9u0V1w2X3y4Z5a6B7c8D9e0F"

# App
NODE_ENV="development"
PORT=3000
BASE_URL="http://localhost:3000"
FRONTEND_URL="http://localhost:3001"

# Features
ENABLE_ANALYTICS=true
ENABLE_GEO_DETECTION=false

# Logging
LOG_LEVEL="info"

# Rate Limiting
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW_MS=60000
```

## Teste a Configuração

```bash
# Inicie o servidor
npm run dev

# Em outro terminal, teste a saúde
curl http://localhost:3000/health

# Deve retornar algo como:
# {"status":"ok","timestamp":"2024-01-01T00:00:00Z"}
```

## Variáveis de Ambiente Suportadas

| Nome | Tipo | Obrigatório | Padrão | Descrição |
|------|------|-------------|--------|-----------|
| `DATABASE_URL` | String | Sim | - | URL de conexão PostgreSQL |
| `JWT_SECRET` | String | Sim | - | Chave para assinar JWT |
| `NODE_ENV` | String | Não | `development` | Ambiente da app |
| `PORT` | Number | Não | `3000` | Porta do servidor |
| `BASE_URL` | String | Não | `http://localhost:3000` | URL base para short links |
| `FRONTEND_URL` | String | Não | `http://localhost:3001` | URL frontend para CORS |
| `AWS_REGION` | String | Não | `us-east-1` | Região AWS |
| `AWS_SECRET_NAME` | String | Não | - | Secret name no AWS |
| `ENABLE_ANALYTICS` | Boolean | Não | `true` | Ativar rastreamento |
| `LOG_LEVEL` | String | Não | `info` | Nível de log |

## Referências

- [Node.js Environment Variables](https://nodejs.org/en/learn/file-system/nodejs-file-system#working-with-environment-variables)
- [Prisma Environment Variables](https://www.prisma.io/docs/orm/reference/prisma-schema-reference)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [PostgreSQL Connection Strings](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING)
