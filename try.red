Red []
view [
	text "Draw:" 30x25
	field 200x25 [
		append box1/draw face/data
		clear face/text
	]
	button "Clear" [
		clear box1/draw
	]
	return
	box1: box 300x300 white draw [
		fill-pen brick 
		circle 150x150 100
		fill-pen gold
		shape [move 30x30 'hline 100 'vline 50 'hline -120 'vline -30 'hline 20]
		fill-pen leaf
		arc 200x200 100x100 -90 -60 ;closed
	]
]
