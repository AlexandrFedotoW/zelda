extends CharacterBody2D

var speed = 50
var last_direction = Vector2.ZERO
var animated_sprite

var direction_change_timer = 0
var direction_change_interval = 3
var swoop = false
var player = null
var player_in_range = false
var swoop_speed = 75
var health = 50
var is_dead = false
var damage_timer = 0.0
var damage_interval = 0.5
var damage_from_player_timer = 0.0
var damage_from_player_interval = 0.5
var is_attacking = false
var min_position = Vector2(0, 0)
var max_position = Vector2(800,430)

func _ready():
	animated_sprite = $AnimatedSprite2D
	pick_random_direction()
	add_to_group("Enemy")

func _physics_process(delta):
	if player_in_range:
		damage_from_player_timer += delta
	if damage_from_player_timer >= damage_from_player_interval:
		health -=10
		print("Enemy health:", health)
		damage_from_player_timer = 0.0
		
	update_health()
	die()
	if swoop:
		var direction_to_player = (player.position - position).normalized()
		position += direction_to_player * swoop_speed * delta
		update_animation(direction_to_player, true)
	else:
		direction_change_timer += delta
		if direction_change_timer >= direction_change_interval:
			pick_random_direction()
			direction_change_timer = 0
		velocity = last_direction * speed
		update_animation(last_direction)
		animated_sprite.flip_h = false
		
	
	move_and_slide()
	
	var old_position = position
	position.x = clamp(position.x, min_position.x, max_position.x)
	position.y = clamp(position.y, min_position.y, max_position.y)
	
	if old_position != position:
		last_direction = -last_direction
		
	if player_in_range:
		damage_timer += delta
	if damage_timer >= damage_interval:
		player.health -= 10
		damage_timer = 0.0

func update_animation(direction, swooping=false):
	if is_dead or is_attacking:
		return
		
	if player_in_range and swooping:
		animated_sprite.play("enemy1_run")
		animated_sprite.flip_h = direction.x < 0 
		is_attacking = true
		return
	
	is_attacking = false	
	animated_sprite.flip_h=false
	
	if direction.x != 0: 
		animated_sprite.play("enemy1_run")
	
func pick_random_direction():
	while last_direction == Vector2.ZERO:
		last_direction = Vector2(randi() % 3 - 1, randi() % 3 -1)
	last_direction = last_direction.normalized()

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	if health > 50:
		healthbar.visible = false
	else:
		healthbar.visible = true 
		
func die():
	if health <= 0 and not is_dead:
		is_dead = true
		animated_sprite.play("enemy1_dead")
		queue_free()

func _on_enemy_1_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		print("Swooping")
		animated_sprite.flip_h = position.x > body.position.x
		swoop_speed = 0
	


func _on_enemy_1_hitbox_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		print("Exited")
		animated_sprite.flip_h = false
		swoop_speed = 75
		

 
func _on_territory_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		swoop = true


func _on_territory_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		swoop = false
		pick_random_direction()
		update_animation(last_direction)



