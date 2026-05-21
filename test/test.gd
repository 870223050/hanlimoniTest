# test.gd — 探索按钮 → EventManager → LLMService → 事件按钮生成 完整流程测试
extends Control

# 节点引用
var explore_button: Button          # 顶层的"请求LLM生成event列表"按钮
var event_list_container: VBoxContainer  # EventList/VBoxContainer — 存放事件选择按钮
var narration_label: Label          # 动态创建的叙事文本标签
var choice_buttons: Array = []      # VBoxContainer 中的选择按钮
var NarrationLabel: Label
# 当前事件数据缓存
var _current_choices: Array = []

func _ready() -> void:
	_setup_nodes()
	_connect_signals()

# 获取所有子节点引用，并动态创建叙事 Label
func _setup_nodes() -> void:
	explore_button = $ExploreButton as Button
	event_list_container = $EventList/EventListContainer as VBoxContainer
	NarrationLabel = $NarrationLabel as Label
	# 收集 VBoxContainer 中现有的 3 个按钮
	choice_buttons = [
		event_list_container.get_node("Button"),
		event_list_container.get_node("Button2"),
		event_list_container.get_node("Button3")
	]

	# 在 EventList 中动态创建一个 Label 用于显示叙事文本
	narration_label = NarrationLabel
	narration_label.name = "NarrationLabel"
	narration_label.text = ""
	narration_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	narration_label.custom_minimum_size = Vector2(400, 60)
	narration_label.add_theme_font_size_override("font_size", 14)

	# 初始隐藏选择按钮
	for btn in choice_buttons:
		btn.visible = false

# 连接信号
func _connect_signals() -> void:
	# 1. 点击"探索"按钮 → 触发 EventManager
	explore_button.pressed.connect(_on_explore_pressed)

	# 2. EventManager 返回事件数据 → 展示叙事文本 + 生成选择按钮
	if not EventManager.event_display.is_connected(_on_event_display):
		EventManager.event_display.connect(_on_event_display)

	# 3. 选择执行完毕 → 展示结果
	if not EventManager.event_result.is_connected(_on_event_result):
		EventManager.event_result.connect(_on_event_result)


# ---------- 处理流程 ----------

# 步骤1: 点击 ExploreButton → 调用 EventManager
func _on_explore_pressed() -> void:
	explore_button.disabled = true
	explore_button.text = "请求中..."
	EventManager.trigger_exploration()


# 步骤2: EventManager 返回事件 → 显示叙事 + 生成选择按钮
func _on_event_display(narration: String, choices: Array) -> void:
	# 恢复探索按钮
	explore_button.disabled = false
	explore_button.text = "请求LLM生成event列表"

	# 显示叙事文本
	narration_label.text = narration
	narration_label.visible = true

	# 缓存当前选择
	_current_choices = choices

	# 根据 choices 数量显示/隐藏按钮，并设置文本
	for i in range(choice_buttons.size()):
		if i < choices.size():
			var btn: Button = choice_buttons[i]
			var choice = choices[i]
			# 设置按钮文本：选项文字 + 风险提示
			var risk_hint: String = choice.get("risk_hint", "")
			var risk_icon: String = ""
			match risk_hint:
				"safe":      risk_icon = "[安全] "
				"risky":     risk_icon = "[冒险] "
				"dangerous": risk_icon = "[危险] "
				"unknown":   risk_icon = "[未知] "
			btn.text = risk_icon + choice.get("text", "选项 %d" % (i + 1))
			btn.visible = true
			# 绑定点击事件（先断开旧连接，再重新连接）
			if btn.pressed.is_connected(_on_choice_pressed):
				btn.pressed.disconnect(_on_choice_pressed)
			btn.pressed.connect(_on_choice_pressed.bind(choice.get("id", "")))
		else:
			choice_buttons[i].visible = false


# 步骤3: 玩家点击某个选择按钮 → 执行事件选择
func _on_choice_pressed(choice_id: String) -> void:
	# 禁用所有选择按钮，防止重复点击
	for btn in choice_buttons:
		btn.disabled = true

	# 交由 EventManager 执行（数据驱动 effects 执行 + 发射 event_result）
	EventManager.execute_choice(choice_id)


# 步骤4: 选择执行后的结果展示
func _on_event_result(narration: String) -> void:
	if narration != "":
		narration_label.text = narration
	else:
		narration_label.text = "事件已处理。"

	# 隐藏选择按钮
	for btn in choice_buttons:
		btn.visible = false
		btn.disabled = false

	# 恢复探索按钮
	explore_button.disabled = false
	explore_button.text = "请求LLM生成event列表"
