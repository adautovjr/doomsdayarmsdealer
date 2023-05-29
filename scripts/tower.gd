extends Area2D
class_name Tower

@export var hp = 10
@export var realm: String = ""
var max_hp: float
const MAX_ARMOR_PENETRATION = 95
@onready var health_bar = $HUD/HealthBar


func _ready():
	max_hp = hp


func _physics_process(_delta):
	update_ui()
	handle_game_over()


############## Actions ##############

func take_damage(damage: float, attacker: Unit):
	var tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "hp", -(damage + attacker.hp), 0.5).as_relative().from_current()
	attacker.queue_free()


func handle_game_over():
	if hp <= 0:
		GameManager.game_over(realm)


############## UI ##############

func update_ui():
	update_health_bar()

func update_health_bar():
	if hp == max_hp:
		health_bar.visible = false
	else:
		health_bar.visible = true
	health_bar.value = hp * 100 / max_hp

