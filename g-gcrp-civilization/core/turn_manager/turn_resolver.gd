extends Node

func resolve_turn(raw_intentions: Dictionary) -> Dictionary:
	# 1. Preparação: Inicializa o registro de resultados
	var turn_results: Dictionary = {"logs": [], "mortes": []}
	
	# 2. Execução Sequencial (A ordem é a regra de ouro aqui)
	_process_actions(raw_intentions, turn_results)
	#_process_messages(raw_intentions, turn_results)
	_process_movement(raw_intentions, turn_results)
	_process_food_consumption(turn_results)
	_process_death_check(turn_results)
	
	print(turn_results)
	return turn_results

func _process_actions(raw_intentions: Dictionary, results: Dictionary) -> void:
	# Lista de ataques válidos para serem resolvidos na Etapa 2
	var attack_queue: Array = []
	
	# --- ETAPA 1: TRIAGEM E PRIORIZAÇÃO ---
	for agent_id in raw_intentions:
		if not _is_agent_alive(agent_id): continue
		
		var intent = raw_intentions[agent_id]
		var action_data = _parse_action(intent.get("acao", "")) # Função auxiliar para separar "atacar" do "alvo"
		
		if action_data.code == AgentData.InteracActions.ATTACK:
			var target_id = action_data.target
			
			# Validação básica de alvo
			if not GameDataManager._ai_agents.has(target_id):
				results["logs"].append("Agente %s tentou atacar alvo inexistente: %s." % [agent_id, target_id])
				continue

			# Validação de alcance (mesmo tile ou adjacente)
			var attacker_pos = GameDataManager.get_agent_position(agent_id)
			var target_pos = GameDataManager.get_agent_position(target_id)
			var distance = max(abs(attacker_pos.x - target_pos.x), abs(attacker_pos.y - target_pos.y))
			
			if distance > 1:
				results["logs"].append("Agente %s tentou atacar %s, mas está fora de alcance." % [agent_id, target_id])
				continue
			# Se passou, adiciona na fila
			attack_queue.append({"attacker": agent_id, "target": target_id})
	
	# Próximo passo: Etapa 2 - Resolução de Combate (usando a attack_queue)
	_resolve_combats(attack_queue, raw_intentions, results)
	# Próximo passo: 3. Etapa de Cooperação e Coleta (O "Ganho")
	_process_cooperation(raw_intentions, results)
	# Próximo passo: 4. Etapa de Cooperação e Coleta (O "Ganho")
	_process_upgrades(raw_intentions, results)

func _resolve_combats(attack_queue: Array, raw_intentions: Dictionary, results: Dictionary) -> void:
	# 1. Varredura de intenções para preencher as esquivas (Imunidade)
	var imunes: Dictionary = {}
	for agent_id in raw_intentions:
		var intent = raw_intentions[agent_id]
		var action_data = _parse_action(intent.get("acao", ""))
		
		if action_data.code == AgentData.InteracActions.FLEE:
			imunes[agent_id] = true

	# 2. Resolução dos combates (Simultaneidade)
	for combat in attack_queue:
		var attacker_id = combat.attacker
		var target_id = combat.target
		
		# Alvos que esquivaram anulam o ataque de imediato
		if imunes.has(target_id):
			results["logs"].append("Ataque de %s em %s falhou: Alvo esquivou." % [attacker_id, target_id])
			continue
			
		var attacker = GameDataManager._ai_agents[attacker_id]
		var target = GameDataManager._ai_agents[target_id]
		
		# Comparação de combate
		if attacker.combat_power > target.combat_power:
			target.health -= attacker.combat_power
			
			# O alvo é penalizado com 100% de roubo se a vida zerou ou já estava zerada neste combate
			var is_lethal = target.health <= 0
			var factor = 1.0 if is_lethal else 0.5

			for res in ["food", "wood", "stone"]:
				var stolen = int(floor(target.inventory[res] * factor))
				target.inventory[res] -= stolen
				attacker.inventory[res] += stolen
				
			results["logs"].append("%s venceu combate contra %s." % [attacker_id, target_id])
			
			# Registra a morte apenas uma vez, mesmo se o alvo for "overkilled"
			if is_lethal and not target_id in results["mortes"]:
				results["mortes"].append(target_id)
		else:
			results["logs"].append("%s não venceu %s no combate." % [attacker_id, target_id])

func _process_upgrades(raw_intentions: Dictionary, results: Dictionary) -> void:
	for agent_id in raw_intentions:
		if not _is_agent_alive(agent_id): continue

		var intent = raw_intentions[agent_id]
		var action_data = _parse_action(intent.get("acao", ""))
		var agent = GameDataManager._ai_agents[agent_id]

		match action_data.code:
			AgentData.InteracActions.UPGRADE_WEAPON:
				if agent.inventory["food"] >= 1 and agent.inventory["wood"] >= 1 and agent.inventory["stone"] >= 1:
					agent.inventory["food"] -= 1
					agent.inventory["wood"] -= 1
					agent.inventory["stone"] -= 1
					GameDataManager.update_agent_stat(agent_id, "combat_power", 2)
					results["logs"].append("Agente %s melhorou sua arma." % agent_id)
				else:
					results["logs"].append("Agente %s tentou melhorar arma, mas faltam recursos." % agent_id)
					
			AgentData.InteracActions.HEAL:
				if agent.inventory["food"] >= 3:
					agent.inventory["food"] -= 3
					GameDataManager.update_agent_stat(agent_id, "health", 2)
					results["logs"].append("Agente %s se curou." % agent_id)
				else:
					results["logs"].append("Agente %s tentou se curar, mas falta comida." % agent_id)
					
			AgentData.InteracActions.UPGRADE_VISION:
				if agent.inventory["food"] >= 1 and agent.inventory["wood"] >= 1 and agent.inventory["stone"] >= 1:
					agent.inventory["food"] -= 1
					agent.inventory["wood"] -= 1
					agent.inventory["stone"] -= 1
					GameDataManager.update_agent_stat(agent_id, "vision_range", 1)
					results["logs"].append("Agente %s melhorou sua visão." % agent_id)
				else:
					results["logs"].append("Agente %s tentou melhorar visão, mas faltam recursos." % agent_id)

