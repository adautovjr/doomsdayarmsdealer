extends CanvasLayer

@onready var matchResult = $MenuContainer/StartMenu/Panel/MarginContainer/Panel/VBoxContainer/MatchResultTitle
@onready var matchDesc = $MenuContainer/StartMenu/Panel/MarginContainer/Panel/VBoxContainer/MatchResultDescription
@onready var bestScore = $MenuContainer/StartMenu/Panel/MarginContainer/Panel/VBoxContainer/MatchResultBestScore

func _ready():
	Events.connect("handle_game_over", handle_game_over)
	matchResult.text = ""
	matchDesc.text = ""
	bestScore.text = ""

func handle_game_over(result):
	matchResult.text = str("The ", result.loser,"s have been obliterated!")
	if result.best_score >= result.earned:
		matchDesc.text = str("You got $", result.earned," this time.")
		bestScore.text = str("You had $", result.best_score," in your best match.")
	else:
		SaveManager.save_best_score(result.earned)
		matchDesc.text = str("Nice! You got your best result yet! $", result.earned)


func back_to_menu():
	Events.emit_signal("play_click_sound")
	get_tree().change_scene_to_packed(load("res://levels/start_screen.tscn"))


func quit():
	Events.emit_signal("play_click_sound")
	get_tree().quit()
