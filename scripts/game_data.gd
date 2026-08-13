extends RefCounted

class_name GameData

## Estrutura com todo o progresso persistido entre fases: os dados do próprio
## jogo (níveis de operadores/dígitos desbloqueados e o range dos powerups)
## mais os dados do jogador (atributos acumulados via powerups), agrupados
## no campo `player`. Ver GameSave para a persistência em disco.

var operator_level: int = 1
var digit_level: int = 4
var bonus_range: float = 4.0
## Maior fase liberada (jogável). A fase 1 está sempre disponível; concluir a
## fase N libera a N+1 (ver game.gd/_finish_phase).
var unlocked_phase: int = 1
var player: Dictionary = {}

## Espelha os @export defaults de player.gd — usado como fallback quando uma
## chave ainda não existe em `player` (ex: antes da primeira fase concluída),
## e por telas sem uma instância de Player em cena, como a loja.
const DEFAULT_PLAYER := {
	"damage": 4.0,
	"speed": 400.0,
	"fire_rate": 0.5,
	"max_shield": 3.0,
	"bullet_amount_progress": 1.0,
	"magnet": 1.0,
	"score": 0,
	"gold": 0,
}

func player_field(key: String) -> float:
	return player.get(key, DEFAULT_PLAYER.get(key, 0.0))

func set_player_field(key: String, value) -> void:
	player[key] = value

func to_dict() -> Dictionary:
	return {
		"operator_level": operator_level,
		"digit_level": digit_level,
		"bonus_range": bonus_range,
		"unlocked_phase": unlocked_phase,
		"player": player,
	}

static func from_dict(data: Dictionary) -> GameData:
	var result := GameData.new()
	result.operator_level = data.get("operator_level", result.operator_level)
	result.digit_level = data.get("digit_level", result.digit_level)
	result.bonus_range = data.get("bonus_range", result.bonus_range)
	result.unlocked_phase = int(data.get("unlocked_phase", result.unlocked_phase))
	result.player = data.get("player", {})
	return result
