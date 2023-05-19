# Code from Digital Student
extends Node

var coins = 0 setget set_coins

func set_coins(value):
	coins = value
	get_node("/root/Coin UI/Node/Counter").set_text(coins)
