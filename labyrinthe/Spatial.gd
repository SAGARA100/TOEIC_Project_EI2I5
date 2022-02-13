extends Spatial

# is used to send a UDP message to the vosk application test_microphone4.py
var client
# is used to receive a UDP message from the vosk application test_microphone4.py
var server
# indicates whether to disable the vosk application test_microphone4.py 0=UnMute, 1=Mute
var muted
# the list of textures (bitmap images) representing the walls
var lTextures_mur
# the sound list
var lSons

# the VERY VERY IMPORTANT cell dictionary
var dictMaze
# indicates the current position of the player
var pos
# indicates the direction of the player 0=N, 1=E, 2=S, 3=O
var dir

# Called when the node enters the scene tree for the first time.
func _ready():
	# We start by resetting the dictionary of cells
	dictMaze={}
	# We position the player on the cell 0
	pos=0
	# direction Nord
	dir=0
	var text_Disp = "NORD \n"  + "The current cell is : "+ str(pos)
	$Control/Label.set_text(text_Disp)
	
	# the lists of textures and sounds are initially empty
	lTextures_mur=[]
	lSons=[]
	# Textures and sounds are loaded
	# Each resource has a number
	chargerTextures()
	chargerSons()

	# The sound is assigned according to the current pos position
	$AudioStreamPlayer.stream=lSons[pos]
	# and we are in UnMute mode by default
	muted=0
	#
	# We build the labyrinth with a succession of calls to createCell
	# There are 10 arguments to pass, summarized here
	#
	# 0 / position en x
	# 1 / position en z
	# 2 / liste des murs 1 indique un mur, 0 pas de mur
	# 3 / liste des textures sur nord, est, sud, ouest
	# 4 / liste des cellules possibles à partir de cette cellule dans l'ordre N,E,S,O
	#    si -1, alors direction impossible
	# 5 / la cellule de base où se trouve la porte
	#    -1 pour la cellule de base, numero de la cellule sinon
	# 6 / la liste des cellules pour lesquelles il y a des questions devant être repondues
	# 7 / le numéro du mur où il y a une porte 0=N, 1=E, 2=S, 3=O
	# 8 / la réponse donnée par le joueur 0=A, 1=B, 2=C, 3=D
	# 9 / la réponse attendue 0=A, 1=B, 2=C, 3=D
	#
	#
	# createCell(...) returns a list of 12 elements
	# 0 / le noeud
	# 1 / le noeud fils au nord
	# 2 / le noeud fils à l'est
	# 3 / le noeud file au sud
	# 4 / le noeud fils à l'ouest
	# 5 / la liste des murs [nord, est,sud, ouest] 0=pas de mur, 1=mur
	# 6 / la liste des destinations [nord, est,sud, ouest] -1=pas de destination, >=0 une destination
	# 7 / la cellule de base de notre cellule, où se trouve la porte
	# 8 / la liste des numéros de cellules associées à une cellule avec porte, [] si pas de porte
	# 9 / le mur à ouvrir contenant la porte 0=X, 1=E, 2=S, 3=O
	# 10 / la réponse donnée par le joueur dans cette cellule, -1=pas encore répondu, 0=A, 1=B, 2=C, 3=D
	# 11 / la réponse attendue 0=A, 1=B, 2=C, 3=D
	
	# This list is stored as a value in the dictionary dictMaze, the key is the cell number
	
	#                  0 1   2        3          4           5     6   7 8  9
	##                 x z   murs    textures   desinations Cbase
	var l=creerCellule(0,0,[0,1,1,1],[0,1,2,3],[1,-1,-1,-1], 22,   [], -1,-1,2)
	add_child(l[0])
	dictMaze[0]=l

	l=creerCellule(0,-2,[1,0,0,1],[4,0,0,5],[-1,2,0,-1],22,[],-1,-1,2)
	add_child(l[0])
	dictMaze[1]=l

	l=creerCellule(2,-2,[0,1,1,0],[0,6,7,0],[3,-1,-1,1],22,[],-1,-1,2)
	add_child(l[0])
	dictMaze[2]=l

	l=creerCellule(2,-4,[0,0,0,1],[0,0,0,8],[22,4,2,-1],22,[],-1,-1,1)
	add_child(l[0])
	dictMaze[3]=l

	l=creerCellule(4,-4,[1,0,1,0],[9,0,10,0],[-1,5,-1,3],21,[],-1,-1,2)
	add_child(l[0])
	dictMaze[4]=l

	l=creerCellule(6,-4,[0,1,1,0],[0,11,12,0],[21,-1,-1,4],21,[],-1,-1,1)
	add_child(l[0])
	dictMaze[5]=l

	l=creerCellule(2,-8,[0,1,0,1],[0,13,0,14],[7,-1,22,-1],0,[],-1,-1,1)
	add_child(l[0])
	dictMaze[6]=l

	l=creerCellule(2,-10,[0,0,0,1],[0,0,0,15],[20,8,6,-1],0,[],-1,-1,3)
	add_child(l[0])
	dictMaze[7]=l

	l=creerCellule(4,-10,[1,0,1,0],[16,0,17,0],[-1,9,-1,7],0,[],-1,-1,1)
	add_child(l[0])
	dictMaze[8]=l

	l=creerCellule(6,-10,[1,1,0,0],[18,19,0,0],[-1,-1,10,8],0,[],-1,-1,0)
	add_child(l[0])
	dictMaze[9]=l

	l=creerCellule(6,-8,[0,0,0,1],[0,0,0,20],[9,11,21,-1],0,[],-1,-1,1)
	add_child(l[0])
	dictMaze[10]=l

	l=creerCellule(8,-8,[1,0,1,0],[21,0,22,0],[-1,12,-1,10],0,[],-1,-1,1)
	add_child(l[0])
	dictMaze[11]=l

	l=creerCellule(10,-8,[0,1,1,0],[0,23,24,0],[13,-1,-1,11],0,[],-1,-1,3)
	add_child(l[0])
	dictMaze[12]=l

	l=creerCellule(10,-10,[0,1,0,1],[0,25,0,26],[14,-1,12,-1],0,[],-1,-1,1)
	add_child(l[0])
	dictMaze[13]=l

	l=creerCellule(10,-12,[0,1,0,1],[0,27,0,28],[15,-1,13,-1],0,[],-1,-1,1)
	add_child(l[0])
	dictMaze[14]=l

	l=creerCellule(10,-14,[1,1,0,0],[29,30,0,0],[-1,-1,14,16],0,[],-1,-1,1)
	add_child(l[0])
	dictMaze[15]=l

	l=creerCellule(8,-14,[1,0,1,0],[31,0,32,0],[-1,15,-1,17],0,[],-1,-1,2)
	add_child(l[0])
	dictMaze[16]=l

	l=creerCellule(6,-14,[1,0,1,0],[33,0,34,0],[-1,16,-1,18],0,[],-1,-1,1)
	add_child(l[0])
	dictMaze[17]=l

	l=creerCellule(4,-14,[1,0,1,0],[35,0,36,0],[-1,17,-1,19],0,[],-1,-1,3)
	add_child(l[0])
	dictMaze[18]=l

	l=creerCellule(2,-14,[1,0,0,1],[37,0,0,38],[-1,18,20,-1],0,[],-1,-1,2)
	add_child(l[0])
	dictMaze[19]=l

	l=creerCellule(2,-12,[0,1,0,1],[0,39,0,40],[19,-1,7,-1],0,[],-1,-1,2)
	add_child(l[0])
	dictMaze[20]=l
	
	l=creerCellule(6,-6,[1,1,0,1],[0,42,0,41],[10,-1,5,-1],-1,[3,4,5],0,-1,-1)
	add_child(l[0])
	dictMaze[21]=l
	
	l=creerCellule(2,-6,[1,1,0,1],[0,42,0,41],[6,-1,3,-1],-1,[0,1,2,3],0,-1,-1)
	add_child(l[0])
	dictMaze[22]=l
	
	# We create the UDP server that waits on port 4242
	server = UDPServer.new()
	server.listen(4242)
	# We create the UDP client to send messages on port 4243
	client= PacketPeerUDP.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# This function is called at each frame, so all the time
	
	# We start by looking if a sound is being played and we have mutated the
	# sound of the vosk application test_microphone4.py
	# If it is the case, we send a UDP request to unmute the vosk application
	if $AudioStreamPlayer.playing==false and muted==1:
		client.connect_to_host("127.0.0.1", 4243)
		client.put_packet("Unmute".to_utf8())
		muted=0
		return
	
	# We now see if a UDP message has arrived. If so, we decode the word
	# and execute the corresponding command by examining the first letter of the word
	# 'f' = forward
	# 'r' = right
	# 'l' = left
	# 'p' = play
	# 'a' = answer a
	# 'b' = answer b
	# 'c' = answer c
	# 'd' = answer d
	
	server.poll() # Important!
	if server.is_connection_available():
		var peer : PacketPeerUDP = server.take_connection()
		var pkt = peer.get_packet()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		var pktstr=pkt.get_string_from_utf8()
		print(len(pktstr)," ",pktstr)
		if (len(pktstr)>0):
			if (pktstr[0]=='f'):
				forward()
			if (pktstr[0]=='r'): 
				turn_right()
			elif (pktstr[0]=='l'):
				turn_left()
			elif (pktstr[0]=='p'):
				# If we need to play the sound of the cell, then we need to mute the python application.
				# We send it a Mute message
				play()
				#$AudioStreamPlayer.play()
				#client.connect_to_host("127.0.0.1", 4243)
				#client.put_packet("Mute".to_utf8())
				#muted=1
			elif (pktstr[0]=='a'):
				answer_a()
			elif (pktstr[0]=='b'):
				answer_b()
			elif (pktstr[0]=='c'):
				answer_c()
			elif (pktstr[0]=='d'):
				answer_d()
