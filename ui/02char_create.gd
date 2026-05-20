# 角色创建场景脚本
# 负责四步向导流程：基本信息 → 灵根 → 属性 → 确认
extends Control

# 步骤容器引用
var step_containers: Array = []
# 当前步骤索引 (0-3)
var current_step: int = 0

# 输入和选择引用
var name_input: LineEdit
var male_button: TextureButton
var female_button: TextureButton
var random_name_button: TextureButton
var reroll_root_button: TextureButton
var reroll_attr_button: TextureButton
var confirm_button: TextureButton
var prev_button: TextureButton
var next_button: TextureButton

# 当前选择数据
var selected_gender: String = "男"
var selected_roots: Array = []
var selected_name: String = ""
var attr_bone: int = 10
var attr_comp: int = 10
var attr_sense: int = 10
var attr_fortune: int = 10
var attr_charis: int = 10

# 预设姓名池
var name_pool: Array = ["云逸", "沐清", "玄真", "灵均", "青蓠", "凌天", "若虚", "道玄", "逍遥", "凤歌"]

# 初始化节点引用
func setup() -> void:
	step_containers = [
		get_node("Step1Container"),
		get_node("Step2Container"),
		get_node("Step3Container"),
		get_node("Step4Container")
	]
	name_input = get_node("Step1Container/NameInput")
	male_button = get_node("Step1Container/MaleButton")
	female_button = get_node("Step1Container/FemaleButton")
	random_name_button = get_node("Step1Container/RandomNameButton")
	reroll_root_button = get_node("Step2Container/RerollRootButton")
	reroll_attr_button = get_node("Step3Container/RerollAttrButton")
	confirm_button = get_node("Step4Container/ConfirmButton")
	prev_button = get_node("PrevButton")
	next_button = get_node("NextButton")

# 绑定按钮事件
func bind_events() -> void:
	male_button.pressed.connect(_on_male_pressed)
	female_button.pressed.connect(_on_female_pressed)
	random_name_button.pressed.connect(_on_random_name_pressed)
	reroll_root_button.pressed.connect(_on_reroll_roots)
	reroll_attr_button.pressed.connect(_on_reroll_attrs)
	confirm_button.pressed.connect(_on_confirm)
	prev_button.pressed.connect(_on_prev)
	next_button.pressed.connect(_on_next)

# 切换到指定步骤
func _go_to_step(step_idx: int) -> void:
	for i in range(step_containers.size()):
		step_containers[i].visible = (i == step_idx)
	current_step = step_idx
	prev_button.visible = (step_idx > 0)
	if step_idx == 3:
		next_button.visible = false
	else:
		next_button.visible = true
	_highlight_step_dots()

# 高亮步骤指示器
func _highlight_step_dots() -> void:
	var indicator = get_node("StepIndicator")
	for i in range(4):
		var dot = indicator.get_node("StepDot" + str(i + 1))
		if i <= current_step:
			dot.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			dot.self_modulate = Color(0.3, 0.3, 0.3, 1.0)

# 选择男性
func _on_male_pressed() -> void:
	selected_gender = "男"

# 选择女性
func _on_female_pressed() -> void:
	selected_gender = "女"

# 随机生成姓名
func _on_random_name_pressed() -> void:
	selected_name = name_pool[randi() % name_pool.size()]
	name_input.text = selected_name

# 重铸灵根
func _on_reroll_roots() -> void:
	var root_types = ["金", "木", "水", "火", "土"]
	selected_roots.clear()
	# 灵根数量加权随机：单灵根5% 双灵根15% 三灵根40% 四灵根25% 杂灵根15%
	var roll = randf()
	var root_count = 3
	if roll < 0.05:
		root_count = 1
	elif roll < 0.20:
		root_count = 2
	elif roll < 0.60:
		root_count = 3
	elif roll < 0.85:
		root_count = 4
	else:
		root_count = 5
	var shuffled = root_types.duplicate()
	shuffled.shuffle()
	for i in range(root_count):
		selected_roots.append(shuffled[i])
	_refresh_roots_display()

# 重铸先天属性
func _on_reroll_attrs() -> void:
	attr_bone = randi() % 16 + 5
	attr_comp = randi() % 16 + 5
	attr_sense = randi() % 16 + 5
	attr_fortune = randi() % 16 + 5
	attr_charis = randi() % 16 + 5
	refresh_view()

# 确认创建角色
func _on_confirm() -> void:
	selected_name = name_input.text
	if selected_name == "":
		selected_name = name_pool[randi() % name_pool.size()]
	if selected_roots.is_empty():
		_on_reroll_roots()
	GameState.create_player(selected_name, selected_gender, selected_roots, attr_bone, attr_comp, attr_sense, attr_fortune, attr_charis)
	get_tree().change_scene_to_file("res://scenes/03game_screen.tscn")

# 上一步
func _on_prev() -> void:
	if current_step > 0:
		_go_to_step(current_step - 1)

# 下一步
func _on_next() -> void:
	if current_step < 3:
		_go_to_step(current_step + 1)

# 刷新灵根图标显示
func _refresh_roots_display() -> void:
	var container = get_node("Step2Container")
	var root_names = ["金", "木", "水", "火", "土"]
	var icon_names = ["RootGoldIcon", "RootWoodIcon", "RootWaterIcon", "RootFireIcon", "RootEarthIcon"]
	for i in range(5):
		var icon = container.get_node(icon_names[i])
		if root_names[i] in selected_roots:
			icon.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			icon.self_modulate = Color(0.2, 0.2, 0.2, 1.0)
	var result_label = container.get_node("RootResultLabel")
	var root_type_names = ["无灵根", "单灵根", "双灵根", "三灵根", "四灵根", "杂灵根"]
	if selected_roots.size() > 0:
		result_label.text = "".join(selected_roots) + " - " + root_type_names[selected_roots.size()]

# 刷新当前视图
func refresh_view() -> void:
	if current_step == 2:
		# 刷新属性展示
		pass

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	_go_to_step(0)
