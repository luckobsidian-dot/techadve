extends Node2D

const W := 540.0
const H := 960.0
const SAVE_PATH := "user://techadv_save.cfg"

const STARTING_COINS := 30
const STATION_COST := 25
const SPAWN_INTERVAL := 2.8
const DOUBLE_ORDER_CHANCE := 0.3   # chance a customer asks for 2 of everything

const FLOOR := Color("f6e6d3")
const WALL := Color("d8efff")
const BLUE := Color("6ca7ff")
const DARK := Color("24445a")
const GREEN := Color("50d46a")
const GREEN_DARK := Color("2b9d49")
const GOLD := Color("ffcc48")
const RED := Color("ff7272")
const PANEL := Color("f8fbff")
const GREY := Color("adb8c8")
const SHADOW := Color(0, 0, 0, 0.12)
const PLANT := Color("52b96a")
const BOX := Color("d2a56d")
const BOX_DARK := Color("b68245")
const CASE_PINK := Color("ff8ac5")
const CASE_BLUE := Color("84b5ff")

# Shop layout. The *_BASE numbers are for a 540 x 960 screen; _layout() turns them into the
# real positions (the vars below) so the shop fills tall phones too.
const STATION_BASE := Vector2(84, 250)
const MB_BASE := Vector2(84, 420)
const SCREEN_BASE := Vector2(84, 590)
const WORKER_HOME_BASE := Vector2(262, 410)
const WORKER_HOME2_BASE := Vector2(304, 462)
const WORKER2_GEM_COST := 20   # gems to hire the second worker (Store)
const COUNTER_BASE := Vector2(390, 282)
const ENTRANCE_BASE := Vector2(500, 690)
const EXIT_BASE := Vector2(500, 690)
const QUEUE_ORIGIN_BASE := Vector2(408, 512)
const FRONT_BASE := Vector2(408, 422)
const WORKER_BOX_BASE := Vector2(250, 360)
const ROOM_TOP := 110.0       # top of the shop room (base numbers)
const ROOM_BOTTOM := 850.0    # bottom of the shop room (base numbers)
const SCREEN_UNLOCK_COST := 100000
const PRODUCT_MENUS := ["station", "mb", "screen", "bat", "cam"]
const MB_UNLOCK_COST := 25000
const MB_COLOR := Color("3fbf6a")

# UI rectangles (shared by drawing and tapping so they always match)
const UPGRADE_BTN_RECT := Rect2(14, 880, 172, 62)
const PLUS_BTN_RECT := Rect2(194, 14, 52, 52)
const GEAR_BTN_RECT := Rect2(474, 14, 52, 52)
const UPGRADE_PANEL := Rect2(45, 210, 450, 570)
const UPGRADE_CLOSE := Rect2(447, 220, 36, 36)
const SETTINGS_PANEL := Rect2(55, 220, 430, 520)
const SETTINGS_CLOSE := Rect2(447, 230, 36, 36)
const RESET_BTN := Rect2(135, 630, 270, 52)
const SETTING_COUNT := 5
const STORE_PANEL := Rect2(45, 210, 450, 570)
const STORE_CLOSE := Rect2(447, 220, 36, 36)
const STATION_PANEL := Rect2(55, 290, 430, 330)
const STATION_CLOSE := Rect2(437, 300, 36, 36)
const STATION_BUY := Rect2(130, 536, 280, 60)
const STATION_MAX_LEVEL := 25
const UPGRADE_COUNT := 6

# Offline rewards
const OFFLINE_MAX_SECONDS := 7200   # 2 hours max
const OFFLINE_MIN_SECONDS := 60     # shorter trips earn nothing
const OFFLINE_CLOCK_SLACK := 120    # clock set back by more than this = tampering
const OFFLINE_RATE := 1.0           # 1.0 = same as playing, 0.5 = half
const OFFLINE_PANEL := Rect2(55, 250, 430, 420)
const OFFLINE_CLAIM2 := Rect2(110, 504, 320, 60)   # "Claim x2" (costs gems)
const OFFLINE_CLAIM := Rect2(170, 578, 200, 46)    # plain Claim under the x2 button
const OFFLINE_X2_GEMS := 3                         # gems one "Claim x2" costs

# Quests (reward gems). [title, what it counts, goal, gems]
const QUESTS_BTN_RECT := Rect2(354, 880, 172, 62)
const QUEST_PANEL := Rect2(45, 210, 450, 570)
const QUEST_CLOSE := Rect2(447, 220, 36, 36)
const QUEST_ROWS := 5
const DAILY_BONUS_GEMS := 2   # extra gems for finishing all 3 daily quests
const QUEST_TAB_RECTS := [Rect2(75, 266, 190, 36), Rect2(275, 266, 190, 36)]
# ---- Worlds ----
const WORLD_ENTRY_COINS := 100000   # coins you must be holding in Zokia factory to enter Zamzung
const WORLD_ENTRY_LEVEL := 23        # everything in Zokia factory must reach this to enter Zamzung
const WORLD_BTN_RECT := Rect2(392, 14, 74, 52)
const WORLD_PANEL := Rect2(45, 210, 450, 570)
const WORLD_CLOSE := Rect2(447, 220, 36, 36)
# Zamzung has 5 benches in two columns, its own worker spots and worker box.
const WORLD2_BASE := [Vector2(38, 230), Vector2(190, 230), Vector2(38, 390), Vector2(190, 390), Vector2(38, 550)]
const WORLD2_HOME_BASE := [Vector2(130, 705), Vector2(196, 725)]
const WORLD2_BOX_BASE := Vector2(222, 580)
# Shop data for each world. Zamzung: same 30 coin start, but more items and much bigger money and costs.
const WORLDS := [
	{
		"name": "Zokia factory",
		"sign": "ZOKIA FACTORY",
		"products": ["Case Maker", "Motherboard", "Screen"],
		"words": ["case", "motherboard", "screen"],
		"what": ["case", "case & motherboard", "full phone"],
		"unlock": [25, 5000, 35000],
		"base": [2, 5, 20],
		"gain": [2, 3, 8],
		"gain_extra": [1, 0, 0],   # every 3rd level pays this much extra (Case Maker: +2, +2, +3, ...)
		"gain_every": [3, 3, 3],
		"bonus": [4, 8, 20],
		"lvl_cost": [8.0, 400.0, 3000.0],
		"lvl_grow": [1.22, 1.25, 1.25],
		"craft": [3.0, 6.0, 10.0],
		"craft_fast": [1.5, 3.0, 5.0],
		"upgrade_costs": [250, 600, 1500, 5000, 10000, 30000],
	},
	{
		"name": "Zamzung",
		"sign": "ZAMZUNG",
		"products": ["Case Maker", "Chipset", "Screen", "Battery", "Camera"],
		"words": ["case", "chipset", "screen", "battery", "camera"],
		"what": ["case", "case & chipset", "case, chipset & screen", "phone with battery", "full smartphone"],
		"unlock": [25, 250000, 1000000, 4000000, 15000000],
		"base": [8, 50, 200, 600, 1600],
		"gain": [8, 30, 80, 240, 640],
		"gain_extra": [0, 0, 0, 0, 0],
		"gain_every": [3, 3, 3, 3, 3],
		"bonus": [40, 80, 200, 600, 1600],
		"lvl_cost": [50.0, 4000.0, 30000.0, 120000.0, 400000.0],
		"lvl_grow": [1.23, 1.26, 1.26, 1.26, 1.26],
		"craft": [3.0, 6.0, 10.0, 12.0, 15.0],
		"craft_fast": [1.5, 3.0, 5.0, 6.0, 7.5],
		"upgrade_costs": [2500, 6000, 15000, 50000, 100000, 300000],
	},
]
const W0_UPGRADE_TITLES := ["More customers", "Faster cases", "Energy", "Faster motherboards", "Money", "Faster screens"]
const W0_UPGRADE_KEYS := ["more_customers_bought", "faster_cases_bought", "energy_bought", "faster_mb_bought", "money_bought", "faster_screen_bought"]
const QUESTS := [
	["Serve 5 customers", "served", 5, 1],
	["Earn 500 coins", "earned", 500, 1],
	["Buy your first upgrade", "upgrades", 1, 2],
	["Serve 3 double orders", "doubles", 3, 2],
	["Serve 25 customers", "served", 25, 3],
	["Earn 5,000 coins", "earned", 5000, 3],
	["Unlock the Motherboard", "mb", 1, 5],
	["Claim offline coins", "claims", 1, 2],
	["Buy 10 upgrades", "upgrades", 10, 5],
	["Serve 100 customers", "served", 100, 5],
	["Earn 100,000 coins", "earned", 100000, 8],
	["Unlock the Screen", "screen", 1, 10],
	["Serve 500 customers", "served", 500, 10],
]

var font: Font

# ---- screen layout (filled in by _layout) ----
var vw := W                 # visible width / height in layout units (>= 540 x 960)
var vh := H
var ox := 0.0               # left offset that centres the 540-wide game
var hud_dy := 0.0           # HUD (top bar) offset: keeps it below the notch / status bar
var bottom_dy := 0.0        # Upgrades / Quests buttons offset: glued to the bottom edge
var menu_dy := 0.0          # popups are centred in the visible area
var shop_dy := 0.0          # shop room offset
var shop_k := 1.0           # how much the shop is spread out vertically on tall screens
var room_bottom := ROOM_BOTTOM   # bottom of the room (shop layer coordinates)
var layer_off := Vector2.ZERO    # offset of the layer being drawn right now

var STATION_POS := STATION_BASE
var MB_POS := MB_BASE
var SCREEN_POS := SCREEN_BASE
var WORKER_HOME := WORKER_HOME_BASE
var WORKER_HOME2 := WORKER_HOME2_BASE
var COUNTER_POS := COUNTER_BASE
var ENTRANCE_POS := ENTRANCE_BASE
var EXIT_POS := EXIT_BASE
var QUEUE_BASE := QUEUE_ORIGIN_BASE
var FRONT_SPOT := FRONT_BASE
var WORKER_BOX_POS := WORKER_BOX_BASE
var WORLD2_POS: Array = WORLD2_BASE.duplicate()
var WORLD2_HOME: Array = WORLD2_HOME_BASE.duplicate()
var WORLD2_BOX := WORLD2_BOX_BASE
var coins := STARTING_COINS
var total_earned := 0

var station_open := false
var worker_open := false

var more_customers_bought := false
var energy_bought := false
var money_bought := false
var faster_cases_bought := false
var faster_mb_bought := false
var faster_screen_bought := false
var levels: Array = [0, 0, 0, 0, 0]                          # level of each product bench in the current world
var unlocked: Array = [false, false, false, false, false]    # bench 0 (Case Maker) uses station_open instead
var profits: Array = [2, 5, 20, 0, 0]                        # coins each part earns right now
var crafts: Array = [3.0, 6.0, 10.0, 12.0, 15.0]             # seconds each part takes right now
var world := 0                                               # 0 = Zokia factory, 1 = Zamzung
var world_states: Array = [{}, {}]                           # saved shop of each world (the live one is in the vars above)
var zamzung_open := false                                    # the gate was passed once, travel is free after that

var max_customers := 1
var worker_move_speed := 42.0

var customers: Array[Dictionary] = []
var leaving: Array[Dictionary] = []
var next_customer_id := 1
var spawn_timer := 0.0
var menu := ""            # "", "upgrades", "settings" or "station"
var reset_confirm := false
var toast := ""
var toast_time := 0.0
var floating_texts: Array[Dictionary] = []
var clock := 0.0

# settings (kept when you reset progress)
var sound_on := true
var vibrate_on := true
var floaters_on := true
var compact_on := false
var notify_on := true

var sfx := {}
var menu_shown := ""       # which popup is being drawn (stays during the close animation)
var menu_t := 0.0          # 0 = hidden, 1 = fully open
var toggle_anim := [0.0, 0.0, 0.0, 0.0, 0.0]
var last_coins := 0
var coin_pop := 0.0
var ripples: Array[Dictionary] = []
var _sb_cache := {}
var last_seen := 0          # unix time, only ever moves forward (stops clock cheating)
var offline_pending := 0    # reward waiting to be claimed (saved, so it can't be lost)
var offline_secs := 0       # how much offline time that reward covers
var clock_warned := false
var notify_bridge = null    # optional: scripts/notify_bridge.gd
var gems := 0
var quest_claimed := 0      # bit i set = quest i collected
var quest_seen := 0         # quests we already announced (not saved)
var stat_served := 0
var stat_doubles := 0
var stat_upgrades := 0
var stat_claims := 0
var quest_tab := 0
var daily_day := 0               # which day the current daily quests are for
var daily_set: Array = []        # 3 entries: [title, what it counts, goal, gems]
var daily_progress := {}         # what it counts -> amount done today
var daily_claimed := 0           # bit per daily quest already collected
var daily_bonus_claimed := false
var daily_seen := 0              # announced already (not saved)
var daily_timer := 0.0
var tz_bias := 0                 # seconds between UTC and the phone's local time

var workers: Array = []       # worker 0 is the first; worker 1 is hired in the Store
var worker2_hired := false
# Workers share one order at a time: the front customer's parts are split between them.
var orders: Array = []        # one entry per customer being served: {id, todo, total, delivered}

func _ready() -> void:
	font = ThemeDB.fallback_font
	_layout()
	get_viewport().size_changed.connect(_layout)
	_setup_audio()
	load_game()
	_recalc_stats()
	_reset_runtime_state()
	last_coins = coins
	_setup_bridges()
	_check_offline()
	_refresh_tz()
	quest_seen = _quests_ready_mask()
	daily_seen = _daily_ready_mask()
	if offline_pending > 0:
		menu = "offline"
	queue_redraw()

# ---------- Screen layout ----------
# The game is designed for 540 x 960. The project uses "expand" stretching, so a taller phone
# simply sees more height (e.g. 540 x 1170) and there are no black bars. Everything is drawn
# in layers: the HUD hangs from the top (below the notch), the buttons sit on the bottom
# edge, popups are centred, and the shop room grows to fill the space in between.

func _sy(y: float) -> float:
	return ROOM_TOP + (y - ROOM_TOP) * shop_k

func _m(v: Vector2) -> Vector2:
	return Vector2(v.x, _sy(v.y))

