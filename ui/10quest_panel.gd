# 任务面板脚本
# 负责任务列表展示、进度查看、追踪和放弃操作
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var tab_ongoing: TextureButton
var tab_completed: TextureButton
var quest_name_label: Label
var quest_desc_label: Label
var quest_progress_label: Label
var quest_reward_label: Label
var track_button: TextureButton
var abandon_button: TextureButton

# 初始化节点引用
func setup() -> void:
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	tab_ongoing = content.get_node("TabOngoing")
	tab_completed = content.get_node("TabCompleted")
	var detail = content.get_node("QuestDetail")
	quest_name_label = detail.get_node("QuestNameLabel")
	quest_desc_label = detail.get_node("QuestDescLabel")
	quest_progress_label = detail.get_node("QuestProgressLabel")
	quest_reward_label = detail.get_node("QuestRewardLabel")
	track_button = detail.get_node("TrackButton")
	abandon_button = detail.get_node("AbandonButton")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	tab_ongoing.pressed.connect(_switch_tab.bind(0))
	tab_completed.pressed.connect(_switch_tab.bind(1))
	track_button.pressed.connect(_on_track)
	abandon_button.pressed.connect(_on_abandon)

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 切换进行中/已完成 Tab
func _switch_tab(tab_idx: int) -> void:
	pass

# 追踪任务
func _on_track() -> void:
	# 接口桩
	pass

# 放弃任务
func _on_abandon() -> void:
	# 接口桩
	pass

# 刷新任务数据
func refresh_view() -> void:
	var player = GameState.player
	if player == null:
		return

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
