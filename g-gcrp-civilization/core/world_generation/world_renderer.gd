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
					
func clean_grid() -> void:
	layer_floor.clear()
	layer_objects.clear()
