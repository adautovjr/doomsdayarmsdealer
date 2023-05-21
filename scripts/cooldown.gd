var time = 0.0
var cooldown = 0.0

func _init(cooldown):
	self.cooldown = cooldown
	self.time = 0

func tick(delta):
	time = max(time - delta, 0)

func is_ready():
	if time > 0:
		return false

	time = cooldown
	return true

func reset():
	time = 0
