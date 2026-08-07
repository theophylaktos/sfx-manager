extends Node
## How to use this SFX Manager:
##
## Setup:
## Copy all of the files inside of the "globals" folder into your project.
## Add the SCENE "sfx_player.tscn" as an autoload in your project.
##
## Use:
## When you want to add a new sound, start by loading the file into Godot.
## Add a descriptive name to the enum "Labels" in sfx_player.gd.
## This name should be in ALL_CAPS.
## Go into the inspector of the node "SfxPlayer" in sfx_player.gd.
## In the dictionary "Label to Setting," add a new pair of a key and a setting.
## Select your audio file as the "stream."
## Make sure to click "Add Key/Value Pair"!!
## You can now call SFX.play(SFX.Labels.YOUR_LABEL).

# Optionally, append a comment (##) after each label to describe where it is used [br]
## List of all sounds. Add a new label here when you add a new sound.
enum Labels {
	FALL, 
	AMBIENCE,
	SAND,
}

## [code]TRUE[/code]: Print debug messages [br]
## [code]FALSE[/code]: Do not print debug messages
const DEBUG_MESSAGES: bool = false

## Variable to make each [AudioStreamPlayer]'s name unique. 
## Increased by one when a new [AudioStreamPlayer] is instantiated.
var counter : int = 0

## A dictionary storing labels from [code]SFX.Labels[/code] and the associated [code]sfx_settings.gd[/code]
@export var label_to_setting: Dictionary[Labels, SfxSettings]

const SFX_PLAYER_SETTINGS = preload("uid://08s6w51f3gvp")

## [b]Play a sound in a new [AudioStreamPlayer], as defined by [param label]. This is called as[/b] [code]SFX.play(SFX.Labels.NAME)[/code]. [br]
##[br]
## [param label]: The sound you want to play, defined in SFX.Labels [br]
## [param loop]: Whether the sound should loop or not. [code]Default: FALSE[/code] [br]
## [param volume_mod]: Volume that is added after variation is calculated. [code]Default: 0.0[/code] [br]
## [param pitch_mod]: Pitch that is added after variation is calculated. [code]Default: 0.0[/code] [br]
## [br]
## Returns the newly instantiated [AudioStreamPlayer]
func play(label: Labels, loop : bool = false, volume_mod: float = 0.0, pitch_mod: float = 0.0):
	# Checks if a min_delay_timer is in the scene tree, and if so, return early
	if has_node(Labels.keys()[label] + "MinDelayTimer"):
		return
	
	## The instance of an AudioStreamPlayer
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.set_script(SFX_PLAYER_SETTINGS)
	
	## The instance of sfx_settings.gd
	var setting = label_to_setting[label]
	audio_stream_player.bus = setting.bus
	audio_stream_player.stream = setting.stream
	audio_stream_player.name = Labels.keys()[label] + str(counter)
	counter += 1
	audio_stream_player.volume_db = setting.volume + randf_range(-1,1) * setting.volume_variance + volume_mod
	audio_stream_player.pitch_scale = setting.pitch + randf_range(-1,1) * setting.pitch_variance + pitch_mod
	if loop == true:
		audio_stream_player.stream.loop = true
	
	add_child(audio_stream_player)
	audio_stream_player.finished.connect(audio_stream_player.queue_free)
	audio_stream_player.playing = true
	
	if DEBUG_MESSAGES:
		print("Played one sound: ", audio_stream_player)
		
	if setting.min_delay != 0:
		_add_min_delay_timer(label)
		
	return audio_stream_player
	
