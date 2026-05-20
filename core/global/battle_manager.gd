# 战斗管理单例
# 回合制战斗引擎：速度排序、AI 决策、伤害结算、胜负判定
extends Node

# 战斗参与者
var player_unit: CombatUnit
var enemy_unit: CombatUnit

# 战斗状态
var round_number: int = 0
var is_battle_active: bool = false
var is_auto_mode: bool = true
var skip_animation: bool = false

# 当前行动队列
var action_queue: Array = []

# 战斗日志
var combat_log: Array = []

# 战斗结算数据
var battle_result: Dictionary = {}

# 信号
signal battle_started(player: CombatUnit, enemy: CombatUnit)
signal round_executed(round_num: int, actions: Array)
signal battle_ended(victory: bool, result: Dictionary)

# 五行相克矩阵
const ELEMENT_MATRIX = {
	"金": {"克": "木", "被克": "火"},
	"木": {"克": "土", "被克": "金"},
	"水": {"克": "火", "被克": "土"},
	"火": {"克": "金", "被克": "水"},
	"土": {"克": "水", "被克": "木"}
}

# 准备战斗
func prepare_battle(enemy_id: String) -> void:
	player_unit = CombatUnit.from_player(GameState.player)
	enemy_unit = _create_enemy(enemy_id)
	round_number = 0
	is_battle_active = true
	combat_log.clear()
	battle_result.clear()
	battle_started.emit(player_unit, enemy_unit)

# 创建敌人
func _create_enemy(enemy_id: String) -> CombatUnit:
	var enemy = CombatUnit.new()
	# 根据不同敌人 ID 创建不同数据
	match enemy_id:
		"forest_spirit":
			enemy.unit_name = "翠鳞蛇"
			enemy.realm = "炼气期"
			enemy.element = "木"
			enemy.max_hp = 60.0
			enemy.current_hp = 60.0
			enemy.max_sp = 30.0
			enemy.current_sp = 30.0
			enemy.attack = 8.0
			enemy.defense = 4.0
			enemy.speed = 8.0
		_:
			enemy.unit_name = "妖兽"
			enemy.realm = "炼气期"
			enemy.element = "土"
			enemy.max_hp = 50.0
			enemy.current_hp = 50.0
			enemy.max_sp = 20.0
			enemy.current_sp = 20.0
			enemy.attack = 6.0
			enemy.defense = 3.0
			enemy.speed = 6.0
	return enemy

# 开始战斗（由场景调用）
func start_battle() -> void:
	round_number = 1
	_execute_round()

# 执行一个回合
func execute_next_round() -> void:
	if not is_battle_active:
		return
	round_number = round_number + 1
	_execute_round()

# 内部：执行回合逻辑
func _execute_round() -> void:
	if not is_battle_active:
		return
	# 构建行动队列
	action_queue.clear()
	if player_unit.speed >= enemy_unit.speed:
		action_queue = [player_unit, enemy_unit]
	else:
		action_queue = [enemy_unit, player_unit]
	# 执行每个单位的行动
	var actions = []
	for unit in action_queue:
		unit.on_turn_start()
		if not unit.is_alive():
			continue
		var target = enemy_unit if unit == player_unit else player_unit
		var action = _ai_decide_action(unit, target)
		actions.append(action)
	# 通知 UI
	round_executed.emit(round_number, actions)
	# 检查胜负
	if _check_battle_end():
		return

# AI 决定行动
func _ai_decide_action(unit: CombatUnit, target: CombatUnit) -> Dictionary:
	# 简化 AI：始终使用普通攻击
	var damage = calculate_damage(unit, target, null)
	target.take_damage(damage)
	unit.on_turn_end()
	return {
		"actor": unit.unit_name,
		"action": "普通攻击",
		"target": target.unit_name,
		"damage": damage,
		"element": unit.element,
		"target_hp_ratio": target.current_hp / target.max_hp
	}

# 计算伤害
func calculate_damage(attacker: CombatUnit, defender: CombatUnit, art) -> float:
	var base_damage = attacker.attack * 10.0
	if art != null:
		base_damage = art.power
	# 五行系数
	var element_mult = _get_element_multiplier(attacker.element, defender.element)
	# 防御减免
	var defense_reduction = defender.defense / (defender.defense + 50.0)
	# 计算
	var damage = base_damage * element_mult * (1.0 - defense_reduction)
	# 随机波动
	damage = damage * randf_range(0.9, 1.1)
	# 暴击
	if randf() < attacker.crit_chance:
		damage = damage * 1.5
	return max(1.0, damage)

# 五行相克系数
func _get_element_multiplier(attacker_element: String, defender_element: String) -> float:
	if attacker_element == defender_element:
		return 1.0
	var info = ELEMENT_MATRIX.get(attacker_element, {})
	if info.get("克", "") == defender_element:
		return 1.3
	if info.get("被克", "") == defender_element:
		return 0.7
	return 1.0

# 检查战斗结束
func _check_battle_end() -> bool:
	if not player_unit.is_alive():
		is_battle_active = false
		battle_result = {"victory": false, "message": "你被击败了..."}
		battle_ended.emit(false, battle_result)
		return true
	if not enemy_unit.is_alive():
		is_battle_active = false
		battle_result = {"victory": true, "message": "战斗胜利！"}
		battle_ended.emit(true, battle_result)
		return true
	return false

# 获取战斗状态摘要
func get_battle_summary() -> Dictionary:
	return {
		"round": round_number,
		"player_hp": player_unit.current_hp,
		"player_max_hp": player_unit.max_hp,
		"player_sp": player_unit.current_sp,
		"player_max_sp": player_unit.max_sp,
		"enemy_hp": enemy_unit.current_hp,
		"enemy_max_hp": enemy_unit.max_hp,
		"enemy_name": enemy_unit.unit_name,
		"is_active": is_battle_active
	}
