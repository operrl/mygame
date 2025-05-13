extends StaticBody2D

@export var is_locked := false
@onready var collision_shape := $CollisionShape2D
var is_open := false
var player_in_range = false

func _ready():
	get_tree().debug_collisions_hint = true
	update_collision()
	#body_entered.connect(_on_body_entered)
	#body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		
func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		
func _input(event):
	if event.is_action_pressed("interact"):
		toggle_door()

func update_collision():
	collision_shape.set_deferred("disabled", is_open)

func toggle_door():
	if !is_open:
		print("Дверь открыта")
		is_open = true
		update_collision()
	else:
		print("Дверь закрыта")
		is_open = false
		update_collision()
