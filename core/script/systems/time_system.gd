# 时间系统接口桩
# 负责日历计算、时辰名称、特殊日期判定
extends RefCounted

# 时辰名称数组
const HOUR_NAMES = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]

# 每个月天数
const DAYS_PER_MONTH = 30
const MONTHS_PER_YEAR = 12
const HOURS_PER_DAY = 12

# 获取时辰名称
func get_hour_name(hour: int) -> String:
	return HOUR_NAMES[hour % 12]

# 推进时间
func advance_time(calendar: Dictionary, hours: int) -> Array:
	# 接口桩，返回触发的事件列表
	var events = []
	calendar["hour"] = calendar["hour"] + hours
	while calendar["hour"] >= HOURS_PER_DAY:
		calendar["hour"] = calendar["hour"] - HOURS_PER_DAY
		calendar["day"] = calendar["day"] + 1
	while calendar["day"] > DAYS_PER_MONTH:
		calendar["day"] = calendar["day"] - DAYS_PER_MONTH
		calendar["month"] = calendar["month"] + 1
	while calendar["month"] > MONTHS_PER_YEAR:
		calendar["month"] = calendar["month"] - MONTHS_PER_YEAR
		calendar["year"] = calendar["year"] + 1
	return events

# 格式化日期时间
func format_datetime(calendar: Dictionary) -> String:
	var hour_name = get_hour_name(calendar.get("hour", 0))
	return "玄黄历 %d年%d月%d日 %s时" % [calendar["year"], calendar["month"], calendar["day"], hour_name]

# 计算剩余天数
func get_days_until(calendar: Dictionary, target_year: int, target_month: int, target_day: int) -> int:
	var current_total = calendar["year"] * 360 + calendar["month"] * 30 + calendar["day"]
	var target_total = target_year * 360 + target_month * 30 + target_day
	return target_total - current_total

# 检查是否为特殊日期
func is_special_date(calendar: Dictionary) -> bool:
	# 接口桩：每10年宗门大比，每30年秘境开启
	var total_months = calendar["year"] * 12 + calendar["month"]
	if total_months % 120 == 0:
		return true  # 宗门大比
	if total_months % 360 == 0:
		return true  # 秘境开启
	return false