func _layout() -> void:
	var vs := get_viewport_rect().size
	vw = maxf(vs.x, W)
	vh = maxf(vs.y, H)
	ox = (vw - W) * 0.5
	var top := 0.0
	var bot := 0.0
	if OS.has_feature("mobile"):
		var win := Vector2(DisplayServer.window_get_size())
		var sa := Rect2(DisplayServer.get_display_safe_area())
		if win.x > 0.0 and win.y > 0.0 and sa.size.x > 0.0 and sa.size.y > 0.0:
			var s := minf(win.x / W, win.y / H)   # screen pixels per layout unit
			top = clampf(sa.position.y / s, 0.0, 70.0)
			bot = clampf((win.y - sa.end.y) / s, 0.0, 50.0)
	hud_dy = top
	shop_dy = top
	bottom_dy = (vh - H) - bot
	menu_dy = (vh - H) * 0.5 + (top - bot) * 0.5
	room_bottom = ROOM_BOTTOM + bottom_dy - top
	shop_k = clampf((room_bottom - ROOM_TOP) / (ROOM_BOTTOM - ROOM_TOP), 0.88, 1.28)
	STATION_POS = _m(STATION_BASE)
	MB_POS = _m(MB_BASE)
	SCREEN_POS = _m(SCREEN_BASE)
	WORKER_HOME = _m(WORKER_HOME_BASE)
	WORKER_HOME2 = _m(WORKER_HOME2_BASE)
	COUNTER_POS = _m(COUNTER_BASE)
	ENTRANCE_POS = _m(ENTRANCE_BASE)
	EXIT_POS = _m(EXIT_BASE)
	# the queue hangs off the counter (not stretched), so customers always stand right in front of it
	FRONT_SPOT = COUNTER_POS + (FRONT_BASE - COUNTER_BASE)
	QUEUE_BASE = FRONT_SPOT + (QUEUE_ORIGIN_BASE - FRONT_BASE)
	WORKER_BOX_POS = _m(WORKER_BOX_BASE)
	WORLD2_BOX = _m(WORLD2_BOX_BASE)
	for i in range(WORLD2_BASE.size()):
		WORLD2_POS[i] = _m(WORLD2_BASE[i])
	for i in range(WORLD2_HOME_BASE.size()):
		WORLD2_HOME[i] = _m(WORLD2_HOME_BASE[i])
	queue_redraw()

# Sets the drawing transform for the current layer (plus an optional pop/scale on top).
func _xf(p: Vector2 = Vector2.ZERO, sc: Vector2 = Vector2.ONE) -> void:
	draw_set_transform(p + layer_off, 0.0, sc)

func _worker_home(i: int) -> Vector2:
	if world == 1:
		return WORLD2_HOME[i]
	return WORKER_HOME if i == 0 else WORKER_HOME2

func _worker_box_pos() -> Vector2:
	return WORLD2_BOX if world == 1 else WORKER_BOX_POS

func _product_count() -> int:
	return (WORLDS[world]["products"] as Array).size()

func _prod_pos(product: int) -> Vector2:
	if world == 1:
		return WORLD2_POS[product]
	if product == 0:
		return STATION_POS
	if product == 1:
		return MB_POS
	return SCREEN_POS

func _deliver_spot(i: int) -> Vector2:
	return COUNTER_POS + Vector2(-40, 36 + 30 * i)

func _make_worker(i: int, mode: String) -> Dictionary:
	return {
		"position": (_worker_box_pos() + Vector2(34, 26)) if mode == "boxed" else _worker_home(i),
		"mode": mode,
		"timer": 0.0,
		"product": 0,
		"order": -1,
		"carried": []
	}

func _reset_runtime_state() -> void:
	customers.clear()
	leaving.clear()
	spawn_timer = 0.0
	workers.clear()
	workers.append(_make_worker(0, "idle" if worker_open else "boxed"))
	if worker2_hired and worker_open:
		workers.append(_make_worker(1, "idle"))
	orders.clear()

func _process(delta: float) -> void:
	delta = minf(delta, 0.1)
	clock += delta
	_track_time()
	_watch_quests()
	_watch_daily(delta)
	if toast_time > 0.0:
		toast_time -= delta
	for i in range(floating_texts.size() - 1, -1, -1):
		floating_texts[i]["time"] = float(floating_texts[i]["time"]) - delta
		if float(floating_texts[i]["time"]) <= 0.0:
			floating_texts.remove_at(i)

	if station_open and worker_open:
		_update_customers(delta)
		_update_workers(delta)
	_update_leaving(delta)
	_update_animations(delta)
	queue_redraw()

func _update_animations(delta: float) -> void:
	# popup open / close
	if menu != "":
		menu_shown = menu
		menu_t = minf(1.0, menu_t + delta * 6.0)
	else:
		menu_t = maxf(0.0, menu_t - delta * 9.0)
		if menu_t <= 0.0:
			menu_shown = ""
	# settings toggle switches slide
	for i in range(SETTING_COUNT):
		var target := 1.0 if _setting_value(i) else 0.0
		toggle_anim[i] = move_toward(float(toggle_anim[i]), target, delta * 8.0)
	# coin counter pops when you earn
	if coins > last_coins:
		coin_pop = 1.0
	last_coins = coins
	coin_pop = maxf(0.0, coin_pop - delta * 3.5)
	# tap ripples
	for i in range(ripples.size() - 1, -1, -1):
		ripples[i]["t"] = float(ripples[i]["t"]) + delta / 0.4
		if float(ripples[i]["t"]) >= 1.0:
			ripples.remove_at(i)

func _ease_back(t: float) -> float:
	var u := t - 1.0
	return 1.0 + 2.70158 * u * u * u + 1.70158 * u * u

# Serving spots at the counter: one per worker (the 2nd worker serves the 2nd customer).
func _slots() -> int:
	return clampi(workers.size(), 1, 2)

func _slot_spot(i: int) -> Vector2:
	return FRONT_SPOT + Vector2(66.0 * i, 0.0)

func _queue_target(i: int) -> Vector2:
	var n := _slots()
	if i < n:
		return _slot_spot(i)
	return QUEUE_BASE + Vector2(0, minf((i - n) * 60.0, 120.0))

func _update_customers(delta: float) -> void:
	if customers.size() < max_customers:
		spawn_timer += delta
		if spawn_timer >= SPAWN_INTERVAL:
			spawn_timer = 0.0
			customers.append({
				"id": next_customer_id,
				"position": ENTRANCE_POS,
				"shirt": [Color("ffb44c"), Color("7ddc9b"), Color("73b7ff")][randi() % 3],
				"qty": 2 if randf() < DOUBLE_ORDER_CHANCE else 1
			})
			next_customer_id += 1
	else:
		spawn_timer = 0.0
	for i in range(customers.size()):
		var target := _queue_target(i)
		customers[i]["position"] = (customers[i]["position"] as Vector2).move_toward(target, 55.0 * delta)

func _update_leaving(delta: float) -> void:
	for i in range(leaving.size() - 1, -1, -1):
		var p: Vector2 = (leaving[i]["position"] as Vector2).move_toward(EXIT_POS, 70.0 * delta)
		leaving[i]["position"] = p
		if p.distance_to(EXIT_POS) < 2.0:
			leaving.remove_at(i)

func _customer_qty(i: int) -> int:
	if i < 0 or i >= customers.size():
		return 1
	return int(customers[i].get("qty", 1))

func _customer_ready(i: int) -> bool:
	if i < 0 or i >= customers.size() or i >= _slots():
		return false
	return (customers[i]["position"] as Vector2).distance_to(_slot_spot(i)) < 3.0

func _customer_index(id: int) -> int:
	for i in range(customers.size()):
		if int(customers[i]["id"]) == id:
			return i
	return -1

func _order_index(id: int) -> int:
	for i in range(orders.size()):
		if int(orders[i]["id"]) == id:
			return i
	return -1

func _next_order_with_todo() -> int:
	for i in range(orders.size()):
		if not (orders[i]["todo"] as Array).is_empty():
			return i
	return -1

func _unlocked(product: int) -> bool:
	if product == 0:
		return station_open
	return bool(unlocked[product])

func _unlocked_products() -> Array:
	var list: Array = []
	for p in range(_product_count()):
		if _unlocked(p):
			list.append(p)
	return list

func _order_total() -> int:
	var total := 0
	for p in _unlocked_products():
		total += _profit(int(p))
	return total

func _station_spot(product: int, who: int = 0) -> Vector2:
	return _prod_pos(product) + Vector2(45 + 44 * who, 52)

func _profit(product: int) -> int:
	return int(profits[product])

func _craft(product: int) -> float:
	return float(crafts[product])

func _update_workers(delta: float) -> void:
	# Every customer standing at a serving spot gets an order. An order needs every part you've
	# unlocked, once per item the customer asked for. A free worker takes the next part of the
	# first order that still has parts waiting, so the 2nd worker goes to the 2nd customer as
	# soon as every part of the 1st customer's order is taken.
	for i in range(mini(customers.size(), _slots())):
		var cid := int(customers[i]["id"])
		if _customer_ready(i) and _order_index(cid) < 0:
			var todo: Array = []
			for _k in range(_customer_qty(i)):
				todo.append_array(_unlocked_products())
			if not todo.is_empty():
				orders.append({"id": cid, "todo": todo, "total": todo.size(), "delivered": []})
	for i in range(workers.size()):
		_update_worker(i, delta)
	for k in range(orders.size() - 1, -1, -1):
		if (orders[k]["delivered"] as Array).size() >= int(orders[k]["total"]):
			_complete_sale(k)

func _update_worker(i: int, delta: float) -> void:
	var w: Dictionary = workers[i]
	var mode: String = str(w["mode"])
	var pos: Vector2 = w["position"]
	var product: int = int(w["product"])
	if mode == "idle":
		var oi := _next_order_with_todo()
		if oi >= 0:
			w["order"] = int(orders[oi]["id"])
			w["product"] = int((orders[oi]["todo"] as Array).pop_front())
			w["mode"] = "to_station"
	elif mode == "to_station":
		var spot := _station_spot(product, i)
		w["position"] = pos.move_toward(spot, worker_move_speed * delta)
		if (w["position"] as Vector2).distance_to(spot) < 2.0:
			w["mode"] = "making"
			w["timer"] = _craft(product)
	elif mode == "making":
		w["timer"] = maxf(0.0, float(w["timer"]) - delta)
		if float(w["timer"]) <= 0.0:
			var carried: Array = w["carried"]
			carried.append(product)
			var oi := _order_index(int(w["order"]))
			if oi >= 0 and not (orders[oi]["todo"] as Array).is_empty():
				w["product"] = int((orders[oi]["todo"] as Array).pop_front())
				w["mode"] = "to_station"
			else:
				w["mode"] = "to_counter"
	elif mode == "to_counter":
		var dest := _deliver_spot(i)
		w["position"] = pos.move_toward(dest, worker_move_speed * delta)
		if (w["position"] as Vector2).distance_to(dest) < 2.0:
			var oi := _order_index(int(w["order"]))
			if oi >= 0:
				(orders[oi]["delivered"] as Array).append_array(w["carried"])
			w["carried"] = []
			w["order"] = -1
			w["mode"] = "returning"
	elif mode == "returning":
		var home := _worker_home(i)
		w["position"] = pos.move_toward(home, worker_move_speed * delta)
		if (w["position"] as Vector2).distance_to(home) < 2.0:
			w["mode"] = "idle"

func _complete_sale(oi: int) -> void:
	var o: Dictionary = orders[oi]
	orders.remove_at(oi)
	var ci := _customer_index(int(o["id"]))
	var qty := _customer_qty(ci)
	var delivered: Array = o["delivered"]
	var earned := 0
	for p in delivered:
		earned += _profit(int(p))
	if earned == 0:
		earned = _order_total() * qty
	if ci >= 0:
		# Customer walks out of the shop happily instead of vanishing.
		leaving.append(customers[ci])
		customers.remove_at(ci)
	coins += earned
	total_earned += earned
	stat_served += 1
	_count("served", 1)
	_count("earned", _quest_coins(earned))
	_count("parts", delivered.size())
	if qty > 1:
		stat_doubles += 1
		_count("doubles", 1)
	if floaters_on:
		floating_texts.append({"text": "+%s" % _fmt_num(earned), "position": COUNTER_POS + Vector2(8, -30), "time": 1.0})
	_sfx("coin")
	_vibe(20)
	var what_list: Array = WORLDS[world]["what"]
	var what: String = str(what_list[clampi(_unlocked_products().size() - 1, 0, what_list.size() - 1)])
	var what_txt := ("a " + what) if qty == 1 else ("%dx %s" % [qty, what])
	show_toast("Sold %s for %s coin%s!" % [what_txt, _fmt_num(earned), "" if earned == 1 else "s"])
	save_game()

func show_toast(message: String) -> void:
	toast = message
	toast_time = 1.9

func spend(amount: int) -> bool:
	if coins < amount:
		show_toast("Need %s more coins" % _fmt_num(amount - coins))
		_sfx("error")
		return false
	coins -= amount
	_sfx("buy")
	_vibe(35)
	return true

func unbox_station() -> void:
	if station_open:
		return
	if spend(STATION_COST):
		station_open = true
		if worker_open:
			show_toast("Shop opened! Customers are coming.")
		else:
			show_toast("Case Maker unboxed! Now unbox the Worker.")
		save_game()

func unbox_worker() -> void:
	if worker_open:
		return
	worker_open = true
	_sfx("buy")
	workers[0]["position"] = _worker_home(0)
	workers[0]["mode"] = "idle"
	if station_open:
		show_toast("Shop opened! Customers are coming.")
	else:
		show_toast("Worker unboxed! Now unbox the Case Maker.")
	save_game()

# ---------- Offline rewards ----------
# How it stays cheat-proof:
# - The reward is worked out and saved the moment you come back, so sitting on the
#   claim popup or changing the clock afterwards changes nothing.
# - last_seen only ever moves FORWARD. Set the clock back and you earn nothing and
#   the old time is kept. Set it forward and you get at most 2h, but the clock then
#   has to catch up before anything more is earned, so you never come out ahead.
# - Claiming empties the pending reward, so closing and reopening can't pay twice.

func _now() -> int:
	return int(Time.get_unix_time_from_system())

func _touch_seen() -> void:
	var now := _now()
	if now > last_seen:
		last_seen = now

func _warn_clock() -> void:
	if not clock_warned:
		clock_warned = true
		show_toast("Clock was set back - no offline rewards")

# Runs every frame. Also catches phone sleep / app in background / PC sleep.
func _track_time() -> void:
	var now := _now()
	if last_seen > 0 and now - last_seen >= OFFLINE_MIN_SECONDS:
		_check_offline()
	elif now >= last_seen:
		last_seen = now
		clock_warned = false
	elif now < last_seen - OFFLINE_CLOCK_SLACK:
		_warn_clock()

func _check_offline() -> void:
	_cancel_reminder()
	var now := _now()
	if last_seen <= 0:
		last_seen = now
		return
	var away := now - last_seen
	if away < 0:
		if away < -OFFLINE_CLOCK_SLACK:
			_warn_clock()
		return  # keep the old last_seen so rolling the clock back never helps
	last_seen = now
	clock_warned = false
	if away < OFFLINE_MIN_SECONDS or not (station_open and worker_open):
		return
	var secs := mini(away, OFFLINE_MAX_SECONDS)
	var rate := _offline_income_per_second() * OFFLINE_RATE
	var earned := int(rate * secs)
	if earned <= 0:
		return
	var cap := int(rate * OFFLINE_MAX_SECONDS)
	offline_pending = mini(offline_pending + earned, cap)
	offline_secs = mini(offline_secs + secs, OFFLINE_MAX_SECONDS)
	menu = "offline"
	reset_confirm = false
	save_game()

