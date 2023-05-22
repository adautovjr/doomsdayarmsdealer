extends Node

@onready var cardDB = preload("res://resources/cards/CardsDatabase.gd")
@onready var cardScene = preload("res://scenes/Card.tscn")

var player_balance = 100.0
var card_buy_price = 20.0

func _ready():
	pass

func increase_engine_speed():
	Engine.time_scale = Engine.time_scale * 2

func decrease_engine_speed():
	Engine.time_scale = Engine.time_scale / 2

func togglePause():
	Engine.time_scale = 0 if Engine.time_scale != 0 else 1


func spawnRandomCards(qty: int):
	var cards = cardDB.DATA.keys()
	var rng = RandomNumberGenerator.new()
	var realms = ["demon", "human"]

	for i in range(0, qty):
		var index = rng.randi_range(0, cards.size() - 1)
		rng.randomize()
		spawnCard(cards[index], realms[rng.randi_range(0, 1)])


func spawnCard(cardName: String, realm: String):
	var newCard = cardScene.instantiate()
	newCard.init(cardName, realm)
	Events.emit_signal("add_cards_to_players_hand", newCard)


func spend_money(amount: float):
	player_balance -= amount
	Events.emit_signal("update_player_balance")


func add_money(amount: float):
	player_balance += amount
	Events.emit_signal("update_player_balance")
