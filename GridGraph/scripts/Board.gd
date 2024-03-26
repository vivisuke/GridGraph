class_name Board

extends Node

enum {
	MOVE_UP = 0, MOVE_LEFT, MOVE_RIGHT, MOVE_DOWN,
}

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
var n_looped = 0		# 発見ループ数
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
func check_wall():		# 壁部分が壊れていないかチェック
	var ix1 = xyToIX(0, -1)
	var ix2 = xyToIX(0, N_VERT)
	for x in range(N_HORZ+1):
		assert( v_link[ix1+x] == UNLINKED_DTM )
		assert( v_link[ix2+x] == UNLINKED_DTM )
	ix1 = xyToIX(-1, 0)
	ix2 = xyToIX(N_HORZ, 0)
	for y in range(N_HORZ+1):
		assert( h_link[ix1+y*ARY_WIDTH] == UNLINKED_DTM )
		assert( h_link[ix2+y*ARY_WIDTH] == UNLINKED_DTM )
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
func dfs_make_h_link(ix):
	h_link[ix] = LINKED
	#degree[ix] += 1
	#degree[ix+1] += 1
	ul_degree[ix+1] += 1
	lnk_count[ix] += 1
	lnk_count[ix-ARY_WIDTH] += 1
	connect_edge(ix, ix+1)
func dfs_make_v_link(ix):
	v_link[ix] = LINKED
	#degree[ix] += 1
	#degree[ix+ARY_WIDTH] += 1
	ul_degree[ix+ARY_WIDTH] += 1
	lnk_count[ix] += 1
	lnk_count[ix-1] += 1
	connect_edge(ix, ix+ARY_WIDTH)
func dfs_unmake_h_link(ix):			# dfs_make_h_link() 処理を戻す
	h_link[ix] = EMPTY
	#degree[ix] -= 1
	#degree[ix+1] -= 1
	ul_degree[ix+1] -= 1
	lnk_count[ix] -= 1
	lnk_count[ix-ARY_WIDTH] -= 1
	unconnect_edge(ix, ix+1)
func dfs_unmake_v_link(ix):			# dfs_make_v_link() 処理を戻す
	v_link[ix] = EMPTY
	#degree[ix] -= 1
	#degree[ix+ARY_WIDTH] -= 1
	ul_degree[ix+ARY_WIDTH] -= 1
	lnk_count[ix] -= 1
	lnk_count[ix-1] -= 1
	unconnect_edge(ix, ix+ARY_WIDTH)
func dfs_make_h_unlink(ix):
	h_link[ix] = UNLINKED
	ul_count[ix] += 1
	ul_count[ix-ARY_WIDTH] += 1
func dfs_make_v_unlink(ix):
	v_link[ix] = UNLINKED
	ul_count[ix] += 1
	ul_count[ix-1] += 1
func dfs_unmake_h_unlink(ix):			# dfs_make_h_unlink() 処理を戻す
	h_link[ix] = EMPTY
	ul_count[ix] -= 1
	ul_count[ix-ARY_WIDTH] -= 1
func dfs_unmake_v_unlink(ix):			# dfs_make_v_unlink() 処理を戻す
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
	if m1 == 0 && m2 == 0:				# 経路途中の場合
		n_end_pnt += 2
	elif m1 == ix2 && m2 == ix1:		# 端点どうしの場合
		n_end_pnt -= 2
	mate[ix2] = mate_stack.pop_back()
	mate[ix1] = mate_stack.pop_back()
	if m1 == 0:		# ix1：パス途中の場合
		mate[mate[ix1]] = ix1
	if m2 == 0:		# ix2：パス途中の場合
		mate[mate[ix2]] = ix2
#
func init_find_all_loop():
	finished = false
	n_looped = 0
	n_step = 0
	fwd = true
	sx = -1
	sy = 0
	clear_edges()
func rand_h_link(ix):
	if randi() % 2 == 1:
		dfs_make_h_link(ix)
	else:
		dfs_make_h_unlink(ix)
