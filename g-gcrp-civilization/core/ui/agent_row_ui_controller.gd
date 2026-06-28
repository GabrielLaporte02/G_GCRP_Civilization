class_name AgentRowUI
extends HBoxContainer

signal remove_requested(node: AgentRowUI)

@onready var agent_name: LineEdit = $AgentName
@onready var option_type: OptionButton = $OptionType
@onready var btn_remove: Button = $BtnRemove

var is_user_defined: bool = false

func _ready() -> void:
	btn_remove.pressed.connect(func(): remove_requested.emit(self))
	agent_name.text_changed.connect(_on_text_changed)
	
	option_type.clear()
	var types = AgentData.AgentType.keys()
	
	for i in range(types.size()):
		var enum_key_string = types[i]
		var display_name = enum_key_string.capitalize()
		
		option_type.add_item(display_name, i)

func _on_text_changed(_new_text: String) -> void:
	is_user_defined = true

func set_agent_name(new_name: String) -> void:
	if not is_user_defined:
		agent_name.text = new_name

func set_remove_disabled(is_disabled: bool) -> void:
	btn_remove.disabled = is_disabled
	
