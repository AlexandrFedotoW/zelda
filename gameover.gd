extends CanvasLayer


func _on_button_pressed():
	get_tree().change_scene_to_file("res://world.tscn")


func _on_button2_pressed():
	get_tree().quit()
