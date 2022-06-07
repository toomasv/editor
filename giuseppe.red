Red [
	Date: 2022-06-07
]
old: 0
separator: "---"
set-pos: func [event][to-integer event/offset/y / 15 + 1]
confirm: function [msg][
	out: no
	view [
		box white 200x50 center wrap msg return 
		button "Yes" [out: yes unview] 
		button "No"  [out: no unview] 
		on-close [out: no]
	]
	out
]
check-saving: does [
	all [
		old-file
		not saved?/data
		confirm rejoin ["Save " old-file "?"]
		write old-file content/text
	]
]
renew-files: func [dir][
	collect [foreach file read dir [if find [%.r %.red] suffix? file [keep file]]]
]
get-files: func [dir][
	either exists? %dir-scripts.red [
		load/all %dir-scripts.red
	][
		renew-files dir
	]
]
open-dir: does [
	if dir: request-dir/dir get-current-dir [
		check-saving
		change-dir dir
		scripts/data: get-files dir
		new: old: scripts/selected: 1
		content/text: read pick scripts/data new
		saved?/data: yes
		show scripts
	]
]
save-dir: does [
	save %dir-scripts.red new-line/all scripts/data true
]
new-file: does [
	check-saving 
	content/text: copy "" 
	saved?/data: yes
	scripts/selected: none
	old-file: none
]
open-file: does [
	if file: request-file/title "Open file" [
		check-saving 
		content/text: read old-file: file 
		saved?/data: yes
		scripts/data: get-files %./
		scripts/selected: either found: find scripts/data last split-path file [
			index? found 
		][none]
	]
]
save-file: func [face][
	case [
		not old-file [face/actors/save-as face none]
		not saved?/data [write old-file content/text saved?/data: yes]
	]
]
save-as: does [
	if file: request-file/save/title "Save file as" [
		write old-file: file content/text
		saved?/data: yes
	]
]
;=======================================
view/flags/options [
	title "Giuseppe's notepad"
	on-down [system/view/auto-sync: off]
	on-up   [system/view/auto-sync: on]
	on-resizing [
		sep/size/y: scripts/size/y: face/size/y - 20
		content/size: face/size - content/offset - 10
	]
	on-menu [
		switch event/picked [
			open  [open-dir]
			save  [save-dir]
			renew [scripts/data: renew-files %./]
			new-file  [new-file]
			open-file [open-file]
			save-file [save-file face]
			save-as   [save-as]
		]
	]
	at 0x0 saved?: check data #[true] hidden
	scripts: text-list 150x500 with [
		data: get-files %./
		menu: ["Up" up "Down" down "Here" here "---" none "Add sep" sep "Remove" rem]] 
	on-menu [
		switch event/picked [
			up   [move current: at face/data face/selected pos: back current] 
			down [move current: at face/data face/selected pos: next current] 
			here [move current: at face/data face/selected pos: at face/data set-pos event]
			sep  [insert at face/data set-pos event copy separator]
			rem  [remove at face/data set-pos event]
			none []
		]
		face/selected: old: new: index? pos
		show face
	] 
	on-down [
		either face/selected [
			old-file: pick face/data face/selected 
		][
			if not saved?/data [
				save-as
			]
		]
		face/selected: old: new: set-pos event
	]
	on-up   [
		if separator <> picked: pick face/data new [
			check-saving
			content/text: read picked
			saved?/data: yes
		]
	]
	all-over
	on-over [
		if all [event/down? old <> new: set-pos event][
			move at face/data old at face/data new
			face/selected: old: new
			show face
		]
	]
	on-key-down [
		switch event/key [
			delete #"^H" [remove at face/data face/selected]
			#"D"   [if event/ctrl? [open-dir]]
		]
		show face
	]
	pad -10x0 
	sep: box 10x500 snow loose on-drag [
		face/offset/y: 10 
		scripts/size/x: face/offset/x - scripts/offset/x
		content/offset/x: face/offset/x + 10
		content/size/x: face/parent/size/x - content/offset/x - 10
		show face/parent
	] 
	on-down [system/view/auto-sync: off]
	on-up   [system/view/auto-sync: on]
	pad -10x0
	content: area 500x500 font [size: 10 ]
	on-wheel [
		if event/ctrl? [
			face/font/size: face/font/size + to-integer event/picked
		]
	]
	on-change [saved?/data: no]
	on-key-down [
		if event/ctrl? [
			switch event/key [
				#"S" [save-file face/parent]
			]
		]
	]
] 'resize [
	menu: [
		"Directory" ["Open" open "Save" save "Renew" renew]
		"File" ["New" new-file "Open ..." open-file "Save" save-file "Save as ..." save-as]
	]
]