extends Button

export(String) var l = "ru"

func _ready():
	connect("pressed", self, "set_locale", [l])

func set_locale(l):
	TranslationServer.set_locale(l)
