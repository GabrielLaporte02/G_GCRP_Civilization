class_name MainMenu
extends Node

const SETUP_SCENE_PATH: String = "res://scenes/SetupScreen.tscn"

@onready var btn_start: Button = $UILayer/MainMargin/CenterAligner/MenuLayout/ButtonsVBox/BtnStart
@onready var btn_tutorial: Button = $UILayer/MainMargin/CenterAligner/MenuLayout/ButtonsVBox/BtnTutorial
@onready var btn_exit: Button = $UILayer/MainMargin/CenterAligner/MenuLayout/ButtonsVBox/BtnExit

@export var background_options: Array[Texture2D]

func _ready() -> void:
	btn_start.pressed.connect(_on_start_pressed)
	btn_tutorial.pressed.connect(_on_tutorial_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	
	btn_start.grab_focus()
	_pick_random_bg()

func _pick_random_bg():
	if background_options.is_empty():
		return
	
	var random_bg = background_options.pick_random()
	
	var bg_sprite: Sprite2D = $Background/Sprite2D
	bg_sprite.texture = random_bg

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(SETUP_SCENE_PATH)

func _on_tutorial_pressed() -> void:
	# get_tree().change_scene_to_file("res://cenas/tutorial_screen.tscn")
	print("Carregar Cena de Tutorial")

func _on_exit_pressed() -> void:
	get_tree().quit()