func rand_v_link(ix):
	if randi() % 2 == 1:
		dfs_make_v_link(ix)
	else:
		dfs_make_v_unlink(ix)
func build_loop_random():
	if finished: return
	#check_wall()
	n_step += 1
	is_loop = false
	# 末端に向かって探索
	sx += 1
	if sx > N_HORZ:
		sx = 0
		sy += 1
		if sy > N_VERT:
			fwd = false
			sy -= 1
			sx = N_HORZ
	var ix = xyToIX(sx, sy)
	var uld = ul_degree[ix]
	if ul_degree[ix] == 0:			# 上・左 両方非接続済みの場合
		if h_link[ix] == EMPTY:
			if v_link[ix] == EMPTY:
				rand_h_link(ix)
				if h_link[ix] == LINKED:
					dfs_make_v_link(ix)
				else:
					dfs_make_v_unlink(ix)
			else:			# 下接続不可（下端の場合など）
				dfs_make_h_unlink(ix)
		else:				# 右接続不可（右端の場合など）
			if v_link[ix] == EMPTY:
				dfs_make_v_unlink(ix)
			else:
				pass
	elif ul_degree[ix] == 1:			# 上・左 片方のみ接続済みの場合
		if h_link[ix] == EMPTY:
			rand_h_link(ix)
			if v_link[ix] == EMPTY:		# 下端でない場合
				if h_link[ix] == LINKED:
					dfs_make_v_unlink(ix)
				else:
					dfs_make_v_link(ix)
			if mate[ix] == 0 && mate[ix+1] == 0:
				if n_end_pnt == 0:	# 閉路
					#print("loop found.")
					is_loop = true
					n_looped += 1
				sx += 1
				fwd = false
		elif v_link[ix] == EMPTY:
			dfs_make_v_link(ix)
		else:
			fwd = false
	elif ul_degree[ix] == 2:			# 上・左 両方接続済みの場合
		if h_link[ix] == EMPTY: dfs_make_h_unlink(ix)
		if v_link[ix] == EMPTY: dfs_make_v_unlink(ix)
	
func find_all_loop_SBS():
	if finished: return
	#check_wall()
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
				sx = N_HORZ
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
					dfs_make_h_link(ix)
					dfs_make_v_link(ix)
				else:			# 下接続不可（下端の場合など）
					dfs_make_h_unlink(ix)
			else:				# 右接続不可（右端の場合など）
				if v_link[ix] == EMPTY:
					dfs_make_v_unlink(ix)
				else:
					pass
			#check_wall()
		else:	# バックトラッキング中
			if h_link[ix] == LINKED && v_link[ix] == LINKED:
				dfs_unmake_v_link(ix)
				dfs_unmake_h_link(ix)
				dfs_make_h_unlink(ix)
				dfs_make_v_unlink(ix)
				fwd = true
			else:
				if h_link[ix] == UNLINKED: dfs_unmake_h_unlink(ix)
				if v_link[ix] == UNLINKED: dfs_unmake_v_unlink(ix)
			#check_wall()
	elif ul_degree[ix] == 1:			# 上・左 片方のみ接続済みの場合
		if fwd:
			if h_link[ix] == EMPTY:
			
				dfs_make_h_link(ix)
				if v_link[ix] == EMPTY:		# 下端でない場合
					dfs_make_v_unlink(ix)
				if mate[ix] == 0 && mate[ix+1] == 0:
					if n_end_pnt == 0:	# 閉路
						#print("loop found.")
						is_loop = true
						n_looped += 1
					sx += 1
					fwd = false
			elif v_link[ix] == EMPTY:
				dfs_make_v_link(ix)
			else:
				fwd = false
			#check_wall()
		else:
			if h_link[ix] == LINKED:
				dfs_unmake_h_link(ix)
				if v_link[ix] != UNLINKED_DTM:
					dfs_make_h_unlink(ix)
					dfs_make_v_link(ix)
					fwd = true
				else:
					pass
					#fwd = false
			else:
				if h_link[ix] == UNLINKED:
					dfs_unmake_h_unlink(ix)
				if v_link[ix] == LINKED:
					dfs_unmake_v_link(ix)
			#check_wall()
	elif ul_degree[ix] == 2:			# 上・左 両方接続済みの場合
		if fwd:
			if h_link[ix] == EMPTY: dfs_make_h_unlink(ix)
			if v_link[ix] == EMPTY: dfs_make_v_unlink(ix)
			#check_wall()
		else:
			if h_link[ix] == UNLINKED: dfs_unmake_h_unlink(ix)
			if v_link[ix] == UNLINKED: dfs_unmake_v_unlink(ix)
			#check_wall()
