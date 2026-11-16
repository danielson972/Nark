# Acabamento pixel art

**Histórico:** esta revisão foi desativada a pedido do usuário. O tratamento global e os shaders de redução de detalhe foram retirados; as artes anteriores voltaram a ser usadas. O estado atual da personalização está documentado em `assets/game/character_builder/README.md`. As imagens desta pasta ficam preservadas como versões anteriores.

Referências enviadas: `style_human.png` e `style_elf.png`. A direção visual usa contornos em degraus, sombras em blocos e cores naturais um pouco vivas.

Artes editadas com a ferramenta integrada ImageGen: `items_pixel.png` (itens, grade 8×8), `shared_equipment_pixel.png` (roupas e armas compartilhadas, grade 8×6) e as três folhas `outfits_*_pixel.png` (24 roupas humanas, quatro colunas e duas linhas por folha). Os prompts exatos estão em `generation.json`. As folhas preservam a ordem das células para manter os equipamentos existentes.

A base humana usa a nova referência. `scripts/tools/prepare_human_appearance.gd` monta `assets/game/sprites/herois/humano/human_equipment_atlas_pixel.png`, com seis classes por seis aparências. As fontes anteriores continuam preservadas.

O autoload `PixelArtStyle` aplica nearest, amostragem em blocos e redução de tons aos sprites de monstros, cenário, tiles e efeitos, inclusive aos criados durante o jogo. Essa parte é um tratamento de renderização das artes existentes. Materiais de corpo, armas e aura compartilham o acabamento e preservam seus efeitos próprios. Ícones de itens e habilidades também recebem o tratamento. Textos mantêm sua renderização normal.

A grade acompanha o recorte de cada quadro animado para evitar vazamento entre células. Velocidade, relógio das animações, colisões, atributos e saves continuam com as mesmas regras.

Validação: `relatorios/verify_pixel_art_style.gd`, `verify_human_appearance.gd`, `verify_equipment_visuals.gd`, `verify_inventory_reference.gd`, `verify_aurora_walk.gd` e `verify_hero_aura.gd`.
