class_name Board

extends Node

const LINK_UP = 1
const LINK_LEFT = 2
const LINK_RIGHT = 4
const LINK_DOWN = 8

const LINKED_DTM = 2		# 連結確定
const LINKED = 1			# 連結
const EMPTY = 0
const UNLINKED = -1			# 非連結
const UNLINKED_DTM = -2		# 非連結確定

var N_HORZ
var N_VERT
var ARY_WIDTH
var ARY_HEIGHT
var ARY_SIZE
const ANY = -1			# 手がかり数字無し
const WALL = -2			# 壁

var clue_num = []		# 手がかり数字
var h_link = []			# 各格子点の右連結フラグ、1 for 連結、0 for 非連結
var v_link = []			# 各格子点の下連結フラグ
var mate = []			# 連結先配列、端点以外は値: 0
var degree = []			# 頂点次数
var dir_order = [LINK_UP, LINK_DOWN, LINK_LEFT, LINK_RIGHT]
var solved = false		# 解探索成功
var finished = false	# 探索終了
var n_solved = 0		# 発見解数
var n_step = 0
var fwd = true
var sx = -1				# 探索位置
var sy = 0
var ix99				# 右下位置
var modified = false

func xyToIX(x, y): return x + (y+1)*ARY_WIDTH

func _init():
	set_board_size(5)
	#print_mate()
	pass
func set_board_size(n):
	N_HORZ = n
	N_VERT = n
	ARY_WIDTH = N_HORZ + 1
	ARY_HEIGHT = N_VERT + 2
	ARY_SIZE = ARY_WIDTH * ARY_HEIGHT + 2
	#
	clue_num.resize(ARY_SIZE)
	clue_num.fill(WALL)				# 空欄
	clear_clue_nums()
	h_link.resize(ARY_SIZE)
	h_link.fill(0)
	v_link.resize(ARY_SIZE)
	v_link.fill(0)
	mate.resize(ARY_SIZE)
	for i in range(ARY_SIZE): mate[i] = i		# 非連結
	degree.resize(ARY_SIZE)
	degree.fill(0)
	ix99 = xyToIX(N_HORZ, N_VERT)
	init_links()
	assert( h_link[xyToIX(-1, 0)] == UNLINKED_DTM )
	assert( v_link[xyToIX(0, -1)] == UNLINKED_DTM )
func clear_clue_nums():
	for y in range(N_VERT):
		for x in range(N_HORZ):
			clue_num[xyToIX(x, y)] = ANY
func clear_edges():
	for y in range(N_VERT+1):
		for x in range(N_HORZ):
			h_link[xyToIX(x, y)] = EMPTY
	for y in range(N_VERT):
		for x in range(N_HORZ+1):
			v_link[xyToIX(x, y)] = EMPTY
func init_links():
	h_link.fill(EMPTY)
	v_link.fill(EMPTY)
	#for ix in range(h_link.size()):
	#	h_link_cnf[ix] = 0
	#	v_link_cnf[ix] = 0
	# 盤面外側の非連結フラグをすべてONに
	var ix1 = xyToIX(0, -1)
	var ix2 = xyToIX(0, N_VERT)
	for x in range(N_HORZ+1):
		v_link[ix1+x] = UNLINKED_DTM
		v_link[ix2+x] = UNLINKED_DTM
	ix1 = xyToIX(-1, 0)
	ix2 = xyToIX(N_HORZ, 0)
	for y in range(N_HORZ+1):
		h_link[ix1+y*ARY_WIDTH] = UNLINKED_DTM
		h_link[ix2+y*ARY_WIDTH] = UNLINKED_DTM
	assert( h_link[xyToIX(-1, 0)] == UNLINKED_DTM )
	assert( v_link[xyToIX(0, -1)] == UNLINKED_DTM )
func print_degree():
	print("vertex degree:")
	for y in range(N_VERT+1):
		var txt = ""
		for x in range(N_HORZ+1):
			var ix = xyToIX(x, y)
			txt += "%d " % degree[ix]
		print(txt)
	print("\n")
func print_board():
	print("board:")
	for y in range(N_VERT):
		var txt = ""
		for x in range(N_HORZ):
			txt += "+---" if h_link[xyToIX(x, y)] > 0 else "+   " if h_link[xyToIX(x, y)] == EMPTY else "+ X "
		txt += "+"
		print(txt)			# 水平線部分
		var txt2 = ""
		for x in range(N_HORZ):
			txt2 += "|   " if v_link[xyToIX(x, y)] > 0 else "    " #if h_link[xyToIX(x, y)] == EMPTY else "  X "
		txt2 += "|" if v_link[xyToIX(N_HORZ, y)] > 0 else " "
		print(txt2)			# 隙間行
		txt = ""
		for x in range(N_HORZ):
			var n = clue_num[xyToIX(x, y)]
			if n == ANY:
				txt += "|   " if v_link[xyToIX(x, y)] > 0 else "    " if v_link[xyToIX(x, y)] == EMPTY else "X   "
			else:
				txt += ("| %d "%n) if v_link[xyToIX(x, y)] > 0 else ("  %d "%n) if v_link[xyToIX(x, y)] == EMPTY else ("X %d "%n)
		var v = v_link[xyToIX(N_HORZ, y)]
		txt += "|" if v_link[xyToIX(N_HORZ, y)] != 0 else (" " if v_link[xyToIX(N_HORZ, y)] == EMPTY else "X")
		print(txt)
		print(txt2)			# 隙間行
	var txt = ""
	for x in range(N_HORZ):
		txt += "+---" if h_link[xyToIX(x, N_VERT)] > 0 else "+   " if h_link[xyToIX(x, N_VERT)] == EMPTY else "+ X "
	txt += "+"
	print(txt, "\n")

func _ready():
	pass # Replace with function body.
func _process(delta):
	pass
