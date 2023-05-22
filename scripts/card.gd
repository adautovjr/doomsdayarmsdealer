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
	# $Sprite2D.frame = 0 if cardRealm == "human" else
	pass


func _on_button_pressed():
	print(cardInfo)
	match cardInfo.type:
		"Unit":
			Events.emit_signal("spawnUnit", unitClass, cardRealm)
		_:
			print(cardInfo.type + " card not Implemented yet")
	queue_free()
