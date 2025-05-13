extends CharacterBody2D
#class_name Player

@export var speed = 100
@export var acceleration := 0.2 #Ускорение
@export var deceleration := 0.25 #Замедление

@onready var animated_sprite = $AnimatedSprite2D

var input_direction := Vector2.ZERO
var last_direction := Vector2.ZERO
var is_moving := false
var idle_time := 0.0
var count = false #переменная обзначающая, вызывалась ли анимация

func _ready() -> void:
	animated_sprite.play("idle")

func _physics_process(delta):
	input_direction = Input.get_vector("a", "d", "w", "s")
	if input_direction.length() > 0:
		last_direction = input_direction
	velocity = input_direction * speed
	
	if input_direction != Vector2.ZERO: 
		idle_time = 0.0
		count = false #персонаж подвигался и значит будет проигрываться
		handle_movement_animation(input_direction)#другая анимация и надо сбросить count 
	elif input_direction == Vector2.ZERO and idle_time < 5: # если персонаж не двигается меньше 5 секун
		handle_movement_animation(last_direction)
		animated_sprite.frame = 2
		
		idle_time += delta #и начинаем отсчет 
	elif input_direction == Vector2.ZERO and idle_time >= 5 and count == false: #если персонаж не двигался дольше 5 секунд и анимация до этого не вызывалась
			animated_sprite.play("waiting") #то мы вызываем анимацию ожидания
			count = true #и отмечаем что анимация проигралась 
		
	move_and_slide()
	is_moving = velocity.length() > 10
	
func handle_movement_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("walk_side")
		animated_sprite.flip_h = direction.x < 0
	elif direction.y < 0:
		animated_sprite.play("walk_up")
	else:
		animated_sprite.play("walk_down")
