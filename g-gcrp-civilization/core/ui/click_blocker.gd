extends ColorRect

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		accept_event()
