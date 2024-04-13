class_name Player extends CharacterBody2D


const MAX_SPEED = 300.0 #not used atm
const ACCELERATION = 10.0
const TURN_SPEED = 0.1
const BASE_BULLET_SPEED = 600.0
const BASE_DAMAGE = 50.0
var particleRng
var viewX = 1
var viewY = 0
var shotReleased = true
var exhaust

@export var health = 100
@export var WEIGHT = 1.0
@export var ELASTICITY = 0.5
@export var DAMAGE_DEALT_BASE = 1
@export var DAMAGE_DEALT_MULTIPLIER = 2
@export var DAMAGE_TAKEN_BASE = 1
@export var DAMAGE_TAKEN_MULTIPLIER = 0.25
@export var KEY_TURN_LEFT = Key.KEY_A
@export var KEY_TURN_RIGHT = Key.KEY_D
@export var KEY_ACCELERATE = Key.KEY_W
@export var KEY_SHOOT = Key.KEY_SPACE
@export var playerName: String

signal health_depleted

func _ready():
	particleRng = RandomNumberGenerator.new()
	viewX = cos(get_node("CenterCollision").get_rotation())
	viewY = sin(get_node("CenterCollision").get_rotation())

func _enter_tree():
	exhaust = get_node("CenterPolygon").get_node("ExhaustEmitter")
	var screenRect = get_viewport_rect().size
	get_node("LeftCollision").position.x = -screenRect.x
	get_node("LeftPolygon").position.x = -screenRect.x
	get_node("UpperLeftCollision").position.x = -screenRect.x
	get_node("UpperLeftCollision").position.y = -screenRect.y
	get_node("UpperLeftPolygon").position.x = -screenRect.x
	get_node("UpperLeftPolygon").position.y = -screenRect.y
	get_node("UpperCollision").position.y = -screenRect.y
	get_node("UpperPolygon").position.y = -screenRect.y
	get_node("UpperRightCollision").position.x = screenRect.x
	get_node("UpperRightCollision").position.y = -screenRect.y
	get_node("UpperRightPolygon").position.x = screenRect.x
	get_node("UpperRightPolygon").position.y = -screenRect.y
	get_node("RightCollision").position.x = screenRect.x
	get_node("RightPolygon").position.x = screenRect.x
	get_node("LowerRightCollision").position.x = screenRect.x
	get_node("LowerRightCollision").position.y = screenRect.y
	get_node("LowerRightPolygon").position.x = screenRect.x
	get_node("LowerRightPolygon").position.y = screenRect.y
	get_node("LowerCollision").position.y = screenRect.y
	get_node("LowerPolygon").position.y = screenRect.y
	get_node("LowerLeftCollision").position.x = -screenRect.x
	get_node("LowerLeftCollision").position.y = screenRect.y
	get_node("LowerLeftPolygon").position.x = -screenRect.x
	get_node("LowerLeftPolygon").position.y = screenRect.y

func _physics_process(delta):
	# Handle turning
	var turnDirection = (Input.is_physical_key_pressed(KEY_TURN_RIGHT) as int) - (Input.is_physical_key_pressed(KEY_TURN_LEFT) as int)
	if turnDirection != 0:
		updateRotation(turnDirection*TURN_SPEED)
		viewX = cos(get_node("CenterCollision").get_rotation())
		viewY = sin(get_node("CenterCollision").get_rotation())
		var direction = Vector2(velocity.x - viewX*20, velocity.y - viewY*20)

	# Handle acceleration
	if Input.is_physical_key_pressed(KEY_ACCELERATE):
		velocity.x += viewX*ACCELERATION
		velocity.y += viewY*ACCELERATION
		setExhaustEmitting(true)
	else:
		setExhaustEmitting(false)
		
	# Handle screen wrap
	var screenRect = get_viewport_rect().size
	if  position.x < 0:
		position.x += screenRect.x
	elif  position.x > screenRect.x:
		position.x -= screenRect.x
	elif  position.y < 0:
		position.y += screenRect.y
	elif  position.y > screenRect.y:
		position.y -= screenRect.y
		
		
	doMovement(velocity * delta)
		
	# Handle shoot
	if Input.is_physical_key_pressed(KEY_SHOOT):
		if shotReleased:
			shotReleased = false
			spawnBullet()
	else:
		shotReleased = true
	
