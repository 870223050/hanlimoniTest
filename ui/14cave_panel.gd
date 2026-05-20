# 洞府面板脚本
# 负责洞府设施管理、升级和使用
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var cave_location_label: Label
var vein_level_label: Label
var spiritual_density_label: Label
var facility_buttons: Array = []
var facility_detail: Control
var facility_level_label: Label
var upgrade_button: TextureButton

# 初始化节点引用
func setup() -> void:
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	cave_location_label = content.get_node("CaveLocationLabel")
	vein_level_label = content.get_node("VeinLevelLabel")
	spiritual_density_label = content.get_node("SpiritualDensityLabel")
	var facility_list = content.get_node("FacilityList")
	facility_buttons = [
		facility_list.get_node("CultivateRoomBtn"),
		facility_list.get_node("AlchemyRoomBtn"),
		facility_list.get_node("CraftingRoomBtn"),
		facility_list.get_node("HerbGardenBtn"),
		facility_list.get_node("StorageBtn")
	]
	facility_detail = content.get_node("FacilityDetail")
	facility_level_label = facility_detail.get_node("FacilityLevelLabel")
	upgrade_button = facility_detail.get_node("UpgradeButton")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	upgrade_button.pressed.connect(_on_upgrade)
	for i in range(facility_buttons.size()):
		var idx = i
		facility_buttons[i].pressed.connect(_on_facility_selected.bind(idx))

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 选中设施
func _on_facility_selected(idx: int) -> void:
	# 接口桩，显示选中设施详情
	pass

# 升级设施
func _on_upgrade() -> void:
	# 接口桩，消耗资源升级设施
	pass

# 刷新洞府数据
func refresh_view() -> void:
	pass

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
