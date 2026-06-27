class_name AgentData
extends Resource

enum AgentType {
	AGGRESSIVE,
	COOPERATIVE
}

var agent_name: String
var personality: AgentType

var health: int
var position: Vector2i
var combat_power: int
var vision_range: int
var inventory: Dictionary

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
