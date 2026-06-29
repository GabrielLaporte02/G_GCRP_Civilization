class_name MascotUI
extends Control

@onready var bubble: PanelContainer = $VBoxContainer/SpeechBubble
@onready var label: Label = $VBoxContainer/SpeechBubble/SpeechText
@onready var cycle_timer: Timer = $CycleTimer

var phrases: Array[String] = [
	"Miau! Bem-vindo ao jogo!",
	"Você sabia que fomos criados por uma equipe de cinco pessoas?",
	"Acho que vi um bug ali... miau.",
	"Hora de investigar alguns mistérios!",
	"Qual será a próxima configuração?",
	"zzZzz... miau... zzZzz...",
	"Preciso de mais sachês para processar isso."
]

var last_phrase_index: int = -1
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	bubble.modulate.a = 0.0
	
	cycle_timer.timeout.connect(_on_timer_timeout)
	cycle_timer.start()
	
	rng.randomize()

func _on_timer_timeout() -> void:
	#_show_phrase()
	pass

func _show_phrase() -> void:
	var current_tween = create_tween()
	
	var new_index = rng.randi_range(0, phrases.size() - 1)
	while new_index == last_phrase_index:
		new_index = rng.randi_range(0, phrases.size() - 1)
		
	last_phrase_index = new_index
	label.text = phrases[new_index]
	
	# 1. Fade IN: Muda a opacidade (Alpha) para 1.0 (visível) ao longo de 0.5 segundos
	current_tween.tween_property(bubble, "modulate:a", 1.0, 0.5)
	
	# 2. Espera: Mantém o balão na tela por 4 segundos para leitura
	current_tween.tween_interval(4.0)
	
	# 3. Fade OUT: Muda a opacidade de volta para 0.0 ao longo de 0.5 segundos
	current_tween.tween_property(bubble, "modulate:a", 0.0, 0.5)
