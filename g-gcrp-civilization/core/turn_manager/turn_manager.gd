class_name TurnManager
extends Node

enum TurnState {
	READY,
	SEND_MESSAGE_API,
	WAIT_RESPONSE,
	ACTIONS,
	MESSAGES,
	MOVEMENT,
	LOSE_FOOD,
	VERIFY_DEATH,
	END_TURN
}

var current_state = TurnState.READY
var current_agent := 0

var can_start_turn : bool = false
var start_running: bool = false
var running_simulation: bool = false

var agents_ids : Array = []
var request_list = []
var responses_dict : Dictionary = {}
var action_dict : Dictionary = {}
var messages_dict : Dictionary = {}
var movement_dict : Dictionary = {}
var waiting_response : bool = false

@export var agent_comm_manager : Agent_Comm_Manager

func _ready() -> void:
	run_simulation()
	EventBus.next_turn_requested.connect(_on_start_turn)

func _physics_process(delta: float) -> void:
	if running_simulation:
		simulation()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_up"):
		_on_start_turn()

func run_simulation():
	running_simulation = true

func simulation():
	match current_state:
		TurnState.READY:
			ready_state()
		TurnState.SEND_MESSAGE_API:
			send_message_state()
		TurnState.WAIT_RESPONSE:
			wait_response_state()
		TurnState.ACTIONS:
			actions_state()
		TurnState.MESSAGES:
			messages_state()
		TurnState.MOVEMENT:
			movement_state()
		TurnState.LOSE_FOOD:
			lose_food_state()
		TurnState.VERIFY_DEATH:
			verify_death_state()
		TurnState.END_TURN:
			end_turn_state()

func turn_start():
	current_state = TurnState.SEND_MESSAGE_API

func _on_start_turn():
	if can_start_turn and current_state == TurnState.READY:
		can_start_turn = false
		turn_start()

func ready_state():
	agents_ids = GameDataManager._ai_agents.keys()
	request_list = agents_ids.duplicate()
	responses_dict = {}
	action_dict = {}
	messages_dict = {}
	movement_dict = {}
	waiting_response = false
	can_start_turn = true

func send_message_state():
	if request_list.size() > 0:
		current_state = TurnState.WAIT_RESPONSE
		agent_comm_manager.send_message(request_list[0])
	else:
		current_state = TurnState.ACTIONS

func wait_response_state():
	if waiting_response:
		return
	waiting_response = true
	await agent_comm_manager.response_received
	waiting_response = false
	responses_dict[request_list[0]] = agent_comm_manager.get_response_data()  
	#print(request_list[0] + ": " + str(responses_dict[request_list[0]]))
	request_list.remove_at(0)
	if request_list.size() > 0:
		current_state = TurnState.SEND_MESSAGE_API
	else:
		current_state = TurnState.ACTIONS

