extends CanvasLayer

@onready var hand = $MarginContainer/Hand

func _ready():
	Events.connect("add_cards_to_players_hand", add_cards_to_players_hand)
	Events.connect("update_player_balance", update_player_balance)
	GameManager.spawnRandomCards(5)
	update_player_balance()


func _on_button_pressed():
	GameManager.increase_engine_speed()


func _on_button_2_pressed():
	GameManager.togglePause()


func _on_button_3_pressed():
	GameManager.decrease_engine_speed()


func _on_buy_card_button_pressed():
	if GameManager.player_balance >= GameManager.card_buy_price:
		GameManager.spend_money(GameManager.card_buy_price)
		GameManager.spawnRandomCards(2)


func add_cards_to_players_hand(card):
	hand.add_child(card)


func update_player_balance():
	$MarginContainer3/PlayerBalance.text = str("$ ", GameManager.player_balance)
