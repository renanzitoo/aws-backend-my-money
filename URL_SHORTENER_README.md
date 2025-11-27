# URL Shortener Backend

Backend de um serviço de encurtamento de URLs construído com Express.js, Prisma ORM e PostgreSQL.

## 🎯 Mudanças Realizadas

Este projeto foi adaptado de um backend de finança pessoal para um **serviço de encurtamento de URLs**. Aqui estão as principais mudanças:

### 1. **Database Schema (Prisma)**
   - ❌ Removidos: `Account`, `Category`, `Transaction`, enums de transações
   - ✅ Adicionados:
     - `ShortenedUrl`: Modelo para URLs encurtadas
     - `UrlAnalytic`: Modelo para rastrear cliques e análises
   - Índices de performance para `shortCode`, `userId` e `clickedAt`

### 2. **Controllers**
   - ❌ Removidos: `account.controller.js`, `category.controller.js`, `transaction.controller.js`
   - ✅ Criado: `url.controller.js` com funções para:
     - Criar URLs encurtadas (com código aleatório ou customizado)
     - Listar URLs do usuário com paginação
     - Obter detalhes de uma URL
     - Atualizar metadados (título, descrição, expiração)
     - Deletar URLs
     - Redirecionar para URL original (público)
     - Obter análises de cliques

### 3. **Routes**
   - ❌ Removidas: rotas para contas, categorias, transações
   - ✅ Criadas: rotas `/api/urls` com endpoints:
     - `POST /api/urls` - Criar URL
     - `GET /api/urls` - Listar URLs
     - `GET /api/urls/urls/:id` - Detalhes
     - `PUT /api/urls/urls/:id` - Atualizar
     - `DELETE /api/urls/urls/:id` - Deletar
     - `GET /api/urls/urls/:id/analytics` - Analytics
     - `GET /:shortCode` - Redirecionar (público)

### 4. **Main Application (index.js)**
   - Atualizadas rotas importadas
   - Mensagem de boas-vindas atualizada

### 5. **Dependencies**
   - ✅ Adicionado: `nanoid@^4.0.2` (para gerar short codes)
   - Mantidos: todos os outros (Express, Prisma, JWT, bcrypt, etc.)

## 🚀 Quick Start

### 1. Instalar dependências
```bash
npm install
```

### 2. Configurar banco de dados
```bash
# Criar migration
npx prisma migrate dev --name init

# Ver dados (opcional)
npx prisma studio
```

### 3. Iniciar servidor
```bash
# Desenvolvimento
npm run dev

# Produção
npm start
```

### 4. Testar API
```bash
# Registrar usuário
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"123456"}'

# Fazer login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"123456"}'

# Criar URL encurtada (substitua TOKEN)
curl -X POST http://localhost:3000/api/urls \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"originalUrl":"https://www.exemplo.com/muito-longa","title":"Exemplo"}'

# Listar URLs
curl -X GET http://localhost:3000/api/urls \
  -H "Authorization: Bearer TOKEN"
```

## 📚 Documentação Completa

Veja [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) para:
- Endpoints detalhados
- Exemplos de requisições e respostas
- Tratamento de erros
- Variáveis de ambiente
- Arquitetura da aplicação

## 🔄 Fluxo Típico

```
1. Usuário registra/faz login
2. Recebe JWT token
3. Cria URL encurtada
4. Compartilha short link
5. Outros usuários clicam no link
6. Sistema redireciona para URL original
7. Análise registra o clique
8. Proprietário vê estatísticas
```

## 🏗️ Estrutura do Projeto

```
src/
├── controllers/
│   ├── auth.controller.js       # Autenticação (register/login)
│   └── url.controller.js        # Gerenciamento de URLs
├── routes/
│   ├── auth.routes.js
│   ├── url.routes.js
│   ├── health.routes.js
│   └── (removidas: account, category, transaction)
├── middlewares/
│   └── auth.middleware.js       # Verificação JWT
├── utils/
│   ├── prisma.js
│   └── aws-secrets.js
└── index.js

prisma/
├── schema.prisma                # ATUALIZADO: novo schema
└── migrations/
    └── (será criado ao executar migrate dev)
```

## 🔐 Segurança

- ✅ Senhas hasheadas com bcrypt
- ✅ Autenticação JWT (1 dia de expiração)
- ✅ Validação de URLs
- ✅ Proteção contra códigos duplicados
- ✅ Usuários só veem suas próprias URLs
- ✅ CORS configurável
- ✅ Suporte a AWS Secrets Manager

## 📊 Features

- ✅ Encurtamento com código aleatório (6 caracteres)
- ✅ Códigos customizados (3-20 caracteres)
- ✅ Expiração de URLs
- ✅ Títulos e descrições
- ✅ Rastreamento de cliques
- ✅ Analytics detalhados (UA, referrer, IP)
- ✅ Paginação
- ✅ Validação de URLs

## 🧪 Testes

```bash
npm test
npm run test:coverage
npm run test:unit
npm run test:integration
```

## 🚢 Deployment

### Docker
```bash
docker build -t url-shortener .
docker compose up
```

### AWS
```bash
npm run setup-env
./scripts/aws-deploy.sh
```

## 📝 Variáveis de Ambiente

Criar arquivo `.env`:
```
DATABASE_URL="postgresql://..."
JWT_SECRET="seu-segredo"
NODE_ENV="development"
BASE_URL="http://localhost:3000"
FRONTEND_URL="http://localhost:3001"
```

## 📄 License

ISC

## 🤝 Next Steps

Algumas melhorias sugeridas:
- [ ] Adicionar autenticação social (Google, GitHub)
- [ ] Implementar QR codes
- [ ] Dashboard com gráficos de analytics
- [ ] Rate limiting
- [ ] Sistema de quotas por usuário
- [ ] Integração com serviços de detecção de país (MaxMind)
- [ ] Webhook para notificações de cliques
- [ ] Sistema de equipes/compartilhamento