func actions_state():
	action_dict.clear()
	# =========================
	# VALIDAR RESPOSTAS
	# =========================
	for agent_id in responses_dict.keys():
		var agent: AgentData = GameDataManager.get_agent_by_id(agent_id)
		var r = responses_dict[agent_id]
		if typeof(r) != TYPE_DICTIONARY:
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				"%s: resposta inválida (não JSON)." % agent.agent_name)
			continue
		if !r.has("ação"):
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				"%s: ação não encontrada." % agent.agent_name)
			continue
		action_dict[agent_id] = r["ação"]
	# =========================
	# EXECUTAR AÇÕES
	# =========================
	for agent_id in action_dict.keys():
		var agent: AgentData = GameDataManager.get_agent_by_id(agent_id)
		var action: String = action_dict[agent_id]
		# =====================================================
		# ATAQUE
		# =====================================================
		if action.begins_with("atacar "):
			var parts = action.split(" ")
			if parts.size() < 2:
				continue
			var target_name = parts[1]
			var target: AgentData = GameDataManager.get_agent_by_name(target_name)
			if target == null:
				GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				"%s: erro, alvo '%s' não pode ser encontrado/não existe" % [agent.agent_name, target_name])
				continue
			if !GameDataManager.is_next_to(agent_id, target.position):
				GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				"%s: tentou atacar %s, mas ele está fora do alcance" % [agent.agent_name, target_name])
				continue
			# dano = combat_power
			GameDataManager.update_agent_stat(target.id, "health", -agent.combat_power)
			var event_text = "%s atacou %s (-%d vida)" % [
				agent.agent_name,
				target.agent_name,
				agent.combat_power
			]
			# morreu → rouba tudo
			if target.health <= 0:
				for k in target.inventory.keys():
					GameDataManager.update_agent_resource(agent_id, k, target.inventory[k])
					target.inventory[k] = 0
				event_text += ", %s morreu e seus recursos foram roubados." % target.agent_name
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION, event_text)
		# =====================================================
		# COLETAR
		# =====================================================
		elif action == "coletar":
			var tile: GridTile = GameDataManager.get_tile(agent.position.x, agent.position.y)
			var amount = tile.get_amount()
			var event_text := ""
			match tile.type:
				GridTile.TileType.FOOD:
					GameDataManager.update_agent_resource(agent_id, "food", amount)
					event_text = "%s coletou %d comida." % [agent.agent_name, amount]
				GridTile.TileType.WOOD:
					GameDataManager.update_agent_resource(agent_id, "wood", amount)
					event_text = "%s coletou %d madeira." % [agent.agent_name, amount]
				GridTile.TileType.STONE:
					GameDataManager.update_agent_resource(agent_id, "stone", amount)
					event_text = "%s coletou %d pedra." % [agent.agent_name, amount]
				GridTile.TileType.EMPTY:
					event_text = "%s tentou coletar, mas não havia recursos." % agent.agent_name
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION, event_text)
		# =====================================================
		# COOPERAR
		# =====================================================
		elif action == "cooperar":
			var tile: GridTile = GameDataManager.get_tile(agent.position.x, agent.position.y)
			var total = tile.get_amount()
			var mine = int(total * 0.5)
			var shared = total - mine
			match tile.type:
				GridTile.TileType.FOOD:
					GameDataManager.update_agent_resource(agent_id, "food", mine)
				GridTile.TileType.WOOD:
					GameDataManager.update_agent_resource(agent_id, "wood", mine)
				GridTile.TileType.STONE:
					GameDataManager.update_agent_resource(agent_id, "stone", mine)
			var receivers = []
			for other in GameDataManager._ai_agents.values():
				if other.id == agent.id:
					continue
				if GameDataManager.is_next_to(agent_id, other.position):
					receivers.append(other)
			if receivers.size() > 0:
				var each = int(shared / receivers.size())
				for other in receivers:
					match tile.type:
						GridTile.TileType.FOOD:
							GameDataManager.update_agent_resource(other.id, "food", each)
						GridTile.TileType.WOOD:
							GameDataManager.update_agent_resource(other.id, "wood", each)
						GridTile.TileType.STONE:
							GameDataManager.update_agent_resource(other.id, "stone", each)
				GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
					"%s: cooperou e compartilhou recursos." % agent.agent_name)
			else:
				GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
					"%s: tentou cooperar, mas não tinha ninguem por perto." % agent.agent_name)
		# =====================================================
		# FUGIR
		# =====================================================
		elif action == "fugir":
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				"%s: está preparado para fugir de ataques." % agent.agent_name)
		# =====================================================
		# MELHORAR ARMA
		# custo: 5 comida / 10 madeira / 15 pedra
		# =====================================================
		elif action == "melhorar_arma":
			if agent.inventory["food"] < 5 or agent.inventory["wood"] < 10 or agent.inventory["stone"] < 15:
				GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				"%s tentou melhorar arma, mas não tinha comida, madeira ou pedra o suficiente." % agent.agent_name)
				continue
			GameDataManager.update_agent_resource(agent_id, "food", -5)
			GameDataManager.update_agent_resource(agent_id, "wood", -10)
			GameDataManager.update_agent_resource(agent_id, "stone", -15)
			GameDataManager.update_agent_stat(agent_id, "combat_power", 2)
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				"%s melhorou arma (+2 combate)." % agent.agent_name)
		# =====================================================
		# CURAR
		# custo: 15 comida
		# =====================================================
		elif action == "curar":
			if agent.inventory["food"] < 15:
				GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				"%s: tentou curar, mas não tinha comida o suficiente." % agent.agent_name)
				continue
			GameDataManager.update_agent_resource(agent_id, "food", -15)
			GameDataManager.update_agent_stat(agent_id, "health", 2)
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				"%s: curou +2 vida." % agent.agent_name)
		# =====================================================
		# MELHORAR VISÃO
		# custo: 10/10/10
		# =====================================================
		elif action == "melhorar_visao":
			if agent.inventory["food"] < 10 or agent.inventory["wood"] < 10 or agent.inventory["stone"] < 10:
				GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				"%s: tentou melhorar a visão, mas não tinha comida, madeira e pedra o suficiente." % agent.agent_name)
				continue
			GameDataManager.update_agent_resource(agent_id, "food", -10)
			GameDataManager.update_agent_resource(agent_id, "wood", -10)
			GameDataManager.update_agent_resource(agent_id, "stone", -10)
			GameDataManager.update_agent_stat(agent_id, "vision_range", 1)
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				"%s: aumentou visão (+1)." % agent.agent_name)
		# =====================================================
		# INVÁLIDO
		# =====================================================
		else:
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				"%s: ação '%s' é inválida." % [agent.agent_name, action])
	current_state = TurnState.MESSAGES

