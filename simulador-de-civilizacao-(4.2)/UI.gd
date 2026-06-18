extends CanvasLayer

@onready var log_label: RichTextLabel = $Panel/RichTextLabel

func _on_turno_concluido(logs: Array) -> void:
	log_label.text = ""
	for msg in logs:
		log_label.text += str(msg) + "\n"
