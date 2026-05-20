# 人物面板脚本
# 负责展示角色属性、境界、装备和神通信息
extends CanvasLayer

# 面板引用
var panel_frame: Control
var close_button: TextureButton
var tab_buttons: Array = []
var tab_contents: Array = []

# 基本信息引用
var name_gender_label: Label
var age_label: Label
var hp_bar: TextureRect
var sp_bar: TextureRect
var poison_bar: TextureRect

# 境界引用
var realm_stage_label: Label
var cultivation_progress_bar: TextureRect
var break_condition_label: Label
var attempt_break_button: TextureButton

# 初始化节点引用
func setup() -> void:
	panel_frame = get_node("PanelFrame")
	close_button = panel_frame.get_node("CloseButton")
	var content = panel_frame.get_node("Content")
	tab_buttons = [
		content.get_node("TabBasic"),
		content.get_node("TabRealm"),
		content.get_node("TabEquip"),
		content.get_node("TabArts")
	]
	tab_contents = [
		content.get_node("TabBasicContent"),
		content.get_node("TabRealmContent"),
		content.get_node("TabEquipContent"),
		content.get_node("TabArtsContent")
	]
	var basic = content.get_node("TabBasicContent")
	name_gender_label = basic.get_node("NameGenderLabel")
	age_label = basic.get_node("AgeLabel")
	hp_bar = basic.get_node("HpBar")
	sp_bar = basic.get_node("SpBar")
	poison_bar = basic.get_node("PoisonBar")
	var realm = content.get_node("TabRealmContent")
	realm_stage_label = realm.get_node("RealmStageLabel")
	cultivation_progress_bar = realm.get_node("CultivationProgressBar")
	break_condition_label = realm.get_node("BreakConditionLabel")
	attempt_break_button = realm.get_node("AttemptBreakButton")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	attempt_break_button.pressed.connect(_on_breakthrough_pressed)
	for i in range(tab_buttons.size()):
		var idx = i
		tab_buttons[i].pressed.connect(_switch_tab.bind(idx))

# 切换到指定 Tab
func _switch_tab(tab_idx: int) -> void:
	for i in range(tab_contents.size()):
		tab_contents[i].visible = (i == tab_idx)

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 尝试突破
func _on_breakthrough_pressed() -> void:
	var result = CultivationSystem.attempt_stage_breakthrough(GameState.player)
	refresh_view()

# 从 GameState 刷新数据
func refresh_view() -> void:
	var player = GameState.player
	if player == null:
		return
	name_gender_label.text = player.player_name + "  " + player.gender
	age_label.text = "年龄：" + str(player.age) + "岁"
	realm_stage_label.text = player.realm + "·" + player.stage
	break_condition_label.text = "修为进度：" + str(player.cultivation_exp) + "/" + str(player.exp_to_next)

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
