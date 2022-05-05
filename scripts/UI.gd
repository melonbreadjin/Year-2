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
	_sgn = Globals.connect("sgn_draw_cards", self, "on_sgn_draw_cards")
	
	is_highlighting = false
	is_selecting = false
	
	card0_hiding = false
	card1_hiding = false
	card2_hiding = false

func _on_EndTurnButton_pressed() -> void:
	Globals.emit_signal("sgn_update_turn")

func on_sgn_update_turn(cost : int) -> void:
	$ActionCountLabel.text = "Total turns : %d" % [int($ActionCountLabel.text) + cost]

func on_sgn_draw_cards(cards : Array) -> void:
	shown_cards = cards
	
	for idx in range(cards.size()):
		get_node("Card%d/Label" % idx).text = cards[idx][0]
		
		card0_hiding = false
		card1_hiding = false
		card2_hiding = false
	
	$Card0/Button0.disabled = false
	$Card1/Button1.disabled = false
	$Card2/Button2.disabled = false

func _on_Button_mouse_entered() -> void:
	if is_selecting == false:
		is_highlighting = true
		Globals.emit_signal("sgn_highlight_start", highlighted_card)

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
	card0_hiding = true
	selected_card = shown_cards[0]
	_on_Button_pressed()
	
	yield(get_tree().create_timer(0.2), "timeout")
	card1_hiding = true
	card2_hiding = true
	
func _on_Button1_pressed():
	card1_hiding = true
	selected_card = shown_cards[1]
	_on_Button_pressed()
	
	yield(get_tree().create_timer(0.2), "timeout")
	card0_hiding = true
	card2_hiding = true
	
func _on_Button2_pressed():
	card2_hiding = true
	selected_card = shown_cards[2]
	_on_Button_pressed()
	
	yield(get_tree().create_timer(0.2), "timeout")
	card0_hiding = true
	card1_hiding = true


func _on_Button0_mouse_entered():
	$Card0.rect_scale = Vector2(1.01, 1.01)
	highlighted_card = shown_cards[0]
	_on_Button_mouse_entered()
	
func _on_Button1_mouse_entered():
	$Card1.rect_scale = Vector2(1.01, 1.01)
	highlighted_card = shown_cards[1]
	_on_Button_mouse_entered()
	
func _on_Button2_mouse_entered():
	$Card2.rect_scale = Vector2(1.01, 1.01)
	highlighted_card = shown_cards[2]
	_on_Button_mouse_entered()


func _on_Button0_mouse_exited():
	$Card0.rect_scale = Vector2(1.0, 1.0)
	_on_Button_mouse_exited()
	
func _on_Button1_mouse_exited():
	$Card1.rect_scale = Vector2(1.0, 1.0)
	_on_Button_mouse_exited()
	
func _on_Button2_mouse_exited():
	$Card2.rect_scale = Vector2(1.0, 1.0)
	_on_Button_mouse_exited()

