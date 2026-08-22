extends Control

#Configurações da Loja

const MainMenuScene := "res://scenes/main_menu.tscn"

const SHIELD_BASE_LEVEL := 3
const SHIELD_BASE_COST := 400 #Custo base para escudo inicial extra
const SHIELD_COST_STEP := 2 #Potência para incremento dos próximos escudos

const ARROW_BASE_LEVEL := 1
const ARROW_BASE_COST := 1000 #Custo base para flecha extra
const ARROW_COST_STEP := 3 #Potência para incremento das próximas flechas

## Custo para desbloquear cada dígito.
const DIGIT_COSTS := {5: 200, 6: 300, 7: 450, 8: 650, 9: 1000}
const MAX_DIGIT_LEVEL := 9

## Custo para desbloquear cada nível de operador (chave = operator_level alvo).
const OPERATOR_COSTS := {2: 900, 3: 1800}
const MAX_OPERATOR_LEVEL := 3
const OPERATOR_NAMES := {1: "+ -", 2: "+ - × ÷", 3: "+ - × ÷ ^ √"}

var _data: GameData

@onready var gold_value: Label = %GoldValue
@onready var shield_info: Label = %ShieldInfo
@onready var shield_cost: Label = %ShieldCost
@onready var shield_buy_button: Button = %ShieldBuyButton
@onready var arrow_info: Label = %ArrowInfo
@onready var arrow_cost: Label = %ArrowCost
@onready var arrow_buy_button: Button = %ArrowBuyButton
@onready var digit_info: Label = %DigitInfo
@onready var digit_cost: Label = %DigitCost
@onready var digit_buy_button: Button = %DigitBuyButton
@onready var operator_info: Label = %OperatorInfo
@onready var operator_cost: Label = %OperatorCost
@onready var operator_buy_button: Button = %OperatorBuyButton
@onready var status_label: Label = %StatusLabel


#Carrega os dados do save
func _ready() -> void:
	_data = GameSave.load_data()
	_refresh()

#Ouro do jogador
func _gold() -> int:
	return int(_data.player_field("gold"))

#Atualiza os dados com o ouro gasto
func _spend(cost: int) -> bool:
	if _gold() < cost:
		status_label.text = "Ouro insuficiente."
		return false
	_data.set_player_field("gold", _gold() - cost)
	return true

#Salva os novos dados
func _save_and_refresh() -> void:
	GameSave.save(_data)
	_refresh()

func _shield_level() -> int:
	return int(floor(_data.player_field("max_shield")))

#Calcula o custo de liberar o próximo escudo (Custo base * (Delta ^ Potência (2)))
func _shield_next_cost() -> int:
	return SHIELD_BASE_COST * (_shield_level() - SHIELD_BASE_LEVEL + 1) ** SHIELD_COST_STEP

func _arrow_level() -> int:
	return int(floor(_data.player_field("bullet_amount_progress")))

#Calcula o custo de liberar a próxima flecha (Custo base * (Delta ^ Potência (2)))
func _arrow_next_cost() -> int:
	return ARROW_BASE_COST * (_arrow_level() - ARROW_BASE_LEVEL + 1) ** ARROW_COST_STEP

#Atualiza os dados na tela
func _refresh() -> void:
	gold_value.text = str(_gold())

	var shield_level := _shield_level()
	var shield_price := _shield_next_cost()
	shield_info.text = "Vidas (escudo máx.): %d" % shield_level
	shield_cost.text = "%d ouro" % shield_price
	shield_buy_button.disabled = _gold() < shield_price

	var arrow_level := _arrow_level()
	var arrow_price := _arrow_next_cost()
	arrow_info.text = "Flechas: %d" % arrow_level
	arrow_cost.text = "%d ouro" % arrow_price
	arrow_buy_button.disabled = _gold() < arrow_price

	var next_digit := _data.digit_level + 1
	if next_digit > MAX_DIGIT_LEVEL:
		digit_info.text = "Dígitos: até %d (máximo)" % _data.digit_level
		digit_cost.text = "--"
		digit_buy_button.disabled = true
	else:
		var digit_price: int = DIGIT_COSTS[next_digit]
		digit_info.text = "Dígitos: até %d (próximo: %d)" % [_data.digit_level, next_digit]
		digit_cost.text = "%d ouro" % digit_price
		digit_buy_button.disabled = _gold() < digit_price

	var next_operator := _data.operator_level + 1
	if next_operator > MAX_OPERATOR_LEVEL:
		operator_info.text = "Operadores: nível %d (%s) — máximo" % [_data.operator_level, OPERATOR_NAMES.get(_data.operator_level, "")]
		operator_cost.text = "--"
		operator_buy_button.disabled = true
	else:
		var operator_price: int = OPERATOR_COSTS[next_operator]
		operator_info.text = "Operadores: nível %d (%s) → nível %d (%s)" % [_data.operator_level, OPERATOR_NAMES.get(_data.operator_level, ""), next_operator, OPERATOR_NAMES.get(next_operator, "")]
		operator_cost.text = "%d ouro" % operator_price
		operator_buy_button.disabled = _gold() < operator_price

#Comprar escudos
func _on_shield_buy_button_pressed() -> void:
	var cost := _shield_next_cost()
	if not _spend(cost):
		return
	_data.set_player_field("max_shield", _data.player_field("max_shield") + 1.0)
	status_label.text = "Vida extra adquirida!"
	_save_and_refresh()

#Comprar flechas
func _on_arrow_buy_button_pressed() -> void:
	var cost := _arrow_next_cost()
	if not _spend(cost):
		return
	_data.set_player_field("bullet_amount_progress", _data.player_field("bullet_amount_progress") + 1.0)
	status_label.text = "Flecha extra adquirida!"
	_save_and_refresh()

#Comprar dígito
func _on_digit_buy_button_pressed() -> void:
	var next_digit := _data.digit_level + 1
	if next_digit > MAX_DIGIT_LEVEL:
		return
	var cost: int = DIGIT_COSTS[next_digit]
	if not _spend(cost):
		return
	_data.digit_level = next_digit
	status_label.text = "Dígito %d desbloqueado!" % next_digit
	_save_and_refresh()

#Comprar Operador
func _on_operator_buy_button_pressed() -> void:
	var next_operator := _data.operator_level + 1
	if next_operator > MAX_OPERATOR_LEVEL:
		return
	var cost: int = OPERATOR_COSTS[next_operator]
	if not _spend(cost):
		return
	_data.operator_level = next_operator
	status_label.text = "Operadores nível %d desbloqueados!" % next_operator
	_save_and_refresh()

#Voltar
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MainMenuScene)
