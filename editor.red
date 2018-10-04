Red [
	Author: "Toomas Vooglaid"
	Date: 2018-10-04
	Purpose: "Demo of simple Red-editor"
	Help: {Write or open Red file (or fragment of it). Select some relatively whole part of it 
		and then select method of presentation from contextual menu.}
]
context [
	win-size: 800x600
	selected-text: func [face [object!] /local start end][
		either face/selected [
			start: face/selected/1 
			end: face/selected/2
			parse face/text [
				some [
					s: if (end < index? s) break 
				| 	newline (if start > index? s [start: start - 1] end: end - 1)
				| 	skip
				]
			] ;probe s
			copy/part at face/text start end - start + 1
		][face/text]
	]
	select-text: func [face [object!] selection /local start end][
		start: selection/1 
		end: selection/2
		parse face/text [
			some [
				s: if (selection/2 < index? s) break 
			| 	newline (if selection/1 > index? s [start: start + 1] end: end + 1)
			| 	skip
			]
		]
		face/selected: as-pair start end
	]
	matching-bracket: [
		[s: 
			#"]" [if (i = 0) break | (i: i - 1) fail]
		|	#"[" (i: i + 1) fail
		;|	skip
		]
	]
	view/flags/options/tight [
		size win-size 
		at 0x0 drawing: box white win-size hidden draw [] with [menu: ["Text" text]]
		on-menu [switch event/picked [text [edited/visible?: yes]]]
		at 0x0 widget: panel win-size hidden with [menu: ["Text" text]]
		on-menu [switch event/picked [text [edited/visible?: yes]]]
		edited: area win-size font-size 9 focus with [
			menu: [
				"Select" [
					"Block" block
					"Face" face
				]
				"Draw" draw
				"Shape" shape
				"VID" vid
				"View" view
				"Red" red
			]
		]
		on-menu [
			switch event/picked [
				block [
					select-text face to-pair parse at face/text offset-to-caret face event/offset [
						s: (s: back s i: 0)
						collect any [s:
							[
								#"[" [
									if (i = 0) keep (1 + index? s) to matching-bracket keep (-1 + index? s) break 
								| 	(i: i - 1) fail
								]
							|	#"]" (i: i + 1) fail
							]
						|	(s: back s) :s
						]
					]
				]
				face [
				
				]
				draw [
					drawing/draw: load selected-text face
					face/visible?: widget/visible?: no
					drawing/visible?: yes 
				]
				shape [
					drawing/draw: append/only [shape] load selected-text face
					face/visible?: widget/visible?: no
					drawing/visible?: yes 
				]
				vid [
					widget/pane: layout/only load/all selected-text face
					face/visible?: no
					widget/visible?: yes 					
				]
				view [
					view load selected-text face
				]
				red [
					do selected-text face
				]
			]
		]
	][resize][	
		menu: [
			"File" [
				"New" new
				"Open" open 
				"Save" save
				"Save as" save-as
				;"Close" close
			]
		]
		actors: object [
			on-resizing: func [win event][
				foreach-face win [
					face/size: win/size
				]
			]
			on-menu: func [face event][
				switch event/picked [
					new [
						clear edited/text 
						face/extra: none
						face/text: "New file"
					]
					open [
						edited/text: read face/extra: request-file
						face/text: to-string second split-path face/extra
					] 
					save [write any [face/extra request-file/save] edited/text]
					save-as [write request-file/save edited/text]
					;close []
				]
			]
		]
	]
]