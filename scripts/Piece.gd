extends Sprite
class_name Piece

func _ready():
	pass

func set_type(type : int) -> void:
	scale = Vector2(0.25, 0.25)
	
	if type == Globals.piece_type.GRASS:
		texture = Globals.texture_grass
	elif type == Globals.piece_type.ROCK:
		texture = Globals.texture_rock
	elif type == Globals.piece_type.WOOD:
		texture = Globals.texture_wood
	
	texture = texture.duplicate()
	
	$StaticBody2D.collision_layer = 1 << (type)
	$StaticBody2D.collision_mask = 1 << (type)


func _on_DespawnTimer_timeout():
	queue_free()