# How long (seconds) the workers need for one order of `qty` sets, splitting the
# parts between `n` workers the same way the game does (earliest free worker first).
func _order_seconds(qty: int, n: int) -> float:
	var speed := maxf(worker_move_speed, 1.0)
	var items: Array = []
	for _i in range(qty):
		items.append_array(_unlocked_products())
	var free: Array = []
	var pos: Array = []
	var made: Array = []
	for i in range(n):
		free.append(0.0)
		pos.append(_worker_home(i))
		made.append(false)
	for item in items:
		var best := 0
		for i in range(1, n):
			if float(free[i]) < float(free[best]):
				best = i
		var spot := _station_spot(int(item), best)
		free[best] = float(free[best]) + (pos[best] as Vector2).distance_to(spot) / speed + _craft(int(item))
		pos[best] = spot
		made[best] = true
	var finish := 0.0
	for i in range(n):
		if made[i]:
			finish = maxf(finish, float(free[i]) + (pos[i] as Vector2).distance_to(_deliver_spot(i)) / speed)
	return finish

# x = coins per second, y = customers per second the shop averages with your current
# upgrades (includes customers who ask for 2, and the second worker).
func _shop_rates() -> Vector2:
	if _unlocked_products().is_empty() or not worker_open:
		return Vector2.ZERO
	var speed := maxf(worker_move_speed, 1.0)
	var back := _deliver_spot(0).distance_to(_worker_home(0)) / speed
	# time until the next customer is standing at the counter
	var wait := QUEUE_BASE.distance_to(FRONT_SPOT) / 55.0
	if max_customers <= 1:
		wait = SPAWN_INTERVAL + ENTRANCE_POS.distance_to(FRONT_SPOT) / 55.0
	var n := 2 if worker2_hired else 1
	var revenue := 0.0
	var seconds := 0.0
	for q in range(1, 3):
		var chance := DOUBLE_ORDER_CHANCE if q == 2 else 1.0 - DOUBLE_ORDER_CHANCE
		revenue += chance * _order_total() * q
		var order_t: float = _order_seconds(q, n)
		if n >= 2 and max_customers >= 2:
			order_t = _order_seconds(q, 1) / float(n)   # each worker takes their own customer
		seconds += chance * maxf(order_t + maxf(back, wait), SPAWN_INTERVAL)
	return Vector2(revenue / seconds, 1.0 / seconds)

func _offline_income_per_second() -> float:
	return _shop_rates().x

func claim_offline(mult: int = 1) -> void:
	if offline_pending <= 0:
		menu = ""
		return
	var got := offline_pending * mult
	offline_pending = 0
	offline_secs = 0
	coins += got
	total_earned += got
	stat_claims += 1
	_count("claims", 1)
	_count("earned", _quest_coins(got))
	menu = ""
	_sfx("coin")
	_vibe(40)
	show_toast("Claimed %s coins!%s" % [_fmt_num(got), " (x2)" if mult > 1 else ""])
	save_game()

func _fmt_duration(secs: int) -> String:
	var h := int(secs / 3600.0)
	var m := int((secs % 3600) / 60.0)
	if h > 0:
		return ("%dh %dm" % [h, m]) if m > 0 else ("%dh" % h)
	if m > 0:
		return "%dm" % m
	return "%ds" % secs

# Save the "last seen" time when the app goes to the background or closes,
# and set the "your shop is full" reminder for when the 2h cap will be reached.
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_touch_seen()
		save_game()
		_schedule_reminder()
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		_cancel_reminder()

# ---------- Gems, "Claim x2" and quests ----------
# Gems come from quests. "Claim x2" on the Welcome back popup costs gems.
# The "shop is full" reminder needs an optional plugin (SETUP_NOTIFICATIONS.txt);
# without it nothing happens and the game runs fine.

func _setup_bridges() -> void:
	if ResourceLoader.exists("res://scripts/notify_bridge.gd"):
		notify_bridge = load("res://scripts/notify_bridge.gd").new()
		add_child(notify_bridge)

# ---------- Daily quests ----------
# 3 new quests every day (phone's local midnight). The day only ever moves forward,
# so setting the clock back can't bring old quests back. Goals scale with your shop.

func _refresh_tz() -> void:
	tz_bias = int(Time.get_time_zone_from_system().get("bias", 0)) * 60

func _local_day() -> int:
	var t := maxi(last_seen, _now())
	return floori((t + tz_bias) / 86400.0)

func _daily_secs_left() -> int:
	var t := maxi(last_seen, _now()) + tz_bias
	return 86400 - (t % 86400)

# Zamzung pays about 10x, so its coins count 1/10 toward "Earn coins" daily quests.
func _quest_coins(n: int) -> int:
	return n / 10 if world == 1 else n

func _count(stat: String, n: int) -> void:
	daily_progress[stat] = int(daily_progress.get(stat, 0)) + n

func _daily_prog(slot: int) -> int:
	return int(daily_progress.get(str(daily_set[slot][1]), 0))

func _daily_ready_mask() -> int:
	if daily_set.size() != 3:
		return 0
	var m := 0
	for s in range(3):
		if ((daily_claimed >> s) & 1) == 0 and _daily_prog(s) >= int(daily_set[s][2]):
			m |= (1 << s)
	if daily_claimed == 7 and not daily_bonus_claimed:
		m |= 8
	return m

func _watch_daily(delta: float) -> void:
	daily_timer -= delta
	if daily_timer > 0.0:
		return
	daily_timer = 1.0
	_refresh_tz()
	var day := _local_day()
	if day != daily_day or daily_set.size() != 3:
		_new_daily(day)

func _nice_number(v: float) -> int:
	if v < 100.0:
		return int(round(v / 5.0)) * 5
	var m := pow(10.0, floor(log(v) / log(10.0)) - 1.0)
	return int(round(v / m) * m)

func _new_daily(day: int) -> void:
	daily_day = day
	daily_progress = {}
	daily_claimed = 0
	daily_bonus_claimed = false
	daily_seen = 0
	var rates := _shop_rates()
	var served_goal := maxi(10, _nice_number(clampf(rates.y * 1200.0, 10.0, 150.0)))  # about 20 min of work
	var doubles_goal := clampi(int(served_goal * 0.25), 3, 40)
	var coins_goal := _nice_number(maxf(200.0, (rates.x / (10.0 if world == 1 else 1.0)) * 1200.0))
	var parts_goal := _nice_number(float(served_goal * maxi(_unlocked_products().size(), 1)))
	var pool := [
		["Serve %s customers", "served", served_goal, 2],
		["Serve %s double orders", "doubles", doubles_goal, 2],
		["Earn %s coins", "earned", coins_goal, 2],
		["Make %s parts", "parts", parts_goal, 1],
		["Claim offline coins", "claims", 1, 1],
	]
	var rng := RandomNumberGenerator.new()
	rng.seed = day * 7919 + 13   # same pick all day, even after restarting
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	daily_set = []
	for k in range(3):
		var e: Array = pool[k]
		var title := str(e[0])
		if title.contains("%s"):
			title = title % _fmt_coins(int(e[2]))
		daily_set.append([title, e[1], e[2], e[3]])
	save_game()

func claim_daily(slot: int) -> void:
	if slot < 0 or slot > 2 or daily_set.size() != 3 or ((daily_claimed >> slot) & 1) == 1:
		return
	if _daily_prog(slot) < int(daily_set[slot][2]):
		show_toast("Keep going!")
		_sfx("error")
		return
	daily_claimed |= (1 << slot)
	var g := int(daily_set[slot][3])
	gems += g
	_sfx("buy")
	_vibe(30)
	show_toast("Daily done! +%d gem%s" % [g, "" if g == 1 else "s"])
	save_game()

func claim_daily_bonus() -> void:
	if daily_bonus_claimed:
		return
	if daily_claimed != 7:
		show_toast("Finish all 3 daily quests first")
		_sfx("error")
		return
	daily_bonus_claimed = true
	gems += DAILY_BONUS_GEMS
	_sfx("buy")
	_vibe(40)
	show_toast("Bonus! +%d gems" % DAILY_BONUS_GEMS)
	save_game()

func hire_worker2() -> void:
	if worker2_hired:
		return
	if not (station_open and worker_open):
		show_toast("Open the shop first")
		_sfx("error")
		return
	if gems < WORKER2_GEM_COST:
		show_toast("Need %d gems - finish quests to earn them" % WORKER2_GEM_COST)
		_sfx("error")
		return
	gems -= WORKER2_GEM_COST
	worker2_hired = true
	workers.append(_make_worker(1, "idle"))
	_sfx("buy")
	_vibe(40)
	show_toast("New worker hired! They serve the next customer.")
	save_game()

func claim_double() -> void:
	if offline_pending <= 0:
		return
	if gems < OFFLINE_X2_GEMS:
		show_toast("Need %d gems - finish quests to earn them" % OFFLINE_X2_GEMS)
		_sfx("error")
		return
	gems -= OFFLINE_X2_GEMS
	claim_offline(2)

func _quest_progress(i: int) -> int:
	match str(QUESTS[i][1]):
		"served":
			return stat_served
		"earned":
			return total_earned
		"upgrades":
			return stat_upgrades
		"doubles":
			return stat_doubles
		"claims":
			return stat_claims
		"mb":
			return 1 if _w0_unlocked(1) else 0
		"screen":
			return 1 if _w0_unlocked(2) else 0
	return 0

func _quest_done(i: int) -> bool:
	return _quest_progress(i) >= int(QUESTS[i][2])

func _quest_claimed(i: int) -> bool:
	return ((quest_claimed >> i) & 1) == 1

func _quests_ready_mask() -> int:
	var m := 0
	for i in range(QUESTS.size()):
		if not _quest_claimed(i) and _quest_done(i):
			m |= (1 << i)
	return m

func _milestones_ready() -> int:
	var n := 0
	for i in range(QUESTS.size()):
		if not _quest_claimed(i) and _quest_done(i):
			n += 1
	return n

func _quests_ready_count() -> int:
	return _milestones_ready() + _bits(_daily_ready_mask())

func _bits(m: int) -> int:
	var n := 0
	while m > 0:
		n += m & 1
		m >>= 1
	return n

# Up to QUEST_ROWS quests to show: finished ones first, then the next unfinished ones.
func _quest_visible() -> Array:
	var list: Array = []
	for i in range(QUESTS.size()):
		if list.size() < QUEST_ROWS and not _quest_claimed(i) and _quest_done(i):
			list.append(i)
	for i in range(QUESTS.size()):
		if list.size() < QUEST_ROWS and not _quest_claimed(i) and not _quest_done(i):
			list.append(i)
	return list

func _watch_quests() -> void:
	var mask := _quests_ready_mask()
	if (mask & ~quest_seen) != 0:
		show_toast("Quest complete! Tap Quests")
		_sfx("buy")
	quest_seen = mask
	var dmask := _daily_ready_mask()
	if (dmask & ~daily_seen) != 0:
		show_toast("Daily quest complete! Tap Quests")
		_sfx("buy")
	daily_seen = dmask

func claim_quest(i: int) -> void:
	if i < 0 or i >= QUESTS.size() or _quest_claimed(i):
		return
	if not _quest_done(i):
		show_toast("Keep going!")
		_sfx("error")
		return
	quest_claimed |= (1 << i)
	var g := int(QUESTS[i][3])
	gems += g
	_sfx("buy")
	_vibe(30)
	show_toast("Quest done! +%d gem%s" % [g, "" if g == 1 else "s"])
	save_game()

func _schedule_reminder() -> void:
	if notify_bridge == null or not notify_on:
		return
	if not (station_open and worker_open) or _offline_income_per_second() <= 0.0:
		return
	var delay := OFFLINE_MAX_SECONDS - offline_secs  # time until the cap is hit
	if delay < OFFLINE_MIN_SECONDS:
		return
	notify_bridge.schedule(delay, "Your shop is full!", "It earned the max offline coins. Come claim them!")

func _cancel_reminder() -> void:
	if notify_bridge != null:
		notify_bridge.cancel()

# ---------- Upgrades ----------

func _upgrade_info(i: int) -> Dictionary:
	var d: Dictionary = WORLDS[world]
	var costs: Array = d["upgrade_costs"]
	var norm: Array = d["craft"]
	var fast: Array = d["craft_fast"]
	var cost: int = int(costs[i])
	var part1: String = "Boards" if world == 0 else "Chipsets"
	var title1: String = "Faster motherboards" if world == 0 else "Faster chipsets"
	match i:
		0:
			return {"title": "More customers", "desc": "Up to 3 customers at once", "cost": cost, "bought": more_customers_bought, "locked": false}
		1:
			return {"title": "Faster cases", "desc": "Cases are made in %ss (now %ss)" % [_fmt_time(float(fast[0])), _fmt_time(float(norm[0]))], "cost": cost, "bought": faster_cases_bought, "locked": false}
		2:
			return {"title": "Energy", "desc": "Worker walks faster", "cost": cost, "bought": energy_bought, "locked": false}
		3:
			var mb_ok: bool = bool(unlocked[1])
			return {"title": title1, "desc": ("%s in %ss (now %ss)" % [part1, _fmt_time(float(fast[1])), _fmt_time(float(norm[1]))]) if mb_ok else ("Unlock the %s first" % _product_name(1)), "cost": cost, "bought": faster_mb_bought, "locked": not mb_ok}
		4:
			var money_desc: String = "+4 case, +8 board, +20 screen" if world == 0 else "Big bonus on every part"
			return {"title": "Money", "desc": money_desc, "cost": cost, "bought": money_bought, "locked": false}
		_:
			var sc_ok: bool = bool(unlocked[2])
			var title5: String = "Faster screens" if world == 0 else "Faster parts"
			var desc5: String = "Screens in %ss (now %ss)" % [_fmt_time(float(fast[2])), _fmt_time(float(norm[2]))]
			if world == 1:
				desc5 = "Screen, battery, camera 2x faster"
			return {"title": title5, "desc": desc5 if sc_ok else "Unlock the Screen first", "cost": cost, "bought": faster_screen_bought, "locked": not sc_ok}

func _fmt_coins(n: int) -> String:
	if n >= 1000:
		var k := n / 1000.0
		return ("%.1fk" % k).replace(".0k", "k")
	return str(n)

func _upgrade_row_rect(i: int) -> Rect2:
	return Rect2(60, 282 + i * 80, 420, 72)

func _upgrade_button_rect(i: int) -> Rect2:
	var r := _upgrade_row_rect(i)
	return Rect2(r.position.x + r.size.x - 124, r.position.y + 15, 112, 42)

func _upgrade_can_buy(i: int) -> bool:
	var info := _upgrade_info(i)
	return not bool(info["bought"]) and not bool(info["locked"]) and coins >= int(info["cost"])

