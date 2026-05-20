# 境界修炼数据模型
# 管理单个角色的境界、修为、灵力和突破条件
class_name Cultivation
extends RefCounted

# 境界枚举
enum Realm {
	REFINING_QI,      # 炼气期
	FOUNDATION,       # 筑基期
	GOLDEN_CORE,      # 金丹期
	NASCENT_SOUL,     # 元婴期
	SPIRIT_SEVERING   # 化神期
}

# 小境界枚举
enum Stage {
	EARLY,    # 初期
	MIDDLE,   # 中期
	LATE,     # 后期
	PEAK      # 圆满
}

# 当前境界
var realm: int = Realm.REFINING_QI
var stage: int = Stage.EARLY

# 修为
var cultivation_exp: float = 0.0
var exp_required: float = 100.0

# 灵力
var spirit_power: float = 50.0
var max_spirit_power: float = 50.0
var spirit_power_regen: float = 5.0

# 修炼速度
var base_cultivation_speed: float = 10.0

# 灵根
var spiritual_roots: Array = []

# 丹毒
var poison_accumulation: float = 0.0

# 获取境界名称
func get_realm_name() -> String:
	var names = {
		Realm.REFINING_QI: "炼气期",
		Realm.FOUNDATION: "筑基期",
		Realm.GOLDEN_CORE: "金丹期",
		Realm.NASCENT_SOUL: "元婴期",
		Realm.SPIRIT_SEVERING: "化神期"
	}
	return names.get(realm, "未知")

# 获取小境界名称
func get_stage_name() -> String:
	var names = {
		Stage.EARLY: "初期",
		Stage.MIDDLE: "中期",
		Stage.LATE: "后期",
		Stage.PEAK: "圆满"
	}
	return names.get(stage, "")

# 获取寿元上限
func get_lifespan_limit() -> int:
	var limits = {
		Realm.REFINING_QI: 150,
		Realm.FOUNDATION: 250,
		Realm.GOLDEN_CORE: 500,
		Realm.NASCENT_SOUL: 1000,
		Realm.SPIRIT_SEVERING: 2000
	}
	return limits.get(realm, 80)

# 获取灵根修炼系数
func get_root_multiplier() -> float:
	var count = spiritual_roots.size()
	var multipliers = [0.4, 0.7, 1.0, 1.3, 2.0]
	if count >= 1 and count <= 5:
		return multipliers[count - 1]
	return 0.4

# 计算最终修炼速度
func calculate_cultivation_speed(spiritual_density: float, technique_bonus: float, pill_bonus: float) -> float:
	var speed = base_cultivation_speed
	speed = speed * get_root_multiplier()
	speed = speed * spiritual_density
	speed = speed * (1.0 + technique_bonus)
	speed = speed * (1.0 + pill_bonus)
	return speed

# 增加修为
func gain_exp(amount: float) -> void:
	cultivation_exp = cultivation_exp + amount
	if cultivation_exp > exp_required:
		cultivation_exp = exp_required

# 能否突破小境界
func can_stage_breakthrough() -> bool:
	return cultivation_exp >= exp_required

# 突破到下一小境界
func stage_breakthrough() -> Dictionary:
	if cultivation_exp < exp_required:
		return {"success": false, "message": "修为不足"}
	var success_rate = 0.9 if stage < Stage.PEAK else 0.7
	var roll = randf()
	if roll < success_rate:
		if stage < Stage.PEAK:
			stage = stage + 1
		else:
			# 已到圆满，需要大境界突破
			return {"success": false, "message": "已达当前境界圆满，需要大境界突破"}
		cultivation_exp = 0.0
		exp_required = exp_required * 1.5
		max_spirit_power = max_spirit_power * 1.3
		spirit_power = max_spirit_power
		return {"success": true, "message": "突破成功！"}
	else:
		cultivation_exp = cultivation_exp * 0.7
		return {"success": false, "message": "突破失败，修为损耗"}

# 序列化
func to_dict() -> Dictionary:
	return {
		"realm": realm,
		"stage": stage,
		"cultivation_exp": cultivation_exp,
		"exp_required": exp_required,
		"spirit_power": spirit_power,
		"max_spirit_power": max_spirit_power,
		"spirit_power_regen": spirit_power_regen,
		"base_cultivation_speed": base_cultivation_speed,
		"spiritual_roots": spiritual_roots.duplicate(),
		"poison_accumulation": poison_accumulation
	}

# 反序列化
func from_dict(d: Dictionary) -> void:
	for key in d.keys():
		if key in self:
			self[key] = d[key]
