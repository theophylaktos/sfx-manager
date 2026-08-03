extends Node

var node

# Called when the node enters the scene tree for the first time.
func _ready():
	node = SFX.play_new(SFX.Labels.AMBIENCE)
	await get_tree().create_timer(3).timeout
	SFX.pause_one(node)
	await get_tree().create_timer(3).timeout
	print("shud be unpausing")
	SFX.unpause_one(node, true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#SFX.play(SFX.Labels.SAND)
