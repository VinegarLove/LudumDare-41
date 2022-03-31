extends Node

export(NodePath) onready var novel_controller
export(NodePath) onready var towerdefence_controller
export(NodePath) onready var score_controller

func _ready():
	print("READY MAIN SCENE")

func __connect_to_winning_contition():
	pass

func __connect_to_losing_condition():
	pass

func _on_towerdefence_enemy_died():
	get_tree().change_scene("res://scenes/won.tscn")

func _on_towerdefence_player_died():
	get_tree().change_scene("res://scenes/lost.tscn")


func _on_towerdefence_player_score_changed(new_score):
	pass # replace with function body
