extends Resource
class_name Agente

var nome: String = ""
var vida: int = 5
var visao: int = 1
var combate: int = 1
var comida: int = 0
var madeira: int = 0
var pedra: int = 0
var pos_x: int = 0
var pos_y: int = 0
var personalidade: String = ""

func _init(_nome: String = "Desconhecido", _personalidade: String = "Fugir", _x: int = 0, _y: int = 0) -> void:
	nome = _nome
	personalidade = _personalidade
	pos_x = _x
	pos_y = _y

# Lógica temporária e hardcoded de decisão baseada na personalidade
func decidir_acao() -> String:
	if personalidade == "Agressivo":
		return "Atacar"
	elif personalidade == "Cooperativo":
		return "Cooperar"
	else:
		return "Fugir"