#	pass

func setLabel():
	var text_cell = "The current cell is : "+ str(pos)
	match dir:
		0:
			var text_Disp_L =  "NORD \n"  + text_cell
			$Control/Label.set_text(text_Disp_L)
			
		1:
			var text_Disp_L =  "EST \n"  + text_cell
			$Control/Label.set_text(text_Disp_L)
		2:	
			var text_Disp_L =  "SUD \n"  + text_cell
			$Control/Label.set_text(text_Disp_L)
		3:
			var text_Disp_L =  "OUEST \n"  + text_cell
			$Control/Label.set_text(text_Disp_L)
			
	## Clears the information of the second label in the other cells
	match pos:
		0,1,2, 4, 5, 8, 9, 10, 11, 13, 14, 16, 17, 18, 19, 20, 21, 22 :
			$Control/Label2.set_text("")


# To turn the camera to the left, rotate the camera by PI/2
# and adjust the variable dir 0=N, 1=E, 2=S, 3=O
func turn_left():
	$Camera.rotation.y+=PI/2.0
	dir=dir-1
	if dir==-1:
		dir=3
	setLabel()

# To turn the camera to the right, rotate the camera by -PI/2
# and adjust the dir variable 0=N, 1=E, 2=S, 3=O
func turn_right():
	$Camera.rotation.y-=PI/2.0
	dir=dir+1
	if dir==4:
		dir=0
	setLabel()

