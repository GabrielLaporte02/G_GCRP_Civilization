extends Resource
class_name Event

enum EventType {
	ACTION,
	MESSAGE
}

var type: EventType
var position: Vector2i
var agent_id: String
var text: String
var turn: int

func _init(
	p_type: EventType,
	p_position: Vector2i,
	p_agent_id: String,
	p_text: String,
	p_turn: int
):
	type = p_type
	position = p_position
	agent_id = p_agent_id
	text = p_text
	turn = p_turn
