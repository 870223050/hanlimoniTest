# UI 面板栈管理单例
# 负责弹窗的打开、关闭和 Esc 键处理
extends Node

# 面板栈
var panel_stack: Array = []

# 打开弹窗
func open_panel(panel_path: String) -> void:
	var scene = load(panel_path)
	if scene == null:
		return
	var panel = scene.instantiate()
	var root = get_tree().current_scene
	if root == null:
		return
	root.add_child(panel)
	panel_stack.append(panel)

# 关闭最上层弹窗
func close_top_panel() -> void:
	if panel_stack.is_empty():
		return
	var panel = panel_stack.pop_back()
	if is_instance_valid(panel):
		panel.queue_free()

# 关闭所有弹窗
func close_all_panels() -> void:
	while not panel_stack.is_empty():
		var panel = panel_stack.pop_back()
		if is_instance_valid(panel):
			panel.queue_free()

# Esc 键处理
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not panel_stack.is_empty():
			close_top_panel()
			get_viewport().set_input_as_handled()

# 是否有打开的弹窗
func has_open_panel() -> bool:
	return not panel_stack.is_empty()
