extends Node
class_name Gerenciador

signal turno_concluido(logs: Array)

var agentes: Array[Agente] = []
var log_do_turno: Array[String] = []

func _ready() -> void:
	randomize()
	_gerar_agentes_iniciais()

func _gerar_agentes_iniciais() -> void:
	var personalidades: Array[String] = ["Agressivo", "Cooperativo"]
	
	for i in range(4):
		# Posições aleatórias num grid de 10x10 (0 a 9)
		var x: int = randi() % 10
		var y: int = randi() % 10
		var personalidade_escolhida: String = personalidades[randi() % personalidades.size()]
		
		var novo_agente: Agente = Agente.new("Agente_" + str(i + 1), personalidade_escolhida, x, y)
		agentes.append(novo_agente)
		
		_registrar_log("Gerado: %s | Personalidade: %s | Posição: (%d, %d)" % [novo_agente.nome, novo_agente.personalidade, x, y])
	
	# Emite os logs iniciais de geração na interface se necessário
	turno_concluido.emit(log_do_turno)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		reiniciar_simulacao()

func reiniciar_simulacao() -> void:
	agentes.clear()
	log_do_turno.clear()
	_registrar_log("--- SIMULAÇÃO REINICIADA ---")
	_gerar_agentes_iniciais()

func _registrar_log(msg: String) -> void:
	log_do_turno.append(msg)
	print(msg)

func resolver_turno() -> void:
	log_do_turno.clear()
	_registrar_log("--- INÍCIO DO TURNO ---")
	
	# 0. Movimentação Aleatória
	for agente in agentes:
		var dir_x: int = (randi() % 3) - 1 # -1, 0, ou 1
		var dir_y: int = (randi() % 3) - 1
		agente.pos_x = clamp(agente.pos_x + dir_x, 0, 9)
		agente.pos_y = clamp(agente.pos_y + dir_y, 0, 9)
	
	# 1. Resolver Fome e Sobrevivência
	for i in range(agentes.size() - 1, -1, -1):
		var agente: Agente = agentes[i]
		
		if agente.comida >= 1:
			agente.comida -= 1
		else:
			agente.vida -= 1
			_registrar_log("%s perdeu 1 de vida por fome. (Vida atual: %d)" % [agente.nome, agente.vida])
			
		# Verifica morte
		if agente.vida <= 0:
			_registrar_log("☠️ %s morreu!" % agente.nome)
			agentes.remove_at(i)
			
	# 2. Resolver Interações e Combate
	var tamanho: int = agentes.size()
	for i in range(tamanho):
		for j in range(i + 1, tamanho):
			var a1: Agente = agentes[i]
			var a2: Agente = agentes[j]
			
			if a1.pos_x == a2.pos_x and a1.pos_y == a2.pos_y:
				_resolver_encontro(a1, a2)
				
	_registrar_log("--- FIM DO TURNO ---")
	
	# Dispara o sinal enviando o log completo do turno para a UI
	turno_concluido.emit(log_do_turno)

func _resolver_encontro(a1: Agente, a2: Agente) -> void:
	var acao1: String = a1.decidir_acao()
	var acao2: String = a2.decidir_acao()
	
	_registrar_log("\n⚔️ Encontro em (%d, %d) entre %s e %s" % [a1.pos_x, a1.pos_y, a1.nome, a2.nome])
	_registrar_log("Decisões -> %s: %s | %s: %s" % [a1.nome, acao1, a2.nome, acao2])
	
	# Matriz de resolução de conflito simplificada
	if acao1 == "Atacar" and acao2 == "Atacar":
		if a1.combate > a2.combate:
			_vencer_conflito(a1, a2)
		elif a2.combate > a1.combate:
			_vencer_conflito(a2, a1)
		else:
			# Empate
			a1.vida -= 1
			a2.vida -= 1
			_registrar_log("Empate no combate! Ambos perdem 1 de vida.")
			
	elif acao1 == "Atacar" and acao2 == "Cooperar":
		_vencer_conflito(a1, a2)
		
	elif acao2 == "Atacar" and acao1 == "Cooperar":
		_vencer_conflito(a2, a1)
		
	elif acao1 == "Cooperar" and acao2 == "Cooperar":
		_registrar_log("🤝 Ambos cooperaram pacificamente.")
		
	else:
		_registrar_log("🏃 Um dos agentes decidiu fugir. Nenhum conflito ocorreu.")

func _vencer_conflito(vencedor: Agente, perdedor: Agente) -> void:
	_registrar_log("🏆 %s venceu e roubou os recursos de %s!" % [vencedor.nome, perdedor.nome])
	
	# Transfere os recursos
	vencedor.comida += perdedor.comida
	vencedor.madeira += perdedor.madeira
	vencedor.pedra += perdedor.pedra
	
	# Zera os recursos do perdedor e causa dano
	perdedor.comida = 0
	perdedor.madeira = 0
	perdedor.pedra = 0
	perdedor.vida -= 1
