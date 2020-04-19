extends TextureButton

func _on_pressed():
	var options = get_node("../../Options")
	
	options.show()
	options.get_node("SFXVolume/SFXVolumeSlider").grab_focus()


func _on_BackButton_pressed():
	var options = get_node("../../Options")
	
	options.hide()
	grab_focus()
