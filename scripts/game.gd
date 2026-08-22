extends Node2D

#Sinal para calcular o resultado da fase (delta de atributos no início e no final da fase)
signal phase_results(before: Dictionary, after: Dictionary)

@export var enemy_scene: PackedScene
@export var power_scene: PackedScene
@export var powerup_enemy_index: int = 5
@export var phase: PhaseData
@export var operator_level: int = 1
@export var digit_level: int = 4
@export var bonus_range: float = 4
@export var audio_player: AudioStreamPlayer


var _spawn_count: int = 0
var _current_stage: SpawnStage = null
var _enemy_pool: Array[PackedScene] = []
var boss_scene: PackedScene = null

var _player_died: bool = false #Ver se jogador morreu
var _phase_start_player: Dictionary = {} #Atributos do jogador ao iniciar a fase

@onready var camera: Camera2D = $Camera

func _on_spawn_timer_timeout() -> void:
	_update_spawn_stage()
	_spawn_count += 1

	var enemy: Enemy = _pick_enemy_scene().instantiate()
	enemy.global_position = _get_spawn_position()
	_apply_stage_to_enemy(enemy, _current_stage)
	add_child(enemy)

	# Só conecta o sinal de morte ao powerup para a instância específica.
	if _spawn_count % powerup_enemy_index == 0:
		enemy.died.connect(_on_powerup_enemy_died)

func _pick_enemy_scene() -> PackedScene:
	if not _enemy_pool.is_empty():
		return _enemy_pool[randi() % _enemy_pool.size()]
	return enemy_scene

#Aplicar dados da fase (spawn stage) ao inimigo
func _apply_stage_to_enemy(enemy: Enemy, stage: SpawnStage) -> void:
	if stage == null:
		return
	if stage.enemy_health >= 0:
		enemy.max_health = stage.enemy_health
	if stage.enemy_reward >= 0:
		enemy.reward_value = stage.enemy_reward
	if stage.enemy_speed >= 0.0:
		enemy.speed = stage.enemy_speed

#Carregar o spawn stage correto de acordo com a distância percorrida na fase
func _update_spawn_stage() -> void:
	if phase == null or phase.spawn_stages.is_empty():
		return
	var distance: float = camera.distance_traveled
	var best: SpawnStage = null
	for stage in phase.spawn_stages:
		if distance >= stage.distance_threshold:
			if best == null or stage.distance_threshold > best.distance_threshold:
				best = stage
	if best == null or best == _current_stage:
		return
	_current_stage = best
	
	#Reinicia o timer de acordo com o passo da fase
	$SpawnTimer.start(best.spawn_interval)
	if not best.enemy_scenes.is_empty():
		_enemy_pool = best.enemy_scenes
	elif best.enemy_scene != null:
		enemy_scene = best.enemy_scene
		_enemy_pool = []


#Quando chegar ao final da fase, inicia sequencia de boss
func _on_phase_completed() -> void:
	$SpawnTimer.stop()
	_run_boss_sequence()
	

#Sequencia do boss
func _run_boss_sequence() -> void:
	await _wait_until_enemies_cleared() #Aguarda todos os inimigos serem mortos
	if not is_inside_tree():
		return
	if boss_scene != null:
		await _spawn_boss() 
		if not is_inside_tree():
			return
		await _wait_until_enemies_cleared()
		if not is_inside_tree():
			return
	_collect_remaining_coins() #Coletar moedas (provavelmente só a do boss) independentemente da distância
	_finish_phase() #Finalizar fase após morte do boss

func _collect_remaining_coins() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	for coin in get_tree().get_nodes_in_group("coin"):
		if coin.has_method("collect"):
			coin.collect(player)

#Checa se todos os inimigos estão mortos
func _wait_until_enemies_cleared() -> void:
	var tree := get_tree()
	while not tree.get_nodes_in_group("enemy").is_empty():
		await tree.create_timer(0.5).timeout
		if not is_inside_tree():
			return

const BossWarningLabelScene := preload("res://entities/BossWarningLabel.tscn")

#Spawn do Boss
func _spawn_boss() -> void:
	if phase != null and phase.boss_music != null: #Tocar música do boss
		var tw := create_tween()
		tw.tween_property(audio_player, "volume_db", -40.0, 0.5)
		await tw.finished
		audio_player.stream = phase.boss_music
		audio_player.play()
		create_tween().tween_property(audio_player, "volume_db", 0.0, 0.5)
	
	#Criar o Warning
	var warning := BossWarningLabelScene.instantiate()
	warning.global_position = _get_boss_spawn_position()
	if phase != null:
		warning.sfx_override = phase.boss_warning_sound
	get_tree().get_first_node_in_group("game_root").add_child(warning)
	
	#Aguarda o warning terminar (som e imagem)
	await warning.finished
	if not is_inside_tree():
		return
	
	#Instancia o Boss
	var boss := boss_scene.instantiate()
	boss.global_position = _get_boss_spawn_position()
	get_tree().get_first_node_in_group("game_root").add_child(boss)

