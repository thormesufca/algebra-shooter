extends Control

#Tela com resultados após finalizar uma fase

const MainMenuScene := "res://scenes/main_menu.tscn"

const COLOR_POSITIVE := Color(0.3, 0.85, 0.35) #Verde
const COLOR_NEGATIVE := Color(0.9, 0.25, 0.25) #Vermelho
const COLOR_ZERO := Color(0.7, 0.7, 0.7) #Cinza

@onready var damage_row: HBoxContainer = %DamageRow
@onready var speed_row: HBoxContainer = %SpeedRow
@onready var fire_rate_row: HBoxContainer = %FireRateRow
@onready var magnet_row: HBoxContainer = %MagnetRow

#Configurar os ícones dos powerups coletáveis
func _ready() -> void:
	_set_row_icon(damage_row, PowerupData.Attribute.DAMAGE)
	_set_row_icon(speed_row, PowerupData.Attribute.SPEED)
	_set_row_icon(fire_rate_row, PowerupData.Attribute.FIRE_RATE)
	_set_row_icon(magnet_row, PowerupData.Attribute.MAGNET)


func show_results(before: Dictionary, after: Dictionary) -> void:
	_show_delta(damage_row, _field(before, "damage"), _field(after, "damage"), "%.2f")
	_show_delta(speed_row, _field(before, "speed"), _field(after, "speed"), "%.0f")
	_show_delta(
		fire_rate_row,
		_shots_per_second(_field(before, "fire_rate")),
		_shots_per_second(_field(after, "fire_rate")),
		"%.2f/s"
	)
	_show_delta(magnet_row, _field(before, "magnet"), _field(after, "magnet"), "%.1f")


func _field(data: Dictionary, key: String) -> float:
	return data.get(key, GameData.DEFAULT_PLAYER.get(key, 0.0))

#Função para converter o timer de tiro em cadência de tiros por segundo
func _shots_per_second(wait_time: float) -> float:
	return 1.0 / wait_time if wait_time > 0.0 else 0.0

#Montar as linhas e valores dos labels de cada atributo
func _show_delta(row: HBoxContainer, before_value: float, after_value: float, format: String) -> void:
	var label: Label = row.get_node("Value")
	label.add_theme_font_size_override("font_size", 26)
	var delta := after_value - before_value
	var sign_prefix := "+" if delta > 0 else ""
	label.text = "%s → %s (%s%s)" % [
		format % before_value,
		format % after_value,
		sign_prefix,
		format % delta,
	]
	if delta > 0:
		label.modulate = COLOR_POSITIVE
	elif delta < 0:
		label.modulate = COLOR_NEGATIVE
	else:
		label.modulate = COLOR_ZERO

#Adicionar o ícone
func _set_row_icon(row: HBoxContainer, attribute: PowerupData.Attribute) -> void:
	var icon: TextureRect = row.get_node("Icon")
	var data := PowerupData.new()
	data.attribute = attribute
	icon.texture = data.get_sprite_frames().get_frame_texture("animated", 0)

#Voltar para menu principal ao finalizar fase
func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MainMenuScene)
