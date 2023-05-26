extends Area2D
class_name Tower

@export var hp = 2000
@export var realm: String = ""
var max_hp: float
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
		GameManager.game_over()


############## UI ##############

func update_ui():
	update_health_bar()
	update_HUD_info()

func update_health_bar():
	if hp == max_hp:
		health_bar.visible = false
	else:
		health_bar.visible = true
	health_bar.value = hp * 100 / max_hp

func update_HUD_info():
	var hp_buff = GameManager.hp_buff[realm]
	var attack_speed_buff = GameManager.attack_speed_buff[realm]
	var damage_buff = GameManager.damage_buff[realm]
	var armor_buff = GameManager.armor_buff[realm]
	var armor_pen_buff = GameManager.armor_penetration_buff[realm]

	if hp_buff == 0:
		$HUD/HPInfo.text = ""
	else:
		$HUD/HPInfo.text = str("HP             +", hp_buff)

	if attack_speed_buff == 0:
		$HUD/AttackSpeedInfo.text = ""
	else:
		$HUD/AttackSpeedInfo.text = str("ATK SPD   +", attack_speed_buff)

	if damage_buff == 0:
		$HUD/DamageInfo.text = ""
	else:
		$HUD/DamageInfo.text = str("DMG         +", damage_buff)

	if armor_buff == 0:
		$HUD/ArmorInfo.text = ""
	else:
		$HUD/ArmorInfo.text = str("ARMOR            +", armor_buff)

	if armor_pen_buff == 0:
		$HUD/ArmorPenetrationInfo.text = ""
	else:
		$HUD/ArmorPenetrationInfo.text = str("ARMOR PEN    +", armor_pen_buff)


