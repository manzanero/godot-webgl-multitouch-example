extends Area2D


signal invincibility_started
signal invincibility_ended

const HitEffect = preload("res://Effects/HitEffect.tscn")

export(bool) var enemy_hurtbox = false

var invincible = false setget set_invincible

onready var timer = $Timer
onready var collider = $CollisionShape2D


func set_invincible(value):
	invincible = value
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")


func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)


func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position - Vector2(0, 8)


func _on_Timer_timeout():
	self.invincible = false


func _on_Hurtbox_invincibility_started():
	enemies_hurt(false)



func _on_Hurtbox_invincibility_ended():
	enemies_hurt(true)


func enemies_hurt(value):
	if not enemy_hurtbox:
		set_collision_layer_bit(2, value)  # recalculates enemies already inside
