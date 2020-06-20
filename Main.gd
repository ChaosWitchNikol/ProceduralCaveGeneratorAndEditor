extends Control

const MIN_WIDTH = 424
const MIN_HEIGHT = 424




# generator
export(NodePath) var _generator_container
onready var generator_container = get_node(_generator_container)
export(NodePath) var _generator
onready var generator = get_node(_generator)


export(NodePath) var _cave_overlay
onready var CaveOverlay = get_node(_cave_overlay)

# values
export(NodePath) var _map_width
onready var MapWidth = get_node(_map_width)
export(NodePath) var _map_height
onready var MapHeight = get_node(_map_height)
export(NodePath) var _iterations
onready var Iterations = get_node(_iterations)
export(NodePath) var _neighbours
onready var Neighbours = get_node(_neighbours)
export(NodePath) var _ground_chance
onready var GroundChance = get_node(_ground_chance)
export(NodePath) var _min_cave_size
onready var MinCaveSize = get_node(_min_cave_size)


# tiles
export(NodePath) var _tiles_row
onready var TilesRow = get_node(_tiles_row)
var available_tiles = []



# preview
export(NodePath) var _preview_texture
onready var PreviewTexture = get_node(_preview_texture)

# description
export(NodePath) var _label_file
onready var LabelFile = get_node(_label_file)
export(NodePath) var _label_status
onready var LabelStatus = get_node(_label_status)


# save
export(NodePath) var _save_map_quick
onready var SaveMapQuick = get_node(_save_map_quick)

var current_image
var map_file_path setget _set_map_file_path
var map_file_status setget _set_map_file_status



#== node
func _ready():
	if TilesRow:
		available_tiles = TilesRow.get_tiles()
	
	if generator:
		if MapWidth: MapWidth.value = generator.map_w
		if MapHeight: MapHeight.value = generator.map_h
		if Iterations: Iterations.value = generator.iterations
		if Neighbours: Neighbours.value = generator.neighbors
		if GroundChance: GroundChance.value = generator.ground_chance
		if MinCaveSize: MinCaveSize.value = generator.min_cave_size
		
		generator.connect("generated", self, "_on_CaveGenerator_generated")
	
	generate_cave()
	
	
	if CaveOverlay:
		CaveOverlay.connect("updated", self, "_on_CaveOverlay_updated")
	
	get_tree().connect("screen_resized", self, "_on_resize")

		

func _input(event):
	if event.is_action_pressed("remap"):
		update_map_rect()


#== functions
func update_map_rect():
	if generator and generator_container and CaveOverlay:
		var rect = generator.get_used_rect()
		var tile_size = generator.cell_size
		
		
		var scale = generator_container.rect_size / (rect.size * tile_size)
		var min_scale = min(scale.x, scale.y)
		if min_scale > 10:
			min_scale = 10
		
		scale.x = min_scale
		scale.y = min_scale
		
		generator.scale = scale
		CaveOverlay.scale = scale
		
		var half_size = (rect.size * tile_size * generator.scale) / 2
		
		var container_center = generator_container.rect_size / 2
		generator.position = container_center - half_size
		CaveOverlay.position = generator.position


func generate_cave():
	if generator:
		self.map_file_path = null
		self.map_file_status = 'Generated'
		LabelFile.text = ''
		generator.generate()
		update_map_rect()
		



func generate_image():
	var cells = generator.get_used_cells()
	var data = []
	for cell in cells:
		var index = generator.get_cellv(cell)
		if CaveOverlay.get_cellv(cell) != TileMap.INVALID_CELL:
			index = CaveOverlay.get_cellv(cell)
		if available_tiles.size() > index:
			var item
			for tile in available_tiles:
				if tile.item_type == index:
					item = tile
			if item:
				var color = item.item_color
				data.append(color.r8)
				data.append(color.g8)
				data.append(color.b8)
	
	var raw_data = PoolByteArray(data)
	
	var w = MapWidth.value
	var h = MapHeight.value
	
	# create image from raw data
	var img = Image.new()
	img.create_from_data(w, h, false, Image.FORMAT_RGB8, raw_data)
	
	current_image = img

	# create texture from image
	var tex = ImageTexture.new()
	tex.create_from_image(img, 2)
	
	PreviewTexture.set_texture(tex)


