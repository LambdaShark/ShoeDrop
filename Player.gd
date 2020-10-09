extends KinematicBody


export onready var mouse_sensitivity : float = 0.2
export onready var throw_sensitivity : float = 0.01
const TO_RAD = TAU / 90

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

enum State {
	THROWING,
	MOVING
}

var state = State.THROWING

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		if state == State.MOVING:
			$Camera.rotation_degrees -= Vector3(event.relative.y, event.relative.x,0) * mouse_sensitivity
			$Camera.rotation.x = clamp($Camera.rotation.x, -TAU/8, TAU/8)
		if state == State.THROWING:
			$BallRotationPoint.rotate_object_local(Vector3(1,0,0),-event.relative.y * throw_sensitivity)
			# $BallRotationPoint.rotate_object_local(Vector3(0,1,0),-event.relative.x * throw_sensitivity)

