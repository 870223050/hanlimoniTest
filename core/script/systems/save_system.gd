# 存档系统接口桩
# 负责游戏存档的读写、列表和删除操作
extends RefCounted

# 存档目录路径
const SAVE_DIR = "user://saves/"

# 将当前游戏状态保存到指定槽位
func save_game(slot_id: int) -> bool:
	var dir = DirAccess.open("user://")
	if dir == null:
		return false
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
	var file = FileAccess.open(SAVE_DIR + "save_" + str(slot_id) + ".json", FileAccess.WRITE)
	if file == null:
		return false
	var data = GameState.to_dict()
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true

# 从指定槽位加载游戏状态
func load_game(slot_id: int) -> bool:
	var file = FileAccess.open(SAVE_DIR + "save_" + str(slot_id) + ".json", FileAccess.READ)
	if file == null:
		return false
	var json_string = file.get_as_text()
	file.close()
	var data = JSON.parse_string(json_string)
	if data == null:
		return false
	GameState.from_dict(data)
	return true

# 列出所有存档槽位信息
func list_saves() -> Array:
	var result = []
	var dir = DirAccess.open(SAVE_DIR)
	if dir == null:
		return result
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("save_") and file_name.ends_with(".json"):
			var slot_id_str = file_name.trim_prefix("save_").trim_suffix(".json")
			var slot_id = int(slot_id_str)
			result.append({"slot_id": slot_id, "file_name": file_name})
		file_name = dir.get_next()
	dir.list_dir_end()
	return result

# 删除指定槽位的存档
func delete_save(slot_id: int) -> bool:
	var file_path = SAVE_DIR + "save_" + str(slot_id) + ".json"
	if not FileAccess.file_exists(file_path):
		return false
	var dir = DirAccess.open(SAVE_DIR)
	if dir == null:
		return false
	dir.remove("save_" + str(slot_id) + ".json")
	return true

# 获取存档文件的最后修改时间
func get_save_info(slot_id: int) -> Dictionary:
	var file_path = SAVE_DIR + "save_" + str(slot_id) + ".json"
	if not FileAccess.file_exists(file_path):
		return {"exists": false}
	# 接口桩，返回基本信息
	return {"exists": true, "slot_id": slot_id}
