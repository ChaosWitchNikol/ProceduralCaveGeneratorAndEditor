extends HBoxContainer

var selected_item
var items = []

func _ready():
	for child in get_children():
		if child is TileItem:
			print(child)
			child.connect("item_selected", self, "on_item_selected")
			items.append(child)


func on_item_selected(selected_item):
	if self.selected_item == selected_item:
		self.selected_item.selected = false
		self.selected_item = null
		return
		
	for item in items:
		item.selected = false
		if item == selected_item:
			item.selected = true
			self.selected_item = selected_item



func get_tiles():
	var tiles = []
	
	for child in get_children():
		if child is TileItem:
			tiles.append(child)
	
	return tiles
