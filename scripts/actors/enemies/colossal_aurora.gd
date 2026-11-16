# Herda os atributos e comportamentos gerais da classe Enemy.
extends Enemy

# Agrupa os atributos usados pelo catálogo para configurar este Colossal.
const CONFIG = {
	"level": 25,
	# Define o nome exibido, o arquivo da imagem e a altura de referência em pixels.
	"name": "Colossal de Granito", "sprite": "res://assets/game/sprites/colossos/aurora/boss_colossal.png", "height": 196.0, 
	# Define vida, dano, defesa, velocidade, experiência concedida e categoria de poder.
	"hp": 2600.0, "damage": 34.0, "defense": 24.0, "speed": 96.0, "xp": 3500, "tier": 4, 
	# Define moedas mínimas/máximas, alcance de percepção, alcance de ataque, recarga e preparação em segundos.
	"coins": [700, 1100], "aggro": 900.0, "attack_range": 170.0, "attack_cd": 2.4, "windup": 0.9, 
	# Define as chances de itens (1 = 100%), o raio de colisão e a identificação como Colossal.
	"drops": {"cristal_aurora": 1.0, "carapaca_branca": 0.5}, "radius": 62.0, "kind": "colossal", 
	# Habilita os tratamentos de miniboss e chefe no sistema de inimigos.
	"miniboss": true, "boss": true, 
# Encerra o dicionário de configuração.
}

# Distância em pixels que desperta o Colossal; pode ser editada no Inspector.
@export var wake_distance: float = 220.0
# Indica se o Colossal já despertou.
var awakened: bool = false
# Distância mínima em pixels examinada à frente; editável no Inspector.
@export var obstacle_lookahead: float = 100.0
# Guarda o lado preferido do desvio: 1 ou -1.
var avoidance_side: float = 1.0

# Nome exibido da habilidade que substitui a antiga invocação de gosmas.
const SUMMON_SKILL_NAME: String = "Invocar"
# Garante Invocar no primeiro ataque e após três outros ataques.
var attacks_until_invocar: int = 0


func _summon_golems() -> void:
	# Procura posições livres para os dois golens, sem sobrepor o chefe ou objetos.
	var created: int = 0
	for ring in range(1, 5):
		for slot in 16:
			var angle: float = TAU * float(slot) / 16.0
			var point: Vector2 = global_position + Vector2.from_angle(angle) * (80.0 + 48.0 * ring)
			if not world.can_stand(point, 18.0) or not world.can_actor_stand(self, point, 18.0):
				continue
			var golem = world.spawn_enemy("golem_pedra", point)
			golem.summoned = true
			golem.ai_state = "chase"
			created += 1
			if created == 2:
				return


# Define o tipo do inimigo assim que a instância é criada.
func _init() -> void:
	# Identifica esta instância como colossal para o catálogo de inimigos.
	type_id = "colossal"


# Inicializa o Colossal com o mundo, o tipo e a posição de nascimento.
func setup_enemy(world_ref: Node, enemy_type: String, spawn: Vector2) -> void:
	# Reinicia o Colossal no estado adormecido.
	awakened = false
	# Reinicia a sequência para que o primeiro ataque seja Invocar.
	attacks_until_invocar = 0
	# Reinicia a preferência pelo lado positivo de rotação.
	avoidance_side = 1.0
	# Aplica a configuração geral do inimigo na classe base.
	super.setup_enemy(world_ref, enemy_type, spawn)
	# Zera a velocidade para manter o Colossal parado.
	velocity = Vector2.ZERO


# Decide se o Colossal deve iniciar a perseguição.
func _can_aggro(distance: float, _aggro: float) -> bool:
	# Desperta quando o herói entra no alcance de proximidade configurado.
	if distance <= wake_distance:
		# Marca o Colossal como desperto, liberando a perseguição.
		awakened = true
	# Permite iniciar o combate apenas se o Colossal estiver desperto.
	return awakened


# Controla o movimento ocioso, mantendo o Colossal adormecido parado.
func _wander(delta: float) -> void:
	# Impede o movimento ocioso enquanto o Colossal estiver adormecido.
	if not awakened:
		# Zera a velocidade para manter o Colossal parado.
		velocity = Vector2.ZERO
		# Encerra esta chamada para não executar as etapas seguintes da função.
		return
	# Usa o movimento ocioso padrão depois de despertar.
	super._wander(delta)


