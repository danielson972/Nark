# RPG do Reino — projeto Godot recuperado

## Abrir e executar

1. Use o Godot **4.7.2**, versão usada pela publicação original. Pode ser a edição padrão ou .NET; os scripts do jogo são GDScript.
2. No gerenciador de projetos, escolha **Importar** e selecione `project.godot` nesta pasta.
3. Aguarde a importação dos recursos e pressione **F5** para jogar.

Se estiver usando o ZIP, extraia toda a pasta antes de importar. Foi encontrado `Godot_v4.7.2-stable_mono_win64.zip` nos seus Downloads.

## Conteúdo recuperado

- 25 scripts GDScript editáveis em `scripts/` e `autoload/`.
- Cena principal em `scenes/main.tscn`.
- Imagens PNG, fontes, recursos de interface, shaders e configurações de entrada.
- 73 recursos convertidos, sem falhas reportadas pelo GDRETools.

A interface e o mundo são construídos principalmente pelos scripts em tempo de execução; por isso, a cena principal é pequena.

## Origem e limites

Recuperado em 13/11/2026 do pacote público deste jogo:
https://rpgdoreino-ikasvawf.manus.game/

Ferramenta: GDRETools 2.7.4, distribuição oficial:
https://github.com/GDRETools/gdsdecomp/releases/tag/v2.7.4

É uma recuperação da versão publicada. Comentários e formatação original dos scripts não são preservados. Histórico de versões, testes originais, ferramentas de build do Manus e presets de exportação não estavam no pacote. `package.json` e os metadados de verificação foram preservados como referência, mas seus comandos dependem dessas ferramentas ausentes. Para editar e jogar, abra diretamente no Godot.

O progresso salvo no navegador não foi transferido. Nenhum arquivo de áudio estava no pacote; os caminhos de música estão vazios nessa publicação. Não foi acrescentada trilha sonora.

## Verificação realizada

- Integridade MD5 dos 164 arquivos do pacote conferida.
- Importação e reconhecimento das classes no Godot 4.7.2.
- Inicialização da cena principal sem erros de execução.
- 24 combinações de raça/classe: criação de personagem, herói, inimigos, inventário, habilidades, mapa regional e pausa.
- Sessão com transições espaçadas passou sem erros.

O teste que alterna imediatamente entre 24 partidas registrou callbacks de interface referenciando objetos já liberados. Esse comportamento foi preservado; o projeto não recebeu mudanças na lógica do jogo. O editor também registrou um erro de gravação segura no ambiente restrito de validação, sem impedir a importação nem os testes de execução. Consulte os logs em `relatorios/`.

O ZIP contém os arquivos editáveis e dispensa caches `.godot` e cópias intermediárias `.autoconverted`; o Godot gera os caches ao importar.