## [b] Play a random sound from [param labels], in a new [AudioStreamPlayer] [/b] [br]
## This is called as [code]SFX.play_random([SFX.Labels.NAME1, SFX.Labels.NAME2])[/code] [br]
## [br]
## [param labels]: An array of labels you want to play [br]
## [param loop]: Whether the sound should loop or not. [code]Default: FALSE[/code] [br]
## [param volume_mod]: Volume that is added after variation is calculated. [code]Default: 0.0[/code] [br]
## [param pitch_mod]: Pitch that is added after variation is calculated. [code]Default: 0.0[/code] [br]
## [br]
## Returns the newly instantiated [AudioStreamPlayer]
func play_random(labels : Array[Labels] = [], loop : bool = false, volume_mod: float = 0.0, pitch_mod: float = 0.0):
	var sound :int = randi_range(0,labels.size() - 1)
	var label : Labels = labels[sound]
	var node : AudioStreamPlayer = SFX.play(label, loop, volume_mod, pitch_mod)
	var keys : Array[String] = []
	for i in labels:
		keys.append(Labels.find_key(i))
	print("Played random sound: ", node, ", chosen from ", keys)
	return node

#region unpause, pause, clear, play_2d
## [b]Unpause one [AudioStreamPlayer], with an optional fade in[/b] [br]
## [br]
## [param audio_stream_player]: The [AudioStreamPlayer] to be unpaused [br]
## [param fade]: Whether the audio should fade out. [code]Default: FALSE[/code] [br]
## [param fade_length]: In seconds, how long the sound should fade in for. [code][code]Default: 1.0[/code][/code]
func unpause_one(audio_stream_player: AudioStreamPlayer, fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node == audio_stream_player:
			if fade == true:
				_add_fade_timer(node, "unpause", fade_length)
			else:
				node.play()
		# If the node is a MinDelayTimer, unpause it
		if node.name == Labels.keys()[_node_to_label(audio_stream_player)] +  "MinDelayTimer":
			node.set_paused(false)
			
	if DEBUG_MESSAGES:
		print("Unpaused one sound: ", audio_stream_player)

## [b]Unpause all [AudioStreamPlayer]s of a specific label, with an optional fade in[/b] [br]
## [br]
## [param label]: [AudioStreamPlayer]s that use this label will be unpaused [br]
## [param fade]: Whether the audio should fade in. [code]Default: FALSE[/code] [br]
## [param fade_length]: In seconds, how long the sound should fade in for. [code]Default: 1.0[/code]
func unpause_type(label: Labels, fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node is AudioStreamPlayer:
			if Labels.keys()[label] not in node.name:
				continue
			if fade == true:
				_add_fade_timer(node, "unpause", fade_length)
			else:
				node.play()
		# If the node is a MinDelayTimer, unpause it
		if node.name == Labels.keys()[label] +  "MinDelayTimer":
			node.set_paused(false)
			
	if DEBUG_MESSAGES:
		print("Unpaused all sounds of type: ", Labels.keys()[label])

## [b]Unpause all [AudioStreamPlayer]s, with an optional fade in[/b] [br]
## [br]
## [param fade]: Whether the audio should fade in. [code]Default: FALSE[/code] [br]
## [param fade_length]: In seconds, how long the sound should fade in for. [code]Default: 1.0[/code]
func unpause_all(fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node is AudioStreamPlayer:
			if fade == true:
				_add_fade_timer(node, "unpause", fade_length)
			else:
				node.play()
		# If the node is a MinDelayTimer, unpause it
		if node.name.contains("MinDelayTimer"):
			node.set_paused(false)
			
	if DEBUG_MESSAGES:
		print("Unpaused all sounds")

## [b]Pause one [AudioStreamPlayer], with an optional fade out.[/b] [br]
## [br]
## [param audio_stream_player]: The [AudioStreamPlayer] to be paused [br]
## [param fade]: Whether the audio should fade out. [code]Default: FALSE[/code] [br]
## [param fade_length]: In seconds, how long the sound should fade out for. [code]Default: 1.0[/code]
func pause_one(audio_stream_player : AudioStreamPlayer, fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node == audio_stream_player:
			if fade == true:
				_add_fade_timer(node, "pause", fade_length)
			else:
				node.stop()
		# If the node is a MinDelayTimer, unpause it
		if node.name == Labels.keys()[_node_to_label(audio_stream_player)] +  "MinDelayTimer":
			node.set_paused(true)
			
	if DEBUG_MESSAGES:
		print("Paused one sound: ", audio_stream_player)

## [b]Pause all [AudioStreamPlayer]s of a specific label, with an optional fade in[/b] [br]
## [br]
## [param label]: [AudioStreamPlayer]s that use this label will be paused [br]
## [param fade]: Whether the audio should fade out. [code]Default: FALSE[/code] [br]
## [param fade_length]: In seconds, how long the sound should fade out for. [code]Default: 1.0[/code]
func pause_type(label: Labels, fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node is AudioStreamPlayer:
			if Labels.keys()[label] not in node.name:
				continue
			if fade == true:
				_add_fade_timer(node, "pause", fade_length)
			else:
				node.stop()
		# If the node is a MinDelayTimer, unpause it
		if node.name == Labels.keys()[label] +  "MinDelayTimer":
			node.set_paused(true)
			
	if DEBUG_MESSAGES:
		print("Paused all sounds of type: ", Labels.keys()[label])

## [b]Pause all [AudioStreamPlayer]s, with an optional fade out[/b] [br]
## [br]
## [param fade]: Whether the audio should fade out. [code]Default: FALSE[/code] [br]
## [param fade_length]: In seconds, how long the sound should fade out for. [code]Default: 1.0[/code]
func pause_all(fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node is AudioStreamPlayer:
			if fade == true:
				_add_fade_timer(node, "pause", fade_length)
			else:
				node.stop()
		# If the node is a MinDelayTimer, unpause it
		if node.name.contains("MinDelayTimer"):
			node.set_paused(true)
			
	if DEBUG_MESSAGES:
		print("Paused all sounds")

## [b]Clear one [AudioStreamPlayer], with an optional fade out.[/b] [br]
## [br]
## [param audio_stream_player]: The [AudioStreamPlayer] to be paused [br]
## [param fade]: Whether the audio should fade out. [code]Default: FALSE[/code] [br]
## [param fade_length]: In seconds, how long the sound should fade out for. [code]Default: 1.0[/code]
func clear_one(audio_stream_player : AudioStreamPlayer, fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node == audio_stream_player:
			if fade == true:
				_add_fade_timer(node, "clear", fade_length)
			else:
				node.queue_free()
		# If the node is a MinDelayTimer, unpause it
		if node.name == Labels.keys()[_node_to_label(audio_stream_player)] +  "MinDelayTimer":
			node.queue_free()
			
	if DEBUG_MESSAGES:
		print("cleared one sound: ", audio_stream_player)

## [b]Clear all [AudioStreamPlayer]s of a specific label, with an optional fade out[/b] [br]
## [br]
## [param label]: [AudioStreamPlayer]s that use this label will be cleared [br]
## [param fade]: Whether the audio should fade out. [code]Default: FALSE[/code] [br]
## [param fade_length]: In seconds, how long the sound should fade out for. [code]Default: 1.0[/code]
func clear_type(label : Labels, fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node is AudioStreamPlayer:
			if Labels.keys()[label] not in node.name:
				continue
			if fade == true:
				_add_fade_timer(node, "clear", fade_length)
			else:
				node.queue_free()
		# If the node is a MinDelayTimer, unpause it
		if node.name == Labels.keys()[label] +  "MinDelayTimer":
			node.queue_free()
			
	if DEBUG_MESSAGES:
		print("Cleared all sounds of type: ", Labels.keys()[label])

## [b]Clear all [AudioStreamPlayer]s, with an optional fade out[/b] [br]
## [br]
## [param fade]: Whether the audio should fade out. [code]Default: FALSE[/code] [br]
## [param fade_length]: In seconds, how long the sound should fade out for. [code]Default: 1.0[/code]
func clear_all(fade: bool = false, fade_length : float = 1.0):
	for node in get_children():
		if node is AudioStreamPlayer:
			if fade == true:
				_add_fade_timer(node, "clear", fade_length)
			else:
				node.queue_free()
		# If the node is a MinDelayTimer, unpause it
		if node.name.contains("MinDelayTimer"):
			node.queue_free()
			
	if DEBUG_MESSAGES:
		print("Cleared all sounds")

## [b]Attach an AudioStreamPlayer2D as a child of a node[/b] [br]
## [br]
## [param label]: The label that the [AudioStreamPlayer2D] should use [br]
## [param node]: The node that the [AudioStreamPlayer2D] should be attached on
## [param loop]: Whether the sound should loop or not. [code]Default: FALSE[/code] [br]
## [br]
## Returns the newly instantiated [AudioStreamPlayer2D]
func play_2d(label : Labels, node : Node, loop : bool = false):
	var setting = label_to_setting[label]
	var audio_stream_player_2d : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	AudioStreamPlayer2D.stream = setting.stream
	AudioStreamPlayer2D.volume_db = setting.volume + randf_range(-1,1) * setting.volume_variance
	AudioStreamPlayer2D.pitch_scale = setting.pitch +  + randf_range(-1,1) * setting.pitch_variance
	AudioStreamPlayer2D.bus = setting.bus
	node.add_child(audio_stream_player_2d)
	
	if loop == true:
		audio_stream_player_2d.stream.loop = true
	
	return audio_stream_player_2d

## [b]Attach an AudioStreamPlayer3D as a child of a node[/b] [br]
## [br]
## [param label]: The label that the [AudioStreamPlayer3D] should use [br]
## [param node]: The node that the [AudioStreamPlayer3D] should be attached on
## [param loop]: Whether the sound should loop or not. [code]Default: FALSE[/code] [br]
## [br]
## Returns the newly instantiated [AudioStreamPlayer3D]
func play_3d(label : Labels, node : Node, loop : bool = false):
	var setting = label_to_setting[label]
	var audio_stream_player_3d : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	
	AudioStreamPlayer3D.stream = setting.stream
	AudioStreamPlayer3D.volume_db = setting.volume + randf_range(-1,1) * setting.volume_variance
	AudioStreamPlayer3D.pitch_scale = setting.pitch +  + randf_range(-1,1) * setting.pitch_variance
	AudioStreamPlayer3D.bus = setting.bus
	
	if loop == true:
		audio_stream_player_3d.stream.loop = true
	
	node.add_child(audio_stream_player_3d)
	
	return audio_stream_player_3d

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

func _add_fade_timer(audio_stream_player : AudioStreamPlayer, type : String, length : float):
	var timer : Timer = Timer.new()
	timer.name = audio_stream_player.name + type
	timer.wait_time = length
	timer.autostart = true
	timer.one_shot = true
	audio_stream_player.add_child(timer)
	audio_stream_player.volume_limit = audio_stream_player.volume_db

func _process(_delta):
	for node in get_children():
		if node is not AudioStreamPlayer:
			continue
		
		for timer in node.get_children():
			var type : String
			if "unpause" in timer.name:
				type = "unpause"
			elif "pause" in timer.name:
				type = "pause"
			elif "clear" in timer.name:
				type = "clear"
				
			if timer.time_left > 0:
				var volume : float = label_to_setting[_node_to_label(node)].volume
				if type == "unpause": ## Fade in
					node.stream_paused = false
					var distance_through_curve = (timer.wait_time - timer.time_left) / timer.wait_time
					var multiplicand = (db_to_linear(volume) - db_to_linear(node.volume_limit)) / db_to_linear(volume)
					var adder = db_to_linear(node.volume_limit - volume)
					node.volume_db = linear_to_db((distance_through_curve * multiplicand) + adder) + volume
				if type == "pause" or type == "clear": ## Fade out
					node.volume_db = linear_to_db(timer.time_left / timer.wait_time) + node.volume_limit
					
			if timer.time_left == 0:
				timer.queue_free()
				if type == "unpause":
					node.stream_paused = false
				if type == "pause":
					node.stream_paused = true
				if type == "clear":
					node.queue_free()

## [b]Accepts a node of type [AudioStreamPlayer], and returns its associated label.[/b] [br]
## [br]
## [param audio_stream_player]: The [AudioStreamPlayer] whose label will be returned
func _node_to_label(audio_stream_player : AudioStreamPlayer):
	var text = audio_stream_player.name.remove_chars("1234567890")
	text = text.to_upper()
	return Labels[text]
#endregion
