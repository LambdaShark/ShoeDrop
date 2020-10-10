extends KinematicBody


export onready var mouse_sensitivity : float = 0.2
export onready var throw_sensitivity : float = 0.008
const TO_RAD = TAU / 90

enum State {
	THROWING,
	LOOKING
}
var has_shoe =  true
var state = State.LOOKING
var last_movements = [0]
onready var hand = $Knee
onready var ball = $Knee/Ball

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ball.mode = RigidBody.MODE_KINEMATIC



func move_camera(event:InputEventMouseMotion, max_down:float, max_up:float):
	rotation_degrees -= Vector3(event.relative.y, event.relative.x,0) * mouse_sensitivity
	rotation.x = clamp(rotation.x, max_down, max_up)

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		if state == State.LOOKING:
			move_camera(event, -TAU/4, TAU/4)
		if state == State.THROWING:
			hand.rotate_object_local(Vector3(1,0,0),-event.relative.y * throw_sensitivity)
			hand.rotation.x = clamp(hand.rotation.x, -TAU/2, TAU/4)
			last_movements.push_back(-event.relative.y)
			if len(last_movements) > 5:
				last_movements.pop_front()
	if has_shoe and event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			state = State.THROWING
		else:
			print(last_movements)
			var amp = mean(last_movements) * 0.01
			var direction = -Vector3(0,sin(hand.rotation.x),cos(hand.rotation.x)) + Vector3(0,TAU/4,TAU/4)
			print(direction)
			DebugDraw.draw_ray_3d(translation, direction, amp, Color(1,0,0,1))
			release_ball(event, amp*direction)
			state = State.LOOKING
			has_shoe = false

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
	set_parent(ball, get_parent())
	ball.mode = RigidBody.MODE_RIGID
	ball.apply_central_impulse(speed)
	
func _physics_process(delta):
	DebugDraw.set_text("test","test")
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#print($Head.rotation)
	var z_movement : float = Input.get_action_strength("backwards") - Input.get_action_strength("forwards")
	var z_direction : Vector3 = Vector3(0, 0, 1).rotated(Vector3(0, 1, 0), rotation.y)
	var z_motion : Vector3 = z_direction * z_movement * delta * move_speed
	var x_movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	var x_direction : Vector3 = Vector3(1, 0, 0).rotated(Vector3(0, 1, 0), rotation.y)
	var x_motion : Vector3 = x_direction * x_movement * delta * move_speed
	move_and_slide(z_motion + x_motion)

export var move_speed : float = 400.0
export var rotate_speed : float = 3.0
