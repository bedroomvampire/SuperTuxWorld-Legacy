extends KinematicBody
#gravity
var gravity = 15
#idle rotation
var xlocation = rand_range(-360,360)
var zlocation = rand_range(-360,360)
#focus at patrol point
var on_the_way = false
#find patrol node
onready var target = get_parent().get_node("PatrollPoint")
onready var target2 = get_parent().get_node("PatrollPoint2")
onready var target3 = get_parent().get_node("PatrollPoint3")
#speed of npc and random moving
var rot_speed = 0.2
var speed = 5
var minimum_speed = 3
var idle_speed = rand_range(minimum_speed, speed)
var move_or_not = [true, false]
var start_move = move_or_not[randi() % move_or_not.size()]
#list of patrol nodes to chose
onready var patrolpoint = [target, target2, target3]
onready var goingto = patrolpoint[randi() % patrolpoint.size()]

#map navigation
onready var agent : NavigationAgent = $NavigationAgent
onready var target_location = goingto

func _on_Timer_timeout():
 $Timer.set_wait_time(rand_range(1,3))
 xlocation = rand_range(-360,360) 
 zlocation = rand_range(-360,360)
 #random speed of idle move
 idle_speed = rand_range(minimum_speed, speed)
 #enemy will move or just look around
 start_move = move_or_not[randi() % move_or_not.size()]
 $Timer.start()


func _on_Timer2_timeout():
 on_the_way = true

func _process(delta):
 if on_the_way == true:
  #move action
  var global_pos = self.global_transform.origin
  var target_pos = goingto.global_transform.origin
  
  var wtransform = self.global_transform.looking_at(Vector3(target_pos.x, global_pos.y, target_pos.z), Vector3.UP)
  var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rot_speed)
  self.global_transform = Transform(Basis(wrotation), global_pos)
  #set patrol location
  agent.set_target_location(goingto.transform.origin)
  #move to patrolpoint
  var next = agent.get_next_location()
  var velocity = (next - transform.origin).normalized() * speed  * delta
  move_and_collide(velocity)
 else:
  #script for random move when target is reached
  var global_pos = self.global_transform.origin
  var wtransform = self.global_transform.looking_at(Vector3(xlocation, global_pos.y, zlocation), Vector3.UP)
  var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rot_speed)
  self.global_transform = Transform(Basis(wrotation), global_pos)
  if start_move == true:
   var velocity = global_transform.basis.z.normalized() * idle_speed * delta
   move_and_collide(-velocity)
 if not is_on_floor():
  move_and_collide(-global_transform.basis.y.normalized() * gravity * delta)

func _on_NavigationAgent_velocity_computed(safe_velocity):
 move_and_collide(safe_velocity)


func _on_NavigationAgent_target_reached():
 on_the_way = false
 start_move = false
 $Timer2.set_wait_time(rand_range(4,8))
 goingto = patrolpoint[randi() % patrolpoint.size()]
 $Timer2.start()
 #Alterntavie patroling straight to target
 ##if goingto == target:
  ##goingto = target2
  #here you can place a command to perform any action, for example,
  #start an animation after which the character will return to patrolling
 ##elif goingto == target2:
  ##goingto = target3
  #another example npc blacksmith goes to point 3 stops where there
  #is an anvil and performs forging animations, after animation going back to point 1
 ##elif goingto == target3:
  ##goingto = target
