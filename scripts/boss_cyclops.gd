extends Boss

## Arremessa uma clava giratória por vez na direção do jogador. Estágios: cadência do timer menor (arremessa mais rápido),
## velocidade da clava maior (ver club_speeds) e, a partir de homing_from_stage, a clava passa a perseguir o jogador.
const ClubProjectileScene := preload("res://entities/club_projectile.tscn")

@export var club_speeds: Array[float] = [220.0, 235.0, 250.0, 280.0] #Velocidade da clava por estágio
@export var timer_speed: Array[float] = [2.0, 1.5, 1.2, 0.9] #Cadência de arremesso
@export var homing_from_stage: int = 2

@export var attack_timer: Timer

#Limites de movimento
@export var patrol_left_x: float = 100.0
@export var patrol_right_x: float = 760.0
@export var patrol_duration: float = 2.5
var _patrol_tween: Tween

func _ready() -> void:
	super._ready()
	_start_patrol()
	_update_attack_timer()

func _start_patrol() -> void:
	_patrol_tween = create_tween()
	_patrol_tween.set_loops()
	_patrol_tween.tween_property(self, "global_position:x", patrol_right_x, patrol_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_patrol_tween.tween_property(self, "global_position:x", patrol_left_x, patrol_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _current_stage() -> int:
	return clampi(_health_threshold_stage(), 0, 999)

func _update_attack_timer() -> void:
	if timer_speed.is_empty() or attack_timer == null:
		return
	var stage := clampi(_current_stage(), 0, timer_speed.size() - 1)
	attack_timer.wait_time = timer_speed[stage]

func _on_attack_timer_timeout() -> void:
	if player == null:
		return
	_set_state(State.ATTACKING)
	_throw_club()

func _throw_club() -> void:
	var stage := clampi(_current_stage(), 0, club_speeds.size() - 1)
	var club := ClubProjectileScene.instantiate()
	club.global_position = global_position
	club.direction = (player.global_position - global_position).normalized()
	club.speed = club_speeds[stage]
	club.homing = stage >= homing_from_stage
	club.target = player
	_register_projectile(club)
	get_tree().get_first_node_in_group("game_root").add_child(club)

func _on_threshold_crossed(stage: int) -> void:
	_update_attack_timer()
	super._on_threshold_crossed(stage)

func _on_death_stop() -> void:
	if _patrol_tween:
		_patrol_tween.kill()
	if attack_timer:
		attack_timer.stop()
