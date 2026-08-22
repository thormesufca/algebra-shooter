extends Camera2D

signal phase_completed

@export var scroll_speed: float = 60.0
@export var travel_distance: float = 5000.0

var distance_traveled: float = 0.0
var _completed: bool = false
var _player: Player = null

func _ready() -> void:
	var nodes := get_tree().get_nodes_in_group("player")
	if nodes.size() > 0:
		_player = nodes[0] as Player
		position = _player.global_position
	else:
		push_error("Jogador não encontrado")

func _process(delta: float) -> void:
	if _completed or (_player != null and _player.is_dead): # Para de se mover quando o player morre
		return
	var step := scroll_speed * delta
	position.y -= step
	distance_traveled += step
	if distance_traveled >= travel_distance: # Se andou até o final da fase, emite sinal de que completou a fase
		distance_traveled = travel_distance
		_completed = true
		phase_completed.emit()

func configure(new_speed: float, new_distance: float) -> void:
	scroll_speed = new_speed
	travel_distance = new_distance
