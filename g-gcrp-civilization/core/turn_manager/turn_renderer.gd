class_name TurnPresenter
extends Node

# Este script deve ser conectado às animações dos seus nós de agente.
# Certifique-se de que seus nós de agente tenham uma função 'play_animation(action_type)'

func present_turn(turn_results: Dictionary) -> void:
	# 1. Exibir Logs
	for log_entry in turn_results.get("logs", []):
		print("LOG: ", log_entry) # Substitua pelo seu sistema de UI de logs
		# await UI_Manager.show_log(log_entry) # Opcional: pausar para o jogador ler

	# 2. Executar animações de Ações (Ataque, Cooperar, Ficar, Mover)
	# Aqui iteramos sobre as intenções ou resultados para acionar os agentes na cena
	await _play_visual_effects(turn_results)
	
	# 3. Processar Mortes (Sequencial para não sobrepor animações)
	for dead_agent_id in turn_results.get("mortes", []):
		var agent_node = _get_agent_node_by_id(dead_agent_id)
		if agent_node:
			# A função da animação deve retornar um sinal ou ser um tween que podemos 'await'
			await agent_node.play_death_animation() 
			agent_node.queue_free()
		
		# Limpa o agente do GameDataManager apenas após a animação
		GameDataManager._ai_agents.erase(dead_agent_id)
		print("Agente removido: ", dead_agent_id)

func _play_visual_effects(results: Dictionary) -> void:
	# Exemplo: animar ações ocorridas
	# Você pode passar os dados do 'raw_intentions' aqui ou enriquecer o turn_results
	# Seus agentes devem estar em um grupo "agents" para fácil acesso
	for agent in get_tree().get_nodes_in_group("agents"):
		# Aqui você acionaria o movimento ou a ação específica do agente
		# Exemplo: await agent.play_move_animation(target_pos)
		pass
	
	# Aguarda um tempo mínimo para o jogador processar a informação visual
	await get_tree().create_timer(0.5).timeout

func _get_agent_node_by_id(id: String) -> Node:
	for node in get_tree().get_nodes_in_group("agents"):
		if node.has_method("get_agent_id") and node.get_agent_id() == id:
			return node
	return null
