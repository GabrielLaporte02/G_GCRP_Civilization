extends API_Communication
class_name Agent_Comm_Manager

@export var game_data_manager : Game_Data_Manager

# --- Funções de mensagens  ---------------------------------------------------------------------- #
# Cria o prompt inicial que da o contexto a IA e indica como ela deve se comportar.
func create_system_prompt():
	system_prompt = FileAccess.get_file_as_string("res://core/api/System_Prompt_Agente_IA_Civilization.txt")

# Cria mensagem que será enviada para o agente, dando o contexto atual para que ele decida quais
# ações ele deve tomar a seguir.
func create_message_to_agent(agent_id:String):
	var prompt := ""
	prompt += "# USER PROMPT – ESTADO ATUAL DA SIMULAÇÃO\n\n"
	prompt += "As informações abaixo representam o estado atual do mundo.\n"
	prompt += "Utilize apenas essas informações juntamente com as regras definidas no System Prompt.\n\n"
	# ------------------------------------------------------------
	prompt += "==================================================\n"
	prompt += "STATUS\n"
	prompt += "==================================================\n\n"
	prompt += get_status(agent_id)
	# ------------------------------------------------------------
	prompt += "\n==================================================\n"
	prompt += "MAPA CONHECIDO\n"
	prompt += "==================================================\n\n"
	prompt += get_known_map(agent_id)
	# ------------------------------------------------------------
	prompt += "\n==================================================\n"
	prompt += "POSIÇÃO ATUAL\n"
	prompt += "==================================================\n\n"
	prompt += get_current_position(agent_id)
	# ------------------------------------------------------------
	prompt += "\n==================================================\n"
	prompt += "ÁREA VISÍVEL\n"
	prompt += "==================================================\n\n"
	prompt += get_visible_area(agent_id)
	# ------------------------------------------------------------
	prompt += "\n==================================================\n"
	prompt += "EVENTOS E RESULTADOS\n"
	prompt += "==================================================\n\n"
	prompt += get_recent_events(agent_id)
	# ------------------------------------------------------------
	prompt += "\n==================================================\n"
	prompt += "CONVERSAS\n"
	prompt += "==================================================\n\n"
	prompt += get_recent_messages(agent_id)
	# ------------------------------------------------------------
	prompt += """
==================================================
DECIDA SUAS AÇÕES
==================================================

Com base nas informações acima:

- Escolha exatamente DUAS ações.

- Caso exista um agente adjacente no início do turno,
escolha também uma interação e indique o alvo.

- Caso não exista agente adjacente:

"acao": null

"alvo": null

- Envie uma mensagem de no máximo 50 caracteres ou uma string vazia.

Responda SOMENTE com o JSON especificado no System Prompt.
"""
	return prompt
# ------------------------------------------------------------------------------------------------ #
# --- Funções de obter dados do agente  ---------------------------------------------------------- #
static func get_status(agent_id:String) -> String:
	return GameDataManager.get_agent_full_status(agent_id)


static func get_known_map(agent_id:String) -> String:
	return GameDataManager.get_agent_known_map(agent_id)


static func get_current_position(agent_id:String) -> String:
	var position_vector:Vector2i = GameDataManager.get_agent_position(agent_id)
	var possition_string = "({0}, {1})".format([position_vector.x, position_vector.y])
	return possition_string


static func get_visible_area(agent_id:String) -> String:
	return GameDataManager.get_agent_seen_map(agent_id)


static func get_recent_events(agent_id:String) -> String:
	return GameDataManager.get_agent_events_and_results(agent_id)


static func get_recent_messages(agent_id:String) -> String:
	return GameDataManager.get_agent_conversations(agent_id)
# ------------------------------------------------------------------------------------------------ #
# --- Funções de comunicação com IA  ------------------------------------------------------------- #
func send_message(agent_id:String):
	send_request(create_message_to_agent(agent_id))
# ------------------------------------------------------------------------------------------------ #
