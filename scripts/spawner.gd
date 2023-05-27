extends Node2D

@onready var DB = preload("res://resources/cards/CardsDatabase.gd")

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

@onready var demon_spawn_cooldown = Cooldown.new(10)
@onready var human_spawn_cooldown = Cooldown.new(10)

var spawned_units_counter = {
	"demon": 0,
	"human": 0
}

var unitNames = null

func _ready():
	Events.connect("spawnUnit", spawnUnit)
	unitNames = DB.get_unit_classes().keys()


func _physics_process(delta):
	_handle_demon_spawns(delta)
	_handle_human_spawns(delta)
	time += delta
	var value = 0
	for i in unitNames.size():
		value = floori(floori(time / 100) * i)
		if value > 0:
			GameManager.unit_spawn_weight[unitNames[i]] += value

	if value > 0:
			time = 0



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
