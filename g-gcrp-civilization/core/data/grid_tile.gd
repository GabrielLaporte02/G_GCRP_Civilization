class_name GridTile
extends Resource

enum TileType {
	EMPTY,
	WOOD,
	FOOD,
	STONE
}

var type: TileType
var amount: int
var max_amount :int
var refil_counter : int
var refil_time : int

func _ready():
	EventBus.turn_updated.connect(_on_new_turn)

# O construtor define valores padrão (vazio e 0) se não passarmos nenhum argumento
func _init(_type: TileType = TileType.EMPTY, _amount: int = 0, _refil_time:int = 10) -> void:
	type = _type
	max_amount = _amount
	amount = max_amount
	refil_time = _refil_time
	refil_counter = refil_time

func _on_new_turn():
	if refil_counter > 0:
		refil_counter -= 1
	else:
		amount = max_amount

func get_amount():
	var value = amount
	amount = int(amount/2)
	refil_counter = refil_time
	return value
	