func _get_boss_spawn_position() -> Vector2:
	var local_camera := get_viewport().get_camera_2d()
	var viewport_size := get_viewport_rect().size
	var cam_pos := local_camera.global_position if local_camera else Vector2.ZERO
	return Vector2(cam_pos.x, cam_pos.y - viewport_size.y / 2 + 120.0)

#Ao matar o boss, salva os atributos atuais em disco
func _finish_phase() -> void:
	if _player_died:
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	var data := GameData.new()
	data.operator_level = operator_level
	data.digit_level = digit_level
	data.bonus_range = bonus_range
	
	#Liberar a próxima fase (se for uma nova, se rejogar uma antiga, continua no mesmo valor)
	if phase != null:
		var prev := GameSave.load_data()
		data.unlocked_phase = max(prev.unlocked_phase, phase.phase_number + 1)
	data.player = player.get_save_data()
	GameSave.save(data)
	phase_results.emit(_phase_start_player, data.player)
	audio_player.stop()

func _on_player_died() -> void:
	_player_died = true
	


func _ready() -> void:
	#Setar fase atual
	if GameConfig.selected_phase != null:
		phase = GameConfig.selected_phase

	var save_data := GameSave.load_data()
	#Verifica se tem dados salvos para carregar, se não, carrega da configuração
	if GameConfig.configured:
		operator_level = GameConfig.operator_level
		digit_level = GameConfig.digit_level
		bonus_range = GameConfig.range_value
	else:
		operator_level = save_data.operator_level
		digit_level = save_data.digit_level
		bonus_range = save_data.bonus_range
	if phase != null:
		_apply_phase(phase)
	_phase_start_player = save_data.player.duplicate()
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		if phase != null:
			player.max_multiplier = phase.max_multiplier
		player.apply_save_data(save_data.player)
		player.died.connect(_on_player_died)

#Aplica os dados da fase atual à cena (Som, Imagem de fundo, evento da fase, velocidade de câmera, distância, etc.)
func _apply_phase(data: PhaseData) -> void:
	if data.power_scene != null:
		power_scene = data.power_scene
	powerup_enemy_index = data.powerup_enemy_index
	boss_scene = data.boss_scene
	$SpawnTimer.wait_time = data.spawn_interval
	camera.configure(data.camera_speed, data.phase_distance)
	camera.phase_completed.connect(_on_phase_completed)
	if data.phase_music != null:
		audio_player.stream = data.phase_music
	audio_player.play()
	if data.imagem != null:
		var background: Parallax2D = $Background/FloorLayer
		var fx: Sprite2D = $Background/FloorLayer/FloorTexture
		fx.texture = data.imagem
		fx.region_rect = Rect2(Vector2.ZERO, data.imagem.get_size())
		background.scroll_scale = Vector2(1,1)
		var tile_height: float = data.imagem.get_size().y * fx.scale.y
		background.repeat_size = Vector2(0, tile_height)
		background.repeat_times = ceil(data.phase_distance / tile_height) + 1
		$Background/SkyLayer/SkyTexture.modulate = data.sky_color
		#$Background/FloorLayer/FloorTexture.modulate = data.floor_color

func _on_powerup_enemy_died(death_position: Vector2) -> void:
	call_deferred("_spawn_powerup", death_position)

#Constantes para controlar distância mínima entre powerups
const POWERUP_OVERLAP_RADIUS := 60.0
const POWERUP_STACK_OFFSET := 40.0

#Calcular o limite de bônus efetivo na fase, com base no que já foi desbloqueado e limite da própria fase
func _effective_range() -> float:
	var unlocked := PowerupGenerator.unlock_range(operator_level, digit_level)
	if phase != null:
		return minf(unlocked, phase.range_max)
	return unlocked

#Instancia e gera um valor para o powerup
func _spawn_powerup(death_position: Vector2)->void:
	var power := power_scene.instantiate()
	var r := _effective_range()
	power.data = PowerupGenerator.generate(operator_level, digit_level, -r, r)
	power.add_to_group("powerup")
	add_child(power)
	power.global_position = _get_free_powerup_position(death_position)

#Modificar um pouco a posição do powerup caso já tem um no mesmo local, para não ficar um escondido atrás do outro
func _get_free_powerup_position(base_position: Vector2) -> Vector2:
	var pos := base_position
	var existing := get_tree().get_nodes_in_group("powerup")
	var moved := true
	while moved:
		moved = false
		for node in existing:
			if node == null or not is_instance_valid(node):
				continue
			if node.global_position.distance_to(pos) < POWERUP_OVERLAP_RADIUS:
				pos.y -= POWERUP_STACK_OFFSET
				moved = true
	return pos


#Calcula a posição onde vai spawnar o inimigo, sempre acima da tela
func _get_spawn_position() -> Vector2:
	var local_camera := get_viewport().get_camera_2d()
	var viewport_size := get_viewport_rect().size
	var cam_pos := local_camera.global_position if local_camera else Vector2.ZERO
	var spawn_x := randf_range(cam_pos.x - viewport_size.x / 2, cam_pos.x + viewport_size.x / 2)
	spawn_x = max(min(spawn_x, 800), 60)
	var spawn_y := cam_pos.y - viewport_size.y / 2 - 20.0
	return Vector2(spawn_x, spawn_y)
