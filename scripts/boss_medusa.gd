extends Boss

## Medusa: fica parada e invoca cobras em ondas periódicas (via nó Timer
## "AttackTimer" na cena). As cobras reaproveitam a IA de perseguição padrão
## de enemy.gd (enemy_snake.tscn) — a ameaça vem delas perseguindo o
## jogador, não da Medusa em si.

const SnakeScene := preload("res://entities/enemies/enemy_snake.tscn")

@export var snakes_per_wave: int = 2
@export var snake_health: int = 8
@export var snake_speed: float = 140.0
const SPAWN_SCATTER := Vector2(80.0, 40.0)

func _on_attack_timer_timeout() -> void:
	for i in range(snakes_per_wave):
		var snake: Enemy = SnakeScene.instantiate()
		snake.max_health = snake_health
		snake.speed = snake_speed
		snake.global_position = global_position + Vector2(
			randf_range(-SPAWN_SCATTER.x, SPAWN_SCATTER.x),
			randf_range(-SPAWN_SCATTER.y, SPAWN_SCATTER.y)
		)
		get_tree().get_first_node_in_group("game_root").add_child(snake)
