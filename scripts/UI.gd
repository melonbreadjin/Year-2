extends CanvasLayer

const left_position = 668
const right_position = 1080

var is_highlighting
var is_selecting

var shown_cards : Array
var highlighted_card : Array
var selected_card : Array

var card0_hiding : bool
var card1_hiding : bool
var card2_hiding : bool

func _ready():
	var _sgn = Globals.connect("sgn_update_turn", self, "on_sgn_update_turn")
	_sgn = Globals.connect("sgn_update_tools", self, "on_sgn_update_tools")
	_sgn = Globals.connect("sgn_draw_cards", self, "on_sgn_draw_cards")
	
	is_highlighting = false
	is_selecting = false
	
	card0_hiding = false
	card1_hiding = false
	card2_hiding = false

func _on_EndTurnButton_pressed() -> void:
	Globals.emit_signal("sgn_update_turn")

func on_sgn_update_turn(cost : int) -> void:
	$TurnCountLabel.bbcode_text = "[center]Total turns : %d[/center]" % [int($TurnCountLabel.bbcode_text) + cost]

func on_sgn_update_tools(cost : int) -> void:
	$ToolUsedLabel.bbcode_text = "[center]Tools used : %d[/center]" % [int($ToolUsedLabel.bbcode_text) + cost]

func on_sgn_draw_cards(cards : Array) -> void:
	shown_cards = cards
	
	for idx in range(cards.size()):
		get_node("Card%d/Label" % idx).text = cards[idx][0]
		
		if cards[idx][1] == Globals.target_type.AREA_3x3:
			get_node("Card%d/Icon_D" % idx).texture = Globals.icon_3x3
		elif cards[idx][1] == Globals.target_type.LINE_HORIZONTAL:
			get_node("Card%d/Icon_D" % idx).texture = Globals.icon_h
		elif cards[idx][1] == Globals.target_type.LINE_VERTICAL:
			get_node("Card%d/Icon_D" % idx).texture = Globals.icon_v
			
		if cards[idx][2] == Globals.piece_type.GRASS:
			get_node("Card%d/Icon_T" % idx).texture = Globals.icon_scythe
		elif cards[idx][2] == Globals.piece_type.ROCK:
			get_node("Card%d/Icon_T" % idx).texture = Globals.icon_pick
		elif cards[idx][2] == Globals.piece_type.WOOD:
			get_node("Card%d/Icon_T" % idx).texture = Globals.icon_axe
		
		card0_hiding = false
		card1_hiding = false
		card2_hiding = false
	
	$Card0/Button0.disabled = false
	$Card1/Button1.disabled = false
	$Card2/Button2.disabled = false
	
	check_highlight()

func check_highlight() -> void:
	if $Card0/Button0.is_hovered():
		$Card0.rect_rotation = 0.5
		highlighted_card = shown_cards[0]
		highlight()
	elif $Card1/Button1.is_hovered():
		$Card1.rect_rotation = 0.5
		highlighted_card = shown_cards[1]
		highlight()
	elif $Card2/Button2.is_hovered():
		$Card2.rect_rotation = 0.5
		highlighted_card = shown_cards[2]
		highlight()

func highlight() -> void:
	if is_selecting == false:
		is_highlighting = true
		Globals.emit_signal("sgn_highlight_start", highlighted_card)

func _on_Button_mouse_entered() -> void:
	highlight()

func _on_Button_mouse_exited() -> void:
	is_highlighting = false
	Globals.emit_signal("sgn_highlight_end")

func _on_Button_pressed() -> void:
	is_highlighting = false
	
	$Card0/Button0.disabled = true
	$Card1/Button1.disabled = true
	$Card2/Button2.disabled = true
	
	Globals.emit_signal("sgn_highlight_end")
	Globals.emit_signal("sgn_selection", shown_cards, selected_card)

