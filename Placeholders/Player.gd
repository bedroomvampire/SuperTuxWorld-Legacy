# Code from GDQuest and JamJam
extends KinematicBody

var speed := 0.0
export var jump_strength := 25.0
export var gravity := 50.0
var sprint = false
var coins = 0

export var walk_speed = 12;
export var sprint_speed = 18;

var _velocity := Vector3.ZERO
var _snap_vector := Vector3.DOWN

onready var _spring_arm: SpringArm = $SpringArm
onready var _model: Spatial = $Tux

func _physics_process(delta: float) -> void:
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	
	_velocity.x = move_direction.x * speed
	_velocity.z = move_direction.z * speed
	_velocity.y -= gravity * delta
	
	var just_landed := is_on_floor() and _snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	if is_jumping:
		$JumpSound.play()
		_velocity.y = jump_strength
		_snap_vector = Vector3.ZERO
	elif just_landed:
		_snap_vector = Vector3.DOWN
	_velocity = move_and_slide_with_snap(_velocity, _snap_vector, Vector3.UP, true)
	
	if _velocity.length() > 0.5:
		var look_direction = Vector2(_velocity.z, _velocity.x)
		_model.rotation.y = look_direction.angle()

func _process(_delta: float) -> void:
	_spring_arm.translation = translation
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed;
	else:
		speed = walk_speed;

func on_Coin_coin_sound() -> void:
	$CoinSound.play()
