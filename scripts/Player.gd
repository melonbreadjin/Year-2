extends Sprite

var player_pos : Vector2
var player_direction : Vector2

var player_state_machine

func _ready():
	player_pos = Vector2(3, 3)
	player_direction = Vector2.RIGHT
	
	player_state_machine = get_node("AnimationTree")["parameters/playback"]

func _unhandled_key_input(event : InputEventKey) -> void:
	if event.is_action_pressed("player_up"):
		if player_pos.y - 1 < 0:
			return
		
		if player_direction == Vector2.UP:
			player_pos.y -= 1
			Globals.emit_signal("sgn_update_player_pos", player_pos)
			Globals.emit_signal("sgn_update_turn", 1)
			Globals.emit_signal("sgn_play_sfx", Globals.a_move)
			
			player_state_machine.travel("hop")
		else:
			player_direction = Vector2.UP
			$Area/F.rotation_degrees = -90
		
		flip_h = true
	elif event.is_action_pressed("player_down"):
		if player_pos.y + 1 >= Globals.GRID_SIZE.y:
			return
		
		if player_direction == Vector2.DOWN:
			player_pos.y += 1
			Globals.emit_signal("sgn_update_player_pos", player_pos)
			Globals.emit_signal("sgn_update_turn", 1)
			Globals.emit_signal("sgn_play_sfx", Globals.a_move)
			
			player_state_machine.travel("hop")
		else:
			player_direction = Vector2.DOWN
			$Area/F.rotation_degrees = 90
		
		flip_h = false
	elif event.is_action_pressed("player_left"):
		if player_pos.x - 1 < 0:
			return
		
		if player_direction == Vector2.LEFT:
			player_pos.x -= 1
			Globals.emit_signal("sgn_update_player_pos", player_pos)
			Globals.emit_signal("sgn_update_turn", 1)
			Globals.emit_signal("sgn_play_sfx", Globals.a_move)
			
			player_state_machine.travel("hop")
		else:
			player_direction = Vector2.LEFT
			$Area/F.rotation_degrees = 180
		
		flip_h = true
	elif event.is_action_pressed("player_right"):
		if player_pos.x + 1 >= Globals.GRID_SIZE.x:
			return
		
		if player_direction == Vector2.RIGHT:
			player_pos.x += 1
			Globals.emit_signal("sgn_update_player_pos", player_pos)
			Globals.emit_signal("sgn_update_turn", 1)
			Globals.emit_signal("sgn_play_sfx", Globals.a_move)
			
			player_state_machine.travel("hop")
		else:
			player_direction = Vector2.RIGHT
			$Area/F.rotation_degrees = 0
		
		flip_h = false
