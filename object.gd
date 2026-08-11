extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	SFX.play_2d(SFX.Id.FALL, self, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
