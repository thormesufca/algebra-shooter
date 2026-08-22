extends Boss

## Kraken: dispara flechas d'água em leque na direção do jogador. Cada estágio dobra a quantidade de flechas e aumenta a velocidade em 10%

const WaterArrowScene := preload("res://entities/water_arrow_projectile.tscn")

@export var base_arrow_speed: float = 400.0
@export var base_arrow_amount: int = 2
@export var spread_degrees: float = 60.0

@export var attack_timer: Timer

@export var patrol_left_x: float = 100.0
@export var patrol_right_x: float = 760.0
@export var patrol_duration: float = 2.5
var _patrol_tween: Tween

func _ready() -> void:
	super._ready()
	_start_patrol()

func _start_patrol() -> void:
	_patrol_tween = create_tween()
	_patrol_tween.set_loops()
	_patrol_tween.tween_property(self, "global_position:x", patrol_right_x, patrol_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_patrol_tween.tween_property(self, "global_position:x", patrol_left_x, patrol_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## Dobra a cada estágio de health_thresholds já alcançado: 2, 4, 8...
func _current_arrow_amount() -> int:
	var stage := clampi(_health_threshold_stage(), 0, 999)
	return base_arrow_amount * int(pow(2, stage))

## +10% sobre a velocidade-base a cada estágio já alcançado
func _current_arrow_speed() -> float:
	var stage := clampi(_health_threshold_stage(), 0, 999)
	return base_arrow_speed * pow(1.1, stage)

func _on_attack_timer_timeout() -> void:
	if player == null:
		return
	_set_state(State.ATTACKING)
	_fire_fan()

func _fire_fan() -> void:
	var amount := _current_arrow_amount()
	var arrow_speed := _current_arrow_speed()
	var base_angle := (player.global_position - global_position).angle()
	var spread := deg_to_rad(spread_degrees)
	for i in range(amount):
		var t : float = float(i) / max(amount - 1, 1)
		var angle : float = (base_angle - spread / 2.0 + spread * t) if amount > 1 else base_angle
		var arrow := WaterArrowScene.instantiate()
		arrow.global_position = global_position
		arrow.direction = Vector2.RIGHT.rotated(angle)
		arrow.speed = arrow_speed
		_register_projectile(arrow)
		get_tree().get_first_node_in_group("game_root").add_child(arrow)

func _on_death_stop() -> void:
	if _patrol_tween:
		_patrol_tween.kill()
	if attack_timer:
		attack_timer.stop()
