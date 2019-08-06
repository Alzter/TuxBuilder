extends HBoxContainer

var coins = 0

func _ready():
	$CoinCount.text = "0"

func _update_coin_count():
	$CoinCount.text = str(coins)