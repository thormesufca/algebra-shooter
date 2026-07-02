extends Node2D

@export var enemy_scene: PackedScene
@export var power_scene: PackedScene
@export var powerup_enemy_index: int = 5
@export var phase: PhaseData

var _spawn_count: int = 0

func _on_spawn_timer_timeout() -> void:
	_spawn_count += 1
 
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.global_position = _get_spawn_position()
	add_child(enemy)
 
	# Só conecta o sinal de morte ao powerup para a instância específica.
	if _spawn_count % powerup_enemy_index == 0:
		enemy.died.connect(_on_powerup_enemy_died)


func _ready() -> void:
	if phase != null:
		_apply_phase(phase)

func _apply_phase(data: PhaseData) -> void:
	if data.enemy_scene != null:
		enemy_scene = data.enemy_scene
	if data.power_scene != null:
		power_scene = data.power_scene
	powerup_enemy_index = data.powerup_enemy_index
	$SpawnTimer.wait_time = data.spawn_interval
	#$Background/SkyLayer/SkyTexture.modulate = data.sky_color
	#$Background/FloorLayer/FloorTexture.modulate = data.floor_color

func _on_powerup_enemy_died(death_position: Vector2) -> void:
	call_deferred("_spawn_powerup", death_position)
	
func _spawn_powerup(death_position: Vector2)->void:
	var power := power_scene.instantiate()
	power.data = PowerupGenerator.generate()
	add_child(power)
	power.global_position = death_position
	
func _get_spawn_position() -> Vector2:
	var camera := get_viewport().get_camera_2d()
	var viewport_size := get_viewport_rect().size
	var cam_pos := camera.global_position if camera else Vector2.ZERO
	var spawn_x := randf_range(cam_pos.x - viewport_size.x / 2, cam_pos.x + viewport_size.x / 2)
	var spawn_y := cam_pos.y - viewport_size.y / 2 - 20.0
	return Vector2(spawn_x, spawn_y)
