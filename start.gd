extends Control

var cfg : ConfigFile

func see():
	OS.shell_open("http://diamondstudiogames.tilda.ws/privacy_policy")

func _ready():
	cfg = ConfigFile.new()
	cfg.load("user://ads.cfg")
	yield(get_tree(), "idle_frame")
	if not cfg.has_section_key("ads", "child"):
		$privacy.popup_centered()
	else:
		go_to_main()

func accept():
	$age.popup_centered()
	$privacy.hide()

func is_child_age():
	var is_child_age_set = $age/age.value < 13
	cfg.set_value("ads", "child", is_child_age_set)
	$age.hide()
	cfg.save("user://ads.cfg")
	go_to_main()


func go_to_main():
	var cfg = ConfigFile.new()
	cfg.load("user://ads.cfg")
	AdMob.initialize(true, cfg.get_value("ads", "child", false), "G" if cfg.get_value("ads", "child", false) else "MA", false)
	AdMob.request_user_consent()
	get_tree().change_scene("res://main.tscn")
