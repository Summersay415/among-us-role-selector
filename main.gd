extends Control

enum State {
	SELECT,
	VIEW,
	VIEW_PAUSE,
	RESTART
}

var crewmates
var impostors
var players = [0]
var current = 0
var state = State.SELECT
var impostors_array = []

func setup_players(val):
	for i in $setup/players.get_children():
		i.queue_free()
	for i in range(0, val):
		var le = LineEdit.new()
		le.name = "pl" + str(i)
		le.size_flags_horizontal = SIZE_EXPAND_FILL
		$setup/players.add_child(le)

func process_next_button_callback():
	if state == State.SELECT:
		state = State.VIEW_PAUSE
		start_view()
		return
	if state == State.VIEW_PAUSE:
		state = State.VIEW
		show_role()
		return
	if state == State.VIEW:
		$crewmate.hide()
		$impostor.hide()
		$shhhhhh.show()
		state = State.VIEW_PAUSE
	if state == State.RESTART:
		get_tree().change_scene("res://game.tscn")

func show_role():
	$shhhhhh.hide()
	if current >= players.size() - 1:
		state = State.RESTART
		$done.show()
		return
	if players[current] in impostors_array:
		$impostor.show()
		$crewmate.hide()
		var players_impostors = "ты"
		for i in range(0, players.size()):
			if players[i] == players[current]:
				continue
			if players[i] in impostors_array:
				var cacheStr = str(players[i])
				cacheStr.erase(cacheStr.length() - 1, 1)
				players_impostors = players_impostors + ", " + cacheStr 
		$impostor/mates.text = "Предатели: " + players_impostors
	else:
		$impostor.hide()
		$crewmate.show()
	current += 1
	var cacheStr = str(players[clamp(current, 0, players.size())])
	cacheStr.erase(cacheStr.length() - 1, 1)
	$shhhhhh/nextPlayer.text = "Следующий:" + cacheStr

func _ready():
	randomize()
	$impostor/next.connect("pressed", self, "process_next_button_callback")
	$crewmate/next.connect("pressed", self, "process_next_button_callback")
	$setup/next.connect("pressed", self, "process_next_button_callback")
	$shhhhhh/next.connect("pressed", self, "process_next_button_callback")
	$done/next.connect("pressed", self, "process_next_button_callback")
	setup_players(4)

func start_view():
	$setup.hide()
	$shhhhhh.show()
	crewmates = $setup/crewmates_selector.value - $setup/impostors_selector.value
	impostors = $setup/impostors_selector.value
	$crewmate/impostors.text = "Обнаружено " + str(impostors) + " предателей среди нас"
	var plc = $setup/crewmates_selector.value
	players = []
	for i in range(0, $setup/players.get_child_count()):
		var nameObj = $setup/players.get_child(i)
		var name = nameObj.text
		players.append(name + str(i))
	players.shuffle()
	impostors_array = range(0, impostors)
	for i in range(0, impostors):
		impostors_array[i] = players[i]
	players.shuffle()
	players.shuffle()
	players.shuffle()
	randomize()
	players.shuffle()
	var cachePlayers = players.duplicate(true)
	for l in range(0, cachePlayers.size()):
		var cacheStr = cachePlayers[l]
		cacheStr.erase(cacheStr.length() - 1, 1)
		cachePlayers[l] = cacheStr
	print(cachePlayers)
	G.players = cachePlayers
	var cacheImp = impostors_array.duplicate(true)
	for d in range(0, cacheImp.size()):
		var cacheStr = cacheImp[d]
		cacheStr.erase(cacheStr.length() - 1, 1)
		cacheImp[d] = cacheStr
	print(cacheImp)
	G.impostors = cacheImp
	G.confrmejects = $setup/cnfrmjctsV.pressed
	G.meetingcd = $setup/cd_selector.value
	players.append("всё1")
	current = 0
	var cacheStr = str(players[current])
	cacheStr.erase(cacheStr.length() - 1, 1)
	$shhhhhh/nextPlayer.text = "Следующий:" + cacheStr
