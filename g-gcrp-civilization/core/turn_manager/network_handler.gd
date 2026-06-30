extends Node

signal intentions_ready(intentions: Dictionary)

var agent_requests: Dictionary = {} # ID: AgentRequestInstance
var final_intentions: Dictionary = {}
var pending_responses: int = 0

func prefetch_intentions():
	pending_responses = GameDataManager._ai_agents.size()

	for agent_id in GameDataManager._ai_agents.keys():
		var request_node = Agent_Comm_Manager.new()
		add_child(request_node)
		request_node.response_received.connect(_on_agent_responded.bind(agent_id))
		request_node.send_message(agent_id)
		agent_requests[agent_id] = request_node

func _on_agent_responded(agent_id: String):
	var node = agent_requests.get(agent_id)
	if is_instance_valid(node):
		var response_text = node.get_response()
		print(response_text)
		var parsed = JSON.parse_string(response_text)
	
		if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
			final_intentions[agent_id] = {"ação": "fugir", "mensagem": "", "movimento": "ficar"}
		else:
			final_intentions[agent_id] = {
				"acao": parsed.get("ação", "fugir"),
				"mensagem": parsed.get("mensagem", ""),
				"movimento": parsed.get("movimento", "ficar")
			}
		
		agent_requests.erase(agent_id)
		node.queue_free()
		
	pending_responses -= 1
	if pending_responses == 0:
		_compile_and_emit()

func _compile_and_emit():
	intentions_ready.emit(final_intentions)
	print(final_intentions)
	#final_intentions.clear()
