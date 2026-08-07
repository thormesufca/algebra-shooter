extends Control

const MainMenuScene := "res://scenes/main_menu.tscn"
const GameScene := "res://scenes/main.tscn"

## Fases jogáveis, na ordem de exibição/dificuldade.
const PHASE_PATHS := [
	"res://resources/phases/phase_01.tres",
	"res://resources/phases/phase_02.tres",
	"res://resources/phases/phase_03.tres",
	"res://resources/phases/phase_04.tres",
	"res://resources/phases/phase_05.tres",
]

@onready var phase_list: VBoxContainer = %PhaseList

func _ready() -> void:
	for path in PHASE_PATHS:
		var phase: PhaseData = load(path)
		var button := Button.new()
		button.text = phase.phase_name
		button.pressed.connect(_on_phase_button_pressed.bind(phase))
		phase_list.add_child(button)

func _on_phase_button_pressed(phase: PhaseData) -> void:
	GameConfig.select_phase(phase)
	get_tree().change_scene_to_file(GameScene)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MainMenuScene)
