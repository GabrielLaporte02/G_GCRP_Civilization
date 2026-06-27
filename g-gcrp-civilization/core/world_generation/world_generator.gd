class_name WorldGenerator
extends Node

var _noise_stone: FastNoiseLite
var _noise_wood: FastNoiseLite
var _noise_food: FastNoiseLite

func generate_world(stone_abundance: WorldConfig.AbundanceLevel, 
					wood_abundance: WorldConfig.AbundanceLevel, 
					food_abundance: WorldConfig.AbundanceLevel) -> void:
	var t_stone: float = WorldConfig.ABUNDANCE_THRESHOLDS[stone_abundance]
	var t_wood: float  = WorldConfig.ABUNDANCE_THRESHOLDS[wood_abundance]
	var t_food: float  = WorldConfig.ABUNDANCE_THRESHOLDS[food_abundance]
	
	#randomiza seeds para valores sempre diferentes
	randomize()
	_noise_stone = _create_noise_layer(randi())
	_noise_wood = _create_noise_layer(randi())
	_noise_food = _create_noise_layer(randi())
	
	var new_grid: Array = [] 
	for x in range(GameDataManager.GRID_WIDTH):
		var column: Array = []
		for y in range(GameDataManager.GRID_HEIGHT):
			var tile_type = _determine_tile_type(x, y, t_stone, t_wood, t_food)
			
			# Lembrar de criar algo para definir o amount de recursos em um unico tile depois
			var amount = 0
			if tile_type != GridTile.TileType.EMPTY:
				amount = 50 
				
			column.append(GridTile.new(tile_type, amount))
		new_grid.append(column)
	GameDataManager.set_full_grid(new_grid)
	
	EventBus.world_generated.emit()

func _create_noise_layer(layer_seed: int) -> FastNoiseLite:
	var noise = FastNoiseLite.new()
	noise.seed = layer_seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.15
	return noise

func _determine_tile_type(x: int, y: int, t_stone: float, t_wood: float, t_food: float) -> GridTile.TileType:
	
	# Somamos 1 e dividimos por 2 para esmagar o valor entre 0.0 e 1.0, facilitando a matemática.
	var val_stone = (_noise_stone.get_noise_2d(x, y) + 1.0) / 2.0
	var val_wood = (_noise_wood.get_noise_2d(x, y) + 1.0) / 2.0
	var val_food = (_noise_food.get_noise_2d(x, y) + 1.0) / 2.0
	
	# Hierarquia (Comida > Madeira > Pedra)
	if val_food > t_food:
		return GridTile.TileType.FOOD
	elif val_wood > t_wood:
		return GridTile.TileType.WOOD
	elif val_stone > t_stone:
		return GridTile.TileType.STONE
	else:
		return GridTile.TileType.EMPTY
