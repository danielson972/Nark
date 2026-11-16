# Organização dos sprites

- `herois/compartilhados/` — seis classes, também reutilizadas por NPCs e pela Sombra de Kael.
- `herois/compartilhados/equipamentos/` — atlas de corpos, armaduras e equipamentos dos heróis.
- `colossos/<regiao>/` — chefes Colossais. Granito pertence a Aurora.
- `monstros/<regiao>/` — inimigos comuns. O Errante reutiliza o sprite do lobo.
- `miniboss/<regiao>/` — minibosses. A Fera de Carapaça Branca pertence a Aurora.
- `cenarios/<regiao>/` — objetos e serviços do mapa. A sala dos desenvolvedores reutiliza os objetos de Aurora.
- `interface/` — ilustrações da tela de título.

As pastas usam os mesmos identificadores de `GameData.REGIONS`.

| Pasta | Região |
| --- | --- |
| `aurora` | Vale de Aurora |
| `vespera` | Bosque de Véspera |
| `sal` | Pântano de Sal |
| `ambar` | Costa do Âmbar |
| `cinzas` | Deserto de Cinzas |
| `gelidos` | Picos Gélidos |
| `oren` | Ruínas de Oren |
| `dourada` | Planície Dourada |
| `mare` | Cais de Maré Alta |

Atualmente só Aurora possui sprites regionais. As demais pastas estão reservadas
com `.gitkeep` para receber as artes quando essas regiões forem desenvolvidas.
Recursos compartilhados mantêm uma única imagem, referenciada pelos consumidores.
