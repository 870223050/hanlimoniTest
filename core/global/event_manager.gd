# 事件管理单例
# 负责事件触发、LLM 协调、选择执行和后果结算
extends Node

# 当前事件类型
var current_event_type: String = ""
var current_event_context: Dictionary = {}

# 效果执行器注册表（effect_type → callable）
var _effect_handlers: Dictionary = {}

# 信号
signal event_display(narration: String, choices: Array)
signal event_result(narration: String)

func _ready() -> void:
	_register_effects()

# 注册所有效果处理器
func _register_effects() -> void:
	_effect_handlers["add_spirit_stones"] = _effect_add_spirit_stones
	_effect_handlers["add_exp"]           = _effect_add_exp
	_effect_handlers["add_item"]          = _effect_add_item
	_effect_handlers["remove_item"]       = _effect_remove_item
	_effect_handlers["start_battle"]      = _effect_start_battle
	_effect_handlers["advance_time"]      = _effect_advance_time
	_effect_handlers["set_flag"]          = _effect_set_flag
	_effect_handlers["change_npc_relation"] = _effect_change_npc_relation
	_effect_handlers["teleport"]          = _effect_teleport
	_effect_handlers["add_hp"]            = _effect_add_hp
	_effect_handlers["add_sp"]            = _effect_add_sp

# 触发探索事件
func trigger_exploration() -> void:
	var context = _build_context()
	LLMService.request_event(context, _on_exploration_response)

