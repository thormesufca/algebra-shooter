extends Control

const GAME_OVER_RESTART_DELAY := 3.0

@onready var hud_left: PanelContainer = %HUDLeft
@onready var hud_right: PanelContainer = %HUDRight
@onready var game: Node2D = $HBoxContainer/ViewportContainer/SubViewport/Game
@onready var game_over_layer: TextureRect = %GameOverLayer
@onready var phase_results_layer: Control = %PhaseResultsLayer
@onready var win_sound: AudioStreamPlayer = %WinSound
@onready var lose_sound: AudioStreamPlayer = %LoseSound

var player: Player = null

func _ready() -> void:
	if game.phase != null:
		hud_right.update_phase({"operadores": game.phase.operators_unlocked, "limite_upgrade": "[-%d, %d]" % [game.bonus_range, game.bonus_range], "upgrades": game.digit_level})
	game.phase_results.connect(_on_phase_results)

func _process(_delta: float) -> void:
	if player == null:
		var nodes := get_tree().get_nodes_in_group("player")
		if nodes.size() > 0:
			player = nodes[0] as Player
			player.died.connect(_on_player_died)
		return

	if game.camera != null and game.camera.travel_distance > 0.0:
		var percent :float = game.camera.distance_traveled / game.camera.travel_distance * 100.0
		hud_right.update_phase_progress(percent)
		hud_right.update_debug_distance(game.camera.distance_traveled, game.camera.travel_distance)

	hud_left.update_stats({
		"dano": player.damage,
		"velocidade": player.speed,
		"cadencia": player.get_node("ShootTimer").wait_time,
		"escudo": player.shield,
		"escudo_max": player.max_shield,
		"arrow_max": player.bullet_amount_progress,
		"magnetismo": player.magnet,
		"pontuacao": player.score,
		"multiplicador": player.multiplicador,
		"gold": player.gold
	})

func _on_phase_results(before: Dictionary, after: Dictionary) -> void:
	get_tree().paused = true
	win_sound.play()
	phase_results_layer.visible = true
	phase_results_layer.show_results(before, after)

func _on_player_died() -> void:
	game_over_layer.visible = true
	lose_sound.play()
	# Guarda a SceneTree numa variável local: se a fase terminar com sucesso
	# enquanto este await ainda está suspenso (ver game.gd._finish_phase()),
	# a cena troca para o menu e este nó sai da árvore — get_tree() passaria
	# a retornar null.
	var tree := get_tree()
	tree.paused = true
	await tree.create_timer(GAME_OVER_RESTART_DELAY).timeout
	tree.paused = false
	if is_inside_tree():
		tree.reload_current_scene()