func buy_upgrade(i: int) -> void:
	var info := _upgrade_info(i)
	if bool(info["bought"]):
		show_toast("Already upgraded")
		return
	if bool(info["locked"]):
		show_toast("Unlock it first")
		return
	if not spend(int(info["cost"])):
		return
	match i:
		0:
			more_customers_bought = true
			show_toast("More customers unlocked!")
		1:
			faster_cases_bought = true
			show_toast("Faster cases! Now %ss per case" % _fmt_time(float((WORLDS[world]["craft_fast"] as Array)[0])))
		2:
			energy_bought = true
			show_toast("Energy upgraded!")
		3:
			faster_mb_bought = true
			show_toast("%s! Now %ss each" % [str(_upgrade_info(3)["title"]), _fmt_time(float((WORLDS[world]["craft_fast"] as Array)[1]))])
		4:
			money_bought = true
			show_toast("Money upgraded!")
		_:
			faster_screen_bought = true
			show_toast("%s! Now %ss for screens" % [str(_upgrade_info(5)["title"]), _fmt_time(float((WORLDS[world]["craft_fast"] as Array)[2]))])
	stat_upgrades += 1
	_recalc_stats()
	save_game()

# Products: 0 = Case Maker, 1 = Motherboard / Chipset, 2 = Screen, 3 = Battery, 4 = Camera (Zamzung only).
func _level(product: int) -> int:
	return int(levels[product])

func _level_cost(product: int) -> int:
	var base: Array = WORLDS[world]["lvl_cost"]
	var grow: Array = WORLDS[world]["lvl_grow"]
	return int(round(float(base[product]) * pow(float(grow[product]), float(levels[product]))))

# What reaching level `lvl` adds to a part's pay (the normal gain, plus the extra on every Nth level).
func _gain_at(product: int, lvl: int) -> int:
	var d: Dictionary = WORLDS[world]
	var g: int = int((d["gain"] as Array)[product])
	var extra: int = int((d["gain_extra"] as Array)[product])
	var every: int = maxi(1, int((d["gain_every"] as Array)[product]))
	if extra > 0 and lvl % every == 0:
		g += extra
	return g

# Total extra pay after `n` levels.
func _gain_total(product: int, n: int) -> int:
	var d: Dictionary = WORLDS[world]
	var g: int = int((d["gain"] as Array)[product])
	var extra: int = int((d["gain_extra"] as Array)[product])
	var every: int = maxi(1, int((d["gain_every"] as Array)[product]))
	return g * n + extra * floori(float(n) / float(every))

# Shown as "Next level: +N coins".
func _level_gain(product: int) -> int:
	return _gain_at(product, int(levels[product]) + 1)

func _unlock_cost(product: int) -> int:
	return int((WORLDS[world]["unlock"] as Array)[product])

func _product_name(product: int) -> String:
	return str((WORLDS[world]["products"] as Array)[product])

func _product_word(product: int) -> String:
	return str((WORLDS[world]["words"] as Array)[product])

func buy_product_upgrade(product: int) -> void:
	if not _unlocked(product):
		if product == 0:
			return
		if spend(_unlock_cost(product)):
			unlocked[product] = true
			_recalc_stats()
			stat_upgrades += 1
			show_toast("%s unlocked!" % _product_name(product))
			save_game()
		return
	if _level(product) >= STATION_MAX_LEVEL:
		show_toast("%s is maxed out!" % _product_name(product))
		return
	if not spend(_level_cost(product)):
		return
	levels[product] = int(levels[product]) + 1
	_recalc_stats()
	stat_upgrades += 1
	show_toast("%s level %d! %s coins each" % [_product_name(product), _level(product), _fmt_num(_profit(product))])
	save_game()

func _product_upgrade_affordable(product: int) -> bool:
	if product == 0 and not station_open:
		return false
	if not _unlocked(product):
		return coins >= _unlock_cost(product)
	return _level(product) < STATION_MAX_LEVEL and coins >= _level_cost(product)

# All gameplay stats are derived from what you own, so they never get out of sync.
func _recalc_stats() -> void:
	var d: Dictionary = WORLDS[world]
	var base: Array = d["base"]
	var bonus: Array = d["bonus"]
	var norm: Array = d["craft"]
	var fast: Array = d["craft_fast"]
	max_customers = 3 if more_customers_bought else 1
	worker_move_speed = 72.0 if energy_bought else 42.0
	profits = []
	crafts = []
	for p in range(base.size()):
		var pay: int = int(base[p]) + _gain_total(p, int(levels[p]))
		if money_bought:
			pay += int(bonus[p])
		profits.append(pay)
		var quick: bool = false
		if p == 0:
			quick = faster_cases_bought
		elif p == 1:
			quick = faster_mb_bought
		else:
			quick = faster_screen_bought
		crafts.append(float(fast[p]) if quick else float(norm[p]))

func reset_progress() -> void:
	coins = STARTING_COINS
	total_earned = 0
	station_open = false
	worker_open = false
	more_customers_bought = false
	energy_bought = false
	money_bought = false
	faster_cases_bought = false
	faster_mb_bought = false
	faster_screen_bought = false
	levels = [0, 0, 0, 0, 0]
	unlocked = [false, false, false, false, false]
	world = 0
	world_states = [{}, {}]
	zamzung_open = false
	_recalc_stats()
	floating_texts.clear()
	offline_pending = 0
	offline_secs = 0
	gems = 0
	worker2_hired = false
	daily_day = 0
	daily_set = []
	daily_progress = {}
	daily_claimed = 0
	daily_bonus_claimed = false
	daily_seen = 0
	quest_claimed = 0
	quest_seen = 0
	stat_served = 0
	stat_doubles = 0
	stat_upgrades = 0
	stat_claims = 0
	_touch_seen()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	_reset_runtime_state()
	save_game()  # rewrites the file with fresh progress but keeps your settings
	show_toast("Progress reset")

# ---------- Worlds ----------
# World 0 = Zokia factory, world 1 = Zamzung. Each world keeps its own shop (coins, benches,
# upgrades). Gems, quests, stats, the extra worker and settings are shared by both.

func _fresh_world() -> Dictionary:
	return {
		"coins": STARTING_COINS,
		"station_open": false,
		"worker_open": false,
		"more_customers_bought": false,
		"energy_bought": false,
		"money_bought": false,
		"faster_cases_bought": false,
		"faster_mb_bought": false,
		"faster_screen_bought": false,
		"levels": [0, 0, 0, 0, 0],
		"unlocked": [false, false, false, false, false],
	}

func _dump_world() -> Dictionary:
	return {
		"coins": coins,
		"station_open": station_open,
		"worker_open": worker_open,
		"more_customers_bought": more_customers_bought,
		"energy_bought": energy_bought,
		"money_bought": money_bought,
		"faster_cases_bought": faster_cases_bought,
		"faster_mb_bought": faster_mb_bought,
		"faster_screen_bought": faster_screen_bought,
		"levels": levels.duplicate(),
		"unlocked": unlocked.duplicate(),
	}

func _levels_from(v) -> Array:
	var out: Array = []
	for k in range(5):
		if v is Array and k < v.size():
			out.append(clampi(int(v[k]), 0, STATION_MAX_LEVEL))
		else:
			out.append(0)
	return out

func _unlocked_from(v) -> Array:
	var out: Array = []
	for k in range(5):
		if v is Array and k < v.size():
			out.append(bool(v[k]))
		else:
			out.append(false)
	return out

func _apply_world(sv: Dictionary) -> void:
	coins = maxi(0, int(sv.get("coins", STARTING_COINS)))
	station_open = bool(sv.get("station_open", false))
	worker_open = bool(sv.get("worker_open", false))
	more_customers_bought = bool(sv.get("more_customers_bought", false))
	energy_bought = bool(sv.get("energy_bought", false))
	money_bought = bool(sv.get("money_bought", false))
	faster_cases_bought = bool(sv.get("faster_cases_bought", false))
	faster_mb_bought = bool(sv.get("faster_mb_bought", false))
	faster_screen_bought = bool(sv.get("faster_screen_bought", false))
	levels = _levels_from(sv.get("levels", []))
	unlocked = _unlocked_from(sv.get("unlocked", []))
	_recalc_stats()

# What Zokia factory looks like right now (live vars if you are in it, saved copy otherwise).
func _w0_state() -> Dictionary:
	if world == 0:
		return _dump_world()
	var sv: Dictionary = world_states[0]
	if sv.is_empty():
		return _fresh_world()
	return sv

func _w0_unlocked(p: int) -> bool:
	var sv: Dictionary = _w0_state()
	var list: Array = _unlocked_from(sv.get("unlocked", []))
	return bool(list[p])

# The "Tech Adventure" gate: every bench at level 23 and every upgrade owned in Zokia factory.
# Each entry is [label, have, goal].
func _world_requirements() -> Array:
	var sv: Dictionary = _w0_state()
	var lv: Array = _levels_from(sv.get("levels", []))
	var names: Array = WORLDS[0]["products"]
	var out: Array = []
	for p in range(3):
		out.append(["%s level" % str(names[p]), int(lv[p]), WORLD_ENTRY_LEVEL])
	for k in range(W0_UPGRADE_KEYS.size()):
		var owned: int = 1 if bool(sv.get(str(W0_UPGRADE_KEYS[k]), false)) else 0
		out.append([str(W0_UPGRADE_TITLES[k]), owned, 1])
	out.append(["Coins", maxi(0, int(sv.get("coins", 0))), WORLD_ENTRY_COINS])
	return out

func _world_gate_open() -> bool:
	for r in _world_requirements():
		if int(r[1]) < int(r[2]):
			return false
	return true

func travel_to(target: int) -> void:
	if target < 0 or target >= WORLDS.size():
		return
	if target == world:
		show_toast("You are already here")
		return
	if target == 1 and not zamzung_open:
		if not _world_gate_open():
			show_toast("Max everything to level %d in Zokia factory first" % WORLD_ENTRY_LEVEL)
			_sfx("error")
			return
		zamzung_open = true
	world_states[world] = _dump_world()
	world = target
	var sv: Dictionary = world_states[world]
	if sv.is_empty():
		sv = _fresh_world()
	_apply_world(sv)
	_reset_runtime_state()
	last_coins = coins
	menu = ""
	_sfx("buy")
	_vibe(40)
	show_toast("Welcome to %s!" % str(WORLDS[world]["name"]))
	save_game()

# ---------- Settings / audio / formatting ----------

const SETTING_NAMES := ["Sound", "Vibration", "Floating +coins", "Compact numbers", "Notifications"]

func _setting_row(i: int) -> Rect2:
	return Rect2(75, 290 + i * 58, 390, 50)

func _setting_value(i: int) -> bool:
	match i:
		0:
			return sound_on
		1:
			return vibrate_on
		2:
			return floaters_on
		3:
			return compact_on
		_:
			return notify_on

func _toggle_setting(i: int) -> void:
	match i:
		0:
			sound_on = not sound_on
		1:
			vibrate_on = not vibrate_on
		2:
			floaters_on = not floaters_on
			if not floaters_on:
				floating_texts.clear()
		3:
			compact_on = not compact_on
		_:
			notify_on = not notify_on
			if not notify_on:
				_cancel_reminder()
	_sfx("coin")
	_vibe(15)
	save_game()

