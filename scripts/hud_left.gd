extends PanelContainer

## Selecione qual quadrante do spritesheet (Shield.png, grade 2x2) usar
## clicando neste campo no Inspector — abre o editor de região de textura.
@export var shield_icon: Texture2D = preload("res://resources/ui/shield_icon.tres")
const SHIELD_ICON_SIZE := Vector2(20, 20)

@onready var damage_label: Label = %DamageValue
@onready var speed_label: Label = %SpeedValue
@onready var fire_rate_label: Label = %FireRateValue
@onready var shield_icons: HBoxContainer = %ShieldIcons
@onready var shield_max_label: Label = %ShieldMaxValue
@onready var magnet_label: Label = %MagnetValue
@onready var score_label: Label = %ScoreValue
@onready var multiplicador_label: Label = %MultiplicadorValue

## Tamanho de fonte do multiplicador: cresce com o valor, limitado a um teto
## pra não estourar a largura fixa do painel (330px).
const MULTIPLIER_BASE_FONT_SIZE := 20
const MULTIPLIER_FONT_STEP := 6
const MULTIPLIER_FONT_MAX := 48

func update_stats(stats: Dictionary) -> void:
	damage_label.text = str(stats.get("dano", 0))
	speed_label.text = str(stats.get("velocidade", 0))
	fire_rate_label.text = "%.2fs" % stats.get("cadencia", 0.0)
	_update_shield_icons(int(stats.get("escudo", 0)))
	shield_max_label.text = str(int(floor(stats.get("escudo_max", 0.0))))
	magnet_label.text = "%.1f" % stats.get("magnetismo", 1.0)
	score_label.text = str(stats.get("pontuacao", 0))
	_update_multiplier_label(int(stats.get("multiplicador", 1)))

func _update_multiplier_label(value: int) -> void:
	multiplicador_label.text = str(value)
	var size := clampi(
		MULTIPLIER_BASE_FONT_SIZE + (value - 1) * MULTIPLIER_FONT_STEP,
		MULTIPLIER_BASE_FONT_SIZE,
		MULTIPLIER_FONT_MAX
	)
	multiplicador_label.add_theme_font_size_override("font_size", size)

func _update_shield_icons(count: int) -> void:
	var current := shield_icons.get_child_count()
	if current == count:
		return
	for child in shield_icons.get_children():
		child.queue_free()
	for i in range(count):
		var icon := TextureRect.new()
		icon.texture = shield_icon
		icon.custom_minimum_size = SHIELD_ICON_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		shield_icons.add_child(icon)
