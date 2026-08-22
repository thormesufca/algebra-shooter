extends Node

## Singleton para salvar em disco os dados do jogo (atributos do jogador e desbloqueios (fase, operadores, dígitos))

const SAVE_DIR := "res://save"
const SAVE_PATH := "res://save/game_save.json"

func _ready() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save(GameData.new())

func load_data() -> GameData:
	if not FileAccess.file_exists(SAVE_PATH):
		return GameData.new()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return GameData.new()
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return GameData.new()
	return GameData.from_dict(parsed)

func save(data: GameData) -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data.to_dict(), "\t"))