# 构建上下文
func _build_context() -> Dictionary:
	return {
		"player_name": GameState.player.player_name,
		"realm": GameState.player.realm,
		"stage": GameState.player.stage,
		"location": GameState.current_location_name,
		"spiritual_roots": GameState.player.spiritual_roots,
		"spirit_stones": GameState.player.spirit_stones,
		"cultivation_exp": GameState.player.cultivation_exp,
		"exp_to_next": GameState.player.exp_to_next,
		"hp": GameState.player.current_hp,
		"max_hp": GameState.player.max_hp,
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

# 执行玩家选择 — 解析 effects 数组，数据驱动
func execute_choice(choice_id: String) -> void:
	var choice = _find_choice(choice_id)
	if choice == null:
		# 找不到 choice 时回退到旧逻辑（Mock 模式）
		_fallback_execute(choice_id)
		return

	var effects: Array = choice.get("effects", [])
	var result_text: String = choice.get("success_text", "")

	# 执行效果链
	for effect in effects:
		var line = _execute_effect(effect)
		if line != "":
			if result_text != "":
				result_text += "\n"
			result_text += line

	if result_text == "":
		result_text = "事情发生了..."

	event_result.emit(result_text)
	GameState.narrative_history.append({"type": current_event_type, "choice": choice_id, "narration": result_text})
	GameState.state_changed.emit()

# 从 choices 数组中查找 choice
func _find_choice(choice_id: String) -> Variant:
	var choices: Array = current_event_context.get("choices", [])
	for c in choices:
		if c.get("id", "") == choice_id:
			return c
	return null

# 回退执行（兼容没有 effects 数据的旧 Mock 流程）
func _fallback_execute(choice_id: String) -> void:
	var narration = _execute_event_effect_legacy(current_event_type, choice_id)
	if narration != "":
		event_result.emit(narration)
		GameState.narrative_history.append({"type": current_event_type, "choice": choice_id, "narration": narration})
	GameState.state_changed.emit()

# 旧版查表执行（仅当 effects 数据缺失时使用）
func _execute_event_effect_legacy(event_type: String, choice_id: String) -> String:
	match event_type:
		"explore":
			return _execute_explore_effect_legacy(choice_id)
		"cultivate":
			return _execute_cultivate_effect_legacy(choice_id)
		_:
			return "事件已处理。"

func _execute_explore_effect_legacy(choice_id: String) -> String:
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

func _execute_cultivate_effect_legacy(choice_id: String) -> String:
	match choice_id:
		"choice_1":
			GameState.advance_time(6)
			return "你继续闭关修炼..."
		"choice_2":
			return "你结束了修炼，准备外出探索。"
		_:
			return ""

# ---------- 通用效果执行引擎 ----------

# 单个效果执行
func _execute_effect(effect: Dictionary) -> String:
	var effect_type: String = effect.get("type", "")
	if _effect_handlers.has(effect_type):
		return _effect_handlers[effect_type].call(effect)
	push_warning("EventManager: 未识别的效果类型 '%s'" % effect_type)
	return ""

# ---------- 效果处理器 ----------

func _effect_add_spirit_stones(effect: Dictionary) -> String:
	var value: int = effect.get("value", 0)
	GameState.player.spirit_stones += value
	if value >= 0:
		return "灵石 +%d（当前：%d）" % [value, GameState.player.spirit_stones]
	else:
		return "灵石 %d（当前：%d）" % [value, GameState.player.spirit_stones]

func _effect_add_exp(effect: Dictionary) -> String:
	var value: int = effect.get("value", 0)
	GameState.player.cultivation_exp += value
	if value >= 0:
		return "修为 +%d（当前：%.0f）" % [value, GameState.player.cultivation_exp]
	else:
		return "修为 %d（当前：%.0f）" % [value, GameState.player.cultivation_exp]

func _effect_add_item(effect: Dictionary) -> String:
	var item_id: String = effect.get("item_id", "")
	var quantity: int = effect.get("quantity", 1)
	var item_name: String = effect.get("item_name", item_id)
	GameState.add_item({"item_id": item_id, "quantity": quantity, "name": item_name})
	return "获得 %s x%d" % [item_name, quantity]

func _effect_remove_item(effect: Dictionary) -> String:
	var item_id: String = effect.get("item_id", "")
	var quantity: int = effect.get("quantity", 1)
	var item_name: String = effect.get("item_name", item_id)
	GameState.remove_item(item_id, quantity)
	return "消耗 %s x%d" % [item_name, quantity]

func _effect_start_battle(effect: Dictionary) -> String:
	var enemy_id: String = effect.get("enemy_id", "")
	BattleManager.prepare_battle(enemy_id)
	return ""  # BattleManager 自行控制 UI 切换

func _effect_advance_time(effect: Dictionary) -> String:
	var hours: int = effect.get("hours", 1)
	GameState.advance_time(hours)
	return "时间流逝 %d 时辰" % hours

func _effect_set_flag(effect: Dictionary) -> String:
	var flag: String = effect.get("flag", "")
	var value = effect.get("value", true)
	GameState.event_flags[flag] = value
	return ""  # 内部标记，不显示

func _effect_change_npc_relation(effect: Dictionary) -> String:
	var npc_name: String = effect.get("npc_name", "")
	var change: int = effect.get("change", 0)
	if GameState.npc_relations.has(npc_name):
		GameState.npc_relations[npc_name] += change
	else:
		GameState.npc_relations[npc_name] = change
	if change >= 0:
		return "%s 好感度 +%d" % [npc_name, change]
	else:
		return "%s 好感度 %d" % [npc_name, change]

func _effect_teleport(effect: Dictionary) -> String:
	var location_id: String = effect.get("location_id", "")
	var location_name: String = effect.get("location_name", location_id)
	var travel_hours: int = effect.get("travel_hours", 1)
	GameState.move_to(location_id, location_name, travel_hours)
	return "你来到了 %s" % location_name

func _effect_add_hp(effect: Dictionary) -> String:
	var value: int = effect.get("value", 0)
	GameState.player.current_hp = min(GameState.player.current_hp + value, GameState.player.max_hp)
	return "生命 %+d（%d/%d）" % [value, GameState.player.current_hp, GameState.player.max_hp]

func _effect_add_sp(effect: Dictionary) -> String:
	var value: int = effect.get("value", 0)
	GameState.player.current_sp = min(GameState.player.current_sp + value, GameState.player.max_sp)
	return "灵力 %+d（%d/%d）" % [value, GameState.player.current_sp, GameState.player.max_sp]

# 触发战斗事件
func trigger_battle(enemy_id: String) -> void:
	BattleManager.prepare_battle(enemy_id)
