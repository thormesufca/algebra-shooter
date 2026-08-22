extends Control

const GAME_OVER_RESTART_DELAY := 3.0
const PhaseSelectScene := "res://scenes/phase_select.tscn"

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
		var r: float = game._effective_range()
		hud_right.update_phase({"operadores": PowerupGenerator.describe_operators(game.operator_level), "limite_upgrade": "±%d" % r, "upgrades": game.digit_level})
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
	var tree := get_tree()
	tree.paused = true
	await tree.create_timer(GAME_OVER_RESTART_DELAY).timeout
	tree.paused = false
	if is_inside_tree(): #Volta pra seleção de fase ao morrer
		tree.change_scene_to_file(PhaseSelectScene)
