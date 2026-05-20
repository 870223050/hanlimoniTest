# 战斗单元数据模型
# 封装一个战斗参与者的属性和状态
class_name CombatUnit
extends RefCounted

# 基本信息
var unit_name: String = ""
var realm: String = ""
var element: String = "金"

# 战斗属性
var max_hp: float = 100.0
var current_hp: float = 100.0
var max_sp: float = 50.0
var current_sp: float = 50.0
var attack: float = 10.0
var defense: float = 5.0
var speed: float = 10.0
var crit_chance: float = 0.05

# 状态效果
var buffs: Array = []
var debuffs: Array = []

# 可用神通
var combat_arts: Array = []

# 冷却追踪
var cooldowns: Dictionary = {}

# 从 Player 创建战斗单元
static func from_player(player: Player) -> CombatUnit:
	var unit = CombatUnit.new()
	unit.unit_name = player.player_name
	unit.realm = player.realm
	unit.max_hp = player.max_hp
	unit.current_hp = player.current_hp
	unit.max_sp = player.max_sp
	unit.current_sp = player.current_sp
	unit.attack = player.attack
	unit.defense = player.defense
	unit.speed = player.speed
	unit.crit_chance = player.crit_chance
	if player.spiritual_roots.size() > 0:
		unit.element = player.spiritual_roots[0]
	unit.combat_arts = player.equipped_combat_arts.duplicate()
	return unit

# 是否存活
func is_alive() -> bool:
	return current_hp > 0

# 受到伤害
func take_damage(amount: float) -> float:
	var actual = max(0, amount)
	current_hp = current_hp - actual
	if current_hp < 0:
		current_hp = 0
	return actual

# 消耗灵力
func consume_sp(amount: float) -> bool:
	if current_sp >= amount:
		current_sp = current_sp - amount
		return true
	return false

# 添加 Buff
func add_buff(buff_name: String, duration: int) -> void:
	buffs.append({"name": buff_name, "duration": duration, "remaining": duration})

# 添加 Debuff
func add_debuff(debuff_name: String, duration: int) -> void:
	debuffs.append({"name": debuff_name, "duration": duration, "remaining": duration})

# 回合开始处理
func on_turn_start() -> void:
	current_sp = min(current_sp + 10, max_sp)
	# 处理 buff 计时
	for buff in buffs:
		buff["remaining"] = buff["remaining"] - 1
	buffs = buffs.filter(func(b): return b["remaining"] > 0)
	# 处理 debuff 计时
	for debuff in debuffs:
		debuff["remaining"] = debuff["remaining"] - 1
	debuffs = debuffs.filter(func(d): return d["remaining"] > 0)

# 回合结束处理
func on_turn_end() -> void:
	# 减少冷却
	for key in cooldowns.keys():
		if cooldowns[key] > 0:
			cooldowns[key] = cooldowns[key] - 1
