extends Control

var players = []
var impasta = []

func _ready():
	players = G.players.duplicate(true)
	impasta = G.impostors.duplicate(true)
	yield(select_dead(), "completed")

func end():
	get_tree().change_scene("res://game.tscn")

func remove_player(na, le, remove_le):
	players.erase(na)
	G.players = players.duplicate(true)
	if na in impasta:
		impasta.erase(na)
		G.impostors = impasta.duplicate(true)
	if G.impostors.size() <= 0:
		get_tree().change_scene("res://crew_win.tscn")
		return
	if players.size() <= G.impostors.size() * 2:
		get_tree().change_scene("res://impostors_win.tscn")
		return
	if remove_le:
		le.queue_free()

func select_dead():
	var butt = $select_dead/button
	var pl = $select_dead/players
	for i in range(0, players.size()):
		var le = Button.new()
		le.name = "pl" + str(i)
		le.size_flags_horizontal = SIZE_EXPAND_FILL
		le.text = players[i]
		le.toggle_mode = true
		le.connect("pressed", self, "remove_player", [players[i], le, true])
		pl.add_child(le)
	yield(butt, "pressed")
	$select_dead.hide()
	$voting.show()

func vote():
	pass
