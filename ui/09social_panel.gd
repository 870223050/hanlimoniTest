# 社交面板脚本
# 负责 NPC 关系列表展示和交互操作（交谈/论道/切磋/赠礼/交易）
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var npc_name_label: Label
var npc_realm_label: Label
var relation_label: Label
var favor_bar: TextureRect
var talk_button: TextureButton
var discuss_button: TextureButton
var spar_button: TextureButton
var gift_button: TextureButton
var trade_button: TextureButton

# 初始化节点引用
func setup() -> void:
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var detail = frame.get_node("Content/NPCDetail")
	npc_name_label = detail.get_node("NPCNameLabel")
	npc_realm_label = detail.get_node("NPCRealmLabel")
	relation_label = detail.get_node("RelationLabel")
	favor_bar = detail.get_node("FavorBar")
	talk_button = detail.get_node("TalkButton")
	discuss_button = detail.get_node("DiscussButton")
	spar_button = detail.get_node("SparButton")
	gift_button = detail.get_node("GiftButton")
	trade_button = detail.get_node("TradeButton")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	talk_button.pressed.connect(_on_talk)
	discuss_button.pressed.connect(_on_discuss)
	spar_button.pressed.connect(_on_spar)
	gift_button.pressed.connect(_on_gift)
	trade_button.pressed.connect(_on_trade)

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 与 NPC 交谈
func _on_talk() -> void:
	# 接口桩，调用 NPC 对话逻辑
	pass

# 与 NPC 论道
func _on_discuss() -> void:
	# 接口桩
	pass

# 与 NPC 切磋
func _on_spar() -> void:
	# 接口桩
	pass

# 赠送礼物
func _on_gift() -> void:
	# 接口桩
	pass

# 交易
func _on_trade() -> void:
	# 接口桩
	pass

# 刷新社交数据
func refresh_view() -> void:
	pass

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
