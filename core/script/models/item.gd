# 物品数据模型
class_name GameItem
extends RefCounted

# 物品类型
enum ItemType {
	PILL,         # 丹药
	MATERIAL,     # 材料
	EQUIPMENT,    # 装备
	SKILL_BOOK,   # 功法书
	QUEST,        # 任务品
	OTHER         # 其他
}

# 品质枚举
enum Grade {
	INFERIOR,     # 劣
	COMMON,       # 凡
	FINE,         # 良
	SUPERIOR,     # 优
	PERFECT,      # 极
	IMMORTAL      # 仙
}

var item_id: String = ""
var item_name: String = ""
var item_type: int = ItemType.OTHER
var grade: int = Grade.COMMON
var description: String = ""
var value: int = 0
var quantity: int = 1
var is_tradable: bool = true
var effects: Array = []

# 获取品质名称
func get_grade_name() -> String:
	var names = {
		Grade.INFERIOR: "劣",
		Grade.COMMON: "凡",
		Grade.FINE: "良",
		Grade.SUPERIOR: "优",
		Grade.PERFECT: "极",
		Grade.IMMORTAL: "仙"
	}
	return names.get(grade, "")

# 获取品质颜色
func get_grade_color() -> String:
	var colors = {
		Grade.INFERIOR: "gray",
		Grade.COMMON: "white",
		Grade.FINE: "green",
		Grade.SUPERIOR: "blue",
		Grade.PERFECT: "purple",
		Grade.IMMORTAL: "gold"
	}
	return colors.get(grade, "white")

# 序列化
func to_dict() -> Dictionary:
	return {
		"item_id": item_id,
		"item_name": item_name,
		"item_type": item_type,
		"grade": grade,
		"description": description,
		"value": value,
		"quantity": quantity,
		"is_tradable": is_tradable
	}

# 反序列化
func from_dict(d: Dictionary) -> void:
	for key in d.keys():
		if key in self:
			self[key] = d[key]
