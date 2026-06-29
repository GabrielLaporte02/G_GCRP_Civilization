extends API_Communication
class_name Agent_Comm_Manager


# --- Funções do sistema  ------------------------------------------------------------------------ #
func _ready():
	configura_http()
	create_system_prompt()
	init_message_list()
# ------------------------------------------------------------------------------------------------ #
# --- Funções de mensagens  ---------------------------------------------------------------------- #
# Cria o prompt inicial que da o contexto a IA e indica como ela deve se comportar.
func create_system_prompt():
	system_prompt = FileAccess.get_file_as_string("res://core/api/System_Prompt_Agente_IA_Civilization.txt")

# Cria mensagem que será enviada para o agente, dando o contexto atual para que ele decida quais
# ações ele deve tomar a seguir.
func create_message_to_agent():
	var prompt := ""
	prompt += "# USER PROMPT – ESTADO ATUAL DA SIMULAÇÃO\n\n"
	prompt += "As informações abaixo representam o estado atual do mundo.\n"
	prompt += "Utilize apenas essas informações juntamente com as regras definidas no System Prompt.\n\n"
	# ------------------------------------------------------------
	prompt += "==================================================\n"
	prompt += "STATUS\n"
	prompt += "==================================================\n\n"
	prompt += get_status()
	# ------------------------------------------------------------
	prompt += "\n==================================================\n"
	prompt += "MAPA CONHECIDO\n"
	prompt += "==================================================\n\n"
	prompt += get_known_map()
	# ------------------------------------------------------------
	prompt += "\n==================================================\n"
	prompt += "POSIÇÃO ATUAL\n"
	prompt += "==================================================\n\n"
	prompt += get_current_position()
	# ------------------------------------------------------------
	prompt += "\n==================================================\n"
	prompt += "ÁREA VISÍVEL\n"
	prompt += "==================================================\n\n"
	prompt += get_visible_area()
	# ------------------------------------------------------------
	prompt += "\n==================================================\n"
	prompt += "EVENTOS E RESULTADOS\n"
	prompt += "==================================================\n\n"
	prompt += get_recent_events()
	# ------------------------------------------------------------
	prompt += "\n==================================================\n"
	prompt += "CONVERSAS\n"
	prompt += "==================================================\n\n"
	prompt += get_recent_messages()
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
# ============================================================
# PLACEHOLDERS
# ============================================================

static func get_status() -> String:
	return "[STATUS]"


static func get_known_map() -> String:
	return "[MAPA_CONHECIDO]"


static func get_current_position() -> String:
	return "[POSICAO_ATUAL]"


static func get_visible_area() -> String:
	return "[AREA_VISIVEL]"


static func get_recent_events() -> String:
	return "[EVENTOS]"


static func get_recent_messages() -> String:
	return "[CONVERSAS]"
# ------------------------------------------------------------------------------------------------ #
# --- Funções de comunicação com IA  ------------------------------------------------------------- #
func send_message():
	send_request(create_message_to_agent())
# ------------------------------------------------------------------------------------------------ #
