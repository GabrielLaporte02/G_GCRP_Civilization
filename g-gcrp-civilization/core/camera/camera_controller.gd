extends Camera2D

@export var floor_layer: TileMapLayer
@export var objects_layer: TileMapLayer

# Zoom Variables
@export var min_zoom: float = 0.4
@export var max_zoom: float = 3.0
@export var step_zoom: float = 0.1
@export var zoom_smoothness: float = 10
var _target_zoom: Vector2 = Vector2.ONE

# Pan Variables
@export var pan_smoothness: float = 10
var _target_position: Vector2 = Vector2.ZERO
var _is_dragging: bool = false

func _ready() -> void:
	await get_tree().process_frame
	_target_zoom = zoom
	_target_position = global_position
	update_camera_limits()
	EventBus.world_generated.connect(update_camera_limits)

func _process(delta: float) -> void:
	zoom = zoom.lerp(_target_zoom, zoom_smoothness * delta)
	global_position = global_position.lerp(_target_position, pan_smoothness * delta)
	# Opcional: Aqui você pode adicionar lógica para dar 'clamp' na global_position
	# e garantir que a câmera (mesmo após o lerp) não passe do limite do mapa.

func update_camera_limits() -> void:
	if not floor_layer or not objects_layer:
		push_warning("Camera2D: As camadas floor e objects não foram atribuídas no Inspector.")
		return

	# Combina os Grids
	var rect_floor = floor_layer.get_used_rect()
	var rect_objects = objects_layer.get_used_rect()
	var combined_rect = rect_floor.merge(rect_objects)

	# Calculo de posições exatas do grid na tela
	var tile_size = floor_layer.tile_set.tile_size
	var pixel_position = combined_rect.position * tile_size
	var pixel_size = combined_rect.size * tile_size

	limit_left = pixel_position.x
	limit_top = pixel_position.y
	limit_right = pixel_position.x + pixel_size.x
	limit_bottom = pixel_position.y + pixel_size.y

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom += Vector2(step_zoom, step_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom -= Vector2(step_zoom, step_zoom)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_is_dragging = event.pressed
	
	if event is InputEventMouseMotion and _is_dragging:
		_target_position -= event.relative / zoom
	
	# Clamp positions para evitar sensações ruins do usuário
	_target_zoom = _target_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	_target_position.x = clamp(_target_position.x, limit_left + (get_viewport_rect().size.x / 2 / zoom.x), limit_right - (get_viewport_rect().size.x / 2 / zoom.x))
	_target_position.y = clamp(_target_position.y, limit_top + (get_viewport_rect().size.y / 2 / zoom.y), limit_bottom - (get_viewport_rect().size.y / 2 / zoom.y))
