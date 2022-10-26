extends Node

export(Array, Array, float) var position

var player : Node2D

var player_pos : Vector2
var target_pos : Vector2

var board : Array
var turn : int
var tools_used : int

var daily_game : bool

var _sgn

var is_debug : bool
var is_ingame : bool
var is_mainmenu_visible : bool

var player_state_machine

func _ready() -> void:
	if OS.is_debug_build():
		is_debug = true
	else:
		is_debug = false
		$MusicIntro.play()
	
	is_ingame = false
	is_mainmenu_visible = true
	
	_sgn = Globals.connect("sgn_update_player_pos", self, "on_sgn_update_player_pos")
	_sgn = Globals.connect("sgn_update_turn", self, "on_sgn_update_turn")
	_sgn = Globals.connect("sgn_update_tools", self, "on_sgn_update_tools")
	_sgn = Globals.connect("sgn_highlight_start", self, "on_sgn_highlight_start")
	_sgn = Globals.connect("sgn_highlight_end", self, "on_sgn_highlight_end")
	_sgn = Globals.connect("sgn_selection", self, "on_sgn_selection")
	_sgn = Globals.connect("sgn_play_sfx", self, "on_sgn_play_sfx")
	
	player = $Player
	player_state_machine = player.get_node("AnimationTree")["parameters/playback"]

func new_game(is_daily : bool) -> void:
	if is_ingame:
		return
	
	turn = 0
	tools_used = 0
	is_ingame = true
	daily_game = is_daily
	
	$UI/TurnCountLabel.bbcode_text = "[center]Total turns : 0[/center]"
	$UI/ToolUsedLabel.bbcode_text = "[center]Tools used : 0[/center]"
	$UI/TurnCountLabel.visible = true
	$UI/ToolUsedLabel.visible = true
	Globals.arr_cards = Globals.arr_deck.duplicate()
	
	if is_daily:
		var date : Dictionary = OS.get_date()
		init_board(hash("%d%02d%d" % [date.year, date.month, date.day]))
	else:
		randomize()
		init_board(randi())

func init_board(board_seed : int) -> void:
	seed(board_seed)
	board_set("player", Vector2(3, 3))
	player_pos = Vector2(3, 3)
	
	for y in range(Globals.GRID_SIZE.y):
		board.append([])
		
		for x in range(Globals.GRID_SIZE.x):
			var piece_inst : Piece = Globals.piece_ref.instance()
			
			piece_inst.position = get_node("Grid/P/%02d" % [y * 7 + x]).position
			var type : int = randi() % Globals.piece_type.size()
			
			board[y].append(type)
			piece_inst.set_type(type)
			
			$Pieces.add_child(piece_inst)
	
	generate_cards()

func _physics_process(_delta : float) -> void:
	if not is_ingame:
		return
	
	if player.position != target_pos:
		player.position = lerp(player.position, target_pos, 0.2)

func board_set(_piece : String, pos : Vector2) -> void:
	target_pos = get_node("Grid/P/%02d" % [pos.y * 7 + pos.x]).position

func generate_cards(count : int = 3) -> void:
	var cards = []
	
	while (cards.size() != count):
		var key = Globals.arr_cards.keys()[ randi() % Globals.arr_cards.size()]
		
		if Globals.arr_cards.has(key):
			var value = Globals.arr_cards[key]
			cards.append(value)
			
			var _v = Globals.arr_cards.erase(key)
	
	Globals.emit_signal("sgn_draw_cards", cards)

func on_sgn_update_turn(cost : int) -> void:
	turn += cost

func on_sgn_update_tools(cost : int) -> void:
	Globals.emit_signal("sgn_update_turn", 1)
	tools_used += cost

func on_sgn_highlight_start(card : Array) -> void:
	$Player/Area.collision_layer = 1 << card[2]
	
	if card[1] == Globals.target_type.LINE_HORIZONTAL:
		$Player/Area/H.disabled = false
	elif card[1] == Globals.target_type.LINE_VERTICAL:
		$Player/Area/V.disabled = false
	elif card[1] == Globals.target_type.LINE_FRONT:
		$Player/Area/F.disabled = false
	elif card[1] == Globals.target_type.AREA_3x3:
		$Player/Area/A.disabled = false
		
func on_sgn_highlight_end() -> void:
		$Player/Area/H.disabled = true
		$Player/Area/V.disabled = true
		$Player/Area/F.disabled = true
		$Player/Area/A.disabled = true

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

