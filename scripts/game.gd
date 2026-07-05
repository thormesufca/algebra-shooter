extends Node2D

@export var enemy_scene: PackedScene
@export var power_scene: PackedScene
@export var powerup_enemy_index: int = 5
@export var phase: PhaseData
@export var operator_level: int = 1
@export var digit_level: int = 4
@export var bonus_range: float = 4


var _spawn_count: int = 0
var _current_stage: SpawnStage = null
var _enemy_pool: Array[PackedScene] = []

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

## Sorteia uma cena de inimigo do pool atual (fase ou estágio), se houver;
## caso contrário usa o enemy_scene único configurado.
func _pick_enemy_scene() -> PackedScene:
	if not _enemy_pool.is_empty():
		return _enemy_pool[randi() % _enemy_pool.size()]
	return enemy_scene

## Aplica os overrides de HP/recompensa do estágio atual ao inimigo recém
## instanciado, antes dele entrar na árvore (max_health precisa ser ajustado
## antes do _ready() da cena definir health/progress_bar).
func _apply_stage_to_enemy(enemy: Enemy, stage: SpawnStage) -> void:
	if stage == null:
		return
	if stage.enemy_health >= 0:
		enemy.max_health = stage.enemy_health
	if stage.enemy_reward >= 0:
		enemy.reward_value = stage.enemy_reward
	if stage.enemy_speed >= 0.0:
		enemy.speed = stage.enemy_speed

## Verifica se, com a distância percorrida pela câmera, um novo estágio de
## dificuldade (definido em phase.spawn_stages) deve entrar em vigor.
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
	$SpawnTimer.wait_time = best.spawn_interval
	if not best.enemy_scenes.is_empty():
		_enemy_pool = best.enemy_scenes
	elif best.enemy_scene != null:
		enemy_scene = best.enemy_scene
		_enemy_pool = []

func _on_phase_completed() -> void:
	$SpawnTimer.stop()


func _ready() -> void:
	if GameConfig.configured:
		operator_level = GameConfig.operator_level
		digit_level = GameConfig.digit_level
		bonus_range = GameConfig.range_value
	if phase != null:
		_apply_phase(phase)

func _apply_phase(data: PhaseData) -> void:
	if data.enemy_scene != null:
		enemy_scene = data.enemy_scene
	if not data.enemy_scenes.is_empty():
		_enemy_pool = data.enemy_scenes
	if data.power_scene != null:
		power_scene = data.power_scene
	powerup_enemy_index = data.powerup_enemy_index
	$SpawnTimer.wait_time = data.spawn_interval
	camera.configure(data.camera_speed, data.phase_distance)
	camera.phase_completed.connect(_on_phase_completed)
	#$Background/SkyLayer/SkyTexture.modulate = data.sky_color
	#$Background/FloorLayer/FloorTexture.modulate = data.floor_color

func _on_powerup_enemy_died(death_position: Vector2) -> void:
	call_deferred("_spawn_powerup", death_position)
	
const POWERUP_OVERLAP_RADIUS := 30.0
const POWERUP_STACK_OFFSET := 40.0

func _spawn_powerup(death_position: Vector2)->void:
	var power := power_scene.instantiate()
	power.data = PowerupGenerator.generate(operator_level, digit_level, -bonus_range, bonus_range)
	print(power.data.expression, " = ", power.data.result)
	power.add_to_group("powerup")
	add_child(power)
	power.global_position = _get_free_powerup_position(death_position)

## Se já existir um powerup perto da posição desejada, empurra o novo (mais
## recente) para cima até achar um lugar livre, evitando que fiquem
## sobrepostos quando dois inimigos morrem no mesmo ponto.
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
	
func _get_spawn_position() -> Vector2:
	var local_camera := get_viewport().get_camera_2d()
	var viewport_size := get_viewport_rect().size
	var cam_pos := local_camera.global_position if local_camera else Vector2.ZERO
	var spawn_x := randf_range(cam_pos.x - viewport_size.x / 2, cam_pos.x + viewport_size.x / 2)
	spawn_x = max(min(spawn_x, 800), 60)
	var spawn_y := cam_pos.y - viewport_size.y / 2 - 20.0
	return Vector2(spawn_x, spawn_y)
