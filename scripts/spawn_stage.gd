extends Resource

#Dados de configuração de cada estágio de spawn de uma fase

class_name SpawnStage

@export var distance_threshold: float = 0.0 #Distância percorrida para usar esses dados

@export var spawn_interval: float = 1.0 #Intervalo de spawn de inimigos

@export var enemy_scene: PackedScene #Qual inimigo vai spawnar

@export var enemy_scenes: Array[PackedScene] = [] #Se quiser spawnar aleatoriamente vários tipos de inimigos diferentes com os mesmos dados (vida, recompensa, velocidade)

#Se na configuração da fase for setado valor diferente de -1 em qualquer dos atributos abaixo, sobrescreve o atributo do inimigo padrão
@export var enemy_health: int = -1 
@export var enemy_reward: int = -1 
@export var enemy_speed: float = -1.0


func _init(_distance: float = 0.0, _spawn_interval: float = 1.0, enemy: PackedScene = null, _enemy_health: int = -1, _enemy_reward: int = -1, _enemy_speed: float = -1.0):
	distance_threshold = _distance
	spawn_interval = _spawn_interval
	enemy_scene = enemy
	enemy_health = _enemy_health
	enemy_reward = _enemy_reward
	enemy_speed = _enemy_speed
