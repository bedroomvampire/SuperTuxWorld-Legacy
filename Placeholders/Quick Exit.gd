extends Spatial
func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
