# Seleção no pátio de Aurora

A cena `scenes/character_creation.tscn` adapta a referência enviada: fundo de ruínas e vegetação, pedestal central, molduras escuras/douradas nas laterais, identidade à esquerda, aparência à direita e ações abaixo do personagem.

`ruins_background.png` foi criado com a ferramenta integrada ImageGen, sem personagem nem interface incorporados. O prompt exato está em `generation.json`. Painéis, campos, paleta e botões são controles reais do Godot; as molduras são desenhadas por `scripts/ui/selection_frame.gd`.

As quatro raças, seis classes, modelos masculino/feminino, cabelos, cores e barbas existentes foram mantidos. A referência visual não acrescenta raças ou rostos fictícios à lista. A paleta seleciona a cor do cabelo; a barba mantém seu seletor de cor independente.

Todos os ajustes locais dos 295 Sprite2D com textura foram preservados: posição, escala, rotação e offset. A cena só desloca os grupos `Cabelos` e `Barbas` juntos para colocar os pés no pedestal. Não ajusta o tamanho dos sprites nem reposiciona cabelos ou barbas individualmente. `relatorios/selection_sprite_baseline.gd` registra as configurações anteriores para verificar essa exigência.

Os sprites continuam editáveis na cena. A instância `Barbas` permite editar os filhos. Os painéis têm rolagem interna caso o conteúdo precise de mais espaço, e o fundo acompanha a área da janela.

`scripts/tools/adapt_character_selection.gd` construiu o novo layout reutilizando os controles e sprites existentes. Validações: `relatorios/verify_selection_screen.gd`, `verify_creation_editor_match.gd` e `verify_beards_and_dwarf.gd`. O fluxo de criar, voltar, salvar e mostrar a aparência no inventário continua integrado ao jogo.