func messages_state():
	for agent_id in responses_dict.keys():
		# Obtem dados 
		var agent : AgentData = GameDataManager.get_agent_by_id(agent_id)
		var r = responses_dict[agent_id]
		if r == null:
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
			 "%s: Erro ao criar json, formato de resposta invalido" % agent.agent_name)
			continue
		if ! r.has("mensagem"):
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
			 '%s: Erro, não há o campo de "mensagem", nada foi feito' % agent.agent_name)
			continue
		messages_dict[agent_id] = r["mensagem"]
	for agent_id in messages_dict.keys():
		var agent : AgentData = GameDataManager.get_agent_by_id(agent_id)
		GameDataManager.add_event(agent.position, agent_id, Event.EventType.MESSAGE,
			 "%s: %s" % [agent.agent_name, messages_dict[agent_id]])
	current_state = TurnState.MOVEMENT

func movement_state():
	for agent_id in responses_dict.keys():
		# Obtem dados 
		var agent : AgentData = GameDataManager.get_agent_by_id(agent_id)
		var r = responses_dict[agent_id]
		if r == null:
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
			 "%s: Erro ao criar json, formato de resposta invalido" % agent.agent_name)
			continue
		if ! r.has("movimento"):
			GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
			 '%s: Erro, não há o campo de "movimento", nada foi feito' % agent.agent_name)
			continue
		movement_dict[agent_id] = r["movimento"]
	for agent_id in movement_dict.keys():
		var agent : AgentData = GameDataManager.get_agent_by_id(agent_id)
		var move = movement_dict[agent_id]
		var event_text = ""
		if move == "ficar":
			event_text += "%s: ficou parado em (%d, %d)" % [agent.agent_name, agent.position.x, agent.position.y]
		else:
			event_text += "%s: se moveu de (%d, %d)" % [agent.agent_name, agent.position.x, agent.position.y]
			if move == "mover_norte":
				agent.anda_norte()
			elif move == "mover_sul":
				agent.anda_sul()
			elif move == "mover_leste":
				agent.anda_leste()
			elif move == "mover_oeste":
				agent.anda_oeste()
			else:
				GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
				'%s: Erro, movimento "%s" não é valido' % [agent.agent_name, move])
				continue
			event_text += " para (%d, %d)" % [agent.position.x, agent.position.y]
		GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
			 event_text)
	current_state = TurnState.LOSE_FOOD

func lose_food_state():
	# =========================
	# CONSUMO DE COMIDA FINAL
	# =========================
	for agent_id in GameDataManager._ai_agents.keys():
		GameDataManager.update_agent_resource(agent_id, "food", -5)
		var ag = GameDataManager.get_agent_by_id(agent_id)
		if ag.inventory["food"] <= 0:
			GameDataManager.update_agent_stat(agent_id, "health", -1)
	current_state = TurnState.VERIFY_DEATH

func verify_death_state():
	var to_remove = []
	for agent_id in responses_dict.keys():
		# Obtem dados 
		var agent : AgentData = GameDataManager.get_agent_by_id(agent_id)
		if agent.health <= 0:
			to_remove.append(agent_id)
	for agent_id in to_remove:
		var agent : AgentData = GameDataManager.get_agent_by_id(agent_id)
		GameDataManager.add_event(agent.position, agent_id, Event.EventType.ACTION,
		'%s: morreu"' % agent.agent_name)
		agent.die()
		GameDataManager._ai_agents.erase(agent_id)
	current_state = TurnState.END_TURN

func end_turn_state():
	print("FIM")
	current_state = TurnState.READY
