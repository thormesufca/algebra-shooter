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
## Se o jogador morrer, o save de fim de fase deve ser cancelado mesmo que os
## inimigos restantes já estejam mortos (ver _finish_phase()).
var _player_died: bool = false

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
	# start() reinicia a contagem já com o novo intervalo; só ajustar
	# wait_time não bastaria, pois o Timer já rearma o próximo ciclo com o
	# valor antigo antes de emitir este próprio "timeout" — na prática, um
	# tick a mais dispararia com o intervalo antigo (visível no estágio do
	# minotauro: um segundo boss surgindo antes do fim da fase).
	$SpawnTimer.start(best.spawn_interval)
	if not best.enemy_scenes.is_empty():
		_enemy_pool = best.enemy_scenes
	elif best.enemy_scene != null:
		enemy_scene = best.enemy_scene
		_enemy_pool = []

func _on_phase_completed() -> void:
	$SpawnTimer.stop()
	_finish_phase_when_enemies_cleared()

## A câmera já percorreu toda a distância da fase, mas podem sobrar
## inimigos em campo: espera todos morrerem antes de considerar a fase
## concluída e salvar o progresso do jogador.
## Guarda a SceneTree numa variável local e confere is_inside_tree() a cada
## volta: se o jogador morrer nesse meio-tempo (main.gd reload_current_scene
## depois de 3s), este nó pode sair da árvore antes do loop terminar —
## get_tree() passaria a retornar null.
func _finish_phase_when_enemies_cleared() -> void:
	var tree := get_tree()
	while not tree.get_nodes_in_group("enemy").is_empty():
		await tree.create_timer(0.5).timeout
		if not is_inside_tree():
			return
	_finish_phase()

const MainMenuScene := "res://scenes/main_menu.tscn"
const PHASE_COMPLETE_DELAY := 1.5

## Persiste o progresso do jogo (níveis de operadores/dígitos, range dos
## powerups e atributos do jogador) ao final da fase e volta ao menu, onde o
## ouro ganho pode ser gasto na loja. Se o jogador morreu no meio do
## caminho, o save é pulado e o progresso salvo anteriormente permanece
## intacto.
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
	data.player = player.get_save_data()
	GameSave.save(data)
	var tree := get_tree()
	await tree.create_timer(PHASE_COMPLETE_DELAY).timeout
	# Se o jogador morrer bem nesse intervalo, main.gd também tenta trocar de
	# cena (reload) — evita disputar a troca com um nó que já saiu da árvore.
	if is_inside_tree():
		tree.change_scene_to_file(MainMenuScene)

func _on_player_died() -> void:
	_player_died = true


func _ready() -> void:
	# A fase escolhida na tela de seleção (se houver) tem prioridade sobre o
	# @export configurado na cena, usado para testar a cena direto no editor.
	if GameConfig.selected_phase != null:
		phase = GameConfig.selected_phase

	# GameConfig (config explícita de uma tela de menu, se houver) tem
	# prioridade sobre o progresso salvo; na ausência de ambos, valem os
	# defaults dos @export.
	var save_data := GameSave.load_data()
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
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		player.apply_save_data(save_data.player)
		player.died.connect(_on_player_died)

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
