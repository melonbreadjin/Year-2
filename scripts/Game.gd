extends Node

onready var a_clear = preload("res://audio/hitHurt.wav")
onready var a_move = preload("res://audio/jump.wav")
onready var a_click = preload("res://audio/pickupCoin.wav")

export(Array, Array, float) var position

const GRID_SIZE : Vector2 = Vector2(7, 7)

var player : Node2D
var player_pos : Vector2
var pivot_pos : Vector2
var target_pos : Vector2
var board : Array
var turn : int
var tools_used : int

var daily_game : bool

var _sgn

var is_ingame : bool
var is_mainmenu_visible : bool

func _ready() -> void:
	$MusicIntro.play()
	
	is_ingame = false
	is_mainmenu_visible = true
	
	player = $Player
	_sgn = Globals.connect("sgn_update_turn", self, "on_sgn_update_turn")
	_sgn = Globals.connect("sgn_highlight_start", self, "on_sgn_highlight_start")
	_sgn = Globals.connect("sgn_highlight_end", self, "on_sgn_highlight_end")
	_sgn = Globals.connect("sgn_selection", self, "on_sgn_selection")

func new_game(is_daily : bool) -> void:
	turn = 0
	tools_used = 0
	is_ingame = true
	daily_game = is_daily
	
	$UI/ActionCountLabel.text = "Total turns : 0"
	$UI/ActionCountLabel.visible = true
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
	
	for y in range(GRID_SIZE.y):
		board.append([])
		
		for x in range(GRID_SIZE.x):
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
			
			Globals.arr_cards.erase(key)
	
	Globals.emit_signal("sgn_draw_cards", cards)

func on_sgn_update_turn(cost : int) -> void:
	turn += cost

func on_sgn_highlight_start(card : Array) -> void:
	$Player/Area.collision_layer = 1 << card[2]
	
	if card[1] == Globals.target_type.LINE_HORIZONTAL:
		$Player/Area/H.disabled = false
	elif card[1] == Globals.target_type.LINE_VERTICAL:
		$Player/Area/V.disabled = false
	elif card[1] == Globals.target_type.AREA_3x3:
		$Player/Area/A.disabled = false
		
func on_sgn_highlight_end() -> void:
		$Player/Area/H.disabled = true
		$Player/Area/V.disabled = true
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
	state_machine.travel("idle")

func on_sgn_selection(cards : Array) -> void:
	if not is_ingame:
		return
	
	Globals.emit_signal("sgn_update_turn", 5)
	tools_used += 1
	
	var bodies = $Player/Area.get_overlapping_bodies()
	
	for body in bodies:
		play_audio(a_clear)
		body.get_parent().queue_free()
	
	if bodies.size() == 0:
		play_audio(a_click)
	
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
	
	if event.is_action_pressed("player_up") and player_pos.y - 1 >= 0:
		player_pos.y -= 1
		Globals.emit_signal("sgn_update_turn", 1)
		player.flip_h = true
		play_audio(a_move)
	elif event.is_action_pressed("player_left") and player_pos.x - 1 >= 0:
		player_pos.x -= 1
		Globals.emit_signal("sgn_update_turn", 1)
		player.flip_h = true
		play_audio(a_move)
	elif event.is_action_pressed("player_down") and player_pos.y + 1 < GRID_SIZE.y:
		player_pos.y += 1
		Globals.emit_signal("sgn_update_turn", 1)
		player.flip_h = false
		play_audio(a_move)
	elif event.is_action_pressed("player_right") and player_pos.x + 1 < GRID_SIZE.x:
		player_pos.x += 1
		Globals.emit_signal("sgn_update_turn", 1)
		player.flip_h = false
		play_audio(a_move)
	
	board_set("player", player_pos)

func play_audio(audio) -> void:
	if not $SFX.playing:
		$SFX.stream = audio
		$SFX.play()

func game_over() -> void:
	is_ingame = false
	
	$UI/ActionCountLabel.visible = false
	
	$GameoverDialog/NinePatchRect/Panel/Label.bbcode_text = "[center][b]GAME OVER[/b]\n\nTools Used : %d\nTotal Turns : %d[/center]" % [tools_used, turn]
	$GameoverDialog/NinePatchRect.visible = true
	$GameoverDialog/BGPanel.visible = true

func _on_MusicIntro_finished():
	$Music.play()

func _on_RetryButton_pressed():
	play_audio(a_click)
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
	play_audio(a_click)
	is_mainmenu_visible = false
	new_game(true)

func _on_RandomButton_pressed():
	play_audio(a_click)
	is_mainmenu_visible = false
	new_game(false)

func _on_MenuButton_pressed():
	play_audio(a_click)
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
	
	$UI/MainMenu/C/Label.text = "í ½í°”í ½í°”í ½í°”í ½í°”í ½í°”í ½í°”í ½í°”Made by melonbreadjin\n\nFont : RobGraves\nby Kevin Richey"
