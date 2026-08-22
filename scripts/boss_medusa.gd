extends Boss
#Mecanica: Solta cada vez mais cobras, cada vez mais rápido

const SnakeScene := preload("res://entities/enemies/enemy_snake.tscn")

@export var snakes_per_wave: int = 2
@export var snake_health: int = 6
@export var snake_speed: float = 140.0
@export var attack_timer: Timer
@export var snake_amounts: Array[int] = [1, 2, 3, 4]
@export var timer_speed: Array[float] = [3.0, 2.5, 1.5, 1.0]

const SPAWN_SCATTER := Vector2(80.0, 40.0)

@export var patrol_left_x: float = 100.0
@export var patrol_right_x: float = 760.0
@export var patrol_duration: float = 2.5
var _patrol_tween: Tween

func _ready() -> void:
	super._ready()
	_start_patrol()
	_update_snakes()

func _start_patrol() -> void:
	_patrol_tween = create_tween()
	_patrol_tween.set_loops()
	_patrol_tween.tween_property(self, "global_position:x", patrol_right_x, patrol_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_patrol_tween.tween_property(self, "global_position:x", patrol_left_x, patrol_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _update_snakes() -> void:
	var stage := _health_threshold_stage()
	if stage == -1 or stage >= snake_amounts.size():
		stage = 0
	snakes_per_wave = snake_amounts[stage]
	attack_timer.wait_time = timer_speed[stage]

func _on_attack_timer_timeout() -> void:
	_set_state(State.ATTACKING)
	for i in range(snakes_per_wave):
		var snake: Enemy = SnakeScene.instantiate()
		snake.max_health = snake_health
		snake.speed = snake_speed
		snake.reward_value = 0
		snake.global_position = global_position + Vector2(
			randf_range(-SPAWN_SCATTER.x, SPAWN_SCATTER.x),
			randf_range(-SPAWN_SCATTER.y, SPAWN_SCATTER.y)
		)
		_register_projectile(snake)
		get_tree().get_first_node_in_group("game_root").add_child(snake)

## Recalcula quantidade de cobras/cadência assim que um limiar é cruzado
## (em vez de só no próximo ataque, como antes) e mantém o "enraging" da
## base (ver boss.gd:_on_threshold_crossed).
func _on_threshold_crossed(stage: int) -> void:
	_update_snakes()
	super._on_threshold_crossed(stage)

func _on_death_stop() -> void:
	if _patrol_tween:
		_patrol_tween.kill()
	if attack_timer:
		attack_timer.stop()
