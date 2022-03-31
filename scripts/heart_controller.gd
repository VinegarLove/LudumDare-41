extends Sprite

export(NodePath) var sound_to_play_path
export(int) var _max_health = 100
signal has_died
signal score_changed(new_score)

var health;
onready var sound_to_play = get_node(sound_to_play_path)

func _ready():
	health = _max_health

func get_current_health():
	return health

func set_current_health(health_new):
	health = health_new

func change_heart_for_death():
	pass

func _on_target_reached(damage):
	health -= damage
	emit_signal("score_changed", health)
	sound_to_play.play()
	if health < 1:
		change_heart_for_death()
		emit_signal("has_died")