# To make the player move in his dir direction from his position, you have to
# get lWalls, the list of walls (0=no wall, 1=wall) and the list of directions lDirections
# These lists are accessible at positions 5 and 6 of the list obtained from dictMaze[pos] 
func forward():
	var lWalls=dictMaze[pos][5]
	var lDirections=dictMaze[pos][6]
	# if there is no wall in the direction you want to go, then the move is valid
	if lWalls[dir]==0:
		# movement towards 0=N, towards negative z
		if (dir==0):
			$Camera.translation.z-=2
		# movement towards 1=E, towards positive x
		elif (dir==1):
			$Camera.translation.x+=2
		# movement towards 2=S, towards positive z
		elif (dir==2):
			$Camera.translation.z+=2
		# movement towards 3=O, towards négative x 
		elif (dir==3):
			$Camera.translation.x-=2
		# and we assign pos with the new management
		pos=lDirections[dir]
		setLabel()

# To play a sound. Click on 'P' or say 'play'. We mute.
func play():
	$AudioStreamPlayer.stream=lSons[pos]
	$AudioStreamPlayer.play()
	client.connect_to_host("127.0.0.1", 4243)
	client.put_packet("Mute".to_utf8())
	muted=1
	
	# Display of questions and rests of the conversation and monologue parts in the cells
	match pos:
		
		6:
			var text_Disp =  "\n1:  What are they discussing? \n   a) party \n   b) trip to a restaurant \n   c) trip to the cinema \n   d) trip to a supermarket \n2:  Why doesn’t the man like the choice? \n   a) it is too cheap \n   b) it is too far \n   c) it doesn’t serve meat \n   d) it doesn’t serve vegetables \n3:  The woman doesn’t want to go to The Gray Fox because...\n    a) The food is unhealthy.\n    b) It's too expensive.\n    c) It only serves meat dishes.\n    d) The servings are small." 
			$Control/Label2.set_text(text_Disp)
		18:
			var text_Disp = "\n1. What are the man and woman mainly discussing?\n    A) A vacation\n    B) A budget\n    C) A company policy.\n    D) A sick son.\n2. Where were the men and women planning to go? \n    A) Airport.\n    B) Conference.\n    C) Convention.\n    D) Doctor.\n3. Why aren't the man and woman going together? \n    A) The woman needs to arrive earlier. \n    B) The man has to work overtime. \n    C) The woman’s son is sick. \n    D) The man has to go to the bank first."
			$Control/Label2.set_text(text_Disp)
		12:	
			var text_Disp =  "\n1: What are the two mens discussing? \n    A) China\n    B) Anime\n    C) Cars\n    D) A friend’s return\n2: Where did Jacob travel to? \n    A) Japan\n    B) China\n    C) France\n    D) Chile\n3: How many weeks does Jacob have left before coming back ? \n    A) 14 Days\n    B) 3 Weeks\n    C) 1 Week\n    D)  2 months." 
			$Control/Label2.set_text(text_Disp)
		15:	
			var text_Disp =  "\n1:  What’s the job of the man’s talking?\n    A) A Manager\n    B) A CEO\n    C) A Teacher\n    D) A reporter.\n2: What’s the company's name ?\n    A) Texas\n    B)  Lexus\n    C) Tesla\n    D) Renault\n3: What’s the name of the new car?\n    A) Tesla\n    B) AmpElectric\n    C) Lexus\n    D) Electrical car." 
			$Control/Label2.set_text(text_Disp)
		7:	
			var text_Disp =  "\n1:  What’s the job of the man’s talking? \n    A) A cook\n    B) A teacher\n    C) A programmer\n    D) A reporter\n2: Where does Tucker live ? \n    A) Texas\n    B)  Paris\n    C) New York\n    D) San Francisco\n3: What is the alias of the person\n    A) Blue face\n    B) Blue shirt\n    C) Red face\n    D) Troll." 
			$Control/Label2.set_text(text_Disp)
		3:	
			var text_Disp =  "\n 1:  What is the man talking about ? \n    A) Queen Elizabeth\n    B) A building’s renovation\n    C) Prince philip\n    D) Supermarket\n 2: for what purpose was the building renovated ? \n    A) To help the queen\n    B)  Because the queen is rich\n    C) To commemorate prince philip\n    D) To make another supermarket\n3:  When will  the building renovation be completed ? \n    A) Next year\n    B) End of the year\n    C) 2022\n    D) Next month." 
			$Control/Label2.set_text(text_Disp)
	
	
