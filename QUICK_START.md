# 🚀 Quick Start - Desenvolvimento Local

Este guia te ajudará a colocar o URL Shortener Backend rodando em 5 minutos.

## Pré-requisitos

- Node.js 14+ (`node --version`)
- npm 6+ (`npm --version`)
- PostgreSQL 12+ (local ou Docker)
- Git

## 1️⃣ Clone ou Acesse o Projeto

```bash
cd /home/renancosta/programs/aws-backend-my-money
```

## 2️⃣ Instale as Dependências

```bash
npm install
```

Se houver erro com `nanoid`, tente:
```bash
npm install nanoid@^4.0.2
```

## 3️⃣ Configure o Banco de Dados

### Opção A: PostgreSQL Local

1. **Instale PostgreSQL** (se não tiver):
   ```bash
   # Ubuntu/Debian
   sudo apt-get install postgresql postgresql-contrib
   
   # macOS
   brew install postgresql@15
   
   # Windows
   # Download: https://www.postgresql.org/download/windows/
   ```

2. **Inicie PostgreSQL**:
   ```bash
   # Ubuntu/Debian
   sudo systemctl start postgresql
   
   # macOS
   brew services start postgresql
   ```

3. **Crie um usuário e banco de dados**:
   ```bash
   psql -U postgres
   ```

   No prompt `postgres=#`:
   ```sql
   CREATE USER urlshortener WITH PASSWORD 'senha123';
   CREATE DATABASE url_shortener_dev OWNER urlshortener;
   \q
   ```

### Opção B: Docker

Se preferir usar Docker:

```bash
docker run --name postgresql \
  -e POSTGRES_USER=urlshortener \
  -e POSTGRES_PASSWORD=senha123 \
  -e POSTGRES_DB=url_shortener_dev \
  -p 5432:5432 \
  -d postgres:15
```

## 4️⃣ Configure Variáveis de Ambiente

```bash
# Criar arquivo .env
cat > .env << EOF
DATABASE_URL="postgresql://urlshortener:senha123@localhost:5432/url_shortener_dev"
JWT_SECRET="sua-chave-super-secreta-openssl-rand-base64-32"
NODE_ENV="development"
PORT=3000
BASE_URL="http://localhost:3000"
FRONTEND_URL="http://localhost:3001"
EOF
```

## 5️⃣ Execute as Migrations

```bash
npm run prisma:migrate
```

Você será perguntado:
```
✔ Enter a name for the new migration: › init
```

Digite `init` e pressione Enter.

## 6️⃣ Inicie o Servidor

```bash
npm run dev
```

Você deve ver:
```
🧧 Initializing application configuration...
✅ Configurations loaded from: local .env
📊 DATABASE_URL: configured
🔐 JWT_SECRET: configured
🚀 Server is running on port 3000
```

## ✅ Teste se Está Funcionando

Abra outro terminal e teste:

```bash
# 1. Verificar saúde
curl http://localhost:3000/health

# 2. Registrar usuário
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@example.com",
    "password": "senha123",
    "name": "Usuário Teste"
  }'

# 3. Fazer login (copie o token)
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@example.com",
    "password": "senha123"
  }'

# 4. Criar URL encurtada (substitua TOKEN)
curl -X POST http://localhost:3000/api/urls \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "originalUrl": "https://github.com/renanzitoo",
    "customCode": "mygithub",
    "title": "Meu GitHub"
  }'
```

## 🎯 Próximos Passos

### Visualizar Dados

```bash
npx prisma studio
```

Abre interface em http://localhost:5555

### Executar Testes

```bash
npm test
npm run test:coverage
```

### Entender a API

Veja documentação completa:
- `API_DOCUMENTATION.md` - Todos os endpoints
- `CURL_EXAMPLES.sh` - Exemplos com curl
- `ENV_CONFIGURATION.md` - Configuração

### Editar Código

Estrutura do projeto:
```
src/
├── controllers/
│   ├── auth.controller.js
│   └── url.controller.js
├── routes/
│   ├── auth.routes.js
│   └── url.routes.js
├── middlewares/
│   └── auth.middleware.js
└── index.js
```

## 🔧 Troubleshooting

### "ECONNREFUSED: PostgreSQL"

Banco de dados não está rodando:
```bash
# Verificar status
sudo systemctl status postgresql  # Linux
brew services list | grep postgres  # macOS

# Iniciar
sudo systemctl start postgresql  # Linux
brew services start postgresql  # macOS
```

### "Migration failed"

Limpe e recrie:
```bash
npx prisma migrate reset --force  # ⚠️ DELETA DADOS
npm run prisma:migrate
```

### "DATABASE_URL not found"

Verifique arquivo `.env`:
```bash
cat .env  # Deve mostrar DATABASE_URL
```

### "Cannot find module 'nanoid'"

Instale dependências:
```bash
npm install
npm install nanoid@^4.0.2
```

## 📚 Recursos

- [Express.js](https://expressjs.com/) - Framework web
- [Prisma ORM](https://www.prisma.io/docs/) - ORM para banco
- [PostgreSQL](https://www.postgresql.org/docs/) - Banco de dados
- [JWT](https://jwt.io/) - Autenticação
- [Jest](https://jestjs.io/) - Testes

## 💡 Dicas

1. **Use Postman ou Insomnia** para testar APIs visualmente
   - Import: `API_DOCUMENTATION.md`
   - Ou use curl do `CURL_EXAMPLES.sh`

2. **Veja logs detalhados** para debugar:
   ```bash
   NODE_ENV=development npm run dev
   ```

3. **Resetar tudo** (se precisar recomeçar):
   ```bash
   # Deletar dados
   npm run prisma:migrate reset --force
   
   # Recriar
   npm run prisma:migrate
   npm run dev
   ```

4. **Ver dados no Prisma Studio**:
   ```bash
   npx prisma studio
   # Abre em http://localhost:5555
   ```

## 🎓 Aprender Enquanto Desenvolve

1. Abra `src/controllers/url.controller.js`
2. Leia como funciona `createUrl()`
3. Veja como valida URLs
4. Entenda geração de short codes
5. Teste via curl/Postman

## ✨ Celebre!

Se chegou aqui, seu backend está rodando! 🎉

```bash
# Fazer uma requisição final:
curl -X GET http://localhost:3000/
# Resposta: "URL Shortener Backend API"
```

## 📞 Precisa de Ajuda?

- Veja `CHANGES_SUMMARY.md` para entender as mudanças
- Veja `API_DOCUMENTATION.md` para endpoints
- Veja `MIGRATION_GUIDE.md` para banco de dados
- Leia o código em `src/controllers/`

---

**Próximo passo**: Crie um frontend para consumir esta API! 🚀
