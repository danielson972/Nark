# Painel de habilidades editável em 2D

Abra `res://scenes/ui/skills_panel.tscn` no Godot e selecione a aba **2D**.

- `Layout/Header`: título e botão de fechar.
- `Layout/Tabs`: botões Ativas e Passivas.
- `Layout/SkillsScroll/SkillsGrid`: cartões em duas colunas. Cada cartão tem `Content/Icon` e `Content/Text` com nome, nível e custo/recarga.
- `Layout/SelectedAbility`, `SelectedDescription` e `SelectedCost`: detalhes da seleção.
- `Layout/Actions`: adicionar à hotbar e usar livro.
- `Ornaments`: linhas 2D dos ornamentos. A moldura e as cores dos botões estão nos StyleBoxes dos respectivos nós, no Inspector.

Os ícones `EditorArt` servem de prévia no editor; durante o jogo o ícone corresponde à habilidade real da classe. Os cartões excedentes ficam ocultos e são reutilizados ao trocar as abas. A cena inclui 16 cartões, suficientes para todas as classes atuais. Para acrescentar mais, duplique um cartão completo e preserve a estrutura de seus filhos.

Preserve os nomes únicos dos controles conectados ao script. O script atualiza os dados e a seleção sem reconstruir o layout ou substituir os estilos definidos na cena. O painel mantém as regras existentes de desbloqueio, livros, limites de nível e hotbar.

`scripts/tools/prepare_skills_panel.gd` é uma ferramenta de criação inicial. **Não execute novamente após editar a cena**, pois ela sobrescreve o arquivo. Ela não é executada pelo jogo.

Verificação: `relatorios/verify_editable_skills.gd` valida as seis classes nos níveis 1 e 100, as duas abas, a reutilização dos nós editáveis, custos, bloqueios e ações, além do enquadramento em 1280×720, 800×600 e 640×360. A abertura e o fechamento também foram conferidos dentro da cena principal, com renderização das duas abas.
