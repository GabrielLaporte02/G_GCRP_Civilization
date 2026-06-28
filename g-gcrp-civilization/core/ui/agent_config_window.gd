class_name AgentConfigWindow
extends PanelContainer

@export var row_scene: PackedScene
@onready var rows_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/AgentRows
@onready var btn_add: Button = $MarginContainer/VBoxContainer/BtnAdd

const MIN_AGENTS: int = 1
const MAX_AGENTS: int = 4

func _ready() -> void:
	btn_add.pressed.connect(_on_add_pressed)
	_add_agent()

func _on_add_pressed() -> void:
	if rows_container.get_child_count() < MAX_AGENTS:
		_add_agent()
	
func _add_agent() -> void:
	var new_row = row_scene.instantiate() as AgentRowUI
	rows_container.add_child(new_row)
	new_row.remove_requested.connect(_on_row_remove_requested)
	
	_update_ui_state()

func _on_row_remove_requested(row_node: AgentRowUI) -> void:
	if rows_container.get_child_count() > MIN_AGENTS:
		row_node.queue_free()
		
		await get_tree().process_frame 
		await get_tree().process_frame
		await get_tree().process_frame
		
		_update_ui_state()

func _update_ui_state() -> void:
	var rows = rows_container.get_children()
	var current_count = rows.size()
	
	for i in range(current_count):
		var row = rows[i] as AgentRowUI
		row.set_agent_name("IA_" + str(i + 1))
		
		row.set_remove_disabled(current_count <= MIN_AGENTS)

	btn_add.disabled = (current_count >= MAX_AGENTS)

func get_agents_data() -> Dictionary:
	var agents_dict: Dictionary = {}
	
	for child in rows_container.get_children():
		var row = child as AgentRowUI
		
		var agent_name = row.agent_name.text
		var agent_type = row.option_type.get_selected_id() as AgentData.AgentType
		
		agents_dict[agent_name] = agent_type
		
	return agents_dict
