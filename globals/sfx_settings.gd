extends Resource
class_name SfxSettings


## The AudioStream to be played
@export var stream: AudioStream
##The Audio Bus for the audio to be played on.
@export var bus: String
## Volume in decibels.
@export var volume: float = 0.0
## A random value between [code]volume_variance[/code] and [code]volume_variance * -1[/code] 
## is added to the volume of of the audio each time it is played.
@export var volume_variance: float = 1.5
## The pitch scale, defined in semitones. Note that this will change the speed of the audio (negligle at low values)
@export var pitch: float = 1.0
## A random value between [code]pitch_variance[/code] and [code]pitch_variance * -1[/code] 
## is added to the pitch of of the audio each time it is played.
@export var pitch_variance: float = 0.1
## Minimum delay between repeated instances playing.
@export var min_delay : float = 0.0
