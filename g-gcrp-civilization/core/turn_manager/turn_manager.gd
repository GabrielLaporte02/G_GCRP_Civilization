class_name TurnManager
extends Node

enum TurnState {
	WAITING_FOR_PLAYER,
	WAITING_FOR_API,
	RESOLVING,
	PRESENTING,
	CLEANUP_AND_PREP
}

@export var network_handler: Node 
@export var turn_resolver: Node 
@export var turn_presenter: Node 

var current_state: TurnState = TurnState.CLEANUP_AND_PREP
var api_is_ready: bool = false
var current_intentions: Dictionary = {}

func _ready() -> void:
	network_handler.intentions_ready.connect(_on_intentions_ready)
	EventBus.next_turn_requested.connect(_run_next_turn)
	
	_start_prep_phase()


func _run_next_turn() -> void:
	if current_state != TurnState.WAITING_FOR_PLAYER:
		return 

	EventBus.turn_lock_changed.emit(true) # Tranca o botão na UI

	# Se a API ainda nao respondeu (jogador rapido demais)
	if not api_is_ready:
		current_state = TurnState.WAITING_FOR_API
		EventBus.loading_api_changed.emit(true)
		
		# Esperamos ativamente o sinal da rede ser emitido
		await network_handler.intentions_ready 
		
		EventBus.loading_api_changed.emit(false)
	
	_process_turn_resolution()


func _process_turn_resolution() -> void:
	current_state = TurnState.RESOLVING
	var turn_results = turn_resolver.resolve_turn(current_intentions)
	
	current_state = TurnState.PRESENTING
	await turn_presenter.present_turn(turn_results)
	
	_start_prep_phase()


# --- LIMPEZA E PREPARAÇÃO (Pre-Fetching) ---
func _start_prep_phase() -> void:
	current_state = TurnState.CLEANUP_AND_PREP
	api_is_ready = false
	current_intentions.clear()
	
	# Aplica as regras de fome e verifica mortes no banco de dados
	turn_resolver.apply_end_of_turn_effects()
	
	GameDataManager.current_turn += 1
	EventBus.turn_updated.emit(GameDataManager.current_turn)
	network_handler.prefetch_intentions()
	
	# IMPORTANTE: Libera o controle para o jogador, MAS a rede trabalha no fundo
	current_state = TurnState.WAITING_FOR_PLAYER
	EventBus.turn_lock_changed.emit(false)


func _on_intentions_ready(intentions: Dictionary) -> void:
	current_intentions = intentions
	api_is_ready = true
