tool
extends VBoxContainer


signal value_changed(value)

export(String) var label = "Value Item:" setget _set_label
export(int) var min_value = 10 setget _set_min_value
export(int) var max_value = 20 setget _set_max_value
export(int) var value_step = 1

var value = min_value setget _set_value

func _ready():
	if(max_value <= min_value): max_value = min_value + 1
	
	
	$HBoxContainer/LineEdit.text = str(value)
	$HBoxContainer/Label.text = label
	$HSlider.min_value = min_value
	$HSlider.max_value = max_value
	$HSlider.value = value
	$HSlider.step = value_step

#== setters 
func _set_label(new_label):
	label = new_label
	$HBoxContainer/Label.text = label

func _set_min_value(new_min_value):
	min_value = max(new_min_value, 0)
	$HBoxContainer/LineEdit.text = str(min_value)


func _set_max_value(new_max_value):
	max_value = max(min_value + 1, new_max_value)


func _set_value(val):
	value = min(max_value, max(val, min_value))
	$HSlider.value = value
	$HBoxContainer/LineEdit.text = str(value)
	emit_signal("value_changed", value)



#== signals
func _on_HSlider_value_changed(value):
	self.value = int(value)


func _on_LineEdit_text_entered(new_text):
	self.value = int(value)
