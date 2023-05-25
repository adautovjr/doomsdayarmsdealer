extends MarginContainer
class_name Card

var cardInfo = null
var unitClass
var cardRealm


@onready var description = $MarginContainer/VBoxContainer/MarginContainer/Description
@onready var sprite = $MarginContainer/Sprite2D
@onready var cardSellPrice = $MarginContainer/VBoxContainer/HBoxContainer/CardSellPrice
@onready var hp = $MarginContainer/VBoxContainer/HBoxContainer2/HP
@onready var attack = $MarginContainer/VBoxContainer/HBoxContainer2/Attack

func init(cardName = "tank", realm = "human"):
	var cardDB = load("res://resources/cards/CardsDatabase.gd")
	cardInfo = cardDB.DATA[cardName]
	unitClass = cardName
	cardRealm = realm


func _ready():
	description.text = str(cardRealm.capitalize(), "\n", cardInfo.description)
	description.visible = cardInfo.type == "Event"
	sprite.frame = cardInfo.sprite_frame + 63 if cardRealm == "demon" and cardInfo.type == "Unit" else cardInfo.sprite_frame
	cardSellPrice.text = str("$", cardInfo.sell_price)
	var ci = load(str("res://resources/classes/class_", unitClass, "_", cardRealm, ".tres")) as ClassInfo
	if ci:
		hp.text = str(ci.hp)
		attack.text = str(ci.damage)
	else:
		hp.text = ""
		attack.text = ""

func _on_button_pressed():
	print(cardInfo)
	match cardInfo.type:
		"Unit":
			Events.emit_signal("spawnUnit", unitClass, cardRealm)
			GameManager.add_money(cardInfo.sell_price)
		"Event":
			GameManager.handle_card_buff(cardInfo, cardRealm)
		_:
			print(cardInfo.type + " card not Implemented yet")
	queue_free()
