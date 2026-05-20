# 战斗系统接口桩
# 提供战斗相关的计算公式和工具方法
extends RefCounted

# 五行相克矩阵
const ELEMENT_MATRIX = {
	"金": {"克": "木", "被克": "火"},
	"木": {"克": "土", "被克": "金"},
	"水": {"克": "火", "被克": "土"},
	"火": {"克": "金", "被克": "水"},
	"土": {"克": "水", "被克": "木"}
}

# 计算五行相克系数
func get_element_multiplier(attacker_element: String, defender_element: String) -> float:
	# 接口桩
	if attacker_element == defender_element:
		return 1.0
	var info = ELEMENT_MATRIX.get(attacker_element, {})
	if info.get("克", "") == defender_element:
		return 1.3
	if info.get("被克", "") == defender_element:
		return 0.7
	return 1.0

# 计算伤害
func calculate_damage(attack: float, defense: float, element_mult: float, art_power: float, crit: bool) -> float:
	# 接口桩
	var base = art_power if art_power > 0 else attack * 10.0
	var defense_reduction = defense / (defense + 50.0)
	var damage = base * element_mult * (1.0 - defense_reduction)
	damage = damage * randf_range(0.9, 1.1)
	if crit:
		damage = damage * 1.5
	return max(1.0, damage)

# 获取战斗状态效果描述
func get_status_effect_description(effect_name: String) -> String:
	# 接口桩
	var descriptions = {
		"poison": "中毒：每回合损失 5% 最大生命值",
		"burn": "灼烧：每回合损失灵力，受到伤害+10%",
		"freeze": "冰冻：速度 -50%，有概率跳过回合",
		"paralysis": "麻痹：有20%概率无法行动",
		"shield": "护盾：吸收伤害",
		"strengthen": "强化：攻击力 +30%"
	}
	return descriptions.get(effect_name, "")
