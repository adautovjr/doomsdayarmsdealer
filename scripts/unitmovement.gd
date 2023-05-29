class_name Unit extends CharacterBody2D

const Cooldown = preload("res://scripts/cooldown.gd")
const SPEED = 100.0
const BASE_ATTACK_TIME = 1.7
const BASE_CRITICAL_CHANCE = 0.1
const CRITICAL_DAMAGE_ALLOWED = true
const MAX_ATTACK_SPEED = 700
var class_info: ClassInfo

enum STATES {
	WALK,
	ATTACK,
	DIE
}

var state: STATES = STATES.WALK
var target = null # We cannot type this since GDScript has no union typing
var max_hp: float

var is_moving_left: bool
var attack_cooldown_time: float
var hp: float = 100.0
var armor: int = 0
var armor_penetration: float = 0
var damage: float

## METADATA ##
var last_hit_by = null
var hits_taken: int = 0
var critical_hits_taken: int = 0
var total_damage_taken: float = 0
var total_damage_dealt: float = 0
var is_in_arena: bool = false
var lifetime: float = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea2D
@onready var health_bar = $HUD/HealthBar
var attack_cooldown = null

func init(ci: ClassInfo, arena = false):
	self.class_info = ci
	is_in_arena = arena


func _ready():
	$HUD/DebugLabel.text = ""
	hp = class_info.hp
	is_moving_left = class_info.is_moving_left
	damage = class_info.damage
	armor = class_info.armor
	armor_penetration = class_info.armor_penetration
	attack_cooldown_time = _get_attack_cooldown_time(clampf(class_info.attack_speed, 1, MAX_ATTACK_SPEED))
	attack_cooldown = Cooldown.new(attack_cooldown_time)

	var shape = RectangleShape2D.new()
	shape.set_size(Vector2(class_info.attack_range, 30))
	var collision = CollisionShape2D.new()
	collision.set_shape(shape)
	detection_area.add_child(collision)

	max_hp = hp
	health_bar.visible = false
	health_bar.value = 100
	if is_moving_left:
		animated_sprite.flip_h = true
		detection_area.position = Vector2(-((class_info.attack_range + 15) /2) , -3)
	else:
		detection_area.position = Vector2(((class_info.attack_range + 15) /2), -3)


func _physics_process(delta):
	lifetime += delta
	_get_animation(delta)
	_get_action(delta)
	move_and_slide()
	update_ui()
	pass


############## Animation ##############

func _get_animation(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	elif state == STATES.ATTACK:
		animated_sprite.play("attack_" + class_info.classname)
	else:
		if velocity.x == 0:
			animated_sprite.play("idle_" + class_info.classname)
		else:
			animated_sprite.play("walk_" + class_info.classname)


############## Movement ##############

func _get_action(delta):
	handle_death()
	match state:
		STATES.WALK:
			velocity.x = -SPEED if is_moving_left else SPEED
		STATES.ATTACK:
			double_check_target()
			velocity.x = 0
			attack_cooldown.tick(delta)
			if attack_cooldown.is_ready() and target != null:
				if target.has_method("take_damage"):
					var is_critical_hit = _is_next_attack_critical(class_info.critical_chance)
					var calculatedDamage = damage * class_info.critical_damage if is_critical_hit else damage
					calculatedDamage *= _get_damage_reduction_multiplier(armor_penetration)
					target.take_damage(calculatedDamage, self)
		_:
			velocity.x = 0
			pass


############## Actions ##############

func take_damage(d: float, attacker: Unit):
	if state == STATES.DIE and attacker:
		attacker.check_collisions_for_valid_target()
		return
	var tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "hp", -d, 0.5).as_relative().from_current()
	process_take_damage_metadata(d, attacker)


func add_damage(value):
	damage += value

func add_max_hp(value):
	max_hp += value
	hp += value

func add_attack_speed(value):
	attack_cooldown_time = _get_attack_cooldown_time(clampf(class_info.attack_speed + value, 1, MAX_ATTACK_SPEED))
	attack_cooldown = Cooldown.new(attack_cooldown_time)


func add_armor(value):
	armor += value


func add_armor_penetration(value):
	armor_penetration += value


