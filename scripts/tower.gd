extends RigidBody2D

@export var hp = 2000
var max_hp: float
@onready var health_bar = $HUD/HealthBar


func _ready():
	max_hp = hp


func _physics_process(_delta):
	update_ui()


func take_damage(damage: float):
	var tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "hp", -damage, 0.5).as_relative().from_current()


func update_ui():
	update_health_bar()

func update_health_bar():
	if hp == max_hp:
		health_bar.visible = false
	else:
		health_bar.visible = true
	health_bar.value = hp * 100 / max_hp
