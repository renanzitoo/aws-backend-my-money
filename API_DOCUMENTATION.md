# URL Shortener Backend API

## Visão Geral

Backend de um serviço de encurtamento de URLs com autenticação, análise de cliques e gerenciamento de URLs personalizadas.

## Funcionalidades

- ✅ Autenticação com JWT
- ✅ Encurtamento de URLs com códigos curtos aleatórios ou customizados
- ✅ Rastreamento de cliques com analytics
- ✅ Expiração de URLs
- ✅ Títulos e descrições personalizadas
- ✅ Paginação e filtros
- ✅ Proteção contra códigos duplicados
- ✅ Validação de URLs

## Endpoints

### Autenticação

#### Registrar usuário
```
POST /api/auth/register
Content-Type: application/json

{
  "email": "usuario@example.com",
  "password": "senha123",
  "name": "Nome do Usuário"
}

Response: 201 Created
{
  "id": 1,
  "email": "usuario@example.com",
  "name": "Nome do Usuário",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

#### Fazer login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "usuario@example.com",
  "password": "senha123"
}

Response: 200 OK
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### URLs Encurtadas

#### Criar URL encurtada
```
POST /api/urls
Authorization: Bearer {token}
Content-Type: application/json

{
  "originalUrl": "https://www.exemplo.com/pagina-muito-comprida",
  "title": "Exemplo",
  "description": "Descrição da URL",
  "customCode": "exemp",  // Opcional: se não fornecido, gera um aleatório
  "expiresAt": "2024-12-31T23:59:59Z"  // Opcional: data de expiração
}

