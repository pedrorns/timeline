extends TextureButton

var Decksize = INF

func _ready():
	rect_scale *= $'../../'.CardSize/rect_size 

func _gui_input(event):
	if Input.is_action_just_released("leftclick"):
		if Decksize > 0:
			Decksize = $'../../'.drawcard()
			if Decksize == 0:
				disabled = true
