# Armaduras em partes

As cenas usam Sprite2D editáveis no mundo e no inventário. O traje completo
continua disponível; a Sala Secreta também oferece peças equipáveis individuais.

## Imagens separadas

As partes Peito, Luvas, Calca e Botas possuem PNGs transparentes próprios em
`assets/game/sprites/herois/partes_armaduras/`. São 528 imagens para os 100 conjuntos
do catálogo, 24 trajes de classe e oito bases de raça e sexo. Todas usam uma tela
de 256 × 512, com os mesmos pontos de referência. Os elmos continuam separados
nas cenas e usam a arte das pranchas do catálogo.

Os recortes preservam os pixels das fontes originais. As mãos usam máscaras
próprias, sem incluir a túnica. A transparência e pequenas margens nas junções
são gravadas nos PNGs; o material não divide mais essas quatro partes durante
a renderização. `Pele` preserva a cabeça das bases; `ReferenciaCabeca` é uma guia
oculta durante o jogo. As áreas ocultas na ilustração original não são redesenhadas.

## Editar no Godot

Abra `catalogo/armadura_001.tscn` a `armadura_100.tscn`, uma cena em
`basicos/<raca>_<genero>.tscn` ou `classes/<classe>/armadura_*.tscn`.
Selecione o Sprite2D e ajuste posição, escala ou rotação. As quatro imagens
partem da mesma origem. O elmo acompanha a cabeça; sua visibilidade oculta o cabelo.
Reinicie a sessão de jogo para carregar alterações da cena.

O peitoral equipado define a referência do corpo. Peças do mesmo conjunto
mantêm a montagem original; combinações alinham cintura, tornozelos e punhos.
As mãos são escaladas uniformemente. Sem peitoral independente, o traje de base
continua definindo o corpo. Luvas deslocadas movem a empunhadura; o Peito move o escudo.

## Sala Secreta

Na bancada **Peças de armadura**, escolha um dos 100 conjuntos, em ordem numérica.
Cada um oferece Elmo, Peitoral, Luvas, Calça e Botas. Dê duplo clique para equipar.
**Ctrl + I** abre o inventário de peças apenas na Sala Secreta. Ele inclui as
partes, arma, escudo, anel, colar, talismã e Hero. **I** mantém o inventário normal.
O progresso da Sala Secreta continua temporário.

## Ferramentas e verificações

- `scripts/tools/rebuild_armor_part_images.py`: refaz os PNGs a partir das fontes e
  máscaras salvas, preservando deslocamentos manuais nas cenas.
- `scripts/tools/check_armor_crop_coverage.py`: verifica a cobertura dos pixels
  visíveis nas 132 roupas e a separação entre luva e túnica.
- `scripts/tools/check_armor_parts_fit.tscn`: confere os conjuntos e a montagem
  no inventário e no mundo; `--basic` mostra bases e combinações parciais.
- `scripts/tools/check_armor_parts_shop.tscn`: testa loja, ícones, equipamento,
  salvamento e o atalho exclusivo da Sala Secreta.

`prepare_armor_layers.gd` é o gerador inicial de cenas e **sobrescreve ajustes
manuais**. Se ele for usado, execute depois `rebuild_armor_part_images.py` para
restaurar as imagens separadas. O jogo não executa esses geradores.
