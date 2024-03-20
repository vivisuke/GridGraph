extends Node2D

var N_HORZ = 5
var N_VERT = 5
var CELL_WIDTH
var NLR = 0.25						# 非結合タップエリア半径割合
var ARY_WIDTH
var ARY_HEIGHT
var ARY_SIZE
var bd

var CBoard = preload("res://scripts/Board.gd")

func xyToIX(x, y): return x + (y+1)*ARY_WIDTH


func _ready():
	bd = CBoard.new()
	set_board_size(5)
	bd.make_h_link(xyToIX(0, 0))
	bd.make_v_link(xyToIX(0, 0))
	bd.make_h_link(xyToIX(1, 1))
	bd.print_board()
	bd.print_degree()
	bd.print_count()
	$Board/Grid.h_link = bd.h_link
	$Board/Grid.v_link = bd.v_link
	$Board/Grid.queue_redraw()
func set_board_size(n):
	N_HORZ = n
	N_VERT = n
	ARY_WIDTH = N_HORZ + 1
	ARY_HEIGHT = N_VERT + 2
	ARY_SIZE = ARY_WIDTH * ARY_HEIGHT + 2
	bd.set_board_size(n)
func _process(delta):
	pass
