extends Node

var node

# Called when the node enters the scene tree for the first time.
func _ready():
	node = SFX.play(SFX.Labels.AMBIENCE)
	await get_tree().create_timer(5).timeout
	SFX.pause_one(node, true, 3)
	await get_tree().create_timer(5).timeout
	print("shud be unpausing")
	SFX.unpause_one(node, true, 12)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#SFX.play(SFX.Labels.SAND)
