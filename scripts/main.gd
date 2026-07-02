extends Control

const GAME_OVER_RESTART_DELAY := 3.0

@onready var hud_left: PanelContainer = %HUDLeft
@onready var hud_right: PanelContainer = %HUDRight
@onready var game: Node2D = $HBoxContainer/ViewportContainer/SubViewport/Game
@onready var game_over_layer: TextureRect = %GameOverLayer

var player: Player = null

func _ready() -> void:
	if game.phase != null:
		hud_right.update_phase({"operadores": game.phase.operators_unlocked})

func _process(_delta: float) -> void:
	if player == null:
		var nodes := get_tree().get_nodes_in_group("player")
		if nodes.size() > 0:
			player = nodes[0] as Player
			player.died.connect(_on_player_died)
		return

	hud_left.update_stats({
		"dano": player.damage,
		"velocidade": player.speed,
		"cadencia": player.get_node("ShootTimer").wait_time,
		"escudo": player.shield,
		"escudo_max": player.max_shield,
		"magnetismo": player.magnet,
		"pontuacao": player.score,
		"multiplicador": player.multiplicador
	})

func _on_player_died() -> void:
	game_over_layer.visible = true
	get_tree().paused = true
	await get_tree().create_timer(GAME_OVER_RESTART_DELAY).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()
