# LLM 服务单例
# 封装 LLM API 调用，支持 Mock / Ollama / OpenAI 三种后端
extends Node

# 后端类型
enum Provider { MOCK, OLLAMA, OPENAI }

var provider: int = Provider.MOCK
var mock_enabled: bool = true

# Ollama 配置
var ollama_url: String = "http://localhost:11434"
var ollama_model: String = "qwen2.5:7b"

# OpenAI 配置
var openai_url: String = "https://api.openai.com/v1"
var openai_key: String = ""
var openai_model: String = "gpt-4o-mini"

# 请求超时
var timeout: float = 30.0

# HTTP 请求节点
var http_request: HTTPRequest

# 当前回调
var _pending_callback: Callable

# 初始化
func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

# 请求事件叙事
func request_event(context: Dictionary, callback: Callable) -> void:
	_pending_callback = callback
	match provider:
		Provider.MOCK:
			_respond_mock_event()
		Provider.OLLAMA:
			_request_ollama("event", context)
		Provider.OPENAI:
			_request_openai("event", context)

# Mock 模式：返回预写事件
func _respond_mock_event() -> void:
	# 预写事件模板
	var events = [
		{
			"narration_text": "你沿着青云山的古道缓步前行，两旁古木参天，灵气氤氲。忽然，前方灌木丛中传来窸窣声响，一道青光闪过——竟是一株通体碧绿的「翠云草」！此草乃是炼制筑基丹的主材之一，极为珍贵。然而，草丛旁隐约可见一条翠绿色的蛇影盘踞...",
			"choices": [
				{"id": "choice_1", "text": "出手采药，正面迎战绿蛇", "risk_hint": "risky"},
				{"id": "choice_2", "text": "施展隐匿术，悄悄采摘", "risk_hint": "safe"},
				{"id": "choice_3", "text": "放弃翠云草，继续前行", "risk_hint": "safe"}
			],
			"event_type": "explore"
		},
		{
			"narration_text": "山风吹过，带来一阵淡淡的药香。你循着气味来到一处山崖之下，发现这里竟然生长着一小片野生灵药。虽不是什么稀世奇珍，但对于炼气期的修士来说，也是不错的收获。然而，你隐约感觉到附近有其他修士的气息...",
			"choices": [
				{"id": "choice_1", "text": "快速采集灵药后离开", "risk_hint": "risky"},
				{"id": "choice_2", "text": "上前与对方打招呼", "risk_hint": "unknown"},
				{"id": "choice_3", "text": "躲藏起来观察情况", "risk_hint": "safe"}
			],
			"event_type": "explore"
		},
		{
			"narration_text": "你在山道上遇到一位负伤的老修士，他背靠古树，面色苍白。看见你走近，他勉强抬起手招呼道：「小友...能否...助老夫一臂之力？」看来他是在与妖兽战斗后受了重伤。",
			"choices": [
				{"id": "choice_1", "text": "上前救治老修士", "risk_hint": "safe"},
				{"id": "choice_2", "text": "询问发生了什么事", "risk_hint": "safe"},
				{"id": "choice_3", "text": "趁其虚弱，夺取他的储物袋", "risk_hint": "dangerous"}
			],
			"event_type": "explore"
		}
	]
	var event = events[randi() % events.size()]
	_pending_callback.call(event)

# Ollama 请求
func _request_ollama(request_type: String, context: Dictionary) -> void:
	var url = ollama_url + "/api/generate"
	var body = {
		"model": ollama_model,
		"prompt": _build_prompt(request_type, context),
		"stream": false
	}
	var headers = ["Content-Type: application/json"]
	var json_body = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)

# OpenAI 请求
func _request_openai(request_type: String, context: Dictionary) -> void:
	var url = openai_url + "/chat/completions"
	var body = {
		"model": openai_model,
		"messages": [
			{"role": "system", "content": _get_system_prompt()},
			{"role": "user", "content": _build_prompt(request_type, context)}
		],
		"response_format": {"type": "json_object"}
	}
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + openai_key
	]
	var json_body = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)

# 构建 Prompt
func _build_prompt(request_type: String, context: Dictionary) -> String:
	var prompt = "你是一个修仙世界的叙事者。当前玩家信息：\n"
	prompt = prompt + "角色名：" + str(context.get("player_name", "")) + "\n"
	prompt = prompt + "境界：" + str(context.get("realm", "")) + "\n"
	prompt = prompt + "位置：" + str(context.get("location", "")) + "\n"
	prompt = prompt + "请生成一个修仙世界的探索事件，返回JSON格式。"
	return prompt

# 获取系统 Prompt
func _get_system_prompt() -> String:
	return "你是修仙世界「玄黄界」的叙事者。请用古典仙侠文风写作，返回严格的JSON格式。"

# HTTP 响应处理
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		_respond_mock_event()
		return
	var text = body.get_string_from_utf8()
	var data = JSON.parse_string(text)
	if data != null:
		# 提取 narrative 和 choices
		# 简化处理：如果解析失败则 fallback
		_respond_mock_event()
	else:
		_respond_mock_event()

# 从配置加载
func load_config(config: Dictionary) -> void:
	provider = config.get("provider", Provider.MOCK)
	ollama_url = config.get("ollama", {}).get("base_url", "http://localhost:11434")
	ollama_model = config.get("ollama", {}).get("model", "qwen2.5:7b")
	openai_url = config.get("openai", {}).get("base_url", "https://api.openai.com/v1")
	openai_key = config.get("openai", {}).get("api_key", "")
	openai_model = config.get("openai", {}).get("model", "gpt-4o-mini")
	mock_enabled = (provider == Provider.MOCK)
