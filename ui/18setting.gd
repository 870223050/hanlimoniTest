# 设置面板脚本
# 负责音量、文本速度、全屏、LLM 后端的配置和保存
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var close_settings_btn: TextureButton
var fullscreen_toggle: TextureButton
var save_settings_button: TextureButton
var vol_master_up: TextureButton
var vol_master_down: TextureButton
var vol_bgm_up: TextureButton
var vol_bgm_down: TextureButton
var text_speed_up: TextureButton
var text_speed_down: TextureButton
var llm_backend_select: TextureButton

# 设置值
var master_volume: float = 1.0
var bgm_volume: float = 1.0
var text_speed: int = 30
var is_fullscreen: bool = false

# 初始化节点引用
func setup() -> void:
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	vol_master_down = content.get_node("VolMasterDown")
	vol_master_up = content.get_node("VolMasterUp")
	vol_bgm_down = content.get_node("VolBGMDown")
	vol_bgm_up = content.get_node("VolBGMUp")
	text_speed_down = content.get_node("TextSpeedDown")
	text_speed_up = content.get_node("TextSpeedUp")
	fullscreen_toggle = content.get_node("FullscreenToggle")
	llm_backend_select = content.get_node("LLMBackendSelect")
	save_settings_button = content.get_node("SaveSettingsButton")
	close_settings_btn = content.get_node("CloseSettingsBtn")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	close_settings_btn.pressed.connect(_on_close)
	vol_master_up.pressed.connect(_on_vol_master_up)
	vol_master_down.pressed.connect(_on_vol_master_down)
	vol_bgm_up.pressed.connect(_on_vol_bgm_up)
	vol_bgm_down.pressed.connect(_on_vol_bgm_down)
	text_speed_up.pressed.connect(_on_text_speed_up)
	text_speed_down.pressed.connect(_on_text_speed_down)
	fullscreen_toggle.pressed.connect(_on_fullscreen_toggle)
	save_settings_button.pressed.connect(_save_settings)

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 主音量 +
func _on_vol_master_up() -> void:
	master_volume = min(master_volume + 0.1, 1.0)

# 主音量 -
func _on_vol_master_down() -> void:
	master_volume = max(master_volume - 0.1, 0.0)

# BGM 音量 +
func _on_vol_bgm_up() -> void:
	bgm_volume = min(bgm_volume + 0.1, 1.0)

# BGM 音量 -
func _on_vol_bgm_down() -> void:
	bgm_volume = max(bgm_volume - 0.1, 0.0)

# 文本速度 +
func _on_text_speed_up() -> void:
	text_speed = min(text_speed + 5, 100)

# 文本速度 -
func _on_text_speed_down() -> void:
	text_speed = max(text_speed - 5, 10)

# 全屏切换
func _on_fullscreen_toggle() -> void:
	is_fullscreen = not is_fullscreen
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# 保存设置
func _save_settings() -> void:
	# 接口桩，后续保存到配置文件
	pass

# 刷新设置界面
func refresh_view() -> void:
	pass

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
