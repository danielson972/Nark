# Montagem do personagem

Cena independente: `scenes/character_creation.tscn`. Também é aberta por **Iniciar** no menu principal.

Inclui Humano, Elfo, Orc e Anão, em modelos masculino e feminino, seis classes, nome, opção Careca, 16 cabelos e sete cores. Todo personagem novo começa com a opção Careca selecionada. Trocar raça, modelo ou classe preserva o nome e as escolhas de cabelo. O cabelo é cosmético e não altera atributos. O anão masculino conserva a barba da referência; careca descreve o couro cabeludo.

As bases `bald_races_source.png` e `bald_races_female_source.png` foram produzidas com a ferramenta integrada ImageGen a partir das referências enviadas. `hair_clean_source.png` adapta os modelos fornecidos sem os números das folhas de referência. Os prompts exatos estão em `generation.json`. As referências de cabelo permanecem preservadas. As folhas mantêm alfa transparente.

O script `scripts/tools/prepare_character_builder.gd` recorta margens e organiza as fontes em `bald_races.png` (quatro colunas, duas linhas; células 256×512) e `hair_models.png` (quatro por quatro). A primeira linha de corpos é masculina e a segunda feminina; ordem Humano, Elfo, Orc, Anão. `packing.json` registra os recortes; `hair_layout.gd` fornece os dados usados no jogo e é incluído automaticamente na exportação. Para regenerar, execute o script com Godot headless e reimporte as imagens no editor.

`character_customization.gd` define recortes e encaixes; `character_parts.gd` monta cabeça/cabelo sobre o corpo. Roupas básicas usam os novos corpos raciais. Armaduras usam os corpos de roupa existentes com cabeça racial independente; as peças de armadura são compartilhadas entre os modelos. Armas e mão sobre a empunhadura continuam separadas. Mundo, criação e inventário usam as mesmas funções de aparência.

Os encaixes de cabelo usam medidas de crânio próprias por raça/modelo e ajustes individuais por penteado. A preparação recorta a maior silhueta conectada de cada célula, descartando pontas de penteados da linha anterior. A máscara segue o contorno real da cabeça e dos ombros, sem sobrepor um retângulo de rosto que corte os cabelos longos. `relatorios/verify_hair_alignment.gd` verifica a cobertura do topo do crânio nas 128 combinações de raça, modelo e penteado.

Os campos `gender_id`, `hair_style` e `hair_color` são gravados em PlayerState. Saves antigos continuam carregando, com modelo masculino e cabelo Careca como padrões. O item Hero e os demais equipamentos permanecem compatíveis.

## Qualidade restaurada

O autoload e os shaders de ampliação artificial de pixels/redução de tons foram retirados. Colossal Aurora usa as folhas originais de idle e caminhada, sem material de pixelização. A velocidade e o ciclo de caminhada de 1,5 s foram preservados. Itens e roupas voltaram às fontes anteriores à revisão pixelada, incluindo `items_atlas.png` e `human_equipment_atlas_vibrant.png`. As novas bases e cabelos são exibidos com seus detalhes nativos. A câmera permanece no zoom 0,65.

Validação: `relatorios/verify_character_assembly.gd` (288 combinações e fluxo completo), `verify_original_art_quality.gd`, `verify_inventory_reference.gd`, `verify_hero_aura.gd`, `verify_aurora_walk.gd` e `verify_colossal_pursuit.gd`.
