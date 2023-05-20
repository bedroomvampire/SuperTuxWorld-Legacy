# Original code from rayuse rp, berryberryniceu and AiTechEye

extends KinematicBody

var max_speed = 0
var movement = 0
export var walk_speed = 14
export var run_speed = 20;
export var acceleration = 70
export var friction = 60
export var air_friction = 10
export var gravity = -48
export var jump_impulse = 24
export var mouse_sensitivity = .2
export var controller_sensitivity = 3
export var rot_speed = 8
export (int, 0, 10) var push = 1

export (NodePath) var joystickRightPath

var velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO
var picked_object
var pull_power = 8
var locked = false
export var walk_pull_power = 9
export var run_pull_power = 13
export var rotation_power = 0.5
export var throw_power = 12

onready var spring_arm = $SpringArm
onready var pivot = $Pivot
onready var camera = $SpringArm/Camera
onready var interaction = $Interaction
onready var hand = $Pivot/Position3D
onready var joint = $Pivot/Joint
onready var staticbody = $Pivot/StaticBody

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and !locked:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		spring_arm.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))		
	
	#if Input.is_action_pressed("rotate"):
	#	locked = true
	#	rotate_object(event)
	#if Input.is_action_just_released("rotate"):
	#	locked = false

func _physics_process(delta):
	var input_vector = get_input_vector()
	var direction = get_direction(input_vector)
	apply_movement(input_vector, direction, delta)
	apply_friction(direction, delta)
	apply_gravity(delta)
	update_snap_vector()
	jump()
	apply_controller_rotation()
#	rotate_player()

	spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg2rad(-75), deg2rad(75))

	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true, 4, 0.785398, false)
	for idx in get_slide_count():
		var collision = get_slide_collision(idx)
		if collision.collider.is_in_group("bodies"):
			collision.collider.apply_central_impulse(-collision.normal * velocity.length() * push)
	
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a)*pull_power)
		
	$AnimationTree.set("parameters/conditions/idle", input_vector == Vector3.ZERO && is_on_floor())
	$AnimationTree.set("parameters/conditions/walk", input_vector != Vector3.ZERO && is_on_floor() && movement == 0)
	$AnimationTree.set("parameters/conditions/run", input_vector != Vector3.ZERO && is_on_floor() && movement == 1)
	$AnimationTree.set("parameters/conditions/jump", !is_on_floor())
	
#func rotate_player():
#	rotate_y(deg2rad(joystickRight.get_output().x * mouse_sensitivity))
#	spring_arm.rotate_x(deg2rad(joystickRight.get_output().y * mouse_sensitivity))	
	
func get_input_vector():
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	return input_vector.normalized() if input_vector.length() > 1 else input_vector
	
func rotate_object(event):
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if picked_object != null:
		if event is InputEventMouseMotion:
			staticbody.rotate_x(deg2rad(event.relative.y * rotation_power))
			staticbody.rotate_y(deg2rad(event.relative.x * rotation_power))
		if InputEventJoypadMotion:
			staticbody.rotate_x(deg2rad(axis_vector.y) * controller_sensitivity)
			staticbody.rotate_y(deg2rad(axis_vector.x) * controller_sensitivity)
	
func get_direction(input_vector):
	var direction = (input_vector.x * transform.basis.x) + (input_vector.z * transform.basis.z)
	return direction
	
func apply_movement(input_vector, direction, delta):
	if direction != Vector3.ZERO:
		velocity.x = velocity.move_toward(direction * max_speed, acceleration * delta).x
		velocity.z = velocity.move_toward(direction * max_speed, acceleration * delta).z
		#pivot.look_at(global_transform.origin + direction, Vector3.UP)
		pivot.rotation.y = lerp_angle(pivot.rotation.y, atan2(-input_vector.x, -input_vector.z), rot_speed * delta)
		
func apply_friction(direction, delta):
	if direction == Vector3.ZERO:
		if is_on_floor():
			velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		else:
			velocity.x = velocity.move_toward(Vector3.ZERO, air_friction * delta).x
			velocity.z = velocity.move_toward(Vector3.ZERO, air_friction * delta).z
		
func apply_gravity(delta):
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, gravity, jump_impulse)
	
	
func update_snap_vector():
	snap_vector = -get_floor_normal() if is_on_floor() else Vector3.DOWN
	
	
func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap_vector = Vector3.ZERO
		velocity.y = jump_impulse
		$JumpSound.play()
	if Input.is_action_just_released("jump") and velocity.y > jump_impulse / 2:
		velocity.y = jump_impulse / 2
		
		
func apply_controller_rotation():
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if InputEventJoypadMotion and !locked:
		rotate_y(deg2rad(-axis_vector.x) * controller_sensitivity)
		spring_arm.rotate_x(deg2rad(-axis_vector.y) * controller_sensitivity)
		
func _on_fov_updated(value):
	camera.fov = value
	
func _on_mouse_sens_updated(value):
	mouse_sensitivity = value
	
func _process(_delta: float) -> void:
	if Input.is_action_pressed("sprint"):
		max_speed = run_speed;
		pull_power = run_pull_power;
		movement = 1;
	else:
		max_speed = walk_speed;
		pull_power = walk_pull_power;
		movement = 0;
		
	if Input.is_action_just_pressed("hold"):
		for body in interaction.get_overlapping_bodies():
			if body is RigidBody and picked_object == null:
				picked_object = body
				joint.set_node_b(picked_object.get_path())
				return
			elif picked_object != null:
				picked_object = null
				joint.set_node_b(joint.get_path())
				return
		
	if Input.is_action_just_pressed("throw"):
		if picked_object != null:
			var knockback = picked_object.translation - translation
			picked_object.apply_central_impulse(knockback * throw_power)
			picked_object = null
			joint.set_node_b(joint.get_path())
			return
		

func _on_Coin_coin_sound():
	$CoinSound.play()