func _fmt_num(n: int) -> String:
	if compact_on:
		if n >= 1000000:
			return "%.2fM" % (n / 1000000.0)
		if n >= 10000:
			return ("%.1fk" % (n / 1000.0)).replace(".0k", "k")
		return str(n)
	var digits := str(n)
	var out := ""
	var count := 0
	for i in range(digits.length() - 1, -1, -1):
		out = digits[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "," + out
	return out

func _make_blip(freq: float, dur: float) -> AudioStreamWAV:
	var rate := 22050
	var n := int(rate * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in range(n):
		var t := float(i) / rate
		var env := (1.0 - float(i) / n)
		var sample := sin(TAU * freq * t) + 0.35 * sin(TAU * freq * 2.0 * t)
		data.encode_s16(i * 2, int(sample * env * 0.28 * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	return wav

func _setup_audio() -> void:
	var defs := {"coin": [880.0, 0.12], "buy": [620.0, 0.16], "error": [170.0, 0.14]}
	for key in defs:
		var player := AudioStreamPlayer.new()
		player.stream = _make_blip(float(defs[key][0]), float(defs[key][1]))
		player.volume_db = -6.0
		add_child(player)
		sfx[key] = player

func _sfx(key: String) -> void:
	if sound_on and sfx.has(key):
		(sfx[key] as AudioStreamPlayer).play()

func _vibe(ms: int) -> void:
	if vibrate_on:
		Input.vibrate_handheld(ms)

# ---------- Input ----------

func _input(event: InputEvent) -> void:
	var tap := Vector2(-1000, -1000)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		tap = event.position
	elif event is InputEventScreenTouch and event.pressed:
		tap = event.position
	else:
		return
	ripples.append({"pos": tap, "t": 0.0})
	if ripples.size() > 4:
		ripples.remove_at(0)
	_handle_tap(tap)

func _handle_tap(raw: Vector2) -> void:
	# popups are drawn centred in the visible area, so shift the tap into their coordinates
	var tap := raw - Vector2(ox, menu_dy)
	if menu == "offline":
		if OFFLINE_CLAIM2.has_point(tap):
			claim_double()
		elif OFFLINE_CLAIM.has_point(tap):
			claim_offline()
		return

	if menu == "quests":
		if QUEST_CLOSE.has_point(tap) or not QUEST_PANEL.has_point(tap):
			menu = ""
			return
		for tab in range(2):
			if (QUEST_TAB_RECTS[tab] as Rect2).has_point(tap):
				quest_tab = tab
				return
		if quest_tab == 0:
			for s in range(3):
				if _quest_button_rect(s).has_point(tap):
					claim_daily(s)
					return
			if _quest_button_rect(3).has_point(tap):
				claim_daily_bonus()
			return
		var vis := _quest_visible()
		for r in range(vis.size()):
			if _quest_button_rect(r).has_point(tap):
				claim_quest(int(vis[r]))
				return
		return

	if menu == "worlds":
		if WORLD_CLOSE.has_point(tap) or not WORLD_PANEL.has_point(tap):
			menu = ""
			return
		for i in range(WORLDS.size()):
			if _world_button_rect(i).has_point(tap):
				travel_to(i)
				return
		return

	if menu == "upgrades":
		if UPGRADE_CLOSE.has_point(tap) or not UPGRADE_PANEL.has_point(tap):
			menu = ""
			return
		for i in range(UPGRADE_COUNT):
			if _upgrade_button_rect(i).has_point(tap):
				buy_upgrade(i)
				return
		return

	var pm := PRODUCT_MENUS.find(menu)
	if pm >= 0:
		if STATION_CLOSE.has_point(tap) or not STATION_PANEL.has_point(tap):
			menu = ""
			return
		if STATION_BUY.has_point(tap):
			buy_product_upgrade(pm)
		return

	if menu == "settings":
		if SETTINGS_CLOSE.has_point(tap) or not SETTINGS_PANEL.has_point(tap):
			menu = ""
			reset_confirm = false
			return
		for i in range(SETTING_COUNT):
			if _setting_row(i).has_point(tap):
				_toggle_setting(i)
				return
		if RESET_BTN.has_point(tap):
			if reset_confirm:
				reset_progress()
				reset_confirm = false
				menu = ""
			else:
				reset_confirm = true
		return

	if menu == "store":
		if STORE_CLOSE.has_point(tap) or not STORE_PANEL.has_point(tap):
			menu = ""
		elif _store_button_rect(0).has_point(tap):
			hire_worker2()
		return

	# main screen: each layer has its own offset
	var bot_tap := raw - Vector2(ox, bottom_dy)
	var hud_tap := raw - Vector2(ox, hud_dy)
	var shop_tap := raw - Vector2(ox, shop_dy)
	if UPGRADE_BTN_RECT.has_point(bot_tap):
		menu = "upgrades"
		return
	if QUESTS_BTN_RECT.has_point(bot_tap):
		menu = "quests"
		quest_tab = 1 if (_daily_ready_mask() == 0 and _milestones_ready() > 0) else 0
		return
	if PLUS_BTN_RECT.has_point(hud_tap):
		menu = "store"
		return
	if WORLD_BTN_RECT.has_point(hud_tap):
		menu = "worlds"
		return
	if GEAR_BTN_RECT.has_point(hud_tap):
		menu = "settings"
		reset_confirm = false
		return
	for p in range(_product_count()):
		var pp: Vector2 = _prod_pos(p)
		if p == 0 and not station_open:
			if Rect2(pp.x - 10, pp.y + 10, 110, 92).has_point(shop_tap):
				unbox_station()
				return
		elif Rect2(pp.x - 10, pp.y - 10, 150, 125).has_point(shop_tap):
			menu = str(PRODUCT_MENUS[p])
			return
	var bp: Vector2 = _worker_box_pos()
	if not worker_open and Rect2(bp.x + 2, bp.y - 2, 78, 84).has_point(shop_tap):
		unbox_worker()
		return

# ---------- Drawing ----------

func _draw() -> void:
	# layer 0: the whole screen (also covers the notch area and wide tablets)
	layer_off = Vector2.ZERO
	_xf()
	draw_rect(Rect2(0, 0, vw, vh), WALL if world == 0 else Color("dcd6f7"))
	# layer 1: the shop room, spread to fill the space between the HUD and the buttons
	layer_off = Vector2(ox, shop_dy)
	_xf()
	_draw_background()
	_draw_shop_decor()
	_draw_station()
	_draw_counter()
	_draw_customers()
	_draw_worker()
	_draw_toast_and_floaters()
	# layer 2: top bar
	layer_off = Vector2(ox, hud_dy)
	_xf()
	_draw_title()
	_draw_hud()
	_draw_world_button()
	# layer 3: bottom buttons
	layer_off = Vector2(ox, bottom_dy)
	_xf()
	_draw_upgrade_button()
	_draw_quests_button()
	# layer 4: popups
	layer_off = Vector2(ox, menu_dy)
	_xf()
	if menu_shown != "":
		_draw_menu_layer()
	# layer 5: tap ripples use raw screen positions
	layer_off = Vector2.ZERO
	_xf()
	_draw_ripples()

func _menu_panel_rect() -> Rect2:
	match menu_shown:
		"upgrades":
			return UPGRADE_PANEL
		"settings":
			return SETTINGS_PANEL
		"store":
			return STORE_PANEL
		"offline":
			return OFFLINE_PANEL
		"quests":
			return QUEST_PANEL
		"worlds":
			return WORLD_PANEL
		_:
			return STATION_PANEL

func _draw_menu_layer() -> void:
	draw_rect(Rect2(-ox, -menu_dy, vw, vh), Color(0.04, 0.09, 0.16, 0.6 * clampf(menu_t * 1.6, 0.0, 1.0)))
	var k := maxf(0.0, _ease_back(menu_t))
	if k < 0.03:
		return
	# pop the panel in / out around its own centre
	var c := _menu_panel_rect().get_center()
	_xf(c * (1.0 - k), Vector2(k, k))
	match menu_shown:
		"upgrades":
			_draw_upgrade_menu()
		"settings":
			_draw_settings_menu()
		"station":
			_draw_product_menu(0)
		"mb":
			_draw_product_menu(1)
		"screen":
			_draw_product_menu(2)
		"bat":
			_draw_product_menu(3)
		"cam":
			_draw_product_menu(4)
		"worlds":
			_draw_world_menu()
		"store":
			_draw_store_menu()
		"offline":
			_draw_offline_menu()
		"quests":
			_draw_quest_menu()
	_xf()

func _draw_ripples() -> void:
	for r in ripples:
		var t := float(r["t"])
		draw_arc(r["pos"], 6.0 + 30.0 * t, 0.0, TAU, 28, Color(0.17, 0.44, 0.95, 0.55 * (1.0 - t)), 3.0)

func _draw_background() -> void:
	var rb := room_bottom
	# checkered floor (runs down to the bottom of the room)
	var light := Color("f7e9d8")
	var dark := Color("f0dcc4")
	if world == 1:
		light = Color("eaecf8")
		dark = Color("dcdff2")
	var rows := int(ceil((rb - 190.0) / 50.0))
	for row in range(rows):
		var y := 190.0 + row * 50.0
		var h := minf(50.0, rb - y)
		for col in range(10):
			draw_rect(Rect2(20 + col * 50, y, 50, h), light if (row + col) % 2 == 0 else dark)
	# back wall + baseboard
	draw_rect(Rect2(20, 110, 500, 74), Color("cfe7ff"))
	draw_rect(Rect2(20, 184, 500, 8), Color("a9cbe6"))
	draw_rect(Rect2(20, 192, 500, 4), SHADOW)
	# side walls
	draw_rect(Rect2(20, 110, 10, rb - 110.0), Color("b8d7ef"))
	draw_rect(Rect2(510, 110, 10, rb - 110.0), Color("b8d7ef"))
	# front edge
	draw_rect(Rect2(20, rb - 8.0, 500, 8), Color("caa97c"))
	# entrance door on the right wall (customers come in and leave through it)
	var door_y := ENTRANCE_POS.y - 50.0
	draw_rect(Rect2(506, door_y, 14, 100), Color("8a5a35"))
	draw_rect(Rect2(509, door_y + 6.0, 8, 88), Color("a97849"))
	draw_circle(Vector2(512, door_y + 52.0), 2.5, GOLD)
	# queue rug
	var rug := Rect2(QUEUE_BASE.x - 32.0, QUEUE_BASE.y - 15.0, 96, 170)
	draw_rect(rug, Color(0.55, 0.39, 0.91, 0.13))
	draw_rect(rug, Color(0.55, 0.39, 0.91, 0.3), false, 2.0)

func _draw_shop_decor() -> void:
	# wall sign
	draw_rect(Rect2(42, 122, 160, 52), Color("2d71d8"))
	draw_rect(Rect2(46, 126, 152, 44), Color("3d86f0"))
	var sign_txt: String = str(WORLDS[world]["sign"])
	label_centered(sign_txt, Rect2(42, 122, 160, 52), 24 if sign_txt.length() <= 9 else 17, Color.WHITE)
	# window
	draw_rect(Rect2(230, 122, 90, 52), Color("a9cbe6"))
	draw_rect(Rect2(234, 126, 82, 44), Color("eaf8ff"))
	draw_rect(Rect2(273, 126, 4, 44), Color("a9cbe6"))
	draw_rect(Rect2(234, 146, 82, 4), Color("a9cbe6"))
	# wall shelf with display cases
	draw_rect(Rect2(350, 122, 150, 52), Color("fffdf6"))
	draw_rect(Rect2(350, 150, 150, 6), Color("d7ad79"))
	draw_rect(Rect2(350, 170, 150, 4), Color("d7ad79"))
	var case_cols := [CASE_PINK, CASE_BLUE, GOLD, GREEN, CASE_PINK, CASE_BLUE]
	for i in range(6):
		draw_rect(Rect2(358 + i * 23, 132, 14, 18), case_cols[i])
		draw_rect(Rect2(358 + i * 23, 156, 14, 14), case_cols[(i + 2) % 6])
	# plants in the corners
	var rb := room_bottom
	if world == 0:
		_draw_plant(Vector2(48, 228))
	_draw_plant(Vector2(56, rb - 50.0))
	_draw_plant(Vector2(484, rb - 50.0))
	# welcome mat
	var mat := Rect2(180, rb - 80.0, 180, 44)
	draw_rect(mat, Color("6ca7ff"))
	draw_rect(mat, Color(1, 1, 1, 0.4), false, 2.0)
	label_centered(str(WORLDS[world]["name"]), mat, 20, Color.WHITE)

func _draw_title() -> void:
	label_centered("Tech Adventure", Rect2(0, 70, W, 38), 30, Color("2b6ff2"))

func _draw_station() -> void:
	for p in range(_product_count()):
		var pp: Vector2 = _prod_pos(p)
		if p == 0 and not station_open:
			draw_rect(Rect2(pp.x - 4, pp.y + 108, 142, 8), SHADOW)
			draw_rect(Rect2(pp.x - 8, pp.y + 54, 150, 56), Color("ffffff"))
			draw_rect(Rect2(pp.x, pp.y + 20, 105, 78), Color("dfedf9"))
			draw_rect(Rect2(pp.x + 10, pp.y + 34, 84, 42), Color("353d56"))
			var bob := sin(clock * 3.0) * 3.0
			_draw_box(Rect2(pp.x + 8, pp.y + 20 + bob, 90, 72), "Case Maker\n%dc" % STATION_COST)
		elif _unlocked(p):
			_draw_workbench(pp, p)
		else:
			_draw_clear_box(pp, p)

func _draw_workbench(pos: Vector2, product: int) -> void:
	draw_rect(Rect2(pos.x - 4, pos.y + 108, 142, 8), SHADOW)
	draw_rect(Rect2(pos.x - 8, pos.y + 54, 150, 56), Color("ffffff"))
	draw_rect(Rect2(pos.x, pos.y + 20, 105, 78), Color("dfedf9"))
	draw_rect(Rect2(pos.x + 10, pos.y + 34, 84, 42), Color("353d56"))
	_draw_item(product, Vector2(pos.x + 26, pos.y + 42), 52.0, 26.0)
	var craft := _craft(product)
	label("%ss" % _fmt_time(craft), Vector2(pos.x + 24, pos.y + 8), 22, DARK)
	var bar_w := 98.0
	var fill := 0.0
	var holding := false
	for w in workers:
		if str(w["mode"]) == "making" and int(w["product"]) == product:
			fill = maxf(fill, (craft - float(w["timer"])) / craft)
		elif (w["carried"] as Array).has(product):
			holding = true
	if fill <= 0.0 and holding:
		fill = 1.0
	draw_rect(Rect2(pos.x + 4, pos.y + 22, bar_w, 10), Color("243548"))
	draw_rect(Rect2(pos.x + 4, pos.y + 22, bar_w * clampf(fill, 0.0, 1.0), 10), GREEN)
	label("Lv%d" % _level(product), Vector2(pos.x + 106, pos.y + 82), 16, DARK)
	if _product_upgrade_affordable(product):
		_draw_dot(pos + Vector2(128, 14))

func _draw_item(product: int, at: Vector2, w: float, h: float) -> void:
	if product == 0:
		draw_rect(Rect2(at.x, at.y, w, h), CASE_PINK)
	elif product == 1:
		_draw_board(at, w, h)
	elif product == 3:
		# battery: dark cell with a green charge bar and a little tip
		draw_rect(Rect2(at.x, at.y + h * 0.1, w * 0.9, h * 0.8), Color("2a3a4a"))
		draw_rect(Rect2(at.x + w * 0.9, at.y + h * 0.35, w * 0.1, h * 0.3), GREY)
		draw_rect(Rect2(at.x + 2, at.y + h * 0.1 + 2, (w * 0.9 - 4) * 0.7, h * 0.8 - 4), GREEN)
	elif product == 4:
		# camera: grey body with a blue lens
		draw_rect(Rect2(at.x, at.y, w, h), Color("5b6475"))
		draw_circle(at + Vector2(w * 0.5, h * 0.5), minf(w, h) * 0.4, Color("1b2330"))
		draw_circle(at + Vector2(w * 0.5, h * 0.5), minf(w, h) * 0.24, Color("6cc4ff"))
	else:
		draw_rect(Rect2(at.x, at.y, w, h), Color("2a3a4a"))
		draw_rect(Rect2(at.x + 2, at.y + 2, w - 4, h - 4), Color("6cc4ff"))
		draw_line(at + Vector2(w * 0.2, h * 0.85), at + Vector2(w * 0.5, h * 0.15), Color(1, 1, 1, 0.55), 2.0)

func _draw_board(at: Vector2, w: float, h: float) -> void:
	draw_rect(Rect2(at.x, at.y, w, h), MB_COLOR)
	draw_rect(Rect2(at.x + w * 0.35, at.y + h * 0.25, w * 0.28, h * 0.45), Color("2a3a4a"))
	for i in range(3):
		draw_rect(Rect2(at.x + 4 + i * 5, at.y + 4, 3, 5), GOLD)
		draw_rect(Rect2(at.x + 4 + i * 5, at.y + h - 9, 3, 5), GOLD)
	draw_rect(Rect2(at.x + w - 12, at.y + 5, 8, h - 10), Color("2f9a55"))

func _draw_clear_box(pos: Vector2, product: int) -> void:
	var bob := sin(clock * 3.0 + 2.0 * product) * 3.0
	var r := Rect2(pos.x + 4, pos.y + 14 + bob, 100, 90)
	draw_rect(Rect2(pos.x + 2, pos.y + 108, 106, 8), SHADOW)
	# the part inside the glass
	_draw_item(product, Vector2(r.position.x + 22, r.position.y + 14), 56.0, 40.0)
	# glass
	draw_rect(r, Color(0.78, 0.93, 1.0, 0.42))
	draw_rect(r, Color(1, 1, 1, 0.95), false, 3.0)
	draw_line(r.position + Vector2(14, 62), r.position + Vector2(40, 10), Color(1, 1, 1, 0.55), 4.0)
	draw_line(r.position + Vector2(30, 72), r.position + Vector2(48, 36), Color(1, 1, 1, 0.4), 3.0)
	# price banner
	var banner := Rect2(r.position.x + 5, r.position.y + r.size.y - 36, r.size.x - 10, 32)
	draw_rect(banner, Color(0.1, 0.15, 0.2, 0.75))
	label_centered(_product_name(product), Rect2(banner.position.x, banner.position.y, banner.size.x, 16), 13, Color.WHITE)
	label_centered(_fmt_coins(_unlock_cost(product)), Rect2(banner.position.x, banner.position.y + 14, banner.size.x, 18), 15, GOLD)
	if _product_upgrade_affordable(product):
		_draw_dot(pos + Vector2(128, 14))

func _fmt_time(t: float) -> String:
	if is_equal_approx(t, roundf(t)):
		return str(int(t))
	return "%.1f" % t

func _draw_counter() -> void:
	draw_rect(Rect2(COUNTER_POS.x - 14, COUNTER_POS.y + 86, 132, 8), SHADOW)
	draw_rect(Rect2(COUNTER_POS.x - 18, COUNTER_POS.y, 132, 88), Color("ffffff"))
	draw_rect(Rect2(COUNTER_POS.x - 18, COUNTER_POS.y + 50, 132, 38), Color("d7ad79"))
	draw_rect(Rect2(COUNTER_POS.x + 72, COUNTER_POS.y + 12, 22, 14), Color("2f4151"))
	# cashier
	draw_circle(COUNTER_POS + Vector2(88, 22), 15, Color("f2c3a0"))
	draw_circle(COUNTER_POS + Vector2(88, 17), 17, Color("915836"))
	draw_rect(Rect2(COUNTER_POS.x + 75, COUNTER_POS.y + 36, 26, 26), Color("384f80"))
	# price bubbles (one per customer waiting at a serving spot, stacked above the counter)
	for slot in range(_slots()):
		if not _customer_ready(slot):
			continue
		var items := _unlocked_products()
		var qty := _customer_qty(slot)
		var oy := -42.0 * slot
		var price_txt := "%d" % (_order_total() * qty)
		var bw := 112.0
		if font != null:
			bw = maxf(112.0, 26.0 + items.size() * 22.0 + font.get_string_size(price_txt, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 20).x)
		var bx: float = minf(COUNTER_POS.x - 6, W - 12.0 - bw)
		_rbox(Rect2(bx, COUNTER_POS.y - 38 + oy, bw, 36), Color.WHITE, 10, Color("d3e3f7"), 2, true)
		if qty > 1:
			var bc := Vector2(bx + bw - 4, COUNTER_POS.y - 40 + oy)
			draw_circle(bc, 14, RED)
			label_centered("x%d" % qty, Rect2(bc.x - 14, bc.y - 14, 28, 28), 14, Color.WHITE)
		for k in range(items.size()):
			_draw_item(int(items[k]), Vector2(bx + 8 + k * 22, COUNTER_POS.y - 27 + oy), 18.0, 14.0)
		label(price_txt, Vector2(bx + 14 + items.size() * 22, COUNTER_POS.y - 11 + oy), 20, Color("e0a400"))

func _draw_shadow(p: Vector2, y_off: float = 34.0) -> void:
	_xf(p + Vector2(0, y_off), Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 18, Color(0, 0, 0, 0.14))
	_xf()

func _draw_eyes(head: Vector2) -> void:
	draw_circle(head + Vector2(-5, -1), 2.2, Color("2a2a33"))
	draw_circle(head + Vector2(5, -1), 2.2, Color("2a2a33"))

# Legless little guys: a round head floating over a rounded body.
func _draw_person(p: Vector2, shirt: Color, qty: int = 1) -> void:
	_draw_shadow(p, 32.0)
	var q := p + Vector2(0, sin(clock * 5.0 + p.x * 0.05) * 1.5)
	_rbox(Rect2(q.x - 14, q.y - 4, 28, 34), shirt, 14)
	draw_circle(q + Vector2(0, -16), 14, Color("f0c6a4"))
	_draw_eyes(q + Vector2(0, -16))
	if qty > 1:
		_rbox(Rect2(q.x - 17, q.y - 54, 34, 20), Color.WHITE, 10, Color("d3e3f7"), 2)
		label_centered("x%d" % qty, Rect2(q.x - 17, q.y - 54, 34, 20), 14, DARK)

func _draw_customers() -> void:
	for c in leaving:
		_draw_person(c["position"], c["shirt"])
	for c in customers:
		_draw_person(c["position"], c["shirt"], int(c.get("qty", 1)))
	if station_open and worker_open:
		var px := QUEUE_BASE.x - 24.0
		var posts := [Vector2(px, QUEUE_BASE.y), Vector2(px, QUEUE_BASE.y + 70.0), Vector2(px, QUEUE_BASE.y + 140.0)]
		for i in range(posts.size() - 1):
			draw_line(posts[i] + Vector2(0, -26), posts[i + 1] + Vector2(0, -26), Color("8b63e8"), 3.0)
		for post in posts:
			draw_rect(Rect2(post.x - 3, post.y - 28, 6, 28), DARK)
			draw_circle(post + Vector2(0, -28), 5, GOLD)

func _draw_worker() -> void:
	if not worker_open:
		var bob := sin(clock * 3.0 + 1.0) * 3.0
		var bp: Vector2 = _worker_box_pos()
		_draw_box(Rect2(bp.x, bp.y + bob, 82, 82), "Worker\nFREE")
		return
	for i in range(workers.size()):
		_draw_one_worker(i)

func _draw_one_worker(i: int) -> void:
	var w: Dictionary = workers[i]
	var wp: Vector2 = w["position"]
	_draw_shadow(wp, 36.0)
	var busy := str(w["mode"]) != "idle"
	var p := wp + Vector2(0, sin(clock * (9.0 if busy else 3.0) + i) * (2.0 if busy else 1.2))
	var lower := Color("2f4870") if i == 0 else Color("7a3b8f")
	var shirt := Color("ffffff") if i == 0 else Color("ffd166")
	var hair := Color("2b2b35") if i == 0 else Color("8a4b2a")
	# body: coloured lower half, shirt on top, no legs
	_rbox(Rect2(p.x - 14, p.y - 4, 28, 38), lower, 14)
	_rbox(Rect2(p.x - 14, p.y - 4, 28, 20), shirt, 12)
	draw_circle(p + Vector2(0, -18), 14, Color("f1c39f"))
	draw_circle(p + Vector2(0, -22), 16, hair)
	draw_circle(p + Vector2(0, -16), 12, Color("f1c39f"))
	_draw_eyes(p + Vector2(0, -16))
	var carried: Array = w["carried"]
	for k in range(carried.size()):
		_draw_item(int(carried[k]), Vector2(p.x + 8 + floori(k / 3.0) * 20, p.y - 2 - (k % 3) * 12), 18.0, 11.0)

# ----- UI primitives -----

func _rbox(rect: Rect2, fill: Color, radius: int = 14, border: Color = Color(0, 0, 0, 0), border_w: int = 0, shadow: bool = false) -> void:
	var key := "%s|%d|%s|%d|%d" % [fill.to_html(true), radius, border.to_html(true), border_w, 1 if shadow else 0]
	var sb: StyleBoxFlat = _sb_cache.get(key)
	if sb == null:
		sb = StyleBoxFlat.new()
		sb.bg_color = fill
		sb.set_corner_radius_all(radius)
		if border_w > 0:
			sb.border_color = border
			sb.set_border_width_all(border_w)
		if shadow:
			sb.shadow_color = Color(0, 0, 0, 0.22)
			sb.shadow_size = 8
			sb.shadow_offset = Vector2(0, 4)
		_sb_cache[key] = sb
	draw_style_box(sb, rect)

func _button(rect: Rect2, text: String, fill: Color, text_color: Color = Color.WHITE, size: int = 20) -> void:
	_rbox(Rect2(rect.position.x, rect.position.y + 4, rect.size.x, rect.size.y - 3), fill.darkened(0.28), 12)
	var top := Rect2(rect.position.x, rect.position.y, rect.size.x, rect.size.y - 3)
	_rbox(top, fill, 12)
	label_centered(text, top, size, text_color)

func _draw_dot(c: Vector2) -> void:
	var k := 1.0 + 0.15 * sin(clock * 6.0)
	draw_circle(c, 11.0 * k, Color.WHITE)
	draw_circle(c, 8.0 * k, RED)

func _draw_close_button(r: Rect2) -> void:
	var c := r.get_center()
	draw_circle(c + Vector2(0, 2), 17, Color("b94a4a"))
	draw_circle(c, 17, RED)
	draw_line(c + Vector2(-6, -6), c + Vector2(6, 6), Color.WHITE, 4.0)
	draw_line(c + Vector2(-6, 6), c + Vector2(6, -6), Color.WHITE, 4.0)

func _draw_panel(panel: Rect2, title: String, close: Rect2, show_close: bool = true) -> void:
	_rbox(panel, PANEL, 22, Color("2b6ff2"), 3, true)
	_rbox(Rect2(panel.position.x, panel.position.y, panel.size.x, 56), Color("2b6ff2"), 20)
	draw_rect(Rect2(panel.position.x, panel.position.y + 28, panel.size.x, 28), Color("2b6ff2"))
	label_centered(title, Rect2(panel.position.x, panel.position.y, panel.size.x, 56), 26, Color.WHITE)
	if show_close:
		_draw_close_button(close)

# ----- HUD -----

func _draw_upgrade_button() -> void:
	var pulse := _any_upgrade_affordable()
	if pulse:
		var pk := 1.0 + 0.035 * sin(clock * 5.0)
		_xf(UPGRADE_BTN_RECT.get_center() * (1.0 - pk), Vector2(pk, pk))
	_rbox(Rect2(UPGRADE_BTN_RECT.position.x, UPGRADE_BTN_RECT.position.y + 4, UPGRADE_BTN_RECT.size.x, UPGRADE_BTN_RECT.size.y - 3), Color("3f4bc4"), 16, Color(0, 0, 0, 0), 0, true)
	var top := Rect2(UPGRADE_BTN_RECT.position.x, UPGRADE_BTN_RECT.position.y, UPGRADE_BTN_RECT.size.x, UPGRADE_BTN_RECT.size.y - 3)
	_rbox(top, Color("5b6cff"), 16)
	var ic := Vector2(top.position.x + 30, top.get_center().y)
	draw_circle(ic, 16, Color.WHITE)
	draw_colored_polygon(PackedVector2Array([ic + Vector2(0, -9), ic + Vector2(-9, 3), ic + Vector2(-3, 3), ic + Vector2(-3, 9), ic + Vector2(3, 9), ic + Vector2(3, 3), ic + Vector2(9, 3)]), Color("5b6cff"))
	label("Upgrades", Vector2(top.position.x + 54, top.get_center().y + 8), 22, Color.WHITE)
	if _any_upgrade_affordable():
		_draw_dot(Vector2(UPGRADE_BTN_RECT.end.x - 4, UPGRADE_BTN_RECT.position.y + 4))
	if pulse:
		_xf()

func _any_upgrade_affordable() -> bool:
	for i in range(UPGRADE_COUNT):
		if _upgrade_can_buy(i):
			return true
	return false

func _draw_hud() -> void:
	# coin pill
	_rbox(Rect2(14, 14, 172, 52), DARK, 26, Color(1, 1, 1, 0.18), 2, true)
	var cc := Vector2(42, 40)
	var pk := 1.0 + 0.3 * coin_pop
	draw_circle(cc, 19.0 * pk, Color("e0a400"))
	draw_circle(cc, 16.0 * pk, GOLD)
	draw_circle(cc, 9.0 * pk, Color("ffe08a"))
	var txt := _fmt_num(coins)
	var sz := 26 + int(4.0 * coin_pop)
	if font != null and font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1.0, sz).x > 100.0:
		sz = 19 + int(3.0 * coin_pop)
	label(txt, Vector2(68, 40 + sz * 0.36), sz, Color.WHITE)
	# gem pill
	var gem_rect := Rect2(254, 14, 130, 52)
	_rbox(gem_rect, DARK, 26, Color(1, 1, 1, 0.18), 2, true)
	_draw_gem(Vector2(gem_rect.position.x + 28, gem_rect.get_center().y), 15.0)
	var gtxt := _fmt_num(gems)
	var gsz := 24
	if font != null and font.get_string_size(gtxt, HORIZONTAL_ALIGNMENT_LEFT, -1.0, gsz).x > 62.0:
		gsz = 17
	label(gtxt, Vector2(gem_rect.position.x + 52, gem_rect.get_center().y + gsz * 0.36), gsz, Color.WHITE)
	# store button (green plus)
	_rbox(Rect2(PLUS_BTN_RECT.position.x, PLUS_BTN_RECT.position.y + 4, PLUS_BTN_RECT.size.x, PLUS_BTN_RECT.size.y - 2), GREEN_DARK, 16)
	var top := Rect2(PLUS_BTN_RECT.position.x, PLUS_BTN_RECT.position.y, PLUS_BTN_RECT.size.x, PLUS_BTN_RECT.size.y - 2)
	_rbox(top, GREEN, 16, Color(1, 1, 1, 0.5), 2)
	var pc := top.get_center()
	_rbox(Rect2(pc.x - 12, pc.y - 3, 24, 6), Color.WHITE, 3)
	_rbox(Rect2(pc.x - 3, pc.y - 12, 6, 24), Color.WHITE, 3)
	if not worker2_hired and station_open and worker_open and gems >= WORKER2_GEM_COST:
		_draw_dot(Vector2(PLUS_BTN_RECT.end.x - 4, PLUS_BTN_RECT.position.y + 4))
	# settings button (gear)
	_rbox(GEAR_BTN_RECT, DARK, 16, Color(1, 1, 1, 0.18), 2, true)
	var g := GEAR_BTN_RECT.get_center()
	for i in range(8):
		var a := i * TAU / 8.0
		draw_circle(g + Vector2(cos(a), sin(a)) * 13.0, 4.0, Color.WHITE)
	draw_circle(g, 11, Color.WHITE)
	draw_circle(g, 5, DARK)

func _draw_toast_and_floaters() -> void:
	for item in floating_texts:
		var p: Vector2 = item["position"] - Vector2(0, 30.0 * (1.0 - float(item["time"])))
		var a := clampf(float(item["time"]) * 2.0, 0.0, 1.0)
		label(str(item["text"]), p + Vector2(1, 2), 22, Color(0, 0, 0, 0.3 * a))
		label(str(item["text"]), p, 22, Color(GOLD.r, GOLD.g, GOLD.b, a))
	if toast_time > 0.0:
		var age := 1.9 - toast_time
		var ta := minf(clampf(toast_time * 3.0, 0.0, 1.0), clampf(age * 8.0, 0.0, 1.0))
		var slide := (1.0 - clampf(age * 6.0, 0.0, 1.0)) * 18.0
		var tr := Rect2(60, room_bottom - 34.0 + slide, 420, 36)
		_rbox(tr, Color(0.1, 0.15, 0.2, 0.88 * ta), 18)
		label_centered(toast, tr, 17, Color(1, 1, 1, ta))
	if not station_open or not worker_open:
		var hr := Rect2(50, room_bottom - 116.0, 440, 34)
		_rbox(hr, Color(0.15, 0.22, 0.32, 0.85), 17)
		label_centered("Unbox the Case Maker and Worker to open the shop", hr, 16, Color.WHITE)

# ----- Worlds -----

func _draw_world_button() -> void:
	var r := WORLD_BTN_RECT
	_rbox(r, DARK, 16, Color(1, 1, 1, 0.18), 2, true)
	var c := r.get_center()
	draw_circle(c, 17, Color("3d86f0"))
	draw_circle(c + Vector2(-5, -4), 6, Color("52b96a"))
	draw_circle(c + Vector2(6, 7), 5, Color("52b96a"))
	draw_arc(c, 17, 0.0, TAU, 28, Color.WHITE, 2.5)
	draw_arc(c, 8, 0.0, TAU, 20, Color(1, 1, 1, 0.7), 1.5)
	draw_line(c + Vector2(-17, 0), c + Vector2(17, 0), Color(1, 1, 1, 0.7), 1.5)
	if world == 0 and not zamzung_open and _world_gate_open():
		_draw_dot(Vector2(r.end.x - 4, r.position.y + 4))

func _world_row_rect(i: int) -> Rect2:
	return Rect2(60, 282 + i * 80, 420, 72)

func _world_button_rect(i: int) -> Rect2:
	var r := _world_row_rect(i)
	return Rect2(r.position.x + r.size.x - 124, r.position.y + 15, 112, 42)

func _draw_world_icon(i: int, r: Rect2) -> void:
	_rbox(r, Color.WHITE, 12, Color("d3e3f7"), 2)
	var c := r.get_center()
	if i == 0:
		# little factory
		draw_rect(Rect2(c.x - 16, c.y - 2, 32, 18), Color("8b97a8"))
		draw_rect(Rect2(c.x - 14, c.y - 12, 8, 12), Color("6c7c8f"))
		draw_rect(Rect2(c.x - 2, c.y - 8, 8, 8), Color("6c7c8f"))
		draw_rect(Rect2(c.x + 9, c.y - 14, 6, 14), Color("6c7c8f"))
		draw_rect(Rect2(c.x - 10, c.y + 4, 6, 6), Color("6cc4ff"))
		draw_rect(Rect2(c.x + 2, c.y + 4, 6, 6), Color("6cc4ff"))
	else:
		# little smartphone
		_rbox(Rect2(c.x - 10, c.y - 17, 20, 34), Color("2a3a4a"), 5)
		draw_rect(Rect2(c.x - 7, c.y - 12, 14, 22), Color("6cc4ff"))
		draw_circle(Vector2(c.x, c.y + 13), 1.8, Color.WHITE)

func _draw_world_menu() -> void:
	_draw_panel(WORLD_PANEL, "WORLDS", WORLD_CLOSE)
	var grey_txt := Color("74879b")
	for i in range(WORLDS.size()):
		var row := _world_row_rect(i)
		var btn := _world_button_rect(i)
		_rbox(row, Color("eaf3ff"), 14, Color("d3e3f7"), 2)
		_draw_world_icon(i, Rect2(row.position.x + 10, row.position.y + 12, 48, 48))
		label(str(WORLDS[i]["name"]), Vector2(row.position.x + 68, row.position.y + 30), 20, DARK)
		var sub: String = "Phones for everyone"
		if i == 1:
			sub = "More items, bigger money" if zamzung_open else "Locked - see below"
		label(sub, Vector2(row.position.x + 68, row.position.y + 54), 13, grey_txt)
		if world == i:
			_button(btn, "Here", GREY, Color.WHITE, 20)
		elif i == 1 and not zamzung_open:
			if _world_gate_open():
				_button(btn, "Enter", GREEN, Color.WHITE, 20)
				_draw_dot(Vector2(btn.end.x - 2, btn.position.y + 2))
			else:
				_button(btn, "Locked", Color("c9d3e0"), Color("6c7c8f"), 20)
		else:
			_button(btn, "Go", GREEN, Color.WHITE, 20)
	if zamzung_open:
		label_centered("Each world keeps its own shop", Rect2(45, 470, 450, 26), 18, DARK)
		label_centered("Zamzung starts with %d coins like Zokia factory," % STARTING_COINS, Rect2(45, 504, 450, 22), 15, grey_txt)
		label_centered("but has 5 items per phone and much bigger", Rect2(45, 526, 450, 22), 15, grey_txt)
		label_centered("coins and costs. Gems and quests are shared.", Rect2(45, 548, 450, 22), 15, grey_txt)
		return
	label_centered("Tech Adventure", Rect2(45, 446, 450, 28), 24, Color("2b6ff2"))
	label_centered("Level %d everything + %s coins in Zokia factory" % [WORLD_ENTRY_LEVEL, _fmt_coins(WORLD_ENTRY_COINS)], Rect2(45, 474, 450, 22), 15, grey_txt)
	var reqs: Array = _world_requirements()
	for k in range(reqs.size()):
		var rr: Array = reqs[k]
		var ry: float = 504.0 + k * 26.0
		var have: int = int(rr[1])
		var goal: int = int(rr[2])
		var done: bool = have >= goal
		draw_circle(Vector2(82, ry + 11), 8, GREEN if done else Color("c9d3e0"))
		if done:
			draw_line(Vector2(78, ry + 11), Vector2(81, ry + 14), Color.WHITE, 2.5)
			draw_line(Vector2(81, ry + 14), Vector2(87, ry + 8), Color.WHITE, 2.5)
		label(str(rr[0]), Vector2(100, ry + 17), 16, DARK)
		var txt: String = "%s/%s" % [_fmt_coins(have), _fmt_coins(goal)]
		label_centered(txt, Rect2(340, ry, 130, 22), 16, GREEN_DARK if done else grey_txt)

# ----- Upgrades menu -----

func _draw_upgrade_menu() -> void:
	_draw_panel(UPGRADE_PANEL, "UPGRADES", UPGRADE_CLOSE)
	for i in range(UPGRADE_COUNT):
		_draw_upgrade_row(i)

func _draw_upgrade_icon(i: int, r: Rect2) -> void:
	_rbox(r, Color.WHITE, 12, Color("d3e3f7"), 2)
	var c := r.get_center()
	match i:
		0:
			draw_circle(c + Vector2(0, -8), 8, BLUE)
			_rbox(Rect2(c.x - 12, c.y + 2, 24, 14), BLUE, 6)
		1:
			_draw_item(0, Vector2(c.x - 16, c.y - 10), 32.0, 20.0)
		2:
			draw_colored_polygon(PackedVector2Array([c + Vector2(4, -18), c + Vector2(-10, 3), c + Vector2(-1, 3), c + Vector2(-5, 18), c + Vector2(11, -5), c + Vector2(2, -5)]), GOLD)
		3:
			_draw_item(1, Vector2(c.x - 16, c.y - 10), 32.0, 20.0)
		4:
			draw_circle(c, 15, Color("e0a400"))
			draw_circle(c, 12, GOLD)
			draw_circle(c, 6, Color("ffe08a"))
		_:
			_draw_item(2, Vector2(c.x - 16, c.y - 10), 32.0, 20.0)

func _draw_upgrade_row(i: int) -> void:
	var info := _upgrade_info(i)
	var row := _upgrade_row_rect(i)
	var btn := _upgrade_button_rect(i)
	_rbox(row, Color("eaf3ff"), 14, Color("d3e3f7"), 2)
	_draw_upgrade_icon(i, Rect2(row.position.x + 10, row.position.y + 12, 48, 48))
	label(str(info["title"]), Vector2(row.position.x + 68, row.position.y + 30), 20, DARK)
	label(str(info["desc"]), Vector2(row.position.x + 68, row.position.y + 54), 13, Color("74879b"))
	var cost := _fmt_coins(int(info["cost"]))
	if bool(info["bought"]):
		_button(btn, "Owned", GREY)
	elif bool(info["locked"]):
		_button(btn, "Locked", Color("c9d3e0"), Color("6c7c8f"))
	elif coins >= int(info["cost"]):
		_button(btn, "Buy %sc" % cost, GREEN)
		_draw_dot(Vector2(btn.end.x - 2, btn.position.y + 2))
	else:
		_button(btn, "%sc" % cost, Color("c9d3e0"), Color("6c7c8f"))

# ----- Station popups -----

func _draw_product_menu(product: int) -> void:
	_draw_panel(STATION_PANEL, _product_name(product).to_upper(), STATION_CLOSE)
	var px := STATION_PANEL.position.x
	var pw := STATION_PANEL.size.x
	var cx := px + pw * 0.5
	_rbox(Rect2(cx - 40, 358, 80, 52), Color("eaf3ff"), 12, Color("d3e3f7"), 2)
	_draw_item(product, Vector2(cx - 28, 366), 56.0, 36.0)
	var word := _product_word(product)
	if not _unlocked(product):
		var cost: int = _unlock_cost(product)
		label_centered("Unlock %s?" % _product_name(product), Rect2(px, 416, pw, 32), 24, DARK)
		label_centered("Every order will need a %s too" % word, Rect2(px, 452, pw, 22), 15, Color("74879b"))
		label_centered("Adds %s coins to every order" % _fmt_num(_profit(product)), Rect2(px, 476, pw, 22), 15, Color("74879b"))
		label_centered("Takes %ss to make" % _fmt_time(_craft(product)), Rect2(px, 500, pw, 22), 15, Color("74879b"))
		if coins >= cost:
			_button(STATION_BUY, "Unlock  %sc" % _fmt_coins(cost), GREEN, Color.WHITE, 22)
		else:
			_button(STATION_BUY, "Unlock  %sc" % _fmt_coins(cost), Color("c9d3e0"), Color("6c7c8f"), 22)
		return
	var lvl := _level(product)
	var profit := _profit(product)
	label_centered("Level %d / %d" % [lvl, STATION_MAX_LEVEL], Rect2(px, 414, pw, 28), 22, DARK)
	var bar := Rect2(95, 450, 350, 18)
	_rbox(bar, Color("dbe6f2"), 9)
	if lvl > 0:
		_rbox(Rect2(bar.position.x, bar.position.y, maxf(18.0, bar.size.x * float(lvl) / STATION_MAX_LEVEL), bar.size.y), GREEN, 9)
	label_centered("Earn %s coin%s per %s" % [_fmt_num(profit), "" if profit == 1 else "s", word], Rect2(px, 476, pw, 26), 20, DARK)
	if lvl >= STATION_MAX_LEVEL:
		label_centered("Max level reached!", Rect2(px, 504, pw, 22), 15, Color("74879b"))
		_button(STATION_BUY, "MAX", GREY, Color.WHITE, 22)
	else:
		var gain := _level_gain(product)
		label_centered("Next level: +%d coin%s per %s" % [gain, "" if gain == 1 else "s", word], Rect2(px, 504, pw, 22), 15, Color("74879b"))
		var up_cost := _level_cost(product)
		if coins >= up_cost:
			_button(STATION_BUY, "Upgrade  %sc" % _fmt_coins(up_cost), GREEN, Color.WHITE, 22)
		else:
			_button(STATION_BUY, "Upgrade  %sc" % _fmt_coins(up_cost), Color("c9d3e0"), Color("6c7c8f"), 22)

# ----- Gems -----

func _draw_gem(c: Vector2, r: float) -> void:
	var kite := PackedVector2Array([c + Vector2(0, -r), c + Vector2(r * 0.85, -r * 0.25), c + Vector2(0, r), c + Vector2(-r * 0.85, -r * 0.25)])
	draw_colored_polygon(kite, Color("49d6ff"))
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r), c + Vector2(r * 0.85, -r * 0.25), c + Vector2(0, -r * 0.25), c + Vector2(-r * 0.85, -r * 0.25)]), Color("a6ecff"))
	draw_polyline(PackedVector2Array([kite[0], kite[1], kite[2], kite[3], kite[0]]), Color("1c8fb8"), 2.0)

