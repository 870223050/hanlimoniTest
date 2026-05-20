# 主游戏界面脚本
# 负责 HUD 数据刷新、事件展示、快捷栏交互和面板打开
extends Control

# HUD 标签引用
var player_name_label: Label
var realm_label: Label
var realm_progress_bar: TextureRect
var lifespan_label: Label
var spirit_stones_label: Label
var datetime_label: Label
var location_label: Label

# 事件区引用
var narration_label: Label
var choice_buttons: Array = []
var continue_button: TextureButton
var event_area: Control

# 空闲区引用
var idle_area: Control
var cultivate_button: TextureButton
var explore_button: TextureButton
var travel_button: TextureButton

# 快捷栏按钮引用
var quick_buttons: Dictionary = {}

# 通知标签
var toast_label: Label

# 初始化节点引用
func setup() -> void:
	var top_hud = get_node("TopHUD")
	player_name_label = top_hud.get_node("PlayerNameLabel")
	realm_label = top_hud.get_node("RealmLabel")
	realm_progress_bar = top_hud.get_node("RealmProgressBar")
	lifespan_label = top_hud.get_node("LifespanLabel")
	spirit_stones_label = top_hud.get_node("SpiritStonesLabel")
	datetime_label = top_hud.get_node("DateTimeLabel")
	location_label = top_hud.get_node("LocationLabel")
	event_area = get_node("EventArea")
	narration_label = event_area.get_node("NarrationLabel")
	choice_buttons = [
		event_area.get_node("ChoiceButton1"),
		event_area.get_node("ChoiceButton2"),
		event_area.get_node("ChoiceButton3")
	]
	continue_button = event_area.get_node("ContinueButton")
	idle_area = get_node("IdleArea")
	cultivate_button = idle_area.get_node("CultivateButton")
	explore_button = idle_area.get_node("ExploreButton")
	travel_button = idle_area.get_node("TravelButton")
	toast_label = get_node("ToastLabel")
	var quick_bar = get_node("QuickBar")
	quick_buttons = {
		"character": quick_bar.get_node("CharacterButton"),
		"skill": quick_bar.get_node("SkillButton"),
		"inventory": quick_bar.get_node("InventoryButton"),
		"map": quick_bar.get_node("MapButton"),
		"faction": quick_bar.get_node("FactionButton"),
		"social": quick_bar.get_node("SocialButton"),
		"quest": quick_bar.get_node("QuestButton"),
		"system": quick_bar.get_node("SystemButton")
	}

# 绑定信号和事件
func bind_events() -> void:
	GameState.state_changed.connect(_on_state_changed)
	EventManager.event_display.connect(_on_event_display)
	EventManager.event_result.connect(_on_event_result)
	cultivate_button.pressed.connect(_on_cultivate_pressed)
	explore_button.pressed.connect(_on_explore_pressed)
	travel_button.pressed.connect(_on_travel_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	quick_buttons["character"].pressed.connect(_open_character_panel)
	quick_buttons["skill"].pressed.connect(_open_skill_panel)
	quick_buttons["inventory"].pressed.connect(_open_inventory_panel)
	quick_buttons["map"].pressed.connect(_open_map_panel)
	quick_buttons["faction"].pressed.connect(_open_faction_panel)
	quick_buttons["social"].pressed.connect(_open_social_panel)
	quick_buttons["quest"].pressed.connect(_open_quest_panel)
	quick_buttons["system"].pressed.connect(_open_system_menu)
	for i in range(choice_buttons.size()):
		var idx = i
		choice_buttons[i].pressed.connect(_on_choice_pressed.bind(i))
	# 默认显示空闲状态
	_show_idle()

# 全局状态变化时刷新 HUD
func _on_state_changed() -> void:
	refresh_view()

# 展示事件文本和选项
func _on_event_display(narration: String, choices: Array) -> void:
	idle_area.visible = false
	event_area.visible = true
	narration_label.text = narration
	# 隐藏所有选项按钮
	for btn in choice_buttons:
		btn.visible = false
	# 根据选项数量显示按钮
	for i in range(choices.size()):
		if i < choice_buttons.size():
			choice_buttons[i].visible = true
			# 选项文本通过脚本暂存，这里仅展示占位
	continue_button.visible = false

# 展示事件执行结果
func _on_event_result(narration: String) -> void:
	narration_label.text = narration
	for btn in choice_buttons:
		btn.visible = false
	continue_button.visible = true

# 选项被点击
func _on_choice_pressed(choice_idx: int) -> void:
	# 隐藏所有选项按钮防止重复点击
	for btn in choice_buttons:
		btn.visible = false
	EventManager.execute_choice("choice_" + str(choice_idx + 1))

# 继续按钮点击
func _on_continue_pressed() -> void:
	_show_idle()
	EventManager.event_result.emit("")

# 显示空闲状态
func _show_idle() -> void:
	event_area.visible = false
	idle_area.visible = true

# 闭关修炼
func _on_cultivate_pressed() -> void:
	EventManager.trigger_cultivate(6)

# 外出探索
func _on_explore_pressed() -> void:
	EventManager.trigger_exploration()

# 游历四方
func _on_travel_pressed() -> void:
	_open_panel("res://scenes/panels/07map_panel.tscn")

# 打开面板的通用方法
func _open_panel(panel_path: String) -> void:
	UIManager.open_panel(panel_path)

func _open_character_panel() -> void:
	_open_panel("res://scenes/panels/04character_panel.tscn")

func _open_skill_panel() -> void:
	_open_panel("res://scenes/panels/05skill_panel.tscn")

func _open_inventory_panel() -> void:
	_open_panel("res://scenes/panels/06inventory_panel.tscn")

func _open_map_panel() -> void:
	_open_panel("res://scenes/panels/07map_panel.tscn")

func _open_faction_panel() -> void:
	_open_panel("res://scenes/panels/08faction_panel.tscn")

func _open_social_panel() -> void:
	_open_panel("res://scenes/panels/09social_panel.tscn")

func _open_quest_panel() -> void:
	_open_panel("res://scenes/panels/10quest_panel.tscn")

# 打开系统菜单（存档/读档/设置/返回标题）
func _open_system_menu() -> void:
	_open_panel("res://scenes/panels/20save_load.tscn")

# 显示浮动通知
func show_toast(message: String) -> void:
	toast_label.text = message
	toast_label.visible = true
	# 2 秒后自动隐藏
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(_hide_toast)

func _hide_toast() -> void:
	toast_label.visible = false

# 刷新全部界面数据
func refresh_view() -> void:
	var player = GameState.player
	if player == null:
		return
	player_name_label.text = player.player_name + "·" + player.get_title()
	realm_label.text = player.realm + "·" + player.stage
	lifespan_label.text = "寿元：" + str(player.age) + "/" + str(player.lifespan) + "岁"
	spirit_stones_label.text = "灵石：" + str(player.spirit_stones)
	datetime_label.text = GameState.get_datetime_string()
	location_label.text = GameState.current_location_name

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
