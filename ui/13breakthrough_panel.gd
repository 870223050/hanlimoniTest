# 突破面板脚本
# 负责境界突破条件展示、心魔考验和突破判定
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var current_realm_label: Label
var target_realm_label: Label
var progress_bar: TextureRect
var success_rate_label: Label
var condition_list_label: Label
var heart_demon_area: Control
var heart_choice_1: TextureButton
var heart_choice_2: TextureButton
var start_break_button: TextureButton
var result_area: Control

# 初始化节点引用
func setup() -> void:
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	current_realm_label = content.get_node("CurrentRealmLabel")
	target_realm_label = content.get_node("TargetRealmLabel")
	progress_bar = content.get_node("ProgressBar")
	success_rate_label = content.get_node("SuccessRateLabel")
	condition_list_label = content.get_node("ConditionListLabel")
	heart_demon_area = content.get_node("HeartDemonArea")
	heart_choice_1 = heart_demon_area.get_node("HeartChoice1")
	heart_choice_2 = heart_demon_area.get_node("HeartChoice2")
	start_break_button = content.get_node("StartBreakButton")
	result_area = content.get_node("ResultArea")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	start_break_button.pressed.connect(_on_start_break)
	heart_choice_1.pressed.connect(_on_heart_choice.bind(0))
	heart_choice_2.pressed.connect(_on_heart_choice.bind(1))

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 开始突破
func _on_start_break() -> void:
	var player = GameState.player
	if player == null:
		return
	if CultivationSystem.can_realm_breakthrough(player):
		# 大境界突破：显示心魔考验
		heart_demon_area.visible = true
	else:
		# 小境界突破：直接判定
		var result = CultivationSystem.attempt_stage_breakthrough(player)
		result_area.visible = true
		refresh_view()

# 心魔考验选择
func _on_heart_choice(choice_idx: int) -> void:
	heart_demon_area.visible = false
	result_area.visible = true

# 刷新突破数据
func refresh_view() -> void:
	var player = GameState.player
	if player == null:
		return
	current_realm_label.text = player.realm + "·" + player.stage
	success_rate_label.text = "成功率：" + str(int(CultivationSystem.get_breakthrough_rate(player) * 100)) + "%"
	condition_list_label.text = "修为：" + str(player.cultivation_exp) + "/" + str(player.exp_to_next)

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