# ----- Offline rewards popup -----

func _draw_offline_menu() -> void:
	_draw_panel(OFFLINE_PANEL, "WELCOME BACK!", Rect2(), false)
	var px := OFFLINE_PANEL.position.x
	var pw := OFFLINE_PANEL.size.x
	label_centered("Your shop kept working!", Rect2(px, 312, pw, 30), 22, DARK)
	label_centered("Away for %s" % _fmt_duration(offline_secs), Rect2(px, 344, pw, 24), 16, Color("74879b"))
	_rbox(Rect2(95, 382, 350, 80), Color("eaf3ff"), 18, Color("d3e3f7"), 2)
	var k := 1.0 + 0.06 * sin(clock * 5.0)
	var cc := Vector2(140, 422)
	draw_circle(cc, 26.0 * k, Color("e0a400"))
	draw_circle(cc, 22.0 * k, GOLD)
	draw_circle(cc, 12.0 * k, Color("ffe08a"))
	var txt := "+%s" % _fmt_num(offline_pending)
	var sz := 38
	while sz > 20 and font != null and font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1.0, sz).x > 240.0:
		sz -= 2
	label_centered(txt, Rect2(176, 382, 260, 80), sz, DARK)
	var can := gems >= OFFLINE_X2_GEMS
	var b := OFFLINE_CLAIM2
	if can:
		label_centered("Spend %d gems to get %s" % [OFFLINE_X2_GEMS, _fmt_num(offline_pending * 2)], Rect2(px, 470, pw, 22), 16, Color("b07d00"))
		_button(b, "Claim x2", GREEN, Color.WHITE, 26)
	else:
		label_centered("Need %d gems for x2 - finish quests!" % OFFLINE_X2_GEMS, Rect2(px, 470, pw, 22), 16, Color("74879b"))
		_button(b, "Claim x2", Color("c9d3e0"), Color("6c7c8f"), 26)
	var gc := Vector2(b.position.x + 36, b.position.y + (b.size.y - 3) * 0.5)
	_draw_gem(gc, 13.0)
	label("%d" % OFFLINE_X2_GEMS, Vector2(gc.x + 18, gc.y + 8), 22, Color.WHITE if can else Color("6c7c8f"))
	_button(OFFLINE_CLAIM, "Claim", Color("8b97a8"), Color.WHITE, 20)
	label_centered("Offline earnings stop after %s" % _fmt_duration(OFFLINE_MAX_SECONDS), Rect2(px, 636, pw, 22), 14, Color("74879b"))

