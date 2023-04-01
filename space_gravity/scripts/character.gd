extends CharacterBody3D


const SPEED = 20.0
const GRAVITY = 8.0
const JUMP_VELOCITY = 30

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var planet : Node3D = $"../Planet"
@onready var camera : Node3D = $"../Camera3D"

func _physics_process(delta):
	var direction_from_planet = position - planet.position
	up_direction = direction_from_planet
	
	# Add the gravity.
	if not is_on_floor():
		velocity -= gravity * delta * direction_from_planet.normalized() * GRAVITY

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity = JUMP_VELOCITY * direction_from_planet.normalized()
		
	
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction_global = camera.basis * Vector3(input_dir.x, -input_dir.y, 0)
	
	var direction_local = self.basis.inverse() * direction_global
	direction_local.y = 0
	
	var desired_forward = basis * Vector3.FORWARD
	
	var direction = basis * direction_local
	direction = direction.normalized()
	
	if direction.length() > 0.01:
		desired_forward = direction
	
	var desired_up = direction_from_planet.normalized()
	var desired_right = desired_forward.cross(desired_up)
	
	var new_orientation = Basis(desired_right, desired_up, -desired_forward)
	
	basis = new_orientation.orthonormalized()

	velocity = lerp(velocity, direction * SPEED, delta * 5)

	move_and_slide()
