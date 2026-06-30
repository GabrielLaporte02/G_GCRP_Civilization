extends Node

#Lembrar de colocar o ID de cada ia no raw_intentions, ficando {"IA_1": resposta ia1, "IA_2": reoista ia2}
func resolve_turn(raw_intentions: Dictionary) -> Dictionary:
	var turn_results: Dictionary = {"logs": [], "mortes": []}
	var imunes: Dictionary = {}
	
	# 1. Identificar Esquivas e Validar Ações
	for agent_id in raw_intentions:
		var intent = raw_intentions[agent_id].get("interacao_agente", {})
		var action_str = intent.get("acao", "")
		var action_code = AgentData.ACTION_FROM_STRING.get(action_str, AgentData.InteracActions.NONE)
		
		if action_code == AgentData.InteracActions.FLEE:
			imunes[agent_id] = true
			turn_results["logs"].append("%s preparou esquiva." % agent_id)
		elif action_code == AgentData.InteracActions.NONE and action_str != "":
			turn_results["logs"].append("ERRO: %s enviou ação desconhecida '%s'." % [agent_id, action_str])
			
	# 2. Resolução de Combates
	for agent_id in raw_intentions:
		var intent = raw_intentions[agent_id].get("interacao_agente", {})
		if AgentData.ACTION_FROM_STRING.get(intent.get("acao")) == AgentData.InteracActions.ATTACK:
			var target_id = intent.get("alvo", "")
			
			# Verificação de IA Inexistente
			if not GameDataManager._ai_agents.has(target_id):
				turn_results["logs"].append("%s tentou atacar alvo inexistente (%s)." % [agent_id, target_id])
				continue
				
			var attacker_pos = GameDataManager.get_agent_position(agent_id)
			var target_pos = GameDataManager.get_agent_position(target_id)
			
			# Verificação de Distância
			if attacker_pos != target_pos:
				turn_results["logs"].append("%s tentou atacar %s longe demais." % [agent_id, target_id])
				continue

			# Verificação de Esquiva
			if imunes.has(target_id):
				turn_results["logs"].append("%s atacou %s, mas o alvo esquivou!" % [agent_id, target_id])
				continue

			var attacker = GameDataManager._ai_agents[agent_id]
			var target = GameDataManager._ai_agents[target_id]
			
			# Resolução de Dano
			if attacker.combat_power > target.combat_power:
				target.health -= attacker.combat_power
				_process_resource_theft(attacker, target)
				turn_results["logs"].append("%s atacou %s e venceu." % [agent_id, target_id])
				
				if target.health <= 0:
					turn_results["mortes"].append(target_id)
			else:
				turn_results["logs"].append("%s falhou ao atacar %s (Empate/Fraqueza)." % [agent_id, target_id])

	# 3. Resolução de Cooperação
	for agent_id in raw_intentions:
		var intent = raw_intentions[agent_id].get("interacao_agente", {})
		if AgentData.ACTION_FROM_STRING.get(intent.get("acao")) == AgentData.InteracActions.COOPERATE:
			var pos = GameDataManager.get_agent_position(agent_id)
			
			# Se o grid real estiver instanciado no teste:
			var tile = GameDataManager.get_tile(pos.x, pos.y)
			if tile != null:
				var amount_to_give = int(tile.amount * 0.5)
				var agents_on_tile = GameDataManager._get_agents_at_position(pos)
				
				for neighbor_name in agents_on_tile:
					# ATENÇÃO: _get_agents_at_position retorna agent_name, não agent_id[cite: 3].
					# O ideal é buscar pelo ID ou garantir que name == ID para o update_agent_resource.
					# Ajustando para usar o dicionário direto pela posição para garantir o ID correto:
					for id in GameDataManager._ai_agents.keys():
						if GameDataManager._ai_agents[id].position == pos:
							GameDataManager.update_agent_resource(id, "food", amount_to_give)
				
				turn_results["logs"].append("%s cooperou no tile %s." % [agent_id, str(pos)])
	return turn_results

func _process_resource_theft(attacker, target):
	# Lógica de transferência de 50% ou 100% (se morto) dos recursos
	var multiplier = 1.0 if target.health <= 0 else 0.5
	for res in target.inventory:
		var amount = int(target.inventory[res] * multiplier)
		target.inventory[res] -= amount
		attacker.inventory[res] += amount
