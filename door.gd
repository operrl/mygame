extends StaticBody2D

@onready var collision_polygon := $CollisionPolygon2D
@onready var area2d = $Area2D
@onready var door_open = $door_open
@onready var door_close = $door_close
@onready var closeddoor = $closedDoor
var is_open := false
var player_in_range = false

func _ready():
	#get_tree().debug_collisions_hint = true #для дебага нужна чтобы подсвечивать коллизии 
	area2d.body_entered.connect(_on_body_entered)
	area2d.body_exited.connect(_on_body_exited)
	collision_polygon.set_deferred("disabled", false)
	closeddoor.visible = true
		
func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false

func _input(event):
	if event.is_action_pressed("interact") and player_in_range:
		toggle_door()

func update_collision():
	collision_polygon.set_deferred("disabled", is_open)

func toggle_door():
	if !is_open:
		is_open = true
		update_collision()
		door_open.play()
		closeddoor.visible = !is_open
	else:
		is_open = false
		update_collision()
		door_close.play()
		closeddoor.visible = !is_open