# Aplica o dano e desperta o Colossal somente se ele perder vida e sobreviver.
func take_damage(amount: float, opts: Dictionary = {}) -> Dictionary:
	# Guarda a vida anterior ao golpe para verificar se houve dano real.
	var previous_hp: float = hp
	# Guarda o resultado do tratamento de dano herdado de Enemy.
	var result: Dictionary = super.take_damage(amount, opts)
	# Confirma que o golpe reduziu a vida e não matou o Colossal.
	if hp < previous_hp and not dead:
		# Marca o Colossal como desperto, liberando a perseguição.
		awakened = true
	# Devolve as informações do dano ao código que aplicou o golpe.
	return result


# Verifica se o trajeto comporta o corpo do Colossal, ignorando o herói no desvio.
func _path_is_clear(direction: Vector2, distance: float) -> bool:
	# Divide a distância em trechos de até 12 pixels, com pelo menos um trecho.
	var steps: int = maxi(1, ceili(distance / 12.0))
	# Percorre os pontos de teste ao longo de todo o trajeto.
	for index in range(1, steps + 1):
		# Calcula a posição intermediária do trajeto que será testada.
		var point: Vector2 = global_position + direction * distance * float(index) / float(steps)
		# Rejeita terreno bloqueado ou colisões com objetos e inimigos, ignorando o herói apenas nesta consulta.
		if not world.can_stand(point, radius) or not world.can_actor_stand(self, point, radius, true):
			# Informa que existe um bloqueio no trajeto.
			return false
	# Informa que todos os pontos examinados estão livres.
	return true


# Escolhe uma velocidade de movimento que contorne os obstáculos detectados.
func _avoid_obstacles(desired: Vector2, delta: float) -> Vector2:
	# Obtém a intensidade da velocidade desejada.
	var speed: float = desired.length()
	# Dispensa o desvio quando não há movimento significativo ou mundo disponível.
	if speed < 1.0 or world == null:
		# Mantém a velocidade originalmente desejada.
		return desired
	# Obtém a direção do movimento sem o valor da velocidade.
	var direction: Vector2 = desired / speed
	# Examina pelo menos o alcance configurado ou o deslocamento deste quadro.
	var probe: float = maxf(obstacle_lookahead, speed * delta)
	# Verifica se é possível seguir diretamente para o herói.
	if _path_is_clear(direction, probe):
		# Mantém a velocidade originalmente desejada.
		return desired
	# Testa primeiro o lado usado no último desvio e depois o lado oposto.
	for side in [avoidance_side, -avoidance_side]:
		# Testa desvios progressivos entre 25 e 180 graus em relação ao alvo.
		for angle in [25.0, 50.0, 75.0, 100.0, 125.0, 150.0, 180.0]:
			# Gira a direção desejada pelo ângulo e pelo lado que estão sendo testados.
			var candidate: Vector2 = direction.rotated(deg_to_rad(angle) * side)
			# Confirma que a direção alternativa está livre até o alcance examinado.
			if _path_is_clear(candidate, probe):
				# Memoriza o lado em que foi encontrado um caminho livre.
				avoidance_side = side
				# Segue a direção alternativa preservando a velocidade de movimento.
				return candidate * speed
	# Para o Colossal quando nenhuma direção testada está livre.
	return Vector2.ZERO


