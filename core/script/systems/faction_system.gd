# 宗门系统接口桩
# 负责宗门信息获取、贡献、兑换和功法学习
extends RefCounted

# 获取宗门信息
func get_faction_info() -> Dictionary:
	# 接口桩，返回宗门基本信息
	return {
		"name": "青云宗",
		"rank": "玄级",
		"leader": "青云真人",
		"member_count": 120
	}

# 贡献资源给宗门
func contribute(amount: int) -> void:
	var player = GameState.player
	if player == null:
		return
	if player.spirit_stones >= amount:
		player.spirit_stones = player.spirit_stones - amount
		player.faction_contribution = player.faction_contribution + amount / 10
		GameState.state_changed.emit()

# 兑换宗门物品
func exchange_item(item_id: String) -> bool:
	# 接口桩，检查贡献度并兑换物品
	return false

# 学习宗门功法
func learn_technique(tech_id: String) -> bool:
	# 接口桩，检查条件并学习功法
	return false
