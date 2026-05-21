# LLM 服务单例
# 封装 LLM API 调用，支持 Mock / Ollama / OpenAI 三种后端
extends Node

# 后端类型
enum Provider { MOCK, OLLAMA, OPENAI }

var provider: int = Provider.OPENAI
var mock_enabled: bool = true

# Ollama 配置
var ollama_url: String = "http://localhost:11434"
var ollama_model: String = "qwen2.5:7b"

# OpenAI 配置
var openai_url: String = "https://api.deepseek.com"
var openai_key: String = "sk-d9db3666e76541e6a17c017922a2fee4"
var openai_model: String = "deepseek-chat"

# 请求超时（LLM 生成通常需要数秒）
var timeout: float = 120.0

# HTTP 请求节点
var http_request: HTTPRequest

# 当前回调
var _pending_callback: Callable

# 初始化
func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.timeout = timeout
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
	# 预写事件模板（与 LLM 使用相同的 effects 协议）
	var events = [
		{
			"narration_text": "你沿着青云山的古道缓步前行，两旁古木参天，灵气氤氲。忽然，前方灌木丛中传来窸窣声响，一道青光闪过——竟是一株通体碧绿的「翠云草」！此草乃是炼制筑基丹的主材之一，极为珍贵。然而，草丛旁隐约可见一条翠绿色的蛇影盘踞...",
			"choices": [
				{
					"id": "choice_1",
					"text": "出手采药，正面迎战绿蛇",
					"risk_hint": "risky",
					"effects": [
						{"type": "add_spirit_stones", "value": 300},
						{"type": "add_exp", "value": 20},
						{"type": "start_battle", "enemy_id": "green_snake"}
					],
					"success_text": "你挺身而出，与绿蛇正面交锋！"
				},
				{
					"id": "choice_2",
					"text": "施展隐匿术，悄悄采摘",
					"risk_hint": "safe",
					"effects": [
						{"type": "add_item", "item_id": "cui_yun_grass", "item_name": "翠云草", "quantity": 1},
						{"type": "add_exp", "value": 10}
					],
					"success_text": "你隐匿身形，悄无声息地采走了翠云草。"
				},
				{
					"id": "choice_3",
					"text": "放弃翠云草，继续前行",
					"risk_hint": "safe",
					"effects": [
						{"type": "add_exp", "value": 5}
					],
					"success_text": "你权衡利弊，决定不去冒险，继续向前探索。"
				}
			],
			"event_type": "explore"
		},
		{
			"narration_text": "山风吹过，带来一阵淡淡的药香。你循着气味来到一处山崖之下，发现这里竟然生长着一小片野生灵药。虽不是什么稀世奇珍，但对于炼气期的修士来说，也是不错的收获。然而，你隐约感觉到附近有其他修士的气息...",
			"choices": [
				{
					"id": "choice_1",
					"text": "快速采集灵药后离开",
					"risk_hint": "risky",
					"effects": [
						{"type": "add_item", "item_id": "wild_herb", "item_name": "野生灵药", "quantity": 3},
						{"type": "add_exp", "value": 15}
					],
					"success_text": "你迅速采集了灵药，在其他人赶到之前悄然离去。"
				},
				{
					"id": "choice_2",
					"text": "上前与对方打招呼",
					"risk_hint": "unknown",
					"effects": [
						{"type": "change_npc_relation", "npc_name": "散修道人", "change": 20},
						{"type": "add_exp", "value": 10}
					],
					"success_text": "你上前行礼，对方竟是一位和善的散修道人。他见你态度诚恳，便与你分享了一些修炼心得。"
				},
				{
					"id": "choice_3",
					"text": "躲藏起来观察情况",
					"risk_hint": "safe",
					"effects": [
						{"type": "add_exp", "value": 5},
						{"type": "set_flag", "flag": "spotted_cultivator", "value": true}
					],
					"success_text": "你躲在暗处观察，发现对方只是路过，待其远去后你才安心采集。"
				}
			],
			"event_type": "explore"
		},
		{
			"narration_text": "你在山道上遇到一位负伤的老修士，他背靠古树，面色苍白。看见你走近，他勉强抬起手招呼道：「小友...能否...助老夫一臂之力？」看来他是在与妖兽战斗后受了重伤。",
			"choices": [
				{
					"id": "choice_1",
					"text": "上前救治老修士",
					"risk_hint": "safe",
					"effects": [
						{"type": "add_exp", "value": 25},
						{"type": "change_npc_relation", "npc_name": "老修士", "change": 50},
						{"type": "set_flag", "flag": "saved_old_cultivator", "value": true}
					],
					"success_text": "你取出丹药为老修士疗伤，他感激涕零，临别时赠你几卷手札，上面记载着珍贵的修炼经验。"
				},
				{
					"id": "choice_2",
					"text": "询问发生了什么事",
					"risk_hint": "safe",
					"effects": [
						{"type": "add_exp", "value": 10},
						{"type": "set_flag", "flag": "know_about_beast_tide", "value": true}
					],
					"success_text": "老修士喘息着告诉你，青云山近来妖兽异动频频，似有兽潮将起。他在前往主峰报信的路上遭到伏击。"
				},
				{
					"id": "choice_3",
					"text": "趁其虚弱，夺取他的储物袋",
					"risk_hint": "dangerous",
					"effects": [
						{"type": "add_spirit_stones", "value": 500},
						{"type": "add_item", "item_id": "healing_dan", "item_name": "疗伤丹", "quantity": 5},
						{"type": "change_npc_relation", "npc_name": "老修士", "change": -100},
						{"type": "add_hp", "value": -10}
					],
					"success_text": "你趁其不备夺走了储物袋，老修士怒目而视，却无力追赶。虽然他不知你姓名，但这份因果或许会在日后带来麻烦...（生命-10）"
				}
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
	print("请求头为：", headers)
	print("请求体为:", json_body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)

# 构建 Prompt
func _build_prompt(request_type: String, context: Dictionary) -> String:
	match request_type:
		"event":
			return _build_event_prompt(context)
		_:
			return "请生成一段修仙事件的JSON。"

func _build_event_prompt(context: Dictionary) -> String:
	var history_text: String = ""
	var history: Array = context.get("history", [])
	var recent = history.slice(max(0, history.size() - 3), history.size())
	for h in recent:
		var t: String = h.get("type", "")
		var n: String = h.get("narration", "")
		if n.length() > 80:
			n = n.substr(0, 80) + "..."
		history_text += "- [%s] %s\n" % [t, n]

	return """你是一个修仙世界的叙事者。根据玩家状态生成探索事件。

当前玩家状态：
- 角色名：{player_name}
- 境界：{realm}（{stage}期）
- 灵根：{spiritual_roots}
- 位置：{location}
- 灵石：{spirit_stones}
- 修为：{cultivation_exp}/{exp_to_next}
- 生命：{hp}/{max_hp}

最近经历：
{history}

请生成一个修仙世界的探索事件，必须严格返回以下JSON格式（不要包含markdown代码块标记）：
{{
  "narration_text": "叙事描述（150-300字，古典仙侠文风，生动细致）",
  "event_type": "explore",
  "choices": [
	{{
	  "id": "choice_1",
	  "text": "选项描述文字",
	  "risk_hint": "safe|risky|dangerous",
	  "effects": [
		{{"type": "add_spirit_stones", "value": 100}}
	  ],
	  "success_text": "选择成功后的叙事反馈"
	}}
  ]
}}

可用的效果类型（effects数组中的type字段，每个选项至少1个effect）：
- add_spirit_stones: 增加灵石，value=数量（10~500）
- add_exp: 增加修为，value=数量（5~50）
- add_item: 获得物品，item_id=物品ID, item_name=物品名, quantity=数量
- remove_item: 消耗物品，item_id=物品ID, item_name=物品名, quantity=数量
- start_battle: 触发战斗，enemy_id=敌人ID（如 forest_spirit, bandit, spirit_beast）
- advance_time: 时间流逝，hours=时辰数
- add_hp: 恢复生命，value=数值
- add_sp: 恢复灵力，value=数值
- set_flag: 设置事件标记，flag=标记名, value=true/false
- change_npc_relation: 改变NPC好感，npc_name=NPC名, change=变化值（-50~50）
- teleport: 传送，location_id=地点ID, location_name=地点名, travel_hours=路程

生成规则：
1. 生成3个选项：1个safe、1个risky、1个dangerous（或safe/risky/unknown）
2. risky选项的effects数量和数值更多，但可能触发战斗；dangerous选项可能失去物品或扣血
3. success_text要与narration_text的仙侠叙事风格一致
4. 叙事要体现玩家当前的境界和灵根特点
""".format({
		"player_name": str(context.get("player_name", "")),
		"realm": str(context.get("realm", "")),
		"stage": str(context.get("stage", "")),
		"spiritual_roots": str(context.get("spiritual_roots", [])),
		"location": str(context.get("location", "")),
		"spirit_stones": str(context.get("spirit_stones", 0)),
		"cultivation_exp": str(context.get("cultivation_exp", 0)),
		"exp_to_next": str(context.get("exp_to_next", 100)),
		"hp": str(context.get("hp", 0)),
		"max_hp": str(context.get("max_hp", 0)),
		#"history": history_text if history_text.strip() != "" else "（暂无）"
	})

# 获取系统 Prompt
func _get_system_prompt() -> String:
	return "你是修仙世界「玄黄界」的叙事者。请用古典仙侠文风写作，返回严格的JSON格式，choices中每个选项必须包含effects数组。"

# HTTP 响应处理
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != OK:
		var err_msg := "未知错误"
		match result:
			ERR_TIMEOUT:       err_msg = "请求超时（> %.0f 秒），考虑增大 timeout 或切换到更快的模型" % timeout
			ERR_CANT_RESOLVE:  err_msg = "无法解析域名，请检查网络连接和 URL 配置"
			ERR_CANT_CONNECT:  err_msg = "无法连接到服务器，请确认 LLM 服务已启动"
			#ERR_SSL_ERROR:     err_msg = "SSL/TLS 错误，请检查证书或使用 HTTP"
			#ERR_BODY_SIZE_LIMIT_EXCEEDED: err_msg = "响应体超出大小限制"
		print_rich("[color=yellow][LLMService][/color] HTTP 请求失败 (result=%d): %s，回退到 Mock" % [result, err_msg])
		_respond_mock_event()
		return

	if response_code != 200:
		print_rich("[color=yellow][LLMService][/color] HTTP 请求失败 (code=%d)，回退到 Mock" % response_code)
		_respond_mock_event()
		return

	var text = body.get_string_from_utf8()
	var response = JSON.parse_string(text)
	if response == null:
		print_rich("[color=yellow][LLMService][/color] JSON 解析失败，回退到 Mock")
		_respond_mock_event()
		return

	# 根据 provider 提取内部的 JSON 内容
	var event_data: Variant = null

	match provider:
		Provider.OLLAMA:
			# Ollama 返回格式: { "response": "{...json...}" }
			var inner_text = response.get("response", "")
			if inner_text != "":
				event_data = JSON.parse_string(inner_text)
		Provider.OPENAI:
			# OpenAI 返回格式: { "choices": [{ "message": { "content": "{...json...}" } }] }
			var choices = response.get("choices", [])
			if choices.size() > 0:
				var content = choices[0].get("message", {}).get("content", "")
				if content != "":
					event_data = JSON.parse_string(content)
					print("接受内容报文为：", event_data)

	# 验证解析结果
	if event_data == null or typeof(event_data) != TYPE_DICTIONARY:
		print_rich("[color=yellow][LLMService][/color] 无法提取事件数据，回退到 Mock")
		_respond_mock_event()
		return

	# 验证必需字段
	if not event_data.has("narration_text") or not event_data.has("choices"):
		print_rich("[color=yellow][LLMService][/color] LLM 响应缺少必需字段，回退到 Mock")
		_respond_mock_event()
		return

	print_rich("[color=green][LLMService][/color] LLM 响应解析成功，调用回调")
	_pending_callback.call(event_data)

# 从配置加载
func load_config(config: Dictionary) -> void:
	provider = config.get("provider", Provider.MOCK)
	ollama_url = config.get("ollama", {}).get("base_url", "http://localhost:11434")
	ollama_model = config.get("ollama", {}).get("model", "qwen2.5:7b")
	openai_url = config.get("openai", {}).get("base_url", "https://api.openai.com/v1")
	openai_key = config.get("openai", {}).get("api_key", "")
	openai_model = config.get("openai", {}).get("model", "gpt-4o-mini")
	mock_enabled = (provider == Provider.MOCK)
