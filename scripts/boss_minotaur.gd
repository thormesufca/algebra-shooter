extends Boss

## Minotauro: dispara leques de pedra na direção do jogador em intervalos regulares, estilo bullet hell. Número de pedras aumenta a cada estágio.

const RockProjectileScene := preload("res://entities/rock_projectile.tscn")

@export var volley_size: int = 5
@export var spread_degrees: float = 60.0
@export var rock_speed: float = 260.0

@export var wave_amounts: Array[int] = [2, 3, 4, 6] #Quantidade de ondas de pedras a cada estágio
@export var wave_interval: float = 0.3 #Pausa entre rajadas

var _is_attacking: bool = false

#Limites Movimentação
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

func _on_attack_timer_timeout() -> void:
	if player == null or _is_attacking:
		return
	_is_attacking = true
	_set_state(State.ATTACKING)
	var wave_amount := _current_wave_amount()
	var tree := get_tree()
	for j in range(wave_amount):
		_fire_volley()
		if j < wave_amount - 1:
			await tree.create_timer(wave_interval).timeout
			if not is_inside_tree() or _dying:
				return
	_is_attacking = false


func _fire_volley() -> void:
	var base_angle := (player.global_position - global_position).angle()
	var spread := deg_to_rad(spread_degrees)
	for i in range(volley_size * _current_wave_amount()): #Quantidade de pedras de cada onda aumenta progressivamente junto com a quantidade de ondas
		var t : float = float(i) / max(volley_size - 1, 1)
		var angle : float = base_angle - spread / 2.0 + spread * t
		var rock := RockProjectileScene.instantiate()
		rock.global_position = global_position
		rock.direction = Vector2.RIGHT.rotated(angle)
		rock.speed = rock_speed
		_register_projectile(rock)
		get_tree().get_first_node_in_group("game_root").add_child(rock)

#Calcula quantidade de ondas de pedras
func _current_wave_amount() -> int:
	if wave_amounts.is_empty():
		return 1
	var stage := _health_threshold_stage()
	if stage == -1 or stage >= wave_amounts.size():
		stage = 0
	return wave_amounts[stage]

func _on_death_stop() -> void:
	if _patrol_tween:
		_patrol_tween.kill()
	$AttackTimer.stop()
