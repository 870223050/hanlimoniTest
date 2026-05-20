# 图鉴系统接口桩
# 负责图鉴数据的解锁、查询和分类展示
extends RefCounted

# 按类别获取图鉴数据
func get_glossary(category: String) -> Array:
	# 接口桩，返回指定类别的图鉴条目
	return []

# 解锁指定图鉴条目
func unlock_entry(entry_id: String) -> void:
	# 接口桩，标记条目为已解锁
	pass

# 检查条目是否已解锁
func is_unlocked(entry_id: String) -> bool:
	# 接口桩，返回解锁状态
	return false
