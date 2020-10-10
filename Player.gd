extends KinematicBody


export onready var mouse_sensitivity : float = 0.2
export onready var throw_sensitivity : float = 0.01
const TO_RAD = TAU / 90

enum State {
	THROWING,
	MOVING
}

var state = State.THROWING
var last_movements = [0]
onready var hand = $Head/Hand
onready var ball = $Head/Hand/Ball

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ball.mode = RigidBody.MODE_KINEMATIC

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		if state == State.MOVING:
			$Head.rotation_degrees -= Vector3(event.relative.y, event.relative.x,0) * mouse_sensitivity
			$Head.rotation.x = clamp($Head.rotation.x, -TAU/8, TAU/8)
		if state == State.THROWING:
			hand.rotate_object_local(Vector3(1,0,0),-event.relative.y * throw_sensitivity)
			hand.rotation.x = clamp(hand.rotation.x, -TAU/8, TAU/10)
			last_movements.push_back(-event.relative.y)
			if len(last_movements) > 5:
				last_movements.pop_front()
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.is_pressed():
		print(last_movements)
		var amp = last_movements.max()
		var direction = ball.translation.normalized() # Relative to rotation point
		release_ball(event, amp*direction)

func mean(iterable):
	var sum = iterable[0]
	for i in iterable:
		sum += i
	return sum / len(iterable)
	return iterable.sum()

func set_parent(child:Spatial, new_parent:Node):
	if !child:
		return
	var old_pos = child.global_transform
	if child.get_parent():
		child.get_parent().remove_child(child)
	new_parent.add_child(child)
	child.global_transform = old_pos

func release_ball(event:InputEventMouseButton, speed: Vector3):
	print("Throwing!")
	print(speed)
	set_parent(ball, get_parent())
	ball.mode = RigidBody.MODE_RIGID
	ball.add_central_force(speed)
	
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("ui_accept"):
		if state == State.MOVING:
			state = State.THROWING
		else:
			state = State.MOVING
	if Input.is_action_just_pressed("up"):
		move_and_slide($Head.rotation * 5)
