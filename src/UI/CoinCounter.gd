extends Node

var coins = 0

const SMOOTH_FACTOR = 5

func _ready():
	$CoinCounter/CoinCount.text = "0"

func _physics_process(delta):
	$CoinCounter/CoinCount.rect_size.x = 0
	$CoinCounter/CoinCount.rect_position.x = -34 - ($CoinCounter/CoinCount.rect_size.x * 0.5)
	$CoinCounter/CoinCount.text = str(coins)