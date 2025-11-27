#!/bin/bash
# URL Shortener API - Exemplos de uso com curl
# 
# Este arquivo contém exemplos de como testar todos os endpoints
# Copie e cole os comandos no terminal para testar

# Configuração base
API_URL="http://localhost:3000"
FRONTEND_URL="http://localhost:3001"

echo "=================================================="
echo "URL Shortener Backend - Exemplos de Teste"
echo "=================================================="
echo ""

# ====================================================
# 1. AUTENTICAÇÃO
# ====================================================
echo "1️⃣  AUTENTICAÇÃO"
echo "=================================================="

echo ""
echo "📝 Registrar novo usuário:"
echo ""
curl -X POST "$API_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@example.com",
    "password": "senha123",
    "name": "Seu Nome"
  }'

echo ""
echo ""
echo "🔐 Fazer login:"
echo ""
RESPONSE=$(curl -s -X POST "$API_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@example.com",
    "password": "senha123"
  }')

echo "$RESPONSE"

# Extrair token (se usando jq)
# TOKEN=$(echo "$RESPONSE" | jq -r '.token')
# Ou manualmente, copie o token e atribua:
TOKEN="seu-token-jwt-aqui"

echo ""
echo "⚠️  Copie o token acima e substitua em TOKEN="

echo ""
echo ""

# ====================================================
# 2. CRIAR URLS ENCURTADAS
# ====================================================
echo "2️⃣  CRIAR URLS ENCURTADAS"
echo "=================================================="

echo ""
echo "✨ Criar URL com código aleatório:"
echo ""
curl -X POST "$API_URL/api/urls" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "originalUrl": "https://www.exemplo.com/uma-url-muito-longa-que-queremos-encurtar",
    "title": "Exemplo",
    "description": "Uma descrição útil para sua URL"
  }'

echo ""
echo ""
echo "🎯 Criar URL com código customizado:"
echo ""
curl -X POST "$API_URL/api/urls" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "originalUrl": "https://github.com/renanzitoo/awesome-project",
    "customCode": "github",
    "title": "Meu Projeto GitHub",
    "description": "Link para meu projeto incrível no GitHub"
  }'

echo ""
echo ""
echo "⏰ Criar URL com data de expiração:"
echo ""
curl -X POST "$API_URL/api/urls" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "originalUrl": "https://evento.exemplo.com/ingressos",
    "customCode": "evento2024",
    "title": "Ingressos do Evento",
    "expiresAt": "2024-12-31T23:59:59Z"
  }'

echo ""
echo ""

# ====================================================
# 3. LISTAR URLS
# ====================================================
echo "3️⃣  LISTAR URLS"
echo "=================================================="

echo ""
echo "📋 Listar todas as URLs (com paginação):"
echo ""
curl -X GET "$API_URL/api/urls?page=1&limit=10&sortBy=createdAt&order=desc" \
  -H "Authorization: Bearer $TOKEN"

echo ""
echo ""
echo "🔍 Listar URLs ordenadas por cliques:"
echo ""
curl -X GET "$API_URL/api/urls?page=1&limit=5&sortBy=clicks&order=desc" \
  -H "Authorization: Bearer $TOKEN"

echo ""
echo ""

# ====================================================
# 4. OBTER DETALHES DE UMA URL
# ====================================================
echo "4️⃣  OBTER DETALHES"
echo "=================================================="

echo ""
echo "📌 Obter detalhes de uma URL (ID: 1):"
echo ""
curl -X GET "$API_URL/api/urls/urls/1" \
  -H "Authorization: Bearer $TOKEN"

echo ""
echo ""

# ====================================================
# 5. ATUALIZAR URL
# ====================================================
echo "5️⃣  ATUALIZAR URL"
echo "=================================================="

echo ""
echo "✏️  Atualizar título e descrição:"
echo ""
curl -X PUT "$API_URL/api/urls/urls/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Novo Título",
    "description": "Nova descrição",
    "expiresAt": "2025-01-01T00:00:00Z"
  }'

echo ""
echo ""

# ====================================================
# 6. ANALYTICS
# ====================================================
echo "6️⃣  ANALYTICS"
echo "=================================================="

