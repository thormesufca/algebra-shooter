extends Node2D

##Cena para o aviso de "BOSS" antes de iniciar a batalha
signal finished

@onready var label: Label = $Label

const DURATION := 2.5
const START_SCALE := 0.6
const PEAK_SCALE := 2.8
const FADE_START_RATIO := 0.6
#Som padrão para tocar (pode ser sobrescrito em cada fase)
const sfxWarning = preload("res://assets/sounds/effects/Alert.wav")
@export var sfx_override: AudioStream = null

func _ready() -> void:
	scale = Vector2.ONE * START_SCALE
	var grow_tween := create_tween()
	grow_tween.tween_property(self, "scale", Vector2.ONE * PEAK_SCALE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var fade_tween := create_tween()
	fade_tween.tween_interval(DURATION * FADE_START_RATIO)
	fade_tween.tween_property(label, "modulate:a", 0.0, DURATION * (1.0 - FADE_START_RATIO))
	var sfx_player := Sfx.play(sfx_override if sfx_override != null else sfxWarning)
	await get_tree().create_timer(DURATION).timeout

	if sfx_player != null and is_instance_valid(sfx_player) and sfx_player.playing: #Aguardar tocar o som antes de emitir que término
		await sfx_player.finished
	finished.emit()
	queue_free()
