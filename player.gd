extends CharacterBody2D

var speed = 200

var last_direction = Vector2.ZERO

var animated_sprite
var enemy_is_range = false
var health = 100
var is_dead = false
var is_attacking = false
var attack_timer = 0.0
var attack_duration = 0.5
func _ready():
	animated_sprite = $AnimatedSprite2D
	add_to_group("Player")

func _physics_process(delta):
	
	update_health()
	die()
	update_animation()
	move_and_slide()
	
	if is_attacking:
		attack_timer += delta
	if attack_timer >= attack_duration:
		is_attacking = false
		attack_timer = 0.0

func update_animation():	
	if is_dead:
		return
		
	if is_attacking:
		if last_direction.x != 0:
			animated_sprite.play("attack")
		return
		
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = direction * speed
	
	if direction != Vector2.ZERO:
		last_direction = direction.normalized()
	
	if direction.x == 0:
		animated_sprite.play("idle")
	
	if direction.x != 0:
		animated_sprite.play("run_right")
	
	elif direction.y > 0:
		animated_sprite.play("run_forward")
		
	animated_sprite.flip_h = last_direction.x < 0
	
func _update(event): 
	if event.is_action_pressed("ui_select"):
		is_attacking = true
		attack_timer = 0.0	

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	if health > 100:
		healthbar.visible = false
	else:
		healthbar.visible = true 
		
func die():
	if health <= 0 and not is_dead:
		is_dead = true
		animated_sprite.play("die")
		queue_free()
		get_tree().change_scene_to_file("res://end_game.tscn")

func _on_hitbox_body_entered(body):
	if body.is_in_group("Enemy"):
		enemy_is_range = false
		print("Enemy exited")


func _on_hitbox_body_exited(body):
	if body.is_in_group("Enemy"):
		enemy_is_range = true
		print("Getting Swooped")
		


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "die":
		get_tree().change_scene_to_file("res://end_game.tscn")



		


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://world_2.tscn")
