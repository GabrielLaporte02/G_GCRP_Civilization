extends Node
class_name Game_Data_Manager

const GRID_WIDTH: int = 10
const GRID_HEIGHT: int = 10

var _grid: Array = []
var _ai_agents: Dictionary[String, AgentData] = {}
var current_turn: int = 0

var event_log: Dictionary[String, Array] = {"Messages": [], "Actions": []}

func _ready() -> void:
	_initialize_empty_grid()

func _initialize_empty_grid() -> void:
	_grid.clear()
	
	# Criando array bidimensional
	for x in range(GRID_WIDTH):
		var column: Array = []
		for y in range(GRID_HEIGHT):
			column.append(GridTile.new())
		_grid.append(column)

func _grid_printt() -> void:
	for y in range(GRID_HEIGHT):
		var linha_atual: Array = []
		
		for x in range(GRID_WIDTH):
			linha_atual.append(_grid[x][y].type)
		printt.callv(linha_atual)

# --- AI AGENTS ---
func register_agent(agent_id: String, start_position: Vector2i, personality: AgentData.AgentType) -> bool:
	if start_position.x < 0 or start_position.x >= GRID_WIDTH or start_position.y < 0 or start_position.y >= GRID_HEIGHT:
		push_error("Error: Agent insertion out of bounds at ", start_position)
		return false
	
	if _ai_agents.has(agent_id):
		push_warning("Warning: Agent ID already exists - " + agent_id)
		return false
	
	var new_agent = AgentData.new(agent_id, personality, start_position)
	
	_ai_agents[agent_id] = new_agent
	return true

# Retorna os status completos do agente,em formato de texto.
func get_agent_full_status(agent_id: String) -> String:
	if not _ai_agents.has(agent_id): 
		return ""
	var agent = _ai_agents[agent_id]
	var status_string = ""
	status_string += "Nome: " + agent.agent_name + "\n"
	status_string += "Vida: " + agent.health + "\n"
	status_string += "Combate: " + agent.combat_power + "\n"
	status_string += "Visão: " + agent.vision_range + "\n"
	status_string += "Personalidade: " + agent.personality + "\n"
	status_string += "Comida: " + agent.inventory["food"] + "\n"
	status_string += "Madeira: " + agent.inventory["wood"] + "\n"
	status_string += "Pedra: " + agent.inventory["stone"] + "\n"
	return status_string

func get_agent_known_map(agent_id: String):
	pass

func get_agent_position(agent_id: String) -> Vector2i:
	if _ai_agents.has(agent_id):
		return _ai_agents[agent_id].position
	push_error("Error: Agent not found - " + agent_id)
	return Vector2i(-1, -1)

func get_agent_vision(agent_id: String) -> Array[Dictionary]:
	var vision_data: Array[Dictionary] = []
	
	if not _ai_agents.has(agent_id):
		push_error("Error: Cannot get vision, agent not found - " + agent_id)
		return vision_data
		
	var ai_pos: Vector2i = _ai_agents[agent_id].position
	var radius: int = _ai_agents[agent_id].vision_range
	
	#obs: O limite superior do for é exclusivo, logo devemos colocar +1
	for x in range(ai_pos.x - radius, ai_pos.x + radius + 1):
		for y in range(ai_pos.y - radius, ai_pos.y + radius + 1):
			if x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT:
				vision_data.append({
					"position": Vector2i(x, y),
					"tile": _grid[x][y]
				})
	return vision_data

# Retorna texto com os eventos e resultados recentemente vistos pelo agente.
func get_agent_events_and_results(agent_id: String):
	if not _ai_agents.has(agent_id): 
		return ""
	var text = ""
	for i in get_agent_recent_seen_actions_index(agent_id, 10):
		var action = event_log["Actions"][i]
		text += action.text + "\n"
		return text

# Retorna texto com as mensagens recentemente recebidas e enviadas pelo agente.
func get_agent_conversations(agent_id: String):
	if not _ai_agents.has(agent_id): 
		return ""
	var text = ""
	for i in get_agent_recent_seen_messages_index(agent_id, 10):
		var message = event_log["Messages"][i]
		text += message.text + "\n"
		return text

func update_agent_stat(agent_id: String, stat_name: String, value: int) -> void:
	if not _ai_agents.has(agent_id): 
		return
	
	var agent = _ai_agents[agent_id]
	match stat_name:
		"health": agent.health += value
		"combat_power": agent.combat_power += value
		"vision_range": agent.vision_range += value

