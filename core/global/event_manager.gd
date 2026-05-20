# 事件管理单例
# 负责事件触发、LLM 协调、选择执行和后果结算
extends Node

# 当前事件类型
var current_event_type: String = ""
var current_event_context: Dictionary = {}

# 信号
signal event_display(narration: String, choices: Array)
signal event_result(narration: String)

# 触发探索事件
func trigger_exploration() -> void:
	var context = _build_context()
	# LLMService.request_event(context, "_on_exploration_response")

# 构建上下文
func _build_context() -> Dictionary:
	return {
		"player_name": GameState.player.player_name,
		"realm": GameState.player.realm,
		"stage": GameState.player.stage,
		"location": GameState.current_location_name,
		"spiritual_roots": GameState.player.spiritual_roots,
		"history": GameState.narrative_history.duplicate()
	}

# LLM 探索响应回调
func _on_exploration_response(result: Dictionary) -> void:
	var narration = result.get("narration_text", "")
	var choices = result.get("choices", [])
	current_event_type = result.get("event_type", "")
	current_event_context = result
	event_display.emit(narration, choices)

# 触发修炼事件
func trigger_cultivate(hours: int) -> void:
	GameState.advance_time(hours)
	var exp_gain = hours * GameState.player.get_spiritual_root_multiplier() * 10
	var narration = "你闭关修炼 %d 个时辰，获得了 %.0f 点修为。" % [hours, exp_gain]
	var choices = [
		{"id": "choice_1", "text": "继续修炼", "risk_hint": "safe"},
		{"id": "choice_2", "text": "外出探索", "risk_hint": "safe"}
	]
	current_event_type = "cultivate"
	event_display.emit(narration, choices)

# 执行玩家选择
func execute_choice(choice_id: String) -> void:
	var narration = _execute_event_effect(current_event_type, choice_id)
	if narration != "":
		event_result.emit(narration)
		GameState.narrative_history.append({"type": current_event_type, "choice": choice_id, "narration": narration})
	GameState.state_changed.emit()

# 执行事件效果（Mock 模式查表）
func _execute_event_effect(event_type: String, choice_id: String) -> String:
	match event_type:
		"explore":
			return _execute_explore_effect(choice_id)
		"cultivate":
			return _execute_cultivate_effect(choice_id)
		_:
			return "事件已处理。"

# 探索事件效果
func _execute_explore_effect(choice_id: String) -> String:
	match choice_id:
		"choice_1":
			GameState.player.spirit_stones = GameState.player.spirit_stones + 500
			return "你收获了一些灵石！（+500 灵石）"
		"choice_2":
			GameState.player.cultivation_exp = GameState.player.cultivation_exp + 30
			return "你在探索中有所感悟，修为略有精进。（修为 +30）"
		"choice_3":
			BattleManager.prepare_battle("forest_spirit")
			return "你遇到了一只妖兽，战斗即将开始！"
		_:
			return "你选择了观望，暂时按兵不动。"

# 修炼事件效果
func _execute_cultivate_effect(choice_id: String) -> String:
	match choice_id:
		"choice_1":
			GameState.advance_time(6)
			return "你继续闭关修炼..."
		"choice_2":
			return "你结束了修炼，准备外出探索。"
		_:
			return ""

# 触发战斗事件
func trigger_battle(enemy_id: String) -> void:
	BattleManager.prepare_battle(enemy_id)
