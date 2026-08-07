extends Enemy

class_name Boss

## Base para bosses: herda HP/dano/morte de Enemy, mas fica parado em vez de
## perseguir o jogador (enemy.gd:_physics_process) — cada boss concreto
## (boss_minotaur.gd, boss_medusa.gd, ...) ataca à distância no lugar disso,
## senão o jogador consegue simplesmente fugir se for mais rápido que o boss.

func _physics_process(_delta: float) -> void:
	pass

func _process(_delta: float) -> void:
	if player != null:
		look_at(player.global_position)
