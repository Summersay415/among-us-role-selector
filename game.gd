extends Control

var time_left
var left

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

func _process(delta):
	if G.impostors.size() <= 0:
		get_tree().change_scene("res://crew_win.tscn")
	if G.players.size() <= G.impostors.size() * 2:
		get_tree().change_scene("res://impostors_win.tscn")

func meeting():
	if left <= 0:
		var sfx = AudioStreamPlayer.new()
		sfx.stream = load("res://sounds/emergency_meeting.ogg")
		sfx.autoplay = true
		sfx.connect("finished", sfx, "queue_free", [], CONNECT_DEFERRED)
		get_tree().root.add_child(sfx)
		get_tree().change_scene("res://vote.tscn")

func report():
	var sfx = AudioStreamPlayer.new()
	sfx.stream = load("res://sounds/report.ogg")
	sfx.autoplay = true
	sfx.connect("finished", sfx, "queue_free", [], CONNECT_DEFERRED)
	get_tree().root.add_child(sfx)
	get_tree().change_scene("res://vote.tscn")

func win_crew():
	get_tree().change_scene("res://crew_win.tscn")

func win_impasta():
	get_tree().change_scene("res://impostors_win.tscn")
