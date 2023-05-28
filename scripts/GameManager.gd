extends Node

@onready var cardDB = preload("res://resources/cards/CardsDatabase.gd")
@onready var cardScene = preload("res://scenes/Card.tscn")

var player_balance = 1000000.0
var card_buy_price = 20.0
var discard_hand_price = 50.0
var swap_hand_price = 100.0
var swap_hand_cooldown_time = 60.0

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
var armor_buff = {
	"demon": 0,
	"human": 0
}
var armor_penetration_buff = {
	"demon": 0,
	"human": 0
}

var unit_spawn_weight = {
	"villager": 0.0,
	"tank": 0.0,
	"footman": 0.0,
	"knight": 0.0,
	"archer": 0.0,
	"royal_guard": 0.0,
	"royal_knight": 0.0
}

var scoreboard = {
	"human": 0,
	"demon": 0
}

var selectedAbility = null

func increase_engine_speed():
	if Engine.time_scale == 0:
		Engine.time_scale = 2
		return

	if Engine.time_scale <= 16:
		Engine.time_scale = Engine.time_scale * 2

func decrease_engine_speed():
	if Engine.time_scale == 0:
		resume()
	Engine.time_scale = Engine.time_scale / 2

func pause():
	Engine.time_scale = 0

func resume():
	Engine.time_scale = 1


func spawnRandomCards(qty: int, realm = null):
	var realms = ["demon", "human"]

	for i in range(0, qty):
		var cardName = weighted_random_card_choice()
		var cardRealm = realm if realm else realms[rand_int(0, 1)]
		if armor_penetration_buff[cardRealm] >= 95:
			if cardName == "armor_penetration_buff":
					cardName = "armor_buff"
		spawnCard(cardName, cardRealm)

func rand_int(begin: int = 0, end: int = 10):
	randomize()
	return randi() % (end+1) + begin

func weighted_random_card_choice():
	var cardKeys = cardDB.DATA.keys()
	var cards = cardDB.DATA.values()
	var cardsCopy: Array = cards.duplicate(true)
	var totalProbability: int = 0

	for i in cards.size():
		totalProbability += int(cardsCopy[i].chance)
		continue

	var chosenOptionInt: int = rand_int(0, totalProbability)

	var growingProbability: int = 0
	for a in cardsCopy.size():
		growingProbability += int(cardsCopy[a].chance)
		cardsCopy[a].chance = growingProbability

		if cardsCopy[a].chance > chosenOptionInt:
			return cardKeys[a]

		if chosenOptionInt <= cardsCopy[cardsCopy.size()-1].chance:
			return cardKeys[cardsCopy.size()-1]


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


func handle_card_buff(cardInfo, eventLevel, realm):
	if cardInfo.type != "Event":
		return

	match cardInfo.buff_type:
		"damage":
			damage_buff[realm] += cardInfo.value * eventLevel
		"attack_speed":
			attack_speed_buff[realm] += cardInfo.value * eventLevel
		"hp":
			hp_buff[realm] += cardInfo.value * eventLevel
		"armor":
			armor_buff[realm] += cardInfo.value * eventLevel
		"armor_penetration":
			armor_penetration_buff[realm] += cardInfo.value * eventLevel
		_:
			print("Card buff not implemented")


func game_over():
	get_tree().quit()
