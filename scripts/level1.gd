extends Node2D

@onready var DB = preload("res://resources/cards/CardsDatabase.gd")
@onready var ability = preload("res://scenes/ability.tscn")

@onready var units = {
	"demon": preload("res://scenes/demon.tscn"),
	"human": preload("res://scenes/human.tscn")
}
@onready var spawn_points = {
	"demon": $DemonSpawn,
	"human": $HumanSpawn,
}

const Cooldown = preload("res://scripts/cooldown.gd")
var time = 0
var time_begin
var time_delay


@onready var demon_spawn_cooldown = Cooldown.new(10)
@onready var human_spawn_cooldown = Cooldown.new(10)

var spawned_units_counter = {
	"demon": 0,
	"human": 0
}

@onready var music = $Music
@onready var musicLoop = $Loop
@onready var sfx = $SFX

@onready var HUD = $Interface
@onready var pauseMenu = $PauseMenuInterface
@onready var gameOverUI = $GameOver

var unitNames = null

func _ready():
	Events.connect("spawnUnit", spawnUnit)
	Events.connect("play_click_sound", play_click_sound)
	Events.connect("play_tick_sound", play_tick_sound)
	Events.connect("play_money_sound", play_money_sound)
	Events.connect("play_spend_money_sound", play_spend_money_sound)
	Events.connect("play_time_control_sound", play_time_control_sound)
	Events.connect("play_pause_sound", play_pause_sound)
	Events.connect("play_denied_sound", play_denied_sound)
	Events.connect("handle_game_over", handle_game_over)
	unitNames = DB.get_unit_classes().keys()
	pauseMenu.hide()
	gameOverUI.hide()
	HUD.show()
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	GameManager.resume()
	GameManager.reset_match()


func _physics_process(delta):
	_handle_demon_spawns(delta)
	_handle_human_spawns(delta)
	var clocktimePassed = (Time.get_ticks_usec() - time_begin) / 1000000.0
	clocktimePassed -= time_delay
	clocktimePassed = max(0, clocktimePassed)
	time += delta

	if clocktimePassed > 15.96 and not musicLoop.playing:
		musicLoop.play()

	var value = 0
	for i in unitNames.size():
		value = floori(floori(time / 100) * i)
		if value > 0:
			GameManager.unit_spawn_weight[unitNames[i]] += value

	if value > 0:
			time = 0


func _input(event):
	if event.is_action_pressed("escape"):
		play_tick_sound()
		if pauseMenu.visible:
			GameManager.resume()
		else:
			GameManager.pause()
		pauseMenu.visible = !pauseMenu.visible



func spawnUnit(className: String, realm: String):
	var unit = units[realm].instantiate()
	unit.init(load(str("res://resources/classes/class_", className, "_", realm, ".tres")))
	unit.add_damage(GameManager.damage_buff[realm])
	unit.add_max_hp(GameManager.hp_buff[realm])
	unit.add_attack_speed(GameManager.attack_speed_buff[realm])
	unit.add_armor(GameManager.armor_buff[realm])
	unit.add_armor_penetration(GameManager.armor_penetration_buff[realm])
	spawn_points[realm].add_child(unit)


func _handle_demon_spawns(delta):
	demon_spawn_cooldown.tick(delta)

	if demon_spawn_cooldown.is_ready():
		var tw = create_tween()
		tw.tween_callback(spawnUnit.bind("villager", "demon")).set_delay(0.8)
		tw.tween_callback(spawnUnit.bind(DB.get_random_unit(), "demon")).set_delay(0.8)
		tw.tween_callback(spawnUnit.bind("archer", "demon")).set_delay(0.8)
		spawned_units_counter.demon += 3


func _handle_human_spawns(delta):
	human_spawn_cooldown.tick(delta)

	if human_spawn_cooldown.is_ready():
		var tw = create_tween()
		tw.tween_callback(spawnUnit.bind("villager", "human")).set_delay(0.8)
		tw.tween_callback(spawnUnit.bind(DB.get_random_unit(), "human")).set_delay(0.8)
		tw.tween_callback(spawnUnit.bind("archer", "human")).set_delay(0.8)
		spawned_units_counter.human += 3


func _on_targetable_area_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_pressed("click") and GameManager.selectedAbility:
		print("used Ability")
		var a = ability.instantiate()
		add_child(a)
		a.global_position = get_global_mouse_position()
		var targets = a.get_child(0).get_overlapping_bodies()
		var targetAreas = a.get_child(0).get_overlapping_areas()
		print("a.global_position", a.global_position)
		print("targets ", targets.size())
		print("targetAreas ", targetAreas.size())
		for t in targets:
			if t.has_method("take_damage"):
				t.take_damage(GameManager.selectedAbility.value, null)
		GameManager.selectedAbility = null


func _on_resume_game_pressed():
	play_click_sound()
	GameManager.resume()
	pauseMenu.hide()


func _on_restart_game_pressed():
	get_tree().change_scene_to_packed(load("res://levels/start_screen.tscn"))


func play_click_sound():
	sfx.stream = load("res://assets/audio/kenney_ui-audio/Audio/click1.ogg")
	sfx.play()


func play_tick_sound():
	sfx.stream = load("res://assets/audio/kenney_ui-audio/Audio/click3.ogg")
	sfx.play()


func play_money_sound():
	sfx.stream = load("res://assets/audio/Shapeforms Audio Free Sound Effects/The Mint – Coins and Money Preview/AUDIO/Coins in Sack Dropped on Soft Surface.wav")
	sfx.play()


func play_spend_money_sound():
	sfx.stream = load("res://assets/audio/Shapeforms Audio Free Sound Effects/The Mint – Coins and Money Preview/AUDIO/Wallet Close.wav")
	sfx.play()


func play_time_control_sound():
	sfx.stream = load("res://assets/audio/Shapeforms Audio Free Sound Effects/Cassette Preview/AUDIO/BUTTON_12.wav")
	sfx.play()


func play_pause_sound():
	sfx.stream = load("res://assets/audio/Shapeforms Audio Free Sound Effects/Cassette Preview/AUDIO/BUTTON_STOP_02.wav")
	sfx.play()


func play_denied_sound():
	sfx.stream = load("res://assets/audio/kenney_interface-sounds/Audio/glass_001.ogg")
	sfx.play()


func handle_game_over(_result):
	pauseMenu.hide()
	gameOverUI.show()
	HUD.hide()
