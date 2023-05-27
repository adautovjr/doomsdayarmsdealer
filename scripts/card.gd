extends MarginContainer
class_name Card

var cardInfo = null
var unitClass
var cardRealm
var eventLevel = 1


@onready var description = $MarginContainer/VBoxContainer/MarginContainer/Description
@onready var sprite = $MarginContainer/Sprite2D
@onready var modifier = $MarginContainer/Modifier
@onready var cardSellPrice = $MarginContainer/VBoxContainer/HBoxContainer/CardSellPrice
@onready var hp = $MarginContainer/VBoxContainer/HBoxContainer2/HP
@onready var attack = $MarginContainer/VBoxContainer/HBoxContainer2/Attack


const EVENT_LEVEL_WEIGHTS = {
	-3: 15,
	-2: 45,
	-1: 60,
	1: 80,
	2: 60,
	3: 20
}

func init(cardName = "tank", realm = "human"):
	var cardDB = load("res://resources/cards/CardsDatabase.gd")
	cardInfo = cardDB.DATA[cardName]
	unitClass = cardName
	cardRealm = realm


func _ready():
	description.visible = cardInfo.type == "Event"
	cardSellPrice.text = str("$", cardInfo.sell_price)
	if cardInfo.type == "Unit":
		description.text = str(cardRealm.capitalize(), "\n", cardInfo.description)
		sprite.frame = cardInfo.sprite_frame + 63 if cardRealm == "demon" else cardInfo.sprite_frame
		modifier.frame = 143
		var ci = load(str("res://resources/classes/class_", unitClass, "_", cardRealm, ".tres")) as ClassInfo
		if ci:
			hp.text = str(ci.hp)
			attack.text = str(ci.damage)
			return
	if cardInfo.type == "Event":
		sprite.frame = cardInfo.sprite_frame[cardRealm]
		eventLevel = weighted_random_level_choice()
		match eventLevel:
			-3:
				modifier.frame = 139
				description.text = str(cardRealm.capitalize(), "\n", "---", cardInfo.description)
			-2:
				modifier.frame = 137
				description.text = str(cardRealm.capitalize(), "\n", "--", cardInfo.description)
			-1:
				modifier.frame = 135
				description.text = str(cardRealm.capitalize(), "\n", "-", cardInfo.description)
			2:
				modifier.frame = 138
				description.text = str(cardRealm.capitalize(), "\n", "++", cardInfo.description)
			3:
				modifier.frame = 140
				description.text = str(cardRealm.capitalize(), "\n", "+++", cardInfo.description)
			_:
				modifier.frame = 136
				description.text = str(cardRealm.capitalize(), "\n", "+", cardInfo.description)
	hp.text = ""
	attack.text = ""

func _on_button_pressed():
	print(cardInfo)
	match cardInfo.type:
		"Unit":
			Events.emit_signal("spawnUnit", unitClass, cardRealm)
			GameManager.add_money(cardInfo.sell_price)
		"Event":
			GameManager.handle_card_buff(cardInfo, eventLevel, cardRealm)
			GameManager.add_money(cardInfo.sell_price)
		_:
			print(cardInfo.type + " card not Implemented yet")
	queue_free()


func weighted_random_level_choice():
	var levels = EVENT_LEVEL_WEIGHTS.keys()
	var weights = EVENT_LEVEL_WEIGHTS.values()
	var weightsCopy: Array = weights.duplicate(true)
	var totalProbability: int = 0

	for i in weights.size():
		totalProbability += int(weightsCopy[i])
		continue

	var chosenOptionInt: int = GameManager.rand_int(0, totalProbability)

	var growingProbability: int = 0
	for a in weightsCopy.size():
		growingProbability += int(weightsCopy[a])
		weightsCopy[a] = growingProbability

		if weightsCopy[a] > chosenOptionInt:
			return levels[a]

		if chosenOptionInt <= weightsCopy[weightsCopy.size()-1]:
			return levels[weightsCopy.size()-1]