Response: 201 Created
{
  "id": 1,
  "originalUrl": "https://www.exemplo.com/pagina-muito-comprida",
  "shortCode": "exemp",
  "shortUrl": "http://localhost:3000/exemp",
  "title": "Exemplo",
  "description": "Descrição da URL",
  "clicks": 0,
  "expiresAt": "2024-12-31T23:59:59Z",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### Listar todas as URLs do usuário
```
GET /api/urls?page=1&limit=10&sortBy=createdAt&order=desc
Authorization: Bearer {token}

Response: 200 OK
{
  "urls": [
    {
      "id": 1,
      "originalUrl": "https://www.exemplo.com/pagina-muito-comprida",
      "shortCode": "exemp",
      "shortUrl": "http://localhost:3000/exemp",
      "title": "Exemplo",
      "description": "Descrição",
      "clicks": 5,
      "analyticsCount": 5,
      "expiresAt": null,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 1,
    "pages": 1
  }
}
```

#### Obter detalhes de uma URL
```
GET /api/urls/urls/{id}
Authorization: Bearer {token}

Response: 200 OK
{
  "id": 1,
  "originalUrl": "https://www.exemplo.com/pagina-muito-comprida",
  "shortCode": "exemp",
  "shortUrl": "http://localhost:3000/exemp",
  "title": "Exemplo",
  "description": "Descrição",
  "clicks": 5,
  "expiresAt": null,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "recentAnalytics": [
    {
      "id": 1,
      "userAgent": "Mozilla/5.0...",
      "referer": "https://example.com",
      "ipAddress": "192.168.1.1",
      "country": "BR",
      "clickedAt": "2024-01-02T10:30:00Z"
    }
  ]
}
```

#### Atualizar uma URL
```
PUT /api/urls/urls/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Novo Título",
  "description": "Nova Descrição",
  "expiresAt": "2024-12-31T23:59:59Z"
}

Response: 200 OK
{
  "id": 1,
  "originalUrl": "https://www.exemplo.com/pagina-muito-comprida",
  "shortCode": "exemp",
  "shortUrl": "http://localhost:3000/exemp",
  "title": "Novo Título",
  "description": "Nova Descrição",
  "clicks": 5,
  "expiresAt": "2024-12-31T23:59:59Z",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-02T00:00:00Z"
}
```

#### Deletar uma URL
```
DELETE /api/urls/urls/{id}
Authorization: Bearer {token}

Response: 204 No Content
```

#### Obter analytics de uma URL
```
GET /api/urls/urls/{id}/analytics?page=1&limit=20
Authorization: Bearer {token}

Response: 200 OK
{
  "analytics": [
    {
      "id": 1,
      "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)...",
      "referer": "https://example.com",
      "ipAddress": "192.168.1.1",
      "country": null,
      "clickedAt": "2024-01-02T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "pages": 1
  }
}
```

#### Redirecionar para URL original (público)
```
GET /{shortCode}

Response: 301 Moved Permanently
Location: https://www.exemplo.com/pagina-muito-comprida

Obs: Este endpoint registra um clique e incrementa o contador
```

## Instalação

### 1. Clonar repositório e instalar dependências
```bash
git clone <repo>
cd aws-backend-my-money
npm install
```

### 2. Configurar variáveis de ambiente
```bash
cp .env.example .env
```

Editar `.env` com suas configurações:
```
DATABASE_URL="postgresql://user:password@localhost:5432/url_shortener"
JWT_SECRET="sua-chave-secreta-super-segura"
NODE_ENV="development"
BASE_URL="http://localhost:3000"
FRONTEND_URL="http://localhost:3001"
```

### 3. Executar migrations do Prisma
```bash
npm run prisma:migrate
```

### 4. Iniciar o servidor
```bash
# Desenvolvimento
npm run dev

# Produção
npm start
```

## Variáveis de Ambiente

| Variável | Obrigatória | Descrição |
|----------|------------|-----------|
| `DATABASE_URL` | Sim | URL de conexão com PostgreSQL |
| `JWT_SECRET` | Sim | Chave secreta para assinar JWT |
| `NODE_ENV` | Não | `development`, `production` ou `aws` |
| `BASE_URL` | Não | URL base para URLs encurtadas (padrão: `http://localhost:3000`) |
| `FRONTEND_URL` | Não | URLs permitidas para CORS (separadas por vírgula) |
| `PORT` | Não | Porta do servidor (padrão: 3000) |

## Testes

```bash
# Rodar todos os testes
npm test

# Testes em modo watch
npm run test:watch

# Testes com coverage
npm run test:coverage

# Apenas testes unitários
npm run test:unit

# Apenas testes de integração
npm run test:integration
```

## Arquitetura

```
src/
├── controllers/
│   ├── auth.controller.js      # Autenticação
│   └── url.controller.js       # URLs encurtadas
├── routes/
│   ├── auth.routes.js
│   ├── url.routes.js
│   └── health.routes.js
├── middlewares/
│   └── auth.middleware.js      # Verificação JWT
├── utils/
│   ├── prisma.js              # Cliente Prisma
│   └── aws-secrets.js         # Integração AWS Secrets Manager
└── index.js                    # Servidor Express
```

## Fluxo de Autenticação

1. Usuário registra com email e senha
2. Senha é hasheada com bcrypt
3. Para login, retorna JWT válido por 1 dia
4. Endpoints protegidos exigem `Authorization: Bearer {token}` no header
5. Middleware valida token e adiciona `userId` ao request

## Geração de Short Codes

- **Aleatórios**: 6 caracteres, usando `nanoid`
- **Customizados**: 3-20 caracteres, deve ser único no banco

## Analytics

Cada acesso ao short link registra:
- User Agent do navegador
- Referrer
- IP Address
- Timestamp

## Tratamento de Erros

Todos os endpoints retornam erros estruturados:
```json
{
  "error": "Mensagem de erro",
  "details": "Detalhes técnicos (apenas em desenvolvimento)"
}
```

## Deployment

### AWS Deployment
```bash
npm run setup-env  # Configura secrets no AWS Secrets Manager
./scripts/aws-deploy.sh
```

### Docker
```bash
docker build -t url-shortener .
docker-compose up -d
```

## Licença

ISC
