extends Label

var coins = 0

func _ready():
	text = String(coins)

func _collect():
	coins = coins + 1
	_ready()
