extends Control

func restart():
	get_tree().change_scene("res://main.tscn")

func _ready():
	$anim.play("vict")
