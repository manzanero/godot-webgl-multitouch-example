extends KinematicBody2D

const PlayerHurtSounds = preload("res://Player/PlayerHurtSound.tscn")

export(float) var max_speed = 80
export(float) var roll_speed = 125
export(float) var acceleration = 500
export(float) var fiction = 500

enum {
	MOVE,
	ROLL,
	ATTACK,
}

var state = MOVE
var velocity := Vector2.ZERO
var roll_vector := Vector2.DOWN  # initial direction
var stats = PlayerStats


onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var sword_hitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blink_animation_player = $BlinkAnimationPlayer


func _ready():
	stats.connect("no_health", self, "queue_free")
	animation_tree.active = true
	sword_hitbox.knockback_vector = roll_vector


func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)

		ROLL:
			roll_state(delta)

		ATTACK:
			attack_state(delta)


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		sword_hitbox.knockback_vector = input_vector
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_state.travel("Run")
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, fiction * delta)

	move()

	if Input.is_action_just_pressed("roll"):
		state = ROLL

	if Input.is_action_just_pressed("attack"):
		state = ATTACK


func roll_state(_delta):
	velocity = roll_vector * roll_speed
	animation_state.travel("Roll")
	move()


func move():
	velocity = move_and_slide(velocity)


func attack_state(_delta):
	velocity = Vector2.ZERO
	animation_state.travel("Attack")


func roll_animation_finished():
	state = MOVE


func attack_animation_finished():
	state = MOVE


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
	var player_hurt_sounds = PlayerHurtSounds.instance()
	get_tree().current_scene.add_child(player_hurt_sounds)


func _on_Hurtbox_invincibility_started():
	blink_animation_player.play("Start")


func _on_Hurtbox_invincibility_ended():
	blink_animation_player.play("Stop")
