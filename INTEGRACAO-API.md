# Integração GestaoOS Web ↔ Mobile Setorial

O modo setorial usa a API real quando as duas variáveis abaixo são informadas:

```text
GESTAOOS_API_URL=http://IP-DO-PC:3000/api
GESTAOOS_EMPRESA_CODIGO=GEST-...
```

Exemplo no tablet Android:

```bash
flutter pub get
flutter run --dart-define=GESTAOOS_API_URL=http://10.133.126.34:3000/api --dart-define=GESTAOOS_EMPRESA_CODIGO=GEST-SEU-CODIGO
```

Fluxo real:

1. Matrícula + PIN → `POST /api/setorial/identificar`
2. API devolve sessão JWT, usuário e setor.
3. Tablet abre OS → `POST /api/ordens`
4. Fotos são enviadas como multipart em `anexos`.
5. OS do setor → `GET /api/setorial/ordens`.
6. O protocolo exibido no tablet é o protocolo real gerado pelo Web.

Sem os dois `--dart-define`, o projeto continua usando o repositório de demonstração para não quebrar os testes/telas existentes.

## PIN

O backend GestaoOS aceita PIN setorial de 4 dígitos armazenado com hash. O PIN pode ser definido pelo endpoint de usuários:

```http
PATCH /api/usuarios/:id
Authorization: Bearer <token-do-administrador>
Content-Type: application/json

{"pin":"1234"}
```

Também é possível pedir geração aleatória no cadastro/alteração:

```json
{"gerarPin":true}
```

A resposta dessa operação contém `pinTemporario` somente para a operação que gerou o PIN.
