extends CanvasLayer

@onready var hand = $MarginContainer/Hand
@onready var cardBuyPriceLabel = $MarginContainer2/CardBuyPrice
@onready var playerBalanceLabel = $MarginContainer3/PlayerBalance

func _ready():
	Events.connect("add_cards_to_players_hand", add_cards_to_players_hand)
	Events.connect("update_balance_ui", update_balance_ui)
	GameManager.spawnRandomCards(5)
	update_balance_ui()


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
	else:
		show_balance_unavailable_warning()


func add_cards_to_players_hand(card):
	GameManager.increase_buy_price(2)
	if hand:
		hand.add_child(card)


func show_balance_unavailable_warning():
	var tw = create_tween()
	tw.tween_method(change_color, Color("000000"), Color("c50000"), .1).set_ease(Tween.EASE_IN)
	tw.tween_method(change_color, Color("c50000"), Color("000000"), .5).set_ease(Tween.EASE_OUT)

func change_color(color: Color):
	cardBuyPriceLabel.add_theme_color_override("font_outline_color", color)
	playerBalanceLabel.add_theme_color_override("font_outline_color", color)


func update_balance_ui():
	if playerBalanceLabel and cardBuyPriceLabel:
		playerBalanceLabel.text = str("$ ", GameManager.player_balance)
		cardBuyPriceLabel.text = str("$ ", GameManager.card_buy_price)
