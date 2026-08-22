extends Boss

## Cérbero: fica parado e cospe bolas de fogo pelas 3 bocas. Padrão: onda 1 só a boca
## central sem crescer, onda 2 só a central mas já crescendo, onda 3
## central+esquerda crescendo, onda 4 as 3 bocas crescendo.
const FireballProjectileScene := preload("res://entities/fireball_projectile.tscn")

@export var fireball_speed: float = 220.0
@export var mouths_per_stage: Array[int] = [1, 1, 2, 3] #Quantas bolas por estágio
@export var growing_from_stage: int = 1
@export var side_mouth_angle_degrees: float = 30.0

@export var mouth_center: Marker2D
@export var mouth_left: Marker2D
@export var mouth_right: Marker2D
@export var attack_timer: Timer

@export var patrol_left_x: float = 100.0
@export var patrol_right_x: float = 760.0
@export var patrol_duration: float = 2.5
var _patrol_tween: Tween

func _ready() -> void:
	super._ready()
	self.health_thresholds = [1, 0.7, 0.4, 0.2]
	_start_patrol()

#Função de movimentar
func _start_patrol() -> void:
	_patrol_tween = create_tween()
	_patrol_tween.set_loops()
	_patrol_tween.tween_property(self, "global_position:x", patrol_right_x, patrol_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_patrol_tween.tween_property(self, "global_position:x", patrol_left_x, patrol_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

##Função de atacar
func _on_attack_timer_timeout() -> void:
	if player == null:
		return
	_set_state(State.ATTACKING)
	var stage := clampi(_health_threshold_stage(), 0, mouths_per_stage.size() - 1)
	var grows := stage
	var center_position: Vector2 = mouth_center.global_position if mouth_center != null else global_position
	var base_direction := (player.global_position - center_position).normalized()
	for config in _active_mouth_configs(mouths_per_stage[stage]):
		_fire_fireball(config["marker"], base_direction.rotated(deg_to_rad(config["angle"])), grows)

#Posicionamento e ângulo (relativo à mira da boca central) de cada boca
func _active_mouth_configs(count: int) -> Array:
	var all := [
		{"marker": mouth_center, "angle": 0.0},
		{"marker": mouth_left, "angle": side_mouth_angle_degrees},
		{"marker": mouth_right, "angle": -side_mouth_angle_degrees},
	]
	return all.slice(0, clampi(count, 0, all.size()))

func _fire_fireball(mouth: Marker2D, _direction: Vector2, grows: int) -> void:
	if mouth == null:
		return
	var fireball := FireballProjectileScene.instantiate()
	fireball.global_position = mouth.global_position
	fireball.direction = _direction
	fireball.speed = fireball_speed
	fireball.grows = grows >= 1
	fireball.growth_rate *= grows
	_register_projectile(fireball)
	get_tree().get_first_node_in_group("game_root").add_child(fireball)

func _on_death_stop() -> void:
	if _patrol_tween:
		_patrol_tween.kill()
	if attack_timer:
		attack_timer.stop()
