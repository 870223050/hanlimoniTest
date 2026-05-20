# 地图面板脚本
# 负责世界地图/区域地图展示、地点选择和移动操作
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var map_area: Control
var world_map_bg: TextureRect
var player_marker: TextureRect
var current_loc_label: Label
var travel_button: TextureButton
var teleport_button: TextureButton
var view_toggle_button: TextureButton

# 地点节点引用
var location_nodes: Array = []

# 当前视图模式 (true: 世界地图, false: 区域地图)
var is_world_view: bool = true

# 选中地点 ID
var selected_location_id: String = ""

# 初始化节点引用
func setup() -> void:
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	map_area = content.get_node("MapArea")
	world_map_bg = map_area.get_node("WorldMapBg")
	player_marker = map_area.get_node("PlayerMarker")
	# 收集地点按钮
	for i in range(1, 4):
		var node = map_area.get_node_or_null("LocationNode" + str(i))
		if node:
			location_nodes.append(node)
	var info_bar = content.get_node("InfoBar")
	current_loc_label = info_bar.get_node("CurrentLocLabel")
	travel_button = info_bar.get_node("TravelButton")
	teleport_button = info_bar.get_node("TeleportButton")
	view_toggle_button = info_bar.get_node("ViewToggleButton")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	travel_button.pressed.connect(_on_travel)
	teleport_button.pressed.connect(_on_teleport)
	view_toggle_button.pressed.connect(_toggle_view)
	for i in range(location_nodes.size()):
		var idx = i
		location_nodes[i].pressed.connect(_on_location_selected.bind(idx))

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 选中地点
func _on_location_selected(index: int) -> void:
	var loc_names = ["青云山·主峰", "坊市·天宝阁", "苍梧秘境"]
	selected_location_id = loc_names[index % loc_names.size()]

# 前往选中地点
func _on_travel() -> void:
	if selected_location_id != "":
		GameState.move_to(selected_location_id, selected_location_id, 2)

# 传送到传送阵
func _on_teleport() -> void:
	# 接口桩，后续扩展传送功能
	pass

# 切换世界/区域地图视图
func _toggle_view() -> void:
	is_world_view = not is_world_view
	refresh_view()

# 刷新地图数据
func refresh_view() -> void:
	current_loc_label.text = GameState.current_location_name

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
