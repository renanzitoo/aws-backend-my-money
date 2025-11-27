# Guia de Execução da Migration do Prisma

## Pré-requisitos

- Node.js instalado
- PostgreSQL em execução
- Variável `DATABASE_URL` configurada em `.env`

## Passos para Executar a Migration

### 1. Instalar dependências (se não feito ainda)
```bash
npm install
```

### 2. Gerar Cliente Prisma
```bash
npm run prisma:generate
```

### 3. Executar Migration
```bash
# Para desenvolvimento (com prompt de confirmar)
npm run prisma:migrate

# Ou equivalente
npx prisma migrate dev --name init
```

### 4. Verificar Status
```bash
npx prisma migrate status
```

### 5. Visualizar Dados (opcional)
```bash
npx prisma studio
```

## O que a Migration Faz

A migration criará as seguintes tabelas:

### 1. `users` (mantida)
```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### 2. `shortened_urls` (nova)
```sql
CREATE TABLE shortened_urls (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL REFERENCES users(id),
  original_url TEXT NOT NULL,
  short_code VARCHAR(20) UNIQUE NOT NULL,
  title VARCHAR(255),
  description TEXT,
  clicks INT DEFAULT 0,
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_short_code ON shortened_urls(short_code);
CREATE INDEX idx_user_id ON shortened_urls(user_id);
```

### 3. `url_analytics` (nova)
```sql
CREATE TABLE url_analytics (
  id INT PRIMARY KEY AUTO_INCREMENT,
  url_id INT NOT NULL REFERENCES shortened_urls(id),
  user_agent VARCHAR(500),
  referer VARCHAR(500),
  ip_address VARCHAR(45),
  country VARCHAR(2),
  clicked_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_url_id ON url_analytics(url_id);
CREATE INDEX idx_clicked_at ON url_analytics(clicked_at);
```

## Se Ocorrer Erro

### "Migration failed: table already exists"
Se tabelas antigas ainda existem, remova-as:
```sql
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS accounts;
```

Depois execute novamente:
```bash
npm run prisma:migrate
```

### "DATABASE_URL not found"
Certifique-se de que `.env` tem a variável:
```
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"
```

### "Connection refused"
Verifique se PostgreSQL está rodando:
```bash
# Linux
sudo systemctl status postgresql

# Mac
brew services list | grep postgresql

# Windows
psql -U postgres
```

## Próximas Etapas

1. Instale as dependências: `npm install`
2. Execute: `npm run prisma:migrate`
3. Inicie: `npm run dev`
4. Teste endpoints em `http://localhost:3000`

## Desfazer Migration

Se precisar reverter:
```bash
# Isso deletará os dados!
npx prisma migrate resolve --rolled-back <migration_name>
npx prisma migrate deploy  # Reaplica migrations anteriores
```

Ou resetar completamente o banco:
```bash
npx prisma migrate reset  # ⚠️ DELETA TODOS OS DADOS
```

## Dicas

- As migrations são versionadas em `prisma/migrations/`
- Cada execução de `npm run prisma:migrate` cria uma nova migration
- Sempre commit das migrations ao Git
- Nunca delete migrations, apenas crie novas para reverter

## Schema Diagram

```
users (1) ─────────(N) shortened_urls (1) ─────────(N) url_analytics
  id                     id
  email                  user_id
  password               original_url
  name                   short_code
  created_at             title
  updated_at             description
                         clicks
                         expires_at
                         created_at
                         updated_at
                                              id
                                              url_id
                                              user_agent
                                              referer
                                              ip_address
                                              country
                                              clicked_at
```
