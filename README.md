# Dvorak Keys

Teclado pessoal para iPhone: Dvorak fixo (igual ao seu atual), com emojis próprios, sugestões, long-press, arrasto pra apagar e Liquid Glass.

## Compilar no GitHub

1. Crie um repositório e suba **todos** estes arquivos (inclusive a pasta `.github`).
2. Vá em **Actions > Build IPA > Run workflow** (ou é só dar push na branch `main`).
3. Quando terminar, baixe o artefato **DvorakKeys-ipa** (dentro tem `DvorakKeys.ipa`, sem assinatura).
4. Instale pelo seu sideloader (AltStore, Sideloadly...). Ele assina o app **e a extensão do teclado**.
   - Conta gratuita: o app + o teclado usam 2 dos seus 3 espaços. A assinatura vence em 7 dias; é só reinstalar.

Se o build falhar, copie o erro vermelho do log da Action e me mande.

## Ativar o teclado no iPhone (permissões)

1. **Ajustes > Geral > Teclado > Teclados > Adicionar Novo Teclado… > Dvorak Keys**
2. Toque em **Dvorak Keys** na lista e ligue **Permitir Acesso Completo**.
3. Em qualquer campo de texto, segure o globo e escolha **Dvorak Keys**.

### Sobre "Permitir Acesso Completo"

- É usado **só para a vibração (haptic)**. Sem ele o teclado funciona normal, só não vibra.
- O iOS mostra um aviso genérico de privacidade quando você liga. O código deste teclado **não tem nenhum acesso à internet** e não grava o que você digita.
- Sugestões e autocorreção usam o corretor do próprio iPhone (dicionários de inglês, espanhol, português e russo já vêm no sistema).
- Campos de senha: o iOS troca automaticamente para o teclado padrão da Apple. Isso é regra do sistema.

## Como usar

| Ação | Como |
|---|---|
| Letra | Toca e a letra sai na hora (sem zona morta entre teclas) |
| Extras (acentos, símbolos) | Segura a tecla e arrasta até o extra |
| Trocar idioma (EN / ES / PT / RU) | Segura o botão de emoji |
| Mover o cursor | Segura a barra de espaço e arrasta |
| Apagar | Arrasta pra esquerda em **qualquer** lugar: curto = 1 letra, longo = palavra |
| Shift | 1 toque = maiúscula; 2 toques rápidos = caps lock |
| Ajustes | Segura o `123` por 3 segundos |

O layout é sempre o mesmo Dvorak; só o dicionário muda entre EN / ES / PT. O russo usa o layout fonético.

## Estrutura

- `project.yml`: definição do projeto (o XcodeGen gera o `.xcodeproj` no GitHub)
- `DvorakKeys/`: app container (instruções + campo de teste)
- `DvorakKeysKeyboard/`: o teclado
  - `Layouts.swift`: **todas as teclas e long-press, em listas** (edite aqui para mudar o layout)
  - `KeyboardView.swift`: desenho das teclas, toques e gestos
  - `KeyboardViewController.swift`: digitação, shift, autocorreção
  - `EmojiPanel.swift`, `SettingsPanel.swift`, `SuggestionEngine.swift`, `Theme.swift`, `Settings.swift`
