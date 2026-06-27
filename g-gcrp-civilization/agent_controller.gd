extends Node2D
class_name AgentSprite

@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@export var move_duration: float = 0.3
var _agent_id: String
var expected_size: float = 64 # Tamanho em pixels

func _ready() -> void:
	# Adaptando tamanho do sprite ao desejado
	if sprite.texture:
		var width_texture = sprite.texture.get_width()
		var height_texture = sprite.texture.get_height()
		
		sprite.scale = Vector2(
			expected_size / width_texture,
			expected_size / height_texture
		)
		
	# Adaptando tamanho da colisao ao planejado
	var rect = RectangleShape2D.new()
	rect.size = Vector2(expected_size, expected_size)
	collision_shape.shape = rect

func setup(agent_id: String) -> void:
	_agent_id = agent_id

# Retorna o Tween para que o Gerenciador possa usar "await move_to().finished"
func move_to(new_pixel_position: Vector2) -> Tween:
	var tween = create_tween()
	
	tween.tween_property(self, "position", new_pixel_position, move_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	return tween

# Sinais conectados a partir do nó Area2D filho
func _on_area_2d_mouse_entered() -> void:
	print("A UI de ", _agent_id, " deve aparecer agora")

func _on_area_2d_mouse_exited() -> void:
	# ocultar a UI
	pass

#play_animation(action_type) para rodar animacoes ta faltando
