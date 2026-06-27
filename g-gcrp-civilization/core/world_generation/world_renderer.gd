class_name WorldRenderer
extends Node

const PATTERN_SIZE: int = 10 

const FLOOR_PATTERN_IDS: Dictionary = {
	GridTile.TileType.WOOD: [16],
	GridTile.TileType.STONE: [17],
	GridTile.TileType.FOOD: [18],
	GridTile.TileType.EMPTY: [19]
}

const OBJECT_PATTERN_IDS: Dictionary = {
	GridTile.TileType.WOOD: [0, 1, 2, 3],
	GridTile.TileType.STONE: [4, 5, 6, 7],
	GridTile.TileType.FOOD: [8, 9, 10, 11],
	GridTile.TileType.EMPTY: [12, 13, 14, 15] 
}

@export var agents_container: Node2D
@export var agent_scene: PackedScene

@onready var layer_floor: TileMapLayer = $Floor
@onready var layer_objects: TileMapLayer = $Objects

func _ready() -> void:
	EventBus.world_generated.connect(_on_requested_generation)

func _on_requested_generation() -> void:
	render_world()

func render_world() -> void:
	clean_grid()
	
	var grid = GameDataManager.get_full_grid()
	
	for x in range(GameDataManager.GRID_WIDTH):
		for y in range(GameDataManager.GRID_HEIGHT):
			var tile: GridTile = grid[x][y]
			
			var visual_pos = Vector2i(x * PATTERN_SIZE, y * PATTERN_SIZE)
			
			if FLOOR_PATTERN_IDS.has(tile.type):
				var floor_id = FLOOR_PATTERN_IDS[tile.type].pick_random()
				var floor_pattern = layer_floor.tile_set.get_pattern(floor_id)
				
				if floor_pattern:
					layer_floor.set_pattern(visual_pos, floor_pattern)
					
			if OBJECT_PATTERN_IDS.has(tile.type):
				var obj_id = OBJECT_PATTERN_IDS[tile.type].pick_random()
				var obj_pattern = layer_objects.tile_set.get_pattern(obj_id)
				
				if obj_pattern:
					layer_objects.set_pattern(visual_pos, obj_pattern)
	spawn_agents()
	
func spawn_agents() -> void:
	var ai_agents = GameDataManager._ai_agents
	var tile_size: int = 160
	var half_tile: float = tile_size / 2.0
	
	# Chave: posicao em Vector2i | Valor: Array de referências de instâncias
	var occupancy_map: Dictionary = {}
	
	# --- PASSO 1: Instanciação e Agrupamento ---
	for agent_id in ai_agents:
		var agent_data = ai_agents[agent_id]
		var pos: Vector2i = agent_data.position
		
		# Instanciando agente
		var agent_instance = agent_scene.instantiate()
		agents_container.add_child(agent_instance)
		agent_instance.setup(agent_id)
			
		# Calcula posição base (centro do tile)
		var base_pixel_pos = Vector2(pos.x * tile_size + half_tile, pos.y * tile_size + half_tile)
		
		# Agrupa as instâncias pela coordenada do grid
		if not occupancy_map.has(pos):
			occupancy_map[pos] = []
			
		occupancy_map[pos].append({
			"node": agent_instance,
			"base_pos": base_pixel_pos
		})

	# --- PASSO 2: Organização Espacial (Offsets) ---
	var offset_amount: float = 40
	
	for pos in occupancy_map:
		var agents_in_tile: Array = occupancy_map[pos]
		var count: int = agents_in_tile.size()
		
		# Itera sobre os agentes que dividem o mesmo tile para aplicar a cruz
		for i in range(count):
			var agent_info = agents_in_tile[i]
			var node = agent_info["node"]
			var final_pos: Vector2 = agent_info["base_pos"]
			
			if count == 2:
				match i:
					0: final_pos.x -= offset_amount # Esquerda
					1: final_pos.x += offset_amount # Direita
			
			elif count == 3:
				match i:
					0: final_pos.x -= offset_amount # Esquerda
					1: final_pos.x += offset_amount # Direita
					2: final_pos.y -= offset_amount # Cima
					
			elif count >= 4:
				match i:
					0: final_pos.x -= offset_amount # Esquerda
					1: final_pos.x += offset_amount # Direita
					2: final_pos.y -= offset_amount # Cima
					3: final_pos.y += offset_amount # Baixo
			
			# Caso seja count == 1, ele apenas pula os if/elif e mantém a base_pos (centro)
			node.position = final_pos
	

func clean_grid() -> void:
	layer_floor.clear()
	layer_objects.clear()
	
	for child in agents_container.get_children():
		child.queue_free()
