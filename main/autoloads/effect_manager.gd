extends Node

var music_node: AudioStreamPlayer2D = null
var audio_holder: Node = null
var particle_holder: Node2D = null
func play_sfx(stream: AudioStream, play_at_time: float = 0.0, volume: float = 10.0, base_pitch: float = 1.0, is_pitch_shifted: bool = false, shift_scale: Vector2 = Vector2(0.9, 1.1)) -> void:
	var pitch: float = base_pitch
	if is_pitch_shifted:
		pitch = _get_pitch_shift(shift_scale.x, shift_scale.y)
	var sfx_player: AudioStreamPlayer2D = _create_sfx_player(stream, volume, pitch)
	sfx_player.bus = "SFX"
	audio_holder.add_child(sfx_player)
	sfx_player.play(play_at_time)
	await sfx_player.finished
	sfx_player.queue_free()


func set_music_node(node: AudioStreamPlayer2D) -> void:
	music_node = node


func set_particle_container(node: Node2D) -> void:
	particle_holder = node


func set_audio_contianer(node: Node) -> void:
	audio_holder = node


func start_music(stream: AudioStream) -> void:
	music_node.stream = stream
	music_node.play()


func end_music() -> void:
	music_node.playing = false


func fade_in_music() -> void:
	pass


func fade_out_music() -> void:
	pass


func _create_sfx_player(stream: AudioStream,volume: float, pitch: float) -> AudioStreamPlayer2D:
	var sfx_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	sfx_player.pitch_scale = pitch
	sfx_player.volume_db = volume
	sfx_player.stream = stream
	return sfx_player


func _get_pitch_shift(min_pitch: float, max_pitch: float) -> float:
	return  randf_range(min_pitch, max_pitch)


func spawn_particles(particle_scene: PackedScene, spawn_position: Vector2, delay: float = 0.0) -> void:
	var particle_node: GPUParticles2D = particle_scene.instantiate()
	particle_node.position = spawn_position
	await get_tree().create_timer(delay).timeout
	particle_holder.add_child(particle_node)
	particle_node.emitting = true
	await particle_node.finished
	particle_node.queue_free()
