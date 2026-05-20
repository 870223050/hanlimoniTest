# 先天属性数据模型
# 根骨、悟性、神识、机缘、魅力
class_name Attributes
extends RefCounted

# 五大先天属性
var bone_structure: int = 10
var comprehension: int = 10
var divine_sense: int = 10
var fortune: int = 10
var charisma: int = 10

# 随机生成属性值
func randomize_attributes() -> void:
	bone_structure = randi_range(1, 20)
	comprehension = randi_range(1, 20)
	divine_sense = randi_range(1, 20)
	fortune = randi_range(1, 20)
	charisma = randi_range(1, 20)

# 获取属性颜色标识
func get_color_for_value(value: int) -> String:
	if value >= 16:
		return "gold"
	elif value >= 12:
		return "green"
	elif value >= 8:
		return "white"
	else:
		return "gray"

# 获取根骨影响的属性
func get_bone_structure_hp_bonus() -> float:
	return bone_structure * 5.0

func get_bone_structure_defense_bonus() -> float:
	return bone_structure * 0.5

# 获取悟性影响的属性
func get_comprehension_learn_bonus() -> float:
	return comprehension * 0.05

# 获取神识影响的属性
func get_divine_sense_crit_bonus() -> float:
	return divine_sense * 0.01

# 获取机缘影响的属性
func get_fortune_luck_bonus() -> float:
	return fortune * 0.02

# 获取魅力影响的属性
func get_charisma_discount() -> float:
	return charisma * 0.015

# 序列化
func to_dict() -> Dictionary:
	return {
		"bone_structure": bone_structure,
		"comprehension": comprehension,
		"divine_sense": divine_sense,
		"fortune": fortune,
		"charisma": charisma
	}

# 反序列化
func from_dict(d: Dictionary) -> void:
	for key in d.keys():
		if key in self:
			self[key] = d[key]
