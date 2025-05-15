extends Area2D

var is_player_in = false
@onready var room = $room

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(body):
	if body.name == "Player":
		is_player_in = true
		room.modulate.a = 1.0

func _on_body_exited(body):
	if body.name == "Player":
		is_player_in = false
		var num: float = 1
		while num > 0.2:
			if is_player_in:
				break
			else:
				num -= 0.1
				room.modulate.a = num
				await get_tree().create_timer(0.1).timeout
