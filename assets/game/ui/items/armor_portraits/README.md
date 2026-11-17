# Ícones de armaduras — peitorais transparentes

Foram criados **130 ícones** seguindo a referência do peitoral: 100 conjuntos do catálogo e 30 variações dos trajes de classe (roupa básica e graus NG, D, C e B para as seis classes).

As 13 pranchas PNG têm fundo RGBA transparente, sem molduras, textos ou fundos de raridade. Cada ícone tem um recurso AtlasTexture próprio em `icons/`, pronto para ser usado como textura no Godot. `icon_manifest.json` relaciona cada item à prancha, ao recorte e ao recurso correspondente. Os recortes são centralizados pela silhueta; os fundos de raridade são desenhados pelo slot durante o jogo.

## Arquivos

- `001-010.png` a `091-100.png`: dez peitorais por prancha, mantendo a ordem e a identidade dos conjuntos originais.
- `classes-atirador-mago.png`, `classes-guerreiro-assassino.png` e `classes-tank-cavaleiro.png`: cinco graus/roupas por classe, uma classe por linha.
- `icons/armadura_catalogo_001.tres` a `icons/armadura_catalogo_100.tres`: ícones individuais dos conjuntos.
- `icons/<classe>/roupa_basica.tres` e `icons/<classe>/armadura_<grau>.tres`: ícones individuais dos trajes de classe.
- `reference/peitoral.png`: referência fornecida pelo usuário, incluindo seu slot original; usada somente como referência de estilo.

## Geração e prompts

Modo utilizado: ferramenta integrada **imagegen**, com transparência solicitada na geração. Cada prancha foi gerada como uma textura independente, usando o peitoral enviado como referência principal e as pranchas originais como referências de identidade. Os prompts completos utilizados estão nos seguintes arquivos:

- [001-010.prompt.txt](001-010.prompt.txt)
- [011-020.prompt.txt](011-020.prompt.txt)
- [021-030.prompt.txt](021-030.prompt.txt)
- [031-040.prompt.txt](031-040.prompt.txt)
- [041-050.prompt.txt](041-050.prompt.txt)
- [051-060.prompt.txt](051-060.prompt.txt)
- [061-070.prompt.txt](061-070.prompt.txt)
- [071-080.prompt.txt](071-080.prompt.txt)
- [081-090.prompt.txt](081-090.prompt.txt)
- [091-100.prompt.txt](091-100.prompt.txt)
- [classes-atirador-mago.prompt.txt](classes-atirador-mago.prompt.txt)
- [classes-guerreiro-assassino.prompt.txt](classes-guerreiro-assassino.prompt.txt)
- [classes-tank-cavaleiro.prompt.txt](classes-tank-cavaleiro.prompt.txt)

## Uso no projeto

`scripts/ui/armor_portrait_catalog.gd` escolhe o ícone do item/classe. `ItemCatalog.icon_texture_for` usa essa arte nas interfaces; as texturas vestidas pelo personagem continuam separadas. Os slots preservam as cores dinâmicas de raridade, incluindo os graus A e S. O filtro de redução usa mipmaps para manter contornos legíveis em ícones pequenos.

As pranchas originais geradas foram preservadas em resolução completa. A importação no Godot usa limite de 1024 pixels por prancha para reduzir memória, mantendo detalhe suficiente para os ícones de inventário. Ao mudar esse limite, execute `scripts/tools/prepare_armor_portraits.gd` para recalcular os recortes sobre as dimensões importadas. Essa ferramenta regrava os recursos de ícones e o manifesto; não altera os pixels das pranchas.

Validação: `relatorios/verify_armor_portraits.gd` confere os 130 ícones, transparência, enquadramento compacto, variantes de classe e fluxo real de equipamento. `relatorios/preview_armor_portraits.gd` renderiza a comparação sobre fundos verde, azul, roxo e dourado, além do inventário real.
