class_name Collidable extends StaticBody2D

var health = 100
var WEIGHT = 1.0
var ELASTICITY = 0.5
var DAMAGE_DEALT_BASE = 1
var DAMAGE_DEALT_MULTIPLIER = 1
var ABSOLUTE_DAMAGE_REDUCTION = 0
var DAMAGE_TAKEN_MULTIPLIER = 1
var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(health = 100, WEIGHT = 1.0, ELASTICITY = 0.5, DAMAGE_DEALT_BASE = 1, DAMAGE_DEALT_MULTIPLIER = 1,  ABSOLUTE_DAMAGE_REDUCTION = 1,DAMAGE_TAKEN_MULTIPLIER = 1):
	self.health = health
	self.WEIGHT = WEIGHT
	self.ELASTICITY = ELASTICITY
	self.DAMAGE_DEALT_BASE = DAMAGE_DEALT_BASE
	self.DAMAGE_DEALT_MULTIPLIER = DAMAGE_DEALT_MULTIPLIER
	self.ABSOLUTE_DAMAGE_REDUCTION = ABSOLUTE_DAMAGE_REDUCTION
	self.DAMAGE_TAKEN_MULTIPLIER = DAMAGE_TAKEN_MULTIPLIER

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	doMovement(velocity * delta)
	
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
	
func collide(collisionInfo):
	print(self)
	var collider = collisionInfo["collider"]
	print(collider.velocity)
	var collisionVector = collider.velocity - velocity
	var surfaceNormal = collisionInfo["surface"]
	var collisionShallowness = collisionVector.dot(surfaceNormal)
	print(str(collisionVector) + " dot " + str(surfaceNormal))
	var directionChange = collisionShallowness/(collider.velocity.length() + velocity.length())*0.5*(collider.velocity.length()*collider.WEIGHT+velocity.length()*WEIGHT)*surfaceNormal
	print(str(collisionShallowness) + "/(" + str(collider.velocity.length()) + "+" + str(velocity.length()) + ")*0.5*(" + str(collider.velocity.length()) + "*" + str(collider.WEIGHT) + "+" + str(velocity.length()) + "*" + str(WEIGHT) + ")*" + str(surfaceNormal) + "=" + str(directionChange))
	changeVelocity(directionChange*ELASTICITY)
	changeHealth(-getDamageValue(abs(collisionShallowness), collider.DAMAGE_DEALT_MULTIPLIER*DAMAGE_TAKEN_MULTIPLIER, max(0.1,collider.DAMAGE_DEALT_BASE-ABSOLUTE_DAMAGE_REDUCTION)))
	emitCollisionParticles(collisionVector, surfaceNormal, collisionInfo["position"])
	
func getDamageValue(collisionShallowness, damageMultiplier, damageBase):
	return damageMultiplier*collisionShallowness*damageBase
	
func changeHealth(healthChange):
	health += healthChange
	if health <= 0:
		destroy()

func changeVelocity(velocityChange):
	velocity += velocityChange
		
func setHealth(newValue):
	health = newValue
	
func destroy():
	queue_free()
	
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