# Controla as fases, a preparação dos ataques e a perseguição do chefe.
func _boss_logic(delta: float, hero, distance: float) -> void :
	# Verifica se a vida está abaixo de metade da vida máxima.
	var phase_two: = hp < max_hp * 0.5
	# Executa a transição de fase apenas uma vez ao cair abaixo de metade da vida.
	if phase_two and phase == 1:
		# Registra a entrada na segunda fase do combate.
		phase = 2
		# Exibe ao jogador o aviso de entrada na segunda fase.
		world.show_notice("O Colossal desperta seu núcleo!", Color(0.6, 0.85, 1.0))
		# Aplica tremor à câmera com a intensidade indicada.
		world.shake(10.0)
		# A entrada da segunda fase também usa Invocar para criar dois golens.
		_summon_golems()
	# Lê a velocidade configurada e aumenta em 25% na segunda fase.
	var speed: = float(definition.get("speed", 96.0)) * (1.25 if phase_two else 1.0)
	# Trata a recuperação após o ataque de varredura.
	if action == "sweep_recover":
		# Zera a velocidade para manter o Colossal parado.
		velocity = Vector2.ZERO
		# Encerra a recuperação depois de 1,5 segundo.
		if action_time > 1.5:
			# Limpa a ação atual, permitindo que outra seja escolhida.
			action = ""
			# Reinicia o tempo decorrido da ação.
			action_time = 0.0
			# Encerra o estado de vulnerabilidade adicional.
			exposed = 0.0
		# Solicita a atualização dos indicadores visuais desenhados pelo inimigo.
		queue_redraw()
		# Encerra esta chamada para não executar as etapas seguintes da função.
		return
	# Permite escolher um ataque quando a recarga acaba e o herói está a menos de 720 pixels.
	if attack_timer <= 0.0 and distance < 720.0:
		# Sorteia um dos três ataques iniciais ou dos quatro disponíveis na segunda fase.
		# Invocar funciona nas duas fases e não depende de um sorteio para aparecer.
		var pattern: int = 3 if attacks_until_invocar == 0 else randi() % 3
		# Prefere pedras quando o herói está longe, exceto se foi sorteada a invocação.
		if distance > 260.0 and pattern != 3:
			# Seleciona o lançamento de pedras.
			pattern = 2
		# Reinicia a recarga, reduzindo sua duração em 20% na segunda fase.
		attack_timer = float(definition.get("attack_cd", 2.4)) * (0.8 if phase_two else 1.0)
		# Alterna a invocação com três ataques normais.
		attacks_until_invocar = 3 if pattern == 3 else attacks_until_invocar - 1
		# Escolhe a preparação correspondente ao ataque sorteado.
		match pattern:
			# Prepara o ataque de impacto no chão.
			0:
				# Define o impacto no chão como ação atual.
				action = "slam"
				# Reinicia o tempo decorrido da ação.
				action_time = 0.0
				# Define a duração de referência da ação em 1.3 segundo(s).
				action_total = 1.3
				# Define a espera de 1.1 segundo(s) antes de executar o ataque.
				windup_left = 1.1
			# Prepara o ataque de varredura frontal.
			1:
				# Define a varredura frontal como ação atual.
				action = "sweep"
				# Reinicia o tempo decorrido da ação.
				action_time = 0.0
				# Define a duração de referência da ação em 1.25 segundo(s).
				action_total = 1.25
				# Define a espera de 0.95 segundo(s) antes de executar o ataque.
				windup_left = 0.95
				# Orienta a frente do Colossal para a posição atual do herói.
				facing = (hero.global_position - global_position).normalized()
			# Prepara o lançamento de pedras.
			2:
				# Define o lançamento de pedras como ação atual.
				action = "rocks"
				# Reinicia o tempo decorrido da ação.
				action_time = 0.0
				# Define a duração de referência da ação em 1.4 segundo(s).
				action_total = 1.4
				# Define a espera de 0.7 segundo(s) antes de executar o ataque.
				windup_left = 0.7
			# Trata qualquer opção que não corresponde aos casos anteriores.
			_:
				# Prepara a habilidade Invocar e apresenta seu nome ao jogador.
				action = "invocar"
				world.show_notice("%s: %s" % [display_name(), SUMMON_SKILL_NAME], Color(0.6, 0.85, 1.0))
				# Reinicia o tempo decorrido da ação.
				action_time = 0.0
				# Define a duração de referência da ação em 1.6 segundo(s).
				action_total = 1.6
				# Define a espera de 1.2 segundo(s) antes de executar o ataque.
				windup_left = 1.2
		# Solicita a atualização dos indicadores visuais desenhados pelo inimigo.
		queue_redraw()
		# Encerra esta chamada para não executar as etapas seguintes da função.
		return
	# Persegue enquanto estiver além de 80% do alcance de ataque configurado.
	if distance > float(definition.get("attack_range", 170.0)) * 0.8:
		# Calcula a velocidade desejada em direção ao herói.
		var desired: Vector2 = (hero.global_position - global_position).normalized() * speed
		# Move o Colossal usando a direção calculada para contornar os obstáculos.
		move_desired(_avoid_obstacles(desired, delta), delta)
	# Executa a alternativa quando a condição anterior não é atendida.
	else:
		# Interrompe o deslocamento quando já está perto o suficiente do herói.
		move_desired(Vector2.ZERO, delta)


