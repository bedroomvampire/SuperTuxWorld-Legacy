# Code from Digital Student
extends Area

signal coin_collected
export var point = 1

func _on_Coin_body_entered(body):
	if body.name == "Player":
		#get_node("/root/Coin/Node").coins += point
		emit_signal("coin_collected")
		queue_free()
