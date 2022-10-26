extends Sprite

var player_pos : Vector2
var player_direction : Vector2

var is_ingame : bool = false

var player_state_machine

func _ready():
	player_state_machine = get_node("AnimationTree")["parameters/playback"]

	var _sgn = Globals.connect("sgn_new_game", self, "on_sgn_new_game")
	_sgn = Globals.connect("sgn_end_game", self, "on_sgn_end_game")

func on_sgn_new_game() -> void:
	player_pos = Vector2(3, 3)
	player_direction = Vector2.RIGHT
	
	Globals.emit_signal("sgn_update_player_pos", player_pos)
	
	$Area/F.rotation_degrees = 0
	flip_h = false
	
	is_ingame = true

func on_sgn_end_game() -> void:
	is_ingame = false

func _unhandled_key_input(event : InputEventKey) -> void:
	if not is_ingame:
		return
	
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

func _on_Area_body_entered(body):
	var sprite : Node = body.get_parent()
	sprite.scale = Vector2(0.3, 0.3)
	
	var state_machine = sprite.get_node("AnimationTree")["parameters/playback"]
	state_machine.travel("highlighted")

func _on_Area_body_exited(body):
	var sprite : Node = body.get_parent()
	sprite.scale = Vector2(0.25, 0.25)
	
	var state_machine = sprite.get_node("AnimationTree")["parameters/playback"]
	
	yield(get_tree().create_timer(0.01), "timeout")
	if state_machine.get_current_node() == "highlighted":
		state_machine.travel("idle")
