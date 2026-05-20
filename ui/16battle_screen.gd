# 战斗场景脚本
# 负责回合制战斗的界面显示、行动指令和结果结算
extends Control

# 敌方区引用
var enemy_name_label: Label
var enemy_hp_bar: TextureRect
var enemy_sp_bar: TextureRect
var enemy_avatar: TextureRect

# 我方区引用
var player_name_label: Label
var player_hp_bar: TextureRect
var player_sp_bar: TextureRect
var player_avatar: TextureRect

# 战斗日志
var combat_narration_label: Label
var round_counter: Label

# 操作栏按钮
var attack_button: TextureButton
var skill_button: TextureButton
var defend_button: TextureButton
var item_button: TextureButton
var flee_button: TextureButton

# 切换按钮
var skip_anim_toggle: TextureButton
var auto_battle_toggle: TextureButton

# 结果覆盖层
var result_overlay: Control
var result_title_label: Label
var loot_summary_label: Label
var return_button: TextureButton

# 自动战斗标志
var is_auto_battle: bool = true
var is_skip_anim: bool = false

# 初始化节点引用
func setup() -> void:
	enemy_name_label = get_node("EnemyArea/EnemyNameLabel")
	enemy_hp_bar = get_node("EnemyArea/EnemyHpBar")
	enemy_sp_bar = get_node("EnemyArea/EnemySpBar")
	player_name_label = get_node("PlayerArea/PlayerNameLabel")
	player_hp_bar = get_node("PlayerArea/PlayerHpBar")
	player_sp_bar = get_node("PlayerArea/PlayerSpBar")
	combat_narration_label = get_node("CombatLog/CombatNarrationLabel")
	round_counter = get_node("RoundCounter")
	var action_bar = get_node("ActionBar")
	attack_button = action_bar.get_node("AttackButton")
	skill_button = action_bar.get_node("SkillButton")
	defend_button = action_bar.get_node("DefendButton")
	item_button = action_bar.get_node("ItemButton")
	flee_button = action_bar.get_node("FleeButton")
	skip_anim_toggle = get_node("SkipAnimToggle")
	auto_battle_toggle = get_node("AutoBattleToggle")
	result_overlay = get_node("ResultOverlay")
	result_title_label = result_overlay.get_node("ResultTitleLabel")
	loot_summary_label = result_overlay.get_node("LootSummaryLabel")
	return_button = result_overlay.get_node("ReturnButton")

# 绑定信号和事件
func bind_events() -> void:
	attack_button.pressed.connect(_on_attack_pressed)
	skill_button.pressed.connect(_on_skill_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	item_button.pressed.connect(_on_item_pressed)
	flee_button.pressed.connect(_on_flee_pressed)
	skip_anim_toggle.pressed.connect(_on_skip_anim_toggle)
	auto_battle_toggle.pressed.connect(_on_auto_battle_toggle)
	return_button.pressed.connect(_on_return)
	# 监听 BattleManager 信号
	BattleManager.battle_started.connect(_on_battle_started)
	BattleManager.battle_ended.connect(_on_battle_ended)

# 战斗开始时刷新双方信息
func _on_battle_started(player: Dictionary, enemy: Dictionary) -> void:
	player_name_label.text = player.get("name", "玩家")
	enemy_name_label.text = enemy.get("name", "敌人")
	refresh_view()

# 战斗结束时显示结果
func _on_battle_ended(victory: bool, result: Dictionary) -> void:
	result_overlay.visible = true
	if victory:
		result_title_label.text = "战斗胜利！"
	else:
		result_title_label.text = "你被击败了..."

# 普通攻击
func _on_attack_pressed() -> void:
	# 接口桩，委托 BattleManager 执行攻击
	pass

# 神通攻击
func _on_skill_pressed() -> void:
	# 接口桩，弹出神通选择
	pass

# 防御
func _on_defend_pressed() -> void:
	pass

# 使用物品
func _on_item_pressed() -> void:
	pass

# 逃跑
func _on_flee_pressed() -> void:
	# 接口桩，委托 BattleManager 判定逃跑
	pass

# 跳过动画切换
func _on_skip_anim_toggle() -> void:
	is_skip_anim = not is_skip_anim

# 自动战斗切换
func _on_auto_battle_toggle() -> void:
	is_auto_battle = not is_auto_battle

# 返回主场景
func _on_return() -> void:
	get_tree().change_scene_to_file("res://scenes/03game_screen.tscn")

# 刷新战斗界面
func refresh_view() -> void:
	pass

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
