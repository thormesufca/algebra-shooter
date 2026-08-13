extends Boss

## Medusa: fica parada e invoca cobras em ondas periódicas (via nó Timer
## "AttackTimer" na cena). As cobras reaproveitam a IA de perseguição padrão
## de enemy.gd (enemy_snake.tscn) — a ameaça vem delas perseguindo o
## jogador, não da Medusa em si.

const SnakeScene := preload("res://entities/enemies/enemy_snake.tscn")

@export var snakes_per_wave: int = 2
@export var snake_health: int = 6
@export var snake_speed: float = 140.0
@export var attack_timer: Timer
@export var health_thresholds: Array[float] = [1.0, 0.5, 0.25, 0.1]
@export var snake_amounts: Array[int] = [2, 3, 4, 6]
@export var timer_speed: Array[float] = [3.0, 2.0, 1.0, 0.5]

const SPAWN_SCATTER := Vector2(80.0, 40.0)

@export var patrol_left_x: float = 100.0
@export var patrol_right_x: float = 760.0
@export var patrol_duration: float = 2.5

func _start_patrol() -> void:
	var patrol_tween := create_tween()
	patrol_tween.set_loops()
	patrol_tween.tween_property(self, "global_position:x", patrol_right_x, patrol_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	patrol_tween.tween_property(self, "global_position:x", patrol_left_x, patrol_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _ready() -> void:
	super._ready()
	_start_patrol()

func _update_snakes():
	var health_fraction := float(health) / float(max_health) if max_health > 0 else 1.0
	for i in range(health_thresholds.size()):
		var threshold = health_thresholds[i]
		if health_fraction > threshold:
			snakes_per_wave = snake_amounts[i]
			attack_timer.wait_time = timer_speed[i]
			break

func _on_attack_timer_timeout() -> void:
	for i in range(snakes_per_wave):
		var snake: Enemy = SnakeScene.instantiate()
		snake.max_health = snake_health
		snake.speed = snake_speed
		snake.reward_value = 0
		snake.global_position = global_position + Vector2(
			randf_range(-SPAWN_SCATTER.x, SPAWN_SCATTER.x),
			randf_range(-SPAWN_SCATTER.y, SPAWN_SCATTER.y)
		)
		get_tree().get_first_node_in_group("game_root").add_child(snake)
	_update_snakes()
