# GestaoOS Setorial — 7 telas completas (versão demonstrativa)

**IMPORTANTE:** esta entrega implementa as telas e a navegação do wireframe em Flutter, **não a integração real** com o GestaoOS Web. Os protocolos/OS do pacote são fictícios e permanecem **em memória** (são perdidos ao reiniciar o app). **Não coloque em produção, nem confunda os dados exibidos com ordens registradas no servidor.**

## Conteúdo

- `lib/main_setorial.dart`: execução do Setorial, sem alterar `lib/main.dart` pessoal.
- `lib/setorial/`: tema, modelos, serviço de demonstração, estado do tablet, componentes e as 7 telas.
- `assets/images/setorial_trabalhador_wireframe.png`: ilustração já utilizada na etapa 1.
- `test/setorial_flow_test.dart`: teste básico do fluxo de UI e validação de exemplo.
- `wireframes/`: referências para comparação final em paisagem e retrato.

## Instalação

1. **Faça backup** do seu projeto Flutter atual.
2. Trabalhe na cópia `C:\Users\54035204811\Documents\OS\gestaoos_setorial` (a pasta `mobileos` pessoal fica preservada).
3. Descompacte na **raiz** de `gestaoos_setorial`, mesclando `lib/`, `assets/` e `test/` e substituindo as versões anteriores de `lib/main_setorial.dart` e `lib/setorial/`.
4. No `pubspec.yaml` existente, confira as dependências `google_fonts: ^6.2.1` e `image_picker: ^1.1.2` (o tema usa Poppins via google_fonts; para depuração sem internet use `--dart-define=GESTAOOS_SYSTEM_FONT=true`) e a seção:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

5. Na pasta do projeto, execute:

```powershell
flutter pub get
flutter analyze
flutter test --dart-define=GESTAOOS_SYSTEM_FONT=true test/setorial_flow_test.dart
flutter run -t lib/main_setorial.dart --dart-define=GESTAOOS_DEMO_ADMIN_PIN=2468
```

**Demonstração:** para identificar o colaborador, digite matrícula `04218` e PIN `1234`. São dados fictícios **somente** desta implementação local. Para abrir a tela 7 (Configuração do tablet), faça **toque longo na marca/ícone no canto superior esquerdo da Home** e digite `2468`, quando iniciado com a opção acima. Sem essa opção, a tela administrativa permanece bloqueada.

**Teste visual:** compare com as imagens `wireframes/` em paisagem (1180×820) e retrato (820×1180). A UI se reorganiza em colunas ou rolagem.

## O que está funcional nesta entrega

- Home com acesso à identificação e consulta às OS de demonstração.
- Matrícula + PIN com teclado grande e bloqueio temporário após 5 tentativas incorretas (em memória).
- Seleção entre 8 serviços, prioridades, local, descrição de até 300 caracteres, até 4 fotos pela câmera.
- Protocolo demonstrativo, resumo e retorno automático para Home em 10 segundos.
- Consulta de OS por status e acompanhamento somente leitura.
- Configuração visual do tablet com opções locais; tempo de inatividade redefine a identificação e limpa dados do fluxo.

## O que NÃO está pronto

- Autorização/vínculo do dispositivo por API, emissão e revogação de token, PIN com hash no servidor, isolamento real de empresa/setor.
- Envio real de OS, fotos e identificação para o GestaoOS Web; sincronização offline persistente.
- Leitura QR pela câmera (o botão indica que está indisponível).
- **Kiosk seguro:** `immersiveSticky` oculta as barras, mas não bloqueia a saída do Android. É necessário configurar Android Lock Task/gerenciamento MDM para equipamentos de produção.
- Persistência de configurações e filas de OS; os valores aqui são apenas de sessão.
- Dados reais de conexão, bateria ou última sincronização; são explicitamente rotulados como demo.

Após revisar as 7 telas em um dispositivo real, faremos a integração incremental com as rotas/autorizações do GestaoOS Web e testes automatizados de segurança e fluxo.
