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

## Inventário e equipamento com o fundo da referência

Abra com **I** para exibir inventário e status lado a lado. **T** abre somente equipamento/status. Fechar o inventário fecha os dois painéis e retoma o jogo. O status também pode ser fechado por T ou por seu botão de fechar. Esc fecha a interface completa.

O fundo usa a imagem enviada em `assets/game/ui/inventory/equipment_inventory_gold.png`, com os itens e números de exemplo cobertos pelos controles reais. As abas são Todos, Armas, Armaduras, Materiais, Consumíveis e Missões. Missões reúne chaves e livros de progressão. A mochila tem oito colunas e rolagem para o catálogo completo. Selecione um item e pressione **Detalhes** para consultar descrição, grau, peso, valor e bônus. Equipar, retirar, usar, guardar e soltar mantêm as regras existentes e preservam a aba e a rolagem.

O slot **Hero** mantém o equipamento cosmético existente (`aura` nos saves). O duplo clique equipa e retira armas, trajes, escudos, anéis, colares, talismãs e Hero.

Para editar visualmente, abra `scenes/ui/equipment_panels.tscn` na aba **2D**. Os dois painéis também têm cenas próprias: `inventory_panel.tscn` e `equipment_status_panel.tscn`, na mesma pasta. Fundo, slots, abas, textos, botões e a área de prévia são nós editáveis. A montagem do personagem e seus sprites permanecem nas cenas existentes.

Validações: `relatorios/verify_reference_panels.gd`, `verify_inventory_reference.gd` e `verify_inventory_double_click.gd`.

## Novo humano

A raça Humano agora usa a imagem enviada como aparência de base, com camisa de linho, calças e botas. Ela aparece no mundo, na criação do personagem e no inventário. As seis classes também têm versões com armaduras NG, D, C e B que mantêm o novo rosto e as proporções. Armas continuam independentes e o brilho Hero acompanha o peito. Elfo, Orc e Anão mantêm suas artes anteriores; saves existentes recebem a nova aparência humana ao carregar, sem alterar equipamentos ou atributos.

Fontes, atlas e prompts em `assets/game/sprites/herois/humano/`. Regeneração pelo script `scripts/tools/prepare_human_appearance.gd`. Validação em `relatorios/verify_human_appearance.gd`.

A revisão de cor usa `human_equipment_atlas_vibrant.png`: roupas mais claras e um pouco mais vivas, em tons de fantasia natural, sem o tratamento sombrio. As fontes originais permanecem preservadas, e os prompts dessa edição estão em `assets/game/sprites/herois/humano/color_generation.json`.

## Acabamento pixel art

A revisão pixelada foi desativada. Colossal Aurora, cenários, itens e efeitos voltaram à renderização com detalhe nativo, sem ampliação de pixels ou redução de tons. A câmera permanece mais próxima, com zoom 0,65. As fontes da revisão ficam preservadas em `assets/game/pixel_art/` como histórico.

## Montagem do personagem

A tela foi adaptada para o pátio de ruínas, com identidade à esquerda, aparência à direita e personagem no pedestal central. As posições locais, escalas, rotações e offsets dos Sprite2D de personagens/cabelos/barbas foram preservados; o conjunto é apenas deslocado para o centro. A paleta muda a cor do cabelo, e a barba tem cor independente. Detalhes e prompt do fundo em `assets/game/ui/creation/README.md`.

O anão masculino usa a nova base sem barba, mantendo exatamente o tamanho e as transformações da montagem. Escolha entre **Sem barba** e 20 modelos em Sprite2D, com cor independente. A seleção aparece no jogo/inventário e fica no save. A cena `scenes/character_beards.tscn` contém as peças editáveis. Os ícones das 100 armaduras foram recortados e centralizados nos slots, preservando suas proporções.

