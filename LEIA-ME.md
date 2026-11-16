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

## Sala secreta do desenvolvedor

Durante uma partida, pressione **Ctrl + Shift + F12** para entrar ou sair. A sala não aparece no menu de teleporte. Aproxime-se das bancadas e use **E** (ou a tecla de interação configurada).

- **Arsenal:** todos os itens cadastrados em GameData.ITEMS, grátis, em quantidades de 1 ou 10.
- **Biblioteca:** teste qualquer uma das seis classes no nível 100, com todas as habilidades da classe e as universais liberadas. As skills entram na hotbar; o menu de skills permite consultá-las e aprimorá-las com livros do arsenal.
- **Bancada:** restaurar HP, mana, energia, recargas e durabilidade, receber moedas, invocar qualquer inimigo cadastrado (até oito simultâneos) e limpar inimigos.
- **Portal:** sair e restaurar o personagem original. O atalho também funciona com painéis abertos ou após morrer.

A sala usa uma cópia temporária do personagem e mantém o mundo original pausado. Salvamento manual e automático ficam desativados durante os testes. Ao sair, personagem, posição, inventário e progresso originais são restaurados.

Validação automatizada: relatorios/verify_developer_room.gd; resultado em relatorios/developer-room-test.log.

## HUD de status do herói

O painel de status agora usa a cena `scenes/ui/hero_status.tscn`, editável no Godot. Mostra somente nome, nível e barras HP, MP, EP e XP, sem fundo de painel. O layout compacto tem 170 pixels de largura. Os números ficam dentro das barras; EP e XP têm 10 pixels de altura, enquanto HP e MP têm 12. As barras usam largura fixa e atualizam o preenchimento de acordo com o valor atual e o máximo. `scripts/ui/game_ui.gd` conecta os valores do personagem à cena. Os detalhes da esquiva aparecem na dica ao passar o mouse sobre EP.

Validação: `relatorios/verify_hud_experience.gd`, `relatorios/verify_energy_hud.gd` e `relatorios/verify_dodge_potions.gd`.

## Equipamentos visíveis no personagem

Novos personagens começam com Roupa Básica e Arma de Treino equipadas. Abra o
inventário com **I**, selecione o slot equipado e use **Desequipar** para retirar;
selecione o item na mochila e use **Equipar** para colocá-lo novamente.

Armas e armaduras aparecem no personagem e no retrato do inventário. Cada classe
tem sua aparência de armadura NG, D, C e B. A arma é independente da roupa e
acompanha o personagem ao virar e atacar. Sem armadura, o personagem usa roupa
de baixo simples; sem arma, o ataque básico passa a ter alcance curto, sem
disparar flechas ou projéteis. As habilidades de classe mantêm suas regras.

Os novos itens básicos também estão disponíveis no arsenal da sala secreta.
Saves anteriores preservam os equipamentos que já estavam usando.

Artes e prompt: `assets/game/sprites/herois/compartilhados/equipamentos/`. Detalhes técnicos no README
dessa pasta. Validação em `relatorios/verify_equipment_visuals.gd`, com uma
galeria renderizada em `relatorios/equipment-visual-gallery.png`.

## Inventário em três colunas

Abra com **I**. A interface adapta a referência com moldura escura/dourada, personagem e equipamentos à esquerda, mochila ao centro e detalhes do item à direita. As abas Todos, Equipamentos, Consumíveis, Materiais e Missão filtram a mochila sem alterar os itens. Missão reúne chaves e livros de progressão. A categoria e a rolagem são preservadas ao executar ações.

O slot dourado **Hero**, ao lado do personagem, usa o equipamento cosmético existente (`aura` nos saves), sem criar um novo atributo ou alterar saves. Vazio, mostra uma estrela; equipado, mostra a arte do item Hero. O duplo clique e os botões Equipar/Desequipar funcionam nele, nas armas, armaduras e joias.

Os detalhes mostram descrição, tipo, grau, peso unitário, valor nas moedas reais do jogo e bônus/durabilidade quando aplicáveis. Usar, Soltar e Guardar no baú mantêm as regras existentes. A interface se ajusta ao espaço da janela; somente a mochila rola. Não foram criados equipamentos de capacete, luvas, botas ou escudo: os quatro slots representam os tipos que o jogo já possui.

Implementação: `scripts/ui/inventory_panel.gd`. Validação: `relatorios/verify_inventory_reference.gd` e `relatorios/verify_inventory_double_click.gd`.
