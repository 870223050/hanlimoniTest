# 数据管理器接口桩
# 负责 JSON 数据文件的加载和查找操作
extends RefCounted

# 数据缓存
var items_cache: Dictionary = {}
var techniques_cache: Dictionary = {}
var locations_cache: Dictionary = {}
var events_cache: Dictionary = {}

# 加载 JSON 文件并返回解析后的数据
func load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var json_string = file.get_as_text()
	file.close()
	var data = JSON.parse_string(json_string)
	if data == null:
		return {}
	return data

# 根据物品 ID 查找物品数据
func get_item_data(item_id: String) -> Dictionary:
	if items_cache.is_empty():
		_load_items()
	return items_cache.get(item_id, {})

# 根据功法 ID 查找功法数据
func get_technique_data(tech_id: String) -> Dictionary:
	if techniques_cache.is_empty():
		_load_techniques()
	return techniques_cache.get(tech_id, {})

# 根据地点 ID 查找地点数据
func get_location_data(loc_id: String) -> Dictionary:
	if locations_cache.is_empty():
		_load_locations()
	return locations_cache.get(loc_id, {})

# 根据事件类型查找事件数据
func get_event_data(event_type: String) -> Dictionary:
	if events_cache.is_empty():
		_load_events()
	return events_cache.get(event_type, {})

# 加载物品数据
func _load_items() -> void:
	var items = load_json("res://data/items.json")
	if items is Array:
		for item in items:
			var item_id = item.get("item_id", "")
			if item_id != "":
				items_cache[item_id] = item

# 加载功法数据
func _load_techniques() -> void:
	var techs = load_json("res://data/techniques.json")
	if techs is Array:
		for tech in techs:
			var tech_id = tech.get("id", "")
			if tech_id != "":
				techniques_cache[tech_id] = tech

# 加载地点数据
func _load_locations() -> void:
	var locs = load_json("res://data/locations.json")
	if locs is Array:
		for loc in locs:
			var loc_id = loc.get("id", "")
			if loc_id != "":
				locations_cache[loc_id] = loc

# 加载事件数据
func _load_events() -> void:
	var evts = load_json("res://data/events.json")
	if evts is Array:
		for evt in evts:
			var evt_type = evt.get("type", "")
			if evt_type != "":
				events_cache[evt_type] = evt
