extends Control

var cfg : ConfigFile

func see():
	OS.shell_open("http://diamondstudiogames.tilda.ws/privacy_policy")

func _ready():
	cfg = ConfigFile.new()
	cfg.load("user://ads.cfg")
	yield(get_tree(), "idle_frame")
	if not cfg.has_section_key("ads", "per"):
		$privacy.popup_centered()
	else:
		get_tree().change_scene("res://main.tscn")

func accept():
	$age.popup_centered()
	$privacy.hide()

func is_child_age():
	var is_child_age_set = false
	var yes_no = true
	if $age/age.value < 13:
		is_child_age_set = true
		yes_no = false
	cfg.set_value("ads", "per", yes_no)
	cfg.set_value("ads", "child", is_child_age_set)
	$age.hide()
	cfg.save("user://ads.cfg")
	get_tree().change_scene("res://main.tscn")
