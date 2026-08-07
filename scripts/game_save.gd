extends Node

## Autoload singleton: persiste em disco o progresso do jogo (GameData) —
## níveis de operadores/dígitos, range dos powerups e os atributos do
## jogador acumulados via powerups.
##
## O save só é escrito ao concluir uma fase (ver game.gd); se o jogador
## morrer antes de terminar, save() nunca é chamado e o progresso salvo
## anteriormente permanece intacto.

const SAVE_PATH := "user://game_save.dat"

func load_data() -> GameData:
	if not FileAccess.file_exists(SAVE_PATH):
		return GameData.new()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return GameData.new()
	var data = file.get_var()
	if typeof(data) != TYPE_DICTIONARY:
		return GameData.new()
	return GameData.from_dict(data)

func save(data: GameData) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_var(data.to_dict())
