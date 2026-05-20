# 宗门面板脚本
# 负责宗门信息展示、任务、商店、功法阁和设施管理
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var tab_buttons: Array = []
var tab_content: Control
var contribute_button: TextureButton
var leave_faction_button: TextureButton

# 信息标签
var faction_name_label: Label
var leader_label: Label
var member_count_label: Label
var personal_rank_label: Label
var reputation_label: Label
var contribution_label: Label

# 宗门系统引用
var faction_sys: FactionSystem

# 初始化节点引用
func setup() -> void:
	faction_sys = FactionSystem.new()
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	faction_name_label = content.get_node("FactionNameLabel")
	leader_label = content.get_node("LeaderLabel")
	member_count_label = content.get_node("MemberCountLabel")
	personal_rank_label = content.get_node("PersonalRankLabel")
	reputation_label = content.get_node("ReputationLabel")
	contribution_label = content.get_node("ContributionLabel")
	tab_buttons = [
		content.get_node("TabMission"),
		content.get_node("TabShop"),
		content.get_node("TabLibrary"),
		content.get_node("TabFacility")
	]
	tab_content = content.get_node("TabContent")
	contribute_button = content.get_node("ContributeButton")
	leave_faction_button = content.get_node("LeaveFactionButton")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	contribute_button.pressed.connect(_on_contribute)
	leave_faction_button.pressed.connect(_on_leave)
	for i in range(tab_buttons.size()):
		var idx = i
		tab_buttons[i].pressed.connect(_switch_tab.bind(idx))

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 切换 Tab
func _switch_tab(tab_idx: int) -> void:
	pass

# 贡献资源
func _on_contribute() -> void:
	faction_sys.contribute(100)

# 离开宗门
func _on_leave() -> void:
	# 接口桩
	pass

# 刷新宗门数据
func refresh_view() -> void:
	var player = GameState.player
	if player == null:
		return
	reputation_label.text = "声望：" + str(player.faction_reputation)
	contribution_label.text = "贡献度：" + str(player.faction_contribution)

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