func _process(_delta : float) -> void:
	if card0_hiding and $Card0.rect_position.x < right_position:
		$Card0.rect_position.x = lerp($Card0.rect_position.x, right_position, 0.05)
	elif not card0_hiding and $Card0.rect_position.x > left_position:
		$Card0.rect_position.x = lerp($Card0.rect_position.x, left_position, 0.05)
	
	if card1_hiding and $Card1.rect_position.x < right_position:
		$Card1.rect_position.x = lerp($Card1.rect_position.x, right_position, 0.05)
	elif not card1_hiding and $Card1.rect_position.x > left_position:
		$Card1.rect_position.x = lerp($Card1.rect_position.x, left_position, 0.05)
	
	if card2_hiding and $Card2.rect_position.x < right_position:
		$Card2.rect_position.x = lerp($Card2.rect_position.x, right_position, 0.05)
	elif not card2_hiding and $Card2.rect_position.x > left_position:
		$Card2.rect_position.x = lerp($Card2.rect_position.x, left_position, 0.05)

func _on_Button0_pressed():
	selected_card = shown_cards[0]
	_on_Button_pressed()
	
	card1_hiding = true
	card2_hiding = true
	
	yield(get_tree().create_timer(0.2), "timeout")
	card0_hiding = true
	
func _on_Button1_pressed():
	selected_card = shown_cards[1]
	_on_Button_pressed()
	
	card0_hiding = true
	card2_hiding = true
	
	yield(get_tree().create_timer(0.2), "timeout")
	card1_hiding = true
	
func _on_Button2_pressed():
	selected_card = shown_cards[2]
	_on_Button_pressed()
	
	card0_hiding = true
	card1_hiding = true
	
	yield(get_tree().create_timer(0.2), "timeout")
	card2_hiding = true

func _on_Button0_mouse_entered():
	$Card0.rect_rotation = 0.5
	highlighted_card = shown_cards[0]
	_on_Button_mouse_entered()
	
func _on_Button1_mouse_entered():
	$Card1.rect_rotation = 0.5
	highlighted_card = shown_cards[1]
	_on_Button_mouse_entered()
	
func _on_Button2_mouse_entered():
	$Card2.rect_rotation = 0.5
	highlighted_card = shown_cards[2]
	_on_Button_mouse_entered()


func _on_Button0_mouse_exited():
	$Card0.rect_scale = Vector2(1.0, 1.0)
	$Card0.rect_rotation = 0.0
	_on_Button_mouse_exited()
	
func _on_Button1_mouse_exited():
	$Card1.rect_scale = Vector2(1.0, 1.0)
	$Card1.rect_rotation = 0.0
	_on_Button_mouse_exited()
	
func _on_Button2_mouse_exited():
	$Card2.rect_scale = Vector2(1.0, 1.0)
	$Card2.rect_rotation = 0.0
	_on_Button_mouse_exited()



func _on_Button_W_pressed():
	$B_W.rect_scale = Vector2(0.72, 0.72)
	yield(get_tree().create_timer(0.2), "timeout")
	$B_W.rect_scale = Vector2(0.75, 0.75)


func _on_Button_A_pressed():
	$B_A.rect_scale = Vector2(0.72, 0.72)
	yield(get_tree().create_timer(0.2), "timeout")
	$B_A.rect_scale = Vector2(0.75, 0.75)


func _on_Button_S_pressed():
	$B_S.rect_scale = Vector2(0.72, 0.72)
	yield(get_tree().create_timer(0.2), "timeout")
	$B_S.rect_scale = Vector2(0.75, 0.75)


func _on_Button_D_pressed():
	$B_D.rect_scale = Vector2(0.72, 0.72)
	yield(get_tree().create_timer(0.2), "timeout")
	$B_D.rect_scale = Vector2(0.75, 0.75)


func _on_DailyButton_mouse_entered():
	$MainMenu/Daily.rect_rotation = 1.5


func _on_DailyButton_mouse_exited():
	$MainMenu/Daily.rect_rotation = 0.0


func _on_RandomButton_mouse_entered():
	$MainMenu/Random.rect_rotation = 1.5


func _on_RandomButton_mouse_exited():
	$MainMenu/Random.rect_rotation = 0.0
