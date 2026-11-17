# Inventário e status — imagem de fundo

A imagem original está em `res://assets/game/ui/inventory/equipment_inventory_gold.png`. Ela é carregada como textura em `ReferenceBackground` de cada painel. As regiões esquerda e direita são recursos AtlasTexture independentes. A imagem original permanece intacta; as regiões das duas metades usam sua altura completa.

A camada `ClearExampleContent` cobre os itens, personagem e números fixos da imagem. Os nós interativos acima dela exibem o estado real do jogador. Os espaços vazios usam uma região vazia da própria imagem como acabamento. Uma base opaca impede que os rótulos fixos apareçam através da transparência da textura.

Abra estas cenas na aba **2D** do Godot:

- `res://scenes/ui/equipment_panels.tscn`: montagem dos painéis lado a lado.
- `res://scenes/ui/equipment_status_panel.tscn`: fundo, slots, prévia, identidade e atributos.
- `res://scenes/ui/inventory_panel.tscn`: fundo, seis abas, slots, detalhes, botões e peso.

Os scripts preenchem os controles existentes, sem recriar o layout ao abrir ou trocar abas. Preserve os nomes únicos dos nós conectados aos scripts. É possível mover ou redimensionar a área de prévia sem modificar os sprites da montagem de personagem.

**I** abre ambos; **T** abre ou alterna o painel de status. Fechar o inventário fecha também o status e retoma o jogo. O status não tem botão para abrir o inventário. Fechar somente o status mantém o inventário aberto. As ações dos itens preservam quais painéis estão visíveis. O atalho padrão antigo C é migrado uma vez para T nas configurações anteriores; remapeamentos posteriores continuam disponíveis.

A ferramenta `scripts/tools/prepare_reference_panels.gd` criou as cenas iniciais. Não a execute após fazer alterações visuais, pois ela sobrescreve os arquivos. O jogo carrega as cenas salvas diretamente.

Verificações realizadas: referência original nas duas texturas, catálogo completo acessível, seis filtros, preservação dos nós ao filtrar, ações dos itens, slot Hero, duplo clique, abertura/fechamento independente, atalho e enquadramento em 1280×720, 960×540 e 640×360. A renderização foi conferida dentro do jogo, incluindo a janela de detalhes.
