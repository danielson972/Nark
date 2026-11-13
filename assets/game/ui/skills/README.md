# Ícones de habilidades

`skills_atlas.png` é a folha original enviada pelo usuário, preservada com transparência.

A textura usa seis colunas e sete linhas. As seis primeiras linhas correspondem, nesta ordem, a Atirador, Mago, Guerreiro, Assassino, Tank e Cavaleiro. A última contém os bônus de HP, velocidade, resistência, Explosão de Aura e Despertar Heroico.

As coordenadas e os IDs estão em `scripts/ui/skill_catalog.gd`. O Godot lê cada região do atlas diretamente, sem alterar a imagem. Os ícones são usados no painel de skills, nos detalhes, na hotbar e na descrição de hover.

HP, velocidade e resistência representam os bônus de grade já existentes. A adaptação visual não altera o balanceamento nem adiciona habilidades aprendidas ao personagem.