# ----- Quests -----

func _quest_row_rect(slot: int) -> Rect2:
	return Rect2(60, 312 + slot * 80, 420, 72)

func _quest_button_rect(slot: int) -> Rect2:
	var r := _quest_row_rect(slot)
	return Rect2(r.position.x + r.size.x - 124, r.position.y + 15, 112, 42)

func _draw_quests_button() -> void:
	var r := QUESTS_BTN_RECT
	var can_claim := _quests_ready_count() > 0
	if can_claim:
		var pk := 1.0 + 0.035 * sin(clock * 5.0)
		_xf(r.get_center() * (1.0 - pk), Vector2(pk, pk))
	_rbox(Rect2(r.position.x, r.position.y + 4, r.size.x, r.size.y - 3), Color("d96a1f"), 16, Color(0, 0, 0, 0), 0, true)
	var top := Rect2(r.position.x, r.position.y, r.size.x, r.size.y - 3)
	_rbox(top, Color("ff8a3d"), 16)
	var ic := Vector2(top.position.x + 30, top.get_center().y)
	draw_circle(ic, 16, Color.WHITE)
	var star := PackedVector2Array()
	for i in range(10):
		var a := -PI / 2.0 + i * PI / 5.0
		var rad := 10.0 if i % 2 == 0 else 4.5
		star.append(ic + Vector2(cos(a), sin(a)) * rad)
	draw_colored_polygon(star, Color("ff8a3d"))
	label("Quests", Vector2(top.position.x + 54, top.get_center().y + 8), 22, Color.WHITE)
	if can_claim:
		_draw_dot(Vector2(r.end.x - 4, r.position.y + 4))
		_xf()

func _draw_quest_menu() -> void:
	_draw_panel(QUEST_PANEL, "QUESTS", QUEST_CLOSE)
	for tab in range(2):
		var r: Rect2 = QUEST_TAB_RECTS[tab]
		var sel := quest_tab == tab
		_rbox(r, Color("2b6ff2") if sel else Color("dbe6f2"), 12)
		label_centered("Daily" if tab == 0 else "Milestones", r, 18, Color.WHITE if sel else DARK)
	if _daily_ready_mask() != 0:
		_draw_dot(Vector2(QUEST_TAB_RECTS[0].end.x - 6, QUEST_TAB_RECTS[0].position.y + 6))
	if _milestones_ready() > 0:
		_draw_dot(Vector2(QUEST_TAB_RECTS[1].end.x - 6, QUEST_TAB_RECTS[1].position.y + 6))
	if quest_tab == 0:
		_draw_daily_tab()
	else:
		_draw_milestone_tab()