func on_sgn_selection(cards : Array, selected_card : Array) -> void:
	if not is_ingame:
		return
	
	Globals.emit_signal("sgn_update_tools", 1)
	
	var bodies = $Player/Area.get_overlapping_bodies()
	
	if selected_card[1] == Globals.target_type.AREA_3x3:
		player_state_machine.travel("swing_AOE")
	else:
		player_state_machine.travel("swing_H")
	
	yield(get_tree().create_timer(0.125), "timeout")
	
	for body in bodies:
		if selected_card[2] == Globals.piece_type.GRASS:
			play_audio(Globals.a_grass)
			var state_machine = body.get_parent().get_node("AnimationTree")["parameters/playback"]
			state_machine.travel("grass_break")
			body.get_parent().get_node("DespawnTimer").start()
		elif selected_card[2] == Globals.piece_type.WOOD:
			play_audio(Globals.a_wood)
			var state_machine = body.get_parent().get_node("AnimationTree")["parameters/playback"]
			state_machine.travel("wood_break")
			body.get_parent().get_node("DespawnTimer").start()
		elif selected_card[2] == Globals.piece_type.ROCK:
			play_audio(Globals.a_rock)
			var state_machine = body.get_parent().get_node("AnimationTree")["parameters/playback"]
			state_machine.travel("rock_break")
			body.get_parent().get_node("DespawnTimer").start()
		
		yield(get_tree().create_timer(0.135), "timeout")
	
	if bodies.size() == 0:
		play_audio(Globals.a_click)
	
	yield(get_tree().create_timer(0.5), "timeout")
	if $Pieces.get_child_count() == 0:
		game_over()
	
	for card in cards:
		Globals.arr_cards[card[0]] = card
	
	if is_ingame:
		yield(get_tree().create_timer(0.7), "timeout")
		generate_cards()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("volume_up"):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), lerp(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")), 0, 0.2))
	elif event.is_action_pressed("volume_down"):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), lerp(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")), -30, 0.05))
	
	if not is_ingame:
		return

func on_sgn_play_sfx(audio) -> void:
	play_audio(audio)

func play_audio(audio) -> void:
	if not $SFX.playing:
		$SFX.stream = audio
		$SFX.play()

func game_over() -> void:
	is_ingame = false
	
	$UI/TurnCountLabel.visible = false
	$UI/ToolUsedLabel.visible = false
	
	$GameoverDialog/NinePatchRect/Panel/Label.bbcode_text = "[center][b]GAME OVER[/b]\n\nTools Used : %d\nTotal Turns : %d[/center]" % [tools_used, turn]
	$GameoverDialog/NinePatchRect.visible = true
	$GameoverDialog/BGPanel.visible = true

func _on_MusicIntro_finished():
	$Music.play()

func _on_RetryButton_pressed():
	play_audio(Globals.a_click)
	$GameoverDialog/NinePatchRect.visible = false
	$GameoverDialog/BGPanel.visible = false
	new_game(daily_game)

func _process(_dt : float):
	if not is_mainmenu_visible:
		$UI/MainMenu.modulate.a = lerp($UI/MainMenu.modulate.a, 0, 0.01)
		$UI/MainMenu/TextureRect.margin_left -= _dt * 128
		$UI/MainMenu/TextureRect.margin_top -= _dt * 128
		$UI/MainMenu/TextureRect.margin_right += _dt * 128
		$UI/MainMenu/TextureRect.margin_bottom += _dt * 128
	else:
		$UI/MainMenu.modulate.a = lerp($UI/MainMenu.modulate.a, 1, 0.1)
		$UI/MainMenu/TextureRect.margin_left = 0
		$UI/MainMenu/TextureRect.margin_top = 0
		$UI/MainMenu/TextureRect.margin_right = 0
		$UI/MainMenu/TextureRect.margin_bottom = 360
	
	if $UI/MainMenu.modulate.a < 0.2:
		$UI/MainMenu.visible = false
	else:
		$UI/MainMenu.visible = true

func _on_DailyButton_pressed():
	play_audio(Globals.a_click)
	is_mainmenu_visible = false
	new_game(true)

func _on_RandomButton_pressed():
	play_audio(Globals.a_click)
	is_mainmenu_visible = false
	new_game(false)

func _on_MenuButton_pressed():
	play_audio(Globals.a_click)
	$GameoverDialog/NinePatchRect.visible = false
	$GameoverDialog/BGPanel.visible = false
	is_mainmenu_visible = true

func _on_CButton_mouse_entered():
	$UI/MainMenu/C.margin_top = -128
	$UI/MainMenu/C.margin_right = 160
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://assets/Robgraves.tres")
	dynamic_font.size = 12

	$UI/MainMenu/C/Label.add_font_override("font", dynamic_font)
	
	$UI/MainMenu/C/Label.margin_left = 18
	$UI/MainMenu/C/Label.margin_right = -18
	
	$UI/MainMenu/C/Label.text = "%s\nMade by melonbreadjin\n\nFont : RobGraves\nby Kevin Richey" % Globals.GAME_VERSION


func _on_Button_W_pressed():
	if player_pos.y - 1 >= 0:
		player_pos.y -= 1
		Globals.emit_signal("sgn_update_turn", 1)
		player.flip_h = true
		play_audio(Globals.a_move)
		player_state_machine.travel("hop")
	
		board_set("player", player_pos)


func _on_Button_A_pressed():
	if player_pos.x - 1 >= 0:
		player_pos.x -= 1
		Globals.emit_signal("sgn_update_turn", 1)
		player.flip_h = true
		play_audio(Globals.a_move)
		player_state_machine.travel("hop")
		
		board_set("player", player_pos)


func _on_Button_S_pressed():
	if player_pos.y + 1 < Globals.GRID_SIZE.y:
		player_pos.y += 1
		Globals.emit_signal("sgn_update_turn", 1)
		player.flip_h = false
		play_audio(Globals.a_move)
		player_state_machine.travel("hop")
		
		board_set("player", player_pos)


func _on_Button_D_pressed():
	if player_pos.x + 1 < Globals.GRID_SIZE.x:
		player_pos.x += 1
		Globals.emit_signal("sgn_update_turn", 1)
		player.flip_h = false
		play_audio(Globals.a_move)
		player_state_machine.travel("hop")
		
		board_set("player", player_pos)

func on_sgn_update_player_pos(pos):
	player_pos = pos
	board_set("player", player_pos)
