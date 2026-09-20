extends Node

var node: Node
var node2: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass
	node = SFX.play(SFX.Id.HIT, true)
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
func _process(_delta: float) -> void:
	pass
	#SFX.play(SFX.Labels.SAND)
