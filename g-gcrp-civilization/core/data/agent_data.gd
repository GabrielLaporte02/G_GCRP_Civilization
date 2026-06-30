extends Resource
class_name AgentData

enum AgentType {
	AGGRESSIVE,
	COOPERATIVE
}

enum InteracActions{
	ATTACK,
	COOPERATE,
	FLEE,
	NONE
}

enum WorldActions{
	MOVEGATHER,
	UPGRADE_WEAPON,
	HEAL,
	UPGRADE_VISION,
	CONVERT_RESOURCE,
	NONE
}

const ACTION_FROM_STRING = {
	"Atacar": InteracActions.ATTACK,
	"Cooperar": InteracActions.COOPERATE,
	"Fugir": InteracActions.FLEE,
	"": InteracActions.NONE
}

const INTERACTIONSNAMES: ={
	InteracActions.ATTACK: "Atacar",
	InteracActions.COOPERATE: "Cooperar",
	InteracActions.FLEE: "Fugir",
}

const WORLDACTIONSNAMES ={
	WorldActions.MOVEGATHER: "Mover e Coletar",
	WorldActions.UPGRADE_WEAPON: "Melhorar Arma",
	WorldActions.HEAL: "Curar",
	WorldActions.UPGRADE_VISION: "Melhorar Visao",
	WorldActions.CONVERT_RESOURCE: "Transformar Recurso",
	WorldActions.NONE: ""
}

var agent_name: String
var personality: AgentType

var health: int
var position: Vector2i
var combat_power: int
var vision_range: int
var inventory: Dictionary

var seen_actions = []
var seen_messages = []

var known_map : Array[Array]
var seen_map : Array[Array]


# --- Funções do sistema  ------------------------------------------------------------------------ #
func _init(_agent_name: String = "", _personality: AgentType = AgentType.COOPERATIVE,
			_position: Vector2i = Vector2i.ZERO) -> void:
	
	agent_name = _agent_name
	personality = _personality
	
	position = _position
	health = 5
	combat_power = 1
	vision_range = 1
	inventory["food"] = 2
	inventory["wood"] = 0
	inventory["stone"] = 0
	initialize_known_map(GameDataManager.GRID_WIDTH, GameDataManager.GRID_HEIGHT)
# ------------------------------------------------------------------------------------------------ #
# --- Maps --------------------------------------------------------------------------------------- #
# Inicializa o mapa que guarda as informações do que o agente já viu.
func initialize_known_map(width: int, height: int):
	known_map.clear()
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(TileMemory.new(x, y))
		known_map.append(row)

# Atualiza o mapa conhecido utilizando a parte do mapa que o agente cnsegue ver.
func update_known_map():
	if seen_map.is_empty():
		return
	for row in seen_map:
		for tile: TileMemory in row:
			if tile != null:
				known_map[tile.tile_cord.y][tile.tile_cord.x] = tile

# Retorna o mapa que o agente conhece em fortato de texto.
func get_known_map():
	return known_map

# Atualiza a parte do mapa que o agente consegue ver.
func update_seen_map(vision_data: Array[Dictionary]):
	var vision_map: Array = []
	if vision_data.is_empty():
		return
	# Descobre os limites da visão:
	var min_x = vision_data[0]["position"].x
	var max_x = min_x
	var min_y = vision_data[0]["position"].y
	var max_y = min_y
	for data in vision_data:
		var pos: Vector2i = data["position"]
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	# Cria a matriz:
	var width = max_x - min_x + 1
	var height = max_y - min_y + 1
	for y in range(height):
		var row: Array = []
		for x in range(width):
			row.append(null)
		vision_map.append(row)
	# Cria TileMemory:
	for data in vision_data:
		var pos: Vector2i = data["position"]
		var tile: GridTile = data["tile"]
		var agents = data["agents"]
		var memory := TileMemory.new(pos.x, pos.y)
		memory.update(tile.food, tile.wood, tile.stone, agents)
		# Add TileMemory a matriz:
		var local_x = pos.x - min_x
		var local_y = pos.y - min_y
		vision_map[local_y][local_x] = memory
	seen_map = vision_map

# Retorna o mapa que o agente está vendo.
func get_seen_map():
	return seen_map

# Transforma o mapa recebido para string.
func map_to_string(map: Array) -> String:
	var text := ""
	for row in map:
		for tile: TileMemory in row:
			if tile != null:
				text += tile.as_string(position) + "\n"
	return text
# ------------------------------------------------------------------------------------------------ #
# --- Seen Actions/Messages ---------------------------------------------------------------------- #
# Adiciona o indice do event_log (em GameDataManager) da ação vista pelo agente
# na lista de ações vistas.
func add_seen_actions(action_index:int):
	seen_actions.append(action_index)

# Adiciona o indice do event_log (em GameDataManager) da mensagens vista pelo
# agente na lista de ações vistas.
func add_seen_messages(message_index:int):
	seen_messages.append(message_index)

# Retorna lista de indices de ações vistas pelo agente.
func get_seen_actions():
	return seen_actions

# Retorna lista de indices de mensagens vistas pelo agente.
func get_seen_messages():
	return seen_messages
# ------------------------------------------------------------------------------------------------ #
