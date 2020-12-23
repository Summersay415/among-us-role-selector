extends Control

var time_left
var left

func end_game():
	get_tree().change_scene("res://main.tscn")

func decrement():
	left -= 1
	time_left.text = str(left)
	if left <= 0:
		time_left.hide()

func _ready():
	left = G.meetingcd
	time_left = $selectAct/emerg/time
	time_left.text = str(left)
	$timer.connect("timeout", self, "decrement")

func meeting():
	if left <= 0:
		get_tree().change_scene("res://vote.tscn")

func report():
	get_tree().change_scene("res://vote.tscn")