#== setters 
func _set_map_file_path(value):
	map_file_path = value
	if value:
		SaveMapQuick.disabled = false
		LabelFile.text = value
	else:
		SaveMapQuick.disabled = true
		LabelFile.text = ''

func _set_map_file_status(value):
	map_file_status = value
	LabelStatus.text = value
	if value or value != '':
		$ResetStatus.start()



# custom signals
func _on_CaveOverlay_updated():
	call_deferred("generate_image")

func _on_CaveGenerator_generated():
	call_deferred("generate_image")

func _on_resize():
	call_deferred("update_map_rect")


func _on_MapWidth_value_changed(value):
	if generator: generator.map_w = value


func _on_MapHeight_value_changed(value):
	if generator: generator.map_h = value


func _on_Iterations_value_changed(value):
	if generator: generator.iterations = value


func _on_Neighbours_value_changed(value):
	if generator: generator.neighbors = value


func _on_GroundChance_value_changed(value):
	if generator: generator.ground_chance = value


func _on_MinCaveSize_value_changed(value):
	if generator: generator.min_cave_size = value





func _on_Generate_pressed():
	call_deferred("generate_cave")


func _on_SaveMap_pressed():
	$SaveMapDialog.popup()
	$ColorRectOverlay.visible = true
	call_deferred("toggle_overlay_active", false)


func _on_ImportMap_pressed():
	$ImportMapDialog.popup()
	$ColorRectOverlay.visible = true
	call_deferred("toggle_overlay_active", false)





#== toggle functionality
func toggle_overlay_active(active):
	for child in get_tree().get_nodes_in_group("NonActiveOnOverlay"):
		child.set_process(active)
		child.set_process_input(active)


func _on_SaveMapDialog_popup_hide():
	$ColorRectOverlay.visible = false
	call_deferred("toggle_overlay_active", true)


func _on_ImportMapDialog_popup_hide():
	$ColorRectOverlay.visible = false
	call_deferred("toggle_overlay_active", true)

# save map
func save_map_image(file_path):
	if current_image and file_path:
		self.map_file_status = 'Saving'
		var result = current_image.save_png(file_path)
		if result == 0:
			self.map_file_status = 'Saved'
			LabelFile.text = file_path
			self.map_file_path = file_path
		else:
			self.map_file_status = 'Save Error'
			LabelFile.text = ''
		

func _on_SaveMapDialog_file_selected(path):
	call_deferred("save_map_image", path)
	
	
func _on_SaveMapQuick_pressed():
	if map_file_path:
		call_deferred("save_map_image", map_file_path)


# load map
func load_map_image(file_path):
	var img = Image.new()
	var err = img.load(file_path)
	
	if err != OK:
		self.map_file_path = null
		self.map_file_status = 'Import Error'
		return
	
	
	self.map_file_path = file_path
	self.map_file_status = 'Imported'
	LabelFile.text = file_path
	
	var w = img.get_width()
	var h = img.get_height()
	
	generator.clear()
	
	var img_data = img.get_data()
	for y in range(0, h):
		for x in range(0, w):
			var index = (x + (y * w)) * 3
			
			var r8 = img_data[index]
			var g8 = img_data[index + 1]
			var b8 = img_data[index + 2]
			
			var type = _get_tile_by_color(r8, g8, b8)
			if type != null:
				generator.set_cell(x, y, type)

	
	
	# set map sizes values
	MapWidth.value = w
	MapHeight.value = h
	
	
	generate_image()
	update_map_rect()

func _get_tile_by_color(r8, g8, b8):
	var color = Color()
	color.r8 = r8
	color.g8 = g8
	color.b8 = b8
	for tile in available_tiles:
		if color == tile.item_color:
			return tile.item_type
	return null



func _on_ImportMapDialog_file_selected(path):
	call_deferred("load_map_image", path)





func _on_ResetStatus_timeout():
	self.map_file_status = ''
	pass # Replace with function body.
