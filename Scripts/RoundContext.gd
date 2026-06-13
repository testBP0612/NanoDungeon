extends RefCounted

var damage_accumulator := 0
var round_multiplier := 1.0
var highest_single_hit := 0
var incoming_damage_reduction := 0.0
var balls_remaining := 0
var balls_in_play := 0
var last_settled_damage := 0
var enemy_acted_this_settlement := false


func start_round(ball_count: int) -> void:
	damage_accumulator = 0
	round_multiplier = 1.0
	highest_single_hit = 0
	incoming_damage_reduction = 0.0
	balls_remaining = ball_count
	balls_in_play = 0
	last_settled_damage = 0
	enemy_acted_this_settlement = false


func add_damage(amount: int) -> void:
	damage_accumulator += amount


func mark_settled() -> void:
	last_settled_damage = damage_accumulator
	enemy_acted_this_settlement = false
