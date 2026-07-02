extends Control

## process_mode precisa ser Always (definido na cena) pra este nó continuar
## recebendo input mesmo com a árvore pausada — senão nunca dá pra despausar.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		visible = get_tree().paused
		get_viewport().set_input_as_handled()
