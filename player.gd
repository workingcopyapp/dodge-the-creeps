extends Area2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var touch_target = null # Where a finger last touched, the player heads there.

func _ready():
	screen_size = get_viewport_rect().size
	hide()


# _input, as the background ColorRect would take touches before _unhandled_input.
func _input(event):
	# Touches can also arrive as a mouse with the button down.
	var touching = event is InputEventScreenTouch or event is InputEventScreenDrag
	if touching or (event is InputEventMouse and event.button_mask != 0):
		touch_target = event.position


func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed(&"move_right"):
		velocity.x += 1
	if Input.is_action_pressed(&"move_left"):
		velocity.x -= 1
	if Input.is_action_pressed(&"move_down"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up"):
		velocity.y -= 1
	if velocity == Vector2.ZERO and touch_target != null:
		if position.distance_to(touch_target) > speed * delta:
			velocity = touch_target - position
		else:
			touch_target = null

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = &"right"
		$AnimatedSprite2D.flip_v = false
		$Trail.rotation = 0
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = &"up"
		rotation = PI if velocity.y > 0 else 0


func start(pos):
	position = pos
	rotation = 0
	touch_target = null
	show()
	$CollisionShape2D.disabled = false


func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred(&"disabled", true)
