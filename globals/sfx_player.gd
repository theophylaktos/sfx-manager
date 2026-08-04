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

@export var label_to_setting: Dictionary[Labels, SfxSettings]

## Play a sound effect, as defined by label. Intended should be SFX.play(SFX.Labels.NAME)
func play_new(label: Labels, loop : bool = false, optional_volume: float = 0.0, optional_pitch: float = 0.0):
	# Checks if a min_delay_timer is in the scene tree, and if so, return early
	if has_node(Labels.keys()[label] + "MinDelayTimer"):
		return
	
	## The instance of an AudioStreamPlayer
	var audio_stream_player = AudioStreamPlayer.new()
	
	## The instance of sfx_settings.gd
	var setting = label_to_setting[label]
	audio_stream_player.bus = setting.bus
	audio_stream_player.stream = setting.stream
	audio_stream_player.name = Labels.keys()[label] + str(counter)
	counter += 1
	audio_stream_player.volume_db = setting.volume + randf_range(-1,1) * setting.volume_variance + optional_volume
	audio_stream_player.pitch_scale = setting.pitch + randf_range(-1,1) * setting.pitch_variance + optional_pitch
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
	min_delay_timer.name = Labels.keys()[label] + "MinDelayTimer"
	min_delay_timer.wait_time = setting.min_delay
	min_delay_timer.autostart = true
	min_delay_timer.timeout.connect(min_delay_timer.queue_free)
	add_child(min_delay_timer)

## Play all audio nodes of a specific type
func unpause_one(audio_stream_player: AudioStreamPlayer, fade: bool = false):
	for node in get_children():
		if node == audio_stream_player:
			if fade == true:
				create_fade(node, "unpause")
			else:
				node.play()
		if node.name == Labels.keys()[node_to_label(audio_stream_player)] +  "MinDelayTimer":
			node.set_paused(false)

## Play all audio nodes that use a certain label
func unpause_type(label: Labels, fade: bool = false):
	for node in get_children():
		if node is AudioStreamPlayer:
			if Labels.keys()[label] not in node.name:
				continue
			if fade == true:
				create_fade(node, "unpause")
			else:
				node.play()
		if node is Timer:
			if node.name == Labels.keys()[label] +  "MinDelayTimer":
				node.set_paused(false)

## Play all audio nodes
func unpause_all(fade: bool = false):
	for node in get_children():
		if node is AudioStreamPlayer:
			if fade == true:
				create_fade(node, "unpause")
			else:
				node.play()
		if node is Timer:
			node.set_paused(false)

func pause_one(audio_stream_player : AudioStreamPlayer, fade: bool = false):
	for node in get_children():
		if node == audio_stream_player:
			if fade == true:
				create_fade(node, "pause")
			else:
				node.stop()
		if node.name == Labels.keys()[node_to_label(audio_stream_player)] +  "MinDelayTimer":
			node.set_paused(true)

##Pause all audio nodes of a specific type
func pause_type(label: Labels, fade: bool = false):
	for node in get_children():
		if node is AudioStreamPlayer:
			if Labels.keys()[label] not in node.name:
				continue
			if fade == true:
				create_fade(node, "pause")
			else:
				node.stop()
		if node is Timer:
			if node.name == Labels.keys()[label] +  "MinDelayTimer":
				node.set_paused(true)

## Pause all audio nodes
func pause_all(fade: bool = false):
	for node in get_children():
		if node is AudioStreamPlayer:
			if fade == true:
				create_fade(node, "pause")
			else:
				node.stop()
		if node is Timer:
			node.set_paused(true)

func clear_one(audio_stream_player : AudioStreamPlayer, fade: bool = false):
	for node in get_children():
		if node == audio_stream_player:
			if fade == true:
				create_fade(node, "clear")
			else:
				node.queue_free()
		if node.name == Labels.keys()[node_to_label(node)] +  "MinDelayTimer":
			node.queue_free()

## remove all playing audio of a specific type
func clear_type(label : Labels, fade: bool = false):
	for node in get_children():
		if node is AudioStreamPlayer:
			if Labels.keys()[label] not in node.name:
				continue
			if fade == true:
				create_fade(node, "clear")
			else:
				node.queue_free()
		if node is Timer:
			if node.name == Labels.keys()[node_to_label(node)] +  "MinDelayTimer":
				node.queue_free()

## remove all audio nodes
func clear_all(fade: bool = false):
	for node in get_children():
		if fade:
			create_fade(node, "clear")
		else:
			node.queue_free()

func create_fade(audio_stream_player : AudioStreamPlayer, type : String, length : float = 1.0):
	var final_multiplier
	
	if type == "unpause":
		print("fade_in")
		final_multiplier = 1
		add_fade_in_timer(audio_stream_player, length)
	if type == "pause" or type == "clear":
		print("fade_out")
		final_multiplier = 0
		add_fade_out_timer(audio_stream_player, length)
		
	#var tween : Tween = audio_stream_player.create_tween()
	#if type == "unpause":
		#audio_stream_player.volume_db = linear_to_db(0.0)
		#tween.tween_property(audio_stream_player, "volume_db", linear_to_db(final_multiplier * db_to_linear(audio_stream_player.volume_db)), length)
	#if type == "pause" or type == "clear":
		#tween.tween_property(audio_stream_player, "volume_db", linear_to_db(final_multiplier * db_to_linear(audio_stream_player.volume_db)), length)
	#print(tween)
	
	#if type == "unpause":
		#audio_stream_player.stream_paused = false
	#if type == "pause":
		#audio_stream_player.stream_paused = true
	#if type == "clear":
		#audio_stream_player.queue_free()

func add_fade_in_timer(audio_stream_player : AudioStreamPlayer, length : float):
	print("timer")
	var fade_in_timer : Timer = Timer.new()
	fade_in_timer.name = audio_stream_player.name + "FadeInTimer"
	fade_in_timer.wait_time = length
	fade_in_timer.autostart = true
	fade_in_timer.one_shot = true
	audio_stream_player.add_child(fade_in_timer)
	
func add_fade_out_timer(audio_stream_player : AudioStreamPlayer, length : float):
	print("timer")
	var fade_out_timer : Timer = Timer.new()
	fade_out_timer.name = audio_stream_player.name + "FadeOutTimer"
	fade_out_timer.wait_time = length
	fade_out_timer.autostart = true
	fade_out_timer.one_shot = true
	audio_stream_player.add_child(fade_out_timer)

func _process(delta):
	for node in get_children():
		if node is not AudioStreamPlayer:
			continue
		for child in node.get_children():
			if "FadeInTimer" not in child.name:
				continue
			if child == null:
				continue
			print(child.time_left)
			if child.time_left > 0:
				node.volume_db = linear_to_db(preload("uid://b558ipjpf7jwo").sample(child.time_left)) + label_to_setting[node_to_label(node)].volume
				print(node.volume_db)
				print("--")
			elif child.time_left == 0:
				print("fade over,delete")
				child.queue_free()
		for child in node.get_children():
			if "FadeOutTimer" not in child.name:
				continue
			if child == null:
				continue
			if child.time_left > 0:
				node.volume_db = linear_to_db(preload("uid://d2651b3sfawfp").sample(child.time_left)) + label_to_setting[node_to_label(node)].volume
				print(child.time_left)
				print(node.volume_db)
				print("--")
			elif child.time_left == 0:
				print("fade over,delete")
				child.queue_free()

func node_to_label(audio_stream_player : AudioStreamPlayer):
	var text = audio_stream_player.name.remove_chars("1234567890")
	text = text.to_upper()
	return Labels[text]
