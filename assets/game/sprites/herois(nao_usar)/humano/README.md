# Nova aparência da raça Humano

**Revisão ativa:** as armaduras usam `human_equipment_atlas_vibrant.png`, com cabeça racial e cabelo independentes. Os corpos básicos masculinos e femininos estão em `assets/game/character_builder/`, cujo README descreve a montagem atual. A revisão `human_equipment_atlas_pixel.png` foi desativada, restaurando o detalhe anterior. As versões e a documentação abaixo ficam preservadas como histórico.

`human_reference.png` preserva integralmente a imagem enviada pelo usuário. A versão ativa `human_reference_vibrant.png` é sua edição de cor, solicitada depois: linho mais claro, calças oliva mais vivas e couro mais quente, em uma paleta de fantasia natural, sem o tom sombrio. As colunas base e roupa básica usam essa versão com recorte de margem transparente e redução nearest para caber no jogo. A camisa de linho, calças e botas permanecem como aparência de base mesmo sem armadura; bônus e durabilidade continuam dependendo exclusivamente do equipamento.

As 24 variações de armadura foram produzidas com a ferramenta integrada ImageGen, seguindo o rosto, cabelo castanho, proporções adultas e pose voltada à esquerda. As fontes ativas têm o sufixo `_vibrant.png`, com tecidos, couros e detalhes coloridos um pouco mais claros e saturados. As fontes anteriores foram preservadas. Não há armas incorporadas no corpo. Os prompts iniciais ficam em `generation.json`; os prompts exatos da edição de cor ficam em `color_generation.json`.

`human_equipment_atlas_vibrant.png` é a folha ativa: 1536×3072, grade de seis colunas por seis linhas, células de 256×512. Linhas: Atirador, Mago, Guerreiro, Assassino, Tank, Cavaleiro. Colunas: base, roupa básica, NG, D, C, B. Pés alinhados em y=502; altura visual no mundo preservada em 92 pixels. A folha anterior `human_equipment_atlas.png` foi preservada.

`scripts/tools/prepare_human_appearance.gd` prepara o atlas a partir das quatro fontes. Para regenerar: `godot --headless --path . --script scripts/tools/prepare_human_appearance.gd`, seguido da reimportação no editor.

`hero_appearance.gd` seleciona este atlas somente para `race_id == humano`, inclusive nos saves existentes e nos retratos de criação/inventário. As demais raças mantêm as fontes anteriores. Armas continuam independentes, com a mão recalibrada para o novo corpo. O patch de dedos usa uma chave de cache com o atlas para não misturar imagens entre raças. A orientação horizontal acompanha a pose original voltada à esquerda. O brilho Hero foi reposicionado sobre o peito do novo humano.

Movimentação, combate, equipamentos, atributos e formato dos saves foram preservados. A animação continua usando o movimento corporal já existente no jogo; esta substituição não acrescenta uma folha de caminhada de pernas independente.

Validações: `relatorios/verify_human_appearance.gd` (144 combinações de raça/classe/armadura), `relatorios/verify_equipment_visuals.gd` (216 combinações de equipamento) e `relatorios/verify_hero_aura.gd`.
