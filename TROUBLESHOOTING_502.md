# Guia de Resolução do Erro 502

## 🔴 Problema
Erro 502 Bad Gateway ao acessar o backend através do CloudFront.

## 🔍 Causa Raiz
O Load Balancer Nginx não consegue alcançar a instância EC2 onde o backend está rodando. Possíveis razões:

1. **Aplicação não iniciando corretamente** - Erro silencioso no boot
2. **CORS mal configurado** - Bloqueando requisições do CloudFront
3. **Porta 3001 não acessível** - Security Group ou aplicação não escutando
4. **Configurações AWS não carregadas** - DATABASE_URL ou JWT_SECRET faltando

## ✅ Correções Implementadas

### 1. **CORS Configurado (src/index.js)**
✅ Adicionado origin do CloudFront `https://d2nvo495vv8bz5.cloudfront.net`
✅ Permitir requisições sem origin (mobile apps, curl)

### 2. **Melhorado Boot Logging (src/index.js)**
✅ Logs detalhados com prefixo `[BOOT]` para diagnosticar problemas
✅ Validação de DATABASE_URL e JWT_SECRET antes de usar
✅ Melhor tratamento de erros de inicialização
✅ Server escuta em `0.0.0.0` (todas as interfaces)

### 3. **Melhorado Script de Inicialização (application_start.sh)**
✅ Validação completa de diretórios e dependências
✅ Melhor tratamento de JWT_SECRET do Secrets Manager
✅ Fallback para variável de ambiente
✅ Verificação de node_modules antes de iniciar

### 4. **Script de Diagnóstico (diagnostic.sh)**
✅ Novo script para diagnosticar problemas em tempo real

## 📋 Próximas Etapas

### Passo 1: Fazer Commit das Mudanças
```bash
cd /home/renancosta/programs/aws-backend-short-url
git add -A
git commit -m "Fix: Melhorar CORS, logging e inicialização da aplicação"
git push origin main
```

### Passo 2: Redeploy na AWS
1. Vá até AWS CodeDeploy
2. Crie um novo deployment ou trigue automaticamente via CodePipeline
3. Aguarde conclusão

### Passo 3: Verificar Logs da Instância EC2
SSH na instância e execute:
```bash
# Ver status do PM2
pm2 list

# Ver logs detalhados
pm2 logs meu-backend --lines 100

# Ou execute o script de diagnóstico
bash /opt/apps/backend/current/codedeploy/diagnostic.sh
```

### Passo 4: Testar Conectividade
```bash
# HTTP local (de dentro da instância)
curl -v http://localhost:3001/

# HTTPS através do CloudFront
curl -v -H "Origin: https://d2nvo495vv8bz5.cloudfront.net" \
  https://d2nvo495vv8bz5.cloudfront.net/api/auth/register
```

## 🔧 Checklist AWS

### Verificar Security Group
- [ ] Porta 3001 aberta para o Load Balancer
- [ ] Load Balancer pode acessar a instância

### Verificar Load Balancer
- [ ] Target Group saudável (Health Check passando)
- [ ] Listener configurado na porta 443 (HTTPS)
- [ ] Target port: 3001

### Verificar RDS
- [ ] Base de dados acessível
- [ ] Secrets Manager contém credentials RDS
- [ ] JWT_SECRET no Secrets Manager

### Verificar IAM
- [ ] Instância EC2 tem role com permissão Secrets Manager
- [ ] Permissão: `secretsmanager:GetSecretValue`

## 🚨 Se Ainda Não Funcionar

### Opção 1: SSH na Instância e Debug
```bash
# Conectar à instância
ssh -i your-key.pem ec2-user@your-instance-ip

# Verificar se aplicação está rodando
sudo pm2 list

# Ver logs completos
sudo pm2 logs meu-backend --lines 200

# Testar conexão local
curl -v http://localhost:3001/

# Verificar porta escutando
netstat -tlnp | grep 3001
lsof -i :3001
```

### Opção 2: Restartar Aplicação
```bash
# Conectar como appuser
sudo su - appuser

# Navegar para o diretório
cd /opt/apps/backend/current

# Restartar PM2
pm2 restart meu-backend

# Ver status
pm2 logs meu-backend --lines 50
```

### Opção 3: Verificar Secrets Manager
```bash
# Verificar se secret existe
aws secretsmanager get-secret-value \
  --secret-id money2-backend-dev-secret-rds \
  --region us-east-1

# Deve retornar JSON com host, username, password, port, dbname, jwt_secret
```

## 📊 Fluxo de Requisição
```
CloudFront
  ↓
Load Balancer Nginx (porta 443)
  ↓
Target Group (porta 3001)
  ↓
EC2 Instance (IP privado)
  ↓
PM2 Process (node src/index.js)
  ↓
Express App (escuta 0.0.0.0:3001)
```

## 🎯 Indicadores de Sucesso
- [ ] Logs mostram `[BOOT] ✅ Server is running on port 3001`
- [ ] Logs mostram `[BOOT] 🎉 Application ready to accept requests`
- [ ] Aplicação conecta ao banco de dados
- [ ] CORS permite requisição do CloudFront
- [ ] Requisições são roteadas corretamente
