extends CharacterBody2D
class_name Player

@export_category("Sound Settings")
@onready var audio_player: AudioStreamPlayer2D = $Sounds/waiting

@export var sound_paths: Dictionary = {
	"waiting": "res://Sounds/The_rustle_of_clothes.mp3"
}

var animation_sounds: Dictionary = {}

@export_category("Movement Settings")
@export var speed = 50
@export var sprint_speed = 90
@export var acceleration := 20 #Ускорение
@export var max_stamina = 100.0
@export var stamina_depletion_rate: float = 25.0  # Скорость расхода
@export var stamina_recovery_rate: float = 15.0   # Скорость восстановления

@onready var animated_sprite = $AnimatedSprite2D

var current_speed: int = speed
var current_stamina: float = max_stamina
var is_sprinting: bool = false
var debug_timer: float = 0.0
const DEBUG_UPDATE_INTERVAL: float = 0.5  # Интервал обновления в секундах


var input_direction := Vector2.ZERO
var last_direction := Vector2.ZERO
var is_moving := false
var idle_time := 0.0
var count: bool = false #переменная обзначающая, вызывалась ли анимация String

func _ready() -> void:
	animated_sprite.play("idle")
	_load_sounds()

'func print_debug_info():
	# Форматируем строки для вывода
	var stamina_percent = ceil((current_stamina / max_stamina) * 100)
	var speed_value = ceil(current_speed)
	
	var debug_string = "Debug Info | "
	debug_string += "Stamina: %d%% | " % stamina_percent
	debug_string += "Speed: %d | " % speed_value
	debug_string += "Sprinting: %s" % ("YES" if is_sprinting else "NO")
	
	# Выводим в консоль
	print(debug_string)
'
func _load_sounds():
	for anim_name in sound_paths:
		var path = sound_paths[anim_name]
		if ResourceLoader.exists(path):
			# Загружаем звук и сохраняем в словарь
			animation_sounds[anim_name] = load(path)
			print("Успешно загружен звук: ", path)
		else:
			push_error("Файл звука не найден: ", path)

func handle_stamina(delta: float):
	if Input.is_action_pressed("shift") and input_direction != Vector2.ZERO and current_stamina > 0:
		is_sprinting = true
		current_stamina = max(current_stamina - stamina_depletion_rate * delta, 0.0)
	else:
		is_sprinting = false
		current_stamina = min(current_stamina + stamina_recovery_rate * delta, max_stamina)

func _get_target_speed() -> float:
	return sprint_speed if (is_sprinting and current_stamina > 0) else speed

func play_waiting_animation():
	animated_sprite.play("waiting") #Проигрывается анимациа ожидания
	_play_sound("waiting") 

func _play_sound(anim_name: String):
	if not audio_player:
		push_error("AudioStreamPlayer2D не инициализирован")
		return
	
	if animation_sounds.has(anim_name):
		var sound = animation_sounds[anim_name]
		if sound:
			audio_player.stream = sound
			audio_player.play()
			print("Воспроизводится звук: ", anim_name)
		else:
			push_error("Звук не загружен для анимации: ", anim_name)
	else:
		push_error("Нет звука для анимации: ", anim_name)

func handle_movement_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("walk_side")
		animated_sprite.flip_h = direction.x < 0
	elif direction.y < 0:
		animated_sprite.play("walk_up")
	else:
		animated_sprite.play("walk_down")

func _physics_process(delta):
	debug_timer += delta
	if debug_timer >= DEBUG_UPDATE_INTERVAL:
		debug_timer = 0.0
		'print_debug_info()'
	
	input_direction = Input.get_vector("a", "d", "w", "s")
	
	handle_stamina(delta)
	
	var target_speed: int = _get_target_speed()
	current_speed = lerp(current_speed, target_speed, acceleration * delta)
	
	if input_direction.length() > 0:
		last_direction = input_direction
		velocity = input_direction * current_speed
	else:
		velocity = Vector2.ZERO
	
	if input_direction != Vector2.ZERO: 
		idle_time = 0.0
		count = false #персонаж подвигался и значит будет проигрываться
		handle_movement_animation(input_direction)#другая анимация и надо сбросить count 
	elif input_direction == Vector2.ZERO and idle_time < 30: # если персонаж не двигается меньше 5 секун
		handle_movement_animation(last_direction)
		animated_sprite.frame = 2
		idle_time += delta #и начинаем отсчет 
	if idle_time >= 30 and not count: #если персонаж не двигался дольше 5 секунд и анимация до этого не вызывалась
			play_waiting_animation()  # Выносим в отдельную функцию
			count = true
	
	move_and_slide()
	is_moving = velocity.length() > 10
