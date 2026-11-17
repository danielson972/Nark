# Qualidade do personagem no mapa

As artes de corpo e cabeça são grandes em relação ao tamanho exibido pelo herói (92 unidades de altura, com zoom 0,65). Amostrar um único texel nessa redução fazia detalhes e bordas aparecerem de forma irregular, especialmente em mãos, botas, roupa e lâmina.

Os materiais do herói no mundo agora calculam a cobertura de cada pixel da tela com 16 amostras da imagem original. A transparência residual da fonte é removida antes da combinação, evitando halos do fundo. Uma parcela pequena do detalhe central mantém o contraste. A grade adicional usada no recorte da cabeça é ignorada nesse modo, evitando uma segunda redução antes da exibição no mapa.

O tratamento cobre corpo, mão sobre a arma, cabeça, cabelo, barba, orelhas e presas. As amostras ficam limitadas ao recorte correspondente do atlas. Corpo e armas usam cópias de material específicas para o mundo, sem alterar os materiais compartilhados pela criação e pelo inventário. As folhas originais, os Sprite2D da seleção, o tamanho físico do herói, o zoom da câmera e as regras de animação/combate não foram modificados. O Colossal e os outros inimigos mantêm sua renderização.

Comparações: `.work/hero-world-before.png`, `.work/hero-world-after.png` e seus recortes ampliados `hero-world-detail-*.png`. A ampliação serve apenas para inspeção dos pixels; o jogo continua com o tamanho anterior.

Validação: `verify_world_hero_rendering.gd` (144 combinações de raça/modelo/classe/roupa, materiais isolados, partes espelhadas e tamanho/câmera preservados), `verify_selection_screen.gd`, `verify_beards_and_dwarf.gd` e `verify_equipment_visuals.gd`. Compilação e comparação visual feitas no renderizador OpenGL Compatibility do projeto.
