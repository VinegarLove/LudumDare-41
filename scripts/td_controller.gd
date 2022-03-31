extends Node2D
export(NodePath) var player_unit_spawn
export(NodePath) var player_unit_target
export(NodePath) var enemy_unit_spawn
export(NodePath) var enemy_unit_target
export(NodePath) var path_unit_player
export(NodePath) var path_unit_target_1
export(NodePath) var path_unit_target_2
signal player_died
signal enemy_died
signal player_score_changed(new_score)
signal enemy_score_changed(new_score)

const template_perpetual_unit = preload("res://scenes/_unit_feeling1.tscn")
const template_bad_choice_unit = preload("res://scenes/_unit_feeling2.tscn")
const template_bad_good_unit = preload("res://scenes/_unit_feeling3.tscn")

var queue = []

func _ready():
	randomize()

func _get_random_enemy_path():
	if randi() % 2:
		return get_node(path_unit_target_1)
	else:
		return get_node(path_unit_target_2)

func _spwan_unit_now(template, path, target):
	var unit = template.instance()
	unit.set_target_path(path)
	unit.connect("target_reached", target, "_on_target_reached")
	path.add_child(unit)

func spawn_towards_player(template, number):
	for i in range(number):
		queue.append([template, _get_random_enemy_path(), get_node(enemy_unit_target)])

func spawn_towards_enemy(template, number):
	for i in range(number):
		queue.append([template, get_node(path_unit_player), get_node(player_unit_target)])

func _on_queue_process_timer_timeout():
	if queue:
		var x = queue.pop_front()
		_spwan_unit_now(x[0], x[1], x[2])

func _on_perpetual_enemy_timer_timeout():
	spawn_towards_player(template_perpetual_unit, 1)

func _on_opponentsheart_has_died():
	emit_signal("player_died")

func _on_playerheart_score_changed(new_score):
	emit_signal("player_score_changed", new_score)

func _on_opponentsheart_score_changed(new_score):
	emit_signal("enemy_score_changed", new_score)

func _on_playerheart_has_died():
	emit_signal("enemy_died")

func _on_dialogue_player_choice_executed(rate):
	if rate == "good":
		spawn_towards_enemy(template_bad_good_unit, '5')
	elif rate == "bad":
		spawn_towards_player(template_bad_choice_unit, '5')