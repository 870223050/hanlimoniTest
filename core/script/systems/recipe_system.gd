# 配方系统接口桩
# 负责丹方和炼器图纸的获取、条件检查和成功率计算
extends RefCounted

# 获取所有炼丹配方
func get_alchemy_recipes() -> Array:
	# 接口桩，返回丹方列表
	return []

# 获取所有炼器图纸
func get_crafting_recipes() -> Array:
	# 接口桩，返回炼器图纸列表
	return []

# 检查是否可以炼制
func can_craft(recipe_id: String, materials: Array) -> bool:
	# 接口桩，检查材料是否满足
	return false

# 计算炼制成功率
func calculate_success_rate(recipe_id: String, player_attrs: Dictionary) -> float:
	# 接口桩，根据配方和玩家属性计算
	return 0.5
