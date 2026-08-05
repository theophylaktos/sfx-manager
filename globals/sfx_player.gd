extends Node
# This node (the scene) to be added as a global named SFX

enum Labels {
	FALL,
	AMBIENCE,
	SAND,
}

## TRUE = get debug messages each time a sound is played, FALSE = no debug messages
const print_sounds: bool = true

## Variable to make each AudioStreamPlayer's name unique. Increased by one per new audio_stream_player
var counter : int = 0

@export var label_to_setting: Dictionary[Labels, SfxSettings]

## Play a sound effect, as defined by label. Intended should be SFX.play(SFX.Labels.NAME)
func play(label: Labels, loop : bool = false, optional_volume: float = 0.0, optional_pitch: float = 0.0):
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
		_add_min_delay_timer(label)
		
	return audio_stream_player

#region unpause, pause, clear, play_2d

## Unpause all audio nodes of a specific type
func unpause_one(audio_stream_player: AudioStreamPlayer, fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node == audio_stream_player:
			if fade == true:
				_add_fade_timer(node, "unpause", fade_length)
			else:
				node.play()
		if node.name == Labels.keys()[_node_to_label(audio_stream_player)] +  "MinDelayTimer":
			node.set_paused(false)

## Play all audio nodes that use a certain label
func unpause_type(label: Labels, fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node is AudioStreamPlayer:
			if Labels.keys()[label] not in node.name:
				continue
			if fade == true:
				_add_fade_timer(node, "unpause", fade_length)
			else:
				node.play()
		if node is Timer:
			if node.name == Labels.keys()[label] +  "MinDelayTimer":
				node.set_paused(false)

## Play all audio nodes
func unpause_all(fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node is AudioStreamPlayer:
			if fade == true:
				_add_fade_timer(node, "unpause", fade_length)
			else:
				node.play()
		if node is Timer:
			node.set_paused(false)

func pause_one(audio_stream_player : AudioStreamPlayer, fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node == audio_stream_player:
			if fade == true:
				_add_fade_timer(node, "pause", fade_length)
			else:
				node.stop()
		if node.name == Labels.keys()[_node_to_label(audio_stream_player)] +  "MinDelayTimer":
			node.set_paused(true)

##Pause all audio nodes of a specific type
func pause_type(label: Labels, fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node is AudioStreamPlayer:
			if Labels.keys()[label] not in node.name:
				continue
			if fade == true:
				_add_fade_timer(node, "pause", fade_length)
			else:
				node.stop()
		if node is Timer:
			if node.name == Labels.keys()[label] +  "MinDelayTimer":
				node.set_paused(true)

## Pause all audio nodes
func pause_all(fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node is AudioStreamPlayer:
			if fade == true:
				_add_fade_timer(node, "pause", fade_length)
			else:
				node.stop()
		if node is Timer:
			node.set_paused(true)

func clear_one(audio_stream_player : AudioStreamPlayer, fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node == audio_stream_player:
			if fade == true:
				_add_fade_timer(node, "clear", fade_length)
			else:
				node.queue_free()
		if node.name == Labels.keys()[_node_to_label(node)] +  "MinDelayTimer":
			node.queue_free()

## remove all playing audio of a specific type
func clear_type(label : Labels, fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node is AudioStreamPlayer:
			if Labels.keys()[label] not in node.name:
				continue
			if fade == true:
				_add_fade_timer(node, "clear", fade_length)
			else:
				node.queue_free()
		if node is Timer:
			if node.name == Labels.keys()[_node_to_label(node)] +  "MinDelayTimer":
				node.queue_free()

## remove all audio nodes
func clear_all(fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if fade:
			_add_fade_timer(node, "clear", fade_length)
		else:
			node.queue_free()

func play_2d(label : Labels, node : Node):
	var setting = label_to_setting[label]
	var audio_stream_player_2d : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	AudioStreamPlayer2D.stream = setting.stream
	AudioStreamPlayer2D.volume_db = setting.volume
	AudioStreamPlayer2D.pitch_scale = setting.pitch
	AudioStreamPlayer2D.bus = setting.bus
	node.add_child(audio_stream_player_2d)
	
func play_3d(label : Labels, node : Node):
	var setting = label_to_setting[label]
	var audio_stream_player_3d : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	AudioStreamPlayer3D.stream = setting.stream
	AudioStreamPlayer3D.volume_db = setting.volume
	AudioStreamPlayer3D.pitch_scale = setting.pitch
	AudioStreamPlayer3D.bus = setting.bus
	node.add_child(audio_stream_player_3d)

#endregion

#region _add_min_delay_timer, _add_fade_timer, _process, _node_to_label

func _add_min_delay_timer(label : Labels):
	var setting = label_to_setting[label]
	var min_delay_timer : Timer = Timer.new()
	min_delay_timer.name = Labels.keys()[label] + "MinDelayTimer"
	min_delay_timer.wait_time = setting.min_delay
	min_delay_timer.autostart = true
	min_delay_timer.timeout.connect(min_delay_timer.queue_free)
	add_child(min_delay_timer)

func _add_fade_timer(audio_stream_player : AudioStreamPlayer, type : String, length : float = 1.0):
	var timer : Timer = Timer.new()
	timer.name = audio_stream_player.name + type
	timer.wait_time = length
	timer.autostart = true
	timer.one_shot = true
	audio_stream_player.add_child(timer)

func _process(_delta):
	for node in get_children():
		if node is not AudioStreamPlayer:
			continue
		#print(node.get_playback_position())
		for child in node.get_children():
			var type : String
			if "unpause" in child.name:
				type = "unpause"
			elif "pause" in child.name:
				type = "pause"
			elif "clear" in child.name:
				type = "clear"
			#print(child.time_left)
			if child.time_left > 0:
				#print(node.volume_db)
				var volume : float = label_to_setting[_node_to_label(node)].volume
				if type == "unpause":
					node.stream_paused = false
					node.volume_db = linear_to_db(preload("uid://b558ipjpf7jwo").sample(child.time_left / child.wait_time)) + volume
				if type == "pause" or type == "clear":
					node.volume_db = linear_to_db(preload("uid://d2651b3sfawfp").sample(child.time_left / child.wait_time)) + volume
					
			if child.time_left == 0:
				child.queue_free()
				if type == "unpause":
					node.stream_paused = false
				if type == "pause":
					node.stream_paused = true
				if type == "clear":
					node.queue_free()
		#print("--")

func _node_to_label(audio_stream_player : AudioStreamPlayer):
	var text = audio_stream_player.name.remove_chars("1234567890")
	text = text.to_upper()
	return Labels[text]

#endregion
