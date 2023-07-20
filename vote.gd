extends Control

var players = []
var impasta = []
var votes = []
var isTie = false
var isSkip = false
var voted_out = 0
signal vote_next

func vote(i):
	votes[i] += 1
	$voted.play(0)
	emit_signal("vote_next")

func _ready():
	players = G.players.duplicate(true)
	impasta = G.impostors.duplicate(true)
	yield(select_dead(), "completed")
	yield(voting(), "completed")
	result()

func end():
	if not isSkip and not isTie:
		remove_player(players[voted_out])
	get_tree().change_scene("res://game.tscn")

func remove_player(na, le = null, remove_le = false):
	players.erase(na)
	G.players = players.duplicate(true)
	if na in impasta:
		impasta.erase(na)
		G.impostors = impasta.duplicate(true)
	if G.impostors.size() <= 0:
		get_tree().change_scene("res://crew_win.tscn")
	if players.size() <= G.impostors.size() * 2:
		get_tree().change_scene("res://impostors_win.tscn")
	if remove_le:
		le.queue_free()

func kill_player(na, le, remove_le):
	remove_player(na, le, remove_le)
	$kill.play(0)

func select_dead():
	var butt = $select_dead/button
	var pl = $select_dead/players
	for i in range(0, players.size()):
		var le = Button.new()
		le.name = "pl" + str(i)
		le.size_flags_horizontal = SIZE_EXPAND_FILL
		le.text = players[i]
		le.rect_min_size = Vector2(0, 30)
		le.toggle_mode = true
		le.connect("pressed", self, "kill_player", [players[i], le, true])
		pl.add_child(le)
	yield(butt, "pressed")
	$select_dead.hide()
	$voting.show()

func voting():
	var pl = $voting/players
	var wiv : Label = $voting/votes
	votes.resize(players.size() + 1)
	for t in range(0, votes.size()):
		votes[t] = 0
	for i in range(0, players.size()):
		var le = Button.new()
		le.name = "pl" + str(i)
		le.text = players[i]
		le.connect("pressed", self, "vote", [i])
		le.rect_min_size = Vector2(0, 30)
		le.size_flags_horizontal = SIZE_EXPAND_FILL
		pl.add_child(le)
	var le = Button.new()
	le.name = "skip"
	le.text = tr("voting.skip_vote")
	le.connect("pressed", self, "vote", [votes.size() - 1])
	le.size_flags_horizontal = SIZE_EXPAND_FILL
	le.rect_min_size = Vector2(0, 30)
	pl.add_child(le)
	for i in range(0, players.size()):
		wiv.text = tr("voting.votes") + players[i]
		yield(self, "vote_next")
	var cv = votes.duplicate(true)
	cv.sort()
	var s = cv.size()
	if cv[s - 1] == cv[s - 2]:
		isTie = true
		return
	var itd = votes.find(cv[s - 1])
	if itd == -1:
		printerr("WTF")
		return
	if int(itd) == int(votes.size() - 1):
		isSkip = true
		return
	voted_out = itd

func result():
	$voting.hide()
	$result.show()
	$vote_end.play(0)
	var text = $result/result
	var an = $result/anim
	if isTie:
		if G.confrmejects:
			text.text = tr("voting.result.tie") + " \n" + str(impasta.size()) + tr("voting.result.remains")
		else:
			text.text = tr("voting.result.tie")
		return
	if isSkip:
		if G.confrmejects:
			text.text = tr("voting.result.skip") + " \n" + str(impasta.size()) + tr("voting.result.remains")
		else:
			text.text = tr("voting.result.skip")
		return
	var nameOfEjected = players[voted_out]
	var isImp = false
	if nameOfEjected in impasta:
		isImp = true
	if not G.confrmejects:
		text.text = nameOfEjected + tr("voting.result.we")
	else:
		if isImp:
			text.text = nameOfEjected + tr("voting.result.wai") + " \n" + str(impasta.size() - 1) + tr("voting.result.remains")
			an.play("impostor_eject")
		else:
			text.text = nameOfEjected + tr("voting.result.wnai") + " \n" + str(impasta.size()) + tr("voting.result.remains")
			an.play("crewmate_eject")
