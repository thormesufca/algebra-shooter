extends Node

## Autoload singleton: permite que outra cena (menu, seleção de fase, etc.)
## configure os parâmetros de geração de expressões antes do jogo iniciar,
## em vez de depender apenas dos valores exportados na cena Game.

var operator_level: int = 1
var digit_level: int = 4
var range_value: float = 4.0

## True assim que configure() é chamado por uma cena externa (ex: menu).
## Enquanto false, game.gd usa seus próprios valores @export como default.
var configured: bool = false

func configure(new_operator_level: int, new_digit_level: int, new_range: float) -> void:
	operator_level = new_operator_level
	digit_level = new_digit_level
	range_value = new_range
	configured = true
