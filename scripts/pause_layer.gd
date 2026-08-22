extends Control

# Tela de Pause

const PhaseSelectScene := "res://scenes/phase_select.tscn"
const MainMenuScene := "res://scenes/main_menu.tscn"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()
		get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused

#Despausar
func _on_resume_button_pressed() -> void:
	_toggle_pause()

#Voltar para seleção de fase
func _on_phase_select_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(PhaseSelectScene)

#Voltar para menu inicial
func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MainMenuScene)
