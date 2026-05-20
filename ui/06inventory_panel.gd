# 背包面板脚本
# 负责物品列表展示、分类筛选、物品使用和丢弃
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var filter_buttons: Array = []
var item_grid: Control
var capacity_label: Label
var detail_area: Control
var item_name_label: Label
var item_desc_label: Label
var use_button: TextureButton
var equip_button: TextureButton
var discard_button: TextureButton
var alchemy_entry_button: TextureButton
var crafting_entry_button: TextureButton

# 当前筛选 (0:全部 1:丹药 2:材料 3:装备 4:功法书 5:任务品)
var current_filter: int = 0

# 初始化节点引用
func setup() -> void:
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	filter_buttons = [
		content.get_node("FilterAll"),
		content.get_node("FilterPill"),
		content.get_node("FilterMaterial"),
		content.get_node("FilterEquip"),
		content.get_node("FilterBook"),
		content.get_node("FilterQuest")
	]
	item_grid = content.get_node("ItemGrid")
	capacity_label = content.get_node("CapacityLabel")
	detail_area = content.get_node("DetailArea")
	item_name_label = detail_area.get_node("ItemNameLabel")
	item_desc_label = detail_area.get_node("ItemDescLabel")
	use_button = detail_area.get_node("UseButton")
	equip_button = detail_area.get_node("EquipButton")
	discard_button = detail_area.get_node("DiscardButton")
	alchemy_entry_button = detail_area.get_node("AlchemyEntryButton")
	crafting_entry_button = detail_area.get_node("CraftingEntryButton")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	use_button.pressed.connect(_on_use_pressed)
	discard_button.pressed.connect(_on_discard_pressed)
	alchemy_entry_button.pressed.connect(_on_alchemy_entry)
	crafting_entry_button.pressed.connect(_on_crafting_entry)
	for i in range(filter_buttons.size()):
		var idx = i
		filter_buttons[i].pressed.connect(_filter_items.bind(idx))

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 按分类筛选物品
func _filter_items(category: int) -> void:
	current_filter = category
	refresh_view()

# 显示物品详情
func _show_item_detail(item: Dictionary) -> void:
	item_name_label.text = item.get("name", "未知物品")
	item_desc_label.text = item.get("description", "")

# 使用物品
func _on_use_pressed() -> void:
	# 接口桩
	pass

# 丢弃物品
func _on_discard_pressed() -> void:
	# 接口桩
	pass

# 打开炼丹面板
func _on_alchemy_entry() -> void:
	UIManager.open_panel("res://scenes/panels/11alchemy_panel.tscn")

# 打开炼器面板
func _on_crafting_entry() -> void:
	UIManager.open_panel("res://scenes/panels/12crafting_panel.tscn")

# 刷新背包数据
func refresh_view() -> void:
	var player = GameState.player
	if player == null:
		return
	capacity_label.text = str(player.inventory.size()) + "/" + str(player.inventory_capacity)

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
