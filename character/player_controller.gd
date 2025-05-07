extends RigidBody3D

@onready var ground = $"../../map/ground"
@onready var raycast = $RayCast3D
@onready var camera = $"../../map/CAMERA/Camera3D"  # Ensure correct path to Camera3D

@export var speed = 5
@export var rotation_speed = 15.0
@export var target_height = 2.0
@export var float_force = 20.0
@export var damping = 2.5
@export var jump_force = 5.0

var is_jumping = false
var target_velocity = Vector3.ZERO  # Helps smooth movement transitions

func _integrate_forces(state):
	var input = Vector3.ZERO

	# Handle input
	if Input.is_action_pressed("move_forward"):
		input.z -= 1
	if Input.is_action_pressed("move_backward"):
		input.z += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1

	# If there is input, adjust movement relative to the camera
	if input.length() > 0:
		var camera_basis = camera.global_transform.basis
		var forward = camera_basis.z.normalized()
		var right = camera_basis.x.normalized()

		# Convert input into world-space movement direction
		var move_direction = (forward * input.z + right * input.x).normalized() * speed
		target_velocity.x = move_direction.x
		target_velocity.z = move_direction.z

		# Smooth rotation towards movement direction
		var target_yaw = atan2(-move_direction.x, -move_direction.z)
		var current_yaw = self.rotation.y
		self.rotation.y = lerp_angle(current_yaw, target_yaw, rotation_speed * state.step)
	else:
		# Decelerate when no input is provided
		target_velocity.x = move_toward(target_velocity.x, 0, speed * 0.1)
		target_velocity.z = move_toward(target_velocity.z, 0, speed * 0.1)

	# Apply movement
	state.linear_velocity.x = target_velocity.x
	state.linear_velocity.z = target_velocity.z

	# Floating and Jump Logic
	var velocity = state.linear_velocity
	if raycast.is_colliding() and not is_jumping:
		var collision_point = raycast.get_collision_point()
		var current_height = self.global_transform.origin.y - collision_point.y
		var height_difference = target_height - current_height

		velocity.y += height_difference * float_force * state.step
		velocity.y -= velocity.y * damping * state.step

	# Jumping mechanics
	if Input.is_action_just_pressed("jump") and raycast.is_colliding() and not is_jumping:
		velocity.y = jump_force
		is_jumping = true

	# Reset jump status when landing
	if raycast.is_colliding() and velocity.y <= 0:
		is_jumping = false

	state.linear_velocity = velocity

	# Prevent unwanted tipping
	state.angular_velocity.x = 0
	state.angular_velocity.z = 0
