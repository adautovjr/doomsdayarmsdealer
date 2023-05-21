class_name Moveable_Object extends InteractableObject

var holdingObject = false
var relative_mouse_position = null
var drop_point

func _ready():
	drop_point = global_position

func interaction_method(value):
	position.x += value * 1.65


func _on_interactable_area_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("click") and GameManager.active_spell == "telekinesis":
		holdingObject = true
		gravity_scale = 0
		relative_mouse_position = global_position - get_global_mouse_position()
		drop_point = global_position

func _physics_process(delta):
	if holdingObject:
		if not $InteractableArea.get_overlapping_bodies().has(func (body): return body.is_in_group("environment")):
			global_position = lerp(global_position, get_global_mouse_position() + relative_mouse_position, 25 * delta)
		# look_at(get_global_mouse_position())
	# elif get_colliding_bodies().size() > 0:
		# global_position = lerp(global_position, drop_point, 10 * delta)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			drop()


func drop():
	print("Dropped")
	holdingObject = false
	gravity_scale = 1


func _on_body_entered(body):
	if body.is_in_group("environment") or body.is_in_group("player"):
		drop()


func _on_interactable_area_body_entered(body):
	if body.is_in_group("environment") or body.is_in_group("player"):
		drop()
