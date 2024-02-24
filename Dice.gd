extends AnimatedSprite


func get_top_number() -> int:
	if frame >= 0 && frame <= 3:
		return 1
	elif frame >= 4 && frame <= 7:
		return 2
	elif frame >= 8 && frame <= 11:
		return 3
	elif frame >= 12 && frame <= 15:
		return 4
	elif frame >= 16 && frame <= 19:
		return 5
	elif frame >= 20 && frame <= 23:
		return 6
	else:
		return -1

func move_left():
	match frame:
		0:
			frame = 7
		1:
			frame = 11
		2:
			frame = 15
		3:
			frame = 19
		4:
			frame = 3
		5:
			frame = 10
		6:
			frame = 14
		7:
			frame = 23
		8:
			frame = 2
		9:
			frame = 6
		10:
			frame = 18
		11:
			frame = 22
		12:
			frame = 1
		13:
			frame = 5
		14:
			frame = 17
		15:
			frame = 21
		16:
			frame = 0
		17:
			frame = 9
		18:
			frame = 13
		19:
			frame = 20
		20:
			frame = 4
		21:
			frame = 8
		22:
			frame = 12
		23:
			frame = 16


func move_right():
	match frame:
		0:
			frame = 16
		1:
			frame = 12
		2:
			frame = 8
		3:
			frame = 4
		4:
			frame = 20
		5:
			frame = 13
		6:
			frame = 9
		7:
			frame = 0
		8:
			frame = 21
		9:
			frame = 17
		10:
			frame = 5
		11:
			frame = 1
		12:
			frame = 22
		13:
			frame = 18
		14:
			frame = 6
		15:
			frame = 2
		16:
			frame = 23
		17:
			frame = 14
		18:
			frame = 10
		19:
			frame = 3
		20:
			frame = 19
		21:
			frame = 15
		22:
			frame = 11
		23:
			frame = 7

	
func move_forward():
	match frame:
		0:
			frame = 9
		1:
			frame = 17
		2:
			frame = 6
		3:
			frame = 14
		4:
			frame = 12
		5:
			frame = 1
		6:
			frame = 22
		7:
			frame = 11
		8:
			frame = 4
		9:
			frame = 20
		10:
			frame = 3
		11:
			frame = 19
		12:
			frame = 16
		13:
			frame = 0
		14:
			frame = 23
		15:
			frame = 7
		16:
			frame = 8
		17:
			frame = 21
		18:
			frame = 2
		19:
			frame = 15
		20:
			frame = 13
		21:
			frame = 5
		22:
			frame = 18
		23:
			frame = 10
	
func move_back():
	match frame:
		0:
			frame = 13
		1:
			frame = 5
		2:
			frame = 18
		3:
			frame = 10
		4:
			frame = 8
		5:
			frame = 21
		6:
			frame = 2
		7:
			frame = 15
		8:
			frame = 16
		9:
			frame = 0
		10:
			frame = 23
		11:
			frame = 7
		12:
			frame = 4
		13:
			frame = 20
		14:
			frame = 3
		15:
			frame = 19
		16:
			frame = 12
		17:
			frame = 1
		18:
			frame = 22
		19:
			frame = 11
		20:
			frame = 9
		21:
			frame = 17
		22:
			frame = 6
		23:
			frame = 14


