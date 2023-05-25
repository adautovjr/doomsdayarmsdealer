extends Node

@onready var cardDB = preload("res://resources/cards/CardsDatabase.gd")
@onready var cardScene = preload("res://scenes/Card.tscn")

var player_balance = 100.0
var card_buy_price = 20.0

var damage_buff = {
	"demon": 0.0,
	"human": 0.0
}
var attack_speed_buff = {
	"demon": 0.0,
	"human": 0.0
}
var hp_buff = {
	"demon": 0.0,
	"human": 0.0
}

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
	Events.emit_signal("update_balance_ui")


func add_money(amount: float):
	player_balance += amount
	Events.emit_signal("update_balance_ui")


func increase_buy_price(amount: float):
	card_buy_price += amount
	Events.emit_signal("update_balance_ui")


func decrease_buy_price(amount: float):
	card_buy_price -= amount
	Events.emit_signal("update_balance_ui")


func save_death_data(data: Dictionary):
	var file = FileAccess.open(ProjectSettings.globalize_path("/Users/adautoguedes/Documents/projects/personal/game_death_analysis/src/death_data.json"), FileAccess.READ_WRITE)
	var storedData = JSON.parse_string(file.get_as_text())
	storedData.merge(data, true)
	file.store_line(JSON.stringify(storedData))


func reset_death_data():
	var file = FileAccess.open(ProjectSettings.globalize_path("/Users/adautoguedes/Documents/projects/personal/game_death_analysis/src/death_data.json"), FileAccess.WRITE)
	file.store_line("{}")
	file.close()


func handle_card_buff(cardInfo, realm):
	if cardInfo.type != "Event":
		return

	match cardInfo.buff_type:
		"damage":
			damage_buff[realm] += cardInfo.value
		"attack_speed":
			attack_speed_buff[realm] += cardInfo.value
		"hp":
			hp_buff[realm] += cardInfo.value
		_:
			print("Card buff not implemented")


func game_over():
	get_tree().quit()
