extends Node3D

func _process(delta):
	# Check if the Escape key is pressed
	if Input.is_action_just_pressed("esc"):  # "ui_cancel" is mapped to the ESC key by default
		get_tree().quit()  # Quit the game
