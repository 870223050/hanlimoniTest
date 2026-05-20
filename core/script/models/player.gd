# 玩家数据模型
# 继承 RefCounted，可序列化为 Dictionary 用于存档
class_name Player
extends RefCounted

# 基本信息
var player_name: String = ""
var gender: String = "男"
var age: int = 16

# 境界与修为
var realm: String = "炼气期"
var stage: String = "初期"
var cultivation_exp: float = 0.0
var exp_to_next: float = 100.0
var lifespan: int = 100
var remaining_lifespan: int = 100

# 先天属性
var bone_structure: int = 10
var comprehension: int = 10
var divine_sense: int = 10
var fortune: int = 10
var charisma: int = 10

# 灵根
var spiritual_roots: Array = []

# 资源
var spirit_stones: int = 1000
var faction_contribution: int = 0
var faction_reputation: int = 0

# 战斗属性
var max_hp: float = 100.0
var current_hp: float = 100.0
var max_sp: float = 50.0
var current_sp: float = 50.0
var attack: float = 10.0
var defense: float = 5.0
var speed: float = 10.0
var crit_chance: float = 0.05
var poison_accumulation: float = 0.0
var cultivation_bonus: float = 0.0

# 背包
var inventory: Array = []
var inventory_capacity: int = 50

# 功法
var techniques: Array = []
var equipped_combat_arts: Array = []
var equipped_passive_arts: Array = []

# 已知配方
var known_recipes: Array = []

# 任务
var quest_log: Array = []
var completed_quests: Array = []

# 获取灵根类型名称
func get_spiritual_root_name() -> String:
	var count = spiritual_roots.size()
	var names = ["杂灵根", "四灵根", "三灵根", "双灵根", "单灵根"]
	if count >= 1 and count <= 5:
		return names[count - 1]
	return "无灵根"

# 获取灵根修炼系数
func get_spiritual_root_multiplier() -> float:
	var count = spiritual_roots.size()
	var multipliers = [0.4, 0.7, 1.0, 1.3, 2.0]
	if count >= 1 and count <= 5:
		return multipliers[count - 1]
	return 0.4

# 获取灵根突破加成
func get_spiritual_root_breakthrough_bonus() -> float:
	var count = spiritual_roots.size()
	var bonuses = [-0.10, -0.05, 0.0, 0.05, 0.20]
	if count >= 1 and count <= 5:
		return bonuses[count - 1]
	return -0.10

# 获取称号
func get_title() -> String:
	var titles = {
		"炼气期": "初入仙途",
		"筑基期": "筑基真人",
		"金丹期": "金丹上仙",
		"元婴期": "元婴老祖",
		"化神期": "化神天尊"
	}
	return titles.get(realm, "修士")

# 序列化为字典
func to_dict() -> Dictionary:
	var d = {}
	d["player_name"] = player_name
	d["gender"] = gender
	d["age"] = age
	d["realm"] = realm
	d["stage"] = stage
	d["cultivation_exp"] = cultivation_exp
	d["exp_to_next"] = exp_to_next
	d["lifespan"] = lifespan
	d["remaining_lifespan"] = remaining_lifespan
	d["bone_structure"] = bone_structure
	d["comprehension"] = comprehension
	d["divine_sense"] = divine_sense
	d["fortune"] = fortune
	d["charisma"] = charisma
	d["spiritual_roots"] = spiritual_roots.duplicate()
	d["spirit_stones"] = spirit_stones
	d["faction_contribution"] = faction_contribution
	d["faction_reputation"] = faction_reputation
	d["max_hp"] = max_hp
	d["current_hp"] = current_hp
	d["max_sp"] = max_sp
	d["current_sp"] = current_sp
	d["attack"] = attack
	d["defense"] = defense
	d["speed"] = speed
	d["crit_chance"] = crit_chance
	d["poison_accumulation"] = poison_accumulation
	d["cultivation_bonus"] = cultivation_bonus
	d["inventory"] = inventory.duplicate()
	d["inventory_capacity"] = inventory_capacity
	d["techniques"] = techniques.duplicate()
	d["equipped_combat_arts"] = equipped_combat_arts.duplicate()
	d["equipped_passive_arts"] = equipped_passive_arts.duplicate()
	d["known_recipes"] = known_recipes.duplicate()
	d["quest_log"] = quest_log.duplicate()
	d["completed_quests"] = completed_quests.duplicate()
	return d

# 从字典反序列化
func from_dict(d: Dictionary) -> void:
	for key in d.keys():
		if key in self:
			self[key] = d[key]
