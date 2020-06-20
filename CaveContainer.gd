extends CenterContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	update_size()



func update_size():
	var rect = $CaveGenerator.get_used_rect()
	set_size(rect.size)
