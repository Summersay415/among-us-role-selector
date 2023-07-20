extends Control

enum State {
	SELECT,
	VIEW,
	VIEW_PAUSE,
	RESTART
}

var ad_loaded = false
var crewmates
var impostors
var players = [0]
var current = 0
var state = State.SELECT
var impostors_array = []

func save_popup():
	save_settings()

func load_popup():
	load_settings()

func save_settings():
	var path = "user://save.cfg"
	var cfg = ConfigFile.new()
	# Imps, crewms, metcd and confej
	cfg.set_value("base", "impostors", $setup/impostors_selector.value)
	cfg.set_value("base", "players", $setup/crewmates_selector.value)
	cfg.set_value("base", "cdmeeting", $setup/cd_selector.value)
	cfg.set_value("base", "ce", $setup/cnfrmjctsV.pressed)
	#player names
	for i in range(0, $setup/crewmates_selector.value):
		var name = $setup/players.get_child(i).text
		cfg.set_value("names", "player" + str(i), name)
	cfg.save(path)

func load_settings():
	var path = "user://save.cfg"
	var cfg = ConfigFile.new()
	var err = cfg.load(path)
	if err != OK:
		return
	$setup/impostors_selector.value = cfg.get_value("base", "impostors")
	$setup/crewmates_selector.value = cfg.get_value("base", "players")
	$setup/cd_selector.value = cfg.get_value("base", "cdmeeting")
	$setup/cnfrmjctsV.pressed = cfg.get_value("base", "ce")
	for i in $setup/players.get_children():
		i.queue_free()
	for i in range(0, $setup/crewmates_selector.value):
		var le = LineEdit.new()
		le.name = "pl" + str(i)
		le.text = cfg.get_value("names", "player" + str(i))
		le.size_flags_horizontal = SIZE_EXPAND_FILL
		le.rect_min_size = Vector2(0, 30)
		$setup/players.add_child(le)

func setup_players(val):
	for i in $setup/players.get_children():
		i.queue_free()
	for i in range(0, val):
		var le = LineEdit.new()
		le.name = "pl" + str(i)
		le.text = "player" + str(i + 1)
		le.size_flags_horizontal = SIZE_EXPAND_FILL
		le.rect_min_size = Vector2(0, 30)
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
		$role_reveal.stop()
	if state == State.RESTART:
		if ad_loaded:
			$AdMob.show_interstitial()
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
		var players_impostors = tr("menu.you")
		for i in range(0, players.size()):
			if players[i] == players[current]:
				continue
			if players[i] in impostors_array:
				players_impostors = players_impostors + ", " + players[i] 
		$impostor/mates.text = tr("menu.mates") + players_impostors
	else:
		$impostor.hide()
		$crewmate.show()
	$role_reveal.play(0)
	current += 1
	$shhhhhh/nextPlayer.text = tr("menu.select.next") + players[clamp(current, 0, players.size())]

func si():
	ad_loaded = true

func _ready():
	TranslationServer.set_locale("ru" if OS.get_locale_language() == "ru" else "en")
	var cfg = ConfigFile.new()
	cfg.load("user://ads.cfg")
	if cfg.get_value("ads", "child", false):
		$AdMob.child_directed = true
	if not cfg.get_value("ads", "per", false):
		$AdMob.is_personalized = false
	$AdMob.connect("interstitial_loaded", self, "si")
	$AdMob.load_interstitial()
	randomize()
	$impostor/next.connect("pressed", self, "process_next_button_callback")
	$crewmate/next.connect("pressed", self, "process_next_button_callback")
	$setup/next.connect("pressed", self, "process_next_button_callback")
	$shhhhhh/next.connect("pressed", self, "process_next_button_callback")
	$done/next.connect("pressed", self, "process_next_button_callback")
	setup_players(4)
	load_popup()

func start_view():
	save_popup()
	$setup.hide()
	$shhhhhh.show()
	crewmates = $setup/crewmates_selector.value - $setup/impostors_selector.value
	impostors = $setup/impostors_selector.value
	$crewmate/impostors.text = tr("menu.select.impostors1") + str(impostors) + tr("menu.select.impostors2")
	var plc = $setup/crewmates_selector.value
	players = []
	for i in range(0, $setup/players.get_child_count()):
		var nameObj = $setup/players.get_child(i)
		var name = nameObj.text
		if name.strip_edges().empty():
			name = "noName"
		while name in players:
			name = name + "|"
		players.append(name)
	randomize()
	players.shuffle()
	impostors_array = range(0, impostors)
	for i in range(0, impostors):
		impostors_array[i] = players[i]
	randomize()
	players.shuffle()
	var cachePlayers = players.duplicate(true)
	G.players = cachePlayers
	var cacheImp = impostors_array.duplicate(true)
	G.impostors = cacheImp
	G.confrmejects = $setup/cnfrmjctsV.pressed
	G.meetingcd = $setup/cd_selector.value
	players.append(tr("menu.all"))
	current = 0
	$shhhhhh/nextPlayer.text = tr("menu.select.next") + players[current]
