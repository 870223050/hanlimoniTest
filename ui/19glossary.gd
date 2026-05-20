# 图鉴面板脚本
# 负责各类图鉴（功法/丹药/妖兽/NPC/地点/教程）的查看
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var tab_buttons: Array = []
var glossary_content: Control

# 初始化节点引用
func setup() -> void:
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	tab_buttons = [
		content.get_node("TabTechniques"),
		content.get_node("TabPills"),
		content.get_node("TabMonsters"),
		content.get_node("TabNPCs"),
		content.get_node("TabLocations"),
		content.get_node("TabTutorial")
	]
	glossary_content = content.get_node("GlossaryContent")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	for i in range(tab_buttons.size()):
		var idx = i
		tab_buttons[i].pressed.connect(_switch_tab.bind(idx))

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 切换图鉴分类
func _switch_tab(tab_idx: int) -> void:
	# 接口桩，根据分类切换图鉴内容
	pass

# 刷新图鉴数据
func refresh_view() -> void:
	pass

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
