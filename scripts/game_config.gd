extends Node

## Singleton: de configuração base do jogo.

var operator_level: int = 1
var digit_level: int = 4
var range_value: float = 4.0

var configured: bool = false

#Se vem da seleção de fase, se não roda a padrão do game.gd (rodar no editor)
var selected_phase: PhaseData = null

func configure(new_operator_level: int, new_digit_level: int, new_range: float) -> void:
	operator_level = new_operator_level
	digit_level = new_digit_level
	range_value = new_range
	configured = true

func select_phase(phase: PhaseData) -> void:
	selected_phase = phase
