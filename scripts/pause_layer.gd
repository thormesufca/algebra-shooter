extends Control

## process_mode precisa ser Always (definido na cena) pra este nó continuar
## recebendo input mesmo com a árvore pausada — senão nunca dá pra despausar.

const PhaseSelectScene := "res://scenes/phase_select.tscn"
const MainMenuScene := "res://scenes/main_menu.tscn"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()
		get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused

func _on_resume_button_pressed() -> void:
	_toggle_pause()

## Sai da fase em andamento sem salvar (o progresso só é persistido ao
## concluir a fase — ver game.gd._finish_phase()). O tree precisa ser
## despausado antes de trocar de cena, senão a próxima cena carrega travada.
func _on_phase_select_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(PhaseSelectScene)

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MainMenuScene)
