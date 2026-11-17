# Nitidez dos textos ao reduzir a janela

As fontes Cinzel (SemiBold e Bold), Figtree, Noto Sans SC e Sora passam a gerar mipmaps na importação. O autoload `ManusFontTheme` aplica filtragem linear com mipmaps somente aos controles que desenham texto e aos menus suspensos. A aplicação após `_ready` impede que uma configuração herdada de um painel pixelado deixe o texto com nearest.

O projeto mantém oversampling automático das fontes. As famílias, pesos e tamanhos do layout continuam os mesmos. O filtro global dos sprites e o filtro explícito dos ícones continuam nearest. A documentação oficial do Godot descreve o uso de mipmaps para evitar granulação de fontes reduzidas: https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_fonts.html#mipmaps

Comparação visual da seleção em janelas de 1280×720, 1024×576 e 960×540, com capturas antes/depois em `.work/font-resize-*.png`. A redução física de resolução ainda limita a quantidade de detalhe visível em textos muito pequenos.

Validação: `verify_font_scaling.gd` (cinco fontes importadas, 47 controles, menus suspensos, painel com escala 0,65, acentos e ícones), `verify_selection_screen.gd` (295 ajustes de sprites preservados) e `verify_inventory_reference.gd` (ações e redimensionamento do inventário).
