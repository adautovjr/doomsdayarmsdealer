extends Node

const SAVE_FILE_PATH = "user://hail2theking.save"

var game_options = {}

func _ready():
	load_data()


func load_data():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		game_options = {
			"window_mode": DisplayServer.WINDOW_MODE_WINDOWED,
			"vsync": DisplayServer.VSYNC_DISABLED,
			"max_fps": 120,
			"master_volume": 0.3,
			"sound_volume": 0.5,
			"music_volume": 0.5
		}
		save_data()
		return
	game_options = file.get_var()
	reset_game_options()
	file.close()


func save_option(optionName: String, value):
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	game_options.merge({
		optionName: value
	}, true)
	file.store_var(game_options)
	file.close()


func save_data():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(game_options)
	file.close()


func reset_game_options():
	set_window_mode(game_options.window_mode)
	set_vsync_mode(game_options.vsync)
	set_master_volume(game_options.master_volume)
	set_sound_volume(game_options.sound_volume)
	set_music_volume(game_options.music_volume)


func set_window_mode(value: DisplayServer.WindowMode):
	DisplayServer.window_set_mode(value)
	save_option("window_mode", value)


func set_vsync_mode(value: DisplayServer.VSyncMode):
	DisplayServer.window_set_vsync_mode(value)
	save_option("vsync", value)


func set_master_volume(value: float):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	save_option("master_volume", value)


func set_sound_volume(value: float):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	save_option("sound_volume", value)


func set_music_volume(value: float):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
	save_option("music_volume", value)
