extends Node2D
class_name API_Communication

# Sinal utilizado para conectar com funções que serão executadas quando a
# resposta for recebia.
signal response_received

# - Variaveis da conversa com a IA:
# Numero de mensagens de requisição e resposta que serão guardadas na lista de
# mensagens.
@export var message_list_size : int = 2
# Lista que guarda as mensagens enviadas e recebidas.
var mensages_list = []
# Prompt inicial que da o contexto a IA e indica como ela deve se comportar.
var system_prompt : String


# - Variaveis para comunicação:
@onready var http = HTTPRequest.new()
enum Request_Stages {CREATE, POLL}
var current_request_stage : Request_Stages
var get_request_url = ""

# - Variaveis da API:
var url = "https://api.replicate.com/v1/predictions"
# Substitua pelo seu token de API
var token = "r8_9KRYViL5VCGUOrMLmJsjXErgoexfxLw3Xy79b"
# Bote o modelo que vocé deseja utilizar
var model = "openai/gpt-4.1-mini"


# --- Funções do sistema  ------------------------------------------------------------------------ #
func _ready():
	configura_http()
	create_system_prompt()
	init_message_list()
# ------------------------------------------------------------------------------------------------ #
# --- Funções de mensagens  ---------------------------------------------------------------------- #
# Cria o prompt inicial que da o contexto a IA e indica como ela deve se comportar.
func create_system_prompt():
	system_prompt = ""

# Inicia lista de mensagens com o contexto do sistema.
func init_message_list():
	mensages_list = [{"role": "system", "content": system_prompt}]

# Adiciona uma nova mensagem a lista de mensagens, removendo as mais antiga caso passe do limite.
# Remove pergunta e resposta mais antiga para evitar que a IA se confunda.
func add_new_message(message):
	if mensages_list.size() > message_list_size + 1:
		mensages_list.remove_at(1)
		mensages_list.remove_at(1)
	mensages_list.append(message)

# Adiciona mensagens que são mandadas pelo usuario.
func add_user_message(text):
	var user_message = {"role": "user", "content": text}
	add_new_message(user_message)

# Adiciona mensagens de resposta da IA (pra guardar o contexto).
func add_assistant_message(text):
	var assistant_message = {"role": "assistant", "content": text}
	add_new_message(assistant_message)

# Retorna o texto da mensagem mais recente da IA.
func get_recent_message():
	var message = mensages_list[-1]
	if message["role"] == "assistant":
		return message["content"]
	return ""
# ------------------------------------------------------------------------------------------------ #
# --- Funções de comunicação com IA  ------------------------------------------------------------- #
# Utiliza API para mandar uma requisição com uma lista de mensagens para a IA.
func _send_to_ai():
	current_request_stage = Request_Stages.CREATE
	# URL api:
	var selected_url = url
	# Cabeçalho da requisição: 
	var headers = [
		"Content-Type: application/json",
		"Authorization: Token %s" % token
		]
	# Corpo da requisição:
	var body = {
		"version": model,
		"input": {
			"messages": mensages_list
			}
		}
	# Converte corpo em json:
	var json = JSON.stringify(body)
	# Manda a requisição http:
	http.request(selected_url, headers, HTTPClient.METHOD_POST, json)


# Executada quando recebe respostas html das requisições feitas.
func _on_HTTPRequest_request_completed(_result, _response_code, _headers, body):
	# Transforma mensagem em algo legivel.
	var json = JSON.parse_string(body.get_string_from_utf8())
	# Estado de criação: obtem o status e faz a consulta do resultado.
	if current_request_stage == Request_Stages.CREATE:
		get_request_url = json["urls"]["get"]
		current_request_stage = Request_Stages.POLL
		await get_tree().create_timer(1.0).timeout
		_check_result(get_request_url)
	# Estado de POLL: Recebe o resultado e salva na lista de mensagens.
	elif current_request_stage == Request_Stages.POLL:
		if json.has("status") and json["status"] is String and json["status"] == "succeeded":
			var resposta = ""
			for t in json["output"]:
				resposta += t
			add_assistant_message(resposta)
			response_received.emit()
		elif json.has("status") and json["status"] is float and json["status"] == 401.0:
			print("HTTP 401.0 - Unauthorized (Não Autorizado), indica que a solicitação feita ao \
servidor falhou porque as credenciais de autenticação são inválidas, \
ausentes ou expiradas.")
		else:
			# continua tentando
			await get_tree().create_timer(2.0).timeout
			_check_result(get_request_url)


# Faz a consulta do resultado da requisição utilizando a url de consulta.
func _check_result(consulta_url):
	var headers = [
		"Authorization: Token %s" % token
	]
	http.request(consulta_url, headers)


# Faz a configuração inicial do HTTPRequest.
func configura_http():
	add_child(http)
	http.request_completed.connect(_on_HTTPRequest_request_completed)
# ------------------------------------------------------------------------------------------------ #
# --- Funções de uso ----------------------------------------------------------------------------- #
# Usao texto recebido para fazer uma requisição para a IA.
func send_request(text:String):
	add_user_message(text)
	_send_to_ai()

# Retorna a resposta mais recente a IA.
func get_response():
	return get_recent_message()

# Retorna a lista inteira de mensagens enviadas e recebidas que estão guardadas.
func get_mensages_list():
	return mensages_list
# ------------------------------------------------------------------------------------------------ #