func update_agent_position(agent_id: String, new_pos: Vector2i) -> bool:
	if not _ai_agents.has(agent_id): 
		return false
	if new_pos.x < 0 or new_pos.x >= GRID_WIDTH or new_pos.y < 0 or new_pos.y >= GRID_HEIGHT:
		return false
		
	_ai_agents[agent_id].position = new_pos
	return true

# Atualiza itens do inventário (melhorar depois caso seja possível, para evitar erros de digitacao)
func update_agent_resource(agent_id: String, resource_name: String, amount: int) -> void:
	if not _ai_agents.has(agent_id):
		return
	
	var agent = _ai_agents[agent_id]
	if agent.inventory.has(resource_name):
		agent.inventory[resource_name] += amount
	else:
		push_warning("Log: Agent [", agent_id, "] inventory doesnt have [", resource_name, "]")

func clear_agents() -> void:
	_ai_agents.clear()

# --- GRID/TILES ---
func get_tile(x: int, y: int) -> GridTile:
	if x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT:
		return _grid[x][y]
	
	push_error("Error: Out of bounds grid access at: ", x, ", ", y)
	return null
	
func get_full_grid() -> Array:
	return _grid

func set_tile(x: int, y: int, new_tile: GridTile) -> void:
	if x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT:
		_grid[x][y] = new_tile
	else:
		push_error("Error: set_tile() failed. Coordinates out of bounds at ", x, ", ", y)

func set_full_grid(new_grid: Array) -> void:
	if new_grid.size() == GRID_WIDTH and new_grid[0].size() == GRID_HEIGHT:
		_grid = new_grid
	else:
		push_error("Error: Invalid grid dimensions passed to set_full_grid().")

# --- TURN ---
func get_current_turn() -> int:
	return current_turn

# --- Events ---
# Cria evento, adiciona ele ao event_log e distribui para os agentes que viram
# o evento ocorrer.
func add_event(position: Vector2i, agent_id: String, type: Event.EventType,text: String):
	# Cria evento:
	var event = Event.new(type, position, agent_id,
	text, current_turn)
	# Add ao event_log:
	if type == Event.EventType.ACTION:
		event_log["Actions"].append(event)
	elif type == Event.EventType.MESSAGE:
		event_log["Messages"].append(event)
	# Distrinui evento:
	_distribute_event(event)

# Distribui o evento para os agentes que viram ele ocorrer;
# Ações são vistas se estiverem dentro do alcance da visão do agente;
# Mensagens são vistas se o agente que mandou a mensagem estiver no mesmo
# quadrado ou em um dos quadrados adjacentes.  
func _distribute_event(event:Event):
	for agent in _ai_agents.values():
		# Obtem a distancia do evento em relação ao agente:
		var distance = max(abs(agent.position.x - event.position.x),
						   abs(agent.position.y - event.position.y))
		# Se evento é ação e está dentro da área de visão,
		# ação foi vista pelo agente.
		if event.type == Event.EventType.ACTION:
			if distance <= agent.vision:
				var index = event_log["Actions"].size() - 1
				agent.add_seen_actions(index)
		# Se evento é mensagem e está adjacente ou na mesma posição,
		# mensagem foi recebida pelo agente.
		elif event.type == Event.EventType.MESSAGE:
			if distance <= 1:
				var index = event_log["Messages"].size() - 1
				agent.add_seen_messages(index)

# Retorna lista com os indices das ações recentemente vistas e feitas pelos
# agente;
# amount: indica a quantidade de ações que será retornada.
func get_agent_recent_seen_actions_index(agent_id: String, amount: int):
	if not _ai_agents.has(agent_id):
		return
	var agent = _ai_agents[agent_id]
	var seen_actions_size = agent.get_seen_actions().size()
	return agent.memory.actions.slice(max(seen_actions_size - amount, 0),
									  seen_actions_size)

# Retorna lista com os indices das mensagens recentemente recebidas e enviadas
# pelos agente;
# amount: indica a quantidade de mensagens que será retornada.
func get_agent_recent_seen_messages_index(agent_id: String, amount: int):
	if not _ai_agents.has(agent_id):
		return
	var agent = _ai_agents[agent_id]
	var seen_messages_size = agent.get_seen_messages().size()
	return agent.memory.actions.slice(max(seen_messages_size - amount, 0),
									  seen_messages_size)
