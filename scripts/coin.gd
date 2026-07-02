extends Area2D

@export var value: int = 1
## Raio e velocidade de atração com magnet = 1.0 (valor base do Player).
@export var base_pickup_radius: float = 80.0
@export var base_attract_speed: float = 300.0

const LIFETIME := 10.0
const BLINK_DURATION := 3.0
const BLINK_INTERVAL := 0.15

var player: Player = null
var _alive := true

func _ready() -> void:
	var nodes := get_tree().get_nodes_in_group("player")
	if nodes.size() > 0:
		player = nodes[0] as Player
	_start_lifetime()

func _start_lifetime() -> void:
	await get_tree().create_timer(LIFETIME - BLINK_DURATION).timeout
	if not _alive:
		return
	var elapsed := 0.0
	while elapsed < BLINK_DURATION and _alive:
		visible = not visible
		await get_tree().create_timer(BLINK_INTERVAL).timeout
		elapsed += BLINK_INTERVAL
	if _alive:
		queue_free()

func _process(delta: float) -> void:
	if player == null:
		return
	var to_player := player.global_position - global_position
	var radius := base_pickup_radius * player.magnet
	if to_player.length() <= radius:
		var direction := to_player.normalized()
		global_position += direction * base_attract_speed * player.magnet * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("add_coins"):
		_alive = false
		body.add_coins(value)
		queue_free()
