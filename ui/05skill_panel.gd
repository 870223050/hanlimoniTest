# 功法面板脚本
# 负责功法列表展示、筛选、详情查看和修炼/遗忘操作
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var filter_buttons: Array = []
var detail_area: Control
var tech_name_label: Label
var tech_grade_label: Label
var tech_level_label: Label
var tech_desc_label: Label
var cultivate_button: TextureButton
var forget_button: TextureButton

# 当前筛选状态 (0: 战斗神通, 1: 被动心法, 2: 主修功法)
var current_filter: int = 0

# 初始化节点引用
func setup() -> void:
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	filter_buttons = [
		content.get_node("FilterCombat"),
		content.get_node("FilterPassive"),
		content.get_node("FilterMain")
	]
	detail_area = content.get_node("DetailArea")
	tech_name_label = detail_area.get_node("TechNameLabel")
	tech_grade_label = detail_area.get_node("TechGradeLabel")
	tech_level_label = detail_area.get_node("TechLevelLabel")
	tech_desc_label = detail_area.get_node("TechDescLabel")
	cultivate_button = detail_area.get_node("CultivateButton")
	forget_button = detail_area.get_node("ForgetButton")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	cultivate_button.pressed.connect(_on_cultivate_pressed)
	forget_button.pressed.connect(_on_forget_pressed)
	for i in range(filter_buttons.size()):
		var idx = i
		filter_buttons[i].pressed.connect(_apply_filter.bind(idx))

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 应用筛选
func _apply_filter(filter_idx: int) -> void:
	current_filter = filter_idx
	refresh_view()

# 显示功法详情
func _show_technique_detail(tech: Dictionary) -> void:
	tech_name_label.text = tech.get("name", "未知道功法")
	tech_grade_label.text = "品级：" + tech.get("grade", "未知")
	tech_level_label.text = "层数：" + str(tech.get("level", 1)) + "/" + str(tech.get("max_level", 9))
	tech_desc_label.text = tech.get("description", "")

# 修炼功法
func _on_cultivate_pressed() -> void:
	# 接口桩，调用功法系统
	pass

# 遗忘功法
func _on_forget_pressed() -> void:
	# 接口桩，调用功法系统
	pass

# 刷新功法列表
func refresh_view() -> void:
	var player = GameState.player
	if player == null:
		return

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
