extends Boss

## Minotauro: patrulha de um lado a outro da tela (em vez de ficar parado —
## alvo parado deixava o leque de pedras fácil demais de prever) enquanto
## dispara leques de pedra na direção do jogador em intervalos regulares (via
## nó Timer "AttackTimer" na cena), estilo bullet hell — ver
## enemy_minotaur.tscn.

const RockProjectileScene := preload("res://entities/rock_projectile.tscn")

@export var volley_size: int = 5
@export var spread_degrees: float = 60.0
@export var rock_speed: float = 260.0

## Quantas ondas de pedra saem por rajada, de acordo com o quanto de vida já
## foi perdido: índices correspondentes entre os dois arrays — a partir do
## momento em que health/max_health cai para wave_health_thresholds[i] (ou
## menos), wave_amounts[i] passa a valer. Com os padrões abaixo (100% → 2
## ondas, 50% → 3, 25% → 4) o boss fica mais agressivo conforme a vida cai.
@export var wave_health_thresholds: Array[float] = [1.0, 0.5, 0.25, 0.1]
@export var wave_amounts: Array[int] = [2, 3, 4, 6]
## Pausa entre cada onda de uma mesma rajada — sem isso todas as ondas
## saíam no mesmo frame, empilhadas.
@export var wave_interval: float = 0.3

var _is_attacking: bool = false

## Limites da patrulha (mesma faixa jogável do player — ver
## player.gd:MIN_X/MAX_X — com uma margem pra sobrar a largura do sprite).
@export var patrol_left_x: float = 100.0
@export var patrol_right_x: float = 760.0
@export var patrol_duration: float = 2.5

func _ready() -> void:
	super._ready()
	_start_patrol()

func _start_patrol() -> void:
	var patrol_tween := create_tween()
	patrol_tween.set_loops()
	patrol_tween.tween_property(self, "global_position:x", patrol_right_x, patrol_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	patrol_tween.tween_property(self, "global_position:x", patrol_left_x, patrol_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## O AttackTimer pode disparar de novo enquanto uma rajada anterior ainda
## está esperando entre ondas (_is_attacking evita empilhar duas rajadas ao
## mesmo tempo).
func _on_attack_timer_timeout() -> void:
	if player == null or _is_attacking:
		return
	_is_attacking = true
	var wave_amount := _current_wave_amount()
	var tree := get_tree()
	for j in range(wave_amount):
		_fire_volley()
		if j < wave_amount - 1:
			await tree.create_timer(wave_interval).timeout
			if not is_inside_tree():
				return
	_is_attacking = false

func _fire_volley() -> void:
	var base_angle := (player.global_position - global_position).angle()
	var spread := deg_to_rad(spread_degrees)
	for i in range(volley_size * _current_wave_amount()):
		var t : float = float(i) / max(volley_size - 1, 1)
		var angle : float = base_angle - spread / 2.0 + spread * t
		var rock := RockProjectileScene.instantiate()
		rock.global_position = global_position
		rock.direction = Vector2.RIGHT.rotated(angle)
		rock.speed = rock_speed
		get_tree().get_first_node_in_group("game_root").add_child(rock)

## Menor limiar de wave_health_thresholds que a vida atual já alcançou —
## mesma lógica de "melhor estágio" de game.gd:_update_spawn_stage, só que
## por fração de HP em vez de distância.
func _current_wave_amount() -> int:
	if wave_amounts.is_empty():
		return 1
	var health_fraction := float(health) / float(max_health) if max_health > 0 else 1.0
	var best_index := -1
	for i in range(wave_health_thresholds.size()):
		if health_fraction <= wave_health_thresholds[i]:
			if best_index == -1 or wave_health_thresholds[i] < wave_health_thresholds[best_index]:
				best_index = i
	if best_index == -1 or best_index >= wave_amounts.size():
		best_index = 0
	return wave_amounts[best_index]
