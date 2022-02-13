extends Camera


var left_pressed
var right_pressed
var forward_pressed
var backward_pressed
var play_pressed
var a_pressed
var b_pressed
var c_pressed
var d_pressed

var spatialNode

# Called when the node enters the scene tree for the first time.
func _ready():
	left_pressed=0
	right_pressed=0
	forward_pressed=0
	backward_pressed=0
	play_pressed=0
	a_pressed=0
	b_pressed=0
	c_pressed=0
	d_pressed=0
	
	spatialNode=get_tree().get_root().get_node("Spatial")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(ev):
	var tree=get_tree().get_root()
	var asp=tree.get_node("Spatial/AudioStreamPlayer")
	#print (asp)
	
	if (asp.playing==true):
		return
		
	if ev is InputEventKey and ev.scancode == KEY_L and not ev.echo and left_pressed==0:
		spatialNode.turn_left()
		left_pressed=1
	elif ev is InputEventKey and ev.scancode == KEY_L and not ev.echo and left_pressed==1:
		left_pressed=0

	if ev is InputEventKey and ev.scancode == KEY_R and not ev.echo and right_pressed==0:
		spatialNode.turn_right()
		right_pressed=1
	elif ev is InputEventKey and ev.scancode == KEY_R and not ev.echo and right_pressed==1:
		right_pressed=0

	if ev is InputEventKey and ev.scancode == KEY_F and not ev.echo and forward_pressed==0:
		spatialNode.forward()
		forward_pressed=1
	elif ev is InputEventKey and ev.scancode == KEY_F and not ev.echo and forward_pressed==1:
		forward_pressed=0

	if ev is InputEventKey and ev.scancode == KEY_P and not ev.echo and play_pressed==0:
		spatialNode.play()
		play_pressed=1
	elif ev is InputEventKey and ev.scancode == KEY_P and not ev.echo and play_pressed==1:
		play_pressed=0

	if ev is InputEventKey and ev.scancode == KEY_A and not ev.echo and a_pressed==0:
		spatialNode.answer_a()
		a_pressed=1
	elif ev is InputEventKey and ev.scancode == KEY_A and not ev.echo and a_pressed==1:
		a_pressed=0

	if ev is InputEventKey and ev.scancode == KEY_B and not ev.echo and b_pressed==0:
		spatialNode.answer_b()
		b_pressed=1
	elif ev is InputEventKey and ev.scancode == KEY_B and not ev.echo and b_pressed==1:
		b_pressed=0

	if ev is InputEventKey and ev.scancode == KEY_C and not ev.echo and c_pressed==0:
		spatialNode.answer_c()
		c_pressed=1
	elif ev is InputEventKey and ev.scancode == KEY_C and not ev.echo and c_pressed==1:
		c_pressed=0

	if ev is InputEventKey and ev.scancode == KEY_D and not ev.echo and d_pressed==0:
		spatialNode.answer_d()
		d_pressed=1
	elif ev is InputEventKey and ev.scancode == KEY_D and not ev.echo and d_pressed==1:
		d_pressed=0

