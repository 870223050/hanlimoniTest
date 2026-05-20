# 游戏结束场景脚本
# 负责结局展示、生涯统计和重新开始/返回标题
extends Control

# 面板引用
var ending_title_label: Label
var summary_label: Label
var cultivation_years_label: Label
var final_realm_label: Label
var kill_count_label: Label
var achievement_label: Label
var rebirth_button: TextureButton
var main_menu_button: TextureButton

# 初始化节点引用
func setup() -> void:
	ending_title_label = get_node("EndingTitleLabel")
	summary_label = get_node("SummaryLabel")
	var stats = get_node("StatsArea")
	cultivation_years_label = stats.get_node("CultivationYearsLabel")
	final_realm_label = stats.get_node("FinalRealmLabel")
	kill_count_label = stats.get_node("KillCountLabel")
	achievement_label = stats.get_node("AchievementLabel")
	rebirth_button = get_node("RebirthButton")
	main_menu_button = get_node("MainMenuButton")

# 绑定按钮事件
func bind_events() -> void:
	rebirth_button.pressed.connect(_on_rebirth)
	main_menu_button.pressed.connect(_on_main_menu)

# 轮回转世
func _on_rebirth() -> void:
	# 接口桩，继承部分资源重新进入创角
	get_tree().change_scene_to_file("res://scenes/02char_create.tscn")

# 返回标题画面
func _on_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/01main_menu.tscn")

# 刷新结算数据
func refresh_view() -> void:
	var player = GameState.player
	if player == null:
		return
	var ending_type = "寿元耗尽·仙途终焉"
	ending_title_label.text = ending_type
	final_realm_label.text = "最终境界：" + player.realm + "·" + player.stage

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
