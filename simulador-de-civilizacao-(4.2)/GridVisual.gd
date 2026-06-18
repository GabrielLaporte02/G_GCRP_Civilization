extends Control

@onready var gerenciador: Gerenciador = $".."

const TAMANHO_CELULA: int = 40
const OFFSET_X: int = 400
const OFFSET_Y: int = 50

func _ready() -> void:
	# Chamada inicial garantida caso o sinal dispare antes do nó estar pronto
	atualizar_grid()

func atualizar_grid() -> void:
	# Limpar visualização anterior
	for child in get_children():
		child.queue_free()
		
	# Desenhar o grid de fundo (10x10)
	for x in range(10):
		for y in range(10):
			var bg_rect = ColorRect.new()
			bg_rect.size = Vector2(TAMANHO_CELULA - 2, TAMANHO_CELULA - 2)
			bg_rect.position = Vector2(OFFSET_X + x * TAMANHO_CELULA, OFFSET_Y + y * TAMANHO_CELULA)
			bg_rect.color = Color(0.15, 0.15, 0.15) # Fundo cinza escuro
			add_child(bg_rect)

	# Desenhar agentes
	for agente in gerenciador.agentes:
		var agente_rect = ColorRect.new()
		agente_rect.size = Vector2(TAMANHO_CELULA - 6, TAMANHO_CELULA - 6)
		# Centraliza levemente dentro do tile
		agente_rect.position = Vector2(OFFSET_X + agente.pos_x * TAMANHO_CELULA + 3, OFFSET_Y + agente.pos_y * TAMANHO_CELULA + 3)
		
		# Cor baseada na personalidade: Agressivo = Vermelho, Cooperativo = Azul
		if agente.personalidade == "Agressivo":
			agente_rect.color = Color(0.9, 0.2, 0.2)
		else:
			agente_rect.color = Color(0.2, 0.5, 0.9)
			
		add_child(agente_rect)

func _on_turno_concluido(_logs: Array) -> void:
	atualizar_grid()
