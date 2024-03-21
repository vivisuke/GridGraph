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
var h_link = []			# 各格子点の右連結フラグ
var v_link = []			# 各格子点の下連結フラグ
var mate = []			# 連結先配列、端点以外は値: 0
var mate_stack = []		# リンク前値
var degree = []			# 頂点次数
var ul_degree = []		# 上・左方向頂点次数
var lnk_count = []		# セル周囲連結エッジ数
var ul_count = []		# セル周囲非連結エッジ数
var dir_order = [LINK_UP, LINK_DOWN, LINK_LEFT, LINK_RIGHT]
var n_end_pnt = 0		# 端点数
var is_loop = false
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
	ul_degree.resize(ARY_SIZE)
	ul_degree.fill(0)
	lnk_count.resize(ARY_SIZE)
	lnk_count.fill(0)
	ul_count.resize(ARY_SIZE)
	ul_count.fill(0)
	ix99 = xyToIX(N_HORZ, N_VERT)
	init_links()
	assert( h_link[xyToIX(-1, 0)] == UNLINKED_DTM )
	assert( v_link[xyToIX(0, -1)] == UNLINKED_DTM )
func clear_clue_nums():
	for y in range(N_VERT):
		for x in range(N_HORZ):
			clue_num[xyToIX(x, y)] = ANY
func clear_edges():
	n_end_pnt = 0
	mate_stack.clear()
	for y in range(N_VERT+1):
		for x in range(N_HORZ):
			h_link[xyToIX(x, y)] = EMPTY
	for y in range(N_VERT):
		for x in range(N_HORZ+1):
			v_link[xyToIX(x, y)] = EMPTY
	degree.fill(0)
	ul_degree.fill(0)
	lnk_count.fill(0)
	ul_count.fill(0)
	for i in range(mate.size()):
		mate[i] = i
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
func make_h_link(ix):
	h_link[ix] = LINKED
	#degree[ix] += 1
	#degree[ix+1] += 1
	ul_degree[ix+1] += 1
	lnk_count[ix] += 1
	lnk_count[ix-ARY_WIDTH] += 1
	connect_edge(ix, ix+1)
func make_v_link(ix):
	v_link[ix] = LINKED
	#degree[ix] += 1
	#degree[ix+ARY_WIDTH] += 1
	ul_degree[ix+ARY_WIDTH] += 1
	lnk_count[ix] += 1
	lnk_count[ix-1] += 1
	connect_edge(ix, ix+ARY_WIDTH)
func unmake_h_link(ix):			# make_h_link() 処理を戻す
	h_link[ix] = EMPTY
	#degree[ix] -= 1
	#degree[ix+1] -= 1
	ul_degree[ix+1] -= 1
	lnk_count[ix] -= 1
	lnk_count[ix-ARY_WIDTH] -= 1
	unconnect_edge(ix, ix+1)
func unmake_v_link(ix):			# make_v_link() 処理を戻す
	v_link[ix] = EMPTY
	#degree[ix] -= 1
	#degree[ix+ARY_WIDTH] -= 1
	ul_degree[ix+ARY_WIDTH] -= 1
	lnk_count[ix] -= 1
	lnk_count[ix-1] -= 1
	unconnect_edge(ix, ix+ARY_WIDTH)
func make_h_unlink(ix):
	h_link[ix] = UNLINKED
	ul_count[ix] += 1
	ul_count[ix-ARY_WIDTH] += 1
func make_v_unlink(ix):
	v_link[ix] = UNLINKED
	ul_count[ix] += 1
	ul_count[ix-1] += 1
func unmake_h_unlink(ix):			# make_h_unlink() 処理を戻す
	h_link[ix] = EMPTY
	ul_count[ix] -= 1
	ul_count[ix-ARY_WIDTH] -= 1
func unmake_v_unlink(ix):			# make_v_unlink() 処理を戻す
	v_link[ix] = EMPTY
	ul_count[ix] -= 1
	ul_count[ix-1] -= 1
func connect_edge(ix1, ix2):
	mate_stack.push_back(mate[ix1])
	mate_stack.push_back(mate[ix2])
	if mate[ix1] == ix1:			# ix1：未接続
		if mate[ix2] == ix2:		# 両方端点→連結
			mate[ix1] = ix2
			mate[ix2] = ix1
			n_end_pnt += 2
		else:						# ix2 が接続済み
			mate[mate[ix2]] = ix1
			mate[ix1] = mate[ix2]
			mate[ix2] = 0				# 中点
	elif mate[ix1] != 0:			# ix1：接続済み
		if mate[ix2] == ix2:		# ix2 が端点
			mate[mate[ix1]] = ix2
			mate[ix2] = mate[ix1]
			mate[ix1] = 0
		else:						# ix1, ix2 が接続済み
			mate[mate[ix1]] = mate[ix2]
			mate[mate[ix2]] = mate[ix1]
			mate[ix1] = 0
			mate[ix2] = 0
			n_end_pnt -= 2
