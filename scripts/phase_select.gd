extends Control

const MainMenuScene := "res://scenes/main_menu.tscn"
const GameScene := "res://scenes/main.tscn"


const PHASE_PATHS := [
	"res://resources/phases/phase_01.tres",
	"res://resources/phases/phase_02.tres",
	"res://resources/phases/phase_03.tres",
	"res://resources/phases/phase_04.tres",
	"res://resources/phases/phase_05.tres",
]

const THUMB_SIZE := Vector2(320, 240)

## Cor aplicada sobre a miniatura de uma fase bloqueada (escurece).
const LOCKED_MODULATE := Color(0.35, 0.35, 0.4)
## Textura de cadeado sobreposta às fases bloqueadas. Se null, a fase
## bloqueada só escurece e mostra o texto.
const LOCK_TEXTURE: Texture2D = preload("res://assets/backgrounds/lock.png")

@onready var phase_list: HFlowContainer = %PhaseList

func _ready() -> void:
	var unlocked: int = GameSave.load_data().unlocked_phase
	for path in PHASE_PATHS:
		var phase: PhaseData = load(path)
		phase_list.add_child(_make_phase_button(phase, phase.phase_number <= unlocked))


func _make_phase_button(phase: PhaseData, unlocked: bool) -> Control:
	var button := TextureButton.new()
	button.custom_minimum_size = THUMB_SIZE
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
	button.texture_normal = phase.thumbnail
	button.disabled = not unlocked
	if unlocked:
		button.pressed.connect(_on_phase_button_pressed.bind(phase))
		button.mouse_entered.connect(func(): button.modulate = Color(1.2, 1.2, 1.2))
		button.mouse_exited.connect(func(): button.modulate = Color.WHITE)
		button.mouse_entered.connect(_on_thumb_hover.bind(button, 1.02))
		button.mouse_exited.connect(_on_thumb_hover.bind(button, 1.0))
	else:
		button.modulate = LOCKED_MODULATE

	var label:= Label.new()
	label.text = phase.phase_name if unlocked else "🔒 " + phase.phase_name
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_outline_color", Color.WHITE)
	label.add_theme_constant_override("outline_size", 6)
	button.add_child(label)

	# Cadeado cobrindo o botão inteiro (só quando bloqueada e houver textura).
	if not unlocked and LOCK_TEXTURE != null:
		var lock := TextureRect.new()
		lock.texture = LOCK_TEXTURE
		lock.set_anchors_preset(Control.PRESET_FULL_RECT)
		lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lock.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(lock)
	return button


func _on_phase_button_pressed(phase: PhaseData) -> void:
	GameConfig.select_phase(phase)
	get_tree().change_scene_to_file(GameScene)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MainMenuScene)
	
func _on_thumb_hover(button: TextureButton, target: float) -> void:
	var tw := create_tween().set_ease(Tween.EASE_OUT)
	tw.tween_property(button, "scale", Vector2(target, target), 0.1)
