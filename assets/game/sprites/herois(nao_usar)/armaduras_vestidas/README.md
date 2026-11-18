# Armaduras vestidas

100 sprites completos: `armadura_001.png` a `armadura_100.png`.
Cada PNG possui 256 x 512 pixels, transparência e os pés alinhados em y=502.
Os IDs correspondem ao campo `catalog_art` do catálogo (Armaduras_RPG/Sets.json).

Os sprites 022, 039 e 040 aprovados anteriormente foram preservados.
Os demais foram desenhados como personagens completos em dez pranchas `source_sheet_*.png`.
As pranchas usam cinco colunas e duas linhas, com numeração da esquerda para a direita.
Não são as antigas peças soltas do catálogo sobrepostas ao corpo.

`worn_layout.gd` contém o ponto de empunhadura de cada nova imagem.
`hero_appearance.gd` carrega diretamente o PNG correspondente ao item equipado.
Armaduras básicas fora do catálogo mantêm os sprites anteriores.

Reproduzir o empacotamento: executar `scripts/tools/pack_all_worn_armor.gd` no Godot.
O empacotador preserva arquivos individuais existentes.
Fontes PNG mantidas para permitir revisar os desenhos sem perder o histórico.
