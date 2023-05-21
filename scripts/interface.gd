extends CanvasLayer

func _on_button_pressed():
	GameManager.increase_engine_speed()


func _on_button_2_pressed():
	GameManager.decrease_engine_speed()
