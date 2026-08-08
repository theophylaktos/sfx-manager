extends Node

var node
var node2

# Called when the node enters the scene tree for the first time.
func _ready():
	#pass
	node = SFX.play(SFX.Id.AMBIENCE)
	await get_tree().create_timer(2).timeout
	SFX.pause_all(true, 5)
	await get_tree().create_timer(3).timeout
	SFX.unpause_one(node, true, 5)
	#await get_tree().create_timer(3).timeout
	#SFX.pause_one(node, true, 5)
	#await get_tree().create_timer(3).timeout
	#SFX.unpause_one(node, true, 5)
	#await get_tree().create_timer(3).timeout
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#SFX.play(SFX.Labels.SAND)
