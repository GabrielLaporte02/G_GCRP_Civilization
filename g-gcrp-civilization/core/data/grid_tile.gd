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

# O construtor define valores padrão (vazio e 0) se não passarmos nenhum argumento
func _init(_type: TileType = TileType.EMPTY, _amount: int = 0) -> void:
	type = _type
	amount = _amount