func answer_a():
	checkAnswer(0)
	print("Answer A")
	
func answer_b():
	checkAnswer(1)
	print("Answer B")
	
func answer_c():
	checkAnswer(2)
	print("Answer C")
	
func answer_d():
	checkAnswer(3)
	print("Answer D")

# Function to assign an answer value to a cell
# This is where we see if answering a question opens or not
# a door
func checkAnswer(r):
	# Element 7 of the list dictMaze[pos] represents the value of the base cell.
	# The cell that contains the door does not have a base cell, so it has a value of -1
	# In our example, cell 0 is the one that contains a door to the north, so its value
	# of base cell contains -1.
	# The 3 questions associated with the opening of this door are located in cells 1,2,3
	# collected in the list of cell numbers [1,2,3].
	var celluleBase=dictMaze[pos][7]
	var lCellules=dictMaze[celluleBase][8]
	#
	# Element 10 of the list dictMaze[pos] initially contains -1, to indicate that the player
	# has not yet answered the question at this location pos. So we assign this list element
	# with the answer r of the player
	dictMaze[pos][10]=r
	#
	# The door is considered to be open by default
	var okPourOuvrir=true
	# et on parcourt la liste des cellules associées à la cellule de base
	for c in lCellules:
		# either cell one of these cells of number 1,2,3 in our example
		var cell=dictMaze[c]
		# if the value entered by the player for this cell (position 10)
		# is not equal to the expected value (position11) then the door cannot open
		if cell[10]!=cell[11]:
			okPourOuvrir=false
	# If all the cells allowing to open the door have correct answers
	if (okPourOuvrir==true):
		# we get the list for the base cell
		var b=dictMaze[celluleBase]
		# we get the clue from the wall where the door is located (0=N, 1=E, 2=S, 3=O)
		var porteAouvrir=b[9]
		# If it is a door in the north, we hide the north wall, and we modify the list of walls
		# to create an opening by putting 0 in the right place in the list
		if (porteAouvrir==0):
			b[1].hide()
			b[5][0]=0
		elif (porteAouvrir==1):
			b[2].hide()
			b[5][1]=0
		elif (porteAouvrir==2):
			b[3].hide()
			b[5][2]=0
		elif (porteAouvrir==3):
			b[4].hide()
			b[5][3]=0
	
