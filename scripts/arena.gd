extends "res://scripts/spawner.gd"

@onready var cardDB = preload("res://resources/cards/CardsDatabase.gd")


func _ready():
	spawnTestUnits()
	GameManager.reset_death_data()


func _physics_process(_delta):
	pass


func spawnUnitInArena(className: String, realm: String, SpawnPoint: String):
	var unit = units[realm].instantiate()
	unit.init(load(str("res://resources/classes/class_", className, "_", realm, ".tres")), true)
	unit.add_damage(spawned_units_counter[realm])
	get_node(SpawnPoint).add_child(unit)


func spawnTestUnits():
	var unitClasses = cardDB.get_unit_classes().keys()
	for i in unitClasses.size():
		for j in unitClasses.size():
			spawnUnitInArena(unitClasses[i], "demon", str("demonSpawns/", unitClasses[i], "/Spawn", str(j + 1) if j != 0 else ""))
			spawnUnitInArena(unitClasses[j], "human", str("humanSpawns/", unitClasses[j], "/Spawn", str(i + 1) if i != 0 else ""))


func _on_reset_pressed():
	GameManager.reset_death_data()
	spawnTestUnits()
