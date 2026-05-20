# 功法数据模型
class_name Technique
extends RefCounted

# 功法类型
enum TechType {
	MAIN,          # 主修功法
	COMBAT_ART,    # 战斗神通
	PASSIVE_ART    # 被动心法
}

# 品质
enum Grade {
	COMMON,        # 凡品
	SPIRITUAL,     # 灵品
	MYSTIC,        # 玄品
	EARTH,         # 地品
	HEAVEN,        # 天品
	IMMORTAL       # 仙品
}

# 五行
enum Element {
	METAL,         # 金
	WOOD,          # 木
	WATER,         # 水
	FIRE,          # 火
	EARTH          # 土
}

var tech_id: String = ""
var tech_name: String = ""
var tech_type: int = TechType.COMBAT_ART
var grade: int = Grade.SPIRITUAL
var element: int = Element.METAL
var required_realm: String = "炼气期"
var level: int = 1
var max_level: int = 5
var proficiency: float = 0.0
var description: String = ""
var effects: Array = []
var spirit_power_cost: int = 0
var cooldown: int = 0
var power: float = 10.0

# 获取品质层数上限
func get_max_level_by_grade() -> int:
	var limits = {
		Grade.COMMON: 3,
		Grade.SPIRITUAL: 5,
		Grade.MYSTIC: 7,
		Grade.EARTH: 9,
		Grade.HEAVEN: 11,
		Grade.IMMORTAL: 12
	}
	return limits.get(grade, 3)

# 获取品质名称
func get_grade_name() -> String:
	var names = {
		Grade.COMMON: "凡品",
		Grade.SPIRITUAL: "灵品",
		Grade.MYSTIC: "玄品",
		Grade.EARTH: "地品",
		Grade.HEAVEN: "天品",
		Grade.IMMORTAL: "仙品"
	}
	return names.get(grade, "")

# 能否升级
func can_upgrade() -> bool:
	return level < max_level and proficiency >= 100.0

# 升级功法
func upgrade() -> Dictionary:
	if not can_upgrade():
		return {"success": false, "message": "无法升级"}
	level = level + 1
	proficiency = 0.0
	power = power * 1.2
	return {"success": true, "message": "升级成功！"}

# 增加熟练度
func add_proficiency(amount: float) -> void:
	if level < max_level:
		proficiency = proficiency + amount
		if proficiency > 100.0:
			proficiency = 100.0

# 序列化
func to_dict() -> Dictionary:
	return {
		"tech_id": tech_id,
		"tech_name": tech_name,
		"tech_type": tech_type,
		"grade": grade,
		"element": element,
		"required_realm": required_realm,
		"level": level,
		"max_level": max_level,
		"proficiency": proficiency,
		"power": power
	}

# 反序列化
func from_dict(d: Dictionary) -> void:
	for key in d.keys():
		if key in self:
			self[key] = d[key]
