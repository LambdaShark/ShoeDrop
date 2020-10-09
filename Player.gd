extends KinematicBody


export onready var mouse_sensitivity : float = 0.2
export onready var throw_sensitivity : float = 0.01
const TO_RAD = TAU / 90

onready var ball = $Hand/Ball

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ball.mode = RigidBody.MODE_KINEMATIC

enum State {
	THROWING,
	MOVING
}

var state = State.THROWING
var last_movements = [0]

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		if state == State.MOVING:
			$Head.rotation_degrees -= Vector3(event.relative.y, event.relative.x,0) * mouse_sensitivity
			$Head.rotation.x = clamp($Head.rotation.x, -TAU/8, TAU/8)
		if state == State.THROWING:
			$Hand.rotate_object_local(Vector3(1,0,0),-event.relative.y * throw_sensitivity)
			$Hand.rotation.x = clamp($Hand.rotation.x, -TAU/8, TAU/16)
			last_movements.push_back(-event.relative.y)
			if len(last_movements) > 5:
				last_movements.pop_front()
			# $BallRotationPoint.rotate_object_local(Vector3(0,1,0),-event.relative.x * throw_sensitivity)
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		print(last_movements)
		var amp = mean(last_movements)
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
