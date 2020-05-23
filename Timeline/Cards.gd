extends Node

#signal MouseOver(value)

#func _ready():
	#if Input.is_action_just_released("leftclick"):
		#emit_signal("MouseOver",31)

#var Cardi = 0

#func _gui_input(event):
#	if Input.is_action_just_released("leftclick"):
#		Cardi = $'../'.holdcard()
#		print(Cardi)

#func _on_node_mouse_entered ():
#	print(8)
