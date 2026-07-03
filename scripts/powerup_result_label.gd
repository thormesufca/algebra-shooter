extends Node2D

## Popup que mostra o resultado percentual de um powerup coletado: aparece
## grande e encolhe/desaparece ao longo de DURATION segundos, como um
## indicador de dano.

@onready var label: Label = $Label
@onready var icon: AnimatedSprite2D = $Icon

const DURATION := 1.0
const START_SCALE := 4.2
const END_SCALE := 0.7
const FADE_START_RATIO := 0.6
## Mesmo tamanho alvo usado no card do powerup (ver power.gd), pra manter a
## identidade visual do ícone consistente entre card e popup.
const TARGET_ICON_SIZE := 24.0

const COLOR_POSITIVE := Color(0.3, 0.85, 0.35)
const COLOR_NEGATIVE := Color(0.9, 0.25, 0.25)
const COLOR_ZERO := Color(0.7, 0.7, 0.7)

## `data` fornece o ícone; `effective_value` é o percentual efetivamente
## aplicado ao atributo (data.result * multiplicador do player), que pode
## divergir do resultado bruto da expressão.
func setup(data: PowerupData, multiplier: int) -> void:
	var value := data.result  * multiplier
	var sign_prefix := "+" if value > 0 else ""
	label.text = "%s%.1f%%" % [sign_prefix,value]
	if value > 0:
		label.modulate = COLOR_POSITIVE
	elif value < 0:
		label.modulate = COLOR_NEGATIVE
	else:
		label.modulate = COLOR_ZERO

	icon.sprite_frames = data.get_sprite_frames()
	icon.animation = "animated"
	icon.play()
	var frame_size := icon.sprite_frames.get_frame_texture("animated", 0).get_size()
	var uniform_scale := TARGET_ICON_SIZE / frame_size.x
	icon.scale = Vector2(uniform_scale, uniform_scale)

func _ready() -> void:
	scale = Vector2.ONE * START_SCALE
	var shrink_tween := create_tween()
	shrink_tween.tween_property(self, "scale", Vector2.ONE * END_SCALE, DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var fade_tween := create_tween()
	fade_tween.tween_interval(DURATION * FADE_START_RATIO)
	fade_tween.tween_property(label, "modulate:a", 0.0, DURATION * (1.0 - FADE_START_RATIO))

	await get_tree().create_timer(DURATION).timeout
	queue_free()
