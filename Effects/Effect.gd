extends AnimatedSprite


func _ready():
	connect("animation_finished", self, "_on_animation_finished")  # warning-ignore:return_value_discarded

	play("Animate")


func _on_animation_finished():
	queue_free()