**Iniciar** abre a cena `scenes/character_creation.tscn`, com Humano, Elfo, Orc e Anão em modelos masculino e feminino. Todos começam carecas; escolha entre 16 cabelos e sete cores, além de nome e classe. A prévia acompanha as escolhas, que aparecem no mundo e no inventário e são gravadas com o save. As armaduras usam peças compartilhadas e mantêm a cabeça racial e o cabelo escolhidos. Saves antigos usam a opção Careca como padrão. Fontes, prompts e detalhes em `assets/game/character_builder/README.md`. Validações em `relatorios/verify_character_assembly.gd` e `relatorios/verify_original_art_quality.gd`.

## Slots de equipamento

O painel tem **Traje, Arma, Escudo, Anel, Colar, Talismã e Hero**. Cada slot vazio exibe um ícone semitransparente do tipo aceito. O ícone desaparece enquanto o espaço estiver ocupado. Os indicadores são TextureRects `EmptyIcon`, editáveis na cena `scenes/ui/equipment_status_panel.tscn`; a opacidade fica em `modulate.a` e a arte em `assets/game/ui/equipment_slots/`.

Os anéis existentes usam o slot Anel. Os doze escudos do Arsenal usam Escudo, permitindo equipar uma arma ao mesmo tempo. O escudo aparece no braço esquerdo no jogo e na prévia. Saves anteriores migram os anéis de `joia` para `anel` e os escudos antes equipados como arma para `escudo`, preservando durabilidade. Colar Simples e Talismã Simples são entradas básicas sem bônus de atributos.

Validação: `relatorios/verify_equipment_slots.gd` e `relatorios/verify_reference_panels.gd`.

## Ícones de peitorais

As 100 armaduras do catálogo e as 30 variantes dos trajes de classe agora usam ícones de torso com fundo transparente, seguindo o peitoral de referência. Os ícones aparecem na mochila, detalhes e slots equipados, sobre as cores dinâmicas de raridade. As peças vestidas pelo personagem mantêm suas próprias imagens.

Pranchas, recursos individuais e prompts: `assets/game/ui/items/armor_portraits/README.md`. Prévia: `relatorios/icones-armaduras-cores.png`. Validação: `relatorios/verify_armor_portraits.gd`.


## Novos heróis e arsenal — 18/11/2026

A criação usa agora as bases de `assets/game/sprites/racas/`: Humano, Elfo,
Orc, Anão e Elarim; modelos masculino/feminino; corpos magro, médio e forte.
Há dez cabelos, cinco barbas e cores. A criação usa uma prévia frontal estática,
sem setas ou controles de animação, com os modelos enviados em
`assets/game/ui/creation/front_races_reference.png`, exibidos com até 160 px de altura.
A caminhada usa os seis quadros de cada linha, a 9 fps, com cadência maior ao correr.
O tipo de corpo acompanha o save; saves antigos assumem o corpo médio.
Elarim usa provisoriamente os bônus raciais de Elfo.

Os cinco espaços novos são Elmo, Peitoral, Luvas, Calça e Botas. As 150 peças
fornecidas estão no Arsenal da sala de desenvolvimento. Novos personagens
recebem peitoral, calça e botas No Grade. Equipar uma peça retira o traje antigo
inteiro; equipar um traje antigo retira as cinco peças, devolvendo tudo à mochila.
Armas e escudos usam os 100 sprites individuais do novo arsenal. Tank usa
provisoriamente as armaduras de Guerreiro; Atirador usa as de Arqueiro.
Os itens antigos continuam cadastrados para preservar os saves.
As peças novas mantêm a ausência de bônus de atributos do catálogo fornecido.

A composição compartilhada está em `scripts/actors/nark_design.gd`.
Corpos têm oito vistas animadas reais. Cabelos, barbas e peças de armadura
foram fornecidos com uma única vista e recebem adaptações de posição, largura,
espelhamento e sobreposição; ainda precisam de artes direcionais próprias para
um acabamento consistente nas laterais e nas costas. As imagens originais
fornecidas não foram modificadas.

