# Correção dos avisos — GestaoOS Setorial

Esta atualização foi preparada para a estrutura exibida no VS Code, com o projeto Flutter chamado `mobos`.

## Passo 1: instalar as dependências (obrigatório)

Abra o terminal do VS Code **na pasta em que está o `pubspec.yaml`** e execute:

```powershell
flutter pub add google_fonts image_picker
flutter pub get
```

Isto resolve os erros vermelhos referentes a `GoogleFonts`, `ImagePicker`, `ImageSource` e `XFile`. A atualização em ZIP, sozinha, **não** instala bibliotecas.

## Passo 2: copiar as pequenas correções

Extraia o conteúdo do ZIP sobre a raiz do projeto `mobos`, mesclando apenas as pastas `lib` e `test`, sem apagar as outras. Faça cópia dos arquivos substituídos antes de aplicar.

Os arquivos deste ZIP são:

- `lib/main_setorial.dart` — callback sem underscores excedentes.
- `lib/setorial/screens/details.dart` — `if` com chaves e callback de erro.
- `lib/setorial/screens/setorial_root.dart` — `if/else` com chaves.
- `test/setorial_flow_test.dart` — imports pelo nome do pacote.

**Se o valor de `name:` no seu `pubspec.yaml` não for `mobos`, substitua `package:mobos/` pelos imports com o nome efetivo do seu projeto nos dois imports do teste.**

## Passo 3: conferir

```powershell
flutter analyze
flutter test test/setorial_flow_test.dart --dart-define=GESTAOOS_SYSTEM_FONT=true
flutter run -t lib/main_setorial.dart --dart-define=GESTAOOS_DEMO_ADMIN_PIN=2468
```

Este ZIP não troca a tela inicial, não muda cores nem wireframes, não modifica o app pessoal e não integra o backend. Ainda é o modo demonstrativo.

*O Flutter SDK não está disponível no ambiente onde o ZIP foi preparado, portanto os testes precisam ser executados no seu computador.*
