extends Node2D

export(NodePath) onready var player_score
export(NodePath) onready var opponents_score

func _ready():
	pass


# callbacks
func _on_towerdefence_enemy_score_changed(new_score):
	var a = get_node(opponents_score)
	a.text = str(new_score)


func _on_towerdefence_player_score_changed(new_score):
	var a = get_node(player_score)
	a.text = str(new_score)