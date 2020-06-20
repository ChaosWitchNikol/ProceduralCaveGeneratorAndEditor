tool
extends ColorRect
class_name TileItem

signal item_selected

export(Color) var item_color setget _set_item_color
export(CaveGenerator.Tiles) var item_type = CaveGenerator.Tiles.ROOF setget _set_item_type


var selected = false setget _set_selected
var hover = false setget _set_hover



func _set_item_color(value):
	item_color = value
	get_node("MarginContainer/VBoxContainer/CenterContainer/TextureRect").self_modulate = item_color	

func _set_item_type(type):
	item_type = type
	var item_name = CaveGenerator.Tiles.keys()[type]
	item_name = item_name.capitalize()
	get_node("MarginContainer/VBoxContainer/Label").text = item_name

func _set_hover(value):
	hover = value
	update_color()

func _set_selected(value):
	selected = value
	update_color()


func update_color():
	var alpha = 0
	if selected: alpha += 0.1
	if hover: alpha += 0.05
	color.a = alpha




func _on_Overlay_mouse_entered():
	self.hover = true


func _on_Overlay_mouse_exited():
	self.hover = false


func _on_Overlay_gui_input(event):
	if event.is_action_pressed("left_mouse"):
		call_deferred("emit_signal", "item_selected", self)

