@tool
extends Resource

const DATA = {
	"villager": {
		"type": "Unit",
		"description": "Villager",
		"sell_price": 4.0,
		"sprite_frame": 0,
		"chance": 50
	},
	"tank": {
		"type": "Unit",
		"description": "Can take more damage",
		"sell_price": 8.0,
		"sprite_frame": 9,
		"chance": 50
	},
	"footman": {
		"type": "Unit",
		"description": "Can deal more damage",
		"sell_price": 10.0,
		"sprite_frame": 18,
		"chance": 35
	},
	"knight": {
		"type": "Unit",
		"description": "King's loyal footmen",
		"sell_price": 15.0,
		"sprite_frame": 27,
		"chance": 30
	},
	"archer": {
		"type": "Unit",
		"description": "Has higher range and damage",
		"sell_price": 10.0,
		"sprite_frame": 36,
		"chance": 40
	},
	"royal_guard": {
		"type": "Unit",
		"description": "Can take a lot more damage",
		"sell_price": 25.0,
		"sprite_frame": 45,
		"chance": 15
	},
	"royal_knight": {
		"type": "Unit",
		"description": "Can deal a lot more damage",
		"sell_price": 30.0,
		"sprite_frame": 54,
		"chance": 10
	},
	"damage_buff": {
		"type": "Event",
		"description": "Damage",
		"sell_price": 5.0,
		"sprite_frame": {
			"human": 128,
			"demon": 129
		},
		"buff_type": "damage",
		"value": 100,
		"chance": 80
	},
	"attack_speed_buff": {
		"type": "Event",
		"description": "Attack speed",
		"sell_price": 1.0,
		"sprite_frame": {
			"human": 127,
			"demon": 126
		},
		"buff_type": "attack_speed",
		"value": 50,
		"chance": 80
	},
	"hp_buff": {
		"type": "Event",
		"description": "HP",
		"sell_price": 8.0,
		"sprite_frame": {
			"human": 131,
			"demon": 130
		},
		"buff_type": "hp",
		"value": 100,
		"chance": 80
	},
	"armor_buff": {
		"type": "Event",
		"description": "Armor",
		"sell_price": 8.0,
		"sprite_frame": {
			"human": 35,
			"demon": 8
		},
		"buff_type": "armor",
		"value": 10,
		"chance": 80
	},
	"armor_penetration_buff": {
		"type": "Event",
		"description": "Armor penetration",
		"sell_price": 8.0,
		"sprite_frame": {
			"human": 133,
			"demon": 132
		},
		"buff_type": "armor_penetration",
		"value": 5,
		"chance": 20
	}
}

# "thunderstrike": {
#		"type": "Ability",
#		"description": "Zaaap",
#		"sell_price": 8.0,
#		"sprite_frame": 89,
#		"value": 200,
#		"chance": 99
#	}


static func get_unit_classes() -> Dictionary:
	var classes = {}
	var cards = DATA.keys()

	for c in cards:
		if DATA.get(c).type == "Unit":
			classes.merge({ c: DATA.get(c)})

	return classes


static func get_random_unit():
	var units = get_unit_classes()
	var unitNames = units.keys()
	var unitInfos = units.values()
	var unitInfosCopy: Array = unitInfos.duplicate(true)
	var totalProbability: int = 0

	for i in unitInfos.size():
		totalProbability += clampi(int(unitInfosCopy[i].chance) + GameManager.unit_spawn_weight[unitNames[i]], 10, 90)
		continue

	var chosenOptionInt: int = GameManager.rand_int(0, totalProbability)

	var growingProbability: int = 0
	for a in unitInfosCopy.size():
		growingProbability += clampi(int(unitInfosCopy[a].chance) + GameManager.unit_spawn_weight[unitNames[a]], 10, 90)
		unitInfosCopy[a].chance = growingProbability

		if unitInfosCopy[a].chance > chosenOptionInt:
			return unitNames[a]

		if chosenOptionInt <= unitInfosCopy[unitInfosCopy.size()-1].chance:
			return unitNames[unitInfosCopy.size()-1]
