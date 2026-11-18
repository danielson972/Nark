# Aparência de equipamentos

`hero_equipment_atlas.png` foi criado com ImageGen, usando os sprites anteriores
e o atlas de itens como referências visuais. O prompt completo está em
`generation-prompt.txt`. Os PNGs anteriores foram preservados.

A grade tem oito colunas e seis linhas. As linhas seguem Atirador, Mago,
Guerreiro, Assassino, Tank e Cavaleiro. As colunas são:

1. Sem armadura: camisa de baixo e calção simples, sem arma.
2. Roupa básica: túnica, calças e sapatos simples, sem arma.
3. Armadura NG da classe, sem arma.
4. Armadura D da classe, sem arma.
5. Armadura C da classe, sem arma.
6. Armadura B da classe, sem arma.
7. Ícone da arma de treino da classe.
8. Ícone da roupa básica.

`scripts/actors/hero_appearance.gd` seleciona a região do corpo, o ponto da mão
e o encaixe da arma. `Hero` renderiza a arma como um `Sprite2D` independente,
usando os ícones existentes ou a nova arma básica. A arma acompanha o espelhamento
horizontal, a ordem de desenho e o movimento do ataque básico. O shader
`shaders/equipment_cutout.gdshader` suprime o fundo translúcido dos ícones quando
usados no personagem, preservando os arquivos originais, a cor e os efeitos de
transparência do personagem.

As espadas usam encaixes individuais no cabo para Treino, NG, D, C e B. Esses
pontos também são usados pelo retrato e mantêm a empunhadura fixa à mão durante
o espelhamento e a rotação do ataque. Validação em `relatorios/verify_sword_grip.gd`.

O guerreiro também usa um ponto de palma calibrado por roupa/armadura e uma
camada `MaoSobreEmpunhadura`, acima da arma. Essa camada reutiliza o recorte
transparente dos dedos do próprio sprite, permitindo que a mão envolva o cabo
sem esconder a lâmina atrás do corpo. O mesmo recorte é usado no inventário.
Prévia ampliada em `relatorios/sword-hold-closeup.png`.

O material de cada espada recorta a extremidade do cabo que passaria da palma,
mantendo a guarda/lâmina à frente e os dedos por cima. O recorte usa as coordenadas
locais da região do atlas e acompanha a rotação e o espelhamento da arma. O
retrato do inventário usa o mesmo material.

## Efeitos das armas do Colosso

`arma_b` ativa brilho violeta pulsante, reflexo móvel e aura no shader, além de
faíscas e um rastro durante o golpe em `colossal_weapon_effect.gd`. Os efeitos
seguem a arma nas seis classes e são removidos ao desequipar ou substituir o
item. São visuais e não alteram dano ou atributos.

Validação em `relatorios/verify_colossal_effects.gd`: compara dois frames
renderizados para confirmar a animação, verifica as seis classes e a remoção dos
efeitos. Capturas em `relatorios/colossal-effects-a.png` e
`relatorios/colossal-effects-b.png`.

`hero_preview.gd` usa as mesmas fontes e encaixes no inventário e na criação
de personagens. Alterações em `PlayerState.equipment` feitas por `equip` e
`unequip` emitem `equipment_changed`; o herói atualiza atributos e aparência
imediatamente, inclusive com o inventário aberto.

Novos personagens recebem `roupa_basica` e `arma_basica`, já equipadas. Ambos
são itens reais: podem ser removidos, reequipados, guardados, recebidos no
arsenal, reparados e salvos. Sem arma, o ataque básico usa alcance corpo a corpo
de 52; habilidades de classe mantêm suas regras existentes. Sem armadura, o
personagem fica com roupa de baixo simples e sem bônus de equipamento.

Saves existentes mantêm os IDs e equipamentos que já tinham. Não há conversão
automática de armaduras antigas em roupa básica, nem perda de itens.

Validação: `relatorios/verify_equipment_visuals.gd` cobre 216 combinações de seis
classes, seis estados de armadura e seis estados de arma, além das ações reais
de equipar/remover no inventário, espelhamento e leitura de saves. A captura
`relatorios/equipment-visual-gallery.png` mostra os estados renderizados no Godot.

## Calibração por classe

Em `hero_appearance.gd`, `CLASS_HANDS` define a palma de cada classe,
`CLASS_GRIPS` define o encaixe de cada arma (Treino, NG, D, C, B), e
`CLASS_WEAPON_HEIGHTS` define a escala. O guerreiro mantém seus pontos por
roupa em `SWORD_HANDS` e por espada em `SWORD_GRIPS`. As coordenadas são
proporções da célula do atlas, de 0 a 1. Todas as classes usam o recorte da
própria mão sobre a empunhadura, no mundo e no retrato do inventário.
