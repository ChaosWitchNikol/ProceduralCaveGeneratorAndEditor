extends TileMap

signal updated

export(NodePath) var _generator
onready var Generator = get_node(_generator)

export(NodePath) var _tiles_row
onready var TilesRow = get_node(_tiles_row)

var cursor_position
var mouse_down = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if Generator:
		Generator.connect("generated", self, "_on_Generator_generated")


func _input(event):
	if Generator:
		if event is InputEventMouseMotion:
			var global_mouse_pos = get_viewport().get_mouse_position()
			
			var mouse_pos = global_mouse_pos - global_position
			var cell_pos = Vector2(int(mouse_pos.x) / int(cell_size.x * scale.x), int(mouse_pos.y) / int(cell_size.y * scale.y))
			
			if Generator.get_used_rect().has_point(cell_pos):
				cursor_position = cell_pos
			else:
				cursor_position = null
			update()
	
	if event.is_action_pressed("left_mouse"): mouse_down = true
	if event.is_action_released("left_mouse"): mouse_down = false
	
	if mouse_down and cursor_position and TilesRow and TilesRow.selected_item:
		set_cellv(cursor_position, TilesRow.selected_item.item_type)
		emit_signal("updated")


func _draw():
	if cursor_position and TilesRow and TilesRow.selected_item:
		var pos = cursor_position * cell_size
		draw_rect(Rect2(pos, Vector2(8, 8)), TilesRow.selected_item.item_color, true)
		draw_rect(Rect2(pos - Vector2.ONE * 2, Vector2(12, 12)), Color("#FFFFFF"), false, 2)


func _on_Generator_generated():
	clear()
	print("generator generated")
