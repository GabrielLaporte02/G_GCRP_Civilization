extends Resource
class_name AgentData

enum AgentType {
	AGGRESSIVE,
	COOPERATIVE
}

enum InteracActions{
	ATTACK,
	COOPERATE,
	FLEE
}

enum WorldActions{
	MOVEGATHER,
	UPGRADE_WEAPON,
	HEAL,
	UPGRADE_VISION,
	CONVERT_RESOURCE,
	NONE
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
