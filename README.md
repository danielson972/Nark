# Nark — Floresta Terrain

Abra project.godot e pressione F5. Cena principal: Scenes/floresta.tscn.

O cenário usa exclusivamente Assets/Environment/forest/Terrain.png como textura: solo e trilha em TileMapLayer, clareira, moitas e árvores estilizadas compostas com recortes de grama do atlas. O asset contém terrenos, não sprites de árvores; os troncos são polígonos e as copas são recortes sobrepostos. Grama e folhas caídas são detalhes desenhados em pixels pelo script detalhes_solo.gd.

Visual: resolução interna 640 × 360, ampliação inteira e filtro nearest. WASD/setas movem a câmera, botão direito arrasta, roda muda o zoom e Home centraliza. Sem personagem ou colisões de jogo.

Reconstrução: godot --headless --path . --script Tools/build_forest.gd. Este comando substitui a cena e suas edições manuais.

Importação, execução e renderização verificadas no Godot 4.7.1 disponível. A versão 4.7.2 não está instalada para teste.
