@tool
extends Resource

const DATA = {
	"villager": {
		"type": "Unit",
		"description": "Villager",
		"sell_price": 4.0,
		"sprite_frame": 0
	},
	"tank": {
		"type": "Unit",
		"description": "Can take more damage",
		"sell_price": 8.0,
		"sprite_frame": 9
	},
	"footman": {
		"type": "Unit",
		"description": "Can deal more damage",
		"sell_price": 10.0,
		"sprite_frame": 18
	},
	"knight": {
		"type": "Unit",
		"description": "King's loyal footmen",
		"sell_price": 15.0,
		"sprite_frame": 27
	},
	"archer": {
		"type": "Unit",
		"description": "Has higher range and damage",
		"sell_price": 10.0,
		"sprite_frame": 36
	},
	"royal_guard": {
		"type": "Unit",
		"description": "Can take a lot more damage",
		"sell_price": 25.0,
		"sprite_frame": 45
	},
	"royal_knight": {
		"type": "Unit",
		"description": "Can deal a lot more damage",
		"sell_price": 30.0,
		"sprite_frame": 54
	},
	"damage_buff": {
		"type": "Event",
		"description": "+Damage",
		"sell_price": 5.0,
		"sprite_frame": 71,
		"buff_type": "damage",
		"value": 100
	},
	"attack_speed_buff": {
		"type": "Event",
		"description": "+Attack speed",
		"sell_price": 1.0,
		"sprite_frame": 71,
		"buff_type": "attack_speed",
		"value": 50
	},
	"hp_buff": {
		"type": "Event",
		"description": "+HP",
		"sell_price": 8.0,
		"sprite_frame": 71,
		"buff_type": "hp",
		"value": 100
	}
}


static func get_unit_classes() -> Dictionary:
	var classes = {}
	var cards = DATA.keys()

	for c in cards:
		if DATA.get(c).type == "Unit":
			classes.merge({ c: DATA.get(c)})

	return classes


static func get_random_unit() -> Dictionary:
	var units = get_unit_classes()
	return units
