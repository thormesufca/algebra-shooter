extends Control

const PhaseSelectScene := "res://scenes/phase_select.tscn"
const ShopScene := "res://scenes/shop.tscn"

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(PhaseSelectScene)

func _on_shop_button_pressed() -> void:
	get_tree().change_scene_to_file(ShopScene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
