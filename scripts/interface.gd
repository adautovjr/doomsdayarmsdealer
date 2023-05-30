extends CanvasLayer

const Cooldown = preload("res://scripts/cooldown.gd")

@onready var hand = $MarginContainer/Hand
@onready var demonCardBuyPriceLabel = $Demon/MarginContainer/CardBuyPrice
@onready var humanCardBuyPriceLabel = $Human/MarginContainer/CardBuyPrice
@onready var playerBalanceLabel = $MatchInfo/HBoxContainer/PlayerBalance
@onready var matchTimeLabel = $MatchInfo/HBoxContainer/MatchTime
@onready var scoreboard = $MatchInfoTop/HBoxContainer/Scoreboard
@onready var discardHandPriceLabel = $Discard/DiscardPrice
@onready var swapHandPriceLabel = $Swap/MarginContainer/SwapPrice
@onready var swapHandProgressBar = $Swap/Node2D/TextureProgressBar
@onready var backButton = $TimeControl/HBoxContainer/BackButton
@onready var pauseButton = $TimeControl/HBoxContainer/PauseButton
@onready var playButton = $TimeControl/HBoxContainer/PlayButton
@onready var forwardButton = $TimeControl/HBoxContainer/ForwardButton

var matchTime = 0.0

var swap_hand_cooldown = null
var swap_hand_ready = false

func _ready():
	Events.connect("add_cards_to_players_hand", add_cards_to_players_hand)
	Events.connect("update_balance_ui", update_ui)
	GameManager.spawnRandomCards(5)
	swap_hand_cooldown = Cooldown.new(GameManager.swap_hand_cooldown_time)
	swap_hand_cooldown.reset()

func _physics_process(delta):
	matchTime += delta
	swap_hand_cooldown.tick(delta)
	swapHandProgressBar.value = swap_hand_cooldown.time * 100 / GameManager.swap_hand_cooldown_time
	var isCDReady = swap_hand_cooldown.is_ready()
	if isCDReady and not swap_hand_ready:
		swap_hand_ready = true
	if swap_hand_ready:
		swapHandProgressBar.visible = false
	else:
		swapHandProgressBar.visible = true

	update_ui()


############## Connections ##############

func _on_button_pressed():
	Events.emit_signal("play_time_control_sound")
	GameManager.increase_engine_speed()


func _on_button_2_pressed():
	Events.emit_signal("play_pause_sound")
	GameManager.pause()


func _on_play_pressed():
	Events.emit_signal("play_time_control_sound")
	GameManager.resume()


func _on_button_3_pressed():
	Events.emit_signal("play_time_control_sound")
	GameManager.decrease_engine_speed()


func _on_buy_human_card_button_pressed():
	if GameManager.selectedAbility:
		return

	if GameManager.player_balance >= GameManager.card_buy_price and hand.get_child_count() <= 7:
		GameManager.spend_money(GameManager.card_buy_price)
		GameManager.spawnRandomCards(1, "human")
	else:
		show_balance_unavailable_warning()


func _on_buy_demon_card_button_pressed():
	if GameManager.selectedAbility:
		return

	if GameManager.player_balance >= GameManager.card_buy_price and hand.get_child_count() <= 7:
		GameManager.spend_money(GameManager.card_buy_price)
		GameManager.spawnRandomCards(1, "demon")
	else:
		show_balance_unavailable_warning()


func _on_discard_button_pressed():
	if GameManager.selectedAbility:
		return

	if hand.get_child_count() >= 1:
		GameManager.add_money((GameManager.card_buy_price / 2) * hand.get_child_count())
		discard_hand()


func _on_swap_button_pressed():
	if GameManager.selectedAbility:
		return

	var cardsCount = hand.get_child_count()
	if GameManager.player_balance >= GameManager.swap_hand_price and cardsCount >= 1:
		if swap_hand_ready:
			swap_hand_ready = false
			swap_hand_cooldown.restart()
			GameManager.spend_money(GameManager.swap_hand_price)
			discard_hand()
			GameManager.spawnRandomCards(cardsCount)
	else:
		show_balance_unavailable_warning()


############## Actions ##############

func discard_hand():
	if hand:
		for n in hand.get_children():
			n.queue_free()


func add_cards_to_players_hand(card):
	if hand:
		hand.add_child(card)


func show_balance_unavailable_warning():
	Events.emit_signal("play_denied_sound")
	var tw = create_tween()
	tw.tween_method(change_color, Color("000000"), Color("c50000"), .1).set_ease(Tween.EASE_IN)
	tw.tween_method(change_color, Color("c50000"), Color("000000"), .5).set_ease(Tween.EASE_OUT)

func change_color(color: Color):
	demonCardBuyPriceLabel.add_theme_color_override("font_outline_color", color)
	humanCardBuyPriceLabel.add_theme_color_override("font_outline_color", color)
	swapHandPriceLabel.add_theme_color_override("font_outline_color", color)
	playerBalanceLabel.add_theme_color_override("font_outline_color", color)


func update_ui():
	if playerBalanceLabel:
		playerBalanceLabel.text = str("$", GameManager.player_balance)
	if demonCardBuyPriceLabel:
		demonCardBuyPriceLabel.text = str("$", GameManager.card_buy_price)
	if humanCardBuyPriceLabel:
		humanCardBuyPriceLabel.text = str("$", GameManager.card_buy_price)
	if discardHandPriceLabel:
		discardHandPriceLabel.text = str("$", str((GameManager.card_buy_price / 2) * hand.get_child_count()))
	if swapHandPriceLabel:
		swapHandPriceLabel.text = str("$", GameManager.swap_hand_price)
	if matchTimeLabel:
		var minutes = str("0", int(matchTime / 60)) if int(matchTime / 60) < 10 else str(int(matchTime / 60))
		var seconds = str("0", int(int(matchTime) % 60)) if int(int(matchTime) % 60) < 10 else str(int(int(matchTime) % 60))
		matchTimeLabel.text = str(minutes, ":", seconds)
	if scoreboard:
		scoreboard.text =	str(GameManager.scoreboard["demon"], " vs ", GameManager.scoreboard["human"], "  ")

	if Engine.time_scale > 1:
		backButton.region_rect = Rect2(0, 192, 16, 16)
		pauseButton.region_rect = Rect2(16, 192, 16, 16)
		playButton.region_rect = Rect2(32, 192, 16, 16)
		forwardButton.region_rect = Rect2(48, 208, 16, 16)
	elif Engine.time_scale == 1:
		backButton.region_rect = Rect2(0, 192, 16, 16)
		pauseButton.region_rect = Rect2(16, 192, 16, 16)
		playButton.region_rect = Rect2(32, 208, 16, 16)
		forwardButton.region_rect = Rect2(48, 192, 16, 16)
	elif Engine.time_scale > 0 and Engine.time_scale < 1:
		backButton.region_rect = Rect2(0, 208, 16, 16)
		pauseButton.region_rect = Rect2(16, 192, 16, 16)
		playButton.region_rect = Rect2(32, 192, 16, 16)
		forwardButton.region_rect = Rect2(48, 192, 16, 16)
	else:
		backButton.region_rect = Rect2(0, 192, 16, 16)
		pauseButton.region_rect = Rect2(16, 208, 16, 16)
		playButton.region_rect = Rect2(32, 192, 16, 16)
		forwardButton.region_rect = Rect2(48, 192, 16, 16)