#
func make_h_link(ix):
	h_link[ix] = LINKED
	degree[ix] += 1
	degree[ix+1] += 1
	lnk_count[ix] += 1
	lnk_count[ix-ARY_WIDTH] += 1
func make_v_link(ix):
	v_link[ix] = LINKED
	degree[ix] += 1
	degree[ix+ARY_WIDTH] += 1
	lnk_count[ix] += 1
	lnk_count[ix-1] += 1
func unmake_h_link(ix):			# dfs_make_h_link() 処理を戻す
	h_link[ix] = EMPTY
	degree[ix] -= 1
	degree[ix+1] -= 1
	lnk_count[ix] -= 1
	lnk_count[ix-ARY_WIDTH] -= 1
func unmake_v_link(ix):			# dfs_make_v_link() 処理を戻す
	v_link[ix] = EMPTY
	degree[ix] -= 1
	degree[ix+ARY_WIDTH] -= 1
	lnk_count[ix] -= 1
	lnk_count[ix-1] -= 1
func rev_h_link(ix):
	if h_link[ix] == LINKED:
		unmake_h_link(ix)
	else:
		make_h_link(ix)
func rev_v_link(ix):
	if v_link[ix] == LINKED:
		unmake_v_link(ix)
	else:
		make_v_link(ix)
func can_move_edge_up(ix) -> bool:	# 水平エッジを上に移動可能？
	if h_link[ix] != LINKED: return false
	if v_link[ix-ARY_WIDTH] == UNLINKED_DTM || v_link[ix-ARY_WIDTH+1] == UNLINKED_DTM:
		return false
	if h_link[ix-ARY_WIDTH] != EMPTY: return false
	if v_link[ix-ARY_WIDTH] == EMPTY && degree[ix-ARY_WIDTH] == 2:
		return false
	if v_link[ix-ARY_WIDTH+1] == EMPTY && degree[ix-ARY_WIDTH+1] == 2:
		return false
	return true
func can_move_edge_down(ix) -> bool:	# 水平エッジを下に移動可能？
	if h_link[ix] != LINKED: return false
	if v_link[ix] == UNLINKED_DTM || v_link[ix+1] == UNLINKED_DTM:
		return false
	if h_link[ix+ARY_WIDTH] != EMPTY: return false
	if v_link[ix] == EMPTY && degree[ix+ARY_WIDTH] == 2:
		return false
	if v_link[ix+1] == EMPTY && degree[ix+ARY_WIDTH+1] == 2:
		return false
	return true
func can_move_edge_left(ix) -> bool:	# 水平エッジを左に移動可能？
	if v_link[ix] != LINKED: return false
	if h_link[ix-1] == UNLINKED_DTM || h_link[ix+ARY_WIDTH-1] == UNLINKED_DTM:
		return false
	if v_link[ix-1] != EMPTY: return false
	if h_link[ix-1] == EMPTY && degree[ix-1] == 2:
		return false
	if h_link[ix+ARY_WIDTH-1] == EMPTY && degree[ix+ARY_WIDTH-1] == 2:
		return false
	return true