func chargerTextures():
	var it=ImageTexture.new()
	it.load("res://textures_mur/porte.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image01.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image02.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image03.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image10.jpg")
	lTextures_mur.append(it)

	it=ImageTexture.new()
	it.load("res://textures_mur/Image13.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image21.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image22.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image33.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image40.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image42.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image51.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image52.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image61.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image63.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image73.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image80.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image82.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image90.jpg")
	lTextures_mur.append(it)

	it=ImageTexture.new()
	it.load("res://textures_mur/Image91.jpg")
	lTextures_mur.append(it)

	it=ImageTexture.new()
	it.load("res://textures_mur/Image103.jpg")
	lTextures_mur.append(it)

	it=ImageTexture.new()
	it.load("res://textures_mur/Image110.jpg")
	lTextures_mur.append(it)

	it=ImageTexture.new()
	it.load("res://textures_mur/Image112.jpg")
	lTextures_mur.append(it)

	it=ImageTexture.new()
	it.load("res://textures_mur/Image121.jpg")
	lTextures_mur.append(it)

	it=ImageTexture.new()
	it.load("res://textures_mur/Image122.jpg")
	lTextures_mur.append(it)

	it=ImageTexture.new()
	it.load("res://textures_mur/Image131.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image133.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image141.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image143.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image150.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image151.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image160.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image162.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image170.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image172.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image180.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image182.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image190.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image193.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image201.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image203.jpg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image_221_211.jpeg")
	lTextures_mur.append(it)
	
	it=ImageTexture.new()
	it.load("res://textures_mur/Image_223_213.jpeg")
	lTextures_mur.append(it)
	
	print("Textures chargées")

