extends Node

@onready var turn_resolver: Node = $TurnResolver
@onready var generator: Node = $Node

func _ready() -> void:
	run_test_scenarios()

func run_test_scenarios():
	generator.generate_world(WorldConfig.AbundanceLevel.SCARCE,WorldConfig.AbundanceLevel.ABUNDANT, WorldConfig.AbundanceLevel.NORMAL,
	{"Agente1": AgentData.AgentType.AGGRESSIVE, "Agente2": AgentData.AgentType.AGGRESSIVE})
	
	GameDataManager.clear_agents()
	GameDataManager.register_agent("IA1", Vector2i(0,0), AgentData.AgentType.AGGRESSIVE)
	GameDataManager.register_agent("IA2", Vector2i(1,1), AgentData.AgentType.AGGRESSIVE)
	GameDataManager.register_agent("IA3", Vector2i(2,2), AgentData.AgentType.COOPERATIVE)
	GameDataManager._ai_agents["IA1"].combat_power = 5

	var scenarios = [
		# Caso 1: Todos no mesmo tile, IA1 ataca IA2, IA3 coopera
		{"IA1": {"interacao_agente": {"acao": "Atacar", "alvo": "IA2"}}, 
		 "IA2": {"interacao_agente": {"acao": "Fugir", "alvo": ""}}, 
		 "IA3": {"interacao_agente": {"acao": "Cooperar", "alvo": ""}}},
		
		# Caso 2: IA2 esquiva do ataque de IA1
		{"IA1": {"interacao_agente": {"acao": "Atacar", "alvo": "IA2"}}, 
		 "IA2": {"interacao_agente": {"acao": "Fugir", "alvo": ""}}, 
		 "IA3": {"interacao_agente": {"acao": "Atacar", "alvo": "IA1"}}},

		# Caso 3: IA1 e IA2 atacam IA3 (diferentes alvos)
		{"IA1": {"interacao_agente": {"acao": "Atacar", "alvo": "IA3"}}, 
		 "IA2": {"interacao_agente": {"acao": "Atacar", "alvo": "IA3"}}, 
		 "IA3": {"interacao_agente": {"acao": "Fugir", "alvo": ""}}},

		# Caso 4: Todos em tiles separados (nenhuma interação de combate efetiva)
		{"IA1": {"interacao_agente": {"acao": "Atacar", "alvo": "IA2"}}, 
		 "IA2": {"interacao_agente": {"acao": "Cooperar", "alvo": ""}}, 
		 "IA3": {"interacao_agente": {"acao": "Atacar", "alvo": "IA1"}}},
		 
		# Caso 5: IA1 mata IA2
		{"IA1": {"interacao_agente": {"acao": "Atacar", "alvo": "IA2"}}, 
		 "IA2": {"interacao_agente": {"acao": "Atacar", "alvo": "IA3"}}, 
		 "IA3": {"interacao_agente": {"acao": "Cooperar", "alvo": ""}}}
	]

	for i in range(scenarios.size()):
		print("--- Teste ", i + 1, " ---")
		var result = turn_resolver.resolve_turn(scenarios[i])
		print(result)
