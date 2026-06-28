class_name SetupController
extends Node

@onready var background: ColorRect = $Background
@onready var config_window: PanelContainer = $WorldConfig/PanelContainer
@onready var reroll_hud: PanelContainer = $RerollHUD/PanelContainer
@onready var agent_config: PanelContainer = $AgentConfigWindow

# Referências aos botões de ação
@onready var btn_generate: Button = $WorldConfig/PanelContainer/MarginContainer/VBoxContainer/BtnGenerate
@onready var btn_close_world_config: Button = $WorldConfig/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/BtnClose
@onready var btn_close_agent_config: Button = $AgentConfigWindow/MarginContainer/VBoxContainer/HBoxContainer/BtnClose
@onready var btn_reopen: Button = $RerollHUD/PanelContainer/MarginContainer/HBoxContainer/BtnReopen
@onready var btn_reroll: Button = $RerollHUD/PanelContainer/MarginContainer/HBoxContainer/BtnReroll
@onready var btn_agents: Button = $WorldConfig/PanelContainer/MarginContainer/VBoxContainer/GridContainer/BtnAgents

# Referências aos OptionButtons para ler os dados
@onready var opt_turns: OptionButton = $WorldConfig/PanelContainer/MarginContainer/VBoxContainer/GridContainer/OptionTurns
@onready var opt_wood: OptionButton = $WorldConfig/PanelContainer/MarginContainer/VBoxContainer/GridContainer/OptionWood
@onready var opt_stone: OptionButton = $WorldConfig/PanelContainer/MarginContainer/VBoxContainer/GridContainer/OptionStone
@onready var opt_food: OptionButton = $WorldConfig/PanelContainer/MarginContainer/VBoxContainer/GridContainer/OptionFood

func _ready() -> void:
	config_window.show()
	background.show()
	reroll_hud.hide()
	agent_config.hide()
	
	#Conectando Butoes as suas respectivas funcoes
	btn_generate.pressed.connect(_on_generate_pressed)
	btn_close_world_config.pressed.connect(_on_close_world_config_pressed)
	btn_close_agent_config.pressed.connect(_on_close_agent_config_pressed)
	btn_reopen.pressed.connect(_on_reopen_pressed)
	btn_reroll.pressed.connect(_on_reroll_pressed)
	btn_agents.pressed.connect(_on_agents_pressed)
	_populate_dropdowns()
	
func _on_generate_pressed() -> void:
	config_window.hide()
	reroll_hud.show()
	agent_config.hide()
	background.hide()
	
	_trigger_world_generation()

func _on_close_world_config_pressed() -> void:
	config_window.hide()
	reroll_hud.show()
	agent_config.hide()
	background.hide()

func _on_close_agent_config_pressed() -> void:
	config_window.show()
	reroll_hud.hide()
	agent_config.hide()
	background.show()

func _on_reopen_pressed() -> void:
	config_window.show()
	reroll_hud.hide()
	agent_config.hide()
	background.show()
	
func _on_reroll_pressed() -> void:
	_trigger_world_generation()

func _on_agents_pressed() -> void:
	config_window.hide()
	reroll_hud.hide()
	agent_config.show()
	background.show()

func _trigger_world_generation() -> void:
	var agents_config: Dictionary = agent_config.get_agents_data()
	var turn_value = opt_turns.get_selected_id()
	var wood_val = opt_wood.get_selected_id() as WorldConfig.AbundanceLevel
	var stone_val = opt_stone.get_selected_id() as WorldConfig.AbundanceLevel
	var food_val = opt_food.get_selected_id() as WorldConfig.AbundanceLevel
	
	GameDataManager.current_turn = turn_value
	EventBus.world_gen_requested.emit(stone_val, wood_val, food_val, agents_config)
	
func _populate_dropdowns() -> void:
	opt_wood.clear()
	opt_stone.clear()
	opt_food.clear()
	
	for level_key in WorldConfig.ABUNDANCE_NAMES:
		var display_name: String = WorldConfig.ABUNDANCE_NAMES[level_key]
		
		# O primeiro parâmetro é o que o jogador lê, o segundo é o ID atrelado (o valor do Enum)
		opt_wood.add_item(display_name, level_key)
		opt_stone.add_item(display_name, level_key)
		opt_food.add_item(display_name, level_key)
		
	for turn_opt in WorldConfig.TURN_OPTIONS:
		var number: String = str(turn_opt)
		opt_turns.add_item(number, turn_opt)
	
	opt_wood.select(opt_wood.get_item_index(WorldConfig.AbundanceLevel.NORMAL))
	opt_stone.select(opt_stone.get_item_index(WorldConfig.AbundanceLevel.NORMAL))
	opt_food.select(opt_food.get_item_index(WorldConfig.AbundanceLevel.NORMAL))
