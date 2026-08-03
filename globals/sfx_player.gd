extends Node
# This node (the scene) to be added as a global named SFX

enum Labels {
	FALL,
	AMBIENCE,
	SAND,
}

## TRUE = get debug messages each time a sound is played, FALSE = no debug messages
const print_sounds: bool = true

## Variable to make each AudioStreamPlayer's name unique. Increased by one per new sound
var counter : int = 0

var player_setting = preload("uid://dal14vdhrcflw")

@export var label_to_setting: Dictionary[Labels, SfxSettings]

## Play a sound effect, as defined by label. Intended should be SFX.play(SFX.Labels.NAME)
func play_new(label: Labels, loop : bool = false, optional_volume: float = 0.0, optional_pitch: float = 0.0):
	# Checks if a min_delay_timer is in the scene tree, and if so, return early
	if has_node(Labels.keys()[label]):
		return
	## The instance of an AudioStreamPlayer
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.set_script(player_setting)
	## The instance of sfx_settings.gd
	var setting = label_to_setting[label]
	audio_stream_player.bus = setting.bus
	audio_stream_player.stream = setting.stream
	audio_stream_player.name = Labels.keys()[label] + str(counter)
	counter += 1
	audio_stream_player.volume_db = setting.volume + randf_range(-1,1) * setting.volume_variance + optional_volume
	audio_stream_player.pitch_scale = setting.pitch + randf_range(-1,1) * setting.pitch_variance + optional_pitch
	audio_stream_player.calculated_volume = audio_stream_player.volume_db
	if loop == true:
		audio_stream_player.stream.loop = true
	
	add_child(audio_stream_player)
	audio_stream_player.finished.connect(audio_stream_player.queue_free)
	audio_stream_player.playing = true
	
	if print_sounds:
		print("playing: ", Labels.keys()[label])
		
	if setting.min_delay != 0:
		add_min_delay_timer(label)
		
	return audio_stream_player

func add_min_delay_timer(label : Labels):
	var setting = label_to_setting[label]
	var min_delay_timer : Timer = Timer.new()
	min_delay_timer.name = Labels.keys()[label]
	min_delay_timer.wait_time = setting.min_delay
	min_delay_timer.autostart = true
	min_delay_timer.timeout.connect(min_delay_timer.queue_free)
	add_child(min_delay_timer)
	
## Play all audio nodes of a specific type
func unpause_one(audio_stream_player: AudioStreamPlayer, fade_in: bool = false):
	for node in get_children():
		if node != audio_stream_player:
			continue
		if fade_in == true:
			print("1")
			apply_fade_in(audio_stream_player)
		else:
			node.play()

## Play all audio nodes of a specific type
func unpause_type(label: Labels):
	for node in get_children():
		if Labels.keys()[label] not in node.name:
			continue
		if node is not AudioStreamPlayer:
			continue
		node.play()

## Play all audio nodes
func unpause_all():
	for node in get_children():
		if node is AudioStreamPlayer:
			node.play()

func apply_fade_in(audio_stream_player: AudioStreamPlayer):
	print("2")
	audio_stream_player.fade_in = true
	var setting = label_to_setting[node_to_label(audio_stream_player)]
	var curve = setting.unpause_fade_curve
	print(curve)
	if curve == null:
		push_warning("No Curve for " + str(audio_stream_player))
		return
	if curve.min_domain != 0:
		push_warning("Min Domain not 0 for " + str(audio_stream_player))
		return
	if curve.min_value != 0:
		push_warning("Min Value not 0 for " + str(audio_stream_player))
		return
	if curve.max_value != 1:
		push_warning("Max Value not 1 for " + str(audio_stream_player))
		return

	var initial : float = audio_stream_player.get_playback_position()
	var length : float = audio_stream_player.stream.get_length()
	var distance_to_end : float = length - initial
	
	audio_stream_player.initial = initial
	
	var scaled_curve : Curve
	
	if distance_to_end < setting.unpause_fade_curve.max_domain:
		scaled_curve = calculate_scaled_curve(setting.unpause_fade_curve, distance_to_end)
		print("had to scale")
	else:
		scaled_curve = curve
		
	audio_stream_player.scaled_fade_in_curve = scaled_curve
	audio_stream_player.play()
	
	add_fade_in_timer(audio_stream_player, scaled_curve.max_domain)

func add_fade_in_timer(audio_stream_player : AudioStreamPlayer, length : float):
	print("timer")
	var fade_in_timer : Timer = Timer.new()
	fade_in_timer.name = audio_stream_player.name + "FadeInTimer"
	fade_in_timer.wait_time = length
	fade_in_timer.autostart = true
	fade_in_timer.one_shot = true
	audio_stream_player.add_child(fade_in_timer)

func calculate_scaled_curve(curve : Curve, length : float):
	print("calc")
	var scaled_curve : Curve = Curve.new()
	for point in curve.point_count:
		var position : Vector2 = curve.get_point_position(point)
		position.x = position.x * (length / curve.get_length())
		scaled_curve.add_point(position)
		
	return scaled_curve
		
func pause_one(audio_stream_player : AudioStreamPlayer):
	for node in get_children():
		if node == audio_stream_player:
			node.stop()

##Pause all audio nodes of a specific type
func pause_type(label: Labels):
	for node in get_children():
		if Labels.keys()[label] not in node.name:
			continue
		if node is not AudioStreamPlayer:
			continue
		node.stop()

## Pause all audio nodes
func pause_all():
	for node in get_children():
		if node is AudioStreamPlayer:
			node.stop()
			continue
		if node is Timer:
			node.stop()
			continue

func clear_one(audio_stream_player : AudioStreamPlayer):
	for node in get_children():
		if node == audio_stream_player:
			node.stream_paused = false

## remove all playing audio of a specific type
func clear_type(label : Labels):
	for node in get_children():
		if Labels.keys()[label] in node.name:
			node.queue_free()

## remove all audio nodes
func clear_all():
	for node in get_children():
		node.queue_free()

func _process(_delta):
	for node in get_children():
		if node is not AudioStreamPlayer:
			continue
		for child in node.get_children():
			#print(node.name + "FadeInTimer") 
			#print(child)
			if "FadeInTimer" in child.name:
				if child != null:
					print(child.time_left)
					if child.time_left > 0:
						#print("fade in time")
						apply_fade_in_curve(node)
					elif child.time_left == 0:
						#print("delete")
						node.fade_in = false
						child.queue_free()

func apply_fade_in_curve(audio_stream_player : AudioStreamPlayer):
	var curve = audio_stream_player.scaled_fade_in_curve
	var position = audio_stream_player.get_playback_position()
	var volume_multiplier = curve.sample(position - audio_stream_player.initial)
	print(curve)
	print(position - audio_stream_player.initial)
	print(volume_multiplier)
	print(audio_stream_player.volume_db)
	audio_stream_player.volume_db = linear_to_db(db_to_linear(audio_stream_player.calculated_volume) * volume_multiplier)
	print(audio_stream_player.volume_db)

func node_to_label(audio_stream_player : AudioStreamPlayer):
	var text = audio_stream_player.name.remove_chars("1234567890")
	text = text.to_upper()
	return Labels[text]
