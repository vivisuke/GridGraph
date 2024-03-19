extends ColorRect

const LINKED_DTM = 2		# 連結確定
const LINKED = 1			# 連結
const EMPTY = 0
const UNLINKED = -1			# 非連結
const UNLINKED_DTM = -2		# 非連結確定

var width = 440.0
var height = width
var N_HORZ = 5
var N_VERT = 5
var ARY_WIDTH = N_HORZ + 1
var ARY_HEIGHT = N_VERT + 2
var ARY_SIZE = ARY_WIDTH * ARY_HEIGHT
var CELL_WIDTH = width / N_HORZ
var CWD2 = CELL_WIDTH / 2
const R = 3.0		# 格子点半径
const XWD = 16.0
const XWD2 = XWD/2
const LINK_COL = Color.GREEN
const LINK_DTM_COL = Color.ORANGE

var sx = -1
var sy = -1
var h_link = []
var v_link = []
#var non_h_link = []
#var non_v_link = []
#var h_link_cnf = []
#var v_link_cnf = []
#var non_h_link_cnf = []
#var non_v_link_cnf = []

func xyToIX(x, y): return x + (y+1)*ARY_WIDTH

func _draw():
	# エッジ線・非連結 X 描画
	#for y in range(N_VERT+1):
	#	var py = y * CELL_WIDTH
	#	for x in range(N_HORZ+1):
	#		var px = x * CELL_WIDTH
	#		var ix = xyToIX(x, y)
	#		# 連結済み線
	#		if h_link[ix] == LINKED_DTM:
	#			draw_line(Vector2(px, py), Vector2(px+CELL_WIDTH, py) , LINK_DTM_COL, R*2)
	#		elif h_link[ix] == LINKED:
	#			draw_line(Vector2(px, py), Vector2(px+CELL_WIDTH, py) , LINK_COL, R*2)
	#		if v_link[ix] == LINKED_DTM:
	#			draw_line(Vector2(px, py), Vector2(px, py+CELL_WIDTH) , LINK_DTM_COL, R*2)
	#		elif v_link[ix] == LINKED:
	#			draw_line(Vector2(px, py), Vector2(px, py+CELL_WIDTH) , LINK_COL, R*2)
	#		# 非連結状態 X
	#		if x < N_HORZ && h_link[ix] == UNLINKED_DTM:
	#			draw_line(Vector2(px+CWD2-XWD2, py-XWD2), Vector2(px+CWD2+XWD2, py+XWD2), LINK_DTM_COL, 3)
	#			draw_line(Vector2(px+CWD2-XWD2, py+XWD2), Vector2(px+CWD2+XWD2, py-XWD2), LINK_DTM_COL, 3)
	#		elif x < N_HORZ && h_link[ix] == UNLINKED:
	#			draw_line(Vector2(px+CWD2-XWD2, py-XWD2), Vector2(px+CWD2+XWD2, py+XWD2), LINK_COL, 3)
	#			draw_line(Vector2(px+CWD2-XWD2, py+XWD2), Vector2(px+CWD2+XWD2, py-XWD2), LINK_COL, 3)
	#		if y < N_VERT && v_link[ix] == UNLINKED_DTM:
	#			draw_line(Vector2(px-XWD2, py+CWD2-XWD2), Vector2(px+XWD2, py+CWD2+XWD2), LINK_DTM_COL, 3)
	#			draw_line(Vector2(px-XWD2, py+CWD2+XWD2), Vector2(px+XWD2, py+CWD2-XWD2), LINK_DTM_COL, 3)
	#		elif y < N_VERT && v_link[ix] == UNLINKED:
	#			draw_line(Vector2(px-XWD2, py+CWD2-XWD2), Vector2(px+XWD2, py+CWD2+XWD2), LINK_COL, 3)
	#			draw_line(Vector2(px-XWD2, py+CWD2+XWD2), Vector2(px+XWD2, py+CWD2-XWD2), LINK_COL, 3)
	# 格子点描画
	for y in range(N_VERT+1):
		for x in range(N_HORZ+1):
			draw_circle(Vector2(x*CELL_WIDTH, y*CELL_WIDTH), R, Color.BLACK)
	if sx >= 0 && sy >= 0:
		draw_circle(Vector2(sx*CELL_WIDTH, sy*CELL_WIDTH), R*3, Color.BLACK)
	pass
func _ready():
	width = self.width
	height = self.height
	var CELL_WIDTH = width / N_HORZ
	set_board_size(5)
	pass # Replace with function body.
func set_board_size(n):
	N_HORZ = n
	N_VERT = n
	CELL_WIDTH = width / N_HORZ
	CWD2 = CELL_WIDTH / 2
	queue_redraw()
func _process(delta):
	pass