func check_collisions_for_valid_target(body = null) -> bool:
	var is_valid_target = _is_valid_target(body)
	if is_valid_target and target == null:
		_set_target(body)
		return true

	if body == null and target == null:
		var bodies = detection_area.get_overlapping_bodies()
		for b in bodies:
			if _is_valid_target(b):
				_set_target(b)
				return true
		var areas = detection_area.get_overlapping_areas()
		for a in areas:
			if _is_valid_target(a):
				_set_target(a)
				return true

	if target != null and target is Unit and target.state == STATES.DIE:
		_set_target(null)
		state = STATES.WALK
		attack_cooldown.reset()

	return false


func _set_target(t):
	target = t
	if t != null:
		state = STATES.ATTACK


func double_check_target():
	if not _is_valid_target(target):
		check_collisions_for_valid_target()

############## UI ##############

func update_ui():
	update_health_bar()

func update_health_bar():
	if hp == max_hp or hp <= 0:
		health_bar.visible = false
	else:
		health_bar.visible = true
	health_bar.value = hp * 100 / max_hp


############## Events ##############

func _on_detection_area_2d_body_entered(body):
	if state != STATES.DIE:
		$HUD/DebugLabel.text = body.name
		check_collisions_for_valid_target(body)


func _on_detection_area_2d_body_exited(_body):
	if state != STATES.DIE:
		check_collisions_for_valid_target()


func _on_detection_area_2d_area_entered(area):
	if state != STATES.DIE:
		check_collisions_for_valid_target(area)


func _on_detection_area_2d_area_exited(_area):
	if state != STATES.DIE:
		check_collisions_for_valid_target()


############## Helpers ##############

func _is_valid_target(body) -> bool:
	if body == null:
		return false
	if not body.has_method("get_collision_layer"):
		return false
	if (body.get_collision_layer() == 2 or body.get_collision_layer() == 4):
		if (body.state != STATES.DIE):
			return true
	if (body.get_collision_layer() == 8 or body.get_collision_layer() == 16):
		return true
	return false


func _get_attack_cooldown_time(attack_speed: float):
	return BASE_ATTACK_TIME / (1 + (attack_speed / 100))


func _get_critical_strike_chance(critical_chance: float):
	return 1 - ((1 - BASE_CRITICAL_CHANCE) * (1 - (critical_chance / 100)))


func _is_next_attack_critical(critical_chance: float) -> bool:
	if not CRITICAL_DAMAGE_ALLOWED:
		return false
	var rng = RandomNumberGenerator.new()
	var roll = rng.randf_range(0, 1)

	return roll <= _get_critical_strike_chance(critical_chance)


func _get_damage_reduction_multiplier(enemy_armor_penetration: float):
	var this_unit_armor = armor
	if enemy_armor_penetration > 0:
		this_unit_armor *= 1 - (enemy_armor_penetration / 100)

	if this_unit_armor < 0:
		return 1 - ((0.06 * this_unit_armor) / (1 + 0.06 * -this_unit_armor))

	return 1 - ((0.06 * this_unit_armor) / (1 + 0.06 * this_unit_armor))


############## METADATA ##############

func handle_death():
	if hp <= 0:
		state = STATES.DIE
		$AnimationPlayer.play("money_earned")
		$HUD/DebugLabel.text = "die_" + class_info.classname
		animated_sprite.play("die_" + class_info.classname)
		GameManager.add_money(2)
		GameManager.scoreboard["demon" if is_moving_left else "human"] += 1
		set_physics_process(false)
		if is_in_arena and last_hit_by:
			var death_data = {
				str("human_" if last_hit_by.is_moving_left else "demon_", last_hit_by.class_info.classname, ";", "human_" if is_moving_left else "demon_", self.class_info.classname): {
					"kills": 1,
					"hits_taken": hits_taken,
					"lifetime": lifetime,
					"critical_hits_taken": critical_hits_taken,
					"total_damage_taken": total_damage_taken,
					"total_damage_dealt": total_damage_dealt
				}
			}
			GameManager.save_death_data(death_data)
			last_hit_by.queue_free()
		create_tween().tween_callback(queue_free).set_delay(2)


func process_take_damage_metadata(d: float, attacker: Unit):
	last_hit_by = attacker
	hits_taken += 1
	total_damage_taken += d
	if attacker:
		critical_hits_taken += 1 if d > attacker.damage else 0
		attacker.total_damage_dealt += d
