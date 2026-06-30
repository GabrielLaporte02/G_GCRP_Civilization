extends CanvasLayer
class_name SimulationHUD

const AGENT_BUTTON_GROUP := "simulation_hud_agent_buttons"

@onready var btn_next_turn: Button = %BtnNextTurn
@onready var turn_label: Label = %TurnLabel
@onready var api_status_label: Label = %ApiStatusLabel
@onready var agents_list: VBoxContainer = %AgentsList
@onready var agent_name_label: Label = %AgentNameLabel
@onready var agent_details_label: Label = %AgentDetailsLabel
@onready var empty_state_label: Label = %EmptyStateLabel

var selected_agent_id: String = ""
var _refresh_elapsed: float = 0.0

func _ready() -> void:
	btn_next_turn.pressed.connect(_on_next_turn_pressed)
	EventBus.turn_lock_changed.connect(_on_turn_lock_changed)
	EventBus.loading_api_changed.connect(_on_loading_api_changed)
	EventBus.turn_updated.connect(_on_turn_updated)
	EventBus.world_generated.connect(_on_agents_changed)
	EventBus.agents_updated.connect(_on_agents_changed)
	
	_on_turn_updated(GameDataManager.get_current_turn())
	_refresh_agents()

func _process(delta: float) -> void:
	_refresh_elapsed += delta
	if _refresh_elapsed >= 0.25:
		_refresh_elapsed = 0.0
		_refresh_agent_buttons()
		_refresh_selected_agent()

func _on_next_turn_pressed() -> void:
	var has_turn_manager := not EventBus.get_signal_connection_list("next_turn_requested").is_empty()
	EventBus.next_turn_requested.emit()
	
	if not has_turn_manager:
		GameDataManager.current_turn += 1
		EventBus.turn_updated.emit(GameDataManager.current_turn)
		EventBus.agents_updated.emit()

func _on_turn_lock_changed(is_locked: bool) -> void:
	btn_next_turn.disabled = is_locked

func _on_loading_api_changed(is_loading: bool) -> void:
	api_status_label.text = "IA pensando..." if is_loading else "Pronto"

func _on_turn_updated(new_turn_number: int) -> void:
	turn_label.text = "Turno: " + str(new_turn_number)
	_refresh_selected_agent()

func _on_agents_changed() -> void:
	_refresh_agents()

func _refresh_agents() -> void:
	for child in agents_list.get_children():
		child.queue_free()
	
	var agent_ids := GameDataManager._ai_agents.keys()
	agent_ids.sort()
	
	if agent_ids.is_empty():
		selected_agent_id = ""
		_show_empty_state()
		return
	
	if selected_agent_id == "" or not GameDataManager._ai_agents.has(selected_agent_id):
		selected_agent_id = agent_ids[0]
	
	for agent_id in agent_ids:
		var button := Button.new()
		button.text = _get_agent_button_text(agent_id)
		button.toggle_mode = true
		button.button_pressed = agent_id == selected_agent_id
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.set_meta("agent_id", agent_id)
		button.add_to_group(AGENT_BUTTON_GROUP)
		button.pressed.connect(_on_agent_button_pressed.bind(agent_id))
		agents_list.add_child(button)
	
	_refresh_selected_agent()

func _on_agent_button_pressed(agent_id: String) -> void:
	selected_agent_id = agent_id
	for button in get_tree().get_nodes_in_group(AGENT_BUTTON_GROUP):
		if button is Button:
			button.button_pressed = str(button.get_meta("agent_id", "")) == agent_id
	_refresh_selected_agent()

func _refresh_agent_buttons() -> void:
	for button in agents_list.get_children():
		if not (button is Button):
			continue
		
		var agent_id := str(button.get_meta("agent_id", ""))
		if GameDataManager._ai_agents.has(agent_id):
			button.text = _get_agent_button_text(agent_id)
			button.button_pressed = agent_id == selected_agent_id

func _refresh_selected_agent() -> void:
	if selected_agent_id == "" or not GameDataManager._ai_agents.has(selected_agent_id):
		_show_empty_state()
		return
	
	empty_state_label.hide()
	agent_name_label.show()
	agent_details_label.show()
	
	var agent: AgentData = GameDataManager._ai_agents[selected_agent_id]
	agent_name_label.text = agent.agent_name
	agent_details_label.text = _format_agent_details(agent)

func _show_empty_state() -> void:
	empty_state_label.show()
	agent_name_label.hide()
	agent_details_label.hide()
	empty_state_label.text = "Nenhum agente na simulacao."

func _get_agent_button_text(agent_id: String) -> String:
	var agent: AgentData = GameDataManager._ai_agents[agent_id]
	return "%s  HP %d  (%d, %d)" % [
		agent.agent_name,
		agent.health,
		agent.position.x,
		agent.position.y
	]

func _format_agent_details(agent: AgentData) -> String:
	var personality := "Cooperador"
	if agent.personality == AgentData.AgentType.Egoista:
		personality = "Egoista"
	elif agent.personality == AgentData.AgentType.Agressivo:
		personality = "Agressivo"
	elif agent.personality == AgentData.AgentType.Estratégico:
		personality = "Estratégico"
	
	var lines := [
		"Vida: " + str(agent.health),
		"Personalidade: " + personality,
		"Posicao: (%d, %d)" % [agent.position.x, agent.position.y],
		"Combate: " + str(agent.combat_power),
		"Visao: " + str(agent.vision_range),
		"",
		"Inventario",
		"Comida: " + str(agent.inventory.get("food", 0)),
		"Madeira: " + str(agent.inventory.get("wood", 0)),
		"Pedra: " + str(agent.inventory.get("stone", 0)),
		"",
		"Memoria",
		"Acoes vistas: " + str(agent.seen_actions.size()),
		"Mensagens vistas: " + str(agent.seen_messages.size())
	]
	
	var text := ""
	for line in lines:
		text += str(line) + "\n"
	return text.strip_edges(false, true)
