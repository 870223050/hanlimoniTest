# 全局游戏状态单例
# 持有玩家数据、世界时间、位置信息和事件标记
extends Node

# 玩家实例
var player: Player

# 日历数据
var calendar: Dictionary = {
	"year": 1,
	"month": 1,
	"day": 1,
	"hour": 0
}

# 当前位置
var current_location_id: String = "qingyun_main"
var current_location_name: String = "青云山·主峰"

# 已访问地点
var visited_locations: Array = []

# 叙事历史（供 LLM 上下文使用）
var narrative_history: Array = []

# 全局事件标记
var event_flags: Dictionary = {}

# NPC 关系数据
var npc_relations: Dictionary = {}

# 已知信息
var known_locations: Array = []
var known_npcs: Array = []

# 信号
signal state_changed()
signal time_advanced(hours: int)
signal location_changed(location_id: String)
signal player_died()
signal player_ascended()

# 初始化
func _ready() -> void:
	player = Player.new()
	_init_default_data()

# 初始化默认数据
func _init_default_data() -> void:
	calendar["year"] = 1
	calendar["month"] = 1
	calendar["day"] = 1
	calendar["hour"] = 6
	current_location_id = "qingyun_main"
	current_location_name = "青云山·主峰"

# 获取当前日期时间字符串
func get_datetime_string() -> String:
	var hour_name = _get_hour_name(calendar["hour"])
	return "玄黄历 %d年%d月%d日 %s时" % [calendar["year"], calendar["month"], calendar["day"], hour_name]

# 获取时辰名称
func _get_hour_name(hour: int) -> String:
	var names = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
	return names[hour % 12]

# 推进时间
func advance_time(hours: int) -> Array:
	var events = []
	var old_day = calendar["day"]
	calendar["hour"] = calendar["hour"] + hours
	while calendar["hour"] >= 12:
		calendar["hour"] = calendar["hour"] - 12
		calendar["day"] = calendar["day"] + 1
	while calendar["day"] > 30:
		calendar["day"] = calendar["day"] - 30
		calendar["month"] = calendar["month"] + 1
	while calendar["month"] > 12:
		calendar["month"] = calendar["month"] - 12
		calendar["year"] = calendar["year"] + 1
	# 年龄增长
	if calendar["day"] != old_day:
		player.age = player.age + 1
		player.remaining_lifespan = player.lifespan - player.age
		# 检查寿元
		if player.remaining_lifespan <= 0:
			player_died.emit()
	# 增加修为
	_add_cultivation_progress(hours)
	time_advanced.emit(hours)
	state_changed.emit()
	return events

# 增加修炼进度
func _add_cultivation_progress(hours: int) -> void:
	var speed = player.get_spiritual_root_multiplier() * 10.0
	var progress = speed * hours
	player.cultivation_exp = player.cultivation_exp + progress
	if player.cultivation_exp > player.exp_to_next:
		player.cultivation_exp = player.exp_to_next

# 移动位置
func move_to(location_id: String, location_name: String, travel_hours: int) -> void:
	current_location_id = location_id
	current_location_name = location_name
	if location_id not in visited_locations:
		visited_locations.append(location_id)
	advance_time(travel_hours)
	location_changed.emit(location_id)
	state_changed.emit()

# 创建玩家角色
func create_player(name: String, gender: String, roots: Array, bone: int, comp: int, sense: int, fort: int, charis: int) -> void:
	player = Player.new()
	player.player_name = name
	player.gender = gender
	player.spiritual_roots = roots.duplicate()
	player.bone_structure = bone
	player.comprehension = comp
	player.divine_sense = sense
	player.fortune = fort
	player.charisma = charis
	# 初始化战斗属性
	player.max_hp = 100.0 + bone * 5.0
	player.current_hp = player.max_hp
	player.max_sp = 50.0 + comp * 2.0
	player.current_sp = player.max_sp
	player.attack = 10.0 + bone * 0.5
	player.defense = 5.0 + bone * 0.3
	player.speed = 10.0 + comp * 0.2
	player.crit_chance = 0.05 + sense * 0.01
	state_changed.emit()

# 添加物品
func add_item(item: Dictionary) -> void:
	player.inventory.append(item)
	state_changed.emit()

# 移除物品
func remove_item(item_id: String, quantity: int) -> bool:
	for i in range(player.inventory.size()):
		if player.inventory[i].get("item_id", "") == item_id:
			player.inventory[i]["quantity"] = player.inventory[i]["quantity"] - quantity
			if player.inventory[i]["quantity"] <= 0:
				player.inventory.remove_at(i)
			state_changed.emit()
			return true
	return false

# 序列化
func to_dict() -> Dictionary:
	return {
		"player": player.to_dict(),
		"calendar": calendar.duplicate(),
		"current_location_id": current_location_id,
		"current_location_name": current_location_name,
		"visited_locations": visited_locations.duplicate(),
		"narrative_history": narrative_history.duplicate(),
		"event_flags": event_flags.duplicate(),
		"npc_relations": npc_relations.duplicate(),
		"known_locations": known_locations.duplicate(),
		"known_npcs": known_npcs.duplicate()
	}

# 反序列化
func from_dict(d: Dictionary) -> void:
	player = Player.new()
	player.from_dict(d.get("player", {}))
	calendar = d.get("calendar", {})
	current_location_id = d.get("current_location_id", "")
	current_location_name = d.get("current_location_name", "")
	visited_locations = d.get("visited_locations", [])
	narrative_history = d.get("narrative_history", [])
	event_flags = d.get("event_flags", {})
	npc_relations = d.get("npc_relations", {})
	known_locations = d.get("known_locations", [])
	known_npcs = d.get("known_npcs", [])
	state_changed.emit()