func chargerSons():
	var s=load("res://sons/N0.wav")
	lSons.append(s)
	s=load("res://sons/N1.wav")
	lSons.append(s)
	s=load("res://sons/N2.wav")
	lSons.append(s)
	s=load("res://sons/N3.wav")
	lSons.append(s)
	s=load("res://sons/N4.wav")
	lSons.append(s)
	s=load("res://sons/N5.wav")
	lSons.append(s)
	s=load("res://sons/N6.wav")
	lSons.append(s)
	s=load("res://sons/N7.wav")
	lSons.append(s)
	s=load("res://sons/N8.wav")
	lSons.append(s)
	s=load("res://sons/N9.wav")
	lSons.append(s)
	s=load("res://sons/N10.wav")
	lSons.append(s)
	s=load("res://sons/N11.wav")
	lSons.append(s)
	s=load("res://sons/N12.wav")
	lSons.append(s)
	s=load("res://sons/N13.wav")
	lSons.append(s)
	s=load("res://sons/N14.wav")
	lSons.append(s)
	s=load("res://sons/N15.wav")
	lSons.append(s)
	s=load("res://sons/N16.wav")
	lSons.append(s)
	s=load("res://sons/N17.wav")
	lSons.append(s)
	s=load("res://sons/N18.wav")
	lSons.append(s)
	s=load("res://sons/N19.wav")
	lSons.append(s)
	s=load("res://sons/N20.wav")
	lSons.append(s)
	print("Sons chargés")
	
