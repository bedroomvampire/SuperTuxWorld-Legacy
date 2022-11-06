# Code from Digital Student
extends "res://Assets/Coins/Coins Counter.gd"

export var point = 1

func _on_Coin_body_entered(body):
	if body.name == "Player":
		get_node("/root/Coin UI/Node/Icon/Counter").coins += point
		emit_signal("coin_sound")
		queue_free()