func _draw_daily_tab() -> void:
	if daily_set.size() != 3:
		return
	for s in range(3):
		var e: Array = daily_set[s]
		_draw_quest_card(s, str(e[0]), _daily_prog(s), int(e[2]), int(e[3]), ((daily_claimed >> s) & 1) == 1)
	_draw_quest_card(3, "All 3 done: bonus!", _bits(daily_claimed), 3, DAILY_BONUS_GEMS, daily_bonus_claimed)
	label_centered("New daily quests in %s" % _fmt_duration(_daily_secs_left()), Rect2(45, 708, 450, 24), 16, DARK)
	label_centered("Spend gems in the Store (+) and on Claim x2", Rect2(45, 738, 450, 22), 14, Color("74879b"))

func _draw_milestone_tab() -> void:
	var vis := _quest_visible()
	for slot in range(vis.size()):
		_draw_quest_row(slot, int(vis[slot]))
	var left := 0
	for i in range(QUESTS.size()):
		if not _quest_claimed(i):
			left += 1
	if vis.is_empty():
		label_centered("All milestones done!", Rect2(45, 420, 450, 40), 30, DARK)
		label_centered("More are coming soon.", Rect2(45, 466, 450, 26), 16, Color("74879b"))
	else:
		label_centered("%d quest%s left" % [left, "" if left == 1 else "s"], Rect2(45, 708, 450, 24), 16, DARK)
	label_centered("Spend gems in the Store (+) and on Claim x2", Rect2(45, 738, 450, 22), 14, Color("74879b"))

func _draw_quest_row(slot: int, i: int) -> void:
	_draw_quest_card(slot, str(QUESTS[i][0]), _quest_progress(i), int(QUESTS[i][2]), int(QUESTS[i][3]), false)

func _draw_quest_card(slot: int, title: String, progress: int, goal: int, reward: int, claimed: bool) -> void:
	var row := _quest_row_rect(slot)
	var btn := _quest_button_rect(slot)
	var prog := mini(progress, goal)
	var done := prog >= goal and not claimed
	var fill := Color("f3f6fa") if claimed else (Color("e6f9ea") if done else Color("eaf3ff"))
	var edge := Color("e3eaf2") if claimed else (Color("b5e8c0") if done else Color("d3e3f7"))
	_rbox(row, fill, 14, edge, 2)
	_rbox(Rect2(row.position.x + 10, row.position.y + 12, 48, 48), Color.WHITE, 12, Color("d3e3f7"), 2)
	_draw_gem(Vector2(row.position.x + 34, row.position.y + 36), 14.0)
	label(title, Vector2(row.position.x + 68, row.position.y + 28), 17, Color("74879b") if claimed else DARK)
	var bar := Rect2(row.position.x + 68, row.position.y + 40, 120, 12)
	_rbox(bar, Color("dbe6f2"), 6)
	if prog > 0:
		_rbox(Rect2(bar.position.x, bar.position.y, maxf(12.0, bar.size.x * float(prog) / goal), bar.size.y), GREEN, 6)
	label("%s/%s" % [_fmt_coins(prog), _fmt_coins(goal)], Vector2(bar.end.x + 8, bar.position.y + 11), 13, Color("74879b"))
	if claimed:
		_button(btn, "Done", Color("c9d3e0"), Color("6c7c8f"), 18)
		return
	_button(btn, "", GREEN if done else Color("c9d3e0"))
	var cy := btn.position.y + (btn.size.y - 3) * 0.5
	_draw_gem(Vector2(btn.position.x + 30, cy), 12.0)
	label("+%d" % reward, Vector2(btn.position.x + 50, cy + 8), 22, Color.WHITE if done else Color("6c7c8f"))
	if done:
		_draw_dot(Vector2(btn.end.x - 2, btn.position.y + 2))

# ----- Store (spend gems) -----

func _store_row_rect(i: int) -> Rect2:
	return Rect2(60, 300 + i * 80, 420, 72)

func _store_button_rect(i: int) -> Rect2:
	var r := _store_row_rect(i)
	return Rect2(r.position.x + r.size.x - 124, r.position.y + 15, 112, 42)

func _draw_store_menu() -> void:
	_draw_panel(STORE_PANEL, "STORE", STORE_CLOSE)
	label_centered("Spend your gems here", Rect2(45, 268, 450, 22), 15, Color("74879b"))
	var row := _store_row_rect(0)
	var btn := _store_button_rect(0)
	_rbox(row, Color("eaf3ff"), 14, Color("d3e3f7"), 2)
	_rbox(Rect2(row.position.x + 10, row.position.y + 12, 48, 48), Color.WHITE, 12, Color("d3e3f7"), 2)
	var c := Vector2(row.position.x + 34, row.position.y + 44)
	_rbox(Rect2(c.x - 11, c.y - 4, 22, 22), Color("7a3b8f"), 10)
	_rbox(Rect2(c.x - 11, c.y - 4, 22, 12), Color("ffd166"), 8)
	draw_circle(c + Vector2(0, -10), 10, Color("8a4b2a"))
	draw_circle(c + Vector2(0, -8), 8, Color("f1c39f"))
	label("Extra Worker", Vector2(row.position.x + 68, row.position.y + 28), 18, DARK)
	label("Serves the next customer", Vector2(row.position.x + 68, row.position.y + 52), 13, Color("74879b"))
	if worker2_hired:
		_button(btn, "Hired", Color("c9d3e0"), Color("6c7c8f"), 18)
	else:
		var can := gems >= WORKER2_GEM_COST and station_open and worker_open
		_button(btn, "", GREEN if can else Color("c9d3e0"))
		var cy := btn.position.y + (btn.size.y - 3) * 0.5
		_draw_gem(Vector2(btn.position.x + 30, cy), 12.0)
		label("%d" % WORKER2_GEM_COST, Vector2(btn.position.x + 50, cy + 8), 22, Color.WHITE if can else Color("6c7c8f"))
	var r2 := _store_row_rect(1)
	_rbox(r2, Color("f3f6fa"), 14, Color("e3eaf2"), 2)
	label_centered("More items coming soon!", r2, 18, Color("74879b"))

# ----- Settings -----

func _draw_settings_menu() -> void:
	_draw_panel(SETTINGS_PANEL, "SETTINGS", SETTINGS_CLOSE)
	for i in range(SETTING_COUNT):
		var row := _setting_row(i)
		_rbox(row, Color("eaf3ff"), 14, Color("d3e3f7"), 2)
		label(SETTING_NAMES[i], Vector2(row.position.x + 18, row.position.y + 32), 20, DARK)
		var a := float(toggle_anim[i])
		var sw := Rect2(row.end.x - 78, row.position.y + 10, 60, 30)
		_rbox(sw, Color("b4c0d0").lerp(GREEN, a), 15)
		draw_circle(Vector2(sw.position.x + lerpf(15.0, 45.0, a), sw.position.y + 15), 11, Color.WHITE)
	label_centered("Total earned: %s coins" % _fmt_num(total_earned), Rect2(SETTINGS_PANEL.position.x, 586, SETTINGS_PANEL.size.x, 30), 18, DARK)
	if reset_confirm:
		_button(RESET_BTN, "Tap again to confirm", RED, Color.WHITE, 19)
	else:
		_button(RESET_BTN, "Reset progress", Color("8b97a8"), Color.WHITE, 20)
	label_centered("Tech Adventure v0.1", Rect2(SETTINGS_PANEL.position.x, 696, SETTINGS_PANEL.size.x, 24), 14, Color("9aa9ba"))

func _draw_box(rect: Rect2, text: String) -> void:
	draw_rect(rect, BOX)
	draw_rect(Rect2(rect.position.x + 4, rect.position.y + 4, rect.size.x - 8, rect.size.y - 8), BOX_DARK, false, 2.0)
	for i in range(3):
		draw_line(rect.position + Vector2(10, 10 + i * 18), rect.position + Vector2(rect.size.x - 10, 10 + i * 18), Color(1, 1, 1, 0.15), 1.0)
	var lines := text.split("\n")
	for line_i in range(lines.size()):
		label(lines[line_i], rect.position + Vector2(12, 28 + line_i * 20), 16, Color.WHITE)

func _draw_plant(pos: Vector2) -> void:
	draw_rect(Rect2(pos.x - 13, pos.y, 26, 18), Color("fffef8"))
	draw_circle(pos + Vector2(-6, -8), 10, PLANT)
	draw_circle(pos + Vector2(0, -14), 10, PLANT)
	draw_circle(pos + Vector2(8, -8), 10, PLANT)

func label(text: String, pos: Vector2, size: int = 20, color: Color = Color.WHITE) -> void:
	if font == null:
		return
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)

func label_centered(text: String, rect: Rect2, size: int = 20, color: Color = Color.WHITE) -> void:
	if font == null:
		return
	var ts := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size)
	var pos := Vector2(rect.position.x + (rect.size.x - ts.x) * 0.5, rect.position.y + (rect.size.y + ts.y * 0.6) * 0.5)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)

# ---------- Save / load ----------

func save_game() -> void:
	var cfg := ConfigFile.new()
	world_states[world] = _dump_world()
	for wi in range(WORLDS.size()):
		var ws: Dictionary = world_states[wi]
		if ws.is_empty():
			ws = _fresh_world()
		for key in ws.keys():
			cfg.set_value("w%d" % wi, str(key), ws[key])
	cfg.set_value("game", "world", world)
	cfg.set_value("game", "zamzung_open", zamzung_open)
	cfg.set_value("game", "total_earned", total_earned)
	cfg.set_value("settings", "sound_on", sound_on)
	cfg.set_value("settings", "vibrate_on", vibrate_on)
	cfg.set_value("settings", "floaters_on", floaters_on)
	cfg.set_value("settings", "compact_on", compact_on)
	cfg.set_value("settings", "notify_on", notify_on)
	cfg.set_value("game", "last_seen", last_seen)
	cfg.set_value("game", "offline_pending", offline_pending)
	cfg.set_value("game", "offline_secs", offline_secs)
	cfg.set_value("game", "gems", gems)
	cfg.set_value("game", "worker2_hired", worker2_hired)
	cfg.set_value("game", "daily_day", daily_day)
	cfg.set_value("game", "daily_set", daily_set)
	cfg.set_value("game", "daily_progress", daily_progress)
	cfg.set_value("game", "daily_claimed", daily_claimed)
	cfg.set_value("game", "daily_bonus_claimed", daily_bonus_claimed)
	cfg.set_value("game", "quest_claimed", quest_claimed)
	cfg.set_value("game", "stat_served", stat_served)
	cfg.set_value("game", "stat_doubles", stat_doubles)
	cfg.set_value("game", "stat_upgrades", stat_upgrades)
	cfg.set_value("game", "stat_claims", stat_claims)
	cfg.save(SAVE_PATH)

func load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	sound_on = bool(cfg.get_value("settings", "sound_on", true))
	vibrate_on = bool(cfg.get_value("settings", "vibrate_on", true))
	floaters_on = bool(cfg.get_value("settings", "floaters_on", true))
	compact_on = bool(cfg.get_value("settings", "compact_on", false))
	notify_on = bool(cfg.get_value("settings", "notify_on", true))
	total_earned = int(cfg.get_value("game", "total_earned", 0))
	zamzung_open = bool(cfg.get_value("game", "zamzung_open", false))
	world_states = [{}, {}]
	if cfg.has_section("w0"):
		for wi in range(WORLDS.size()):
			var sec := "w%d" % wi
			var loaded: Dictionary = {}
			if cfg.has_section(sec):
				for key in cfg.get_section_keys(sec):
					loaded[key] = cfg.get_value(sec, key)
			world_states[wi] = loaded
	else:
		# save from an older version (before worlds): it was all Zokia factory
		var g := "game"
		world_states[0] = {
			"coins": int(cfg.get_value(g, "coins", STARTING_COINS)),
			"station_open": bool(cfg.get_value(g, "station_open", false)),
			"worker_open": bool(cfg.get_value(g, "worker_open", false)),
			"more_customers_bought": bool(cfg.get_value(g, "more_customers_bought", false)),
			"energy_bought": bool(cfg.get_value(g, "energy_bought", false)),
			"money_bought": bool(cfg.get_value(g, "money_bought", false)),
			"faster_cases_bought": bool(cfg.get_value(g, "faster_cases_bought", false)),
			"faster_mb_bought": bool(cfg.get_value(g, "faster_mb_bought", false)),
			"faster_screen_bought": bool(cfg.get_value(g, "faster_screen_bought", false)),
			"levels": [int(cfg.get_value(g, "station_level", 0)), int(cfg.get_value(g, "mb_level", 0)), int(cfg.get_value(g, "screen_level", 0)), 0, 0],
			"unlocked": [false, bool(cfg.get_value(g, "mb_unlocked", false)), bool(cfg.get_value(g, "screen_unlocked", false)), false, false],
		}
	world = clampi(int(cfg.get_value("game", "world", 0)), 0, WORLDS.size() - 1)
	if world == 1 and not zamzung_open:
		world = 0
	var current: Dictionary = world_states[world]
	if current.is_empty():
		current = _fresh_world()
	_apply_world(current)
	last_seen = int(cfg.get_value("game", "last_seen", 0))
	offline_pending = maxi(0, int(cfg.get_value("game", "offline_pending", 0)))
	offline_secs = clampi(int(cfg.get_value("game", "offline_secs", 0)), 0, OFFLINE_MAX_SECONDS)
	gems = maxi(0, int(cfg.get_value("game", "gems", 0)))
	worker2_hired = bool(cfg.get_value("game", "worker2_hired", false))
	daily_day = int(cfg.get_value("game", "daily_day", 0))
	var ds = cfg.get_value("game", "daily_set", [])
	daily_set = []
	if ds is Array and ds.size() == 3:
		var ok := true
		for e in ds:
			if not (e is Array and e.size() == 4):
				ok = false
		if ok:
			daily_set = ds
	var dp = cfg.get_value("game", "daily_progress", {})
	daily_progress = dp if dp is Dictionary else {}
	daily_claimed = clampi(int(cfg.get_value("game", "daily_claimed", 0)), 0, 7)
	daily_bonus_claimed = bool(cfg.get_value("game", "daily_bonus_claimed", false))
	quest_claimed = maxi(0, int(cfg.get_value("game", "quest_claimed", 0)))
	stat_served = maxi(0, int(cfg.get_value("game", "stat_served", 0)))
	stat_doubles = maxi(0, int(cfg.get_value("game", "stat_doubles", 0)))
	stat_upgrades = maxi(0, int(cfg.get_value("game", "stat_upgrades", 0)))
	stat_claims = maxi(0, int(cfg.get_value("game", "stat_claims", 0)))
	_recalc_stats()