func creerCellule(x,z,lWalls,lTextureNumbers,lDestinations,celluleBase,lCellules,porteAOuvrir,reponse,reponseAttendue):
	var n=Spatial.new()
	n.translate(Vector3(x,0.0,z))
	
	var nNord=Spatial.new()
	nNord.translate(Vector3(0.0,0.0,-0.98))
	n.add_child(nNord)

	var nEst=Spatial.new()
	nEst.translate(Vector3(0.98,0.0,0.0))
	n.add_child(nEst)

	var nSud=Spatial.new()
	nSud.translate(Vector3(0.0,0.0,0.98))
	n.add_child(nSud)

	var nOuest=Spatial.new()
	nOuest.translate(Vector3(-0.98,0.0,0.0))
	n.add_child(nOuest)
	
	var miPoteauNO=MeshInstance.new()
	miPoteauNO.scale=Vector3(0.05,1.0,0.05)
	miPoteauNO.translation=Vector3(-0.95,0.0,-0.95)
	var meshPoteauNO=CubeMesh.new()
	miPoteauNO.mesh=meshPoteauNO
	var matPoteauNO=SpatialMaterial.new()
	miPoteauNO.set_surface_material(0,matPoteauNO)
	matPoteauNO.albedo_color=Color(0.0,0.0,0.0,1.0)
	n.add_child(miPoteauNO)

	var miPoteauNE=MeshInstance.new()
	miPoteauNE.scale=Vector3(0.05,1.0,0.05)
	miPoteauNE.translation=Vector3(0.95,0.0,-0.95)
	var meshPoteauNE=CubeMesh.new()
	miPoteauNE.mesh=meshPoteauNE
	var matPoteauNE=SpatialMaterial.new()
	miPoteauNE.set_surface_material(0,matPoteauNE)
	matPoteauNE.albedo_color=Color(0.0,0.0,0.0,1.0)
	n.add_child(miPoteauNE)

	var miPoteauSE=MeshInstance.new()
	miPoteauSE.scale=Vector3(0.05,1.0,0.05)
	miPoteauSE.translation=Vector3(0.95,0.0,0.95)
	var meshPoteauSE=CubeMesh.new()
	miPoteauSE.mesh=meshPoteauSE
	var matPoteauSE=SpatialMaterial.new()
	miPoteauSE.set_surface_material(0,matPoteauSE)
	matPoteauSE.albedo_color=Color(0.0,0.0,0.0,1.0)
	n.add_child(miPoteauSE)

	var miPoteauSO=MeshInstance.new()
	miPoteauSO.scale=Vector3(0.05,1.0,0.05)
	miPoteauSO.translation=Vector3(-0.95,0.0,0.95)
	var meshPoteauSO=CubeMesh.new()
	miPoteauSO.mesh=meshPoteauSE
	var matPoteauSO=SpatialMaterial.new()
	miPoteauSO.set_surface_material(0,matPoteauSO)
	matPoteauSO.albedo_color=Color(0.0,0.0,0.0,1.0)
	n.add_child(miPoteauSO)
	
	if (lWalls[0]==1):
		var miMurNord=MeshInstance.new()
		#miMurNord.scale=Vector3(0.05,1.0,0.05)
		miMurNord.rotation=Vector3(PI/2.0,0.0,0.0)
		var meshMurNord=PlaneMesh.new()
		miMurNord.mesh=meshMurNord
		var matMurNord=SpatialMaterial.new()
		miMurNord.set_surface_material(0,matMurNord)
		matMurNord.albedo_texture=lTextures_mur[lTextureNumbers[0]]
		nNord.add_child(miMurNord)

	if (lWalls[1]==1):
		var miMurEst=MeshInstance.new()
		#miMurNord.scale=Vector3(0.05,1.0,0.05)
		miMurEst.rotation=Vector3(PI/2.0,-PI/2.0,0.0)
		var meshMurEst=PlaneMesh.new()
		miMurEst.mesh=meshMurEst
		var matMurEst=SpatialMaterial.new()
		miMurEst.set_surface_material(0,matMurEst)
		matMurEst.albedo_texture=lTextures_mur[lTextureNumbers[1]]
		nEst.add_child(miMurEst)

	if (lWalls[2]==1):
		var miMurSud=MeshInstance.new()
		#miMurNord.scale=Vector3(0.05,1.0,0.05)
		miMurSud.rotation=Vector3(PI/2.0,-PI,0.0)
		var meshMurSud=PlaneMesh.new()
		miMurSud.mesh=meshMurSud
		var matMurSud=SpatialMaterial.new()
		miMurSud.set_surface_material(0,matMurSud)
		matMurSud.albedo_texture=lTextures_mur[lTextureNumbers[2]]
		nSud.add_child(miMurSud)

	if (lWalls[3]==1):
		var miMurOuest=MeshInstance.new()
		#miMurNord.scale=Vector3(0.05,1.0,0.05)
		miMurOuest.rotation=Vector3(PI/2.0,PI/2.0,0.0)
		var meshMurOuest=PlaneMesh.new()
		miMurOuest.mesh=meshMurOuest
		var matMurOuest=SpatialMaterial.new()
		miMurOuest.set_surface_material(0,matMurOuest)
		matMurOuest.albedo_texture=lTextures_mur[lTextureNumbers[3]]
		nOuest.add_child(miMurOuest)
	
	# On construit une liste très importante que l'on va ranger dans un dictionnaire
	# 0 / le noeud
	# 1 / le noeud fils au nord
	# 2 / le noeud fils à l'est
	# 3 / le noeud file au sud
	# 4 / le noeud fils à l'ouest
	# 5 / la liste des murs [nord, est,sud, ouest] 0=pas de mur, 1=mur
	# 6 / la liste des destinations [nord, est,sud, ouest] -1=pas de destination, >=0 une destination
	# 7 / la cellule de base de notre cellule, où se trouve la porte
	# 8 / la liste des numéros de cellules associées à une cellule avec porte, [] si pas de porte
	# 9 / le mur à ouvrir contenant la porte 0=X, 1=E, 2=S, 3=O
	# 10 / la réponse donnée par le joueur dans cette cellule, -1=pas encore répondu, 0=A, 1=B, 2=C, 3=D
	# 11 / la réponse attendue 0=A, 1=B, 2=C, 3=D
	return [n,nNord,nEst,nSud,nOuest,lWalls,lDestinations,celluleBase,lCellules,porteAOuvrir,reponse,reponseAttendue]
