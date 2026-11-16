# Ícones de equipamentos e itens

`items_atlas.png` foi gerado com a ferramenta integrada ImageGen, usando o atlas
de skills como referência visual. O prompt completo está em `generation-prompt.txt`.
A imagem tem transparência e uma grade de oito colunas por oito linhas.

As seis primeiras linhas são Atirador, Mago, Guerreiro, Assassino, Tank e Cavaleiro.
Em cada linha, as quatro primeiras colunas são armas NG, D, C e B; as quatro
últimas são armaduras das mesmas grades. Cada classe tem silhuetas próprias:
arcos e gibões, cajados e mantos, espadas e couraças, adagas e trajes furtivos,
maças/martelos e armaduras pesadas, lanças e armaduras de cavaleiro.

A sétima linha contém presa de lobo, gosma, sucata de ferro, cristal de Aurora,
carapaça branca, essência errante, selo de entrada e livro de skill.
A oitava contém poção de cura, anel de cobre, anel de prata e cinco artes extras:
bolsa de moedas e quatro escudos. Os extras são apenas imagens disponíveis no
catálogo; não acrescentam itens nem slots ao jogo.

`scripts/ui/item_catalog.gd` relaciona os IDs às células. As regiões são calculadas
pela dimensão real da imagem, sem recortar ou modificar o arquivo original.
Os 19 itens originais estão cobertos, incluindo quatro grades de armas e armaduras
para as seis classes: 59 imagens utilizadas e cinco extras, totalizando 64.

Roupa Básica e Arma de Treino também estão disponíveis: seus 12 ícones por
classe vêm da folha `assets/game/sprites/herois/compartilhados/equipamentos/hero_equipment_atlas.png`.
O catálogo cobre, portanto, os 21 itens atuais em 71 regiões de arte.

Os equipamentos mantêm os IDs, nomes e atributos atuais. A classe do personagem
define sua aparência no inventário, detalhes, baú, forja e arsenal da sala secreta.
A arte original de skills permanece intacta. Slots vazios e itens futuros sem arte
usam os desenhos anteriores como alternativa.

Validação: `relatorios/verify_item_art.gd`; captura do inventário e prévia das
64 células em `relatorios/item-art-inventory.png` e `relatorios/item-art-gallery.png`.
