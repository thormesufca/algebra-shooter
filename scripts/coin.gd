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

const CoinSfx := preload("res://assets/sounds/effects/Coin.wav")
## Variação de pitch por moeda coletada, pra várias moedas seguidas não soarem sempre idênticas.
const COIN_PITCH_VARIATION := 0.1

func _ready() -> void:
	var nodes := get_tree().get_nodes_in_group("player")
	if nodes.size() > 0:
		player = nodes[0] as Player
	_start_lifetime()

#Calcular a duração da moeda na cena
func _start_lifetime() -> void:
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
		var pitch := randf_range(1.0 - COIN_PITCH_VARIATION, 1.0 + COIN_PITCH_VARIATION)
		Sfx.play(CoinSfx, 0.0, "Master", pitch)
		collect(body)

#Função separada para coletar moeda. Permite que no final da fase, após matar o chefão, a recompensa seja recolhida independentemente da distância
func collect(collector: Node) -> void:
	if not _alive:
		return
	_alive = false
	collector.add_gold(value)
	queue_free()