echo ""
echo "📊 Obter analytics de uma URL (ID: 1):"
echo ""
curl -X GET "$API_URL/api/urls/urls/1/analytics?page=1&limit=20" \
  -H "Authorization: Bearer $TOKEN"

echo ""
echo ""

# ====================================================
# 7. REDIRECIONAR (SEM AUTENTICAÇÃO)
# ====================================================
echo "7️⃣  REDIRECIONAR (Público - sem auth)"
echo "=================================================="

echo ""
echo "🔗 Redirecionar usando short code:"
echo ""
echo "Abra no navegador ou use -L para seguir redirecionamento:"
curl -L "$API_URL/abc123"

echo ""
echo ""
echo "Ou apenas veja o redirecionamento (sem -L):"
echo ""
curl -i "$API_URL/abc123"

echo ""
echo ""

# ====================================================
# 8. DELETAR URL
# ====================================================
echo "8️⃣  DELETAR URL"
echo "=================================================="

echo ""
echo "🗑️  Deletar uma URL (ID: 1):"
echo ""
curl -X DELETE "$API_URL/api/urls/urls/1" \
  -H "Authorization: Bearer $TOKEN"

echo ""
echo ""

# ====================================================
# CASOS DE TESTE ADICIONAIS
# ====================================================
echo "9️⃣  CASOS DE TESTE - VALIDAÇÕES"
echo "=================================================="

echo ""
echo "❌ Tentar criar URL sem originalUrl:"
echo ""
curl -X POST "$API_URL/api/urls" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Sem URL"
  }'

echo ""
echo ""
echo "❌ Tentar criar URL com URL inválida:"
echo ""
curl -X POST "$API_URL/api/urls" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "originalUrl": "nao-e-uma-url-valida"
  }'

echo ""
echo ""
echo "❌ Tentar usar código customizado já existente:"
echo ""
curl -X POST "$API_URL/api/urls" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "originalUrl": "https://example.com",
    "customCode": "github"
  }'

echo ""
echo ""
echo "❌ Tentar acessar URL expirada:"
echo ""
curl -i "$API_URL/expired-code"

echo ""
echo ""

# ====================================================
# UTILITÁRIOS
# ====================================================
echo "🔧 UTILITÁRIOS"
echo "=================================================="

echo ""
echo "✅ Verificar saúde da aplicação:"
echo ""
curl "$API_URL/health"

echo ""
echo ""
echo "💾 Visualizar dados no Prisma Studio:"
echo ""
echo "Execute em outro terminal:"
echo "npx prisma studio"
echo "Ou: npm run dev (ja abre em http://localhost:5555)"

echo ""
echo ""

# ====================================================
# SCRIPT COM JQ (JSON query)
# ====================================================
echo "📦 COM JQ (para parsing JSON)"
echo "=================================================="

echo ""
echo "Se tiver jq instalado, pode fazer:"
echo ""
echo "# Extrair token"
echo "TOKEN=\$(curl -s -X POST $API_URL/api/auth/login \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"email\":\"user@example.com\",\"password\":\"123\"}' \\"
echo "  | jq -r '.token')"
echo ""
echo "# Listar apenas os short codes"
echo "curl -s -X GET \"$API_URL/api/urls\" \\"
echo "  -H \"Authorization: Bearer \$TOKEN\" \\"
echo "  | jq '.urls[].shortCode'"
echo ""
echo "# Contar URLs totais"
echo "curl -s -X GET \"$API_URL/api/urls\" \\"
echo "  -H \"Authorization: Bearer \$TOKEN\" \\"
echo "  | jq '.pagination.total'"

echo ""
echo ""

# ====================================================
# INSTALLAÇÃO DO JQ
# ====================================================
echo "📥 INSTALAR JQ"
echo "=================================================="

echo ""
echo "# Linux (Debian/Ubuntu):"
echo "sudo apt-get install jq"
echo ""
echo "# macOS:"
echo "brew install jq"
echo ""
echo "# Windows (Chocolatey):"
echo "choco install jq"

echo ""
echo "=================================================="
echo "✅ Testes Concluídos!"
echo "=================================================="
