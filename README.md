# Portifolium

Monorepo da aplicacao Portifolium, organizado para deploy via Docker Compose no Coolify.

## Estrutura

```text
backend/                 API Spring Boot
frontend/                Aplicacao Angular servida por Nginx
docker-compose.yml       Compose de producao
docker-compose.dev.yml   Compose local com portas expostas e profile e2e
.env.example             Exemplo de variaveis de ambiente
VERSION                  Versao SemVer unica do projeto
```

## Execucao local com Docker

```powershell
Copy-Item .env.example .env
docker compose -f docker-compose.dev.yml up -d --build
```

URLs locais:

- Frontend: http://localhost:4200
- API: http://localhost:8080
- Health: http://localhost:8080/actuator/health

Para parar:

```powershell
docker compose -f docker-compose.dev.yml down
```

## Deploy no Coolify

Use `docker-compose.yml` na raiz do repositorio. Configure as variaveis do `.env.example` no ambiente do Coolify, principalmente:

- `POSTGRES_PASSWORD`
- `JWT_SECRET_KEY`
- `APP_CORS_ALLOWED_ORIGINS`
- `FRONTEND_URL`
- variaveis de e-mail, se o envio estiver habilitado

O backend garante um administrador padrao no startup. As credenciais iniciais podem ser ajustadas com:

- `APP_SEED_ADMIN_EMAIL`
- `APP_SEED_ADMIN_PASSWORD`
- `APP_SEED_ADMIN_RESET_PASSWORD`

O Nginx do frontend encaminha chamadas iniciadas em `/api/` para o servico interno `app:8080`.

## Validacao

Backend:

```powershell
cd backend
.\mvnw.cmd test
```

Frontend:

```powershell
cd frontend
npm run build
```

E2E via Compose:

```powershell
cd frontend
npm run e2e
```
