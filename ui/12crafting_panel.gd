# 炼器面板脚本
# 负责炼器图纸选择、材料投入、锻造流程和成品展示
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var recipe_detail: Control
var recipe_name_label: Label
var material_list_label: Label
var result_preview_label: Label
var start_forge_button: TextureButton
var result_area: Control

# 初始化节点引用
func setup() -> void:
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	recipe_detail = content.get_node("RecipeDetail")
	recipe_name_label = recipe_detail.get_node("RecipeNameLabel")
	material_list_label = recipe_detail.get_node("MaterialListLabel")
	result_preview_label = recipe_detail.get_node("ResultPreviewLabel")
	start_forge_button = recipe_detail.get_node("StartForgeButton")
	result_area = content.get_node("ResultArea")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	start_forge_button.pressed.connect(_on_start_forge)

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 开始锻造
func _on_start_forge() -> void:
	recipe_detail.visible = false
	result_area.visible = true

# 刷新炼器数据
func refresh_view() -> void:
	pass

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