# Executa o ataque preparado quando o tempo de preparação termina.
func _boss_release(hero) -> void :
	# Executa o efeito correspondente à ação preparada.
	match action:
		# Executa o impacto no chão.
		"slam":
			# Guarda a posição atual do herói como alvo do impacto.
			var target: Vector2 = hero.global_position
			# Cria um impacto de área no alvo, com raio de 165 pixels, dano 42 e a cor indicada.
			world.spawn_area_burst(target, 165.0, 42.0, Color(0.85, 0.55, 0.3), self)
			# Inicia o período de recuperação após o impacto.
			action = "recover"
			# Reinicia o tempo decorrido da ação.
			action_time = 0.0
			# Define a duração de referência da ação em 0.9 segundo(s).
			action_total = 0.9
			# Aplica tremor à câmera com a intensidade indicada.
			world.shake(12.0)
		# Executa a varredura frontal.
		"sweep":
			# Define o alcance da varredura em 235 pixels.
			var reach: = 235.0
			# Só permite acertar a varredura se o herói estiver dentro do alcance.
			if global_position.distance_to(hero.global_position) < reach:
				# Calcula a direção normalizada entre o Colossal e o herói.
				var dir: Vector2 = (hero.global_position - global_position).normalized()
				# Confirma que o herói está no setor frontal indicado pela direção do Colossal.
				if dir.dot(facing) > 0.2:
					# Aplica 140% do dano configurado, marcando o golpe como crítico e informando sua origem.
					hero.take_damage(float(definition.get("damage", 34.0)) * 1.4, {"from": global_position, "crit": true, "type": type_id})
			# Exibe o indicador em cone da varredura com alcance, abertura, cor e duração definidos.
			world.spawn_cone_telegraph(global_position, facing, reach, 100.0, Color(0.95, 0.4, 0.25), 0.6)
			# Inicia o período de recuperação específico da varredura.
			action = "sweep_recover"
			# Reinicia o tempo decorrido da ação.
			action_time = 0.0
			# Define a duração de referência da ação em 1.5 segundo(s).
			action_total = 1.5
		# Executa o lançamento de pedras.
		"rocks":
			# Repete três vezes para criar três projéteis.
			for index in 3:
				# Cria uma nova instância do projétil de pedra.
				var projectile: = Projectile.new()
				# Vincula o projétil ao mundo atual.
				projectile.world = world
				# Marca o projétil como inimigo para atingir o herói.
				projectile.hostile = true
				# Mira no herói com uma variação aleatória para espalhar as pedras.
				projectile.direction = (hero.global_position - global_position + Vector2(randf_range(-80, 80), randf_range(-80, 80))).normalized()
				# Define a velocidade da pedra em 420 pixels por segundo.
				projectile.speed = 420.0
				# Define o dano da pedra como 60% do dano configurado do Colossal.
				projectile.damage = float(definition.get("damage", 34.0)) * 0.6
				# Define a duração máxima do projétil em 2,4 segundos.
				projectile.life = 2.4
				# Define o tamanho do projétil como 13.
				projectile.size = 13.0
				# Aplica uma tonalidade de pedra ao projétil.
				projectile.color = Color(0.7, 0.65, 0.55)
				# Posiciona o lançamento 90 pixels acima da origem do Colossal.
				projectile.position = global_position + Vector2(0, -90)
				# Adiciona a pedra ao mundo para iniciar seu processamento.
				world.add_projectile(projectile)
			# Limpa a ação atual, permitindo que outra seja escolhida.
			action = ""
			# Reinicia o tempo decorrido da ação.
			action_time = 0.0
		# Executa Invocar ao terminar a preparação da habilidade.
		"invocar":
			# Cria dois golens independentes, com movimento, ataque e colisão.
			_summon_golems()
			# Limpa a ação atual, permitindo que outra seja escolhida.
			action = ""
			# Reinicia o tempo decorrido da ação.
			action_time = 0.0
		# Trata qualquer opção que não corresponde aos casos anteriores.
		_:
			# Limpa a ação atual, permitindo que outra seja escolhida.
			action = ""
	# Reinicia o tempo decorrido da ação.
	action_time = 0.0


