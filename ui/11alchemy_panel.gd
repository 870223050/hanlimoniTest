# 炼丹面板脚本
# 负责丹方选择、材料投入、炼制流程和结果展示
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var recipe_detail: Control
var recipe_name_label: Label
var material_list_label: Label
var success_rate_label: Label
var start_refine_button: TextureButton
var refill_button: TextureButton
var result_area: Control

# 初始化节点引用
func setup() -> void:
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	recipe_detail = content.get_node("RecipeDetail")
	recipe_name_label = recipe_detail.get_node("RecipeNameLabel")
	material_list_label = recipe_detail.get_node("MaterialListLabel")
	success_rate_label = recipe_detail.get_node("SuccessRateLabel")
	start_refine_button = recipe_detail.get_node("StartRefineButton")
	refill_button = recipe_detail.get_node("RefillButton")
	result_area = content.get_node("ResultArea")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	start_refine_button.pressed.connect(_on_start_refine)
	refill_button.pressed.connect(_on_refill)

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 开始炼制
func _on_start_refine() -> void:
	recipe_detail.visible = false
	result_area.visible = true

# 自动填充材料
func _on_refill() -> void:
	# 接口桩，自动从背包填充所需材料
	pass

# 刷新炼丹数据
func refresh_view() -> void:
	pass

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
