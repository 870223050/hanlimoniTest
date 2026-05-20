# 存档/读档面板脚本
# 负责存档槽位展示、保存和读取操作
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var close_save_btn: TextureButton
var delete_button: TextureButton
var slot_controls: Array = []

# 存档模式 ("save" 或 "load")
var mode: String = "save"

# 存档系统引用
var save_sys: SaveSystem

# 初始化节点引用
func setup() -> void:
	save_sys = SaveSystem.new()
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	close_save_btn = content.get_node("CloseSaveBtn")
	delete_button = content.get_node("DeleteButton")
	for i in range(1, 6):
		var slot = content.get_node("Slot" + str(i))
		var info_label = slot.get_node("Slot" + str(i) + "InfoLabel")
		var action_button = slot.get_node("Slot" + str(i) + "ActionButton")
		slot_controls.append({
			"info_label": info_label,
			"action_button": action_button,
			"slot_id": i
		})

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	close_save_btn.pressed.connect(_on_close)
	delete_button.pressed.connect(_on_delete)
	for slot_data in slot_controls:
		var btn = slot_data["action_button"]
		var slot_id = slot_data["slot_id"]
		btn.pressed.connect(_on_slot_action.bind(slot_id))

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 槽位操作（保存或读取）
func _on_slot_action(slot_id: int) -> void:
	if mode == "save":
		save_sys.save_game(slot_id)
	else:
		save_sys.load_game(slot_id)
		if mode == "load":
			get_tree().change_scene_to_file("res://scenes/03game_screen.tscn")

# 删除存档
func _on_delete() -> void:
	# 接口桩
	pass

# 刷新存档列表
func refresh_view() -> void:
	for slot_data in slot_controls:
		var slot_id = slot_data["slot_id"]
		var info = save_sys.get_save_info(slot_id)
		var label = slot_data["info_label"]
		if info.get("exists", false):
			label.text = "槽位 " + str(slot_id) + " - 已存档"
		else:
			label.text = "槽位 " + str(slot_id) + " - 空"

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
