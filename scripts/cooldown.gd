var time = 0.0
var cooldown = 0.0

func _init(cd):
	self.cooldown = cd
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


func restart():
	time = cooldown
