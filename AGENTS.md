# Instrucoes para o Codex

Responda sempre em portugues do Brasil.

## Workspace

Este workspace usa um monorepo:

- Backend/API: `backend`
- Frontend: `frontend`

## Fluxo Git Padrao

Siga este fluxo para o monorepo:

1. Identifique quais areas foram alteradas: backend, frontend, infraestrutura, documentacao ou release.
2. Evite misturar alteracoes independentes de backend e frontend no mesmo commit. Mudancas coordenadas de infraestrutura ou contrato podem ficar no mesmo commit quando fizer sentido.
3. Para qualquer nova feature ou fix, atualize a `main` local a partir de `origin/main` antes de criar branch ou implementar, salvo quando a tarefa exigir uma PR empilhada.
4. Trabalhe a partir de `main` atualizada, salvo quando a tarefa exigir uma PR empilhada.
5. Crie uma branch especifica para a tarefa quando a alteracao ainda nao estiver em `main`.
6. Use nomes de branch descritivos, por exemplo:
   - `codex-backend-ajuste-seguranca`
   - `codex-frontend-versionamento`
   - `codex-docs-organizacao`
7. Implemente apenas o escopo solicitado.
8. Rode a validacao adequada antes do commit:
   - Backend/API: `cd backend; ./mvnw test`
   - Frontend: `cd frontend; npm run build`
9. Faca commit somente dos arquivos alterados pela tarefa.
10. Use mensagens objetivas, por exemplo:
   - `fix: corrigir validacao de curso`
   - `feat: adicionar fluxo de relatorio`
   - `docs: reorganizar documentacao`
   - `chore(release): vX.Y.Z`
11. Envie a branch para `origin`.
12. Abra PR para `main` quando a alteracao nao deve ir direto para `main`.
13. Se a tarefa pedir explicitamente para atualizar `main`, avance `main`, valide, faca push e informe o commit enviado.
14. Ao finalizar, informe branch, commit, PR ou destino do push, areas alteradas e validacoes executadas.

## Release Management

A aplicacao usa versionamento SemVer `x.y.z`.

A fonte unica da versao e o arquivo `VERSION` na raiz do workspace.

Nunca altere manualmente versoes hardcoded nas telas "Sobre". Use `scripts/release.ps1` para:

- atualizar `VERSION`;
- atualizar `backend/pom.xml`;
- atualizar `frontend/package.json`;
- atualizar `frontend/package-lock.json`;
- gerar `frontend/src/environments/version.ts`;
- criar commit `chore(release): vX.Y.Z`;
- criar tag Git anotada `vX.Y.Z`.

Tags de release devem sempre usar o formato `vX.Y.Z`.
