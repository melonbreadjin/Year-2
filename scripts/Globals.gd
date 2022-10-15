extends Node

signal sgn_update_turn
signal sgn_update_tools
signal sgn_draw_cards

signal sgn_highlight_start
signal sgn_highlight_end
signal sgn_selection

signal sgn_piece_collision_start
signal sgn_piece_collision_end

var texture_grass = preload("res://assets/grass.png")
var texture_rock = preload("res://assets/rock.png")
var texture_wood = preload("res://assets/wood.png")

var icon_3x3 = preload("res://assets/icon_3x3.png")
var icon_h = preload("res://assets/icon_h.png")
var icon_v = preload("res://assets/icon_v.png")
var icon_pick = preload("res://assets/icon_pick.png")
var icon_axe = preload("res://assets/icon_axe.png")
var icon_scythe = preload("res://assets/icon_scythe.png")

var piece_ref = preload("res://scene/Piece.tscn")

enum target_type{
	LINE_HORIZONTAL,
	LINE_VERTICAL,
	AREA_3x3
}

enum piece_type{
	GRASS,
	ROCK,
	WOOD
}

var arr_cards : Dictionary = {
	"3x3_grass" : ["3x3 scythe", target_type.AREA_3x3, piece_type.GRASS],
	"3x3_rock" : ["3x3 pick", target_type.AREA_3x3, piece_type.ROCK],
	"3x3_wood" : ["3x3 axe", target_type.AREA_3x3, piece_type.WOOD],
	"7x3_grass" : ["horizontal scythe", target_type.LINE_HORIZONTAL, piece_type.GRASS],
	"7x3_rock" : ["horizontal pick", target_type.LINE_HORIZONTAL, piece_type.ROCK],
	"7x3_wood" : ["horizontal axe", target_type.LINE_HORIZONTAL, piece_type.WOOD],
	"3x7_grass" : ["vertical scythe", target_type.LINE_VERTICAL, piece_type.GRASS],
	"3x7_rock" : ["vertical pick", target_type.LINE_VERTICAL, piece_type.ROCK],
	"3x7_wood" : ["vertical axe", target_type.LINE_VERTICAL, piece_type.WOOD]
}

var arr_deck : Dictionary = {
	"3x3_grass" : ["3x3 scythe", target_type.AREA_3x3, piece_type.GRASS],
	"3x3_rock" : ["3x3 pick", target_type.AREA_3x3, piece_type.ROCK],
	"3x3_wood" : ["3x3 axe", target_type.AREA_3x3, piece_type.WOOD],
	"7x3_grass" : ["horizontal scythe", target_type.LINE_HORIZONTAL, piece_type.GRASS],
	"7x3_rock" : ["horizontal pick", target_type.LINE_HORIZONTAL, piece_type.ROCK],
	"7x3_wood" : ["horizontal axe", target_type.LINE_HORIZONTAL, piece_type.WOOD],
	"3x7_grass" : ["vertical scythe", target_type.LINE_VERTICAL, piece_type.GRASS],
	"3x7_rock" : ["vertical pick", target_type.LINE_VERTICAL, piece_type.ROCK],
	"3x7_wood" : ["vertical axe", target_type.LINE_VERTICAL, piece_type.WOOD]
}
