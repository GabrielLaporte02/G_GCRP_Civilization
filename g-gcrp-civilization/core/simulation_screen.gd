extends Node2D


func _ready() -> void:
	EventBus.world_generated.emit()
