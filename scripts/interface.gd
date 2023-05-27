extends CanvasLayer

@onready var hand = $MarginContainer/Hand
@onready var demonCardBuyPriceLabel = $Demon/CardBuyPrice
@onready var humanCardBuyPriceLabel = $Human/CardBuyPrice
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


func _on_buy_human_card_button_pressed():
	if GameManager.player_balance >= GameManager.card_buy_price and hand.get_child_count() <= 6:
		GameManager.spend_money(GameManager.card_buy_price)
		GameManager.spawnRandomCards(1, "human")
	else:
		show_balance_unavailable_warning()


func _on_buy_demon_card_button_pressed():
	if GameManager.player_balance >= GameManager.card_buy_price and hand.get_child_count() <= 6:
		GameManager.spend_money(GameManager.card_buy_price)
		GameManager.spawnRandomCards(1, "demon")
	else:
		show_balance_unavailable_warning()


func add_cards_to_players_hand(card):
	if hand:
		hand.add_child(card)


func show_balance_unavailable_warning():
	var tw = create_tween()
	tw.tween_method(change_color, Color("000000"), Color("c50000"), .1).set_ease(Tween.EASE_IN)
	tw.tween_method(change_color, Color("c50000"), Color("000000"), .5).set_ease(Tween.EASE_OUT)

func change_color(color: Color):
	demonCardBuyPriceLabel.add_theme_color_override("font_outline_color", color)
	humanCardBuyPriceLabel.add_theme_color_override("font_outline_color", color)
	playerBalanceLabel.add_theme_color_override("font_outline_color", color)


func update_balance_ui():
	if playerBalanceLabel and demonCardBuyPriceLabel and humanCardBuyPriceLabel:
		playerBalanceLabel.text = str("$ ", GameManager.player_balance)
		demonCardBuyPriceLabel.text = str("$ ", GameManager.card_buy_price)
		humanCardBuyPriceLabel.text = str("$ ", GameManager.card_buy_price)
