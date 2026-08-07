extends Node2D

## Aviso "BOSS!" mostrado por DURATION segundos antes do boss da fase
## aparecer (ver game.gd/_spawn_boss). Mesmo padrão de tween de
## powerup_result_label.gd, sem a parte de ícone.

@onready var label: Label = $Label

const DURATION := 2.5
const START_SCALE := 0.6
const PEAK_SCALE := 1.8
const FADE_START_RATIO := 0.6

func _ready() -> void:
	scale = Vector2.ONE * START_SCALE
	var grow_tween := create_tween()
	grow_tween.tween_property(self, "scale", Vector2.ONE * PEAK_SCALE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var fade_tween := create_tween()
	fade_tween.tween_interval(DURATION * FADE_START_RATIO)
	fade_tween.tween_property(label, "modulate:a", 0.0, DURATION * (1.0 - FADE_START_RATIO))

	await get_tree().create_timer(DURATION).timeout
	queue_free()