func _process_cooperation(raw_intentions: Dictionary, results: Dictionary) -> void:
	for agent_id in raw_intentions:
		if not _is_agent_alive(agent_id): continue

		var intent = raw_intentions[agent_id]
		var action_data = _parse_action(intent.get("acao", ""))
		
		print("Ação de Cooperar Detectada")
		
		if action_data.code == AgentData.InteracActions.COOPERATE:
			print("Ação de Cooperar Detectada")
			var pos = GameDataManager.get_agent_position(agent_id)
			var tile = GameDataManager.get_tile(pos.x, pos.y)
			
			# Aplica regra: 50% para si e 50% para os outros (todos recebem o mesmo valor total)
			# O valor é arredondado para baixo para evitar criação de recursos
			var tile_type = tile.type
			var gain = int(floor(tile.amount * 0.5))

			# Identifica quem está no mesmo tile para receber a parte da cooperação
			var agents_on_tile = GameDataManager._get_agents_at_position(pos)

			for recipient_id in agents_on_tile:
				# O cooperador e todos os outros no tile recebem a mesma fatia
				var key: String = "stone"
				if tile_type == 1:
					key = "wood"
				elif tile_type == 2:
					key = "food"
				elif tile_type == 3:
					key = "stone"

				GameDataManager.update_agent_resource(recipient_id, key, gain)
			
			results["logs"].append("Agente %s cooperou no tile %s, distribuindo recursos." % [agent_id, str(pos)])

func _process_movement(intentions: Dictionary, results: Dictionary) -> void:
	for agent_id in intentions:
		if not _is_agent_alive(agent_id): continue
		
		var move_intent = intentions[agent_id].get("movimento", "ficar")
		var current_pos = GameDataManager.get_agent_position(agent_id)
		var next_pos = current_pos
		
		match move_intent:
			"mover_norte": next_pos += Vector2i(0, -1)
			"mover_sul":   next_pos += Vector2i(0, 1)
			"mover_leste": next_pos += Vector2i(1, 0)
			"mover_oeste": next_pos += Vector2i(-1, 0)
			"ficar":       pass
			_:             pass # Movimento inválido, não faz nada
			
		# Validação de limites e aplicação
		if next_pos != current_pos:
			var success = GameDataManager.update_agent_position(agent_id, next_pos)
			if success:
				results["logs"].append("%s moveu-se para %s." % [agent_id, str(next_pos)])
			else:
				results["logs"].append("%s tentou mover-se para fora do mapa." % agent_id)

func _process_food_consumption(results: Dictionary) -> void:
	for agent_id in GameDataManager._ai_agents.keys():
		if not _is_agent_alive(agent_id): continue
		var agent = GameDataManager._ai_agents[agent_id]
		# Regra: 1 de comida consumido, se não tiver, perde 1 de vida
		if agent.inventory["food"] > 0:
			agent.inventory["food"] -= 1
			results["logs"].append("Agente %s se alimentou e perdeu 1 de comida." % agent_id)
		else:
			agent.health -= 1
			results["logs"].append("Agente %s passou fome e perdeu 1 de vida." % agent_id)
			
		# Marca para remoção se a fome causar a morte
		if agent.health <= 0:
			results["mortes"].append(agent_id)

func _process_death_check(results: Dictionary) -> void:
	for agent_id in GameDataManager._ai_agents.keys():
		if not _is_agent_alive(agent_id):
			if not agent_id in results["mortes"]:
				results["mortes"].append(agent_id)
				# Mensagem personalizada conforme solicitado
				results["logs"].append("Durante as atividades do turno, agente %s morreu." % agent_id)

func _parse_action(action_string: String) -> Dictionary:
	var parts = action_string.strip_edges().split(" ")
	var command = parts[0].to_lower()

	var result = {"code": AgentData.InteracActions.NONE, "target": "", "extra": []}

	match command:
		"atacar":
			result.code = AgentData.InteracActions.ATTACK
			if parts.size() > 1: result.target = parts[1]
		"cooperar":
			result.code = AgentData.InteracActions.COOPERATE
		"fugir":
			result.code = AgentData.InteracActions.FLEE
		"melhorar_arma":
			result.code = AgentData.InteracActions.UPGRADE_WEAPON
		"curar":
			result.code = AgentData.InteracActions.HEAL
		"melhorar_visao":
			result.code = AgentData.InteracActions.UPGRADE_VISION
		"transformar_recurso":
			result.code = AgentData.InteracActions.CONVERT_RESOURCE
			if parts.size() > 2: result.extra = [parts[1], parts[2]]

	return result

func _is_agent_alive(agent_id: String) -> bool:
	if not GameDataManager._ai_agents.has(agent_id):
		return false
	
	return GameDataManager._ai_agents[agent_id].health > 0
