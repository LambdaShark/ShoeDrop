extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export onready var mouse_sensitivity : float = 0.2
const TO_RAD = TAU / 90

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		$Camera.rotation -= Vector3(event.relative.y, event.relative.x,0) * mouse_sensitivity * TO_RAD
		$Camera.rotation.x = clamp($Camera.rotation.x, -TAU/8, TAU/8)
