extends RefCounted

var damage_accumulator := 0
var round_multiplier := 1.0
var highest_single_hit := 0
var incoming_damage_reduction := 0.0
var balls_remaining := 0
var balls_in_play := 0
var last_settled_damage := 0
var enemy_acted_this_settlement := false
var pending_heal := 0
var multiplier_triggers := 0
var pending_drop_bonus_multiplier := 0.0


func start_round(ball_count: int) -> void:
	damage_accumulator = 0
	round_multiplier = 1.0
	highest_single_hit = 0
	incoming_damage_reduction = 0.0
	balls_remaining = ball_count
	balls_in_play = 0
	last_settled_damage = 0
	enemy_acted_this_settlement = false
	pending_heal = 0
	multiplier_triggers = 0
	pending_drop_bonus_multiplier = 0.0


func add_damage(amount: int) -> void:
	damage_accumulator += amount
	highest_single_hit = max(highest_single_hit, amount)


func add_settlement_bonus(amount: int) -> void:
	damage_accumulator += amount


func add_heal(amount: int) -> void:
	pending_heal += amount


func try_apply_multiplier(multiplier: float, max_triggers: int) -> bool:
	if multiplier_triggers >= max_triggers:
		return false
	multiplier_triggers += 1
	round_multiplier *= multiplier
	return true


func add_drop_bonus_multiplier(multiplier: float) -> void:
	pending_drop_bonus_multiplier += multiplier


func apply_damage_reduction(reduction: float) -> void:
	incoming_damage_reduction = max(incoming_damage_reduction, reduction)


func mark_settled() -> void:
	last_settled_damage = damage_accumulator
	enemy_acted_this_settlement = false
