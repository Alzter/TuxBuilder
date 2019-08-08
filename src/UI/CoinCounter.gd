extends Node

var coins = 0

func _ready():
	$CoinCounter/CoinCount.text = "0"

func _update_coin_count():
	$CoinCounter/CoinCount.text = str(coins)