extends MarginContainer

onready var CardDatabase=preload("res://Cards/CardsDatabase.gd")
var Cardname = 'Fuego'
onready var CardInfo = CardDatabase.DATA[CardDatabase.get(Cardname)]
onready var Orig_scale = rect_scale.x
var startpos = 0
var targetpos = 0
var startrot = 0
var targetrot = 0
var t = 0
var TimeOrder = 0
#var Timepos = 0

var CardBacktoHandpos = 0
var CardBacktoHandrot = 0

var DRAWTIME = .3
var ORGANIZETIME = .15
enum {
	BackToHand
	InHand
	InPlay
	InMouse
	FocusInHand
	MoveDrawnCardToHand
	ReOrganiseHand
	Timelining
	Timelining2
	Timelining3
	Timelined
	TimedRight
	TimedWrong
}
var state = InHand

# Called when the node enters the scene tree for the first time.
func _ready():
	print(CardInfo[4])
	var CardSize = rect_size
	$Card.scale*= CardSize/$Card.texture.get_size()
	$CardBack.scale*= CardSize/$CardBack.texture.get_size()
	var Type=str(CardInfo[0])
	var Event=str(CardInfo[1])
	var Description=str(CardInfo[2])
	var YearLabel=str(CardInfo[3])
	var Year=float(CardInfo[4])
	$Bars/TopBar/Type/CenterContainer/Label.text = Type
	$Bars/MidBar/Description/CenterContainer/Label.text = ""
	$Bars/BottomBar/Event/CenterContainer/Label.text = Event
	$BarsBack/TopBar/Type/CenterContainer/Label.text = Type
	$BarsBack/MidBar/YearLabel/CenterContainer/Label.text = YearLabel
	$BarsBack/BottomBar/Event/CenterContainer/Label.text = Event
	
func _physics_process(delta):
	match state:
		BackToHand:
			rect_position=CardBacktoHandpos
			rect_rotation=CardBacktoHandrot
			state = InHand
		InHand:
			pass
		InPlay:
			pass
		InMouse:
			pass
		FocusInHand:
			pass
		MoveDrawnCardToHand:
			if t <=1:
				rect_position = startpos.linear_interpolate(targetpos, t)
				rect_rotation=startrot * (1-t) + targetrot*t
				t += delta/float(DRAWTIME)
			else:
				rect_position = targetpos
				rect_rotation=targetrot
				state = InHand
				t = 0
		ReOrganiseHand:
			if t <=1:
				rect_position = startpos.linear_interpolate(targetpos, t)
				rect_rotation=startrot * (1-t) + targetrot*t
				t += delta/float(DRAWTIME)
			else:
				rect_position = targetpos
				rect_rotation=targetrot
				state = InHand
				t = 0
		Timelining:
			if t <=1:
				rect_position = startpos.linear_interpolate(targetpos, t)
				rect_rotation=startrot * (1-t) + targetrot*t
				t += delta/float(DRAWTIME)
			else:
				rect_position = targetpos
				rect_rotation=targetrot
				state = Timelining2
				t = 0
		Timelining2:
			if t <=1:
				rect_scale.x = Orig_scale * abs(2*t-1)
				if $Card.visible:
					if t>=0.5:
						$Card.visible = false
						$Bars.visible = false
						$CardBack.visible = true
						$BarsBack.visible = true
				t += delta/float(DRAWTIME)
			else:
				t = 0
				rect_scale.x = Orig_scale 
				#print("Timelined")
				state = Timelining3
		Timelining3:
			pass
		Timelined:
			rect_position=targetpos
			rect_rotation=0
		TimedWrong:
			pass
		TimedRight:
			state = Timelined

