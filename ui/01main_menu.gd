# 标题画面脚本
# 负责主菜单按钮交互和场景切换
extends Control

# 按钮节点引用
var new_game_button: TextureButton
var load_game_button: TextureButton
var settings_button: TextureButton
var glossary_button: TextureButton
var quit_button: TextureButton

# 初始化节点引用
func setup() -> void:
	new_game_button = get_node("NewGameButton")
	load_game_button = get_node("LoadGameButton")
	settings_button = get_node("SettingsButton")
	glossary_button = get_node("GlossaryButton")
	quit_button = get_node("QuitButton")

# 绑定按钮事件
func bind_events() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	glossary_button.pressed.connect(_on_glossary_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

# 进入新游戏，切换至角色创建场景
func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/02char_create.tscn")

# 继续游戏，打开存档弹窗（读取模式）
func _on_load_game_pressed() -> void:
	UIManager.open_panel("res://scenes/panels/20save_load.tscn")

# 打开设置弹窗
func _on_settings_pressed() -> void:
	UIManager.open_panel("res://scenes/panels/18setting.tscn")

# 打开图鉴弹窗
func _on_glossary_pressed() -> void:
	UIManager.open_panel("res://scenes/panels/19glossary.tscn")

# 退出游戏
func _on_quit_pressed() -> void:
	get_tree().quit()

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
