extends Node

var node
var node2

# Called when the node enters the scene tree for the first time.
func _ready():
	#pass
	node = SFX.play(SFX.Labels.AMBIENCE)
	await get_tree().create_timer(2).timeout
	node2 = SFX.play(SFX.Labels.AMBIENCE)
	await get_tree().create_timer(5).timeout
	SFX.pause_type(SFX.Labels.AMBIENCE, true, 3)
	await get_tree().create_timer(5).timeout
	SFX.unpause_one(node, true, 12)
	await get_tree().create_timer(5).timeout
	SFX.clear_all(true, 3)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#SFX.play(SFX.Labels.SAND)