func can_move_edge_right(ix) -> bool:	# 水平エッジを右に移動可能？
	if v_link[ix] != LINKED: return false
	if h_link[ix] == UNLINKED_DTM || h_link[ix+ARY_WIDTH] == UNLINKED_DTM:
		return false
	if v_link[ix+1] != EMPTY: return false
	if h_link[ix] == EMPTY && degree[ix+1] == 2:
		return false
	if h_link[ix+ARY_WIDTH] == EMPTY && degree[ix+ARY_WIDTH+1] == 2:
		return false
	return true
func move_edge_up(ix):	# 水平エッジを上に移動
	unmake_h_link(ix)
	rev_v_link(ix-ARY_WIDTH)
	rev_v_link(ix-ARY_WIDTH+1)
	make_h_link(ix-ARY_WIDTH)
func move_edge_down(ix):	# 水平エッジを下に移動
	unmake_h_link(ix)
	rev_v_link(ix)
	rev_v_link(ix+1)
	make_h_link(ix+ARY_WIDTH)
func move_edge_left(ix):	# 垂直エッジを左に移動
	unmake_v_link(ix)
	rev_h_link(ix-1)
	rev_h_link(ix+ARY_WIDTH-1)
	make_v_link(ix-1)
func move_edge_right(ix):	# 垂直エッジを右に移動
	unmake_v_link(ix)
	rev_h_link(ix)
	rev_h_link(ix+ARY_WIDTH)
	make_v_link(ix+1)
func list_movable_edges() -> Array:
	var lst = []
	for y in range(N_VERT):
		for x in range(N_HORZ):
			var ix = xyToIX(x, y)
			if can_move_edge_up(ix): lst.push_back(ix*4 + MOVE_UP)
			if can_move_edge_left(ix): lst.push_back(ix*4 + MOVE_LEFT)
			if can_move_edge_right(ix): lst.push_back(ix*4 + MOVE_RIGHT)
			if can_move_edge_down(ix): lst.push_back(ix*4 + MOVE_DOWN)
	return lst
#
func gen__outer_loop():		# 最外周ループ作成
	for x in range(N_HORZ):
		make_h_link(xyToIX(x, 0))
		make_h_link(xyToIX(x, N_VERT))
		make_v_link(xyToIX(0, x))
		make_v_link(xyToIX(N_VERT, x))
func move_edge_dir_ix(dix):
	var dir = dix % 4
	var ix = dix / 4
	if dir == MOVE_UP:
		move_edge_up(ix)
	elif dir == MOVE_LEFT:
		move_edge_left(ix)
	elif dir == MOVE_RIGHT:
		move_edge_right(ix)
	elif dir == MOVE_DOWN:
		move_edge_down(ix)
func is_there_00() -> bool:			# ０が縦 or 横に並んでいるか？
	for y in range(N_VERT):
		for x in range(N_HORZ):
			var ix = xyToIX(x, y)
			if lnk_count[ix] == 0 && (lnk_count[ix+1] == 0 || lnk_count[ix+ARY_WIDTH] == 0):
				return true
	return false
func gen_proper_loop():
	clear_edges()
	gen__outer_loop()
	for k in range(10000):
		var lst = list_movable_edges()
		if lst.is_empty(): break
		var i = 0
		if lst.size() > 1:
			i = randi() % lst.size()
		move_edge_dir_ix(lst[i])
		if k >= 100 && !is_there_00():
			break
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
func print_ul_degree():
	print("vertex ul_degree:")
	for y in range(N_VERT+1):
		var txt = ""
		for x in range(N_HORZ+1):
			var ix = xyToIX(x, y)
			txt += "%d " % ul_degree[ix]
		print(txt)
	print("\n")
func print_degree():
	print("vertex degree:")
	for y in range(N_VERT+1):
		var txt = ""
		for x in range(N_HORZ+1):
			var ix = xyToIX(x, y)
			txt += "%d " % degree[ix]
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
