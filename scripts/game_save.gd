extends Node

## Autoload singleton: persiste em disco o progresso do jogo (GameData) —
## níveis de operadores/dígitos, range dos powerups e os atributos do
## jogador acumulados via powerups.
##
## Fica em res://save/, dentro do projeto, em JSON legível — pensado pra
## facilitar inspecionar/editar o save durante o desenvolvimento. Por isso a
## pasta está no .gitignore (não deve ir pro repositório) e o arquivo é
## recriado automaticamente ao lançar o jogo caso não exista.
##
## O save só é escrito ao concluir uma fase (ver game.gd); se o jogador
## morrer antes de terminar, save() nunca é chamado e o progresso salvo
## anteriormente permanece intacto.

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
