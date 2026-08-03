extends Resource
class_name SfxSettings

##The bus for the audio to be played on
@export var bus: String
## the audio stream to be played
@export var stream: AudioStream
## volume in decibels
@export var volume: float = 0.0
## +- this amount to the volume
@export var volume_variance: float = 0.0
## the pitch scale (multiplier on the pitch)
@export var pitch: float = 1.0
## += this amount to the pitch scale
@export var pitch_variance: float = 0.0
## Minimum delay between repeated instances playing. 0.0 means no delay
@export var min_delay : float = 1.0

## The curve for the fade in after calling an unpause() function
@export var unpause_fade_curve: Curve
## The curve for the fade out after calling a pause() or clear() function
@export var pause_clear_fade_curve: Curve
