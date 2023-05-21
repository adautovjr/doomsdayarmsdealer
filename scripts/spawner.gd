extends Node2D


@onready var units = {
	"demon": preload("res://scenes/demon.tscn"),
	"human": preload("res://scenes/human.tscn")
}
@onready var spawn_points = {
	"demon": $DemonSpawn,
	"human": $HumanSpawn,
}

const Cooldown = preload("res://scripts/cooldown.gd")

@onready var demon_spawn_cooldown = Cooldown.new(5)
@onready var human_spawn_cooldown = Cooldown.new(5)

var spawned_units_counter = {
	"demon": 0,
	"human": 0
}


func _physics_process(delta):
	_handle_demon_spawns(delta)
	#_handle_human_spawns(delta)


func spawnUnit(className: String, type: String):
	var unit = units[type].instantiate()
	unit.init(load("res://resources/classes/class_" + className + "_" + type + ".tres"))
	unit.add_damage(spawned_units_counter[type])
	spawn_points[type].add_child(unit)


func _handle_demon_spawns(delta):
	demon_spawn_cooldown.tick(delta)

	if demon_spawn_cooldown.is_ready():
		var tw = create_tween()
		tw.tween_callback(spawnUnit.bind("tank", "demon")).set_delay(0.5)
		tw.tween_callback(spawnUnit.bind("knight", "demon")).set_delay(0.5)
		tw.tween_callback(spawnUnit.bind("archer", "demon")).set_delay(0.5)
		spawned_units_counter.demon += 3


func _handle_human_spawns(delta):
	human_spawn_cooldown.tick(delta)

	if human_spawn_cooldown.is_ready():
		var tw = create_tween()
		tw.tween_callback(spawnUnit.bind("tank", "human")).set_delay(0.5)
		tw.tween_callback(spawnUnit.bind("knight", "human")).set_delay(0.5)
		tw.tween_callback(spawnUnit.bind("archer", "human")).set_delay(0.5)
		spawned_units_counter.human += 3
