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

@onready var demon_spawn_cooldown = Cooldown.new(10)
@onready var human_spawn_cooldown = Cooldown.new(10)

var spawned_units_counter = {
	"demon": 0,
	"human": 0
}


func _ready():
	Events.connect("spawnUnit", spawnUnit)


func _physics_process(delta):
	_handle_demon_spawns(delta)
	_handle_human_spawns(delta)
	pass


func spawnUnit(className: String, realm: String):
	var unit = units[realm].instantiate()
	unit.init(load(str("res://resources/classes/class_", className, "_", realm, ".tres")))
	unit.add_damage(GameManager.damage_buff[realm])
	unit.add_max_hp(GameManager.hp_buff[realm])
	unit.add_attack_speed(GameManager.attack_speed_buff[realm])
	spawn_points[realm].add_child(unit)


func _handle_demon_spawns(delta):
	demon_spawn_cooldown.tick(delta)

	if demon_spawn_cooldown.is_ready():
		var tw = create_tween()
		tw.tween_callback(spawnUnit.bind("villager", "demon")).set_delay(0.5)
		tw.tween_callback(spawnUnit.bind("footman", "demon")).set_delay(0.5)
		tw.tween_callback(spawnUnit.bind("archer", "demon")).set_delay(0.5)
		spawned_units_counter.demon += 3


func _handle_human_spawns(delta):
	human_spawn_cooldown.tick(delta)

	if human_spawn_cooldown.is_ready():
		var tw = create_tween()
		tw.tween_callback(spawnUnit.bind("villager", "human")).set_delay(0.5)
		tw.tween_callback(spawnUnit.bind("footman", "human")).set_delay(0.5)
		tw.tween_callback(spawnUnit.bind("archer", "human")).set_delay(0.5)
		spawned_units_counter.human += 3
