extends Resource

class_name PhaseData

@export var phase_name: String = "Fase 1" #Nome da fase
@export var phase_number: int = 1 #Número da fase (para calcular desbloqueio)

#Dados referente ao spawn de inimigos
@export_group("Spawn")
@export var power_scene: PackedScene #Powerup, único
@export var spawn_interval: float = 1.0 #Intervalo padrão de spawn de inimigos
@export var powerup_enemy_index: int = 5 #Intervalo de inimigos para gerar powerup (A cada 5º inimigo gerado, tem powerup)
@export var spawn_stages: Array[SpawnStage] = [SpawnStage.new()] #Lista de stages de spawn para configurar na fase

#Configurações da Câmera
@export_group("Câmera")
@export var camera_speed: float = 60.0 #Velocidade da Câmera
@export var phase_distance: float = 50000.0 #Tamanho total da Fase

#Configurações de Limite
@export_group("Limites")
@export var range_max: float = 6.0 #Limite de Range de Bônus para a fase (+- o valor)
@export var max_multiplier: int = 3 #Valor máximo do multiplicador da fase

#Configuração do Boss da Fase
@export_group("Boss")
@export var boss_scene: PackedScene #Qual é o boss (cena)
@export var boss_warning_sound: AudioStream #Som para tocar para o warning do boss (sobrescrever o padrão)

#Configurações da imagem de fundo
@export_group("Fundo")
@export var sky_color: Color = Color(0.7137255, 0.68235296, 0.827451, 0.5) #Tint para o layer do céu (transparente)
@export var walls_color: Color = Color(0.24705882, 0.19607843, 0.15686275, 0.85) #Tint para as paredes
@export var floor_color: Color = Color(0.41960785, 0.3372549, 0.24313726, 1) #Tint para o chão
@export var imagem: Texture2D #Imagem de fundo da fase
@export var thumbnail: Texture2D #Thumbnail para a seleção de fase

#Configurações para áudio da fase
@export_group("Audio")
@export var phase_music: AudioStream #Música da fase
@export var boss_music: AudioStream #Música para o chefão da fase