Validação: `relatorios/verify_new_design.gd`, com 1.440 quadros, 150 peças,
100 armas/escudos, persistência de aparência e animação/ataque das seis classes.
Resultado: `relatorios/new-design-test.log`. A abertura real da criação e do
inventário foi renderizada por `relatorios/preview_new_design.gd`; imagens
`new-character-creation.png`, `new-equipment-panel.png` e galerias na mesma pasta.


### Criação novamente editável na aba 2D

Abra `scenes/character_creation.tscn` no Godot. Fundo, menus, textos, botões e
personagens estão salvos como nós da cena. Os scripts apenas conectam as ações,
selecionam a aparência e atualizam visibilidade e cores; não recriam a montagem.

Em `Margens/Colunas/Apresentacao/Personagem/Apoio/Modelos`, cada grupo de raça e
modelo contém `Base`, `Cabelos/Modelo1..10` e `Barbas/Modelo1..5`. Posição, escala,
rotação e recorte dos Sprite2D são editáveis e preservados durante as seleções.
Para ver outra camada no editor, altere sua visibilidade na árvore. A criação
continua frontal e estática, sem setas e sem equipamentos.

Cabelos e barbas agora usam recursos persistentes nos Sprite2D e materiais que
preservam a transparência, substituindo os acessórios temporários desenhados
pelo método `_draw`. Verificação renderizada: `relatorios/verify_editable_creation.gd`;
resultado: `relatorios/editable-creation-test.log` (dez montagens, cem camadas de
cabelo e cinquenta de barba). Prévia: `relatorios/editable-creation-hair-beard.png`.


### Alinhamento pela edição do humano masculino e porte físico

A posição (-545, -230.50003) e a escala (1.3664985, 1.3664985) da Base humana
masculina foram preservadas como referência da montagem. As dez combinações
raciais/de modelo agora apoiam os pés no mesmo ponto do pedestal; cabelos e
barbas acompanham o transform da respectiva Base. O cálculo dos encaixes ignora
pixels quase transparentes que ampliavam incorretamente os limites das imagens.

Cada grupo contém `Base` (médio), `BaseMagro` e `BaseForte`, além de Cabelos e
Barbas. O seletor Corpo alterna essas camadas sem reposicionar a montagem. A
prancha frontal fornecida tem um único porte: as prévias magra e forte ajustam
a silhueta do tronco com `shaders/creation_body_shape.gdshader`, preservando
rosto, altura e pés. Os sprites do jogo continuam usando as variantes magra,
média e forte fornecidas em racas/caminhada.

Validação: `relatorios/verify_creation_builds.gd` testa as trinta combinações,
a preservação do ajuste humano, a linha dos pés e a mudança visual do porte.
Imagens: `creation-aligned-models.png` e `creation-build-comparison.png` em relatorios.


### Novo estilo heroi — artes específicas de criação e jogo

Os recursos ativos agora vêm de `assets/game/sprites/heroi/personagens.json`.
A criação usa os 30 arquivos de `heroi/criacao` (cinco raças, dois modelos,
três portes reais), com cabelos e barbas de `heroi/cabelos/frente` e
`heroi/barbas/frente`. A cena continua montada em Sprite2D editáveis em 2D,
sem animação, setas, armas ou armaduras. A prévia preserva a altura visual e o
ponto de apoio da montagem anterior. BaseMagro e BaseForte usam os desenhos
fornecidos; não usam mais o shader de deformação da silhueta.

No mundo e no inventário, os corpos vêm de `heroi/topdown/parado` e
`heroi/topdown/andando`, com seis quadros por direção e 9 fps. Cabelos e barbas
usam as versões topdown. As IDs de aparência e os saves continuam compatíveis.
As imagens fornecidas permanecem intactas. Os nós de personagens e acessórios
estão em `Margens/Colunas/Apresentacao/Personagem/Apoio/Modelos` na cena de criação.

Validação: 30 prévias com recursos corretos e ponto de apoio preservado em
`relatorios/creation-builds-test.log`; caminhadas, armas, escudos e fluxo do jogo
em `relatorios/new-design-test.log`. A imagem de comparação dos portes está em
`relatorios/creation-build-comparison.png`.
