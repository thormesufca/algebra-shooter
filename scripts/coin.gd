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
	# Guarda a SceneTree numa variável local: se a fase terminar com sucesso
	# enquanto esta moeda ainda está na tela (ver game.gd._finish_phase()), a
	# cena troca para o menu e este nó sai da árvore — get_tree() passaria a
	# retornar null nos awaits seguintes.
	var tree := get_tree()
	await tree.create_timer(LIFETIME - BLINK_DURATION).timeout
	if not _alive or not is_inside_tree():
		return
	var elapsed := 0.0
	while elapsed < BLINK_DURATION and _alive:
		visible = not visible
		await tree.create_timer(BLINK_INTERVAL).timeout
		if not is_inside_tree():
			return
		elapsed += BLINK_INTERVAL
	if _alive and is_inside_tree():
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
	if body.is_in_group("player") and body.has_method("add_gold"):
		collect(body)

## Coleta forçada, sem exigir colisão — usada por game.gd para recolher
## moedas restantes quando a fase termina antes do jogador chegar até elas.
func collect(collector: Node) -> void:
	if not _alive:
		return
	_alive = false
	collector.add_gold(value)
	queue_free()
