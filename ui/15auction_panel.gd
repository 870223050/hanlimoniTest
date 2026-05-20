# 拍卖行面板脚本
# 负责拍卖品浏览、出价、一口价和寄售操作
extends CanvasLayer

# 面板引用
var close_button: TextureButton
var item_name_label: Label
var current_bid_label: Label
var bid_button: TextureButton
var buyout_button: TextureButton
var sell_button: TextureButton

# 拍卖系统引用
var auction_sys: AuctionSystem

# 初始化节点引用
func setup() -> void:
	auction_sys = AuctionSystem.new()
	var frame = get_node("PanelFrame")
	close_button = frame.get_node("CloseButton")
	var content = frame.get_node("Content")
	var detail = content.get_node("ItemDetail")
	item_name_label = detail.get_node("ItemNameLabel")
	current_bid_label = detail.get_node("CurrentBidLabel")
	bid_button = detail.get_node("BidButton")
	buyout_button = detail.get_node("BuyoutButton")
	sell_button = content.get_node("SellButton")

# 绑定按钮事件
func bind_events() -> void:
	close_button.pressed.connect(_on_close)
	bid_button.pressed.connect(_on_bid)
	buyout_button.pressed.connect(_on_buyout)
	sell_button.pressed.connect(_on_sell)

# 关闭弹窗
func _on_close() -> void:
	UIManager.close_top_panel()

# 出价
func _on_bid() -> void:
	auction_sys.place_bid("item_001", 500)

# 一口价购买
func _on_buyout() -> void:
	# 接口桩
	pass

# 寄售物品
func _on_sell() -> void:
	# 接口桩，弹出背包选择物品
	pass

# 刷新拍卖数据
func refresh_view() -> void:
	pass

# 准备就绪时初始化
func _ready() -> void:
	setup()
	bind_events()
	refresh_view()
