extends MarginContainer
class_name Card

var cardInfo = null
var unitClass
var cardRealm


func init(className = "tank", realm = "human"):
	var cardDB = load("res://resources/cards/CardsDatabase.gd")
	cardInfo = cardDB.DATA[className]
	unitClass = className
	cardRealm = realm


func _ready():
	$MarginContainer/VBoxContainer/Description.text = cardInfo.description
	$Sprite2D.frame = cardInfo.sprite_frame if cardRealm == "human" else cardInfo.sprite_frame + 63
	pass


func _on_button_pressed():
	print(cardInfo)
	match cardInfo.type:
		"Unit":
			Events.emit_signal("spawnUnit", unitClass, cardRealm)
			GameManager.add_money(cardInfo.sell_price)
		_:
			print(cardInfo.type + " card not Implemented yet")
	queue_free()
