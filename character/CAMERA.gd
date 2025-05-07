extends Camera3D

@onready var character = $"../../../player/RigidBody3D"

@export var offset_x: float = 0.0  # Horizontal offset
@export var offset_y: float = 0.0  # Vertical offset
@export var offset_z: float = 10.0 # Default zoom level

@export var follow_smoothness_x: float = 0.1 # Smoothness on X-axis
@export var follow_smoothness_y: float = 0.1 # Smoothness on Y-axis
@export var follow_smoothness_z: float = 0.1 # Smoothness on Z-axis

@export var rotation_speed: float = 0.005 # Sensitivity of rotation
@export var mouse_sensitivity: float = 1.0 # Overall mouse sensitivity multiplier
@export var zoom_speed: float = 1.0 # Speed of zooming
@export var zoom_smoothness: float = 0.1 # Smoothness of zoom transition
@export var min_zoom: float = 5.0 # Minimum zoom distance
@export var max_zoom: float = 15.0 # Maximum zoom distance

var rotation_angle = Vector3.ZERO
var target_zoom: float = offset_z  # Store target zoom level

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Lock the mouse inside the window

func _input(event):
	if event is InputEventMouseMotion:
		rotation_angle.x = clamp(rotation_angle.x - event.relative.y * rotation_speed * mouse_sensitivity, -1.5, 1.5) # Vertical rotation
		rotation_angle.y -= event.relative.x * rotation_speed * mouse_sensitivity # Horizontal rotation

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		target_zoom = max(min_zoom, target_zoom - zoom_speed) # Zoom in
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		target_zoom = min(max_zoom, target_zoom + zoom_speed) # Zoom out

func _process(delta):
	offset_z = lerp(offset_z, target_zoom, zoom_smoothness)

	var offset = Vector3(offset_x, offset_y, offset_z)
	var rotated_offset = offset.rotated(Vector3.RIGHT, rotation_angle.x)
	rotated_offset = rotated_offset.rotated(Vector3.UP, rotation_angle.y)

	var target_position = character.global_transform.origin + rotated_offset
	
	global_transform.origin.x = lerp(global_transform.origin.x, target_position.x, follow_smoothness_x)
	global_transform.origin.y = lerp(global_transform.origin.y, target_position.y, follow_smoothness_y)
	global_transform.origin.z = lerp(global_transform.origin.z, target_position.z, follow_smoothness_z)

	look_at(character.global_transform.origin, Vector3.UP)
