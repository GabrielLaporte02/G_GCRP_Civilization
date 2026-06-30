extends Resource
class_name TileMemory

var known: bool = false

var has_food: bool = false
var has_wood: bool = false
var has_stone: bool = false

var agents: Array[String] = []

var tile_cord : Vector2i

func _init(x : int, y : int) -> void:
	tile_cord = Vector2i(x, y)

# Atualiza o que tem no tile.
func update(food: bool, wood: bool, stone: bool, visible_agents: Array) -> void:
	known = true
	has_food = food
	has_wood = wood
	has_stone = stone
	agents.clear()
	agents.append_array(visible_agents)


# Retorna o que tem no tile como formato de uma string.
func as_string(agent_position:Vector2i) -> String:
	var content: Array[String] = []
	if !known:
		content.append("?")
	else:
		if agent_position == tile_cord:
			content.append("X")
		if has_food:
			content.append("F")
		if has_wood:
			content.append("W")
		if has_stone:
			content.append("S")
		for agent in agents:
			content.append("A(%s)" % agent)
		if content.is_empty():
			content.append(".")
	return "(%d,%d): %s" % [tile_cord.x, tile_cord.y, " ".join(content)]
