extends RefCounted

class_name GameData

## Singleton para dados do jogo (salvar e carregar)

var operator_level: int = 1 #Operador desbloqueado (inicia em 1)
var digit_level: int = 4 #Digitos desbloqueados (inicia em 1 - 4)
var bonus_range: float = 4.0 #Limite do valor do powerup (Inicia em 4, progride na loja/fase)
var unlocked_phase: int = 1 #Fase inicial desbloqueada
var player: Dictionary = {}

#Valores padrões para exportação, caso não existam no Player
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

#Converte dados em dicionário
func to_dict() -> Dictionary:
	return {
		"operator_level": operator_level,
		"digit_level": digit_level,
		"bonus_range": bonus_range,
		"unlocked_phase": unlocked_phase,
		"player": player,
	}

#Carrega dados de um dicionário
static func from_dict(data: Dictionary) -> GameData:
	var result := GameData.new()
	result.operator_level = data.get("operator_level", result.operator_level)
	result.digit_level = data.get("digit_level", result.digit_level)
	result.bonus_range = data.get("bonus_range", result.bonus_range)
	result.unlocked_phase = int(data.get("unlocked_phase", result.unlocked_phase))
	result.player = data.get("player", {})
	return result
