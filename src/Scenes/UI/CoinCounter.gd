extends Node

var coins = 0
var offset = 0

const SMOOTH_FACTOR = 5

func _ready():
	offset = 100
	$CoinCounter/CoinCount.text = "0"

func _process(_delta):
	$CoinCounter.rect_position.x = get_viewport().size.x + offset
	if offset < 2:
		offset = 0
	else: offset *= 0.8
	$CoinCounter/CoinCount.rect_size.x = 0
	$CoinCounter/CoinCount.rect_position.x = -34 - ($CoinCounter/CoinCount.rect_size.x * 0.5)
	$CoinCounter/CoinCount.text = str(coins)
