extends Node

func increase_engine_speed():
	Engine.time_scale = Engine.time_scale * 2

func decrease_engine_speed():
	Engine.time_scale = Engine.time_scale / 2
