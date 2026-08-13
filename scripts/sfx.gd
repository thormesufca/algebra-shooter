extends Node

## Autoload singleton: toca efeitos sonoros pontuais (one-shot) a partir de um
## nó persistente, desacoplado de quem pediu o som. Isso resolve o caso em que
## o emissor é efêmero e se auto-libera logo após tocar (ex: powerup pego, que
## dá queue_free() no mesmo frame — ver power.gd): como o AudioStreamPlayer
## fica aqui, e não como filho do emissor, o som não é cortado.
##
## Cada chamada cria um AudioStreamPlayer temporário que se libera sozinho ao
## terminar, permitindo sons sobrepostos sem cortar uns aos outros.

func play(stream: AudioStream, volume_db: float = 0.0, bus: String = "Master") -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.max_polyphony = 2
	player.volume_db = volume_db
	player.bus = bus
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
