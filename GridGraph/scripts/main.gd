extends Node2D

var N_HORZ = 6
var N_VERT = 6
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
	bd.print_board()
	pass # Replace with function body.

func _process(delta):
	pass
