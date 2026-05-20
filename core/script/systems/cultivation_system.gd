# 修炼系统接口桩
# 负责修炼速度计算和突破判定
extends RefCounted

# 计算修炼速度
func calculate_cultivation_speed(player: Player, location_density: float) -> float:
	# 接口桩，调用 Player 模型的方法
	return player.get_spiritual_root_multiplier() * 10.0 * location_density

# 检查小境界突破条件
func can_stage_breakthrough(player: Player) -> bool:
	# 接口桩
	return player.cultivation_exp >= player.exp_to_next

# 尝试小境界突破
func attempt_stage_breakthrough(player: Player) -> Dictionary:
	# 接口桩，返回 {success: bool, message: String}
	if not can_stage_breakthrough(player):
		return {"success": false, "message": "修为不足"}
	var rate = 0.9
	if player.stage == "圆满":
		return {"success": false, "message": "已达当前境界圆满"}
	if randf() < rate:
		# 升阶
		var stages = ["初期", "中期", "后期", "圆满"]
		var idx = stages.find(player.stage)
		if idx >= 0 and idx < 3:
			player.stage = stages[idx + 1]
		player.cultivation_exp = 0.0
		player.exp_to_next = player.exp_to_next * 1.5
		return {"success": true, "message": "突破成功！"}
	else:
		player.cultivation_exp = player.cultivation_exp * 0.7
		return {"success": false, "message": "突破失败，修为损耗"}

# 检查大境界突破条件
func can_realm_breakthrough(player: Player) -> bool:
	# 接口桩
	return player.stage == "圆满" and player.cultivation_exp >= player.exp_to_next

# 获取突破成功率
func get_breakthrough_rate(player: Player) -> float:
	# 接口桩
	var base = 0.5
	var root_bonus = player.get_spiritual_root_breakthrough_bonus()
	return base + root_bonus

# 序列化
func to_dict() -> Dictionary:
	return {}

# 反序列化
func from_dict(d: Dictionary) -> void:
	pass