func updateRotation(rot):
	for child in get_children():
		child.rotate(rot)

func setExhaustEmitting(isOn):
	exhaust.set_emitting(isOn)
	if isOn:
		exhaust.set_rotation(-get_node("CenterPolygon").get_rotation())
		var direction = Vector2(viewX*15, viewY*15)
		direction = velocity - direction.rotated(particleRng.randf_range(-0.3745, 0.3745))
		exhaust.set_direction(direction)
		exhaust.set_param_min(CPUParticles2D.Parameter.PARAM_INITIAL_LINEAR_VELOCITY, direction.length())
		exhaust.set_param_max(CPUParticles2D.Parameter.PARAM_INITIAL_LINEAR_VELOCITY, direction.length())
		
func spawnBullet():
	var bulletPosition = Vector2(position.x + viewX*50, position.y + viewY*50)
	var bulletVelocity = Vector2(viewX*BASE_BULLET_SPEED + velocity.x, viewY*BASE_BULLET_SPEED + velocity.y)

	add_sibling(Bullet.new(bulletPosition, bulletVelocity))
	
	
func collide(collisionInfo):
	var collider = collisionInfo["collider"]
	print(collider)
	print(collider.DAMAGE_DEALT_BASE)
	var collisionVector = collider.velocity - velocity
	var surfaceNormal = collisionInfo["surface"]
	var collisionShallowness = collisionVector.dot(surfaceNormal)
	var directionChange = collisionShallowness*collider.WEIGHT*surfaceNormal
	velocity += directionChange*ELASTICITY
	updateHealth(-getDamageValue(abs(collisionShallowness), collider.DAMAGE_DEALT_MULTIPLIER*DAMAGE_TAKEN_MULTIPLIER, max(0.1,collider.DAMAGE_DEALT_BASE-DAMAGE_TAKEN_BASE)))
	emitCollisionParticles(collisionVector, surfaceNormal, collisionInfo["position"])
	
#TODO: update damage calculation
func getDamageValue(collisionShallowness, damageMultiplier, damageBase):
	return damageMultiplier*collisionShallowness*damageBase
	
func emitCollisionParticles(collisionVector, surfaceNormal, collisionPoint):
	print(collisionPoint)
	var particlesMaterial = ParticleProcessMaterial.new()
	particlesMaterial.angle_max = 360
	var bouncedVector = collisionVector.bounce(surfaceNormal)
	particlesMaterial.direction = Vector3(bouncedVector.x, bouncedVector.y, 0)
	particlesMaterial.spread = 45
	var particlesVelocity = (collisionVector - velocity).length()
	particlesMaterial.initial_velocity_min = particlesVelocity * 0.01
	particlesMaterial.initial_velocity_max = particlesVelocity * 0.2
	particlesMaterial.gravity = Vector3.ZERO
	var particlesEmitter = GPUParticles2D.new()
	particlesEmitter.set_amount(10)
	particlesEmitter.set_explosiveness_ratio(1.0)
	particlesEmitter.set_one_shot(true)
	particlesEmitter.set_lifetime(2.0)
	particlesEmitter.set_randomness_ratio(0.5)
	particlesEmitter.set_process_material(particlesMaterial)
	particlesEmitter.position = collisionPoint
	get_parent().add_child(particlesEmitter)
	
	
func doMovement(movementVector):
	var collisionInfo = move_and_collide(movementVector)
	if collisionInfo:
		var collider = collisionInfo.get_collider()
		var surfaceNormal = collisionInfo.get_normal()
		
		var collisionDictSelf = {"collider": collider, "surface": surfaceNormal, "position": collisionInfo.get_position()}
		collide(collisionDictSelf)
		var collisionDictOther = {"collider": self, "surface": -surfaceNormal, "position": collisionInfo.get_position()}
		
		collider.collide(collisionDictOther)
		doMovement(ELASTICITY*collisionInfo.get_remainder().bounce(-surfaceNormal))
	

func updateHealth(healthChange):
	health += healthChange
	if health <= 0:
		destroy()
	
func setHealth(newValue):
	health = newValue

func destroy():
	health_depleted.emit(get_parent())
