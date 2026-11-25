# Sistema de Fluxo Financeiro

Sistema web de aprovação de pagamentos em uso diário na **DMF Empreendimentos** e na **JFX Engenharia**. Ele substituiu a coleta física de assinaturas por aprovação digital feita de qualquer lugar.

## O problema

Todo dia, o financeiro extraía os lançamentos do ERP Conta Azul, montava uma planilha com os pagamentos e levava o papel para **3 gestores e 1 diretor** assinarem. O processo tomava **de 2 a 3 horas por dia** e dependia de todos estarem no escritório.

## A solução

- **Importação automática do Conta Azul:** o sistema busca as despesas pela API do ERP e monta o fluxo do dia sozinho, sem redigitação.
- **Aprovação digital:** cada gestor aprova os pagamentos do seu contrato pelo navegador ou pelo celular.
- **Assinatura verificável:** cada aprovação gera uma assinatura HMAC, que pode ser conferida numa página pública de verificação (`/verify`).
- **Acesso por papel e por empresa:** perfis de aprovador, auditor e administrador, com cada usuário vendo só as empresas e os centros de custo liberados para ele.
- **Trilha de auditoria:** registro de quem aprovou o quê e quando.
- **Relatórios e arquivo** dos fluxos de pagamento fechados.
- **PWA:** pode ser instalado no celular e tem página offline.

## Stack

| Camada | Tecnologias |
| --- | --- |
| Backend | Node.js, Express, Sequelize, PostgreSQL |
| Segurança | JWT, bcrypt, Helmet, rate limiting, express-validator |
| Frontend | HTML, CSS e JavaScript, PWA com Service Worker |
| Integrações | API do Conta Azul (OAuth2 e webhook) |
| Infra | Render (web service + Postgres), GitHub Actions |

## Como funciona

```
Conta Azul (ERP) ──API/webhook──▶ API Express ──▶ PostgreSQL
                                     │
                    navegador / PWA ◀┘  (login JWT, aprovação, auditoria)
```

## Estrutura

| Caminho | Conteúdo |
| --- | --- |
| `server.js` | API Express: autenticação, pagamentos, assinaturas, auditoria |
| `db.js` | Modelos Sequelize e preparação do banco |
| `script.js` | Lógica do frontend |
| `*.html`, `*.fragment.html` | Telas (painel, pagamentos, auditoria, admin) |
| `sw.js`, `manifest.webmanifest` | PWA |
| `scripts/` | Checagens de segurança, smoke tests e verificações de produção |
| `docs/` | Checklists de deploy, runbook de operação e pendências |
| `.github/workflows/` | CI: instalação, checagem de sintaxe e de segurança a cada push |

## Rodar localmente

Pré-requisitos: Node.js 22 e um PostgreSQL acessível.

```bash
npm install
cp .env.example .env   # preencha DATABASE_URL, JWT_SECRET e as credenciais do Conta Azul
npm run dev
```

Webhook, se necessário:

```bash
npm run start:webhook
```

## Deploy no Render

O arquivo `render.yaml` provisiona o web service e o banco Postgres, liga o `DATABASE_URL` ao banco e gera `JWT_SECRET` e `SIGNATURE_SECRET` automaticamente. Os segredos do Conta Azul são cadastrados direto no painel do Render; veja `.env.render.example`.

Configuração manual equivalente:

- Build: `npm install`
- Start: `node server.js`
- Health check: `GET /api/health`

Para criar um administrador no primeiro deploy, defina `ENABLE_BOOTSTRAP_ADMIN=true` e as variáveis `BOOTSTRAP_ADMIN_*`. Depois volte para `false`.

## Checagens

```bash
npm run check:baseline                                   # validações locais
npm run check:phase3                                     # checklist completo
BASE_URL=https://seu-app.onrender.com npm run smoke:prod # smoke test em produção
npm run go-live:check                                    # checagem de go-live
```

Métricas operacionais: `GET /api/ops/metrics` (requer permissão de administrador).

## Segurança

- Nunca versione `.env` nem `.env.render`; os segredos ficam só no ambiente do Render.
- Revise `CORS_ORIGINS`, `PG_SSL` e `DATABASE_URL` antes de cada deploy.

## Próximos passos

- Separar `server.js` em rotas, controllers e services.
- Adicionar testes automatizados das regras de aprovação.
- Concluir a integração com a Cobli (veja `docs/TODO_Cobli.md`).

## Autor

Pedro Cruz · [LinkedIn](https://www.linkedin.com/in/pedro-cruz-fullstack/) · [GitHub](https://github.com/DevCruz11)
