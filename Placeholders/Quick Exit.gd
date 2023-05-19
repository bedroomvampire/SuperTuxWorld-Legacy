extends Spatial
func _input(_event):
	if Input.is_action_pressed("ui_end"):
		get_tree().quit()