func unconnect_edge(ix1, ix2):
	var m1 = mate[ix1]
	var m2 = mate[ix2]
	if m1 == 0 && m2 == 0: n_end_pnt += 2
	mate[ix2] = mate_stack.pop_back()
	mate[ix1] = mate_stack.pop_back()
	if m1 == 0:		# ix1：パス途中の場合
		mate[mate[ix1]] = ix1
	if m2 == 0:		# ix2：パス途中の場合
		mate[mate[ix2]] = ix2
#
func init_find_all_loop():
	finished = false
	n_step = 0
	fwd = true
	sx = -1
	sy = 0
	clear_edges()
func find_all_loop_SBS():
	if finished: return
	n_step += 1
	is_loop = false
	if fwd:		# 末端に向かって探索中
		sx += 1
		if sx > N_HORZ:
			sx = 0
			sy += 1
			if sy > N_VERT:
				fwd = false
				sy -= 1
				sx = N_HORZ + 1
	if !fwd:		# バックトラッキング中
		sx -= 1
		if sx < 0:
			sx = N_HORZ
			sy -= 1
			if sy < 0:
				print("finished.")
				finished = true
				return
	var ix = xyToIX(sx, sy)
	var uld = ul_degree[ix]
	if ul_degree[ix] == 0:			# 上・左 両方非接続済みの場合
		if fwd:
			if h_link[ix] == EMPTY:
				if v_link[ix] == EMPTY:
					make_h_link(ix)
					make_v_link(ix)
				else:			# 下接続不可（下端の場合など）
					make_h_unlink(ix)
			else:				# 右接続不可（右端の場合など）
				if v_link[ix] == EMPTY:
					make_v_unlink(ix)
				else:
					pass
		else:	# バックトラッキング中
			if h_link[ix] != UNLINKED && v_link[ix] != UNLINKED:
				if h_link[ix] != UNLINKED_DTM: h_link[ix] = UNLINKED
				if v_link[ix] != UNLINKED_DTM: v_link[ix] = UNLINKED
				fwd = true
			else:
				if h_link[ix] != UNLINKED_DTM: h_link[ix] = EMPTY
				if v_link[ix] != UNLINKED_DTM: v_link[ix] = EMPTY
	elif ul_degree[ix] == 1:			# 上・左 片方のみ接続済みの場合
		if fwd:
			if h_link[ix] == EMPTY:
				make_h_link(ix)
				if v_link[ix] == EMPTY:		# 下端でない場合
					make_v_unlink(ix)
				if mate[ix] == 0 && mate[ix+1] == 0:
					if n_end_pnt == 0:	# 閉路
						print("loop found.")
						is_loop = true
					sx += 1
					fwd = false
			elif v_link[ix] == EMPTY:
				make_v_link(ix)
			else:
				fwd = false
		else:
			if h_link[ix] == LINKED:
				unmake_h_link(ix)
				if v_link[ix] != UNLINKED_DTM:
					make_h_unlink(ix)
					make_v_link(ix)
					fwd = true
				else:
					pass
					#fwd = false
			elif v_link[ix] == LINKED:
				make_v_unlink(ix)
	elif ul_degree[ix] == 2:			# 上・左 両方接続済みの場合
		if fwd:
			make_h_unlink(ix)
			make_v_unlink(ix)
		else:
			unmake_h_unlink(ix)
			unmake_v_unlink(ix)
#
func print_mate():
	print("n_end_pnt = %d, mate:" % n_end_pnt)
	for y in range(N_VERT+1):
		var txt = ""
		for x in range(N_HORZ+1):
			var ix = xyToIX(x, y)
			txt += "%2d " % mate[ix]
		print(txt)
	print("\n")
func print_degree():
	print("vertex ul_degree:")
	for y in range(N_VERT+1):
		var txt = ""
		for x in range(N_HORZ+1):
			var ix = xyToIX(x, y)
			txt += "%d " % ul_degree[ix]
		print(txt)
	print("\n")
func print_count():
	print("linked edge count:")
	for y in range(N_VERT):
		var txt = ""
		for x in range(N_HORZ):
			var ix = xyToIX(x, y)
			txt += "%d " % lnk_count[ix]
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
