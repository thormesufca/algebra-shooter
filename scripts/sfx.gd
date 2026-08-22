extends Node

#No para tocar sons avulsos, não ligados à fase
func play(stream: AudioStream, volume_db: float = 0.0, bus: String = "Master", pitch_scale: float = 1.0) -> AudioStreamPlayer:
	if stream == null:
		return null
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.max_polyphony = 2
	player.volume_db = volume_db
	player.bus = bus
	player.pitch_scale = pitch_scale
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
	return player
