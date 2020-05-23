extends Node2D


const CardSize = Vector2(150,210)
const CardBase = preload("res://Cards/CardBase.tscn")
const Deck = preload("res://Cards/InitialDeck.gd")
onready var DeckSize = Deck.CardList.size()
var CardSelected = []

onready var CentreCardOval = get_viewport().size * Vector2(0.5, 1.2)
var CardOffset=Vector2()
onready var Hor_rad = get_viewport().size.x*0.62
onready var Ver_rad = get_viewport().size.y*0.4
var angle = deg2rad(90)-0.5
var Card_Numb = 0
var NumberCardsHand = 0
var CardSpread = 0.25
var OvalAngleVector = Vector2()
var MaxHandSize = 4
var NewCardAddedTimeline = 0
var RightlyTimed = 1

var GameState=0 #(0) Set up, (1) playing, (2) game over.


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

var Points =0
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() 
	$Points.text = str(Points)

func drawcard():
	if MaxHandSize>NumberCardsHand:
		angle = PI/2 + CardSpread*(float(NumberCardsHand)/2-NumberCardsHand)
		var new_card = CardBase.instance()
		CardSelected = randi() % DeckSize
		new_card.Cardname = Deck.CardList[CardSelected]
		#new_card.rect_position = get_global_mouse_position()
		new_card.state=MoveDrawnCardToHand
		OvalAngleVector = Vector2(Hor_rad*cos(angle), - Ver_rad*sin(angle))
		new_card.startrot = 0
		new_card.targetrot = (90 - rad2deg(angle))/4
		new_card.startpos = $Deck.position - CardSize/3.2
		new_card.targetpos = CentreCardOval+OvalAngleVector- new_card.rect_size/2
		new_card.rect_scale *= CardSize/new_card.rect_size
		Card_Numb = 0
		for Card in $Cards.get_children():
			if Card.state == InHand or Card.state == MoveDrawnCardToHand:
				angle = PI/2 + CardSpread*(float(NumberCardsHand)/2-Card_Numb)
				OvalAngleVector = Vector2(Hor_rad*cos(angle), - Ver_rad*sin(angle))
				Card.startrot = Card.rect_rotation
				Card.targetrot = (90 - rad2deg(angle))/4
				Card.targetpos = CentreCardOval+OvalAngleVector- Card.rect_size/2
				Card_Numb +=1
				if Card.state == InHand:
					Card.state = ReOrganiseHand
					Card.startpos = Card.rect_position
				elif Card.state == MoveDrawnCardToHand:
					Card.startpos = Card.targetpos - ((Card.targetpos-Card.rect_position)/(1-Card.t))
		$Cards.add_child(new_card)
		Deck.CardList.erase(Deck.CardList[CardSelected])
		angle += 0.25
		DeckSize -= 1
		NumberCardsHand += 1
	elif MaxHandSize<=NumberCardsHand and GameState==0:
		var new_card = CardBase.instance()
		CardSelected = randi() % DeckSize
		new_card.Cardname = Deck.CardList[CardSelected]
		#new_card.rect_position = get_global_mouse_position()
		new_card.startrot = 0
		new_card.targetrot = 0
		new_card.startpos = $Deck.position - CardSize/3.2
		new_card.targetpos = get_viewport().size * Vector2(0.4, 0.05)
		new_card.rect_scale *= CardSize/new_card.rect_size
		new_card.state = Timelining
		$Cards.add_child(new_card)
		Deck.CardList.erase(Deck.CardList[CardSelected])
		DeckSize -= 1
		if new_card.state==7 and NumberCardsHand>0:
			GameState = 1
	else:
		pass
	return DeckSize

#func holdcard():
#	print(2)
#	return 1
	
func _input(event):
	if GameState==1 and Input.is_action_just_released("leftclick"):
		for Card in $Cards.get_children():
			if Card.state==InHand and (Card.rect_position.x-(get_global_mouse_position().x-120))<70 and (-Card.rect_position.x+(get_global_mouse_position().x-120))<70 and (Card.rect_position.y-(get_global_mouse_position().y-180))<100 and (-Card.rect_position.y+(get_global_mouse_position().y-180))<100 :
				#Card.rect_position = get_global_mouse_position()
				Card.CardBacktoHandpos=Card.rect_position
				Card.CardBacktoHandrot=Card.rect_rotation
				Card.rect_rotation = 0
				Card.state = InMouse
			elif Card.state==InMouse and Card.rect_position.y>100:
				if Input.is_action_just_released("leftclick"):
					Card.state =BackToHand
			elif Card.state==InMouse and Card.rect_position.y<=100:
				if Input.is_action_just_released("leftclick"):
					NumberCardsHand -= 1
					for Cardi in $Cards.get_children():
						if Cardi.state == Timelined:
							if Cardi.rect_position.x<Card.rect_position.x and Cardi.CardInfo[4]>=Card.CardInfo[4]:
								RightlyTimed = 0
							elif Cardi.rect_position.x>Card.rect_position.x and Cardi.CardInfo[4]<=Card.CardInfo[4]:
								RightlyTimed = 0
					#print(RightlyTimed)
					if RightlyTimed==0:
						Card.targetrot=0
						Card.startpos=Card.rect_position
						Card.targetpos=Card.rect_position
						Points -= 1
						Card.state = Timelining
						$Nice.visible = false
						$Oops.visible = true
						print(Points)
					if RightlyTimed == 1:
						MaxHandSize -=1
						Card.targetrot = 0
						Card.startpos=Card.rect_position
						Card.targetpos=Card.rect_position
						Card.state = Timelining
						Points += 1
						$Oops.visible = false
						$Nice.visible = true
					RightlyTimed =1
					drawcard()
	for Card in $Cards.get_children():
		if Card.state==Timelining3:
			NewCardAddedTimeline = 1
			Card.state=Timelined
	if NewCardAddedTimeline == 1:
		for Card in $Cards.get_children():
			if Card.state==Timelined:
				Card.TimeOrder=0
				for Cardi in $Cards.get_children():
					#print(2)
					if Cardi.CardInfo[4]>Card.CardInfo[4] and Cardi.state==Timelined:
						#print(Cardi.CardInfo[4])
						Card.TimeOrder -= 1
					if Cardi.CardInfo[4]<Card.CardInfo[4] and Cardi.state==Timelined:
						Card.TimeOrder +=1
				#print(Card.CardInfo[4])
				#print(Card.TimeOrder)
			NewCardAddedTimeline = 2
	if NewCardAddedTimeline == 2:
		for Card in $Cards.get_children():
			Card.startpos = Card.rect_position
			Card.targetpos.x=500+(Card.TimeOrder-1)*70
			Card.targetpos.y=30
			#if Card.state==Timelined:
				#Card.state = Timelined
		NewCardAddedTimeline=0



func _process(delta):
	for Card in $Cards.get_children():
		if Card.state == InMouse:
			Card.set_position(get_viewport().get_mouse_position()-Vector2(120,180))

#func _on_Cards_MouseOver(value):
#	print(32)
#	pass # Replace with function body.
