# Armaduras em partes

As armaduras continuam sendo um único item de equipamento, com os mesmos atributos e salvamento. A aparência agora usa peças Sprite2D independentes, tanto no mundo quanto na prévia de equipamento.

Cada cena contém:

- **Elmo:** acessório de cabeça. Nos 100 conjuntos do catálogo, usa o elmo da prancha original. Começa oculto para preservar a aparência atual; marque `Visible` para usá-lo. O cabelo é ocultado automaticamente enquanto o elmo está visível. Os conjuntos básicos e de classe não tinham desenho de elmo e mantêm este Sprite2D vazio.
- **Peito:** torso, ombreiras e avambraços.
- **Luvas:** mãos e luvas. Conjuntos sem luvas desenhadas preservam as mãos originais.
- **Calca:** parte inferior até as botas.
- **Botas:** pés e botas.

## Editar visualmente

1. Abra uma cena em `catalogo/armadura_001.tscn` até `armadura_100.tscn`. Exemplo: `catalogo/armadura_038.tscn`.
2. Na área **2D**, selecione o Sprite2D da peça.
3. Ajuste `Transform > Position`, `Scale`, `Rotation` ou `Visible` e salve a cena.
4. Equipe o conjunto no jogo para conferir a montagem. Para ver alterações em uma sessão já aberta, reinicie a sessão.

Para **subir a armadura no personagem**, diminua o `Position Y` do nó **Peito**. As posições das peças são respeitadas pelo jogo. Ajustes da posição de Luvas também deslocam a arma e a mão que a segura; ajustes de Peito deslocam a posição do escudo.

As roupas básicas ficam em `basicos/<raca>_<genero>.tscn`, e os conjuntos por classe em `classes/<classe>/armadura_ng.tscn`, `armadura_d.tscn`, `armadura_c.tscn` e `armadura_b.tscn`.

`ReferenciaCabeca` ajuda a visualizar o alinhamento no editor e é ocultada durante o jogo. `Pele` preserva a cabeça original das bases carecas. Não são peças de equipamento. O sistema de criação de personagem mantém os tamanhos e posições anteriores.

## Arte e recortes

As peças reutilizam os pixels dos PNGs originais através de AtlasTexture e máscaras no material. Não houve redução de resolução nem alteração nos ícones do inventário. A divisão permite editar a montagem; áreas escondidas na ilustração original não são redesenhadas ao afastar uma peça ou misturar conjuntos.

Os limites de luvas, cintura e botas podem ser refinados nos parâmetros `armor_glove_a`, `armor_glove_b`, `armor_waist_y` e `armor_boots_y` dos materiais. São coordenadas normalizadas no quadro original de 256 × 512; mantenha os mesmos limites nos quatro materiais para evitar lacunas ou sobreposição.

`scripts/tools/prepare_armor_layers.gd` é a ferramenta de geração inicial. **Executá-la novamente sobrescreve as cenas e seus ajustes manuais.** O jogo carrega as cenas salvas e não executa essa ferramenta.
