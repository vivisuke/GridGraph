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
	seed(0)
	bd = CBoard.new()
	if true:
		set_board_size(4)
		bd.make_h_link(xyToIX(0,0))
		bd.make_v_link(xyToIX(0,0))
		bd.make_h_link(xyToIX(0,1))
		bd.make_v_link(xyToIX(1,0))
		bd.move_edge_down(xyToIX(0,1))
		bd.move_edge_right(xyToIX(1,1))
		bd.move_edge_right(xyToIX(2,1))
		bd.move_edge_down(xyToIX(0,0))
		#bd.print_board()
		#bd.print_degree()
		bd.move_edge_up(xyToIX(1,1))
		#bd.move_edge_left(xyToIX(3,1))
		bd.print_board()
		bd.print_count()
		bd.print_degree()
		assert( !bd.can_move_edge_up(xyToIX(1, 0)) )
		assert( bd.can_move_edge_up(xyToIX(2, 1)) )
		bd.move_edge_up(xyToIX(2, 1))
		bd.print_board()
		bd.print_count()
		bd.print_degree()
		assert( bd.can_move_edge_up(xyToIX(0, 1)) )
		assert( !bd.can_move_edge_up(xyToIX(1, 2)) )
		assert( bd.can_move_edge_down(xyToIX(1, 0)) )
		assert( !bd.can_move_edge_down(xyToIX(0, 1)) )
		assert( bd.can_move_edge_down(xyToIX(0, 2)) )
	if false:
		set_board_size(4)
	if false:
		set_board_size(5)
		bd.dfs_make_h_link(xyToIX(0, 0))
		bd.dfs_make_h_link(xyToIX(1, 0))
		bd.print_board()
		bd.print_mate()
		bd.dfs_unmake_h_link(xyToIX(1, 0))
		bd.print_board()
		bd.print_mate()
		#bd.dfs_unmake_h_link(xyToIX(0, 0))
	if false:
		set_board_size(5)
		bd.dfs_make_h_link(xyToIX(0, 0))
		bd.dfs_make_v_link(xyToIX(0, 0))
		bd.dfs_make_h_link(xyToIX(1, 1))
		bd.dfs_make_h_unlink(xyToIX(0, 1))
		bd.dfs_make_v_unlink(xyToIX(1, 0))
		bd.print_board()
		bd.print_degree()
		bd.print_count()
		bd.print_mate()
		#bd.dfs_unmake_h_link(xyToIX(0, 0))
		#bd.dfs_unmake_v_link(xyToIX(0, 0))
		#bd.print_board()
		#bd.print_degree()
		#bd.print_count()
		#
		bd.clear_edges()
		bd.dfs_make_h_link(xyToIX(0, 0))
		bd.dfs_make_v_link(xyToIX(0, 0))
		bd.dfs_make_h_link(xyToIX(1, 0))
		bd.dfs_make_v_unlink(xyToIX(1, 0))
		bd.dfs_make_h_link(xyToIX(2, 0))
		bd.dfs_make_v_unlink(xyToIX(2, 0))
		bd.dfs_make_h_unlink(xyToIX(3, 0))
		bd.dfs_make_v_link(xyToIX(3, 0))
		bd.dfs_make_h_link(xyToIX(4, 0))
		bd.dfs_make_v_link(xyToIX(4, 0))
		bd.dfs_make_v_link(xyToIX(5, 0))
		#bd.print_board()
		#bd.print_mate()
		bd.dfs_make_h_link(xyToIX(0, 1))
		bd.dfs_make_h_link(xyToIX(2, 1))
		bd.print_board()
		bd.print_degree()
		bd.print_count()
		bd.print_mate()
	#
	$Board/Grid.h_link = bd.h_link
	$Board/Grid.v_link = bd.v_link
	$Board/Grid.queue_redraw()
func set_board_size(n):
	N_HORZ = n
	N_VERT = n
	ARY_WIDTH = N_HORZ + 1
	ARY_HEIGHT = N_VERT + 2
	ARY_SIZE = ARY_WIDTH * ARY_HEIGHT + 2
	$Board/Grid.set_board_size(n)
	bd.set_board_size(n)
func _process(delta):
	pass

func _input(event):
	#if event is InputEventKey && event.is_pressed():
	#	_on_step_1_button_pressed()
	pass

func do_step(n, find_loop=false):
	var start = Time.get_ticks_msec()
	for i in range(n):
		#bd.find_all_loop_SBS()
		bd.build_loop_random()
		if bd.finished: break
		if find_loop && bd.is_loop: break
	var end = Time.get_ticks_msec()
	bd.print_board()
	bd.print_degree()
	bd.print_mate()
	bd.print_count()
	$NStepLabel.text = "#%d" % bd.n_step
	$NLoopLabel.text = "#Loop: %d" % bd.n_looped
	$MessLabel.text = ("#%d loop, "%bd.n_looped) if bd.is_loop else ""
	$MessLabel.text += ("n_end_pnt = %d" % bd.n_end_pnt)
	$MessLabel.text += (", fwd = %d" % (1 if bd.fwd else 0))
	$Board/Grid.sx = bd.sx
	$Board/Grid.sy = bd.sy
	$Board/Grid.queue_redraw()
	print("dur = %d msec" % (end - start))
func _on_step_1_button_pressed():
	do_step(1)
func _on_step_10_button_pressed():
	do_step(10)
func _on_step_100_button_pressed():
	do_step(100)
func _on_step_1000_button_pressed():
	do_step(1000)
func _on_step_10000_button_pressed():
	do_step(100000)

func _on_restart_button_pressed():
	bd.init_find_all_loop()
	$NStepLabel.text = "#%d" % bd.n_step
	$NLoopLabel.text = "#Loop: %d" % bd.n_looped
	$Board/Grid.sx = bd.sx
	$Board/Grid.sy = bd.sy
	$Board/Grid.queue_redraw()
	pass # Replace with function body.

func _on_next_button_pressed():
	do_step(1000*1000, true)
	pass # Replace with function body.
