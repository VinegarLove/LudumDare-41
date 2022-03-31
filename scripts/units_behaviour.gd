extends PathFollow2D

export(float) var _max_speed = 0.5
export(int) var _max_damage = 1
export(int) var _max_health = 1
export(float) var threshold = 2.0

onready var health = _max_health
onready var damage = _max_damage
onready var speed = _max_speed
onready var target_path = null

signal target_reached(damage)

func _ready():
	set_process(true)

func set_target_path(path):
	target_path = path

func _process(delta):
	var next = get_unit_offset() + speed * delta
	self.set_unit_offset(get_unit_offset() + speed * delta)
	if next >= 1.0:
		signal_impact_to_target()
		set_process(false)

func signal_impact_to_target():
	emit_signal("target_reached", damage)
	queue_free()